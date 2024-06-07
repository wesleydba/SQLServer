--Apenas Estatísticas que necessitam de atualização (Novo Filtro Rotina Administrativa - 10 dias)
SELECT OBJECT_SCHEMA_NAME(obj.object_id) SchemaName, obj.name TableName,
    stat.name, modification_counter,
    [rows], rows_sampled, rows_sampled* 100 / [rows] AS [% Rows Sampled],
    last_updated,
    'UPDATE STATISTICS ' +OBJECT_SCHEMA_NAME(obj.object_id)+'.'+obj.name+'(['+ stat.name +'])' + ' WITH FULLSCAN'
FROM sys.objects AS obj
    INNER JOIN sys.stats AS stat ON stat.object_id = obj.object_id
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
WHERE       obj.is_ms_shipped = 0
    AND (sp.modification_counter* 100 / [rows] >= 30 OR sp.rows_sampled* 100 / [rows] <= 70 OR DATEDIFF(DAY, sp.last_updated, GETDATE()) > 10)
    AND obj.name not like '%_TTAT_LOG%' COLLATE Latin1_General_CI_AI
ORDER BY    modification_counter DESC
---
DECLARE @Command NVARCHAR(MAX)

DECLARE CommandCursor CURSOR FOR
SELECT 'UPDATE STATISTICS ' + OBJECT_SCHEMA_NAME(obj.object_id) + '.' + obj.name + '([' + stat.name + '])' + ' WITH FULLSCAN'
FROM sys.objects AS obj
    INNER JOIN sys.stats AS stat ON stat.object_id = obj.object_id
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
WHERE obj.is_ms_shipped = 0
    AND (sp.modification_counter * 100 / [rows] >= 30 OR sp.rows_sampled * 100 / [rows] <= 70 OR DATEDIFF(DAY, sp.last_updated, GETDATE()) > 10)
    AND obj.name NOT LIKE '%_TTAT_LOG%' COLLATE Latin1_General_CI_AI
ORDER BY modification_counter DESC

OPEN CommandCursor
FETCH NEXT FROM CommandCursor INTO @Command

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC sp_executesql @Command

    FETCH NEXT FROM CommandCursor INTO @Command
END

CLOSE CommandCursor
DEALLOCATE CommandCursor
---
SELECT OBJECT_SCHEMA_NAME(obj.object_id) SchemaName,
    obj.name TableName,
    stat.name, modification_counter,
    [rows], rows_sampled, rows_sampled* 100 / [rows] AS [% Rows Sampled],
    last_updated ,
    'UPDATE STATISTICS ' +OBJECT_SCHEMA_NAME(obj.object_id)+'.'+obj.name+'(['+ stat.name +'])' + ' WITH FULLSCAN'
FROM sys.objects AS obj
    INNER JOIN sys.stats AS stat ON stat.object_id = obj.object_id
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
WHERE       obj.is_ms_shipped = 0
    AND (rows_sampled* 100 / [rows]) < 70
--AND last_updated <= DATEADD(dd, - 7, GETDATE())
--and obj.name not like '%TTAT_LOG'
ORDER BY    modification_counter  ASC

---
SELECT OBJECT_SCHEMA_NAME(obj.object_id) SchemaName, obj.name TableName,
    stat.name, modification_counter,
    [rows], rows_sampled, rows_sampled* 100 / [rows] AS [% Rows Sampled],
    last_updated
FROM sys.objects AS obj
    INNER JOIN sys.stats AS stat ON stat.object_id = obj.object_id
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
WHERE       obj.is_ms_shipped = 0
    AND (rows_sampled* 100 / [rows]) < 70
ORDER BY    modification_counter DESC

---

SELECT OBJECT_SCHEMA_NAME(obj.object_id) SchemaName, obj.name TableName,
    stat.name, modification_counter,
    [rows], rows_sampled, rows_sampled* 100 / [rows] AS [% Rows Sampled],
    last_updated ,
    'UPDATE STATISTICS ' + obj.name COLLATE LATIN1_General_CI_AS + ' WITH FULLSCAN'
FROM sys.objects AS obj
    INNER JOIN sys.stats AS stat ON stat.object_id = obj.object_id
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
WHERE       obj.is_ms_shipped = 0
    AND (rows_sampled* 100 / [rows]) < 70
ORDER BY    modification_counter DESC

---

SELECT OBJECT_SCHEMA_NAME(obj.object_id) SchemaName, obj.name TableName,
    stat.name, modification_counter,
    [rows], rows_sampled, rows_sampled* 100 / [rows] AS [% Rows Sampled],
    last_updated ,
    'UPDATE STATISTICS ' + obj.name COLLATE LATIN1_General_CI_AS + ' WITH FULLSCAN' as [Comando fullscan],
    'UPDATE STATISTICS ' + obj.name COLLATE LATIN1_General_CI_AS + ' WITH SAMPLE 35 PERCENT'  as [Comando sample 35%]
--- bases grandes
FROM sys.objects AS obj
    INNER JOIN sys.stats AS stat ON stat.object_id = obj.object_id
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
WHERE       obj.is_ms_shipped = 0
    AND (rows_sampled* 100 / [rows]) < 70
--and obj.name = 'nome_da_tabela' -- Nome da tabela especifica
ORDER BY    modification_counter DESC
