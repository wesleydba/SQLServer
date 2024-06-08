--Validar Collation de todas as colunas de todas as tabelas do banco de dados
SELECT t.name TableName, c.name ColumnName, collation_name  
FROM sys.columns c  
inner join sys.tables t on c.object_id = t.object_id
where collation_name <> 'Latin1_General_BIN';