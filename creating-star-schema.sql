CREATE TABLE [dbo].[FactResellerSales](
    [ProductKey] [int] NOT NULL,
    [OrderDateKey] [int] NOT NULL,
    [DueDateKey] [int] NOT NULL,
    [ShipDateKey] [int] NOT NULL,
    [ResellerKey] [int] NOT NULL,
    [EmployeeKey] [int] NOT NULL,
    [PromotionKey] [int] NOT NULL,
    [CurrencyKey] [int] NOT NULL,
    [SalesTerritoryKey] [int] NOT NULL,
    [SalesOrderNumber] [nvarchar](20) NOT NULL,
    [SalesOrderLineNumber] [tinyint] NOT NULL,
    [RevisionNumber] [tinyint] NULL,
    [OrderQuantity] [smallint] NULL,
    [UnitPrice] [money] NULL,
    [ExtendedAmount] [money] NULL,
    [UnitPriceDiscountPct] [float] NULL,
    [DiscountAmount] [float] NULL,
    [ProductStandardCost] [money] NULL,
    [TotalProductCost] [money] NULL,
    [SalesAmount] [money] NULL,
    [TaxAmt] [money] NULL,
    [Freight] [money] NULL,
    [CarrierTrackingNumber] [nvarchar](25) NULL,
    [CustomerPONumber] [nvarchar](25) NULL,
    [OrderDate] [datetime] NULL,
    [DueDate] [datetime] NULL,
    [ShipDate] [datetime] NULL
)
WITH
(
    DISTRIBUTION = HASH([SalesOrderNumber]),
    CLUSTERED COLUMNSTORE INDEX
);
GO

