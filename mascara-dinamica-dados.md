# Gerenciar dados confidenciais com a Máscara Dinâmica de Dados
A Máscara Dinâmica de Dados garante exposição limitada de dados a usuários sem privilégios, de modo que eles não possam ver os dados que estão sendo mascarados.<br>
A Máscara Dinâmica de Dados é um recurso de segurança baseado em políticas.<br>
![image](https://user-images.githubusercontent.com/88280223/159042369-7992c640-23f5-41cc-91df-be16a1f69467.png)<br>
Para o Azure Synapse Analytics, a maneira de configurar uma política de Máscara Dinâmica de Dados é usar o PowerShell ou a API REST.<br>
A configuração da política de Máscara Dinâmica de Dados pode ser feita pelas funções administrador do Banco de Dados SQL do Azure, administrador do servidor ou Gerenciador de Segurança do SQL.<br>

Analisando políticas de Máscara Dinâmica de Dados:
- Usuários SQL excluídos das Políticas de Máscara Dinâmica de Dados: Usuários com privilégios de administrador sempre são excluídos do mascaramento e veem os dados originais sem qualquer máscara.
- Regras de mascaramento: São um conjunto de regras que definem os campos designados que serão mascarados, incluindo a função de mascaramento que será usada.
- Funções de mascaramento: São um conjunto de métodos que controlam a exposição de dados para cenários diferentes.<br>
