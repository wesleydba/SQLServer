DECLARE @start DATETIME = DATEADD(HOUR, -2 ,GETDATE())
DECLARE @end   DATETIME = GETDATE()
EXEC master.dbo.xp_readerrorlog 0, 1, N'is full due to', null, @start, @end


DECLARE @start DATETIME = DATEADD(HOUR, -2 ,GETDATE())
DECLARE @end   DATETIME = GETDATE()
EXEC master.dbo.xp_readerrorlog 0, 1, N'Login failed for user', null, @start, @end