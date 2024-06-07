DECLARE @LOGIN varchar(MAX)
SET @LOGIN ='TESTE'
DECLARE @DB_Name varchar(100)
DECLARE @Command nvarchar(200)
DECLARE database_cursor CURSOR FOR
SELECT name
FROM MASTER.sys.sysdatabases
where dbid > 4
OPEN database_cursor
FETCH NEXT FROM database_cursor INTO @DB_Name
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @Command = 'USE ' + '['+@DB_Name+']' + ' CREATE USER ' + @LOGIN + ' FOR LOGIN '  + @LOGIN + ' ALTER ROLE [db_datareader] ADD MEMBER '  + @LOGIN + ' ALTER ROLE [db_datawriter] ADD MEMBER '  + @LOGIN + ' ALTER ROLE [db_ddladmin] ADD MEMBER '  + @LOGIN
    EXEC sp_executesql @Command
    FETCH NEXT FROM database_cursor INTO @DB_Name
END
CLOSE database_cursor
DEALLOCATE database_cursor

---

DECLARE @LOGIN nvarchar(MAX)
SET @LOGIN ='[dominio\nome_login]'
DECLARE @DB_Name varchar(100)
DECLARE @Command nvarchar(MAX)
DECLARE database_cursor CURSOR FOR
SELECT name
FROM MASTER.sys.sysdatabases
where dbid > 4
ALTER SERVER ROLE [sysadmin] DROP MEMBER [dominio\nome_login] -- informe o nome do usuario
OPEN database_cursor
FETCH NEXT FROM database_cursor INTO @DB_Name
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @Command = 'USE ' + '['+@DB_Name+']' + ' CREATE USER ' + @LOGIN + ' FOR LOGIN '  + @LOGIN + ' ALTER ROLE [db_datareader] ADD MEMBER '  + @LOGIN + ' ALTER ROLE [db_datawriter] ADD MEMBER '  + @LOGIN + ' ALTER ROLE [db_ddladmin] ADD MEMBER '  + @LOGIN
    EXEC sp_executesql @Command
    FETCH NEXT FROM database_cursor INTO @DB_Name
END
CLOSE database_cursor
DEALLOCATE database_cursor



