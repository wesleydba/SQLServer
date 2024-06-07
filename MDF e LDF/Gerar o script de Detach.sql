USE [master] ;
GO
DECLARE @database NVARCHAR( 200) ,
    @cmd NVARCHAR(1000 ) ,
    @detach_cmd NVARCHAR(4000 ) ,
    @attach_cmd NVARCHAR(4000 ) ,
    @file NVARCHAR(1000 ) ,
    @i INT ,
    @DetachOrAttach BIT;

-- 1 Gera o Script de Detach
-- 0 Gera o Script de Attach
SET @DetachOrAttach = 1
;

DECLARE dbname_cur CURSOR STATIC LOCAL FORWARD_ONLY
FOR
    SELECT RTRIM(LTRIM ([name]))
FROM sys.databases
WHERE   database_id not in (1,2,3,4,5,6);
-- No system databases e os database que estão no C:\ ReportServer ReportServer_log ,ReportServerTempDB ,ReportServerTempDB_log
OPEN dbname_cur

FETCH NEXT FROM dbname_cur INTO @database

WHILE @@FETCH_STATUS = 0
    BEGIN
    SELECT @i = 1
    ;

    SET @attach_cmd = '-- ' + QUOTENAME( @database) + CHAR (10)
            + 'EXEC sp_attach_db @dbname = ''' + @database + '''' + CHAR (10);
    SET @detach_cmd = '-- ' + QUOTENAME( @database) + CHAR (10)
            + 'EXEC sp_detach_db @dbname = ''' + @database
            + ''' , @skipchecks = ''true'';' + CHAR(10 );

    DECLARE dbfiles_cur CURSOR STATIC LOCAL FORWARD_ONLY
        FOR
            SELECT physical_name
    FROM sys .master_files
    WHERE   database_id = DB_ID(@database )
    ORDER BY [file_id];

    OPEN dbfiles_cur

    FETCH NEXT FROM dbfiles_cur INTO @file

    WHILE @@FETCH_STATUS = 0
            BEGIN
        SET @attach_cmd = @attach_cmd + '    ,@filename'
                    + CAST (@i AS NVARCHAR (10)) + ' = ''' + @file + ''''
                    + CHAR (10);
        SET @i = @i + 1;

        FETCH NEXT FROM dbfiles_cur INTO @file
    END

    CLOSE dbfiles_cur ;

    DEALLOCATE dbfiles_cur ;

    IF ( @DetachOrAttach = 0 )
            BEGIN
        PRINT @attach_cmd ;
    END
        ELSE
            PRINT @detach_cmd ;

    FETCH NEXT FROM dbname_cur INTO @database
END

CLOSE dbname_cur ;

DEALLOCATE dbname_cur ;



