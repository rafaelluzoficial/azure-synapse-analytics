# Trabalhar com funções de janela (Window Functions)
## Cláusula OVER
Esta cláusula determina o particionamento e a ordenação de um conjunto de linhas antes da aplicação de uma window function a ela associada.<br>
```
SELECT
ROW_NUMBER() OVER(PARTITION BY Region ORDER BY Quantity DESC) AS "Row Number",
Product,
Quantity,
Region
FROM wwi_security.Sale
WHERE Quantity <> 0  
ORDER BY Region;
```
Quando usamos PARTITION BY com a cláusula OVER, dividimos o conjunto de resultados da consulta em partições.<br>
A função de janela (ORDER BY) é aplicada separadamente a cada partição e a computação é reiniciada para cada partição.
<br>![image](https://user-images.githubusercontent.com/88280223/158491445-3477d31b-657f-4d29-90a1-2076398dab39.png)<br>

O script que executamos usa a cláusula OVER com a função ROW_NUMBER (1) para exibir um número de linha para cada linha dentro de uma partição.<br>
A partição em nosso caso é a coluna Região.<br>
A cláusula ORDER BY (2) especificada na cláusula OVER ordena as linhas em cada partição pela coluna Quantidade.<br>
A cláusula ORDER BY na instrução SELECT determina a ordem na qual todo o conjunto de resultados da consulta é retornado.<br>

## Funções de agregação
```
SELECT
ROW_NUMBER() OVER(PARTITION BY Region ORDER BY Quantity DESC) AS "Row Number",
Product,
Quantity,
SUM(Quantity) OVER(PARTITION BY Region) AS Total,  
AVG(Quantity) OVER(PARTITION BY Region) AS Avg,  
COUNT(Quantity) OVER(PARTITION BY Region) AS Count,  
MIN(Quantity) OVER(PARTITION BY Region) AS Min,  
MAX(Quantity) OVER(PARTITION BY Region) AS Max,
Region
FROM wwi_security.Sale
WHERE Quantity <> 0  
ORDER BY Region;
```
Adicionamos as funções de agregação SUM, AVG, COUNT, MIN e MAX. O uso da cláusula OVER é mais eficiente do que o uso de subconsultas.
<br>![image](https://user-images.githubusercontent.com/88280223/158491749-3d543036-6eb4-4424-8851-b9864dbd0473.png)<br>

## Funções analíticas
As funções analíticas computam um valor agregado com base em um grupo de linhas.<br>
Ao contrário das funções de agregação, no entanto, as funções analíticas podem retornar várias linhas para cada grupo.<br>
Use funções analíticas para calcular médias móveis, totais acumulados, percentuais ou os primeiros N resultados de um grupo.<br>
<br>
Uma empresa tem dados de vendas de livros que ela importa da loja online e deseja computar percentuais de downloads de livros pelas categorias.<br>
Para fazer isso, decidimos criar window functions que usam as funções PERCENTILE_CONT e PERCENTILE_DISC.<br>
```
-- PERCENTILE_CONT, PERCENTILE_DISC
SELECT DISTINCT c.Category  
,PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY bc.Downloads)
                    OVER (PARTITION BY Category) AS MedianCont  
,PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY bc.Downloads)
                    OVER (PARTITION BY Category) AS MedianDisc  
FROM dbo.Category AS c  
INNER JOIN dbo.BookList AS bl
    ON bl.CategoryID = c.ID
INNER JOIN dbo.BookConsumption AS bc  
    ON bc.BookID = bl.ID
ORDER BY Category
```
<br>![image](https://user-images.githubusercontent.com/88280223/158491971-e4c4dc0a-4754-4c9f-bed0-e8b4dad17bd7.png)<br>

Nesta consulta, usamos PERCENTILE_CONT (1) e PERCENTILE_DISC (2) para localizar o número mediano de downloads em cada categoria de livro.<br>
Essas funções podem não retornar o mesmo valor.<br>
PERCENTILE_CONT interpola o valor apropriado, quer ele exista ou não no conjunto de dados, enquanto PERCENTILE_DISC sempre retorna um valor real do conjunto.<br>
Para explicar melhor, PERCENTILE_DISC computa um percentil específico para obter valores classificados em um conjunto de linhas inteiro ou dentro de partições distintas de um conjunto de linhas.<br>
O valor de 0,5 passado às funções de percentil (1 e 2) calcula o 50º percentil ou a mediana dos downloads.<br>
A expressão WITHIN GROUP (3) especifica uma lista de valores para classificar e computar o percentil.<br>
Somente uma expressão ORDER BY é permitida e a ordem de classificação padrão é ascendente.<br>
A cláusula OVER (4) divide o conjunto de resultados da cláusula FROM em partições, neste caso, Categoria.<br>
A função de percentil é aplicada nessas partições.<br>

## Função LAG
```
--LAG Function
SELECT ProductId,
    [Hour] AS SalesHour,
    TotalAmount AS CurrentSalesTotal,
    LAG(TotalAmount, 1,0) OVER (ORDER BY [Hour]) AS PreviousSalesTotal,
    TotalAmount - LAG(TotalAmount,1,0) OVER (ORDER BY [Hour]) AS Diff
FROM [wwi_perf].[Sale_Index]
WHERE ProductId = 3848 AND [Hour] BETWEEN 8 AND 20;
```
A empresa deseja comparar os totais de vendas de um produto por hora ao longo do tempo, mostrando a diferença de valor.<br>
Para fazer isso, use a função analítica LAG.<br>
Essa função acessa os dados de uma linha anterior no mesmo conjunto de resultados sem usar uma autojunção.<br>
LAG fornece acesso a uma linha a um determinado deslocamento físico que antecede a linha atual.<br>
Usamos essa função analítica para comparar valores na linha atual com valores em uma linha anterior.
<br>![image](https://user-images.githubusercontent.com/88280223/158492356-9eccd2a1-037c-41d9-8e24-c62b787a12d0.png)<br>

Nesta consulta, usamos a função LAG (1) para retornar a diferença em vendas (2) para um produto específico em horas de vendas de pico (8-20).<br>
Também calculamos a diferença nas vendas de uma linha para a próxima (3).<br>
Observe que, como não há um valor de retardo disponível para a primeira linha, o padrão de zero (0) é retornado.<br>

## Cláusula ROWS
As cláusulas ROWS e RANGE limitam ainda mais as linhas dentro da partição, especificando os pontos inicial e final dentro da partição.<br>
Isso é feito pela especificação de um intervalo de linhas em relação à linha atual por associação lógica ou associação física.<br>
A associação física é obtida com o uso de uma cláusula ROWS.<br>
<br>
A empresa quer encontrar os livros que têm menos downloads por país, ao mesmo tempo que exibe o número total de downloads para cada livro dentro de cada país em ordem crescente.<br>
Para fazer isso, você usa ROWS em combinação com UNBOUNDED PRECEDING para limitar as linhas dentro da partição do País, especificando que a janela começa com a primeira linha da partição.<br>
```
-- ROWS UNBOUNDED PRECEDING
SELECT DISTINCT bc.Country, b.Title AS Book, bc.Downloads
    ,FIRST_VALUE(b.Title) OVER (PARTITION BY Country  
        ORDER BY Downloads ASC ROWS UNBOUNDED PRECEDING) AS FewestDownloads
FROM dbo.BookConsumption AS bc
INNER JOIN dbo.Books AS b
    ON b.ID = bc.BookID
ORDER BY Country, Downloads
```
<br>![image](https://user-images.githubusercontent.com/88280223/158492617-7cd5c952-eb9a-4feb-8715-26d4fe287968.png)<br>
Nesta consulta, usamos a função analítica FIRST_VALUE para recuperar o título do livro com o menor número de downloads, conforme indicado pela cláusula ROWS UNBOUNDED PRECEDING acima da partição País (1).<br>
A opção UNBOUNDED PRECEDING anterior definiu a janela iniciar para a primeira linha da partição, fornecendo o título do livro com o menor número de downloads para o país dentro da partição.
