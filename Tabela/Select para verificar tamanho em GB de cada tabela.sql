-- Tamanho em GB, sem registros. Se quiser registros, colocar t.rows na consulta
USE [nome_database] -- informe o seu database
GO
SELECT
    t.NAME AS TableName,
    s.Name AS SchemaName,
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00/1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceGB,
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00/1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceGB,
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00/1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceGB
FROM
    sys.tables t
    INNER JOIN
    sys.indexes i ON t.OBJECT_ID = i.object_id
    INNER JOIN
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
    INNER JOIN
    sys.allocation_units a ON p.partition_id = a.container_id
    LEFT OUTER JOIN
    sys.schemas s ON t.schema_id = s.schema_id
WHERE
    t.NAME NOT LIKE 'dt%'
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255

GROUP BY
    t.Name, s.Name, p.Rows
ORDER BY
    TotalSpaceGB DESC, t.Name


