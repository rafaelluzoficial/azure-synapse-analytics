-- this sample references external data source and external file format defined in previous section
CREATE PROCEDURE usp_calculate_population_by_year_state
AS
BEGIN
    CREATE EXTERNAL TABLE population_by_year_state
    WITH (
        LOCATION = 'population_by_year_state/',
        DATA_SOURCE = destination_ds,  
        FILE_FORMAT = parquet_file_format
    )  
    AS
    SELECT decennialTime, stateName, SUM(population) AS population
    FROM
        OPENROWSET(BULK 'https://azureopendatastorage.blob.core.windows.net/censusdatacontainer/release/us_population_county/year=*/*.parquet',
        FORMAT='PARQUET') AS [r]
    GROUP BY decennialTime, stateName
END
GO