use tempdb
DBCC FREEPROCCACHE
GO
DBCC DROPCLEANBUFFERS
go
DBCC FREESYSTEMCACHE ('ALL')
GO
DBCC FREESESSIONCACHE
GO
dbcc shrinkfile (temp4, 1000) -- trocar o nome do arquivo do tempdb que deseja
GO