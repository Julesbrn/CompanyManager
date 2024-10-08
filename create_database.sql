USE [master]
GO
/****** Object:  Database [ExampleCompany]    Script Date: 9/15/2024 1:26:59 PM ******/
CREATE DATABASE [ExampleCompany]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ExampleCompany', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\ExampleCompany.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'ExampleCompany_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\ExampleCompany_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [ExampleCompany] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ExampleCompany].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ExampleCompany] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ExampleCompany] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ExampleCompany] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ExampleCompany] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ExampleCompany] SET ARITHABORT OFF 
GO
ALTER DATABASE [ExampleCompany] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ExampleCompany] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ExampleCompany] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ExampleCompany] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ExampleCompany] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ExampleCompany] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ExampleCompany] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ExampleCompany] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ExampleCompany] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ExampleCompany] SET  DISABLE_BROKER 
GO
ALTER DATABASE [ExampleCompany] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ExampleCompany] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ExampleCompany] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ExampleCompany] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ExampleCompany] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ExampleCompany] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ExampleCompany] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ExampleCompany] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [ExampleCompany] SET  MULTI_USER 
GO
ALTER DATABASE [ExampleCompany] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ExampleCompany] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ExampleCompany] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ExampleCompany] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [ExampleCompany] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [ExampleCompany] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [ExampleCompany] SET QUERY_STORE = ON
GO
ALTER DATABASE [ExampleCompany] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [ExampleCompany]
GO
/****** Object:  User [user2]    Script Date: 9/15/2024 1:27:00 PM ******/
CREATE USER [user2] FOR LOGIN [user2] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [user1]    Script Date: 9/15/2024 1:27:00 PM ******/
CREATE USER [user1] FOR LOGIN [user1] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  UserDefinedFunction [dbo].[has_item_quantity]    Script Date: 9/15/2024 1:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[has_item_quantity]
(
	@product_id BIGINT,
	@requested_amount BIGINT
)
RETURNS BIT -- TRUE/FALSE
AS
BEGIN
	DECLARE @available BIT
	DECLARE @current_amount BIGINT

	-- Get the current amount
	SELECT @current_amount = i.quantity
	FROM inventory i
	INNER JOIN products p
	ON i.product_id = p.id
	WHERE i.product_id = @product_id


	-- Check if amount is available
	IF @current_amount >= @requested_amount
		SET @available = 1
	ELSE
		SET @available = 0

	return @available
