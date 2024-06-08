if exists (select 1
from tempdb.sys.tables
where name like '%##tabela%')
       drop table ##tabela
go
create table ##tabela
(
    DatabaseName sysname,
    SchemaName sysname,
    TableName sysname,
    IndexName sysname null,
    IndexType tinyint
)
if DB_ID() > 4 and DATABASEPROPERTYEX(DB_NAME(), 'status') = 'ONLINE' and DATABASEPROPERTYEX(DB_NAME(), 'updateability') = 'READ_WRITE'
       insert into ##tabela
    (DatabaseName, SchemaName, TableName, IndexName, IndexType)
select distinct
    DB_NAME() DBName,
    sc.name SchemaName,
    st.name TableName,
    si.name IndexName,
    si.type IndexType
from sys.tables st
    inner join sys.schemas sc on sc.schema_id = st.schema_id
    inner join sys.indexes si on si.object_id = st.object_id
order by IndexType

declare @cmdSQL varchar(max) = ''
declare @dbname sysname, @schemaname sysname, @tablename sysname, @indexname sysname, @indextype tinyint
declare cr_looping cursor keyset for
select DatabaseName, SchemaName, TableName, IndexName, IndexType
from ##tabela
order by IndexType asc
open cr_looping
fetch first from cr_looping into @dbname, @schemaname, @tablename, @indexname, @indextype
while @@FETCH_STATUS = 0
 begin
    begin try
              
              if @indextype = 0
                     set @cmdSQL = 'alter table [' + @dbname + '].[' + @schemaname + '].[' + @tablename + '] rebuild with (data_compression = PAGE)'
              else if @indextype in (1, 2)
                     set @cmdSQL = 'alter index [' + @indexname + '] on [' + @dbname + '].[' + @schemaname + '].[' + @tablename + '] rebuild with (data_compression = PAGE, fillfactor = 80)'
              
              execute (@cmdSQL)
       end try
       begin catch
              print @cmdSQL
              print ERROR_MESSAGE()
       end catch
    fetch next from cr_looping into @dbname, @schemaname, @tablename, @indexname, @indextype
end
close cr_looping
deallocate cr_looping
go
DECLARE @tableName varchar(80),@shemaname varchar(80)
DECLARE @SQL AS NVARCHAR(200)
DECLARE TblName_cursor CURSOR FOR
SELECT t.name, s.name
FROM sys.tables t join sys.schemas s
    on s.schema_id=t.schema_id
OPEN TblName_cursor
FETCH NEXT FROM TblName_cursor
INTO @tableName,@shemaname
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 'UPDATE STATISTICS '+@shemaname+'.[' + @tableName + '] WITH FULLSCAN '
    PRINT @SQL
    EXEC sp_executesql @statement = @SQL
    FETCH NEXT FROM TblName_cursor
   INTO @tableName,@shemaname
END
CLOSE TblName_cursor
DEALLOCATE TblName_cursor