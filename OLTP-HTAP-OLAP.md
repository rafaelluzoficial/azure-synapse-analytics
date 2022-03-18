# Soluções híbridas de processamento (HTAP), transacionais (OLTP) e analíticas (OLAP), usando Azure Synapse Analytics
## Entenda os padrões do processamento transacional, analítico e híbrido
Muitas arquiteturas de aplicativos de negócios separam o processamento transacional e o analítico em sistemas diferentes,
com os dados armazenados e processados em infraestruturas separadas.
Essas infraestruturas são conhecidas como sistemas OLTP (processamento de transações online), que trabalham com os dados operacionais,
e sistemas OLAP (processamento analítico online), que trabalham com os dados históricos, sendo cada sistema otimizado para sua tarefa específica.
Os sistemas OLTP são otimizados para lidar imediatamente com solicitações discretas de sistemas ou usuários e responder o mais rápido possível.

Os sistemas OLAP são otimizados para o processamento analítico, a ingestão, a sintetização e o gerenciamento de grandes conjuntos de dados históricos.
Os dados processados pelos sistemas OLAP são originários, em grande parte, de sistemas OLTP e precisam ser carregados em sistemas OLAP por meio de processos
em lotes conhecidos como trabalhos ETL (Extrair, Transformar e Carregar).

Devido à sua complexidade e à necessidade de copiar fisicamente grandes quantidades de dados, é gerado um atraso na disponibilidade dos dados para fornecer
insights por meio dos sistemas OLAP.<br>
À medida que cada vez mais empresas adotam processos digitais, elas reconhecem ainda mais o valor poder responder a oportunidades tomando decisões mais rápidas e bem informadas.<br>

O HTAP (Processamento Transacional/Analítico Híbrido) permite que as empresas executem análises avançadas quase em tempo real em dados armazenados
e processados por sistemas OLTP.

