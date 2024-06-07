--
;With
    idsize
    as
    
    (
        SELECT tn.[name] AS [Table name]
	, ix.[name] AS [Index_name]
	, SUM(sz.[used_page_count]) * 8 AS [Index size (KB)]
	, SUM(sz.[used_page_count]) * 8 / 1024 AS [Index size (MB)]
	, CAST(SUM(sz.[used_page_count]) * 8 / 1024.00 / 1024.00 AS DECIMAL(19, 2)) AS [Index size (GB)]
        FROM sys.dm_db_partition_stats AS sz
            INNER JOIN sys.indexes AS ix ON sz.[object_id] = ix.[object_id]
                AND sz.[index_id] = ix.[index_id]
            INNER JOIN sys.tables tn ON tn.OBJECT_ID = ix.object_id
        WHERE tn.[name] in ('GIC010' )
        GROUP BY tn.[name]
	,ix.[name]
        --ORDER BY 5 desc --tn.[name]
    )
,
    comando
    as
    (
        SELECT [s].[name] AS [Schema],
            [t].[name] AS [Table],
            [i].[name] AS [Index],
            [p].[partition_number] AS [Partition],
            [p].[data_compression_desc] AS [Compression],
            [i].[fill_factor],
            [p].[rows],
            'ALTER INDEX [' + [i].[name] + '] ON [' + [s].[name] + '].[' + [t].[name] + 
             '] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE' +
             CASE WHEN [i].[fill_factor] BETWEEN 1 AND 89 THEN ', FILLFACTOR = 90' ELSE '' END + 
             CASE WHEN [i].is_primary_key = 1 THEN ', ONLINE = OFF ' ELSE ', ONLINE=ON ,RESUMABLE = ON,MAXDOP =20 'END+
             ' )' AS Ds_Comando
        FROM [sys].[partitions] AS [p]
            INNER JOIN sys.tables AS [t]
            ON [t].[object_id] = [p].[object_id]
            INNER JOIN sys.indexes AS [i]
            ON [i].[object_id] = [p].[object_id] AND i.index_id = p.index_id
            INNER JOIN sys.schemas AS [s]
            ON [t].[schema_id] = [s].[schema_id]
        WHERE [p].[index_id] > 0
            AND [t].[name] in ('GIC010' )
            --   AND [p].[rows] > 10000
            AND [p].[data_compression_desc] = 'NONE'
        --ORDER BY [p].[rows]  asc          
    )
select *
from idsize
    inner join comando on [comando].[Index] = idsize.[Index_name]
ORDER BY 5 DESC


