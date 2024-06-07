-- =================================================================================================
-- Author:         Eli Leiba
-- Create date:    2018-09
-- Procedure Name: dbo.usp_DBSplitBackup
-- Description:
--           The procedure takes 5 parameters:
--            1. @dbName = Logical database name
--            2. @primaryDrive = primary drive in which the odd parts of backup are stored.
--            3. @secondaryDrive = secondary drive in which the even parts of the backup are stored.
--            4. @backupDir = backup directory to store all backup parts
--            5. @nParts = number of files for which to split the backup.
--          
--           The procedure splits the database backup files to the number of files
--           given each file is numbered and sized as equal as possible.
--           All the backup parts are stored in the Backup directory.

--#############################################################
-- Ajustado : WESLEY CARDOSO - 06/junho/2021 add os parametros de backup
-- https://www.mssqltips.com/sqlservertip/5668/sql-server-script-to-automatically-split-database-backups-into-multiple-backup-files/
-- =================================================================================================
use master;
go
drop procedure if exists dbo.usp_DBSplitBackup ;
go
CREATE PROCEDURE dbo.usp_DBSplitBackup (
   @dbName SYSNAME,
   @primaryDrive CHAR (1),
   @secondaryDrive CHAR (1),
   @backupDir NVARCHAR (200),
   @nParts TINYINT)
AS
BEGIN
   SET NOCOUNT ON
   DECLARE @backupTSQLCmd NVARCHAR (2000)
   DECLARE @idx TINYINT = 0
   SET @idx += 1
   SET @backupTSQLCmd = CONCAT ('BACKUP DATABASE ', '[',@dbName,'] TO ')
 
   WHILE @idx <= @nParts
   BEGIN
      SET @backupTSQLCmd += CONCAT (
            'DISK = ',
            '''',
            iif(@idx % 2 = 1, @primaryDrive, @secondaryDrive),
            ':\',
            @backupDir,
            '\',
            @dbName,
            '_',
            rtrim(ltrim(STR(@idx))),
            '.BAK',
            '''',
                     ', '
            )
      SET @idx += 1
   END
   SET @backupTSQLCmd = left (@backupTSQLCmd, len(@backupTSQLCmd) - 1) + ' WITH  COPY_ONLY, NOFORMAT, NOINIT,SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10'
   PRINT @backupTSQLCmd
   EXEC (@backupTSQLCmd)
   SET NOCOUNT OFF
END
GO

---

/* Exemplo para execução .: 
https://www.mssqltips.com/sqlservertip/5668/sql-server-script-to-automatically-split-database-backups-into-multiple-backup-files/
*/

use master
go
EXEC dbo.usp_DBSplitBackup
@dbName='Northwind',
@primaryDrive='C',
@secondaryDrive='C',
@backupDir='Datashare\SQLBackup',
@nParts=10
go
