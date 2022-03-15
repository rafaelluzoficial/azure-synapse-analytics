# Ingestão de dados usando Copy e Polybase
Os amplos recursos da atividade Copy permitem mover dados de maneira rápida e fácil para pools de SQL de uma variedade de fontes.
<br>
Quando os arquivos forem armazenados no ADLS Gen2, você poderá usar as tabelas externas do PolyBase ou a nova instrução COPY ao usar comandos T-SQL.
Ambas as opções permitem operações de carregamento de dados rápidas e escalonáveis, mas há algumas diferenças entre as duas:
<p>
POLYBASE
<br>
Precisa da permissão CONTROL<br>
Tem limites de largura de linha<br>
Nenhum delimitador no texto<br>
Delimitador de linha fixo<br>
Complexo para configurar no código
<p>
COPY
<br>
Permissão reduzida<br>
Sem limite de largura de linha<br>
Dá suporte a delimitadores no texto<br>
Dá suporte a delimitadores de linha e de coluna personalizados<br>
Reduz a quantidade de código
<p>

## Ingerir dados usando o PolyBase
Para usar o PolyBase precisamos criar os seguintes elementos:<br>
- Uma fonte de dados externa que aponta para o caminho abfss no ADLS Gen2 onde os arquivos Parquet estão localizados.<br>
- Um formato de arquivo externo para arquivos Parquet.<br>
- Uma tabela externa que define o esquema para os arquivos, bem como o local, a fonte de dados e o formato de arquivo.
<p>

Criando a fonte de dados externa<br>
```
-- Replace YOURACCOUNT with the name of your ADLS Gen2 account.
CREATE EXTERNAL DATA SOURCE ABSS
WITH
( TYPE = HADOOP,
    LOCATION = 'abfss://wwi-02@YOURACCOUNT.dfs.core.windows.net'
);
```
<p>

Criando o formato de arquivo externo e a tabela de dados externa.<br>
Definimos TransactionId como um campo nvarchar(36) em vez de uniqueidentifier.<br>
Isso ocorre porque as tabelas externas atualmente não dão suporte a colunas uniqueidentifier.<br>
```
CREATE EXTERNAL FILE FORMAT [ParquetFormat]
WITH (
    FORMAT_TYPE = PARQUET,
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
)
GO

CREATE SCHEMA [wwi_external];
GO

CREATE EXTERNAL TABLE [wwi_external].Sales
    (
        [TransactionId] [nvarchar](36)  NOT NULL,
        [CustomerId] [int]  NOT NULL,
        [ProductId] [smallint]  NOT NULL,
        [Quantity] [smallint]  NOT NULL,
        [Price] [decimal](9,2)  NOT NULL,
        [TotalAmount] [decimal](9,2)  NOT NULL,
        [TransactionDate] [int]  NOT NULL,
        [ProfitAmount] [decimal](9,2)  NOT NULL,
        [Hour] [tinyint]  NOT NULL,
        [Minute] [tinyint]  NOT NULL,
        [StoreId] [smallint]  NOT NULL
    )
WITH
    (
        LOCATION = '/sale-small%2FYear%3D2019',  
        DATA_SOURCE = ABSS,
        FILE_FORMAT = [ParquetFormat]  
    )  
GO
```
<p>

Carregando os dados na tabela wwi_staging.SalesHeap<br>
```
INSERT INTO [wwi_staging].[SaleHeap]
SELECT *
FROM [wwi_external].[Sales]
```
<p>

## Ingerir dados de forma mais simples usando Copy<br>
Cubstitua o script pelo seguinte para truncar a tabela heap e carregar dados usando a instrução COPY.<br>
```
TRUNCATE TABLE wwi_staging.SaleHeap;
GO

-- Replace YOURACCOUNT with the workspace default storage account name.
COPY INTO wwi_staging.SaleHeap
FROM 'https://YOURACCOUNT.dfs.core.windows.net/wwi-02/sale-small%2FYear%3D2019'
WITH (
    FILE_TYPE = 'PARQUET',
    COMPRESSION = 'SNAPPY'
)
GO
```
<p>

## Mais exemplos de Copy<br>
A atividade Copy dá suporte a uma grande variedade de fontes de dados e coletores locais e na nuvem.<br>
Ele facilita a análise eficiente, mas flexível, bem como a transferência de dados ou arquivos entre sistemas de maneira otimizada, além permitir a conversão fácil de conjuntos de dados para outros formatos.
<p>
No exemplo a seguir, você pode carregar dados de uma conta de armazenamento público.<br>
Aqui, o padrão da instrução COPY corresponde ao formato do arquivo CSV de item de linha.<br>

