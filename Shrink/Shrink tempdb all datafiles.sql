DECLARE @TheBigShrink NVARCHAR(MAX)
DBCC FREEPROCCACHE
-- clean cache
DBCC DROPCLEANBUFFERS
-- clean buffers
DBCC FREESYSTEMCACHE ('ALL')
-- clean system cache
DBCC FREESESSIONCACHE
-- clean session cache
DBCC SHRINKDATABASE(tempdb, 10);
-- shrink tempdb
SELECT @TheBigShrink = @TheBigShrink + ' USE ['' + DB_NAME(dbid) + '']
                                        DBCC SHRINKFILE (N'' + name + '', 1)
                            '
FROM master.dbo.sysaltfiles
where filename like '%TEMP%'
EXEC (@TheBigShrink) -- uncomment this line when happy with the output.
                            go
USE [tempdb]
                            GO
DECLARE @TheBigShrink2 NVARCHAR(MAX)
SELECT @TheBigShrink2 = @TheBigShrink2 + ' USE ['' + DB_NAME(dbid) + '']
                                        DBCC SHRINKFILE (N'' + name + '', 0, TRUNCATEONLY)
                            '
FROM master.dbo.sysaltfiles
where name like '%temp%'
EXEC (@TheBigShrink2) -- uncomment this line when happy with the output.