CREATE TABLE [dbo].[DimReseller](
    [ResellerKey] [int] NOT NULL,
    [GeographyKey] [int] NULL,
    [ResellerAlternateKey] [nvarchar](15) NULL,
    [Phone] [nvarchar](25) NULL,
    [BusinessType] [varchar](20) NOT NULL,
    [ResellerName] [nvarchar](50) NOT NULL,
    [NumberEmployees] [int] NULL,
    [OrderFrequency] [char](1) NULL,
    [OrderMonth] [tinyint] NULL,
    [FirstOrderYear] [int] NULL,
    [LastOrderYear] [int] NULL,
    [ProductLine] [nvarchar](50) NULL,
    [AddressLine1] [nvarchar](60) NULL,
    [AddressLine2] [nvarchar](60) NULL,
    [AnnualSales] [money] NULL,
    [BankName] [nvarchar](50) NULL,
    [MinPaymentType] [tinyint] NULL,
    [MinPaymentAmount] [money] NULL,
    [AnnualRevenue] [money] NULL,
    [YearOpened] [int] NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
GO

CREATE TABLE [dbo].[DimEmployee](
    [EmployeeKey] [int] NOT NULL,
    [ParentEmployeeKey] [int] NULL,
    [EmployeeNationalIDAlternateKey] [nvarchar](15) NULL,
    [ParentEmployeeNationalIDAlternateKey] [nvarchar](15) NULL,
    [SalesTerritoryKey] [int] NULL,
    [FirstName] [nvarchar](50) NOT NULL,
    [LastName] [nvarchar](50) NOT NULL,
    [MiddleName] [nvarchar](50) NULL,
    [NameStyle] [bit] NOT NULL,
    [Title] [nvarchar](50) NULL,
    [HireDate] [date] NULL,
    [BirthDate] [date] NULL,
    [LoginID] [nvarchar](256) NULL,
    [EmailAddress] [nvarchar](50) NULL,
    [Phone] [nvarchar](25) NULL,
    [MaritalStatus] [nchar](1) NULL,
    [EmergencyContactName] [nvarchar](50) NULL,
    [EmergencyContactPhone] [nvarchar](25) NULL,
    [SalariedFlag] [bit] NULL,
    [Gender] [nchar](1) NULL,
    [PayFrequency] [tinyint] NULL,
    [BaseRate] [money] NULL,
    [VacationHours] [smallint] NULL,
    [SickLeaveHours] [smallint] NULL,
    [CurrentFlag] [bit] NOT NULL,
    [SalesPersonFlag] [bit] NOT NULL,
    [DepartmentName] [nvarchar](50) NULL,
    [StartDate] [date] NULL,
    [EndDate] [date] NULL,
    [Status] [nvarchar](50) NULL,
    [EmployeePhoto] [varbinary](max) NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED INDEX (EmployeeKey)
);
GO

CREATE TABLE [dbo].[DimProduct](
    [ProductKey] [int] NOT NULL,
    [ProductAlternateKey] [nvarchar](25) NULL,
    [ProductSubcategoryKey] [int] NULL,
    [WeightUnitMeasureCode] [nchar](3) NULL,
    [SizeUnitMeasureCode] [nchar](3) NULL,
    [EnglishProductName] [nvarchar](50) NOT NULL,
    [SpanishProductName] [nvarchar](50) NULL,
    [FrenchProductName] [nvarchar](50) NULL,
    [StandardCost] [money] NULL,
    [FinishedGoodsFlag] [bit] NOT NULL,
    [Color] [nvarchar](15) NOT NULL,
    [SafetyStockLevel] [smallint] NULL,
    [ReorderPoint] [smallint] NULL,
    [ListPrice] [money] NULL,
    [Size] [nvarchar](50) NULL,
    [SizeRange] [nvarchar](50) NULL,
    [Weight] [float] NULL,
    [DaysToManufacture] [int] NULL,
    [ProductLine] [nchar](2) NULL,
    [DealerPrice] [money] NULL,
    [Class] [nchar](2) NULL,
    [Style] [nchar](2) NULL,
    [ModelName] [nvarchar](50) NULL,
    [LargePhoto] [varbinary](max) NULL,
    [EnglishDescription] [nvarchar](400) NULL,
    [FrenchDescription] [nvarchar](400) NULL,
    [ChineseDescription] [nvarchar](400) NULL,
    [ArabicDescription] [nvarchar](400) NULL,
    [HebrewDescription] [nvarchar](400) NULL,
    [ThaiDescription] [nvarchar](400) NULL,
    [GermanDescription] [nvarchar](400) NULL,
    [JapaneseDescription] [nvarchar](400) NULL,
    [TurkishDescription] [nvarchar](400) NULL,
    [StartDate] [datetime] NULL,
    [EndDate] [datetime] NULL,
    [Status] [nvarchar](7) NULL    
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED INDEX (ProductKey)
);
GO

CREATE TABLE [dbo].[DimGeography](
    [GeographyKey] [int] NOT NULL,
    [City] [nvarchar](30) NULL,
    [StateProvinceCode] [nvarchar](3) NULL,
    [StateProvinceName] [nvarchar](50) NULL,
    [CountryRegionCode] [nvarchar](3) NULL,
    [EnglishCountryRegionName] [nvarchar](50) NULL,
    [SpanishCountryRegionName] [nvarchar](50) NULL,
    [FrenchCountryRegionName] [nvarchar](50) NULL,
    [PostalCode] [nvarchar](15) NULL,
    [SalesTerritoryKey] [int] NULL,
    [IpAddressLocator] [nvarchar](15) NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
GO



COPY INTO [dbo].[DimProduct]
FROM 'https://solliancepublicdata.blob.core.windows.net/dataengineering/dp-203/awdata/DimProduct.csv'
WITH (
    FILE_TYPE='CSV',
    FIELDTERMINATOR='|',
    FIELDQUOTE='',
    ROWTERMINATOR='\n',
    ENCODING = 'UTF16'
);
GO

COPY INTO [dbo].[DimReseller]
FROM 'https://solliancepublicdata.blob.core.windows.net/dataengineering/dp-203/awdata/DimReseller.csv'
WITH (
    FILE_TYPE='CSV',
    FIELDTERMINATOR='|',
    FIELDQUOTE='',
    ROWTERMINATOR='\n',
    ENCODING = 'UTF16'
);
GO

COPY INTO [dbo].[DimEmployee]
FROM 'https://solliancepublicdata.blob.core.windows.net/dataengineering/dp-203/awdata/DimEmployee.csv'
WITH (
    FILE_TYPE='CSV',
    FIELDTERMINATOR='|',
    FIELDQUOTE='',
    ROWTERMINATOR='\n',
    ENCODING = 'UTF16'
);
GO

COPY INTO [dbo].[DimGeography]
FROM 'https://solliancepublicdata.blob.core.windows.net/dataengineering/dp-203/awdata/DimGeography.csv'
WITH (
    FILE_TYPE='CSV',
    FIELDTERMINATOR='|',
    FIELDQUOTE='',
    ROWTERMINATOR='\n',
    ENCODING = 'UTF16'
);
GO

COPY INTO [dbo].[FactResellerSales]
FROM 'https://solliancepublicdata.blob.core.windows.net/dataengineering/dp-203/awdata/FactResellerSales.csv'
WITH (
    FILE_TYPE='CSV',
    FIELDTERMINATOR='|',
    FIELDQUOTE='',
    ROWTERMINATOR='\n',
    ENCODING = 'UTF16'
);
GO



SELECT
    Coalesce(p.[ModelName], p.[EnglishProductName]) AS [Model]
    ,g.City AS ResellerCity
    ,g.StateProvinceName AS StateProvince
    ,Year(f.OrderDate) AS CalendarYear
    ,CASE
        WHEN Month(f.OrderDate) < 7 THEN Year(f.OrderDate)
        ELSE Year(f.OrderDate) + 1
    END AS FiscalYear -- Fiscal year runs from Jul to June)
    ,Month(f.OrderDate) AS [Month]
    ,Sum(f.OrderQuantity) AS Quantity
    ,Sum(f.ExtendedAmount) AS Amount
    ,Approx_count_distinct(f.SalesOrderNumber) AS UniqueOrders  
FROM
    [dbo].[FactResellerSales] f
INNER JOIN [dbo].[DimReseller] r
    ON f.ResellerKey = r.ResellerKey
INNER JOIN [dbo].[DimGeography] g
    ON r.GeographyKey = g.GeographyKey
INNER JOIN [dbo].[DimProduct] p
    ON f.[ProductKey] = p.[ProductKey]
GROUP BY
    Coalesce(p.[ModelName], p.[EnglishProductName])
    ,g.City
    ,g.StateProvinceName
    ,Year(f.OrderDate)
    ,CASE
        WHEN Month(f.OrderDate) < 7 THEN Year(f.OrderDate)
        ELSE Year(f.OrderDate) + 1
    END
    ,Month(f.OrderDate)
ORDER BY Amount DESC