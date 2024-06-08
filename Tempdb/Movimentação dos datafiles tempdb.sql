DECLARE @DIR VARCHAR(MAX)
/*Informe o novo diretório na variavel @DIR , lembrando que deve conter a barra final*/
/*Segue um exemplo da variavel basta trocar para o que vc deseja */
set @DIR  = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\'
SELECT 'ALTER DATABASE tempdb MODIFY FILE (NAME = [' + f.name + '],'
       + ' FILENAME =  ''' +@DIR + f.name
       + CASE WHEN f.type = 1 THEN '.ldf' ELSE '.mdf' END
       + ''');'
FROM sys.master_files f
WHERE f.database_id = DB_ID(N'tempdb');