# Transferir dados entre SQL Pool e Databricks Pool
Transferir dados bidirecionalmente em um pool do Apache Spark e um pool de SQL dedicado anexado no workspace que você criou para sua conta do Azure Synapse Analytics.<br>
Se estiver usando um notebook no Azure Synapse Studio, vinculada ao seu recurso de workspace, não precisará usar instruções de importação.<br>
As instruções de importação só são necessárias quando você não está usando notebook no Azure Synapse Studio.<br>

## Configurando Constants e SqlAnalyticsConnector
```
#scala
 import com.microsoft.spark.sqlanalytics.utils.Constants
 import org.apache.spark.sql.SqlAnalyticsConnector._
```

Para ler dados de um pool de SQL dedicado, você deverá usar a API de Leitura.<br>
A API de Leitura funciona com tabelas internas (tabelas gerenciadas) e tabelas externas no pool de SQL dedicado.<br>
Os parâmetros necessários são:<br>

- DBName: o nome do banco de dados.
- Schema: a definição de esquema, como dbo.
- TableName: o nome da tabela da qual deseja ler os dados.

```
#scala
val df = spark.read.sqlanalytics("<DBName>.<Schema>.<TableName>")
```

Para gravar dados em um pool de SQL dedicado, você deverá usar a API de Gravação.<br>
A API de Gravação cria uma tabela no pool de SQL dedicado, em seguida, ela invoca o PolyBase para carregar os dados na tabela criada.<br>
A tabela não pode já existir no pool de SQL dedicado, caso contráro, você receberá um erro.<br>

```
df.write.sqlanalytics("<DBName>.<Schema>.<TableName>", <TableType>)
```
Os parâmetros necessários são:

- DBName: o nome do banco de dados.
- Schema: a definição de esquema, como dbo.
- TableName: o nome da tabela da qual deseja ler os dados.
- TableType: especificação do tipo de tabela, que pode ter dois valores:<br>
Constants.INTERNAL – Tabela gerenciada no pool de SQL dedicado<br>
Constants.EXTERNAL – Tabela externa no pool de SQL dedicado<br>
```
df.write.sqlanalytics("<DBName>.<Schema>.<TableName>", Constants.INTERNAL)
```

Para usar uma tabela externa do pool de SQL, você precisa ter uma EXTERNAL DATA SOURCE e um EXTERNAL FILE FORMAT existente no pool usando os seguintes exemplos:
```
--For an external table, you need to pre-create the data source and file format in dedicated SQL pool using SQL queries:
CREATE EXTERNAL DATA SOURCE <DataSourceName>
WITH
  ( LOCATION = 'abfss://...' ,
    TYPE = HADOOP
  ) ;

CREATE EXTERNAL FILE FORMAT <FileFormatName>
WITH (  
    FORMAT_TYPE = PARQUET,  
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'  
);
```

Não será necessário criar um objeto EXTERNAL CREDENTIAL se você estiver usando a autenticação do Azure AD na conta de armazenamento.<br>
Você precisa ser membro da função "Colaborador de Dados do Blob de Armazenamento" na conta de armazenamento.<br>
A próxima etapa será usar o comando df.write no Scala com DATA_SOURCE, FILE_FORMAT e o comando sqlanalytics.<br>
```
df.write.
    option(Constants.DATA_SOURCE, <DataSourceName>).
    option(Constants.FILE_FORMAT, <FileFormatName>).
    sqlanalytics("<DBName>.<Schema>.<TableName>", Constants.EXTERNAL)
```

Outra maneira de se autenticar é usando a Autenticação do SQL em vez do Azure AD.<br>
Os parâmetros necessários são:

- Constants.Server: especifique a URL do servidor
- Constants.USER: nome de usuário de logon do SQL Server
- Constants.PASSWORD: senha de logon do SQL Server
- DBName: o nome do banco de dados.
- Schema: a definição de esquema, como dbo.
- TableName: o nome da tabela da qual deseja ler os dados.
```
val df = spark.read.
option(Constants.SERVER, "samplews.database.windows.net").
option(Constants.USER, <SQLServer Login UserName>).
option(Constants.PASSWORD, <SQLServer Login Password>).
sqlanalytics("<DBName>.<Schema>.<TableName>")
```

