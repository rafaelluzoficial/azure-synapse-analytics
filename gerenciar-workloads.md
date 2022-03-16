# Gerenciar cargas de trabalho no Azure Synapse Analytics
O Azure Synapse Analytics permite que você crie, controle e gerencie a disponibilidade de recursos quando as cargas de trabalho estão competindo.<br>
Isso permite gerenciar a importância relativa de cada carga de trabalho ao aguardar os recursos disponíveis.
<br>
O gerenciamento de carga de trabalho do pool de SQL dedicado no Azure Synapse consiste em três conceitos de alto nível:<br>
- Classificação da carga de trabalho
- Importância da carga de trabalho
- Isolamento de carga de trabalho
<br>
Esses recursos oferecem mais controle sobre como sua carga de trabalho utiliza os recursos do sistema.<br>

## Classificação de carga de trabalho
A classificação mais simples e mais comum é a "carga" e a "consulta".<br>
Você carrega dados com instruções "insert", "update" e "delete", e consulta com a instrução "select".<br>
Você também pode separar "carga" e "consulta em subclasses.<br>
A subclasse oferece mais controle sobre suas cargas de trabalho.<br>
Por exemplo, as cargas de trabalho de consulta podem consistir em "atualizações de cubo", "consultas de painel", "consultas ad hoc", etc.<br>
Você pode atribuir a cada uma dessas cargas subclasses, recursos ou "configurações de importância".<br>

## Importância da carga de trabalho
A importância da carga de trabalho influencia a ordem em que uma solicitação obtém acesso aos recursos.<br>
Em um sistema ocupado, uma solicitação com maior importância acessa os recursos primeiro.<br>
Há cinco níveis de importância:<br>
- low
- below_normal
- normal
- above_normal
- high
<br>

Criar um classificador de carga de trabalho para dar importância a determinadas consultas:<br>
Sua organização perguntou a você se havia uma forma de marcar consultas executadas pelo CEO como mais importantes do que outras para que elas não parecessem lentas devido ao carregamento de dados pesado ou a outras cargas de trabalho na fila.<br>
Você decide criar um classificador de carga de trabalho e adicionar importância para priorizar as consultas do CEO.<br>
<br>
1o Passo - Confirmar que não há nenhuma consulta sendo executada atualmente por usuários conectados como asa.sql.workload01, representando o CEO da organização ou asa.sql.workload02 representando o Analista de Dados que está trabalhando no projeto:
```
--First, let's confirm that there are no queries currently being run by users logged in workload01 or workload02

SELECT s.login_name, r.[Status], r.Importance, submit_time, 
start_time ,s.session_id FROM sys.dm_pdw_exec_sessions s 
JOIN sys.dm_pdw_exec_requests r ON s.session_id = r.session_id
WHERE s.login_name IN ('asa.sql.workload01','asa.sql.workload02') and Importance
is not NULL AND r.[status] in ('Running','Suspended') 
--and submit_time>dateadd(minute,-2,getdate())
ORDER BY submit_time ,s.login_name
```
2o Passo - Daremos prioridade às consultas do usuário asa.sql.workload01 implementando o recurso asa.sql.workload01:
```
IF EXISTS (SELECT * FROM sys.workload_management_workload_classifiers WHERE name = 'CEO')
BEGIN
    DROP WORKLOAD CLASSIFIER CEO;
END
CREATE WORKLOAD CLASSIFIER CEO
  WITH (WORKLOAD_GROUP = 'largerc'
  ,MEMBERNAME = 'asa.sql.workload01',IMPORTANCE = High);
```
3o Passo - Comparar a importância das consultas de asa.sql.workload01 e asa.sql.workload02
```
SELECT s.login_name, r.[Status], r.Importance, submit_time, start_time ,s.session_id FROM sys.dm_pdw_exec_sessions s 
JOIN sys.dm_pdw_exec_requests r ON s.session_id = r.session_id
WHERE s.login_name IN ('asa.sql.workload01','asa.sql.workload02') and Importance
is not NULL AND r.[status] in ('Running','Suspended') and submit_time>dateadd(minute,-2,getdate())
ORDER BY submit_time ,status desc
```

