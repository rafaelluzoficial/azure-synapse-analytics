# Trabalhar com os dados do JSON em pools de SQL
Os pools de SQL dedicados do Azure Synapse dão suporte a dados de formato JSON para serem armazenados usando colunas de tabela NVARCHAR padrão.<br>
Ele permite transformar matrizes de objetos JSON em formato de tabela.<br>
O desempenho de dados JSON pode ser otimizado usando índices columnstore e tabelas otimizadas para memória.
<br><br>

Inserir dados JSON – dados JSON podem ser inseridos usando instruções INSERT T-SQL.
<br><br>

Ler dados JSON – dados JSON podem ser lidos usando as funções T-SQL a seguir e permite executar agregação e filtro em valores JSON.<br>
- ISJSON – verificar se o texto é um JSON válido
- JSON_VALUE – extraia um valor de uma cadeia de caracteres JSON
- JSON_QUERY extrai um objeto ou uma matriz JSON de uma cadeia de caracteres JSON
<br><br>

Modificar dados JSON – os dados JSON podem ser modificados e consultados usando as funções do T-SQL a seguir, permitindo atualizar a cadeia de caracteres JSON usando T-SQL e converter dados hierárquicos em uma estrutura de tabela plana.<br>
- JSON_MODIFY – modifica um valor em uma cadeia de caracteres JSON
- OPENJSON – converte a coleção JSON em um conjunto de linhas e colunas
<br><br>

Você também pode consultar arquivos JSON usando SQL sem servidor.<br>
O objetivo da consulta é ler o tipo de arquivos JSON a seguir usando OPENROWSET.<br>
Arquivos JSON padrão em que vários documentos JSON são armazenados como uma matriz JSON.
Arquivos JSON delimitados por linha, em que os documentos JSON são separados por caractere de nova linha.<br>
As extensões comuns para esses tipos de arquivos são jsonl, ldjson e ndjson.

## Ler documentos JSON
A maneira mais fácil de ver o conteúdo do arquivo JSON é fornecer a URL do arquivo para a função OPENROWSET, especificar o formato CSV e definir os valores de 0x0b para as variáveis fieldterminator e fieldquote.<br>
Se você precisar ler arquivos JSON delimitados por linha, isso será suficiente.<br>
Se você tem um arquivo JSON clássico, defina valores 0x0b para rowterminator.<br>
A função OPENROWSET analisará o JSON e retornará todos os documentos no seguinte formato:
```
{"date_rep":"2020-07-24","day":24,"month":7,"year":2020,"cases":3,"deaths":0,"geo_id":"AF"}
{"date_rep":"2020-07-25","day":25,"month":7,"year":2020,"cases":7,"deaths":0,"geo_id":"AF"}
{"date_rep":"2020-07-26","day":26,"month":7,"year":2020,"cases":4,"deaths":0,"geo_id":"AF"}
{"date_rep":"2020-07-27","day":27,"month":7,"year":2020,"cases":8,"deaths":0,"geo_id":"AF"}
```

## Leitura de arquivos JSON
Ler arquivo JSON delimitado por linha
```
select top 10 * 
from 
    openrowset( 
        bulk 'https://pandemicdatalake.blob.core.windows.net/public/curated/covid-19/ecdc_cases/latest/ecdc_cases.jsonl', 
        format = 'csv', 
        fieldterminator ='0x0b', 
        fieldquote = '0x0b' 
    ) with (doc nvarchar(max)) as rows
```

Ler arquivo JSON padrão
```
select top 10 * 
from 
    openrowset( 
        bulk 'https://pandemicdatalake.blob.core.windows.net/public/curated/covid-19/ecdc_cases/latest/ecdc_cases.json', 
        format = 'csv', 
        fieldterminator ='0x0b', 
        fieldquote = '0x0b', 
        rowterminator = '0x0b' --> You need to override rowterminator to read classic JSON 
    ) with (doc nvarchar(max)) as rows
```

