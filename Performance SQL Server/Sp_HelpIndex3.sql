DECLARE @Nm_Schema VARCHAR(100) = 'dbo',
              @Nm_Tabela VARCHAR(200) = 'CTT010'
-- nome tabela
DECLARE @Nm_Parametro VARCHAR(300) = '' + @Nm_Schema + '.' + @Nm_Tabela + ''
IF(OBJECT_ID('tempdb..#Temp_Helpindex') IS NOT NULL) DROP TABLE #Temp_Helpindex
CREATE TABLE #Temp_Helpindex
(
    index_name VARCHAR(MAX),
    index_description VARCHAR(MAX),
    index_keys VARCHAR(MAX)
)
INSERT INTO #Temp_Helpindex
    (index_name, index_description, index_keys)
EXEC sp_helpindex @Nm_Parametro
IF(OBJECT_ID('tempdb..#Temp_Include') IS NOT NULL) DROP TABLE #Temp_Include
select SCHEMA_NAME (o.SCHEMA_ID) SchemaName
  , o.name ObjectName, i.name IndexName
  , i.type_desc
  , LEFT(list, ISNULL(splitter-1,len(list))) Columns
  , SUBSTRING(list, indCol.splitter+1, 1000) includedColumns--len(name) - splitter-1) columns
  , COUNT(1)over (partition by o.object_id) qtd
into #Temp_Include
from sys.indexes i
    join sys.objects o on i.object_id= o.object_id
cross apply (select NULLIF(charindex('|',indexCols.list),0) splitter , list
    from (select cast((
                          select case when sc.is_included_column = 1 and sc.ColPos= 1 then'|'else '' end +
                                 case when sc.ColPos > 1 then ', ' else ''end + name
            from (select sc.is_included_column, index_column_id, name
                                       , ROW_NUMBER()over (partition by sc.is_included_column
                                                            order by sc.index_column_id)ColPos
                from sys.index_columns  sc
                    join sys.columns        c on sc.object_id= c.object_id
                        and sc.column_id = c.column_id
                where sc.index_id= i.index_id
                    and sc.object_id= i.object_id) sc
            order by sc.is_included_column
                           ,ColPos
            for xml path (''),type) as varchar(max)) list)indexCols) indCol
where indCol.splitter is not null
    and SCHEMA_NAME (o.SCHEMA_ID) = @Nm_Schema
    and o.name = @Nm_Tabela
order by 5
IF(OBJECT_ID('tempdb..#Temp_Utilizacao') IS NOT NULL) DROP TABLE #Temp_Utilizacao
select o.name, i.name Nm_Indice, SCHEMA_NAME(schema_id) Nm_Schema, s.user_seeks, s.user_scans, s.user_lookups, s.user_Updates,
    isnull(s.last_user_seek,isnull(s.last_user_scan,s.last_User_Lookup)) Ultimo_acesso, fill_factor
into #Temp_Utilizacao
from sys.dm_db_index_usage_stats s
    join sys.indexes i on i.object_id = s.object_id and i.index_id = s.index_id
    join sys.sysobjects o on i.object_id = o.id
    join sys.tables t on o.id = t.object_id
where s.database_id = db_id()
    and SCHEMA_NAME(schema_id) = @Nm_Schema
    and o.name = @Nm_Tabela
order by s.user_seeks desc--o.Name, SCHEMA_NAME(schema_id), i.name
IF(OBJECT_ID('tempdb..#Temp_TamanhoIndices') IS NOT NULL) DROP TABLE #Temp_TamanhoIndices
SELECT i.[name] AS IndexName
    , SUM(s.[used_page_count]) * 8 AS IndexSizeKB
into #Temp_TamanhoIndices
FROM sys.dm_db_partition_stats AS s
    INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
        AND s.[index_id] = i.[index_id]
    join sysobjects o ON i.[object_id] = o .id
where o.name = @Nm_Tabela
GROUP BY i.[name]
ORDER BY 2 desc
IF(OBJECT_ID('tempdb..#Temp_Compression') IS NOT NULL) DROP TABLE #Temp_Compression
select i.name, data_compression_desc
into #Temp_Compression
FROM [sys].[partitions] AS [p]
    INNER JOIN sys.tables AS [t]
    ON [t].[object_id] = [p].[object_id]
    INNER JOIN sys.indexes AS [i]
    ON [i].[object_id] = [p].[object_id] AND i.index_id = p.index_id
    INNER JOIN sys.schemas AS [s]
    ON [t].[schema_id] = [s].[schema_id]
where t.name = @Nm_Tabela
select B.index_name, B.index_description, B.index_keys, C.includedColumns, A.user_seeks, A.user_scans, A.user_Updates, A.Ultimo_acesso, A.fill_factor, D.IndexSizeKB
from #Temp_Helpindex B
    left join #Temp_Include C on B.index_name = C.IndexName collate Latin1_General_BIN
    left join #Temp_Utilizacao A on  B.index_name = A.Nm_Indice  collate Latin1_General_BIN
    left join #Temp_TamanhoIndices D on B.index_name = D.IndexName collate Latin1_General_BIN
    left join #Temp_Compression E on B.index_name = E.name
where B.index_description <> 'nonclustered, hypothetical'
order by B.index_keys,A.user_seeks desc