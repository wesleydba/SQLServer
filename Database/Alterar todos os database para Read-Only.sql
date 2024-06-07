DECLARE @databaseName NVARCHAR(128);
DECLARE @sql NVARCHAR(MAX);
DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE [is_read_only] = 0 and name not like  '%CloudControle%' and database_id > 4

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @databaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'ALTER DATABASE [' + @databaseName + '] SET  READ_ONLY WITH NO_WAIT ' + ' ALTER DATABASE [' + @databaseName + '] SET RECOVERY SIMPLE WITH NO_WAIT';
    EXEC sp_executesql @sql;
    FETCH NEXT FROM db_cursor INTO @databaseName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;