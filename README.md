# SQL Server .Net C# Web API Boilerplate

This project is a simple boilerplate implementation of a .Net (C#) web API with a SQL Server database. This project includes several examples of various features of SQL.

## Overview

This project serves as a starting point for a C# web API with a SQL Server database. This project involves views, functions, stored procedures, etc. The C# code includes both read and write queries.

This project is provided as both a teaching tool and a boiler plate. This project has the MIT license. Meaning you can use this however you want, including commercially. However, I am not responsible nor liable for anything created.

## Setup and Installation

Here is a high level overview to get this running.

1. Install Visual Studio 2022
2. Install SQL Server 2022
3. Clone this repo
4. Install NuGet packages
4a. Microsoft.Data.SqlClient
4b. Microsoft.EntityFrameworkCore
4c. Microsoft.VisualStudio.Azure.Containers.Tools.Target
4d. Swashbuckle.AspNetCore
5. Install Docker Desktop (If using Docker)
6. Run create_database.sql in your SQL server. Remember to find and replace "ExampleCompany" with your company name.

## Running the Application

Simply follow the instructions above and build the docker image with visual studio.
Once the docker image is built, run as follows.
```bash
docker run -e ConnectionString="Server=host.docker.internal\\SQLEXPRESS;Database=ExampleCompany;User Id=myUser1;Password=myPass123;Encrypt=False;TrustServerCertificate=True;" IMAGENAME
```
Note: The provided connection string is an example. Replace with your connection string.
See https://stackoverflow.com/a/10479937

Note2: If you're using this as a docker container, remember that localhost is not the same for the container. Instead we would use ```host.docker.internal``` to reference the host. If the SQL Server instance is running in another docker container, you would reference it by the container's name. e.g. ```mySqlServer``` or ```mySqlServer.myNet1```.
See https://docs.docker.com/engine/network/

Note3: In debug mode, the connection string is stored as an environment variable under ```launchSettings.json``` in ```profiles.Container (Dockerfile).environmentVariables.ConnectionString```.

## How to add endpoints

See controllers/CompanyController.cs.
The function ```exampleEndpoint``` has comments describing how it works.

## API Endpoints

### /list-unpaid

Purpose: Returns list of employees and wages owed
Input: None
Returns: List of Employee with unpaid wages
```json
  [{
    "employee_id": 3,
    "wage": 250,
    "name": "Jose Doyle",
    "position": "manager"
  }, ...
```

### /log-hours

Purpose: Used to log hours for a specific day
Input: Employee ID, hours worked, work date
Returns: True if successful, False if an error occured

### /sell-item

Purpose: Used to handle selling items. Keeps track of inventory and employee commission
Input: Employee ID, Product ID, Number of items sold, price sold for
Returns: Status as an integer
```C#
// 0 - No Error
// 1 - Not enough inventory
// 2 - An unexpected number of rows were modified.
// 3 - An exception occurred (try/catch)
```

### /inventory

Purpose: Lists inventory
Input: None
Returns: List of Inventory items
``` json
  [{
    "inventory_id": 1,
    "product_id": 1,
    "quantity": 20,
    "msrp": 99.99,
    "name": "Velocity Pro",
    "brand": "Apex"
  }, ...
```

### /employees

Purpose: List employees
Input: None
Returns: List of Employees
```json
  [{
    "id": 3,
    "name": "Jose Doyle",
    "hourlyWage": 25
  }, ...
```

### /employee

Purpose: Fetch a single employee's details
Input: Employee ID
Returns: Single Employee
```json
{
  "id": 1,
  "name": "Lillian Malone",
  "hourlyWage": 7.5,
  "position": "sales",
  "commission": 0.25
}
```


## Database

This section is broken up into tables, views, functions, and stored procedures.

### Tables

#### employees

Purpose: Used to keep track of employees
Columns: id, name, hourly_wage, position, commission
Foreigns keys: None

#### employees_commission

Purpose: Used to keep track of employee's commission
Columns: id, employee_id, sale_date, paid_date, commission

Foreign keys: 
| local column | foreign table | referenced column |
|:-------------|:--------------|:------------------|
|employee_id|employees|id|

#### employee_hours

Purpose: Used to keep track of employee's hours
Columns: id, day, hours, employee_id, hourly_wage, paid_date

Foreign keys:
| local column | foreign table | referenced column |
|:-------------|:--------------|:------------------|
|employee_id|employees|id|

#### inventory

Purpose: Used to keep track of inventory
Columns: id, product_id, msrp, quantity

Foreign keys:
| local column | foreign table | referenced column |
|:-------------|:--------------|:------------------|
|product_id|products|id|

#### products

Purpose: Used to keep track of product details
Columns: id, name, brand

Foreign keys: None

#### sales

Purpose: Used to keep track of sales
Columns: id, product_id, employee_id, quantity, price, datetime

Foreign keys:
| local column | foreign table | referenced column |
|:-------------|:--------------|:------------------|
|product_id|products|id|
|employee_id|employees|id|

### views

#### inventory_detailed

This is a joined table between inventory and products.

### Functions

Below is a list of database functions.

#### has_item_quantity

Simple function to determine if product_id x has quantity y
Returns a bit (True/False) depending on result.

### Stored Prodecures

#### insert_hours

Inserts hours into employees_hours with wage calculated on current hourly_wage.

#### list_unpaid

Uses a Common Table Expression to sum commissions and hourly wage grouped by employee.

#### sell_item

Does the following:
1. Check if the inventory has enough of the requested item.
2. Attempts to insert the sale into the sales table.
3. Attempts to remove the requested amount of items from the inventory table.
4. If the an error occurs, the transaction will be rolled back.

A non-zero error code will be returned if an error occurs. See ```/sell-items``` endpoint.

See ```sales_commission``` trigger for commissions.

### Triggers

#### sales.sales_commission

Triggers each time a sale is inserted. If the responsible employee is paid commission, an entry will be added to the employee_commission table.

### Misc

Indexes and constraints are left as a challenge to the reader.

## Server-Side Code

This project is a C# .Net Core project. Below is an overview of the structure.

### Classes

In the root of the project is a "classes" folder. This folder contains the various classes used.

#### Employee

A class representation of the employee database table.

#### InventoryItem

A class representation of a single item in the inventory_detailed view.

#### Unpaid

A class representation of a single item returned in the list_unpaid stored procedure.

### Company Controller

This is where the bulk of the code resides. This file contains the functions related to the api. The example endpoint has detailed comment describing the purpose of each line and how to modify.

## License

MIT License. See license.txt