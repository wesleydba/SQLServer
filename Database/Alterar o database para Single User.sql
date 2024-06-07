-- Observar as 3 últimas linhas

USE master
GO
DECLARE @kill varchar(max) = '';
SELECT @kill = @kill + 'KILL ' + CONVERT(varchar(10), spid) + '; '
FROM master..sysprocesses
WHERE spid > 50 AND dbid = DB_ID('VETORH')
EXEC(@kill);
 GO
SET DEADLOCK_PRIORITY HIGH
ALTER DATABASE [VETORH] SET SINGLE_USER WITH NO_WAIT
ALTER DATABASE [VETORH] SET MULTI_USER WITH ROLLBACK IMMEDIATE
--alter database VETORH set READ_COMMITTED_SNAPSHOT ON
GO