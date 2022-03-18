# Gerenciar acesso a dados em nível de linhas e colunas
A lógica de gestão de acesso a dados por meio de linas e colunas está localizada na camada de banco de dados, e não na camada de dados de nível de aplicativo.<br>
Se precisar acessar dados de qualquer camada, o banco de dados deverá aplicar a restrição de acesso toda vez que o user tentar acessar dados de outra camada.<br>

## Segurança em nível de coluna no Azure Synapse Analytics (RCS)
Permite restringir o acesso a colunas para proteger dados confidenciais.<br>
Por exemplo, se você quiser garantir que um usuário específico 'Leo' só possa acessar determinadas colunas de uma tabela porque ele está em um departamento específico.<br>
O motivo para fazer isso é garantir que sua segurança seja confiável e robusta, já que estamos reduzindo a área de segurança geral.<br>
A maneira de implementar a segurança no nível da coluna é usar a instrução GRANT do T-SQL.<br>
Usando essa instrução, o SQL e o AAD (Azure Active Directory) dão suporte à autenticação.<br>
<br>
O exemplo a seguir mostra como restringir TestUser de acessar a coluna SSN da tabela Membership:<br>
Crie a tabela Membership com a coluna SSN usada para armazenar números de seguro social
```
CREATE TABLE Membership
  (MemberID int IDENTITY,
   FirstName varchar(100) NULL,
   SSN char(9) NOT NULL,
   LastName varchar(100) NOT NULL,
   Phone varchar(12) NULL,
   Email varchar(100) NULL);
```
Permita que TestUser acesse todas as colunas, exceto a coluna SSN, que tem os dados confidenciais
```
GRANT SELECT ON Membership(MemberID, FirstName, LastName, Phone, Email) TO TestUser;
```
As consultas executadas como TestUser falharão se elas incluírem a coluna SSN
```
SELECT * FROM Membership;

-- Msg 230, Level 14, State 1, Line 12
-- The SELECT permission was denied on the column 'SSN' of the object 'Membership', database 'CLS_TestDW', schema 'dbo'.
```

## Segurança em nível de linha no Azure Synapse Analytics (RLS)
A RLS ajuda a implementar restrições no acesso à linha de dados.<br>
Você pode implementar a RLS em casos como:
- Caso o user só possa acessar linhas de dados que são importantes para o departamento dele.
- Se quiser restringir o acesso apenas aos dados de clientes que são relevantes para a empresa.

O acesso a dados no nível da linha em uma tabela é resringido por meio de uma função com predicado de segurança (filtros).<br>
Essa função será invocada e imposta pela política de segurança criada por você.<br>
Os filtros serão aplicados quando os dados forem lidos da tabela base.<br>
O filtro afeta todas as operações GET como: SELECT, DELETE, UPDATE.<br>
Não se pode selecionar, excluir ou atualizar linhas filtradas.<br>
O que se pode fazer é atualizar as linhas antes da filtragem.<br>
Os filtros RLS são equivalentes a acrescentar uma cláusula WHERE TenantId = 42.<br>

## Políticas de Segurança e Permissões
A maneira de implementar a RLS é usando criando Políticas de Segurança com a instrução CREATE SECURITY POLICY.<br>
Para alterar ou remover as políticas de segurança utilize a instrução ALTER ANY SECURITY POLICY, destinada a usuários altamente privilegiados.<br>
Depois de configurar as políticas de segurança, elas serão aplicadas a todos os usuários (incluindo os usuários DBO no banco de dados).<br>
Se forem necessário usuários especiais altamente privilegiados, como um sysadmin ou db_owner, que precisam ver todas as linhas,
também nestes casos serão necessárias política de segurança para isso.<br>

