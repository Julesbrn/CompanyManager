using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using CompanyManager.classes;

namespace CompanyManager.Controllers
{
    public class CompanyController : Controller
    {
        public CompanyController()
        {
        }

        //This creates a GET endpoint with the path "example-endpoint". Other options are POST, DELETE, OPTIONS, etc.
        [HttpGet("example-endpoint")]
        public IActionResult exampleEndpoint(int var1) // The name of the function does not matter.
        {
            //Note: @var1 is included to show how to safely use user sourced variables.
            string sql = @"SELECT col1, col2, col3, @var1 FROM myTable"; // Sql query goes here.
            using (var connection = new SqlConnection(Environment.GetEnvironmentVariable("ConnectionString"))) // We pull from the environment variable, modify accordingly.
            {
                connection.Open(); // Note: This does not create a new connection each time. Instead a pool is used. If there is an active connection to the database, it will use that. Otherwise it will create a connection.
                using (SqlCommand cmd2 = new SqlCommand()) // We use the SqlCommand object to run sql queries.
                {
                    cmd2.Connection = connection; // Now that we have a SqlCommand object, set the connection and sql statement.
                    cmd2.CommandText = sql;

                    cmd2.Parameters.AddWithValue("@var1", var1); // This is how we prevent sql injections. DO NOT USE STRING CONCATENATION. https://owasp.org/Top10/A03_2021-Injection/

                    List<Unpaid> ret = new List<Unpaid>(); //If you want to return a list, initialize a list like this.

                    using (SqlDataReader reader = cmd2.ExecuteReader()) //This is for a reader. See ExecuteNonQuery for non queries.
                    {
                        // Each time we call .Read(), we read a new row.
                        // We can then reference the column number by its index.
                        // This is why we do not use SELECT *, we instead have a fixed number of columns returned.
                        // When we run out of columns, the while loop will exit.
                        throw new Exception("Not Implemented."); // Remove this.
                        while (reader.Read()) 
                        {
                            // .Net prefers we use classes for returning data. So we created a class and initialize it.
                            Unpaid tmp = new Unpaid();


                            //Now we fill in data. Calling reader.GetTYPE(x) is optional, but recommended.
                            tmp.employee_id = reader.GetInt64(0);
                            tmp.wage = (decimal)reader.GetDouble(1);
                            tmp.name = reader.GetString(2);
                            tmp.position = reader.GetString(3);

                            // Add it to the list
                            ret.Add(tmp);
                        }
                    }
                    // This is commented out because this function is not fully implemented.
                    // Modify the return type to match the class or List<class> required.
                    //return StatusCode(200, ret);
                }
            }
            // This is how you return data. You can pass custom objects here instead of the string.
            return StatusCode(501, "Not Implemented."); // Be sure to modify this.
        }

        [HttpGet("list-unpaid")]
        public IActionResult listUnpaid()
        {
            try
            {
                string sql = @"EXECUTE [dbo].[list_unpaid]";
                using (var connection = new SqlConnection(Environment.GetEnvironmentVariable("ConnectionString")))
                {
                    connection.Open();
                    using (SqlCommand cmd2 = new SqlCommand())
                    {
                        cmd2.Connection = connection;
                        cmd2.CommandText = sql;

                        List<Unpaid> ret = new List<Unpaid>();

                        using (SqlDataReader reader = cmd2.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                Unpaid tmp = new Unpaid();
                                tmp.employee_id = reader.GetInt64(0);
                                tmp.wage = (decimal)reader.GetDouble(1);
                                tmp.name = reader.GetString(2);
                                tmp.position = reader.GetString(3);

                                //Console.WriteLine($":{tmp.employee_id}:{tmp.wage}:");
                                ret.Add(tmp);
                            }
                        }
                        return StatusCode(200, ret);
                    }
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Error");
            }
        }

        [HttpPost("log-hours")]
        public IActionResult logHours(Int64 employee_id, decimal hours, DateTime day)
        {
            string sql = @"
EXECUTE [dbo].[insert_hours] 
   @employee_id
  ,@hours
  ,@day
";
            try
            {
                using (var connection = new SqlConnection(Environment.GetEnvironmentVariable("ConnectionString")))
                {
                    connection.Open();
                    using (SqlCommand cmd2 = new SqlCommand())
                    {
                        cmd2.CommandText = sql;
                        cmd2.Parameters.AddWithValue("@employee_id", employee_id);
                        cmd2.Parameters.AddWithValue("@hours", hours);
                        cmd2.Parameters.AddWithValue("@day", day);
                        cmd2.Connection = connection;

                        int rows = cmd2.ExecuteNonQuery();

                        if (rows > 0) return StatusCode(200, true);
                        else return StatusCode(200, false);
                    }
                }
            }
            catch (Exception)
            {
                return StatusCode(500, "Error");
            }
        }