```
COPY INTO dbo.[lineitem] FROM 'https://unsecureaccount.blob.core.windows.net/customerdatasets/folder1/lineitem.csv'
```
Os valores padrão para arquivos CSV do comando COPY são:<br>
- DATEFORMAT = DATEFORMAT da sessão<br>
- MAXERRORS = 0<br>
- O padrão de COMPRESSION é descompactado<br>
- FIELDQUOTE = “”<br>
- FIELDTERMINATOR = “,”<br>
- ROWTERMINATOR = ‘\n'<br>
- FIRSTROW = 1<br>
- ENCODING = ‘UTF8’<br>
- FILE_TYPE = ‘CSV’<br>
- IDENTITY_INSERT = ‘OFF’
<p>

Este exemplo carrega arquivos especificando uma lista de colunas com valores padrão.<br>

```
--Note when specifying the column list, input field numbers start from 1
COPY INTO test_1 (Col_one default 'myStringDefault' 1, Col_two default 1 3)
FROM 'https://myaccount.blob.core.windows.net/myblobcontainer/folder1/'
WITH (
    FILE_TYPE = 'CSV',
    CREDENTIAL=(IDENTITY= 'Storage Account Key', SECRET='<Your_Account_Key>'),
	  --CREDENTIAL should look something like this:
    --CREDENTIAL=(IDENTITY= 'Storage Account Key', SECRET='x6RWv4It5F2msnjelv3H4DA80n0PQW0daPdw43jM0nyetx4c6CpDkdj3986DX5AHFMIf/YN4y6kkCnU8lb+Wx0Pj+6MDw=='),
    FIELDQUOTE = '"',
    FIELDTERMINATOR=',',
    ROWTERMINATOR='0x0A',
    ENCODING = 'UTF8',
    FIRSTROW = 2
)
```
O exemplo a seguir carrega arquivos que usam a alimentação de linha como um terminador de linha, como uma saída UNIX.<br>
Este exemplo também usa uma chave de SAS para autenticação no Armazenamento de Blobs do Azure.<br>
```
COPY INTO test_1
FROM 'https://myaccount.blob.core.windows.net/myblobcontainer/folder1/'
WITH (
    FILE_TYPE = 'CSV',
    CREDENTIAL=(IDENTITY= 'Shared Access Signature', SECRET='<Your_SAS_Token>'),
	  --CREDENTIAL should look something like this:
    --CREDENTIAL=(IDENTITY= 'Shared Access Signature', SECRET='?sv=2018-03-28&ss=bfqt&srt=sco&sp=rl&st=2016-10-17T20%3A14%3A55Z&se=2021-10-18T20%3A19%3A00Z&sig=IEoOdmeYnE9%2FKiJDSHFSYsz4AkNa%2F%2BTx61FuQ%2FfKHefqoBE%3D'),
    FIELDQUOTE = '"',
    FIELDTERMINATOR=';',
    ROWTERMINATOR='0X0A',
    ENCODING = 'UTF8',
    DATEFORMAT = 'ymd',
	MAXERRORS = 10,
	ERRORFILE = '/errorsfolder',--path starting from the storage container
	IDENTITY_INSERT = 'ON'
)
```
## Usar Copy para carregar um arquivo de texto com delimitadores de linha não padrão<br>
Uma das realidades da engenharia de dados é que muitas vezes precisamos processar dados imperfeitos.<br>
Isso significa que as fontes de dados contêm formatos de dados inválidos, registros corrompidos ou configurações personalizadas, como delimitadores não padrão.<br>
Uma das vantagens que COPY tem sobre o PolyBase é que ele dá suporte a delimitadores de linha e de coluna personalizados.<br>
Suponha que você tenha um processo noturno que ingere dados de vendas regionais de um sistema de análise de parceiro e salva os arquivos no data lake.<br>
Os arquivos de texto usam delimitadores de linha e coluna não padrão, em que as colunas são delimitadas por um "." e as linhas por uma ","<br>

```
20200421.114892.130282.159488.172105.196533,20200420.109934.108377.122039.101946.100712,20200419.253714.357583.452690.553447.653921
```
Os dados têm os seguintes campos: Date, NorthAmerica, SouthAmerica, Europe, Africa e Asia. Eles devem processar esses dados e armazená-los no Synapse Analytics.
<p>
Criar a tabela DailySalesCounts e carregar dados usando a instrução COPY.<br>

```
CREATE TABLE [wwi_staging].DailySalesCounts
    (
        [Date] [int]  NOT NULL,
        [NorthAmerica] [int]  NOT NULL,
        [SouthAmerica] [int]  NOT NULL,
        [Europe] [int]  NOT NULL,
        [Africa] [int]  NOT NULL,
        [Asia] [int]  NOT NULL
    )
GO

-- Replace <PrimaryStorage> with the workspace default storage account name.
COPY INTO wwi_staging.DailySalesCounts
FROM 'https://YOURACCOUNT.dfs.core.windows.net/wwi-02/campaign-analytics/dailycounts.txt'
WITH (
    FILE_TYPE = 'CSV',
    FIELDTERMINATOR='.',
    ROWTERMINATOR=','
)
GO
```
