using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using wwi_app.Services;

namespace wwi_app.Controllers
{
    [Authorize]
    public class TestDashboardController : Controller
    {
        private readonly TestRunnerService _runner;

        public TestDashboardController(TestRunnerService runner)
        {
            _runner = runner;
        }

        public async Task<IActionResult> TestDashboard()
        {
            var tests = await _runner.DiscoverTestsAsync();
            return View("~/Views/TestDashboard/Index.cshtml", tests);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> RunTests()
        {
            if (_runner.Status == TestRunStatus.Running)
            {
                Response.StatusCode = 409;
                return Json(new { status = "Running", message = "A test run is already in progress." });
            }

            await _runner.StartRunAsync();
            return Json(new { runId = _runner.RunId, status = _runner.Status.ToString() });
        }

        public IActionResult TestStatus()
        {
            var results = _runner.GetResults() ?? new System.Collections.Generic.List<TestCaseResult>();

            int passed = results.Count(r => r.Outcome == "Passed");
            int failed = results.Count(r => r.Outcome == "Failed");
            int total = results.Count;

            return Json(new
            {
                status = _runner.Status.ToString(),
                runId = _runner.RunId,
                startedAt = _runner.StartedAt,
                completedAt = _runner.CompletedAt,
                summary = new { total, passed, failed, pending = total - passed - failed },
                results = results.Select(r => new
                {
                    r.ClassName,
                    r.MethodName,
                    r.Outcome,
                    r.DurationMs,
                    r.ErrorMessage
                })
            });
        }
    }
}