## Azure Cosmos DB x HTAP
O Azure Cosmos DB fornece um repositório transacional otimizado para cargas de trabalho transacionais e um repositório analítico otimizado para
cargas de trabalho analíticas, bem como um processo totalmente gerenciado para manter os dados nesses repositórios sincronizados.<br>
![image](https://user-images.githubusercontent.com/88280223/159069306-fd210e88-c6c4-4c27-8e37-7db9ac6b87a1.png)<br>

## Link do Azure Synapse para Azure Cosmos DB
O Link do Azure Synapse para Azure Cosmos DB é uma funcionalidade de HTAP nativa de nuvem que permite executar análises quase em tempo real em
dados operacionais armazenados no Azure Cosmos DB. O Link do Azure Synapse cria uma integração perfeita entre o Azure Cosmos DB e o Azure Synapse Analytics.<br>
![image](https://user-images.githubusercontent.com/88280223/159069477-83e14f42-409e-4792-bc21-df8e224f9964.png)
O Azure Synapse Analytics fornece um mecanismo de consulta SQL sem servidor para consultar o repositório analítico usando T-SQL e um mecanismo de consulta
de Apache Spark para aproveitar o repositório analítico usando Scala, Java, Python ou SQL, fornecendo ainda uma experiência de notebook amigável.

Juntos, o Azure Cosmos DB e o Synapse Analytics permitem que as organizações gerem e consumam insights de seus dados operacionais quase em tempo real,
usando as ferramentas de consulta e análise de sua escolha. Tudo isso é realizado sem a necessidade de pipelines de ETL complexos e sem afetar o desempenho dos sistemas
OLTP usando o Azure Cosmos DB.

## Integração HTAP para Cargas de Trabalho Transacionais x Analíticas
Veja casos de uso comuns da funcionalidade do Link do Azure Synapse para Azure Cosmos DB para atender necessidades comerciais reais usando análise operacional.

## Análise, previsão e relatórios em uma cadeia de suprimentos:
Como cadeias de suprimentos geram a cada minuto volumes crescentes de dados operacionais relacionados a pedidos, remessas e transações de vendas,
para ficarem um passo à frente, fabricantes e varejistas precisam de um banco de dados operacional que possa ser dimensionado de maneira a lidar com os volumes, bem como de uma plataforma analítica
para atingir um nível de inteligência contextual em tempo real.

O Link do Azure Synapse para Cosmos DB permite a essas organizações armazenar dados de seus sistemas de vendas, ingerir dados de telemetria em tempo real
de sistemas de veículos e integrar dados de seus sistemas de ERP em um repositório operacional comum no Azure Cosmos DB. Em seguida, podem aproveitar 
os dados do Synapse Analytics para habilitar cenários de análise preditiva, como monitoramento de estoque e gerenciamento de gargalos na cadeia de suprimentos (1),
além de habilitar relatórios operacionais diretamente em seus dados operacionais usando ferramentas de relatórios como o Power BI (2).<br>
![image](https://user-images.githubusercontent.com/88280223/159070990-a083f7be-8a42-4864-b056-8a21a8831561.png)<br>
<br>

## Personalização de varejo em tempo real:
No varejo, muitos varejistas baseados na Web executam análise de carrinho em tempo real para fazer recomendações de produtos para clientes que estão prestes
a comprar algo. A análise de cesta em tempo real pode aumentar as receitas das organizações, uma vez que as sugestões de destino podem estimular outras compras
de produtos normalmente comprados juntos.<br>
![image](https://user-images.githubusercontent.com/88280223/159071320-cf2f82ec-3dc4-4004-a0f9-049d86b52eff.png)<br>
<br>

## Manutenção preditiva usando a detecção de anomalias com IoT:
As inovações na IoT industrial reduziram drasticamente o tempo de inatividade de máquinas e aumentaram a eficiência geral em todos os campos da indústria.<br>
Uma dessas inovações é a análise de manutenção preditiva de máquinas na borda da nuvem.<br>
A seguinte arquitetura aplica os recursos de HTAP nativos de nuvem do Link do Azure Synapse para Azure Cosmos DB na manutenção preditiva de IoT:<br>
![image](https://user-images.githubusercontent.com/88280223/159071609-a9c66808-8f1e-4aae-9824-832739afbb70.png)<br>

## Entenda os cenários de HTAP no contexto do Link do Synapse
O HTAP (Processamento Híbrido Transacional e Analítico) permite que as empresas executem análises em sistemas de banco de dados que fornecem recursos transacionais
de alto desempenho sem afetar o desempenho desses sistemas. O HTAP permite que as organizações usem um banco de dados para atender às necessidades transacionais
e analíticas, a fim de dar suporte à análise de dados operacionais quase em tempo real e tomar decisões em tempo hábil.

Por exemplo, sua empresa usa o Azure Cosmos DB para armazenar dados de ordens de vendas e de perfil dos clientes de seu site de comércio eletrônico.
O repositório de documentos NoSQL fornecido pelo Azure Cosmos DB permite a familiaridade de gerenciar os dados usando a sintaxe SQL e, ao mesmo tempo,
ler e gravar os arquivos em uma escala maciça e global.

Embora sua empresa esteja satisfeita com os recursos e o desempenho do Azure Cosmos DB, a empresa está preocupada com o custo da execução de um grande volume
de consultas analíticas complexas necessárias para atender aos requisitos de relatórios operacionais. Eles querem acessar com eficiência todos os seus dados
operacionais armazenados no Cosmos DB sem precisar aumentar a taxa de transferência do Azure Cosmos DB e o custo associado. Eles examinaram opções para extrair
dados dos contêineres para o data lake à medida que os dados são alterados, por meio do mecanismo de feed de alterações do Azure Cosmos DB.
Os problemas dessa abordagem são o serviço extra e as dependências de código, bem como a manutenção de longo prazo da solução.
Eles poderiam executar exportações em massa por meio de um Pipeline do Azure Synapse, mas dessa maneira não teriam as informações mais atualizadas a qualquer momento.

Eles decidem habilitar o Link do Azure Synapse para o Cosmos DB e habilitar o repositório analítico nos contêineres do Azure Cosmos DB. Com essa configuração,
todos os dados transacionais são armazenados automaticamente em um repositório de coluna totalmente isolado. Esse repositório permite a análise em larga escala
dos dados operacionais no Azure Cosmos DB sem afetar as cargas de trabalho transacionais. O Link do Azure Synapse para Cosmos DB cria uma estreita integração
entre o Azure Cosmos DB e o Azure Synapse Analytics, o que permite à Adventure Works executar análises quase em tempo real dos dados operacionais sem ETL
e com isolamento de desempenho completo das cargas de trabalho transacionais da empresa.

Combinando a escala distribuída do processamento transacional do Cosmos DB e o repositório analítico interno e o poder de computação do Azure Synapse Analytics,
o Link do Azure Synapse habilita uma arquitetura de HTAP (Processamento Transacional/Analítico Híbrido) para otimizar os processos de negócios da sua empresa.
Essa integração elimina os processos de ETL, permitindo que analistas de negócios, engenheiros de dados e cientistas de dados realizem o autoatendimento e
executem pipelines de BI, análise e Machine Learning quase em tempo real sobre os dados operacionais.

## Descrevendo o repositório analítico
O repositório analítico do Azure Cosmos DB é um repositório de coluna totalmente isolado para habilitar a análise em grande escala de dados operacionais
em seu Azure Cosmos DB, sem nenhum impacto as cargas de trabalho transacionais.

## Repositório transacional orientado a linha
Os dados operacionais em um contêiner do Azure Cosmos DB são armazenados internamente em um "repositório transacional" baseado em linhas e indexado.
O formato de repositório de linha e o índice de árvore b associado foram projetados para permitir leituras e gravações transacionais rápidas, com tempos de resposta
de milissegundos e consultas operacionais de alto desempenho. À medida que o conjunto de dados cresce, consultas analíticas complexas podem ficar caras,
pois usam mais dos recursos de taxa de transferência provisionados. O aumento no consumo da taxa de transferência provisionada, por sua vez, afeta o desempenho
das cargas de trabalho transacionais.

## Repositório analítico orientado por coluna
O repositório analítico do Azure Cosmos DB aborda os desafios de complexidade e latência que ocorrem com os pipelines de ETL tradicionais.
O repositório analítico do Azure Cosmos DB pode sincronizar automaticamente dados do repositório transacional em um repositório de coluna separado.
O formato de repositório de coluna é adequado para consultas analíticas de larga escala a serem executadas de maneira otimizada, resultando na melhoria da latência dessas consultas.<br>
![image](https://user-images.githubusercontent.com/88280223/159073130-0058ad1c-1c4c-495e-aab7-7fc42d2683e9.png)<br>

## Recursos do repositório analítico
Quando cria um contêiner do Azure Cosmos DB, você tem a opção de habilitar o repositório analítico, e uma estrutura de repositório de coluna é criada
dentro do contêiner, duplicando os dados do repositório transacional. Esses dados da estrutura de repositório de coluna são persistidos separadamente
do repositório transacional orientado por linha, com as inserções, atualizações e exclusões realizadas no repositório transacional sendo copiadas
de maneira transparente por meio de um processo de sincronização automática interna totalmente gerenciado para o repositório analítico quase em tempo real.
Você pode habilitar o repositório analítico apenas no momento da criação de um contêiner.
O Link do Synapse tem suporte da API do Azure Cosmos DB SQL (principal) e da API do Azure Cosmos DB para MongoDB.

Normalmente, os dados são sincronizados automaticamente entre o repositório transacional e o repositório analítico dentro de dois minutos por meio do
processo de sincronização automática. No entanto, em algumas circunstâncias, especialmente em situações em que a taxa de transferência do banco de dados
é compartilhada com muitos contêineres, a latência da sincronização automática pode ser de até cinco minutos.

Devido ao fato de o repositório transacional e o repositório analítico serem persistidos e consultados separadamente, as cargas de trabalho associadas a eles
são isoladas umas das outras, ou seja, consultas no repositório analítico (ou no processo de sincronização automática) não afetam o desempenho nem usam recursos
(taxa de transferência ou unidades de solicitação) provisionados para o repositório transacional, e operações executadas no repositório transacional não afetam
a latência da sincronização automática.

As transações (leitura e gravação) e os custos do armazenamento analítico são cobrados separadamente do armazenamento transacional e da taxa de transferência.

Conforme novas propriedades exclusivas são adicionadas aos itens dentro do contêiner, o processo de sincronização automática também cuida automaticamente
das atualizações de esquema no repositório analítico esquematizado para você. Isso permite que você desfrute das vantagens de desempenho proporcionadas pela
esquematização sem fazer nenhum esforço.

Você pode configurar a propriedade de TTL (vida útil) padrão dos registros armazenados nos repositórios transacional e analítico de maneira independente um do outro.
O valor da TTL de um registro define quando ele será excluído automaticamente do repositório. Configurando o valor da TTL padrão dos dois repositórios,
você pode gerenciar o ciclo de vida dos dados e definir por quanto tempo eles serão retidos em cada repositório. Você pode substituir o valor padrão da
TTL (no nível do item) do repositório transacional, mas o valor padrão da TTL sempre se aplicará aos dados no repositório analítico e não poderá ser substituído no nível do item.

## Entender esquemas bem definidos
Duas restrições se aplicam à inferências de esquemas feitas pelo processo de sincronização automática conforme ele mantém de modo transparente o esquema
no repositório analítico com base em itens adicionados ou atualizados no repositório transacional:
- Você pode ter no máximo 1000 propriedades em qualquer nível de aninhamento dentro dos itens armazenados em um repositório transacional. Qualquer propriedade além disso, bem como os valores associados, não estarão presentes no repositório analítico.
- Os nomes das propriedades devem ser exclusivos quando comparados sem diferenciar maiúsculas de minúsculas. Por exemplo, as propriedades {"name": "Franklin Ye"} e {"Name": "Franklin Ye"} não podem sair no mesmo nível de aninhamento no mesmo item nem em itens diferentes dentro de um contêiner, dado que "name" e "Name" não são exclusivos quando comparados sem diferenciar maiúsculas de minúsculas.

Há dois modos de representação de esquema para os dados armazenados no repositório analítico:
- Representação de esquema bem definido
- Representação de esquema com fidelidade total

Para contas da API do SQL (principal), quando o repositório analítico está habilitado, a representação de esquema padrão no repositório analítico é bem definida. 
Para contas da API do Azure Cosmos DB para MongoDB, por sua vez, a representação de esquema padrão no repositório analítico é a representação de esquema com fidelidade total.

A representação de esquema bem definido cria uma representação de tabela simples dos dados independentes de esquema no repositório transacional à medida que os
copia para o repositório analítico.

O seguinte fragmento de código é um exemplo de documento JSON que representa um registro de perfil de cliente:
```
{
  "id": "54AB87A7-BDB9-4FAE-A668-AA9F43E26628",
  "type": "customer",
  "name": "Franklin Ye",
  "customerId": "54AB87A7-BDB9-4FAE-A668-AA9F43E26628",
  "address": {
    "streetNo": 15850,
    "streetName": "NE 40th St.",
    "postcode": "CR30AA",
  }
}
```
A representação de esquema bem definida tem as propriedades de nível superior dos documentos expostos como colunas quando consultadas do Synapse SQL e do Synapse Spark,
juntamente com os valores de coluna que representam os valores de propriedade. Exceto no caso em que esses valores são de um tipo de objeto ou de matriz, nesse caso,
uma representação JSON dos valores de propriedade é atribuída aos valores de coluna e tem as seguintes considerações adicionais:

- Uma propriedade sempre tem o mesmo tipo em vários itens
Por exemplo, {"postcode":98065} e não {"postcode": "CR30AA"} tem um esquema bem definido porque "postcode" às vezes é uma cadeia de caracteres e, às vezes, um número.
Nesse caso, o repositório analítico registra o tipo de dados do atributo postcode no repositório analítico como o tipo de dados da propriedade postcode em sua primeira
ocorrência no tempo de vida do contêiner, e os itens em que o tipo de dados do atributo postcode difere desse valor registrado não serão incluídos no repositório analítico.

- Essa condição não se aplica a propriedades nulas.
Por exemplo, {"postcode": 98065} {"postcode": null} ainda é bem definido.

- Tipos de matriz devem conter um só tipo repetido.
Por exemplo, {"postcode": [98065, "CR30AA"]} não é um esquema bem definido porque a matriz contém uma combinação de tipos inteiros e de cadeia de caracteres.

Vale ressaltar que quando o repositório analítico do Azure Cosmos DB está usando o modo de representação de esquema bem definido e os dados armazenados em documentos
adicionados ao contêiner violam as regras acima, esses documentos não são incluídos no repositório analítico.

Exemplo de registro de repositório analítico consultado no Synapse:<br>
![image](https://user-images.githubusercontent.com/88280223/159075605-9a60cc62-2e8a-4a9f-bbfc-b2801e0372e0.png)<br>

Exemplo de registro de repositório analítico consultado no Spark:<br>
![image](https://user-images.githubusercontent.com/88280223/159075657-1c485f67-bc1e-4de5-9c14-943970f1da22.png)<br>

## Representação de esquema com fidelidade total
A representação de esquema com fidelidade total cria uma representação de tabela mais complexa dos dados independentes de esquema no repositório transacional
à medida que os copia para o repositório analítico. A representação de esquema com fidelidade total tem as propriedades de nível superior dos documentos expostas
como colunas quando consultadas do SQL do Azure Synapse e do Synapse Spark, em conjunto com uma representação JSON dos valores de propriedades contidos como valores
de coluna. Isso é estendido de maneira a incluir o tipo de dados das propriedades junto com seus valores de propriedade e, assim, pode lidar melhor com esquemas
polimórficos de dados operacionais. Com essa representação de esquema, nenhum item é removido do repositório analítico devido à necessidade de atender a regras
de esquema bem definidas. Por exemplo, vejamos o seguinte documento de exemplo no repositório transacional:
```
{
  "id": "54AB87A7-BDB9-4FAE-A668-AA9F43E26628",
  "type": "customer",
  "name": "Franklin Ye",
  "customerId": "54AB87A7-BDB9-4FAE-A668-AA9F43E26628",
  "address": {
    "streetNo": 15850,
    "streetName": "NE 40th St.",
    "postcode": "CR30AA",
  }
}
```

A propriedade folha streetNo dentro do objeto aninhado address será representada no esquema do repositório analítico como "streetNo": {"Int32": "15850"} JSON.
O tipo de dados é adicionado como um sufixo ao JSON inserido para a coluna de endereço.

Dessa forma, se for adicionado ao repositório transacional outro documento em que o valor da propriedade folha streetNo for "05851"
(observe que é uma cadeia de caracteres), o esquema do repositório analítico evoluirá automaticamente sem a necessidade de estar de acordo com os tipos de propriedade
gravados anteriormente. A propriedade folha streetNo dentro do endereço aninhado será representada no esquema do repositório analítico como "streetNo":{"string":"05851"} JSON.
```
{
  "id": "54AB87A7-BDB9-4FAE-A668-AA9F43E26629",
  "type": "customer",
  "name": "Franklin Ye",
  "customerId": "54AB87A7-BDB9-4FAE-A668-AA9F43E26629",
  "address": {
    "streetNo": “05851”,
    "streetName": "NE 40th St.",
    "postcode": 98052
  }
}
```
Conjunto de resultados mostrado no Spark:<br>
![image](https://user-images.githubusercontent.com/88280223/159076452-4367b350-22e6-458a-8f9e-fd4f0b0e7eff.png)<br>

Conjunto de resultados mostrado no Synapse:<br>
![image](https://user-images.githubusercontent.com/88280223/159076498-b7cddf3f-bbd8-4445-8ec0-948f22953ed4.png)<br>

Para referência, este é um mapa de todos os tipos de dados de propriedade e suas representações com sufixo no repositório analítico, com uma indicação da API
em que há suporte para esses tipos de dados de propriedade:<br>
![image](https://user-images.githubusercontent.com/88280223/159076686-38f364d4-58d2-4ecd-b29b-2dce06860e7f.png)<br>

## Projetar cenários de write-back
O repositório analítico do Azure Cosmos DB é somente leitura do ponto de vista das cargas de trabalho analíticas; no entanto, há cenários em que os
resultados de consultas analíticas precisam ser recuperados por clientes que estão usando o repositório transacional do Cosmos DB.
Para esses requisitos, os resultados das consultas analíticas executadas em um repositório analítico do Cosmos DB podem ser gravados de volta no
repositório transacional do Cosmos DB usando o Apache Spark do Azure Synapse.
