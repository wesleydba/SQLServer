SELECT tn.[name] AS [Table name], ix.[name] AS [Index name],
    SUM(sz.[used_page_count]) * 8/1024/1024 AS [Index size (GB)]
FROM sys.dm_db_partition_stats AS sz
    INNER JOIN sys.indexes AS ix ON sz.[object_id] = ix.[object_id]
        AND sz.[index_id] = ix.[index_id]
    INNER JOIN sys.tables tn ON tn.OBJECT_ID = ix.object_id
where tn.[name]= 'SRC050_TTAT_LOG' -- Informe o nome da tabela.
GROUP BY tn.[name], ix.[name]
ORDER BY tn.[name]