SET NOCOUNT ON
GO
DECLARE updatestats CURSOR FOR
SELECT table_name
FROM information_schema.tables
where TABLE_TYPE = 'BASE TABLE'
OPEN updatestats
DECLARE @tablename NVARCHAR(128)
DECLARE @Statement NVARCHAR(300)
FETCH NEXT FROM updatestats INTO @tablename
WHILE (@@FETCH_STATUS = 0)
BEGIN
    PRINT N'UPDATING STATISTICS ' + @tablename
    SET @Statement = 'UPDATE STATISTICS '  + @tablename + '  WITH FULLSCAN'
    EXEC sp_executesql @Statement
    FETCH NEXT FROM updatestats INTO @tablename
END
CLOSE updatestats
DEALLOCATE updatestats
GO
SET NOCOUNT OFF
GO