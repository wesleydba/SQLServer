/*O script abaixo verifica quais as bases foram restauradas nos últimos 30 dias, mas pode-se alterar para trazer as bases restauradas em qualquer período de tempo:
Fonte: https://adjuniordba.wordpress.com/page/3/ */


DECLARE @dbname sysname = NULL
        , @days int = -30

SELECT rsh.destination_database_name AS [Database]
, rsh.user_name AS [Restored By]
, CASE WHEN rsh.restore_type = 'D' THEN 'Database'
      WHEN rsh.restore_type = 'F' THEN 'File'
      WHEN rsh.restore_type = 'G' THEN 'Filegroup'
      WHEN rsh.restore_type = 'I' THEN 'Differential'
      WHEN rsh.restore_type = 'L' THEN 'Log'
      WHEN rsh.restore_type = 'V' THEN 'Verifyonly'
      WHEN rsh.restore_type = 'R' THEN 'Revert'
    ELSE rsh.restore_type
  END AS [Restore Type]
, rsh.restore_date AS [Restore Started]
, bmf.physical_device_name AS [Restored From]
, rf.destination_phys_name AS [Restored To]
FROM msdb.dbo.restorehistory rsh
    INNER JOIN msdb.dbo.backupset bs ON rsh.backup_set_id = bs.backup_set_id
    INNER JOIN msdb.dbo.restorefile rf ON rsh.restore_history_id = rf.restore_history_id
    INNER JOIN msdb.dbo.backupmediafamily bmf ON bmf.media_set_id = bs.media_set_id
WHERE rsh.restore_date >= DATEADD(dd, @days, GETDATE())
    AND destination_database_name = ISNULL(@dbname, destination_database_name)
ORDER BY rsh.restore_history_id DESC