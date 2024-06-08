/*Script abaixo ira gerar o comando para executar o shrink*/

SELECT
      'USE [' + d.name + N']' + CHAR(13) + CHAR(10)
    + 'DBCC SHRINKFILE (N''' + mf.name + N''' , 0, TRUNCATEONLY)'
    + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
FROM
         sys.master_files mf
    JOIN sys.databases d
        ON mf.database_id = d.database_id
WHERE d.database_id > 4 and mf.type_desc = 'LOG' AND d.state_desc='ONLINE';


/*Script abaixo irá executar o shrink de log*/

DECLARE @Script NVARCHAR(MAX) = ''

SELECT @Script = @Script + 'USE [' + d.name + N']' + CHAR(13) + CHAR(10)
    + 'DBCC SHRINKFILE (N''' + mf.name + N''' , 0, TRUNCATEONLY)'
    + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
FROM
    sys.master_files mf
    JOIN sys.databases d ON mf.database_id = d.database_id
WHERE
    d.database_id > 4 AND
    mf.type_desc = 'LOG' AND
    d.state_desc = 'ONLINE';

-- Exibir o script gerado
--PRINT @Script;

-- Executar o script gerado
EXECUTE sp_executesql @Script;