Esse pequeno exemplo cria três usuários e uma external table com seis linhas.<br>
```
--run in master
CREATE LOGIN Manager WITH PASSWORD = '<user_password>'
GO
CREATE LOGIN Sales1 WITH PASSWORD = '<user_password>'
GO
CREATE LOGIN Sales2 WITH PASSWORD = '<user_password>'
GO

--run in master and your SQL pool database
CREATE USER Manager FOR LOGIN Manager;  
CREATE USER Sales1  FOR LOGIN Sales1;  
CREATE USER Sales2  FOR LOGIN Sales2 ;
```
Crie uma tabela para armazenar dados<br>
```
CREATE TABLE Sales  
    (  
    OrderID int,  
    SalesRep sysname,  
    Product varchar(10),  
    Qty int  
    );
```
Preencha a tabela com seis linhas de dados, mostrando três pedidos para cada representante de vendas<br>
```
INSERT INTO Sales VALUES (1, 'Sales1', 'Valve', 5);
INSERT INTO Sales VALUES (2, 'Sales1', 'Wheel', 2);
INSERT INTO Sales VALUES (3, 'Sales1', 'Valve', 4);
INSERT INTO Sales VALUES (4, 'Sales2', 'Bracket', 2);
INSERT INTO Sales VALUES (5, 'Sales2', 'Wheel', 5);
INSERT INTO Sales VALUES (6, 'Sales2', 'Seat', 5);
-- View the 6 rows in the table  
SELECT * FROM Sales;
```
Crie uma tabela externa do Azure Synapse na tabela de Vendas recém-criada<br>
```
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<user_password>';
CREATE DATABASE SCOPED CREDENTIAL msi_cred WITH IDENTITY = 'Managed Service Identity';

CREATE EXTERNAL DATA SOURCE ext_datasource_with_abfss WITH (TYPE = hadoop, LOCATION = 'abfss://<file_system_name@storage_account>.dfs.core.windows.net', CREDENTIAL = msi_cred);
CREATE EXTERNAL FILE FORMAT MSIFormat  WITH (FORMAT_TYPE=DELIMITEDTEXT);
CREATE EXTERNAL TABLE Sales_ext WITH (LOCATION='<your_table_name>', DATA_SOURCE=ext_datasource_with_abfss, FILE_FORMAT=MSIFormat, REJECT_TYPE=Percentage, REJECT_SAMPLE_VALUE=100, REJECT_VALUE=100)
AS SELECT * FROM sales;
```
Conceda SELECT para os três usuários na tabela externa Sales_ext criada<br>
```
GRANT SELECT ON Sales_ext TO Sales1;  
GRANT SELECT ON Sales_ext TO Sales2;  
GRANT SELECT ON Sales_ext TO Manager;
```
Crie um esquema e uma função com valor de tabela embutida<br>.
A função retorna 1 quando uma linha da coluna SalesRep é igual ao usuário que executa a consulta (@SalesRep = USER_NAME())
ou se o usuário que executa a consulta é o usuário Gerente (USER_NAME() = 'Manager').<br>
```
CREATE SCHEMA Security;  
GO  
  
CREATE FUNCTION Security.fn_securitypredicate(@SalesRep AS sysname)  
    RETURNS TABLE  
WITH SCHEMABINDING  
AS  
    RETURN SELECT 1 AS fn_securitypredicate_result
WHERE @SalesRep = USER_NAME() OR USER_NAME() = 'Manager';
```
Crie uma política de segurança para external table Sales_ext usando a função Security.fn_securitypredicate como um predicado de filtro.<br>
O estado deve ser definido como ON para habilitar a política.
```
CREATE SECURITY POLICY SalesFilter_ext
ADD FILTER PREDICATE Security.fn_securitypredicate(SalesRep)
ON dbo.Sales_ext  
WITH (STATE = ON);
```
Agora teste o predicado de filtragem selecionando a tabela externa Sales_ext.<br>
Faça login como cada usuário: Vendas1, Vendas2 e Gerente e execute o comando a seguir como cada usuário.<br>
O gerente deve ver todas as seis linhas.<br>
Os usuários Vendas1 e Vendas2 deverão ver apenas suas vendas.<br>
```
SELECT * FROM Sales_ext;
```
Altere a política de segurança para desabilitar a política específica
```
ALTER SECURITY POLICY SalesFilter_ext  
WITH (STATE = OFF);
```
Agora, os usuários Vendas1 e Vendas2 podem ver todas as seis linhas.<br>
<br>
Conectar-se ao banco de dados do Azure Synapse para limpar recursos
```
DROP USER Sales1;
DROP USER Sales2;
DROP USER Manager;

DROP SECURITY POLICY SalesFilter_ext;
DROP TABLE Sales;
DROP EXTERNAL TABLE Sales_ext;
DROP EXTERNAL DATA SOURCE ext_datasource_with_abfss ;
DROP EXTERNAL FILE FORMAT MSIFormat;
DROP DATABASE SCOPED CREDENTIAL msi_cred; 
DROP MASTER KEY;

DROP LOGIN Sales1;
DROP LOGIN Sales2;
DROP LOGIN Manager;
```
Em seguida, ele cria uma função com valor de tabela embutida e uma política de segurança para a tabela externa.<br>
O exemplo mostra como as instruções select são filtrados para os diversos usuários.
