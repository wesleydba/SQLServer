EXECUTE sp_MSforeachdb 'USE ?
IF DB_NAME() NOT IN(''master'',''msdb'',''tempdb'',''model'',''ReportServer'')
SET DEADLOCK_PRIORITY -10;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT ''sqlserver_orphaned_users'' AS [measurement],
              @@SERVERNAME AS [server],
              dp.type_desc,
              dp.SID as [sid],
              dp.name AS [username],
              CASE WHEN sp.sid IS NOT NULL THEN 0 ELSE 1 END AS is_orphaned,DB_NAME()
FROM sys.database_principals AS dp
LEFT JOIN sys.server_principals AS sp
       ON dp.SID = sp.SID
WHERE authentication_type_desc = ''INSTANCE'' AND dp.type_desc=''SQL_USER'';'