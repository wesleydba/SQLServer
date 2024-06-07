
/*Besides monitoring server’s free disk space you also need to take note of how much free memory is available on your server. If the amount of free memory is approaching some critical value you need to take steps to free it.

To check your server’s memory with SQL you can use the following syntax:*/

SELECT available_physical_memory_kb/1024 as "Total Memory MB",
available_physical_memory_kb/(total_physical_memory_kb*1.0)*100 AS "% Memory Free"
FROM sys.dm_os_sys_memory

/*fonte:  https://sqlbak.com/blog/sql-server-health-check-checklist*/