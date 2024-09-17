namespace CompanyManager.classes
{
    public class Employee
    {
        public Int64 Id { get; set; }
        public string Name { get; set; }
        public decimal HourlyWage { get; set; }
        public string position { get; set; }
        public decimal commission { get; set; }

        public Employee()
        {

        }

        public Employee(Int64 id, string name, decimal wage)
        {
            this.Id = id;
            this.Name = name;
            this.HourlyWage = wage;
        }
    }
}

/* -- Table creation script
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

ALTER TABLE [dbo].[employees] ADD  CONSTRAINT [employees_commission_default]  DEFAULT ((0)) FOR [commission]
GO
*/