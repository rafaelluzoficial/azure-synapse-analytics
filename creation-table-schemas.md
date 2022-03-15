# Creation Table Schemas in Synapse Analytics.
## Star Schema
Como o Synapse Analytics é um sistema MPP (processamento paralelo maciço), você deve considerar como os dados são distribuídos em seu design de tabela, em vez de sistemas SMP (multiprocessamento simétrico), como bancos de dado OLTP, como o Banco de Dados SQL do Azure. A categoria da tabela geralmente determina qual opção escolher para a distribuição da tabela.
<p>
Categoria de tabela	Opção de distribuição recomendada:
<p>
Tabelas Fato: Use a distribuição de hash com índice columnstore clusterizado. O desempenho melhora quando duas tabelas de hash são unidas na mesma coluna de distribuição.
<p>
Tabelas Dimensão: Use a replicada para tabelas menores. Se as tabelas forem grandes demais para serem armazenadas em cada nó de computação, use a distribuição de hash.
<p>
Tabelas Staging: Use um round robin para a tabela de preparo. A carga com CTAS é rápida. Quando os dados estiverem na tabela de preparo, use INSERT...SELECT para mover os dados para uma tabela de produção.
<p>

## Criando tabelas fato e dimensões
  ```
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
  ```
<p>

## Populando tabelas fato e dimensões
  ```
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
  ```

<p>

## Consulta para recuperar dados das tabelas fato e dimensões
  ```
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
  ```
<p>
  
## Snowflake Schema
  
Um esquema floco de neve é um conjunto de tabelas normalizadas para uma só entidade empresarial. Por exemplo, a uma empresa classifica produtos por categoria e subcategoria. As categorias são atribuídas a subcategorias e os produtos, por sua vez, são atribuídos a subcategorias. No data warehouse relacional da empresa, a dimensão de produto é normalizada e armazenada em três tabelas relacionadas: DimProductCategory, DimProductSubcategory e DimProduct.

<p>

O esquema floco de neve é uma variação do esquema em estrela. Você adiciona tabelas de dimensões normalizadas a um esquema em estrela para criar um padrão floco de neve. No diagrama de dados você vê as tabelas de dimensões ao redor da tabela de fatos. Muitas das tabelas de dimensões se relacionam umas com as outras para normalizar as entidades empresariais.

<p>

## Criando tabelas dimensão com Snowflake Schema
Neste código, você adiciona duas novas tabelas de dimensões: DimProductCategory e DimProductSubcategory. Há uma relação implícita entre essas duas tabelas e a tabela DimProduct que cria uma dimensão de produto normalizada, conhecida como uma dimensão floco de neve. Fazer isso atualiza o esquema em estrela para incluir a dimensão de produto normalizada, transformando-a em um esquema floco de neve.
```
  CREATE TABLE [dbo].[DimProductCategory](
    [ProductCategoryKey] [int] NOT NULL,
    [ProductCategoryAlternateKey] [int] NULL,
    [EnglishProductCategoryName] [nvarchar](50) NOT NULL,
    [SpanishProductCategoryName] [nvarchar](50) NOT NULL,
    [FrenchProductCategoryName] [nvarchar](50) NOT NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
GO

CREATE TABLE [dbo].[DimProductSubcategory](
    [ProductSubcategoryKey] [int] NOT NULL,
    [ProductSubcategoryAlternateKey] [int] NULL,
    [EnglishProductSubcategoryName] [nvarchar](50) NOT NULL,
    [SpanishProductSubcategoryName] [nvarchar](50) NOT NULL,
    [FrenchProductSubcategoryName] [nvarchar](50) NOT NULL,
    [ProductCategoryKey] [int] NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
GO
```
<p>

## Populando tabelas dimensão Snowflake Schema
```
  COPY INTO [dbo].[DimProductCategory]
FROM 'https://solliancepublicdata.blob.core.windows.net/dataengineering/dp-203/awdata/DimProductCategory.csv'
WITH (
    FILE_TYPE='CSV',
    FIELDTERMINATOR='|',
    FIELDQUOTE='',
    ROWTERMINATOR='\n',
    ENCODING = 'UTF16'
);
GO

COPY INTO [dbo].[DimProductSubcategory]
FROM 'https://solliancepublicdata.blob.core.windows.net/dataengineering/dp-203/awdata/DimProductSubcategory.csv'
WITH (
    FILE_TYPE='CSV',
    FIELDTERMINATOR='|',
    FIELDQUOTE='',
    ROWTERMINATOR='\n',
    ENCODING = 'UTF16'
);
GO
```
<p>

## Consultando dados das tabelas dimensão Snowflake Schema
```
  SELECT
    pc.EnglishProductCategoryName AS ProductCategory
    ,psc.EnglishProductSubcategoryName AS ProductSubcategory
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
INNER JOIN [dbo].[DimProduct] p
    ON f.[ProductKey] = p.[ProductKey]
INNER JOIN [dbo].[DimProductSubcategory] psc
    ON p.[ProductSubcategoryKey] = psc.[ProductSubcategoryKey]
INNER JOIN [dbo].[DimProductCategory] pc
    ON psc.[ProductCategoryKey] = pc.[ProductCategoryKey]
GROUP BY
    pc.EnglishProductCategoryName
    ,psc.EnglishProductSubcategoryName
    ,Year(f.OrderDate)
    ,CASE
        WHEN Month(f.OrderDate) < 7 THEN Year(f.OrderDate)
        ELSE Year(f.OrderDate) + 1
    END
    ,Month(f.OrderDate)
ORDER BY Amount DESC
```
<p>

