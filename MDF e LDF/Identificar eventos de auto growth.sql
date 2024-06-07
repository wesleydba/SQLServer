/* Utilizando o default trace, conseguimos identificar a ocorrência de eventos de autogrowth na instância, isto é, quando o SQL Server alocou dinamicamente mais espaço nos arquivos à medida que isso foi necessário para alocar novos dados. */

DECLARE
    @Ds_Arquivo_Trace VARCHAR(500) = (SELECT [path]
FROM sys.traces
WHERE is_default = 1)

DECLARE
    @Index INT = PATINDEX('%\%', REVERSE(@Ds_Arquivo_Trace))

DECLARE
    @Nm_Arquivo_Trace VARCHAR(500) = LEFT(@Ds_Arquivo_Trace, LEN(@Ds_Arquivo_Trace) - @Index) + '\log.trc'


SELECT
    A.DatabaseName,
    A.[Filename],
    ( A.Duration / 1000 ) AS 'Duration_ms',
    A.StartTime,
    A.EndTime,
    ( A.IntegerData * 8.0 / 1024 ) AS 'GrowthSize_MB',
    A.ApplicationName,
    A.HostName,
    A.LoginName
FROM
    ::fn_trace_gettable(@Nm_Arquivo_Trace, DEFAULT) A
WHERE
    A.EventClass >= 92
    AND A.EventClass <= 95
    AND A.ServerName = @@servername
ORDER BY
    A.StartTime DESC



---
--- https://www.sqlshack.com/get-details-of-sql-server-database-growth-and-shrink-events/
DECLARE @current_tracefilename VARCHAR(500);
DECLARE @0_tracefilename VARCHAR(500);
DECLARE @indx INT;
SELECT @current_tracefilename = path
FROM sys.traces
WHERE is_default = 1;
SET @current_tracefilename = REVERSE(@current_tracefilename);
SELECT @indx = PATINDEX('%\%', @current_tracefilename);
SET @current_tracefilename = REVERSE(@current_tracefilename);
SET @0_tracefilename = LEFT(@current_tracefilename, LEN(@current_tracefilename) - @indx) + '\log.trc';
SELECT DatabaseName,
    te.name,
    Filename,
    CONVERT(DECIMAL(10, 3), Duration / 1000000e0) AS TimeTakenSeconds,
    StartTime,
    EndTime,
    (IntegerData * 8.0 / 1024) AS 'ChangeInSize MB',
    ApplicationName,
    HostName,
    LoginName
FROM ::fn_trace_gettable(@0_tracefilename, DEFAULT) t
    INNER JOIN sys.trace_events AS te ON t.EventClass = te.trace_event_id
WHERE(trace_event_id >= 92
    AND trace_event_id <= 95)
ORDER BY 4 desc --t.StartTime;