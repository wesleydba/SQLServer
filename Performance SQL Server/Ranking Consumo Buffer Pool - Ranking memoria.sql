-- RANKING CONSUMO BUFFER POOL / RANKING MEMORIA
--lista consumo de buffer poool
WITH
    AggregateBufferPoolUsage
    AS
    (
        SELECT DB_NAME(database_id) AS [Database Name],
            CAST(COUNT(*) * 8/1024.0 AS DECIMAL (10,2))  AS [CachedSize]
        FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
        WHERE database_id <> 32767
        -- ResourceDB
        GROUP BY DB_NAME(database_id)
    )
SELECT ROW_NUMBER() OVER(ORDER BY CachedSize DESC) AS [Buffer Pool Rank], [Database Name], CachedSize AS [Cached Size (MB)],
    CAST(CachedSize / SUM(CachedSize) OVER() * 100.0 AS DECIMAL(5,2)) AS [Buffer Pool Percent]
FROM AggregateBufferPoolUsage
ORDER BY [Buffer Pool Rank]
OPTION
(RECOMPILE);


---

-- RANKING CONSUMO BUFFER POOL / RANKING MEMORIA
--lista consumo de buffer poool
WITH
    AggregateBufferPoolUsage
    AS
    (
        SELECT DB_NAME(database_id) AS [Database Name],
            CAST(COUNT(*) * 8/1024.0 AS DECIMAL (10,2))  AS [CachedSize]
        FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
        WHERE database_id <> 32767
        -- ResourceDB
        GROUP BY DB_NAME(database_id)
    ),
    sizedb
    as
    (
        SELECT d.NAME
    , ROUND(SUM(CAST(mf.size AS bigint)) * 8 / 1024, 0) Size_MBs
    , (SUM(CAST(mf.size AS bigint)) * 8 / 1024) / 1024 AS Size_GBs
        FROM sys.master_files mf
            INNER JOIN sys.databases d ON d.database_id = mf.database_id
        GROUP BY d.NAME
    )
SELECT ROW_NUMBER() OVER(ORDER BY CachedSize DESC) AS [Buffer Pool Rank], [Database Name], CachedSize AS [Cached Size (MB)],
    CAST(CachedSize / SUM(CachedSize) OVER() * 100.0 AS DECIMAL(5,2)) AS [Buffer Pool Percent], Size_MBs , Size_GBs
FROM AggregateBufferPoolUsage
    inner join sizedb on sizedb.NAME = AggregateBufferPoolUsage.[Database Name]
ORDER BY [Buffer Pool Rank]
OPTION
(RECOMPILE);