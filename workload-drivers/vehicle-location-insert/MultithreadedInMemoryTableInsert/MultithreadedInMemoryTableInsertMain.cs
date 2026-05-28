/*
 * Vehicle Location Insert — PostgreSQL version
 *
 * The original MSSQL demo tested OnDisk vs InMemory table insert performance using
 * SQL Server's In-Memory OLTP feature.  PostgreSQL has no equivalent distinction,
 * so both modes now write to the same table:
 *
 *   warehouse.vehiclelocations  — see postgres/Warehouse/Tables/VehicleLocations.sql
 */
using Npgsql;
using NpgsqlTypes;
using System;
using System.Threading;
using System.Windows.Forms;

namespace MultithreadedInMemoryTableInsert
{
    public partial class MultithreadedInMemoryTableInsertMain : Form
    {
        public bool errorHasOccurred;
        public string errorDetails = "";

        public MultithreadedInMemoryTableInsertMain()
        {
            InitializeComponent();
        }

        private void MultithreadedInMemoryTableInsertMain_Load(object sender, EventArgs e)
        {
            ConnectionStringTextBox.Text = Properties.Settings.Default.WWI_ConnectionString;
            if (ConnectionStringTextBox.Text.Length == 0)
            {
                ConnectionStringTextBox.Text = "Host=localhost;Database=wideworldimporters;Username=webapi;Password=Sp1d3rman!;Maximum Pool Size=250;";
            }
        }

        private void MultithreadedInMemoryTableInsertMain_FormClosing(object sender, FormClosingEventArgs e)
        {
            Properties.Settings.Default.WWI_ConnectionString = ConnectionStringTextBox.Text;
            Properties.Settings.Default.Save();
        }

        private void InsertButton_Click(object sender, EventArgs e)
        {
            InsertButton.Text = "Running";
            InsertButton.Refresh();

            errorHasOccurred = false;
            errorDetails = "";

            var connStr = ConnectionStringTextBox.Text.Length == 0
                ? "Host=localhost;Database=wideworldimporters;Username=webapi;Password=Sp1d3rman!;Maximum Pool Size=250;"
                : ConnectionStringTextBox.Text;

            var startingTime = DateTime.Now;

            try
            {
                int numberOfThreads = (int)NumberOfThreadsNumericUpDown.Value;
                var sqlTasks = new Thread[numberOfThreads];

                for (int i = 0; i < numberOfThreads; i++)
                {
                    int threadIndex = i;
                    sqlTasks[i] = new Thread(() => PerformSqlTask(threadIndex, this, connStr));
                    sqlTasks[i].Start();
                }

                foreach (var t in sqlTasks)
                    t.Join();
            }
            catch (Exception ex)
            {
                errorHasOccurred = true;
                errorDetails = ex.ToString();
            }

            InsertButton.Text = "&Insert";
            LastExecutionTimeTextBox.Text = ((int)DateTime.Now.Subtract(startingTime).TotalMilliseconds).ToString();

            if (errorHasOccurred)
            {
                var errorForm = new ErrorDetailsForm();
                errorForm.ErrorMessage = errorDetails;
                errorForm.ShowDialog();
            }
        }

        public void PerformSqlTask(int taskNumber, MultithreadedInMemoryTableInsertMain parentForm, string connStr)
        {
            try
            {
                using var conn = new NpgsqlConnection(connStr);
                conn.Open();

                using var cmd = conn.CreateCommand();
                // Both OnDisk and InMemory modes write to warehouse.vehicle_locations.
                // PostgreSQL has no in-memory OLTP distinction.
                cmd.CommandText =
                    @"INSERT INTO warehouse.vehiclelocations (RegistrationNumber, TrackedWhen, Longitude, Latitude)
                      VALUES (@reg, @when, @lon, @lat)";

                cmd.Parameters.Add("reg",  NpgsqlDbType.Varchar);
                cmd.Parameters.Add("when", NpgsqlDbType.TimestampTz);
                cmd.Parameters.Add("lon",  NpgsqlDbType.Numeric);
                cmd.Parameters.Add("lat",  NpgsqlDbType.Numeric);
                cmd.Prepare();

                var rnd = new Random();
                using var tran = conn.BeginTransaction();
                cmd.Transaction = tran;

                for (int i = 0; i < (int)NumberOfRowsPerThreadNumericUpDown.Value; i++)
                {
                    cmd.Parameters["reg"].Value  = "EA24-GL";
                    cmd.Parameters["when"].Value = DateTime.UtcNow;
                    cmd.Parameters["lon"].Value  = (decimal)rnd.Next(100);
                    cmd.Parameters["lat"].Value  = (decimal)rnd.Next(100);
                    cmd.ExecuteNonQuery();
                }

                tran.Commit();
            }
            catch (Exception ex)
            {
                parentForm.errorHasOccurred = true;
                parentForm.errorDetails = ex.ToString();
            }
        }
    }
}
