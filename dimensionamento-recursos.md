# Dimensionar recursos de computação no Azure Synapse Analytics
Um dos principais recursos de gerenciamento que você tem à sua disposição no Azure Synapse Analytics é a capacidade de dimensionar os recursos de computação para pools do SQL ou do Spark para atender às demandas de processamento de seus dados.<br>
Em pools do SQL, a unidade de escala é uma abstração da potência de computação conhecida como uma unidade de data warehouse.<br>
A computação é separada do armazenamento, o que permite que você dimensione a computação independentemente dos dados em seu sistema.<br>
Isso significa que você pode escalar verticalmente e reduzir o poder de computação para atender às suas necessidades.<br>
Você pode dimensionar um pool de SQL do Synapse por meio do portal do Azure, do Azure Synapse Studio ou programaticamente usando o TSQL ou o PowerShell.

## Fazer a modificação usando Transact-SQL (MODIFY)
```
ALTER DATABASE mySampleDataWarehouse
MODIFY (SERVICE_OBJECTIVE = 'DW300c');
```

## Fazer a modificação usando PowerShell
```
Set-AzSqlDatabase -ResourceGroupName "resourcegroupname" -DatabaseName "mySampleDataWarehouse" -ServerName "sqlpoolservername" -RequestedServiceObjectiveName "DW300c"
```
