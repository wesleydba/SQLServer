SELECT name AS FileLogicalName, physical_name AS FileLocation
FROM sys.master_files
WHERE database_id = DB_ID(N'Nome_database')