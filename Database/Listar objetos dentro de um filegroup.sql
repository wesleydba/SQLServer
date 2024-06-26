SELECT o.name AS table_name
       , p.index_id
       , i.name AS index_name
       , au.type_desc AS allocation_type
       , FG.name
       , au.data_pages
       , partition_number
FROM sys.allocation_units AS au
    JOIN sys.partitions AS p ON au.container_id = p.partition_id
    JOIN sys.objects AS o ON p.object_id = o.object_id
    JOIN sys.indexes AS i ON p.index_id = i.index_id
        AND i.object_id = p.object_id
    JOIN sys.filegroups FG ON au.data_space_id = FG.data_space_id
where FG.name LIKE '%AUDIT%' -- informe o nome do filegroup
ORDER BY o.name
       ,p.index_id;