Para gravar dados em um pool de SQL dedicado, use a API de Gravação.<br>
A API de Gravação cria a tabela no pool de SQL dedicado e usa o PolyBase para carregar os dados na tabela criada.<br>
```
df.write.
option(Constants.SERVER, "samplews.database.windows.net").
option(Constants.USER, <SQLServer Login UserName>).
option(Constants.PASSWORD, <SQLServer Login Password>).
sqlanalytics("<DBName>.<Schema>.<TableName>", <TableType>)
```

## Gravação em um SQL pool dedicado depois de executar tarefas no Spark
Se quisermos usar o conector do SQL do Synapse ao pool do Apache Spark (sqlanalytics), uma opção será criar uma view temporária dos dados dentro do DataFrame.<br>
```
%%python
# Create a temporary view for top purchases 
topPurchases.createOrReplaceTempView("top_purchases")
```
Devemos executar o código que usa o pool do Apache Spark para o conector SQL do Synapse no Scala.<br>
```
%%spark
// Make sure the name of the SQL pool (SQLPool01 below) matches the name of your SQL pool.
val df = spark.sqlContext.sql("select * from top_purchases")
df.write.sqlanalytics("SQLPool01.wwi.TopPurchases", Constants.INTERNAL)
```
A tabela wwi.TopPurchases foi criada automaticamente, com base no esquema derivado do DataFrame do Apache Spark.<br>
O pool do Apache Spark para o conector do SQL do Synapse foi responsável por criar a tabela e carregar os dados nela com eficiência.<br>
<br>
Ler os dados de arquivos Parquet localizados em uma pasta
```
%%python
dfsales = spark.read.load('abfss://wwi-02@' + datalake + '.dfs.core.windows.net/sale-small/Year=2019/Quarter=Q4/Month=12/*/*.parquet', format='parquet')
display(dfsales.limit(10))
```

Fazer a leitura da tabela TopSales do pool de SQL e salvá-la em uma view temporária
```
%%spark
// Make sure the name of the SQL pool (SQLPool01 below) matches the name of your SQL pool.
val df2 = spark.read.sqlanalytics("SQLPool01.wwi.TopPurchases")
df2.createTempView("top_purchases_sql")
df2.head(10)
```

Criar um DataFrame da exibição view top_purchases_sql
```
%%python
dfTopPurchasesFromSql = sqlContext.table("top_purchases_sql")
display(dfTopPurchasesFromSql.limit(10))
```

Unir os dados dos arquivos Parquet de vendas e do pool de SQL TopPurchases
```
%%python
inner_join = dfsales.join(dfTopPurchasesFromSql,
    (dfsales.CustomerId == dfTopPurchasesFromSql.visitorId) & (dfsales.ProductId == dfTopPurchasesFromSql.productId))

inner_join_agg = (inner_join.select("CustomerId","TotalAmount","Quantity","itemsPurchasedLast12Months","top_purchases_sql.productId")
    .groupBy(["CustomerId","top_purchases_sql.productId"])
    .agg(
        sum("TotalAmount").alias("TotalAmountDecember"),
        sum("Quantity").alias("TotalQuantityDecember"),
        sum("itemsPurchasedLast12Months").alias("TotalItemsPurchasedLast12Months"))
    .orderBy("CustomerId") )

display(inner_join_agg.limit(100))
```
Na consulta, unimos os DataFrames dfsales e dfTopPurchasesFromSql, correspondentes em CustomerId e ProductId.<br>
Essa união combinou os dados da tabela do pool de SQL TopPurchases com os dados do Parquet de vendas de dezembro de 2019 TopPurchases.<br>
Agrupamos os campos CustomerId e ProductId.<br>
Como o nome do campo ProductId é ambíguo (ele existe nos dois DataFrames), precisamos qualificar totalmente o nome ProductId para referenciar àquele no DataFrame TopPurchasesProductId.<br>
Em seguida, criamos uma agregação que somava o valor total gasto em cada produto em dezembro, o número total de itens de produto em dezembro e o total de itens de produto comprados nos últimos 12 meses.<br>
Por fim, exibimos os dados que foram unidos e agregados em uma exibição de tabela.
