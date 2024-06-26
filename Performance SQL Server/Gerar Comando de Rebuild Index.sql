
--REBUILD INDEX
SELECT [s].[name] AS [Schema],
    OBJECT_NAME(ips.OBJECT_ID)
 , i.NAME
 , ips.index_id
 , index_type_desc
 , avg_fragmentation_in_percent
 , avg_page_space_used_in_percent
 , page_count
 , p.name
 ,
    'ALTER INDEX [' + [i].[name] + '] ON ' +  +'[' + [s].[name] + ']' + '.[' + [p].[name] + 
             '] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE' +
             CASE WHEN [i].[fill_factor] BETWEEN 1 AND 89 THEN ', FILLFACTOR = 90' ELSE '' END + 
             CASE WHEN [i].is_primary_key = 1 THEN ', ONLINE = OFF ' ELSE ', ONLINE=ON 'END+
             ' )' AS Ds_Comando
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
    INNER JOIN sys.indexes i ON (ips.object_id = i.object_id)
    inner join sys.tables p ON [i].[object_id] = [p].[object_id]
    INNER JOIN sys.schemas AS [s] ON [p].[schema_id] = [s].[schema_id]
        AND (ips.index_id = i.index_id)
        and avg_fragmentation_in_percent > 30
ORDER BY avg_fragmentation_in_percent DESC

---
--REBUILD INDEX
SELECT OBJECT_NAME(ips.OBJECT_ID)
 , i.NAME
 , ips.index_id
 , index_type_desc
 , avg_fragmentation_in_percent
 , avg_page_space_used_in_percent
 , page_count
 , p.name
 ,
    'ALTER INDEX [' + [i].[name] + '] ON .[' + [p].[name] + 
             '] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE' +
             CASE WHEN [i].[fill_factor] BETWEEN 1 AND 89 THEN ', FILLFACTOR = 90' ELSE '' END + 
             CASE WHEN [i].is_primary_key = 1 THEN ', ONLINE = OFF ' ELSE ', ONLINE=ON 'END+
             ' )' AS Ds_Comando
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
    INNER JOIN sys.indexes i ON (ips.object_id = i.object_id)
    inner join sys.tables p ON [i].[object_id] = [p].[object_id]
        AND (ips.index_id = i.index_id)
        and avg_fragmentation_in_percent > 10
ORDER BY avg_fragmentation_in_percent DESC