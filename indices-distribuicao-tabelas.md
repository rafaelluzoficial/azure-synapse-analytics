# Usando índices e distribuição de tabelas para melhorar o desempenho
Quando uma tabela é criada, por padrão, a estrutura de dados não tem índices e é chamada de heap.<br>
Uma estratégia de indexação bem projetada pode reduzir as operações de E/S de disco e consumir menos recursos do sistema, o que melhora o desempenho das consultas, especialmente ao usar filtragens, verificações e junções nelas.<br>
Os pools de SQL dedicados têm as seguintes opções de indexação disponíveis:

## Índice columnstore clusterizado
Os pools de SQL dedicados criam um índice columnstore clusterizado quando nenhuma opção de índice é especificada em uma tabela.<br>
As tabelas columnstore clusterizadas oferecem o nível mais alto de compactação de dados e o melhor desempenho geral de consulta.<br>
Os índices columnstore clusterizados geralmente têm melhor desempenho que os índices rowstore clusterizados ou as tabelas de heap e são normalmente a melhor escolha para tabelas grandes.<br>
Também é possível obter compactação de dados adicional com a opção de índice COLUMNSTORE_ARCHIVE.<br>
Esses tamanhos menores permitem que menos memória seja usada ao acessar e usar os dados, além de reduzirem o IOPs necessário para recuperar dados do armazenamento.
<br><br>

## Índice clusterizado
Os índices rowstore clusterizados definem como a própria tabela é armazenada, ordenando-a pelas colunas usadas para o índice.<br>
Pode haver apenas um índice clusterizado em uma tabela.<br>
Os índices clusterizados são melhores para consultas e junções que requerem a verificação dos intervalos de dados, preferencialmente na mesma ordem definida para o índice.
<br>
Criar uma tabela de distribuição de hash com um índice columnstore clusterizado
```
CREATE TABLE [wwi_perf].[Sale_Hash]
WITH
(
   DISTRIBUTION = HASH ( [CustomerId] ),
   CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT
   *
FROM
   [wwi_perf].[Sale_Heap]
```

## Índice não clusterizado
Um índice não clusterizado pode ser definido em uma tabela ou exibição com um índice clusterizado ou em um heap.<br>
Cada linha do índice não clusterizado contém o valor da chave não clusterizada e um localizador de linha.<br>
Essa é uma estrutura de dados diferente/adicional para a tabela ou o heap.<br>
Você pode criar vários índices não clusterizados em uma tabela.<br>
Esses índices funcionam melhor para as colunas em uma junção, para a instrução Group by ou para as cláusulas WHERE que retornam uma correspondência exata ou poucas linhas.
