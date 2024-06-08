/*O scritp e para ser executado via registerd server*/
--SET NOCOUNT OFF
DECLARE @shrinklog varchar(max) = '';
SELECT @shrinklog = @shrinklog +
    + ':Connect ' + @@SERVERNAME  
       + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
       + ' USE [' + d.name + N']' + CHAR(13) + CHAR(10) + 'DBCC SHRINKFILE (N''' + mf.name + N''' , 0, TRUNCATEONLY)'
       + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
       + ' GO'
    + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
FROM
         sys.master_files mf
    JOIN sys.databases d
        ON mf.database_id = d.database_id
WHERE d.database_id > 4 and mf.type_desc = 'LOG' AND d.state_desc='ONLINE';
print @shrinklog