## Isolamento de carga de trabalho
O isolamento da carga de trabalho reserva ou limitar recursos para um grupo de carga de trabalho, mantidos exclusivamente para esse grupo, para garantir a execução.<br>
<br>
Reservar recursos para cargas de trabalho específicas por meio de isolamento de carga de trabalho:<br>
<br>
1o Passo - Criar um grupo de carga de trabalho chamado CEODemo para reservar recursos para consultas executadas pelo CEO.<br>
O script abaixo cria um grupo de carga de trabalho chamado CEODemo para reservar recursos exclusivamente para este grupo.<br>
MIN_PERCENTAGE_RESOURCE definido como 50% e REQUEST_MIN_RESOURCE_GRANT_PERCENT definido como 25% tem simultaneidade 2 garantida.<br>
```
IF NOT EXISTS (SELECT * FROM sys.workload_management_workload_groups where name = 'CEODemo')
BEGIN
    Create WORKLOAD GROUP CEODemo WITH  
    ( MIN_PERCENTAGE_RESOURCE = 50        -- integer value
    ,REQUEST_MIN_RESOURCE_GRANT_PERCENT = 25 --  
    ,CAP_PERCENTAGE_RESOURCE = 100
    )
END
```

2o Passo - Criar um classificador de carga de trabalho chamado CEODreamDemo que atribui ao grupo de carga de trabalho a importância.<br>
```
IF NOT EXISTS (SELECT * FROM sys.workload_management_workload_classifiers where  name = 'CEODreamDemo')
BEGIN
    Create Workload Classifier CEODreamDemo with
    ( Workload_Group ='CEODemo',MemberName='asa.sql.workload02',IMPORTANCE = BELOW_NORMAL);
END
```

3o Passo - Confirmar que não há nenhuma consulta ativa em execução por asa.sql.workload02<br>
```
SELECT s.login_name, r.[Status], r.Importance, submit_time,
start_time ,s.session_id FROM sys.dm_pdw_exec_sessions s
JOIN sys.dm_pdw_exec_requests r ON s.session_id = r.session_id
WHERE s.login_name IN ('asa.sql.workload02') and Importance
is not NULL AND r.[status] in ('Running','Suspended')
ORDER BY submit_time, status
```

4o Passo - Verifique a importancia de todas as consultas asa.sql.workload02<br>
```
SELECT s.login_name, r.[Status], r.Importance, submit_time,
start_time ,s.session_id FROM sys.dm_pdw_exec_sessions s
JOIN sys.dm_pdw_exec_requests r ON s.session_id = r.session_id
WHERE s.login_name IN ('asa.sql.workload02') and Importance
is not NULL AND r.[status] in ('Running','Suspended')
ORDER BY submit_time, status
```

5o Passo - Definir o mínimo de 3,25% de recursos por solicitação<br>
```
IF  EXISTS (SELECT * FROM sys.workload_management_workload_classifiers where group_name = 'CEODemo')
BEGIN
    Drop Workload Classifier CEODreamDemo
    DROP WORKLOAD GROUP CEODemo
    --- Creates a workload group 'CEODemo'.
        Create  WORKLOAD GROUP CEODemo WITH  
    (MIN_PERCENTAGE_RESOURCE = 26 -- integer value
        ,REQUEST_MIN_RESOURCE_GRANT_PERCENT = 3.25 -- factor of 26 (guaranteed more than 4 concurrencies)
    ,CAP_PERCENTAGE_RESOURCE = 100
    )
    --- Creates a workload Classifier 'CEODreamDemo'.
    Create Workload Classifier CEODreamDemo with
    (Workload_Group ='CEODemo',MemberName='asa.sql.workload02',IMPORTANCE = BELOW_NORMAL);
END
```

Passo 6 - Validar as alterações
```
SELECT s.login_name, r.[Status], r.Importance, submit_time,
start_time ,s.session_id FROM sys.dm_pdw_exec_sessions s
JOIN sys.dm_pdw_exec_requests r ON s.session_id = r.session_id
WHERE s.login_name IN ('asa.sql.workload02') and Importance
is  not NULL AND r.[status] in ('Running','Suspended')
ORDER BY submit_time, status
```
