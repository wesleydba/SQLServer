DECLARE @databaseName NVARCHAR(128);
DECLARE @sql NVARCHAR(MAX);
DECLARE db_cursor CURSOR FOR
SELECT [name]
FROM sys.databases
WHERE [is_read_only] = 1;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @databaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'ALTER DATABASE [' + @databaseName + '] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [' + @databaseName + '];';
    EXEC sp_executesql @sql;
    FETCH NEXT FROM db_cursor INTO @databaseName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;