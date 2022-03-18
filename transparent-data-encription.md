# Criptografia no Azure Synapse Analytics
## O que é Transparent Data Encryption?
A TDE (Transparent Data Encryption) é um mecanismo de criptografia para ajudá-lo a proteger o Azure Synapse Analytics.<br>
Ela protegerá o Azure Synapse Analytics contra ameaças de atividades offline mal-intencionadas.<br>
A maneira como a TDE fará isso é criptografando os dados inativos.<br>
O TDE realiza a criptografia e a descriptografia em tempo real do banco de dados, de backups associados e de arquivos de log de transações em repouso sem a necessidade de fazer alterações no aplicativo.<br>
Para usar a TDE para o Azure Synapse Analytics, é preciso habilitá-la manualmente.
O que a TDE faz é executar a criptografia e a descriptografia de E/S de dados no nível de página em tempo real.<br>
Quando uma página é lida na memória, ela é descriptografada, e criptografada novamente antes de ser gravada no disco.<br>
A TDE criptografa todo o armazenamento de base de dados, usando uma chave simétrica chamada de DEK (chave de criptografia de banco de dados).<br>
A DEK é protegida pelo Transparent Data Encryption, que pode ser um certificado (gerenciado por um serviço) ou uma chave assimétrica armazenada no Azure Key Vault (gerenciado pelo cliente).
O TDE é definido no nível do servidor (incluindo instâncias/réplicas), sendo herdado por todos os bancos de dados anexados ou alinhados a esse servidor.<br>

## Transparent Data Encryption Gerenciado por Serviço (Certificado)
Nessa configuração padrão a DEK é protegida por um certificado interno, exclusivo para cada servidor, com o algoritmo de criptografia AES256.<br>
Por padrão, a TDE gerenciada por serviço é usada, portanto, um certificado TDE é gerado automaticamente para o servidor que contém o banco de dados.<br>

## Transparent Data Encryption Gerenciado por Usuário (Azure Key Vault)
Neste cenário, o protetor de TDE que criptografa a DEK é uma chave assimétrica gerenciada pelo cliente, armazenada em seu próprio Azure Key Vault.<br>
O Azure Synapse Analytics precisa receber permissões para o Key Vault do cliente para descriptografar e criptografar o DEK.<br>
Se as permissões do servidor para o Key Vault forem revogadas, um banco de dados não poderá ser acessado e todos os dados serão criptografados.

## Gerenciar Transparent Data Encryption no Portal do Azure
Para o Azure Synapse Analytics, você pode gerenciar TDE para o banco de dados no portal do Azure depois de entrar com a conta de administrador ou colaborador do Azure.<br>
As configurações de TDE podem ser encontradas no seu banco de dados de usuário.<br>
![image](https://user-images.githubusercontent.com/88280223/159047015-0038ef11-6011-4bb7-a376-b04472c2976b.png)<br>

## Como mover um banco de dados protegido por TDE?
É um padrão muito comum acessar ou ingerir dados de fontes externas.<br>
A menos que a fonte de dados externa permita acesso anônimo, é muito provável que você precise proteger sua conexão com uma credencial ou uma senha.<br>
No Azure Synapse Analytics, o processo de integração é simplificado por meio de Linked Services.<br>
Ao fazer isso, os detalhes da conexão podem ser armazenados no Linked Service ou no Azure Key Vault.<br>
Por meio do Apache Spark, utilizando a biblioteca TokenLibrary, você poderá fazer referência a um Linked Service para recuperar as informações de credenciais de acesso.

Nestes exemplo, para recuperarmos a cadeia de conexão, usamos a função getConnectionString, passando o nome do Linked Service.
```
// Scala
// retrieve connectionstring from TokenLibrary
import com.microsoft.azure.synapse.tokenlibrary.TokenLibrary
val connectionString: String = TokenLibrary.getConnectionString("<LINKED SERVICE NAME>")
println(connectionString)
```

```
# Python
# retrieve connectionstring from TokenLibrary
from pyspark.sql import SparkSession
sc = SparkSession.builder.getOrCreate()
token_library = sc._jvm.com.microsoft.azure.synapse.tokenlibrary.TokenLibrary
connection_string = token_library.getConnectionString("<LINKED SERVICE NAME>")
print(connection_string)
```