Ler o arquivo JSON clássico
```
select top 10 * 
from 
    openrowset( 
        bulk 'https://pandemicdatalake.blob.core.windows.net/public/curated/covid-19/ecdc_cases/latest/ecdc_cases.json', 
        format = 'csv', 
        fieldterminator ='0x0b', 
        fieldquote = '0x0b', 
        rowterminator = '0x0b' --> You need to override rowterminator to read classic JSON 
    ) with (doc nvarchar(max)) as rows
```

## Definindo uma fonte de dados
O exemplo anterior usa um caminho completo para o arquivo.<br>
Como alternativa, você pode criar uma fonte de dados externa com a localização que aponta para a pasta raiz do armazenamento e usar essa fonte de dados e o caminho relativo para o arquivo na função OPENROWSET:
```
create external data source covid 
with (location = 'https://pandemicdatalake.blob.core.windows.net/public/curated/covid-19/ecdc_cases');
go 
select top 10 * 
from 
    openrowset( 
        bulk 'latest/ecdc_cases.jsonl', 
        data_source = 'covid', 
        format = 'csv', 
        fieldterminator ='0x0b', 
        fieldquote = '0x0b' 
    ) with (doc nvarchar(max)) as rows 
go 
select top 10 * 
from 
    openrowset( 
        bulk 'latest/ecdc_cases.json', 
        data_source = 'covid', 
        format = 'csv', 
        fieldterminator ='0x0b', 
        fieldquote = '0x0b', 
        rowterminator = '0x0b' --> You need to override rowterminator to read classic JSON 
    ) with (doc nvarchar(max)) as rows
```

## Analisar documentos JSON
As consultas nos exemplos anteriores retornam cada documento JSON como uma cadeia de caracteres em uma linha separada do conjunto de resultados.<br>
Você pode usar funções JSON_VALUE e OPENJSON para analisar os valores em documentos JSON e retorná-los como valores relacionais.
```
JSON
{ 
    "date_rep":"2020-07-24", 
    "day":24,
    "month":7,
    "year":2020, 
    "cases":13,
    "deaths":0, 
    "countries_and_territories":"Afghanistan", 
    "geo_id":"AF", 
    "country_territory_code":"AFG", 
    "continent_exp":"Asia",
    "load_date":"2020-07-25 00:05:14", 
    "iso_country":"AF" 
}
```
Consultar arquivo JSON usando JSON_VALUE<br>
A seguinte consulta mostra como usar JSON_VALUE para recuperar valores escalares (título, editor) de documentos JSON.
```
select 
    JSON_VALUE(doc, '$.date_rep') AS date_reported, 
    JSON_VALUE(doc, '$.countries_and_territories') AS country, 
    JSON_VALUE(doc, '$.cases') as cases, 
    doc 
from 
    openrowset( 
        bulk 'latest/ecdc_cases.jsonl', 
        data_source = 'covid', 
        format = 'csv', 
        fieldterminator ='0x0b', 
        fieldquote = '0x0b' 
    ) with (doc nvarchar(max)) as rows 
order by JSON_VALUE(doc, '$.geo_id') desc
```

Consultar arquivo JSON usando OPENJSON<br>
A consulta a seguir usa OPENJSON. Ela recuperará as estatísticas de COVID relatadas na Sérvia.
```
select * 
from 
    openrowset( 
        bulk 'latest/ecdc_cases.jsonl', 
        data_source = 'covid', 
        format = 'csv', 
        fieldterminator ='0x0b', 
        fieldquote = '0x0b' 
    ) with (doc nvarchar(max)) as rows 
    cross apply openjson (doc) 
        with ( date_rep datetime2, 
                   cases int, 
                   fatal int '$.deaths', 
                   country varchar(100) '$.countries_and_territories') 
where country = 'Serbia' 
order by country, date_rep desc;
```