END
GO
/****** Object:  Table [dbo].[inventory]    Script Date: 9/15/2024 1:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[inventory](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[product_id] [bigint] NOT NULL,
	[msrp] [money] NOT NULL,
	[quantity] [bigint] NOT NULL,
 CONSTRAINT [PK_inventory] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[products]    Script Date: 9/15/2024 1:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[products](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[name] [text] NULL,
	[brand] [text] NULL,
 CONSTRAINT [PK_products] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[inventory_detailed]    Script Date: 9/15/2024 1:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[inventory_detailed]
AS
SELECT i.id AS inventory_id, i.product_id, i.quantity, i.msrp, p.name, p.brand
FROM     dbo.inventory AS i INNER JOIN
                  dbo.products AS p ON i.product_id = p.id
GO
/****** Object:  Table [dbo].[employees]    Script Date: 9/15/2024 1:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[employees](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[name] [text] NOT NULL,
	[hourly_wage] [smallmoney] NOT NULL,
	[position] [text] NULL,
	[commission] [numeric](7, 4) NOT NULL,
 CONSTRAINT [PK_employees] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[employees_commission]    Script Date: 9/15/2024 1:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[employees_commission](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[employee_id] [bigint] NOT NULL,
	[sale_date] [date] NOT NULL,
	[paid_date] [date] NULL,
	[commission] [money] NOT NULL,
 CONSTRAINT [PK_employees_commission] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[employees_hours]    Script Date: 9/15/2024 1:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[employees_hours](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[day] [date] NOT NULL,
	[hours] [float] NOT NULL,
	[employee_id] [bigint] NOT NULL,
	[hourly_wage] [smallmoney] NOT NULL,
	[paid_date] [date] NULL,
 CONSTRAINT [PK_employees_hours] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sales]    Script Date: 9/15/2024 1:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sales](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[product_id] [bigint] NOT NULL,
	[employee_id] [bigint] NOT NULL,
	[quantity] [bigint] NOT NULL,
	[price] [money] NOT NULL,
	[datetime] [datetime] NOT NULL,
 CONSTRAINT [PK_sales] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[employees] ON 

INSERT [dbo].[employees] ([id], [name], [hourly_wage], [position], [commission]) VALUES (1, N'Lillian Malone', 7.5000, N'sales', CAST(0.2500 AS Numeric(7, 4)))
INSERT [dbo].[employees] ([id], [name], [hourly_wage], [position], [commission]) VALUES (2, N'Patricia Terry', 9.0000, N'sales', CAST(0.0000 AS Numeric(7, 4)))
INSERT [dbo].[employees] ([id], [name], [hourly_wage], [position], [commission]) VALUES (3, N'Jose Doyle', 25.0000, N'manager', CAST(0.0000 AS Numeric(7, 4)))
INSERT [dbo].[employees] ([id], [name], [hourly_wage], [position], [commission]) VALUES (4, N'Chad Cline', 7.2500, N'sales', CAST(0.0000 AS Numeric(7, 4)))
INSERT [dbo].[employees] ([id], [name], [hourly_wage], [position], [commission]) VALUES (5, N'Terrance Riggs', 8.5000, N'inventory manager', CAST(0.0000 AS Numeric(7, 4)))
SET IDENTITY_INSERT [dbo].[employees] OFF
GO
SET IDENTITY_INSERT [dbo].[employees_commission] ON 

INSERT [dbo].[employees_commission] ([id], [employee_id], [sale_date], [paid_date], [commission]) VALUES (1, 1, CAST(N'2024-09-08' AS Date), NULL, 93.7500)
INSERT [dbo].[employees_commission] ([id], [employee_id], [sale_date], [paid_date], [commission]) VALUES (2, 1, CAST(N'2024-09-10' AS Date), NULL, 12.4950)
INSERT [dbo].[employees_commission] ([id], [employee_id], [sale_date], [paid_date], [commission]) VALUES (3, 1, CAST(N'2024-09-10' AS Date), NULL, 12.4950)
INSERT [dbo].[employees_commission] ([id], [employee_id], [sale_date], [paid_date], [commission]) VALUES (4, 1, CAST(N'2024-09-10' AS Date), NULL, 12.4950)
SET IDENTITY_INSERT [dbo].[employees_commission] OFF
GO
SET IDENTITY_INSERT [dbo].[employees_hours] ON 

INSERT [dbo].[employees_hours] ([id], [day], [hours], [employee_id], [hourly_wage], [paid_date]) VALUES (1, CAST(N'2024-09-08' AS Date), 6.5, 1, 7.5000, NULL)
INSERT [dbo].[employees_hours] ([id], [day], [hours], [employee_id], [hourly_wage], [paid_date]) VALUES (2, CAST(N'2024-09-08' AS Date), 8, 2, 9.0000, NULL)
INSERT [dbo].[employees_hours] ([id], [day], [hours], [employee_id], [hourly_wage], [paid_date]) VALUES (3, CAST(N'2024-09-08' AS Date), 10, 3, 25.0000, NULL)
INSERT [dbo].[employees_hours] ([id], [day], [hours], [employee_id], [hourly_wage], [paid_date]) VALUES (4, CAST(N'2024-09-08' AS Date), 1.5, 4, 7.2500, NULL)
INSERT [dbo].[employees_hours] ([id], [day], [hours], [employee_id], [hourly_wage], [paid_date]) VALUES (5, CAST(N'2024-09-08' AS Date), 12, 5, 8.5000, NULL)
INSERT [dbo].[employees_hours] ([id], [day], [hours], [employee_id], [hourly_wage], [paid_date]) VALUES (6, CAST(N'2024-09-10' AS Date), 3, 1, 7.5000, NULL)
INSERT [dbo].[employees_hours] ([id], [day], [hours], [employee_id], [hourly_wage], [paid_date]) VALUES (7, CAST(N'2024-09-10' AS Date), 3, 1, 7.5000, NULL)
INSERT [dbo].[employees_hours] ([id], [day], [hours], [employee_id], [hourly_wage], [paid_date]) VALUES (8, CAST(N'2024-09-11' AS Date), 9, 2, 9.0000, NULL)
SET IDENTITY_INSERT [dbo].[employees_hours] OFF
GO
SET IDENTITY_INSERT [dbo].[inventory] ON 

INSERT [dbo].[inventory] ([id], [product_id], [msrp], [quantity]) VALUES (1, 1, 99.9900, 20)
INSERT [dbo].[inventory] ([id], [product_id], [msrp], [quantity]) VALUES (2, 2, 124.9900, 10)
INSERT [dbo].[inventory] ([id], [product_id], [msrp], [quantity]) VALUES (3, 3, 224.4900, 4)
INSERT [dbo].[inventory] ([id], [product_id], [msrp], [quantity]) VALUES (4, 5, 24.9900, 42)
SET IDENTITY_INSERT [dbo].[inventory] OFF
GO
SET IDENTITY_INSERT [dbo].[products] ON 

INSERT [dbo].[products] ([id], [name], [brand]) VALUES (1, N'Velocity Pro', N'Apex')
INSERT [dbo].[products] ([id], [name], [brand]) VALUES (2, N'Summit Climber', N'Apex')
INSERT [dbo].[products] ([id], [name], [brand]) VALUES (3, N'Glow Sprinter', N'Neon Pulse')
INSERT [dbo].[products] ([id], [name], [brand]) VALUES (4, N'Cloud Walker', N'Nimbus')
INSERT [dbo].[products] ([id], [name], [brand]) VALUES (5, N'Silent Stepper', N'Whisper')
SET IDENTITY_INSERT [dbo].[products] OFF
GO
SET IDENTITY_INSERT [dbo].[sales] ON 

INSERT [dbo].[sales] ([id], [product_id], [employee_id], [quantity], [price], [datetime]) VALUES (1, 5, 2, 2, 19.9900, CAST(N'2024-09-08T14:56:40.520' AS DateTime))
INSERT [dbo].[sales] ([id], [product_id], [employee_id], [quantity], [price], [datetime]) VALUES (2, 1, 1, 5, 75.0000, CAST(N'2024-09-08T15:47:54.370' AS DateTime))
INSERT [dbo].[sales] ([id], [product_id], [employee_id], [quantity], [price], [datetime]) VALUES (3, 5, 1, 2, 24.9900, CAST(N'2024-09-10T18:05:08.370' AS DateTime))
INSERT [dbo].[sales] ([id], [product_id], [employee_id], [quantity], [price], [datetime]) VALUES (4, 5, 1, 2, 24.9900, CAST(N'2024-09-10T18:06:03.947' AS DateTime))
INSERT [dbo].[sales] ([id], [product_id], [employee_id], [quantity], [price], [datetime]) VALUES (5, 5, 1, 2, 24.9900, CAST(N'2024-09-10T18:06:43.943' AS DateTime))
INSERT [dbo].[sales] ([id], [product_id], [employee_id], [quantity], [price], [datetime]) VALUES (6, 3, 2, 1, 22.4400, CAST(N'2024-09-10T18:38:01.697' AS DateTime))
SET IDENTITY_INSERT [dbo].[sales] OFF
GO
/****** Object:  Index [IX_employees_commission_paid_date]    Script Date: 9/15/2024 1:27:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_employees_commission_paid_date] ON [dbo].[employees_commission]
(
	[paid_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_employees_commission_sale_date]    Script Date: 9/15/2024 1:27:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_employees_commission_sale_date] ON [dbo].[employees_commission]
(
	[sale_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_employees_hours_day]    Script Date: 9/15/2024 1:27:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_employees_hours_day] ON [dbo].[employees_hours]
(
	[day] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_employees_hours_paid_date]    Script Date: 9/15/2024 1:27:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_employees_hours_paid_date] ON [dbo].[employees_hours]
(
	[paid_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_inventory]    Script Date: 9/15/2024 1:27:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_inventory] ON [dbo].[inventory]
(
	[quantity] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_sales__quantity]    Script Date: 9/15/2024 1:27:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_sales__quantity] ON [dbo].[sales]
(
	[quantity] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_sales_datetime]    Script Date: 9/15/2024 1:27:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_sales_datetime] ON [dbo].[sales]
(
	[datetime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_sales_price]    Script Date: 9/15/2024 1:27:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_sales_price] ON [dbo].[sales]
(
	[price] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employees] ADD  CONSTRAINT [employees_commission_default]  DEFAULT ((0)) FOR [commission]
GO
ALTER TABLE [dbo].[employees_commission]  WITH CHECK ADD  CONSTRAINT [FK_employees_commission_employees] FOREIGN KEY([employee_id])
REFERENCES [dbo].[employees] ([id])
GO
ALTER TABLE [dbo].[employees_commission] CHECK CONSTRAINT [FK_employees_commission_employees]
GO
ALTER TABLE [dbo].[employees_hours]  WITH CHECK ADD  CONSTRAINT [FK_employees_hours_employees] FOREIGN KEY([employee_id])
REFERENCES [dbo].[employees] ([id])
GO
ALTER TABLE [dbo].[employees_hours] CHECK CONSTRAINT [FK_employees_hours_employees]
GO
ALTER TABLE [dbo].[inventory]  WITH CHECK ADD  CONSTRAINT [FK_products_inventory] FOREIGN KEY([product_id])
REFERENCES [dbo].[products] ([id])
GO
ALTER TABLE [dbo].[inventory] CHECK CONSTRAINT [FK_products_inventory]
GO
ALTER TABLE [dbo].[sales]  WITH CHECK ADD  CONSTRAINT [FK_sales_employees] FOREIGN KEY([employee_id])
REFERENCES [dbo].[employees] ([id])
GO
ALTER TABLE [dbo].[sales] CHECK CONSTRAINT [FK_sales_employees]
GO
ALTER TABLE [dbo].[sales]  WITH CHECK ADD  CONSTRAINT [FK_sales_products] FOREIGN KEY([product_id])
REFERENCES [dbo].[products] ([id])
GO
ALTER TABLE [dbo].[sales] CHECK CONSTRAINT [FK_sales_products]
GO
ALTER TABLE [dbo].[inventory]  WITH CHECK ADD  CONSTRAINT [CK_inventory_quantity] CHECK  (([quantity]>=(0)))
GO
ALTER TABLE [dbo].[inventory] CHECK CONSTRAINT [CK_inventory_quantity]
GO
/****** Object:  StoredProcedure [dbo].[insert_hours]    Script Date: 9/15/2024 1:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[insert_hours] 
(
	@employee_id bigint,
	@hours float,
	@day date
)
AS
BEGIN
	DECLARE @current_wage smallmoney
	SET @current_wage = (
		SELECT hourly_wage
		FROM employees e
		WHERE e.id = @employee_id
	)

	INSERT INTO [dbo].[employees_hours]
           ([day]
           ,[hours]
           ,[employee_id]
           ,[hourly_wage])
     VALUES
           (@day
           ,@hours
           ,@employee_id
           ,@current_wage)
END
GO
/****** Object:  StoredProcedure [dbo].[list_unpaid]    Script Date: 9/15/2024 1:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[list_unpaid]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    WITH hourly as 
	(
		SELECT 
		employee_id, sum(hours * hourly_wage) as wage
		FROM [ExampleCompany].[dbo].[employees_hours]
		WHERE paid_date is null
		group by employee_id
	),
	comm as
	(
		SELECT 
		employee_id, sum(commission) as wage
		FROM employees_commission
		where paid_date is null
		group by employee_id
	),
	combined as 
	(
		select * from hourly
		union all
		select * from comm
	),
	summed as 
	(
		select employee_id, sum(wage) as wage
		from combined
		group by employee_id
	)

	select s.employee_id, s.wage, e.name, e.position
	from summed s
	inner join employees e
	on s.employee_id = e.id
END
GO
/****** Object:  StoredProcedure [dbo].[sell_item]    Script Date: 9/15/2024 1:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sell_item]
(
	@employee_id bigint,
	@product_id  bigint,
	@sell_amount bigint,
	@price		 money,
	@error	 tinyint OUTPUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

	DECLARE @ROWS_AFFECTED tinyint -- We expect 2 rows. Anything else is a failure.

	-- Check to make sure we have enough items.
	IF dbo.has_item_quantity(@product_id, @sell_amount) != 1
		BEGIN
			PRINT 'A'
			SET @error = 1
			RETURN
		END
	ELSE
		BEGIN
		PRINT 'B'
			SET @error = 0
		END

	-- try catch in case something goes wrong.
	BEGIN TRY
		-- Use a transaction to allow a potential rollback.
		BEGIN TRANSACTION
		
		PRINT 'C'

		-- First we'll attempt to insert a sales record
		INSERT INTO [dbo].[sales]
           ([product_id], [employee_id], [quantity], [price], [datetime])
     VALUES
           (@product_id, @employee_id, @sell_amount, @price, GETDATE())

		PRINT 'D'
		SET @ROWS_AFFECTED = @ROWS_AFFECTED + @@ROWCOUNT -- Keep track of affected rows
		PRINT 'E'

	-- Then we'll attempt to remove the items from inventory
		UPDATE [dbo].[inventory]
		   SET quantity = quantity - @sell_amount
		 WHERE product_id = @product_id
		
		PRINT 'F'
		SET @ROWS_AFFECTED = @ROWS_AFFECTED + @@ROWCOUNT -- Keep track of affected rows
		PRINT 'G'

		IF @ROWS_AFFECTED != 2
		BEGIN
			PRINT 'H'
			-- Something unexpected happened. Fail and rollback.
			ROLLBACK TRANSACTION
			SET @error = 2
			--RETURN
		END
			
		PRINT 'I'


		COMMIT TRANSACTION -- Successfull transaction
		SET @error = 0
		--RETURN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			PRINT 'J'
			ROLLBACK TRANSACTION
			SET @error = 3
		END
	END CATCH
END
GO
/****** Object:  Trigger [dbo].[sales_commission]    Script Date: 9/15/2024 1:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER  [dbo].[sales_commission] --<Schema_Name, sysname, Schema_Name>.<Trigger_Name, sysname, Trigger_Name> 
   ON [dbo].[sales] --<Schema_Name, sysname, Schema_Name>.<Table_Name, sysname, Table_Name> 
   AFTER INSERT -- <Data_Modification_Statements, , INSERT,DELETE,UPDATE>
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @employee_id bigint
	SET @employee_id = (
	SELECT employee_id
	FROM inserted
	)

	DECLARE @commission numeric(7,4)
	SET @commission = (
		SELECT commission
		FROM employees e2
		WHERE e2.id = @employee_id
	)

	DECLARE @sale_amount money
	SET @sale_amount = (
		SELECT price * quantity
		FROM INSERTED
	)

	IF @commission > 0 
	BEGIN
		DECLARE @commission_amount money
		SET @commission_amount = @commission * @sale_amount

		INSERT INTO [dbo].[employees_commission]
           ([employee_id]
           ,[sale_date]
           ,[commission])
     VALUES
           (@employee_id
           ,GETDATE()
           ,@commission_amount)
	END

    -- Insert statements for trigger here
	--DECLARE @commission = (
	--SELECT commission
	--FROM employees e
	--WHERE e.id = inserted.employee_id
	--)

END
GO
ALTER TABLE [dbo].[sales] ENABLE TRIGGER [sales_commission]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[26] 2[15] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "i"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 190
               Right = 236
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "p"
            Begin Extent = 
               Top = 17
               Left = 379
               Bottom = 222
               Right = 637
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1608
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 2028
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1356
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'inventory_detailed'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'inventory_detailed'
GO
USE [master]
GO
ALTER DATABASE [ExampleCompany] SET  READ_WRITE 
GO
