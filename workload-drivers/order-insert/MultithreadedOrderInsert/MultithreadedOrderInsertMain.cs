using Dapper;
using Npgsql;
using NpgsqlTypes;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Windows.Forms;

namespace MultithreadedInMemoryTableInsert
{
    // Composite types matching website.order_list and website.order_line_list in PostgreSQL.
    // Field names must match the PostgreSQL composite type attribute names (case-insensitive).
    [PgName("website.order_list")]
    public class OrderList
    {
        public int OrderReference { get; set; }
        public int CustomerID { get; set; }
        public int ContactPersonID { get; set; }
        public DateOnly ExpectedDeliveryDate { get; set; }
        public string CustomerPurchaseOrderNumber { get; set; } = "";
        public bool IsUndersupplyBackordered { get; set; }
        public string Comments { get; set; } = "";
        public string DeliveryInstructions { get; set; } = "";
    }

    [PgName("website.order_line_list")]
    public class OrderLineList
    {
        public int OrderReference { get; set; }
        public int StockItemID { get; set; }
        public string Description { get; set; } = "";
        public int Quantity { get; set; }
    }

    public partial class MultithreadedOrderInsertMain : Form
    {
        public bool errorHasOccurred;
        public string errorDetails = "";

        private Thread[] sqlTasks = Array.Empty<Thread>();
        private Int64 totalOrders;
        private Int64 totalMilliseconds;

        private NpgsqlDataSource? _dataSource;

        public MultithreadedOrderInsertMain()
        {
            InitializeComponent();
        }

        private void MultithreadedOrderInsertMain_Load(object sender, EventArgs e)
        {
            ConnectionStringTextBox.Text = MultithreadedOrderInsert.Properties.Settings.Default.WWI_ConnectionString;
            if (ConnectionStringTextBox.Text.Length == 0)
            {
                ConnectionStringTextBox.Text = "Host=localhost;Database=wideworldimporters;Username=webapi;Password=Sp1d3rman!;Maximum Pool Size=250;";
            }
        }

        private void MultithreadedOrderInsertMain_FormClosing(object sender, FormClosingEventArgs e)
        {
            MultithreadedOrderInsert.Properties.Settings.Default.WWI_ConnectionString = ConnectionStringTextBox.Text;
            MultithreadedOrderInsert.Properties.Settings.Default.Save();
            _dataSource?.Dispose();
        }

        public void UpdateTotals(int millisecondsForOrder)
        {
            lock (this)
            {
                totalOrders += 1;
                totalMilliseconds += millisecondsForOrder;
            }
        }

        private void InsertButton_Click(object sender, EventArgs e)
        {
            if (InsertButton.Text == "&Insert")
            {
                InsertButton.Text = "&Stop Now";
                InsertButton.Refresh();
                this.Refresh();
                DisplayUpdateTimer.Enabled = true;

                errorHasOccurred = false;
                errorDetails = "";
                totalOrders = 0;
                totalMilliseconds = 0;

                var connStr = ConnectionStringTextBox.Text.Length == 0
                    ? "Host=localhost;Database=wideworldimporters;Username=webapi;Password=Sp1d3rman!;Maximum Pool Size=250;"
                    : ConnectionStringTextBox.Text;

                // Build a typed data source once per session so composite type mappings are registered.
                _dataSource?.Dispose();
                var builder = new NpgsqlDataSourceBuilder(connStr);
                builder.MapComposite<OrderList>("website.order_list");
                builder.MapComposite<OrderLineList>("website.order_line_list");
                _dataSource = builder.Build();

                try
                {
                    int numberOfThreads = (int)NumberOfThreadsNumericUpDown.Value;
                    sqlTasks = new Thread[numberOfThreads];
                    for (int i = 0; i < numberOfThreads; i++)
                    {
                        int threadIndex = i;
                        sqlTasks[i] = new Thread(() => PerformSqlTask(threadIndex, this));
                        sqlTasks[i].Start();
                    }
                }
                catch (Exception ex)
                {
                    errorHasOccurred = true;
                    errorDetails = ex.ToString();
                }

                if (errorHasOccurred)
                {
                    var errorForm = new ErrorDetailsForm();
                    errorForm.ErrorMessage = errorDetails;
                    errorForm.ShowDialog();
                }
            }
            else
            {
                InsertButton.Text = "Stopping";
                InsertButton.Refresh();
                DisplayUpdateTimer.Enabled = false;
                foreach (var t in sqlTasks)
                    t.Interrupt();
                InsertButton.Text = "&Insert";
            }
        }

