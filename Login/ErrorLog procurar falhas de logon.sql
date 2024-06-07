DECLARE @start DATETIME = DATEADD(HOUR, -24 ,GETDATE())
DECLARE @end   DATETIME = GETDATE()
EXEC master.dbo.xp_readerrorlog 0, 1, N'Password did not match that for the login provided', null, @start, @end