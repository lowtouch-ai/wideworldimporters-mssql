using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace wwi_app.Services
{
    public enum TestRunStatus { Idle, Running, Completed, Failed }

    public record TestCaseSummary(string ClassName, string MethodName);

    public record TestCaseResult(
        string ClassName,
        string MethodName,
        string Outcome,
        double DurationMs,
        string? ErrorMessage);

    public class TestRunnerService
    {
        private static readonly string TestProjectPath =
            Directory.Exists("/tests/wwi-app.Tests")
                ? "/tests/wwi-app.Tests"
                : Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "../../../../wwi-app.Tests"));

        private static readonly XNamespace TrxNs =
            "http://microsoft.com/schemas/VisualStudio/TeamTest/2010";

        private readonly SemaphoreSlim _lock = new(1, 1);


        public TestRunStatus Status     { get; private set; } = TestRunStatus.Idle;
        public string?       RunId      { get; private set; }
        public DateTimeOffset? StartedAt   { get; private set; }
        public DateTimeOffset? CompletedAt { get; private set; }
        public int?          ExitCode   { get; private set; }
        private string?      _trxPath;

        public async Task<List<TestCaseSummary>> DiscoverTestsAsync()
        {
            var psi = new ProcessStartInfo("dotnet", $"test \"{TestProjectPath}\" --list-tests")
            {
                RedirectStandardOutput = true,
                RedirectStandardError  = true,
                UseShellExecute        = false,
                CreateNoWindow         = true
            };

            using var proc = Process.Start(psi)!;
            var output = await proc.StandardOutput.ReadToEndAsync();
            await proc.WaitForExitAsync();

            return output
                .Split('\n', StringSplitOptions.RemoveEmptyEntries)
                .Where(l => l.StartsWith("    "))
                .Select(l => l.Trim())
                .Select(ParseTestName)
                .Where(t => t != null)
                .Select(t => t!)
                .ToList();
        }

        public async Task StartRunAsync()
        {
            if (!await _lock.WaitAsync(0)) return;

            RunId = Guid.NewGuid().ToString("N");
            var resultsDir = Path.Combine(Path.GetTempPath(), "wwi-tests", RunId);
            Directory.CreateDirectory(resultsDir);
            _trxPath = Path.Combine(resultsDir, "results.trx");

            Status      = TestRunStatus.Running;
            StartedAt   = DateTimeOffset.UtcNow;
            CompletedAt = null;
            ExitCode    = null;

            var psi = new ProcessStartInfo(
                "dotnet",
                $"test \"{TestProjectPath}\" --logger \"trx;LogFileName=results.trx\" --results-directory \"{resultsDir}\" --verbosity detailed")
            {
                RedirectStandardOutput = true,
                RedirectStandardError  = true,
                UseShellExecute        = false,
                CreateNoWindow         = true
            };

            var proc = Process.Start(psi)!;

            // Drain stdout/stderr to prevent OS pipe-buffer deadlock (64 KB limit)
            var stdoutTask = Task.Run(() => proc.StandardOutput.ReadToEndAsync());

            // Drain stderr to prevent buffer deadlock
            var stderrTask = Task.Run(() => proc.StandardError.ReadToEndAsync());

            _ = Task.Run(async () =>
            {
                try
                {
                    await Task.WhenAll(stdoutTask, stderrTask);
                    await proc.WaitForExitAsync();
                    ExitCode    = proc.ExitCode;
                    CompletedAt = DateTimeOffset.UtcNow;
                    Status      = proc.ExitCode == 0 ? TestRunStatus.Completed : TestRunStatus.Failed;
                }
                finally
                {
                    proc.Dispose();
                    _lock.Release();
                }
            });
        }

        // During a run: regex-parses the partial TRX file (FileShare.ReadWrite so we
        // don't block the writer). Each <UnitTestResult> is flushed by the TRX logger
        // as each test completes, giving true incremental progress.
        // After completion: same path — the full file is now valid XML, regex still works.
        public List<TestCaseResult>? GetResults()
        {
            if (_trxPath == null || !File.Exists(_trxPath)) return null;
            try
            {
                string content;
                using (var fs = new FileStream(_trxPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
                using (var sr = new StreamReader(fs, Encoding.UTF8))
                    content = sr.ReadToEnd();

                var results = new List<TestCaseResult>();

                // Match every opening <UnitTestResult …> tag — safe on partial/incomplete XML
                foreach (Match tag in Regex.Matches(content, @"<UnitTestResult\s([^>]+?)(?:/>|>)", RegexOptions.Singleline))
                {
                    var attrs    = tag.Value;
                    var testName = GetAttr(attrs, "testName");
                    var outcome  = GetAttr(attrs, "outcome") ?? "Unknown";
                    var duration = ParseDuration(GetAttr(attrs, "duration"));

                    // Error message lives inside the element body — only present when the
                    // closing tag has already been written (i.e. the element is complete)
                    string? errorMsg = null;
                    var bodyEnd = content.IndexOf("</UnitTestResult>", tag.Index, StringComparison.Ordinal);
                    if (bodyEnd > 0)
                    {
                        var body     = content.Substring(tag.Index, bodyEnd - tag.Index);
                        var errMatch = Regex.Match(body, @"<Message>(.*?)</Message>", RegexOptions.Singleline);
                        if (errMatch.Success)
                            errorMsg = WebUtility.HtmlDecode(errMatch.Groups[1].Value);
                    }

                    results.Add(new TestCaseResult(
                        ExtractClassName(testName),
                        ExtractMethodName(testName),
                        outcome, duration, errorMsg));
                }

                return results.Count > 0 ? results : null;
            }
            catch { return null; }
        }

        // ── Private helpers ───────────────────────────────────────────────────

        private static string? GetAttr(string xml, string attr)
        {
            var m = Regex.Match(xml, attr + @"=""([^""]*)""");
            return m.Success ? m.Groups[1].Value : null;
        }

        private static TestCaseSummary? ParseTestName(string line)
        {
            var parts = line.Split('.');
            if (parts.Length < 2) return null;
            return new TestCaseSummary(parts[^2], parts[^1]);
        }

        private static string ExtractClassName(string? fullName)
        {
            if (fullName == null) return "Unknown";
            var parts = fullName.Split('.');
            return parts.Length >= 2 ? parts[^2] : fullName;
        }

        private static string ExtractMethodName(string? fullName)
        {
            if (fullName == null) return "Unknown";
            return fullName.Split('.')[^1];
        }

        private static double ParseDuration(string? raw)
        {
            if (raw == null) return 0;
            return TimeSpan.TryParse(raw, out var ts) ? ts.TotalMilliseconds : 0;
        }
    }
}
