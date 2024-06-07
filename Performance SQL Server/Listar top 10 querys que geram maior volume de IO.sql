SELECT TOP 10
    (total_logical_reads/execution_count) AS [Média de leituras lógicas],
    (total_logical_writes/execution_count) AS [Média de escritas lógicas],
    (total_physical_reads/execution_count) AS [Média de leituras físicas],
    execution_count,
    plan_handle,
    (SELECT SUBSTRING(text, statement_start_offset/2 + 1,
(CASE WHEN statement_end_offset = -1
THEN LEN(CONVERT(nvarchar(MAX),text)) * 2
ELSE statement_end_offset
END - statement_start_offset)/2)
    FROM sys.dm_exec_sql_text(sql_handle)) AS [Texto da query]
FROM sys.dm_exec_query_stats
ORDER BY (total_logical_reads + total_logical_writes) DESC;