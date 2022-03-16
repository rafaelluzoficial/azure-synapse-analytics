# Execução de consulta aproximada usando funções de HyperLogLog
À medida que a empresa começa a trabalhar com grandes conjuntos de dados, ela enfrenta problemas com consultas lentas que normalmente são executadas rapidamente.<br>
Por exemplo, obter uma contagem distinta de todos os clientes nas fases iniciais da exploração de dados desacelera o processo.<br>
Como ela podem acelerar essas consultas?<br>
<br>
Você decide usar a execução aproximada com a precisão de HyperLogLog para reduzir a latência de consulta no Exchange ao custo de uma pequena redução na precisão.<br>
Esse equilíbrio funciona para a situação da empresa, em que ela só precisa ter uma ideia dos dados.<br>
<br>
Para entender seus requisitos, primeiro executamos uma contagem distinta sobre a tabela de Sale_Heap grande para encontrar a contagem de clientes distintos.
```
%%sql
SELECT COUNT(DISTINCT CustomerId) from wwi_perf.Sale_Heap
```
A consulta leva até 20 segundos para ser executada.<br>
Isso é esperado, pois contagens distintas são um dos tipos de consultas mais difíceis de otimizar.<br>
<br>
```
%sql
SELECT APPROX_COUNT_DISTINCT(CustomerId) from wwi_perf.Sale_Heap
```
A consulta leva cerca de metade do tempo para ser executada. O resultado não é exatamente o mesmo.<br>
APPROX_COUNT_DISTINCT retorna um resultado com uma precisão de 2% de cardinalidade verdadeira em média.<br>
Isso significa que, se COUNT (DISTINCT) retornar um milhão, HyperLogLog retornará um valor no intervalo de 999.736 a 1.016.234.