        public void PerformSqlTask(int taskNumber, MultithreadedOrderInsertMain parentForm)
        {
            if (_dataSource is null) return;
            var rnd = new Random(taskNumber);

            while (true)
            {
                try
                {
                    var startingTime = DateTime.Now;

                    using var conn = _dataSource.OpenConnection();

                    // Pick a random employee as salesperson.
                    var salespersonID = conn.QueryFirst<int>(
                        "SELECT PersonID FROM application.people WHERE IsEmployee ORDER BY random() LIMIT 1");

                    // Pick a random customer for the order header.
                    var order = conn.QueryFirst(
                        @"SELECT 1 AS OrderReference,
                                 c.CustomerID,
                                 c.PrimaryContactPersonID AS ContactPersonID,
                                 (CURRENT_DATE + INTERVAL '1 day')::date AS ExpectedDeliveryDate,
                                 CAST(FLOOR(random() * 10000 + 1) AS text) AS CustomerPurchaseOrderNumber,
                                 false AS IsUndersupplyBackordered,
                                 'Auto-generated' AS Comments,
                                 c.DeliveryAddressLine1 || ', ' || c.DeliveryAddressLine2 AS DeliveryInstructions
                          FROM sales.customers AS c ORDER BY random() LIMIT 1");

                    var orders = new List<OrderList>
                    {
                        new OrderList
                        {
                            OrderReference              = 1,
                            CustomerID                  = (int)((IDictionary<string, object>)order)["customerid"],
                            ContactPersonID             = (int)((IDictionary<string, object>)order)["contactpersonid"],
                            ExpectedDeliveryDate        = DateOnly.FromDateTime(DateTime.Today.AddDays(1)),
                            CustomerPurchaseOrderNumber = ((IDictionary<string, object>)order)["customerpurchaseordernumber"]?.ToString() ?? "",
                            IsUndersupplyBackordered    = false,
                            Comments                    = "Auto-generated",
                            DeliveryInstructions        = ((IDictionary<string, object>)order)["deliveryinstructions"]?.ToString() ?? ""
                        }
                    };

                    // Pick random non-chiller stock lines; occasionally add a chiller item.
                    var lineQuery =
                        @"SELECT StockItemID, StockItemName AS Description
                          FROM warehouse.stockitems
                          WHERE IsChillerStock = false ORDER BY random() LIMIT 7";
                    var lineRows = conn.Query(lineQuery);

                    var orderLines = new List<OrderLineList>();
                    foreach (var row in lineRows)
                    {
                        var d = (IDictionary<string, object>)row;
                        orderLines.Add(new OrderLineList
                        {
                            OrderReference = 1,
                            StockItemID    = (int)d["stockitemid"],
                            Description    = d["description"]?.ToString() ?? "",
                            Quantity       = rnd.Next(1, 10)
                        });
                    }

                    if (rnd.Next(1, 100) < 4)
                    {
                        var chiller = conn.QueryFirstOrDefault(
                            "SELECT StockItemID, StockItemName AS Description FROM warehouse.stockitems WHERE IsChillerStock ORDER BY random() LIMIT 1");
                        if (chiller != null)
                        {
                            var d = (IDictionary<string, object>)chiller;
                            orderLines.Add(new OrderLineList
                            {
                                OrderReference = 1,
                                StockItemID    = (int)d["stockitemid"],
                                Description    = d["description"]?.ToString() ?? "",
                                Quantity       = rnd.Next(1, 10)
                            });
                        }
                    }

                    // Call the PostgreSQL function with composite-type arrays.
                    using var cmd = conn.CreateCommand();
                    cmd.CommandText = "SELECT website.insert_customer_orders(@orders, @lines, @createdBy, @salesperson)";
                    cmd.Parameters.Add(new NpgsqlParameter("orders", orders.ToArray()));
                    cmd.Parameters.Add(new NpgsqlParameter("lines", orderLines.ToArray()));
                    cmd.Parameters.Add(new NpgsqlParameter("createdBy", salespersonID));
                    cmd.Parameters.Add(new NpgsqlParameter("salesperson", salespersonID));
                    cmd.ExecuteNonQuery();

                    parentForm.UpdateTotals((int)DateTime.Now.Subtract(startingTime).TotalMilliseconds);
                }
                catch (ThreadInterruptedException)
                {
                    break;
                }
                catch (Exception ex)
                {
                    parentForm.errorHasOccurred = true;
                    parentForm.errorDetails = ex.ToString();
                    break;
                }
            }
        }

        private void DisplayUpdateTimer_Tick(object sender, EventArgs e)
        {
            if (totalOrders > 0)
            {
                AverageOrderInsertionTimeTextBox.Text = (totalMilliseconds / totalOrders).ToString();
                AverageOrderInsertionTimeTextBox.Refresh();
                this.Refresh();
            }
        }
    }
}
