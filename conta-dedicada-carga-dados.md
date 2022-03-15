# Criar uma conta dedicada para realizar carga de dados
Um erro que muitas pessoas cometem ao explorar os pools de SQL dedicados pela primeira vez é usar a conta de administrador de serviços como aquela usada para carregar dados.
Essa conta é limitada a usar a classe de recurso dinâmico smallrc que pode usar entre 3% e 25% dos recursos, dependendo do nível de desempenho dos pools de SQL provisionados.
Em vez disso, é melhor criar contas específicas atribuídas a diferentes classes de recursos dependentes da tarefa prevista.
Isso otimizará o desempenho de carga e manterá a simultaneidade conforme necessário, gerenciando os slots de recursos disponíveis no pool de SQL dedicado.
Este exemplo cria um usuário de carregamento classificado para um grupo de carga de trabalho específico.
<p>

A primeira etapa é conectar-se ao mestre e criar um logon.
```
-- Connect to master
CREATE LOGIN loader WITH PASSWORD = 'a123STRONGpassword!';
```

Em seguida, conecte-se ao pool de SQL dedicado e crie um usuário.
O código a seguir pressupõe que você esteja conectado ao banco de dados chamado mySampleDataWarehouse.
Ele mostra como criar um usuário chamado Loader e fornece permissões de usuário para criar e carregar tabelas usando a instrução COPY.
Em seguida, classifica o usuário para o grupo de cargas de trabalho de carregamentos DataLoads com o máximo de recursos.

```
-- Connect to the SQL pool
CREATE USER loader FOR LOGIN loader;
GRANT ADMINISTER DATABASE BULK OPERATIONS TO loader;
GRANT INSERT ON <yourtablename> TO loader;
GRANT SELECT ON <yourtablename> TO loader;
GRANT CREATE TABLE TO loader;
GRANT ALTER ON SCHEMA::dbo TO loader;

CREATE WORKLOAD GROUP DataLoads
WITH ( 
    MIN_PERCENTAGE_RESOURCE = 100
    ,CAP_PERCENTAGE_RESOURCE = 100
    ,REQUEST_MIN_RESOURCE_GRANT_PERCENT = 100
    );

CREATE WORKLOAD CLASSIFIER [wgcELTLogin]
WITH (
        WORKLOAD_GROUP = 'DataLoads'
    ,MEMBERNAME = 'loader'
);
```
