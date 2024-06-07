select
    local_physical_seeding_id,
    remote_physical_seeding_id,
    local_database_name,
    @@servername as local_machine_name,
    remote_machine_name,
    role_desc as [role],
    transfer_rate_bytes_per_second,
    transferred_size_bytes / 1024 as transferred_size_KB,
    database_size_bytes / 1024 as database_size_KB,
    DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), start_time_utc) as start_time,
    DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), estimate_time_complete_utc) as estimate_time_complete,
    total_disk_io_wait_time_ms,
    total_network_wait_time_ms,
    is_compression_enabled
from sys.dm_hadr_physical_seeding_stats

-- Fonte: https://www.dbi-services.com/blog/sql-server-2016-alwayson-new-way-to-add-dbs-in-ag-with-direct-seeding/