## Tabelas de Dimensão Temporal
Uma tabela de dimensão temporal é uma das tabelas de dimensão usadas mais consistentemente. Esse tipo de tabela permite granularidade consistente para análise temporal e relatórios e geralmente contém hierarquias temporais, como Year>Quarter>Month>Day. Além da consistência em atributos de tempo, esse design também ajudará no desempenho da consulta. É mais eficaz filtrar os atributos armazenados em uma tabela de dimensão pequena do que sempre calcular os atributos de tempo no momento da consulta.
<p>
As tabelas de dimensão temporal podem conter atributos empresariais específicos que são referências úteis para relatórios e filtros, como períodos fiscais e feriados públicos.
<p>
Você pode preencher tabelas de dimensão de tempo de várias maneiras, incluindo scripts T-SQL usando funções de data/hora, funções do Microsoft Excel, importando de um arquivo simples ou ferramentas de geração automática por BI (business intelligence). Neste exercício, você examinará um script que poderia popular a tabela de dimensão de tempo usando o T-SQL, mas pode ser lento em um sistema MPP como o Synapse Analytics. Em seguida, você carregará os resultados previamente computados de um arquivo simples, o que é um processo muito mais rápido.

<p>

## Opção 1 - Criar tabelas populadas dirtamente no SQL Pool do Synapse
```
  IF OBJECT_ID('tempdb..#DateTmp') IS NOT NULL
BEGIN
    DROP TABLE #DateTmp
END

CREATE TABLE #DateTmp (DateKey datetime NOT NULL)

-- Create temp table with all the dates we will use
DECLARE @StartDate datetime
DECLARE @EndDate datetime
SET @StartDate = '01/01/2005'
SET @EndDate = getdate() 
DECLARE @LoopDate datetime
SET @LoopDate = @StartDate
WHILE @LoopDate <= @EndDate
BEGIN
INSERT INTO #DateTmp VALUES
    (
        @LoopDate
    )  		  
    SET @LoopDate = DateAdd(dd, 1, @LoopDate)
END

INSERT INTO dbo.DimDate 
SELECT
CAST(CONVERT(VARCHAR(8), DateKey, 112) AS int) , -- date key
        DateKey, -- date alt key
        Year(DateKey), -- calendar year
        datepart(qq, DateKey), -- calendar quarter
        Month(DateKey), -- month number of year
        datename(mm, DateKey), -- month name
        Day(DateKey),  -- day number of month
        datepart(dw, DateKey), -- day number of week
        datename(dw, DateKey), -- day name of week
        CASE
            WHEN Month(DateKey) < 7 THEN Year(DateKey)
            ELSE Year(DateKey) + 1
        END, -- Fiscal year (assuming fiscal year runs from Jul to June)
        CASE
            WHEN Month(DateKey) IN (1, 2, 3) THEN 3
            WHEN Month(DateKey) IN (4, 5, 6) THEN 4
            WHEN Month(DateKey) IN (7, 8, 9) THEN 1
            WHEN Month(DateKey) IN (10, 11, 12) THEN 2
        END -- fiscal quarter 
    FROM #DateTmp
GO
```
<p>

## Opção 2 - Criar tabelas importando dados externos
```
  CREATE TABLE [dbo].[DimDate]
( 
    [DateKey] [int]  NOT NULL,
    [DateAltKey] [datetime]  NOT NULL,
    [CalendarYear] [int]  NOT NULL,
    [CalendarQuarter] [int]  NOT NULL,
    [MonthOfYear] [int]  NOT NULL,
    [MonthName] [nvarchar](15)  NOT NULL,
    [DayOfMonth] [int]  NOT NULL,
    [DayOfWeek] [int]  NOT NULL,
    [DayName] [nvarchar](15)  NOT NULL,
    [FiscalYear] [int]  NOT NULL,
    [FiscalQuarter] [int]  NOT NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
GO
```
  
<p>

## Populando tabela com dados externos
```
  COPY INTO [dbo].[DimDate]
FROM 'https://solliancepublicdata.blob.core.windows.net/dataengineering/dp-203/awdata/DimDate.csv'
WITH (
    FILE_TYPE='CSV',
    FIELDTERMINATOR='|',
    FIELDQUOTE='',
    ROWTERMINATOR='0x0a',
    ENCODING = 'UTF16'
);
GO
```
  
<p>

## Consultando dados da tabela de Dimensão Temporal
```
  SELECT
    Coalesce(p.[ModelName], p.[EnglishProductName]) AS [Model]
    ,g.City AS ResellerCity
    ,g.StateProvinceName AS StateProvince
    ,d.[CalendarYear]
    ,d.[FiscalYear]
    ,d.[MonthOfYear] AS [Month]
    ,sum(f.OrderQuantity) AS Quantity
    ,sum(f.ExtendedAmount) AS Amount
    ,approx_count_distinct(f.SalesOrderNumber) AS UniqueOrders  
FROM
    [dbo].[FactResellerSales] f
INNER JOIN [dbo].[DimReseller] r
    ON f.ResellerKey = r.ResellerKey
INNER JOIN [dbo].[DimGeography] g
    ON r.GeographyKey = g.GeographyKey
INNER JOIN [dbo].[DimDate] d
    ON f.[OrderDateKey] = d.[DateKey]
INNER JOIN [dbo].[DimProduct] p
    ON f.[ProductKey] = p.[ProductKey]
WHERE d.[MonthOfYear] = 10 AND d.[FiscalYear] IN (2012, 2013)
GROUP BY
    Coalesce(p.[ModelName], p.[EnglishProductName])
    ,g.City
    ,g.StateProvinceName
    ,d.[CalendarYear]
    ,d.[FiscalYear]
    ,d.[MonthOfYear]
ORDER BY d.[FiscalYear]
```