        [HttpPost("sell-item")]
        public IActionResult sellItem(Int64 employee_id, Int64 product_id, Int64 sell_amount, decimal price)
        {
            string sql = @"
DECLARE @error tinyint
EXECUTE [dbo].[sell_item] 
   @employee_id
  ,@product_id
  ,@sell_amount
  ,@price
  ,@error OUTPUT
SELECT @error as res
";
            try
            {
                using (var connection = new SqlConnection(Environment.GetEnvironmentVariable("ConnectionString")))
                {
                    connection.Open();
                    using (SqlCommand cmd2 = new SqlCommand())
                    {
                        cmd2.CommandText = sql;
                        cmd2.Parameters.AddWithValue("@employee_id", employee_id);
                        cmd2.Parameters.AddWithValue("@product_id", product_id);
                        cmd2.Parameters.AddWithValue("@sell_amount", sell_amount);
                        cmd2.Parameters.AddWithValue("@price", price);
                        cmd2.Connection = connection;

                        using (SqlDataReader reader = cmd2.ExecuteReader())
                        {
                            reader.Read(); // We only need one value.
                            int ret = reader.GetByte(0);
                            // 0 - No Error
                            // 1 - Not enough inventory
                            // 2 - An unexpected number of rows were modified.
                            // 3 - An exception occurred (try/catch)

                            return StatusCode(200, ret);
                        }
                    }
                }
            }
            catch (Exception)
            {
                return StatusCode(500, "error");
            }
        }

        [HttpGet("inventory")]
        public IActionResult inventory()
        {
            string sql = @"SELECT [inventory_id],[product_id],[quantity],[msrp],[name],[brand] FROM [inventory_detailed]";
            try
            {
                using (var connection = new SqlConnection(Environment.GetEnvironmentVariable("ConnectionString")))
                {
                    connection.Open();
                    using (SqlCommand cmd2 = new SqlCommand())
                    {
                        cmd2.Connection = connection;
                        cmd2.CommandText = sql;

                        List<InventoryItem> inventory = new List<InventoryItem>();

                        using (SqlDataReader reader = cmd2.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                InventoryItem tmp = new InventoryItem();
                                tmp.inventory_id = reader.GetInt64(0);
                                tmp.product_id = reader.GetInt64(1);
                                tmp.quantity = reader.GetInt64(2);
                                tmp.msrp = reader.GetDecimal(3);
                                tmp.name = reader.GetString(4);
                                tmp.brand = reader.GetString(5);

                                inventory.Add(tmp);
                            }
                        }
                        return StatusCode(200, inventory);
                    }
                }
            }
            catch (Exception)
            {
                return StatusCode(500, "error");
            }
        }

        [HttpGet("employees")]
        public IActionResult employees()
        {
            string sql = @"select id, name, hourly_wage from employees";
            try
            {
                using (var connection = new SqlConnection(Environment.GetEnvironmentVariable("ConnectionString")))
                {
                    connection.Open();
                    using (SqlCommand cmd2 = new SqlCommand())
                    {
                        cmd2.Connection = connection;
                        cmd2.CommandText = sql;

                        List<Employee> employees = new List<Employee>();

                        //StringBuilder ret = new StringBuilder();
                        using (SqlDataReader reader = cmd2.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                Console.WriteLine(String.Format("{0}", reader[0]));
                                Employee tmp = new Employee(reader.GetInt64(0), reader.GetString(1), reader.GetDecimal(2));
                                employees.Add(tmp);
                            }
                        }
                        return StatusCode(200, employees);
                    }
                }
            }
            catch (Exception)
            {
                return StatusCode(500, "Error");
            }
        }

        [HttpGet("employee")]
        public IActionResult employee(int id)
        {
            try
            {
                string sql = @"select id, name, hourly_wage, position, commission from employees where id = @id";
                using (var connection = new SqlConnection(Environment.GetEnvironmentVariable("ConnectionString")))
                {
                    connection.Open();
                    using (SqlCommand cmd2 = new SqlCommand())
                    {
                        cmd2.Connection = connection;
                        cmd2.CommandText = sql;
                        cmd2.Parameters.AddWithValue("@id", id);

                        using (SqlDataReader reader = cmd2.ExecuteReader())
                        {
                            reader.Read();
                            Employee ret = new Employee();
                            ret.Id = reader.GetInt64(0);
                            ret.Name = reader.GetString(1);
                            ret.HourlyWage = reader.GetDecimal(2);
                            ret.position = reader.GetString(3);
                            ret.commission = reader.GetDecimal(4);
                            return Ok(ret);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"An error occurred while processing your request for employee id {id}.");
            }
        }
    }
}