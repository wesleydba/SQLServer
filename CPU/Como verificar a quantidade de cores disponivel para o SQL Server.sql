SELECT current_tasks_count, runnable_tasks_count, *
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255
    AND status = 'VISIBLE ONLINE'