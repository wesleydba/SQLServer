--Retirada dos jobs antigos
USE [msdb];
IF EXISTS
    (
        SELECT
            job_id
        FROM
            msdb.dbo.sysjobs_view
        WHERE
            name = N'TOTVS | DBA Cloud - Index Maintenance'
    )
    EXEC sp_delete_job
        @job_name = N'TOTVS | DBA Cloud - Index Maintenance',
        @delete_unused_schedule = 1;
GO
IF EXISTS
    (
        SELECT
            job_id
        FROM
            msdb.dbo.sysjobs_view
        WHERE
            name = N'TOTVS | DBA Cloud - Load Index Fragmentation'
    )
    EXEC sp_delete_job
        @job_name = N'TOTVS | DBA Cloud - Load Index Fragmentation',
        @delete_unused_schedule = 1;
GO
IF EXISTS
    (
        SELECT
            job_id
        FROM
            msdb.dbo.sysjobs_view
        WHERE
            name = N'TOTVS | DBA Cloud - Update Statistics'
    )
    EXEC sp_delete_job
        @job_name = N'TOTVS | DBA Cloud - Update Statistics',
        @delete_unused_schedule = 1;
GO
IF EXISTS
    (
        SELECT
            job_id
        FROM
            msdb.dbo.sysjobs_view
        WHERE
            name = N'Totvs | DBA Cloud - Database Rebuild All Indexes'
    )
    EXEC sp_delete_job
        @job_name = N'Totvs | DBA Cloud - Database Rebuild All Indexes',
        @delete_unused_schedule = 1;
GO
IF EXISTS
    (
        SELECT
            job_id
        FROM
            msdb.dbo.sysjobs_view
        WHERE
            name = N'DBACLOUD_Rebuild_AllDatabases'
    )
    EXEC sp_delete_job
        @job_name = N'DBACLOUD_Rebuild_AllDatabases',
        @delete_unused_schedule = 1;
GO

IF EXISTS
    (
        SELECT
            job_id
        FROM
            msdb.dbo.sysjobs_view
        WHERE
            name = N'Totvs | Stop DBA Cloud - Maintenance'
    )
    EXEC sp_delete_job
        @job_name = N'Totvs | Stop DBA Cloud - Maintenance',
        @delete_unused_schedule = 1;
GO



--Retirada procedures versão antiga: serão criadas novamente durante a execução do job
USE [master];
GO
IF EXISTS
    (
        SELECT
            *
        FROM
            sys.objects
        WHERE
            type = 'P'
            AND name = 'usp_Totvs_DBACloud_RebuildIndexes2'
    )
    DROP PROCEDURE [dbo].[usp_Totvs_DBACloud_RebuildIndexes2];
GO

USE [master];
GO
IF EXISTS
    (
        SELECT
            *
        FROM
            sys.objects
        WHERE
            type = 'P'
            AND name = 'usp_Totvs_DBACloud_UpdateStatistics2'
    )
    DROP PROCEDURE [dbo].[usp_Totvs_DBACloud_UpdateStatistics2];
GO

USE [master];
IF NOT EXISTS
    (
        SELECT
            name,
            *
        FROM
            sys.databases
        WHERE
            name = '_DBACloudControle'
    )
    BEGIN

        CREATE DATABASE _DBACloudControle;

    END;

GO

--Criação Tabela Log Rebuild Index
USE [_DBACloudControle];
IF NOT EXISTS
    (
        SELECT
            *
        FROM
            sys.objects
        WHERE
            object_id = OBJECT_ID(N'[dbo].[tblLogRebuildIndex]')
            AND type IN (
                            N'U'
                        )
    )
    BEGIN

        USE [_DBACloudControle];
        CREATE TABLE [dbo].[tblLogRebuildIndex]
            (
                [id]                   [INT]            IDENTITY(1, 1) NOT NULL,
                [DBName]               [sysname]        NOT NULL,
                [SchemaName]           [sysname]        NOT NULL,
                [ObjectName]           [sysname]        NOT NULL,
                [IndexName]            [sysname]        NULL,
                [FragmentationPercent] [DECIMAL](18, 2) NOT NULL,
                [IndexSizeMB]          [DECIMAL](18, 2) NULL,
                [LastAccess]           [DATETIME]       NULL,
                [TSQLCommand]          [VARCHAR](MAX)   NULL,
                [StartTime]            [DATETIME]       NOT NULL
                    DEFAULT (GETDATE()),
                [EndTime]              [DATETIME]       NULL,
                PRIMARY KEY CLUSTERED ([id] ASC)
                WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
                      ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80
                     ) ON [PRIMARY]
            ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];


    END;

--Criação Tabela Log Erro Rebuild Index
USE [_DBACloudControle];
IF NOT EXISTS
    (
        SELECT
            *
        FROM
            sys.objects
        WHERE
            object_id = OBJECT_ID(N'[dbo].[tblLogErroRebuildIndex]')
            AND type IN (
                            N'U'
                        )
    )
    BEGIN

        USE [_DBACloudControle];
        CREATE TABLE [dbo].[tblLogErroRebuildIndex]
            (
                [id]      [INT]          NOT NULL,
                [MsgErro] [VARCHAR](MAX) NULL,
                PRIMARY KEY CLUSTERED ([id] ASC)
                WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
                      ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80
                     ) ON [PRIMARY]
            ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];


        ALTER TABLE [dbo].[tblLogErroRebuildIndex] WITH CHECK
        ADD
            CONSTRAINT [FK_tblLogErroRebuildIndex_tblLogRebuildIndex]
            FOREIGN KEY ([id])
            REFERENCES [dbo].[tblLogRebuildIndex] ([id]);

        ALTER TABLE [dbo].[tblLogErroRebuildIndex] CHECK CONSTRAINT [FK_tblLogErroRebuildIndex_tblLogRebuildIndex];

    END;



USE [_DBACloudControle];
IF NOT EXISTS
    (
        SELECT
            *
        FROM
            sys.objects
        WHERE
            object_id = OBJECT_ID(N'[dbo].[ListaExclusaoRebuild]')
            AND type IN (
                            N'U'
                        )
    )
    BEGIN

        USE [_DBACloudControle];

        CREATE TABLE [dbo].[ListaExclusaoRebuild]
            (
                [IdListaExclusaoRebuild] [INT]      IDENTITY(1, 1) NOT NULL,
                [NomeTabela]             [sysname]  NOT NULL,
                [DataInicio]             [DATETIME] NULL,
                [DataFim]                [DATETIME] NULL,
                PRIMARY KEY CLUSTERED ([IdListaExclusaoRebuild] ASC)
                WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
                      ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80
                     ) ON [PRIMARY]
            ) ON [PRIMARY];

    END;

USE [_DBACloudControle];
GO

/****** Object:  Table [dbo].[idx_rebuild]    Script Date: 23/08/2024 18:28:04 ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO


IF NOT EXISTS
    (
        SELECT
            *
        FROM
            sys.objects
        WHERE
            object_id = OBJECT_ID(N'[dbo].[idx_rebuild]')
            AND type IN (
                            N'U'
                        )
    )
    BEGIN


        CREATE TABLE [dbo].[idx_rebuild]
            (
                [Dt_Log]               [DATETIME]       NULL
                    DEFAULT (GETDATE()),
                [Usage]                [BIGINT]         NULL,
                [DatabaseName]         [sysname]        NOT NULL,
                [ObjectName]           [sysname]        NOT NULL,
                [IndexName]            [sysname]        NULL,
                [SchemaName]           [sysname]        NOT NULL,
                [FragmentationPercent] [DECIMAL](18, 2) NULL,
                [IndexType]            [VARCHAR](255)   NULL,
                [AllocationUnitType]   [VARCHAR](255)   NULL,
                [IndexSizeMB]          [DECIMAL](18, 2) NULL,
                [LastAccess]           [DATETIME]       NULL
            ) ON [PRIMARY];
    END;



USE [_DBACloudControle];
GO
IF NOT EXISTS
    (
        SELECT
            *
        FROM
            sys.objects
        WHERE
            object_id = OBJECT_ID(N'[dbo].[LogSpaceUsage]')
            AND type IN (
                            N'U'
                        )
    )
    BEGIN

        USE [_DBACloudControle];


        CREATE TABLE [dbo].[LogSpaceUsage]
            (
                [DatabaseName]        [NVARCHAR](128) NULL,
                [TotalLogSizeMB]      [FLOAT]         NULL,
                [UsedLogSpaceMB]      [FLOAT]         NULL,
                [FreeLogSpaceMB]      [FLOAT]         NULL,
                [UsedLogSpacePercent] [FLOAT]         NULL,
                [FreeSpaceMB]         [FLOAT]         NULL
            ) ON [PRIMARY];
    END;



/****** Object:  Table [dbo].[tblLogUpdateStatistics]    Script Date: 23/08/2024 18:28:04 ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO


IF NOT EXISTS
    (
        SELECT
            *
        FROM
            sys.objects
        WHERE
            object_id = OBJECT_ID(N'[dbo].[tblLogUpdateStatistics]')
            AND type IN (
                            N'U'
                        )
    )
    BEGIN
        CREATE TABLE [dbo].[tblLogUpdateStatistics]
            (
                [Id]                  [INT]          IDENTITY(1, 1) NOT NULL,
                [DBName]              [sysname]      NOT NULL,
                [SchemaName]          [sysname]      NOT NULL,
                [TableName]           [sysname]      NOT NULL,
                [StatsName]           [sysname]      NULL,
                [LastUpdated]         DATETIME       NULL,
                [Rows]                [BIGINT]          NULL,
                [ModificationCounter] [BIGINT]          NULL,
                [% Rows Sampled]      [INT]          NULL,
                [TSQLCommand]         [VARCHAR](MAX) NULL,
                [StartTime]           [DATETIME]     NOT NULL
                    DEFAULT (GETDATE()),
                [EndTime]             [DATETIME]     NULL,
                PRIMARY KEY CLUSTERED ([Id] ASC)
                WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
                      ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80
                     ) ON [PRIMARY]
            ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
    END;
ELSE
    BEGIN
        -- Verifica se a coluna 'StartTime' já possui o valor padrão GETDATE()
        IF NOT EXISTS
            (
                SELECT
                        *
                FROM
                        sys.default_constraints dc
                    INNER JOIN
                        sys.columns             c
                            ON dc.parent_object_id = c.object_id
                               AND dc.parent_column_id = c.column_id
                WHERE
                        c.object_id = OBJECT_ID(N'[dbo].[tblLogUpdateStatistics]')
                        AND c.name = 'StartTime'
                        AND dc.definition = '(GETDATE())'
            )
            BEGIN
                -- Remove o constraint de default existente (se houver) na coluna 'StartTime'
                DECLARE @ConstraintName NVARCHAR(128);
                SELECT
                        @ConstraintName = dc.name
                FROM
                        sys.default_constraints dc
                    INNER JOIN
                        sys.columns             c
                            ON dc.parent_object_id = c.object_id
                               AND dc.parent_column_id = c.column_id
                WHERE
                        c.object_id = OBJECT_ID(N'[dbo].[tblLogUpdateStatistics]')
                        AND c.name = 'StartTime';

                IF @ConstraintName IS NOT NULL
                    EXEC ('ALTER TABLE [dbo].[tblLogUpdateStatistics] DROP CONSTRAINT ' + @ConstraintName);

                -- Adiciona o novo default constraint com GETDATE()
                ALTER TABLE [dbo].[tblLogUpdateStatistics]
                ADD
                    DEFAULT (GETDATE()) FOR [StartTime];
            END;
    END;

USE [_DBACloudControle];
GO

ALTER TABLE tblLogRebuildIndex
ALTER COLUMN TSQLCommand VARCHAR(MAX) NULL;
GO


-------------------------------------------------------------------------------------------------------------------------------
/*exclui estrutura de job antigos*/
-------------------------------------------------------------------------------------------------------------------------------

USE [msdb];

IF EXISTS
    (
        SELECT
            job_id
        FROM
            msdb.dbo.sysjobs_view
        WHERE
            name = N'TOTVS | DBA Cloud - Load Index Fragmentation'
    )
    EXEC sp_delete_job
        @job_name = N'TOTVS | DBA Cloud - Load Index Fragmentation',
        @delete_unused_schedule = 1;
GO
IF EXISTS
    (
        SELECT
            job_id
        FROM
            msdb.dbo.sysjobs_view
        WHERE
            name = N'TOTVS | DBA Cloud - Update Statistics'
    )
    EXEC sp_delete_job
        @job_name = N'TOTVS | DBA Cloud - Update Statistics',
        @delete_unused_schedule = 1;
GO
IF EXISTS
    (
        SELECT
            job_id
        FROM
            msdb.dbo.sysjobs_view
        WHERE
            name = N'Totvs | DBA Cloud - Database Rebuild All Indexes'
    )
    EXEC sp_delete_job
        @job_name = N'Totvs | DBA Cloud - Database Rebuild All Indexes',
        @delete_unused_schedule = 1;
GO
IF EXISTS
    (
        SELECT
            job_id
        FROM
            msdb.dbo.sysjobs_view
        WHERE
            name = N'DBACLOUD_Rebuild_AllDatabases'
    )
    EXEC sp_delete_job
        @job_name = N'DBACLOUD_Rebuild_AllDatabases',
        @delete_unused_schedule = 1;
GO


-- Primeiro, defina o nome atual do job e o novo nome desejado
DECLARE @OldJobName NVARCHAR(128) = N'Totvs | DBA Cloud - Maintenance';
DECLARE @NewJobName NVARCHAR(128) = N'%%Totvs | DBA Cloud - Maintenance%%_OLD';
DECLARE @JobId UNIQUEIDENTIFIER;

-- Verifica se o job existe
SELECT
    @JobId = job_id
FROM
    msdb.dbo.sysjobs
WHERE
    name = @OldJobName;

-- Se o job existir, renomeia e desabilita
IF @JobId IS NOT NULL
    -- Altera o nome do job
    EXEC msdb.dbo.sp_update_job
        @job_name = @OldJobName,
        @new_name = @NewJobName;

-- Desabilita o job
EXEC msdb.dbo.sp_update_job
    @job_name = @NewJobName,
    @enabled = 0;

-- Confirmação de alteração
PRINT 'O job foi renomeado para "' + @NewJobName + '" e desabilitado com sucesso.';

-------------------------------------------------------------------------------------------------------------------------------
/*exclui estrutura de job antigos*/
-------------------------------------------------------------------------------------------------------------------------------

USE [_DBACloudControle];
IF NOT EXISTS
    (
        SELECT
            *
        FROM
            sys.objects
        WHERE
            object_id = OBJECT_ID(N'[dbo].[UpdateStatistics_Priority]')
            AND type IN (
                            N'U'
                        )
    )
    BEGIN

        USE [_DBACloudControle];

        CREATE TABLE [dbo].[UpdateStatistics_Priority]
            (
                [DBNamePriority]     [sysname] NOT NULL,
                [SchemaNamePriority] [sysname] NOT NULL,
                [TableNamePriority]  [sysname] NOT NULL
            ) ON [PRIMARY];

    END;

USE [_DBACloudControle];
GO

ALTER TABLE tblLogRebuildIndex
ALTER COLUMN TSQLCommand VARCHAR(MAX) NULL;
GO

USE [_DBACloudControle];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO


IF NOT EXISTS
    (
        SELECT
            1
        FROM
            sys.procedures
        WHERE
            name = 'stpCarga_TLogSize'
    )
    BEGIN
        EXEC ('CREATE PROCEDURE stpCarga_TLogSize AS SELECT 1;');
    END;

GO

ALTER PROCEDURE stpCarga_TLogSize
AS
    BEGIN


        -- Cria uma tabela temporária para armazenar o espaço livre dos discos
        IF OBJECT_ID('tempdb..#DiskSpace') IS NOT NULL
            DROP TABLE #DiskSpace;

        CREATE TABLE #DiskSpace
            (
                Drive       CHAR(2),
                FreeSpaceMB FLOAT
            );

        -- Insere dados do xp_fixeddrives na tabela temporária
        INSERT INTO #DiskSpace
            (
                Drive,
                FreeSpaceMB
            )
        EXEC xp_fixeddrives;

        TRUNCATE TABLE _DBACloudControle..LogSpaceUsage;

        -- Declara um cursor para percorrer as databases
        DECLARE @DatabaseName NVARCHAR(128);
        DECLARE db_cursor CURSOR FOR
            SELECT
                name
            FROM
                sys.databases
            WHERE
                state_desc = 'ONLINE'
                AND name NOT IN (
                                    'master', 'model', 'msdb', 'tempdb', '_DBACloudControle'
                                );

        OPEN db_cursor;

        FETCH NEXT FROM db_cursor
        INTO
            @DatabaseName;

        WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Construção da SQL dinâmica para cada database
                DECLARE @SQL NVARCHAR(MAX);
                DECLARE @DBName NVARCHAR(128) = @DatabaseName;

                SET @SQL
                    = N'
        USE [' + @DatabaseName
                      + N'];

        -- Consulta informações dos arquivos de log e associa com o espaço livre do disco
      
        SELECT TOP 1
            DB_NAME(lsu.database_id) AS DatabaseName,                        -- Nome do banco de dados
            lsu.total_log_size_in_bytes / 1024 / 1024 AS TotalLogSizeMB,      -- Tamanho total do log de transações em MB
            lsu.used_log_space_in_bytes / 1024 / 1024 AS UsedLogSpaceMB,      -- Espaço utilizado no log de transações em MB
            (lsu.total_log_size_in_bytes - lsu.used_log_space_in_bytes) / 1024 / 1024 AS FreeLogSpaceMB,  -- Espaço livre no log de transações em MB
            lsu.used_log_space_in_percent AS UsedLogSpacePercent,            -- Percentual de espaço utilizado no log de transações
            ds.FreeSpaceMB                                                   -- Espaço livre na unidade onde o log está localizado em MB

        FROM
            sys.dm_db_log_space_usage lsu
        JOIN
            sys.master_files AS mf
            ON lsu.database_id = mf.database_id
            AND mf.type = 1                                                  -- Filtra apenas os arquivos de log
        JOIN
            #DiskSpace AS ds
            ON LEFT(mf.physical_name, 1) = ds.Drive                          -- Junta com a unidade correspondente
        WHERE
            lsu.total_log_size_in_bytes IS NOT NULL;                         -- Garante que há dados válidos para exibir
    '           ;

                -- Executa o SQL dinâmico
                INSERT INTO LogSpaceUsage
                EXEC sp_executesql
                    @SQL;

                FETCH NEXT FROM db_cursor
                INTO
                    @DatabaseName;
            END;

        CLOSE db_cursor;
        DEALLOCATE db_cursor;

        -- Limpa a tabela temporária
        DROP TABLE #DiskSpace;

    END;
GO

USE [_DBACloudControle];
GO

IF NOT EXISTS
    (
        SELECT
            1
        FROM
            sys.procedures
        WHERE
            name = 'usp_Totvs_DBACloud_UpdateStatistics2'
    )
    BEGIN
        EXEC ('CREATE PROCEDURE usp_Totvs_DBACloud_UpdateStatistics2 AS SELECT 1;');
    END;

USE [_DBACloudControle];
GO
/****** Object:  StoredProcedure [dbo].[usp_Totvs_DBACloud_UpdateStatistics2]    Script Date: 09/10/2024 10:49:44 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

ALTER PROCEDURE [dbo].[usp_Totvs_DBACloud_UpdateStatistics2]
    @mdcounter       INT  = 30,         -- Valor usado para filtrar estatísticas a serem atualizadas
    @ControleHorario BIT  = 1,          -- Controle para aplicar regras de horário (1 = ativado, 0 = desativado)
    @StartTime       TIME = '22:00:00', -- Horário de início para controle de execução
    @EndTime         TIME = '06:00:00', -- Horário de término para controle de execução
    @TimeRuduceStats TIME = '05:00:00', -- Horário para controle de redução de rows
    @LimiteLinhas    INT  = 1000000     -- Limite de linhas para a atualização das estatísticas
AS
    BEGIN
        BEGIN TRY
            DROP TABLE IF EXISTS #tbl_stats;
            DROP TABLE IF EXISTS #tbl_stats_priority;
        END TRY
        BEGIN CATCH
        END CATCH;

        CREATE TABLE #tbl_stats
            (
                DBName              sysname,
                SchemaName          sysname,
                TableName           sysname,
                StatName            sysname,
                LastUpdated         DATETIME,
                ModificationCounter BIGINT,
                [Rows]              BIGINT,
                [% Rows Sampled]    BIGINT
            );

        CREATE TABLE #tbl_stats_priority
            (
                DBNamePriority              sysname,
                SchemaNamePriority          sysname,
                TableNamePriority           sysname,
                StatNamePriority            sysname,
                LastUpdatedPriority         DATETIME,
                ModificationCounterPriority BIGINT,
                [RowsPriority]              BIGINT,
                [% Rows Sampled Priority]   BIGINT
            );

        IF OBJECT_ID('tempdb.dbo.##tbmdcounter') IS NOT NULL
            DROP TABLE ##tbmdcounter;

        SELECT
             @mdcounter AS mdcounter
        INTO ##tbmdcounter;

        INSERT INTO #tbl_stats
            (
                DBName,
                SchemaName,
                TableName,
                StatName,
                LastUpdated,
                ModificationCounter,
                [Rows],
                [% Rows Sampled]
            )
        EXEC sp_MSforeachdb
            @command1 = 'USE [?];
        IF DB_ID() > 4 and DATABASEPROPERTYEX(DB_NAME(), ''status'') = ''ONLINE'' and DATABASEPROPERTYEX(DB_NAME(), ''updateability'') = ''READ_WRITE''
        SELECT   
            DBName = DB_NAME(),   
            SchemaName = OBJECT_SCHEMA_NAME(obj.object_id),
            TableName = obj.name,
            StatName = stat.name,
            LastUpdated = sp.last_updated,
            ModificationCounter = sp.modification_counter,
            [Rows],
            [% Rows Sampled] = sp.rows_sampled * 100 / [rows]
        FROM  sys.objects AS obj
        INNER JOIN  sys.stats AS stat ON stat.object_id = obj.object_id
        CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp 
        WHERE obj.is_ms_shipped = 0
            AND (sp.modification_counter * 100 / [rows] >= (SELECT mdcounter FROM ##tbmdcounter) 
            OR sp.rows_sampled * 100 / [rows] <= 10 
            OR DATEDIFF(DAY, sp.last_updated, GETDATE()) > 5)
            AND obj.name NOT LIKE ''%_TTAT_LOG%'' COLLATE Latin1_General_CI_AI
            AND obj.name NOT IN (SELECT TableNamePriority COLLATE Latin1_General_CI_AI FROM _DBACloudControle.[dbo].[UpdateStatistics_Priority])';

        INSERT INTO #tbl_stats_priority
            (
                DBNamePriority,
                SchemaNamePriority,
                TableNamePriority,
                StatNamePriority,
                LastUpdatedPriority,
                ModificationCounterPriority,
                [RowsPriority],
                [% Rows Sampled Priority]
            )
        EXEC sp_MSforeachdb
            @command1 = 'USE [?];
        IF DB_ID() > 4 and DATABASEPROPERTYEX(DB_NAME(), ''status'') = ''ONLINE'' and DATABASEPROPERTYEX(DB_NAME(), ''updateability'') = ''READ_WRITE''
        SELECT   
            DBName = DB_NAME(),   
            SchemaName = OBJECT_SCHEMA_NAME(obj.object_id),
            TableName = obj.name,
            StatName = stat.name,
            LastUpdated = sp.last_updated,
            ModificationCounter = sp.modification_counter,
            [Rows],
            [% Rows Sampled] = sp.rows_sampled * 100 / [rows]
        FROM  sys.objects AS obj
        INNER JOIN  sys.stats AS stat ON stat.object_id = obj.object_id
        CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp 
        WHERE obj.is_ms_shipped = 0
            AND (sp.modification_counter * 100 / [rows] >= (SELECT mdcounter FROM ##tbmdcounter) 
            OR sp.rows_sampled * 100 / [rows] <= 10 
            OR DATEDIFF(DAY, sp.last_updated, GETDATE()) > 7)
            AND obj.name NOT LIKE ''%_TTAT_LOG%'' COLLATE Latin1_General_CI_AI
            AND obj.name IN (SELECT TableNamePriority COLLATE Latin1_General_CI_AI FROM _DBACloudControle.[dbo].[UpdateStatistics_Priority]) or Rows <= 1000000';

        DECLARE
            @DBName              sysname,
            @SchemaName          sysname,
            @TableName           sysname,
            @StatName            sysname,
            @str_UpdateStats     NVARCHAR(MAX) = N'',
            @LastUpdated         DATETIME2,
            @ModificationCounter BIGINT,
            @Rows                BIGINT,
            @RowsSampled         BIGINT;

        DECLARE cr_UpdateStats CURSOR KEYSET FOR
            SELECT
                DBName,
                SchemaName,
                TableName,
                StatName,
                LastUpdated,
                ModificationCounter,
                [Rows],
                [% Rows Sampled]
            FROM
                #tbl_stats
            ORDER BY
                DBName;

        OPEN cr_UpdateStats;

        FETCH NEXT FROM cr_UpdateStats
        INTO
            @DBName,
            @SchemaName,
            @TableName,
            @StatName,
            @LastUpdated,
            @ModificationCounter,
            @Rows,
            @RowsSampled;

        WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE @CurrentTime TIME = CONVERT(TIME, GETDATE()); -- Horário atual
                DECLARE @currentDay INT = DATEPART(WEEKDAY, GETDATE());
                --DECLARE @CurrentTime TIME = DATEADD(HOUR, 4, GETDATE()); -- Horário atual

                IF @currentDay <> 1
                    SET @ControleHorario = 1;


                IF OBJECT_ID('tempdb.dbo.#tblLogUpdateStatistics', 'U') IS NOT NULL
                    DROP TABLE #tblLogUpdateStatistics;

                CREATE TABLE #tblLogUpdateStatistics
                    (
                        id INT
                    );

                -- Verificação do controle de horário
                IF (
                       @currentDay <> 1
                       OR @ControleHorario = 1
                   )
                    BEGIN
                        -- Verificação de horários, considerando a passagem da meia-noite
                        IF (@StartTime <= @EndTime)
                            BEGIN
                                IF (
                                       @CurrentTime < @StartTime
                                       OR @CurrentTime > @EndTime
                                   )
                                    BEGIN
                                        PRINT 'Fora do horário permitido.';
                                        BREAK;
                                    END;
                            END;
                        ELSE
                            BEGIN
                                IF NOT (
                                           @CurrentTime >= @StartTime
                                           OR @CurrentTime <= @EndTime
                                       )
                                    BEGIN
                                        PRINT 'Fora do horário permitido.';
                                        BREAK;
                                    END;
                            END;
                    END;

                -- Verifica se a quantidade de linhas excede o limite a partir do horário de redução
                IF (
                       @currentDay = 1
                       AND @ControleHorario = 0
                   )
                    BEGIN
                        IF (
                               (
                                   @TimeRuduceStats <= @EndTime
                                   AND @CurrentTime >= @TimeRuduceStats
                                   AND @CurrentTime <= @EndTime
                               )
                               OR
                                   (
                                       @TimeRuduceStats > @EndTime
                                       AND
                                           (
                                               @CurrentTime >= @TimeRuduceStats
                                               OR @CurrentTime <= @EndTime
                                           )
                                   )
                           )
                           AND @Rows > @LimiteLinhas
                            BEGIN
                                PRINT 'Quantidade de linhas excede o limite para o horário';
                                FETCH NEXT FROM cr_UpdateStats
                                INTO
                                    @DBName,
                                    @SchemaName,
                                    @TableName,
                                    @StatName,
                                    @LastUpdated,
                                    @ModificationCounter,
                                    @Rows,
                                    @RowsSampled;
                                CONTINUE;
                            END;
                    END;

                -- Atualização das estatísticas
                SET @str_UpdateStats
                    = N'UPDATE STATISTICS ' + QUOTENAME(@DBName) + N'.' + QUOTENAME(@SchemaName) + N'.'
                      + QUOTENAME(@TableName) + N'(' + N'[' + @StatName + N']' + N') WITH FULLSCAN';
                EXEC (@str_UpdateStats);

                INSERT INTO _DBACloudControle.dbo.tblLogUpdateStatistics
                    (
                        DBName,
                        SchemaName,
                        TableName,
                        StatsName,
                        LastUpdated,
                        [Rows],
                        ModificationCounter,
                        [% Rows Sampled],
                        TSQLCommand
                    )
                OUTPUT
                    inserted.Id
                INTO #tblLogUpdateStatistics
                VALUES
                    (
                        @DBName, @SchemaName, @TableName, @StatName, @LastUpdated, @Rows, @ModificationCounter,
                        @RowsSampled, @str_UpdateStats
                    );

                UPDATE
                    _DBACloudControle.dbo.tblLogUpdateStatistics
                SET
                    EndTime = GETDATE()
                WHERE
                    Id =
                    (
                        SELECT TOP 1
                               id
                        FROM
                               #tblLogUpdateStatistics
                    );

                FETCH NEXT FROM cr_UpdateStats
                INTO
                    @DBName,
                    @SchemaName,
                    @TableName,
                    @StatName,
                    @LastUpdated,
                    @ModificationCounter,
                    @Rows,
                    @RowsSampled;
            END;

        CLOSE cr_UpdateStats;
        DEALLOCATE cr_UpdateStats;

        -- Limpeza das tabelas temporárias
        DROP TABLE #tbl_stats;
        DROP TABLE #tbl_stats_priority;
        IF OBJECT_ID('tempdb.dbo.##tbmdcounter') IS NOT NULL
            DROP TABLE ##tbmdcounter;
    END;


    /****** Object:  StoredProcedure [dbo].[usp_Totvs_DBACloud_RebuildIndexes]    Script Date: 23/08/2024 18:29:12 ******/
    SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

IF NOT EXISTS
    (
        SELECT
            1
        FROM
            sys.procedures
        WHERE
            name = 'usp_Totvs_DBACloud_RebuildIndexes'
    )
    BEGIN
        EXEC ('CREATE PROCEDURE usp_Totvs_DBACloud_RebuildIndexes AS SELECT 1;');
    END;


USE [_DBACloudControle];
GO

/****** Object:  StoredProcedure [dbo].[usp_Totvs_DBACloud_RebuildIndexes]    Script Date: 06/08/2024 18:39:50 ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO


ALTER PROCEDURE [dbo].[usp_Totvs_DBACloud_RebuildIndexes]
    (
        @fragidx             INT        = 10,         -- Fragmentação maior ou igual a @fragidx %
        @fillfactor          INT        = 80,         -- Fillfactor dos indexes ex: 90 para ocupar 90% de deixar 10% livre
        @SortTempdb          VARCHAR(3) = 'OFF',      -- Especifica se os resultados de classificação devem ser armazenados em tempdb. O padrão é OFF.
        @RecompStats         VARCHAR(3) = 'OFF',      -- Especifica se as estatísticas de distribuição são recomputadas. O padrão é OFF.ON -> As estatísticas desatualizadas não são recalculadas automaticamente.OFF -> A atualização automática de estatísticas está habilitada.
        @online              BIT        = 0,
        @DataCompression     CHAR(4)    = 'NONE',
        @MaxDuration         INT        = NULL,
        @RebuildHeaps        BIT        = 0,          -- Novo parâmetro: Controla se o rebuild de heaps será feito (0 = não, 1 = sim)
        @ControleHorario     BIT        = 1,          -- Novo parâmetro: Controle de horário (1 = ativado, 0 = desativado)
        @TimeRuduceIndexSize TIME       = '05:00:00', -- Parâmetro: Horario que limita o tamanho dos indices
        @StartTime           TIME       = '00:00:00', -- Parâmetro: Hora de Inicio
        @EndTime             TIME       = '06:00:00'  -- Parâmetro: Hora de término
    )
AS
    BEGIN
        DECLARE
            @str  NVARCHAR(MAX),
            @TTAT VARCHAR(255) = '';
        DECLARE @TOTAL_ERROS INT;
        SET @TOTAL_ERROS = 0;

        IF OBJECT_ID(N'#temp_indexes', N'U') IS NOT NULL
            DROP TABLE tempdb..#temp_indexes;

        CREATE TABLE #temp_indexes
            (
                ObjectName     VARCHAR(500),
                IndexId        INT,
                IndexName      VARCHAR(500),
                IndexType      INT,
                AllowPageLocks BIT,
                IsImageText    BIT
            );


        INSERT INTO #temp_indexes
        EXEC sp_MSforeachdb
            @command1 = 'use [?]
            if DB_ID() > 4 and DATABASEPROPERTYEX(DB_NAME(), ''status'') = ''ONLINE'' and DATABASEPROPERTYEX(DB_NAME(), ''updateability'') = ''READ_WRITE''
    SELECT  objects.[name] AS ObjectName,
           indexes.index_id AS IndexID,
           indexes.[name] AS IndexName,
           indexes.[type] AS IndexType,
           indexes.allow_page_locks AS AllowPageLocks,
           CASE
               WHEN indexes.[type] = 1
                    AND EXISTS
                        (
                            SELECT *
                            FROM sys.columns columns
                                INNER JOIN sys.types types
                                    ON columns.system_type_id = types.user_type_id
                            WHERE columns.[object_id] = objects.object_id
                                  AND types.name IN ( ''image'', ''text'', ''ntext'')
                        ) THEN
                   1
               ELSE
                   0
           END AS IsImageText
    FROM sys.indexes indexes
        INNER JOIN sys.objects objects
            ON indexes.[object_id] = objects.[object_id]
        INNER JOIN sys.schemas schemas
            ON objects.[schema_id] = schemas.[schema_id]
        LEFT OUTER JOIN sys.tables tables
            ON objects.[object_id] = tables.[object_id]
        LEFT OUTER JOIN sys.stats stats
            ON indexes.[object_id] = stats.[object_id]
               AND indexes.[index_id] = stats.[stats_id]
    WHERE objects.[type] IN ( ''U'', ''V'' )
          AND indexes.[type] IN ( 1, 2, 3, 4, 5, 6, 7 )
          AND indexes.is_disabled = 0
          AND indexes.is_hypothetical = 0
    '   ;

        DECLARE
            @ProductLevel TINYINT,
            @UpSP1        BIT;

        SELECT
            @ProductLevel = CAST(SUBSTRING(CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')), 1, 2) AS TINYINT), --SQL 2016 ou superior
            @UpSP1        = CASE
                                WHEN (CONVERT(VARCHAR(128), SERVERPROPERTY('productlevel')) NOT IN (
                                                                                                       'RTM', 'SP1'
                                                                                                   )
                                     )
                                    THEN
                                    1 --SP2 ou superior
                                ELSE
                                    0
                            END;

        IF @DataCompression <> 'NONE'
            BEGIN
                IF NOT (
                           (CONVERT(VARCHAR(128), SERVERPROPERTY('edition')) LIKE 'Enterprise%')
                           OR
                               (
                                   @ProductLevel > 12
                                   AND @UpSP1 = 1
                               )
                       )
                    SET @DataCompression = 'NONE';
            END;

        DECLARE @var_online VARCHAR(500) = 'OFF';

        IF CONVERT(VARCHAR(128), SERVERPROPERTY('edition')) LIKE 'Enterprise%'
            BEGIN
                IF @online = 1
                    SET @var_online
                        = 'ON ( WAIT_AT_LOW_PRIORITY ( MAX_DURATION = 5 MINUTES, ABORT_AFTER_WAIT = SELF))';
                ELSE
                    SET @var_online = 'OFF';
            END;


        DECLARE @str_rebuild NVARCHAR(MAX);
        DECLARE
            @Usage                BIGINT,
            @databaseName         NVARCHAR(256),
            @ObjectName           NVARCHAR(256),
            @SchemaName           sysname,
            @IndexName            sysname,
            @FragmentationPercent DECIMAL(18, 2),
            @IndexType            NVARCHAR(60),
            @AllocationUnitType   VARCHAR(255),
            @IndexSizeMB          DECIMAL(18, 2),
            @LastAccess           DATETIME;

        DECLARE RebuildIndexes CURSOR KEYSET FOR
            SELECT
                Usage,
                DatabaseName,
                SchemaName,
                ObjectName,
                IndexName,
                FragmentationPercent,
                IndexType,
                AllocationUnitType,
                IndexSizeMB,
                LastAccess
            FROM
                _DBACloudControle..idx_rebuild
            WHERE
                FragmentationPercent >= 10
                AND
                    (
                        @RebuildHeaps = 1
                        OR IndexName IS NOT NULL
                    )
            ORDER BY
                FragmentationPercent DESC,
                Usage DESC;

        OPEN RebuildIndexes;

        FETCH FIRST FROM RebuildIndexes
        INTO
            @Usage,
            @databaseName,
            @SchemaName,
            @ObjectName,
            @IndexName,
            @FragmentationPercent,
            @IndexType,
            @AllocationUnitType,
            @IndexSizeMB,
            @LastAccess;

        WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE @currentTime TIME = CAST(GETDATE() AS TIME);
                DECLARE @currentDay INT = DATEPART(WEEKDAY, GETDATE());

                IF (
                       @currentDay <> 1
                       OR @ControleHorario = 1
                   )
                    BEGIN

                        -- Verificação de horários, considerando a passagem da meia-noite
                        IF (@StartTime <= @EndTime)
                            BEGIN
                                IF (
                                       @currentTime < @StartTime
                                       OR @currentTime > @EndTime
                                   )
                                    BEGIN
                                        PRINT 'Fora do horário permitido para rebuild.';
                                        BREAK;
                                    END;
                            END;
                        ELSE
                            BEGIN
                                IF NOT (
                                           @currentTime >= @StartTime
                                           OR @currentTime <= @EndTime
                                       )
                                    BEGIN
                                        PRINT 'Fora do horário permitido para rebuild.';
                                        BREAK;
                                    END;
                            END;
                    END;

                -- Limitação de tamanho dos índices após as 05:00


                IF (
                       (
                           @TimeRuduceIndexSize <= @EndTime
                           AND @currentTime >= @TimeRuduceIndexSize
                           AND @currentTime <= @EndTime
                       )
                       OR
                           (
                               @TimeRuduceIndexSize > @EndTime
                               AND
                                   (
                                       @currentTime >= @TimeRuduceIndexSize
                                       OR @currentTime <= @EndTime
                                   )
                           )
                   )
                   AND @IndexSizeMB > 300.00
                    BEGIN
                        PRINT 'Índice excede 300 MB após as ' + CAST(@TimeRuduceIndexSize AS VARCHAR(100))
                              + '. Rebuild não realizado.';
                        FETCH NEXT FROM RebuildIndexes
                        INTO
                            @Usage,
                            @databaseName,
                            @SchemaName,
                            @ObjectName,
                            @IndexName,
                            @FragmentationPercent,
                            @IndexType,
                            @AllocationUnitType,
                            @IndexSizeMB,
                            @LastAccess;

                        CONTINUE;
                    END;
                ELSE
                    BEGIN
                        -- Se for domingo e controle de horário estiver desabilitado, permitir rebuild sem limitação de tamanho
                        PRINT 'Sem limitação de tamanho.';
                    END;


                -- Verificação de uso para índices nomeados

                IF @IndexName IS NOT NULL
                    BEGIN

                        -- Check if the index is currently being used/locked
                        IF NOT EXISTS
                            (
                                SELECT
                                    1
                                FROM
                                    sys.dm_tran_locks
                                WHERE
                                    resource_associated_entity_id = OBJECT_ID(@databaseName + '.' + @SchemaName + '.'
                                                                              + @ObjectName
                                                                             )
                                    AND resource_type = 'OBJECT'
                                    AND request_status = 'GRANT'
                            )
                            BEGIN
                                IF (@FragmentationPercent
                                   BETWEEN 5 AND 10
                                   )
                                    SET @str_rebuild
                                        = N'ALTER INDEX ' + QUOTENAME(@IndexName) + N' ON ' + QUOTENAME(@databaseName)
                                          + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@ObjectName)
                                          + N' REORGANIZE;';

                                IF (@FragmentationPercent > 10)
                                    SET @str_rebuild
                                        = N'ALTER INDEX ' + QUOTENAME(@IndexName) + N' ON ' + QUOTENAME(@databaseName)
                                          + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@ObjectName)
                                          + N' REBUILD WITH (
						                    DATA_COMPRESSION = ' + @DataCompression + N', FILLFACTOR = '
                                          + CONVERT(VARCHAR(3), @fillfactor) + N', ONLINE = ' + @var_online
                                          + N', SORT_IN_TEMPDB = ' + @SortTempdb + N', STATISTICS_NORECOMPUTE = '
                                          + @RecompStats + N');';

                                IF @var_online LIKE ('ON%')
                                    IF EXISTS
                                        (
                                            SELECT
                                                    1
                                            FROM
                                                    #temp_indexes                  a
                                                JOIN
                                                    _DBACloudControle..idx_rebuild b
                                                        ON a.ObjectName = b.ObjectName
                                                           AND a.IndexName = b.IndexName
                                            WHERE
                                                    a.IsImageText = 1
                                                    AND a.IndexName = @IndexName
                                        )
                                        BEGIN
                                            SET @var_online = 'OFF';
                                        END;

                                BEGIN
                                    SET @str_rebuild
                                        = N'ALTER INDEX ' + QUOTENAME(@IndexName) + N' ON ' + QUOTENAME(@databaseName)
                                          + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@ObjectName)
                                          + N' REBUILD WITH (
						                DATA_COMPRESSION = ' + @DataCompression + N', FILLFACTOR = '
                                          + CONVERT(VARCHAR(3), @fillfactor) + N', ONLINE = ' + @var_online
                                          + N', SORT_IN_TEMPDB = ' + @SortTempdb + N', STATISTICS_NORECOMPUTE = '
                                          + @RecompStats + N');';
                                END;
                            END;

                        ELSE
                            BEGIN
                                PRINT ('Índice ' + @IndexName + ' no objeto ' + @ObjectName
                                       + ' está sendo utilizado. Pular a reconstrução.'
                                      );
                                SET @str_rebuild = NULL;
                            END;
                    END;


                ELSE
                    BEGIN
                        -- Verificação de uso para HEAP
                        IF NOT EXISTS
                            (
                                SELECT
                                    1
                                FROM
                                    sys.dm_tran_locks
                                WHERE
                                    resource_associated_entity_id = OBJECT_ID(@databaseName + '.' + @SchemaName + '.'
                                                                              + @ObjectName
                                                                             )
                                    AND resource_type = 'OBJECT'
                                    AND request_status = 'GRANT'
                            )
                            BEGIN
                                IF (@FragmentationPercent
                                   BETWEEN 5 AND 10
                                   )
                                    SET @str_rebuild
                                        = N'ALTER TABLE ' + QUOTENAME(@databaseName) + N'.' + QUOTENAME(@SchemaName)
                                          + N'.' + QUOTENAME(@ObjectName) + N' REORGANIZE;';

                                IF (@FragmentationPercent > 10)
                                    SET @str_rebuild
                                        = N'ALTER TABLE ' + QUOTENAME(@databaseName) + N'.' + QUOTENAME(@SchemaName)
                                          + N'.' + QUOTENAME(@ObjectName) + N' REBUILD WITH (DATA_COMPRESSION = '
                                          + @DataCompression + N', ONLINE = ' + @var_online + N');';
                            END;
                        ELSE
                            BEGIN
                                PRINT ('Heap no objeto ' + @ObjectName + ' está sendo utilizado. Pular a reconstrução.');
                                SET @str_rebuild = NULL;
                            END;
                    END;

                IF EXISTS
                    (
                        SELECT
                            1
                        FROM
                            tempdb.sys.tables
                        WHERE
                            name LIKE '%#tblLogRebuildIndex%'
                    )
                    DROP TABLE #tblLogRebuildIndex;

                CREATE TABLE #tblLogRebuildIndex
                    (
                        id INT
                    );

                INSERT INTO _DBACloudControle.dbo.tblLogRebuildIndex
                    (
                        DBName,
                        SchemaName,
                        ObjectName,
                        IndexName,
                        FragmentationPercent,
                        IndexSizeMB,
                        LastAccess,
                        TSQLCommand
                    )
                OUTPUT
                    inserted.id
                INTO #tblLogRebuildIndex
                VALUES
                    (
                        @databaseName, @SchemaName, @ObjectName, @IndexName, @FragmentationPercent, @IndexSizeMB,
                        @LastAccess, @str_rebuild
                    );

                BEGIN TRY

                    -- Verificação do tamanho do transaction log

                    DECLARE @IsSpaceSufficient BIT = 0;

                    WHILE @IsSpaceSufficient = 0
                        BEGIN
                            -- Verificação do tamanho do transaction log
                            EXEC stpCarga_TLogSize;

                            DECLARE @TotalLogSizeMB FLOAT;
                            DECLARE @FreeSpaceMB FLOAT;
                            DECLARE @UsedLogSpacePercent FLOAT;

                            SELECT
                                @TotalLogSizeMB      = TotalLogSizeMB,
                                @FreeSpaceMB         = FreeSpaceMB,
                                @UsedLogSpacePercent = UsedLogSpacePercent
                            FROM
                                [dbo].[LogSpaceUsage]
                            WHERE
                                [DatabaseName] = @databaseName; -- Altere conforme necessário

                            IF (@FreeSpaceMB - @TotalLogSizeMB) < 10240
                               AND @UsedLogSpacePercent > 85
                                BEGIN
                                    -- Log a message or perform any other action before delaying
                                    PRINT 'Insufficient free space for log growth. Waiting for 15 minutes...';

                                    -- Delay execution for 15 minutes
                                    WAITFOR DELAY '00:15:00';;
                                END;
                            ELSE
                                BEGIN
                                    -- Se o espaço for suficiente, sair do loop
                                    SET @IsSpaceSufficient = 1;
                                END;
                        END;



                    IF (DATEPART(WEEKDAY, GETDATE()) = 1)
                        BEGIN
                            IF
                                (
                                    SELECT
                                        COUNT(*)
                                    FROM
                                        sys.dm_hadr_database_replica_states
                                    WHERE
                                        log_send_queue_size >= 20971520
                                        OR redo_queue_size >= 20971520
                                        OR synchronization_health_desc <> 'HEALTHY'
                                        OR synchronization_state_desc NOT IN (
                                                                                 'SYNCHRONIZING', 'SYNCHRONIZED'
                                                                             )
                                ) > 0
                                BEGIN
                                    PRINT ('Base de dados com mais de 20gb de Sync...');
                                    WAITFOR DELAY '00:05:00';
                                END;
                        END;

                    IF (DATEPART(WEEKDAY, GETDATE()) <> 1)
                        BEGIN
                            IF
                                (
                                    SELECT
                                        COUNT(*)
                                    FROM
                                        sys.dm_hadr_database_replica_states
                                    WHERE
                                        log_send_queue_size >= 10485760
                                        OR redo_queue_size >= 10485760
                                        OR synchronization_health_desc <> 'HEALTHY'
                                        OR synchronization_state_desc NOT IN (
                                                                                 'SYNCHRONIZING', 'SYNCHRONIZED'
                                                                             )
                                ) > 0
                                BEGIN
                                    PRINT ('Base de dados com mais de 10gb de Sync...');
                                    WAITFOR DELAY '00:05:00';
                                END;
                        END;

                    EXEC (@str_rebuild);

                    UPDATE
                        _DBACloudControle.dbo.tblLogRebuildIndex
                    SET
                        EndTime = GETDATE()
                    WHERE
                        id =
                        (
                            SELECT
                                id
                            FROM
                                #tblLogRebuildIndex
                        );

                    DELETE FROM
                    _DBACloudControle..idx_rebuild
                    WHERE
                        IndexName = @IndexName;

                END TRY
                BEGIN CATCH

                    INSERT INTO _DBACloudControle.dbo.tblLogErroRebuildIndex
                        (
                            id,
                            MsgErro
                        )
                                SELECT
                                    id,
                                    ERROR_MESSAGE()
                                FROM
                                    #tblLogRebuildIndex;

                END CATCH;

                DROP TABLE #tblLogRebuildIndex;

                FETCH NEXT FROM RebuildIndexes
                INTO
                    @Usage,
                    @databaseName,
                    @SchemaName,
                    @ObjectName,
                    @IndexName,
                    @FragmentationPercent,
                    @IndexType,
                    @AllocationUnitType,
                    @IndexSizeMB,
                    @LastAccess;
            END;

        CLOSE RebuildIndexes;
        DEALLOCATE RebuildIndexes;
    END;


GO



USE [_DBACloudControle];
GO

/****** Object:  StoredProcedure [dbo].[stpCargaFragmentacao]    Script Date: 23/08/2024 15:22:31 ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO


IF NOT EXISTS
    (
        SELECT
            1
        FROM
            sys.procedures
        WHERE
            name = 'stpCargaFragmentacao'
    )
    BEGIN
        EXEC ('CREATE PROCEDURE stpCargaFragmentacao AS SELECT 1;');
    END;


USE [_DBACloudControle];
GO
/****** Object:  StoredProcedure [dbo].[stpCargaFragmentacao] ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

ALTER PROCEDURE [dbo].[stpCargaFragmentacao]
AS
    BEGIN
        -- Limpar a tabela de fragmentação
        TRUNCATE TABLE _DBACloudControle..idx_rebuild;

        -- Declaração do cursor para iterar sobre as databases
        DECLARE @DatabaseName NVARCHAR(128);
        DECLARE db_cursor CURSOR FOR
            SELECT
                name
            FROM
                sys.databases
            WHERE
                database_id > 4
                AND state_desc = 'ONLINE'
                AND DATABASEPROPERTYEX(name, 'updateability') = 'READ_WRITE';

        -- Abrir o cursor
        OPEN db_cursor;

        -- Buscar a primeira database
        FETCH NEXT FROM db_cursor
        INTO
            @DatabaseName;

        -- Loop pelo cursor
        WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Construção do comando SQL em partes menores
                DECLARE @SQL NVARCHAR(MAX);
                SET @SQL = N'USE ' + QUOTENAME(@DatabaseName) + N'; ';

                SET @SQL
                    = @SQL
                      + N'INSERT INTO _DBACloudControle..idx_rebuild
        (
            Usage,
            DatabaseName,
            SchemaName,
            ObjectName,
            IndexName,
            FragmentationPercent,
            IndexType,
            AllocationUnitType,
            IndexSizeMB,
            LastAccess
        ) '     ;

                SET @SQL
                    = @SQL
                      + N'SELECT
            ISNULL((s.user_seeks + s.user_scans + s.user_lookups + s.user_updates), 0) AS [Usage],
            DB_NAME() AS DatabaseName,
            sc.name AS SchemaName,
            so.name AS ObjectName,
            i.name AS IndexName,
            CAST(a.avg_fragmentation_in_percent AS DECIMAL(18, 2)) AS FragmentationPercent,
            a.index_type_desc AS IndexType,
            a.alloc_unit_type_desc AS AllocationUnitType,
            CAST((a.page_count / 128) AS DECIMAL(18, 2)) AS IndexSizeMB,
            s.LastAccess
        FROM sys.indexes AS i
        INNER JOIN sys.objects so ON so.object_id = i.object_id
        INNER JOIN sys.schemas sc ON so.schema_id = sc.schema_id
        INNER JOIN sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, ''LIMITED'') a
            ON i.[object_id] = a.[object_id]
            AND i.index_id = a.index_id
            AND a.alloc_unit_type_desc = ''IN_ROW_DATA''
        LEFT OUTER JOIN
        (
            SELECT s.database_id, s.object_id, s.index_id, s.user_seeks, s.user_scans, s.user_lookups, s.user_updates,  
            ISNULL(s.last_user_seek, ISNULL(s.last_user_scan, s.last_user_lookup)) AS LastAccess
            FROM sys.dm_db_index_usage_stats s
        ) AS s 
            ON s.database_id = DB_ID()
            AND s.object_id = so.object_id
            AND s.index_id = i.index_id   
        WHERE ISNULL(OBJECTPROPERTY(s.[object_id], ''IsMsShipped''), 0) = 0
          AND a.avg_fragmentation_in_percent >= 10
          AND a.page_count > 1000
          AND so.name NOT LIKE ''%_TTAT_LOG%'' COLLATE Latin1_General_CI_AI
          AND so.name NOT IN 
              (SELECT NomeTabela COLLATE Latin1_General_CI_AI 
               FROM _DBACloudControle..ListaExclusaoRebuild 
               WHERE GETDATE() BETWEEN DataInicio AND DataFim);';

                -- Executar o comando SQL dinâmico
                EXEC sp_executesql
                    @SQL;

                -- Buscar a próxima database
                FETCH NEXT FROM db_cursor
                INTO
                    @DatabaseName;
            END;

        -- Fechar e desalocar o cursor
        CLOSE db_cursor;
        DEALLOCATE db_cursor;
    END;
GO

-------------------------------------------------------------------------------------------------------------------------------
/*Cria os novos job*/
-------------------------------------------------------------------------------------------------------------------------------

USE [msdb];
GO

/****** Object:  Job [Totvs | DBA Cloud - Maintenance]    Script Date: 23/08/2024 18:53:36 ******/
BEGIN TRANSACTION;
DECLARE @ReturnCode INT;
SELECT
    @ReturnCode = 0;

/****** Verificar se o Job já existe ******/
IF NOT EXISTS
    (
        SELECT
            name
        FROM
            msdb.dbo.sysjobs
        WHERE
            name = N'Totvs | DBA Cloud - Maintenance'
    )
    BEGIN
        /****** Object:  JobCategory [Data Collector]    Script Date: 23/08/2024 18:53:36 ******/
        IF NOT EXISTS
            (
                SELECT
                    name
                FROM
                    msdb.dbo.syscategories
                WHERE
                    name = N'Data Collector'
                    AND category_class = 1
            )
            BEGIN
                EXEC @ReturnCode = msdb.dbo.sp_add_category
                    @class = N'JOB',
                    @type = N'LOCAL',
                    @name = N'Data Collector';
                IF (
                       @@ERROR <> 0
                       OR @ReturnCode <> 0
                   )
                    GOTO QuitWithRollback;
            END;

        DECLARE @jobId BINARY(16);
        EXEC @ReturnCode = msdb.dbo.sp_add_job
            @job_name = N'Totvs | DBA Cloud - Maintenance',
            @enabled = 1,
            @notify_level_eventlog = 0,
            @notify_level_email = 0,
            @notify_level_netsend = 0,
            @notify_level_page = 0,
            @delete_level = 0,
            @description = N'No description available.',
            @category_name = N'Data Collector',
            @owner_login_name = N'JCStack',
            @job_id = @jobId OUTPUT;
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;

        /****** Object:  Step [DIARIO]    Script Date: 23/08/2024 18:53:36 ******/
        EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
            @job_id = @jobId,
            @step_name = N'DIARIO',
            @step_id = 1,
            @cmdexec_success_code = 0,
            @on_success_action = 1,
            @on_success_step_id = 0,
            @on_fail_action = 2,
            @on_fail_step_id = 0,
            @retry_attempts = 3,
            @retry_interval = 10,
            @os_run_priority = 0,
            @subsystem = N'TSQL',
            @command = N'DECLARE @IsPrimaryReplica BIT = 0
DECLARE @IsAlwaysOnEnabled BIT = 0
DECLARE @DayOfWeek INT
DECLARE @SqlCommand NVARCHAR(MAX)
DECLARE @ReplicaServerName NVARCHAR(255)

-- Verificar se AlwaysOn está habilitado
IF EXISTS (SELECT 1 FROM sys.dm_hadr_availability_group_states)
BEGIN
    SET @IsAlwaysOnEnabled = 1
END

-- Se AlwaysOn estiver habilitado, verificar se é a réplica primária
IF @IsAlwaysOnEnabled = 1
BEGIN
    -- Obter o nome da réplica atual (servidor/instância)
    SET @ReplicaServerName = CAST(SERVERPROPERTY(''ServerName'') AS NVARCHAR(255))

    -- Verificar se o banco está em AlwaysOn e se é a réplica primária
    IF EXISTS (
        SELECT 1 
        FROM sys.dm_hadr_availability_replica_states AS ha
        INNER JOIN sys.dm_hadr_availability_group_states AS gs 
            ON ha.group_id = gs.group_id
        INNER JOIN sys.dm_hadr_availability_replica_cluster_states AS cs 
            ON ha.replica_id = cs.replica_id
        WHERE ha.role_desc = ''PRIMARY'' 
        AND cs.replica_server_name = @ReplicaServerName
    )
    BEGIN
        SET @IsPrimaryReplica = 1
    END
END
ELSE
BEGIN
    -- Se AlwaysOn não estiver habilitado, considerar como se fosse a réplica primária
    SET @IsPrimaryReplica = 1
END

-- Obter o dia da semana (1 = Domingo, 7 = Sábado)
SET @DayOfWeek = DATEPART(WEEKDAY, GETDATE())

-- Executar a procedure apenas se for a réplica primária ou se não houver AlwaysOn
IF @IsPrimaryReplica = 1
BEGIN
    IF @DayOfWeek = 1 -- Se for domingo
    BEGIN
        SET @SqlCommand = ''exec usp_Totvs_DBACloud_UpdateStatistics2 @mdcounter = 30, @ControleHorario = 0, @StartTime = ''''21:00:00'''', @TimeRuduceStats = ''''05:00'''', @EndTime = ''''06:00:00''''''
    END
    ELSE -- Se for qualquer outro dia da semana
    BEGIN
        SET @SqlCommand = ''exec usp_Totvs_DBACloud_UpdateStatistics2 @mdcounter = 30, @ControleHorario = 1, @StartTime = ''''21:00:00'''', @TimeRuduceStats = ''''05:00'''', @EndTime = ''''06:00:00''''''
    END

    -- Executa o comando SQL gerado
    EXEC sp_executesql @SqlCommand
END
ELSE
BEGIN
    PRINT ''Este servidor não é a réplica primária ou não está em um ambiente AlwaysOn.''
END
'       ,
            @database_name = N'_DBACloudControle',
            @flags = 16;
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;

        EXEC @ReturnCode = msdb.dbo.sp_update_job
            @job_id = @jobId,
            @start_step_id = 1;
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;

        EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule
            @job_id = @jobId,
            @name = N'DIARIO',
            @enabled = 1,
            @freq_type = 4,
            @freq_interval = 1,
            @freq_subday_type = 1,
            @freq_subday_interval = 0,
            @freq_relative_interval = 0,
            @freq_recurrence_factor = 0,
            @active_start_date = 20240821,
            @active_end_date = 99991231,
            @active_start_time = 210000,
            @active_end_time = 235959,
            @schedule_uid = N'7bf1471c-7929-45b0-ad09-f5d0a280109c';
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;

        EXEC @ReturnCode = msdb.dbo.sp_add_jobserver
            @job_id = @jobId,
            @server_name = N'(local)';
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;
    END;

COMMIT TRANSACTION;
GOTO EndSave;

QuitWithRollback:
IF (@@TRANCOUNT > 0)
    ROLLBACK TRANSACTION;

EndSave:
GO

/****** Object:  Job [Totvs | DBA Cloud - Maintenance - Rebuild]    Script Date: 23/08/2024 18:53:36 ******/
USE [msdb];
GO

BEGIN TRANSACTION;
DECLARE @ReturnCode INT;
SELECT
    @ReturnCode = 0;

/****** Verificar se o Job já existe ******/
IF NOT EXISTS
    (
        SELECT
            name
        FROM
            msdb.dbo.sysjobs
        WHERE
            name = N'Totvs | DBA Cloud - Maintenance - Rebuild'
    )
    BEGIN
        /****** Object:  JobCategory [Data Collector]    Script Date: 09/10/2024 12:49:34 ******/
        IF NOT EXISTS
            (
                SELECT
                    name
                FROM
                    msdb.dbo.syscategories
                WHERE
                    name = N'Data Collector'
                    AND category_class = 1
            )
            BEGIN
                EXEC @ReturnCode = msdb.dbo.sp_add_category
                    @class = N'JOB',
                    @type = N'LOCAL',
                    @name = N'Data Collector';
                IF (
                       @@ERROR <> 0
                       OR @ReturnCode <> 0
                   )
                    GOTO QuitWithRollback;

            END;

        DECLARE @jobId BINARY(16);
        EXEC @ReturnCode = msdb.dbo.sp_add_job
            @job_name = N'Totvs | DBA Cloud - Maintenance - Rebuild',
            @enabled = 1,
            @notify_level_eventlog = 0,
            @notify_level_email = 0,
            @notify_level_netsend = 0,
            @notify_level_page = 0,
            @delete_level = 0,
            @description = N'No description available.',
            @category_name = N'Data Collector',
            @owner_login_name = N'JCStack',
            @job_id = @jobId OUTPUT;
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;
        /****** Object:  Step [Carga Frag Index]    Script Date: 09/10/2024 12:49:34 ******/
        EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
            @job_id = @jobId,
            @step_name = N'Carga Frag Index',
            @step_id = 1,
            @cmdexec_success_code = 0,
            @on_success_action = 3,
            @on_success_step_id = 0,
            @on_fail_action = 2,
            @on_fail_step_id = 0,
            @retry_attempts = 0,
            @retry_interval = 0,
            @os_run_priority = 0,
            @subsystem = N'TSQL',
            @command = N'exec stpCargaFragmentacao',
            @database_name = N'_DBACloudControle',
            @flags = 0;
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;
        /****** Object:  Step [Exec Rebuild]    Script Date: 09/10/2024 12:49:34 ******/
        EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
            @job_id = @jobId,
            @step_name = N'Exec Rebuild',
            @step_id = 2,
            @cmdexec_success_code = 0,
            @on_success_action = 1,
            @on_success_step_id = 0,
            @on_fail_action = 2,
            @on_fail_step_id = 0,
            @retry_attempts = 3,
            @retry_interval = 10,
            @os_run_priority = 0,
            @subsystem = N'TSQL',
            @command = N'DECLARE @IsPrimaryReplica BIT = 0
DECLARE @IsAlwaysOnEnabled BIT = 0
DECLARE @DayOfWeek INT
DECLARE @SqlCommand NVARCHAR(MAX)
DECLARE @ReplicaServerName NVARCHAR(255)

-- Verificar se AlwaysOn está habilitado
IF EXISTS (SELECT 1 FROM sys.dm_hadr_availability_group_states)
BEGIN
    SET @IsAlwaysOnEnabled = 1
END

-- Se AlwaysOn estiver habilitado, verificar se é a réplica primária
IF @IsAlwaysOnEnabled = 1
BEGIN
    -- Obter o nome da réplica atual (servidor/instância)
    SET @ReplicaServerName = CAST(SERVERPROPERTY(''ServerName'') AS NVARCHAR(255))

    -- Verificar se o banco está em AlwaysOn e se é a réplica primária
    IF EXISTS (
        SELECT 1
        FROM sys.dm_hadr_availability_replica_states AS ha
        INNER JOIN sys.dm_hadr_availability_group_states AS gs 
            ON ha.group_id = gs.group_id
        INNER JOIN sys.dm_hadr_availability_replica_cluster_states AS cs
            ON ha.replica_id = cs.replica_id
        WHERE ha.role_desc = ''PRIMARY''
        AND cs.replica_server_name = @ReplicaServerName
    )
    BEGIN
        SET @IsPrimaryReplica = 1
    END
END
ELSE
BEGIN
    -- Se AlwaysOn não estiver habilitado, considerar como se fosse a réplica primária
    SET @IsPrimaryReplica = 1
END

-- Obter o dia da semana (1 = Domingo, 7 = Sábado)
SET @DayOfWeek = DATEPART(WEEKDAY, GETDATE())

-- Executar a procedure apenas se for a réplica primária ou se não houver AlwaysOn
IF @IsPrimaryReplica = 1
BEGIN
    IF @DayOfWeek = 1 -- Se for domingo
    BEGIN
        SET @SqlCommand = ''EXECUTE usp_Totvs_DBACloud_RebuildIndexes @online = 1, @DataCompression = ''''PAGE'''', @ControleHorario = 0, @StartTime = ''''20:00:00'''', @TimeRuduceIndexSize = ''''05:00:00'''', @EndTime = ''''06:00:00''''''
    END
    ELSE -- Se for qualquer outro dia da semana
    BEGIN
        SET @SqlCommand = ''EXECUTE usp_Totvs_DBACloud_RebuildIndexes @online = 1, @DataCompression = ''''PAGE'''', @ControleHorario = 1, @StartTime = ''''20:00:00'''', @TimeRuduceIndexSize = ''''05:00:00'''', @EndTime = ''''06:00:00''''''
    END

    -- Executa o comando SQL gerado
    EXEC sp_executesql @SqlCommand
END
ELSE
BEGIN
    PRINT ''Este servidor não é a réplica primária ou não está em um ambiente AlwaysOn.''
END
'       ,
            @database_name = N'_DBACloudControle',
            @flags = 8;
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;
        EXEC @ReturnCode = msdb.dbo.sp_update_job
            @job_id = @jobId,
            @start_step_id = 1;
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;
        EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule
            @job_id = @jobId,
            @name = N'DIARIO',
            @enabled = 1,
            @freq_type = 4,
            @freq_interval = 1,
            @freq_subday_type = 1,
            @freq_subday_interval = 0,
            @freq_relative_interval = 0,
            @freq_recurrence_factor = 0,
            @active_start_date = 20240821,
            @active_end_date = 99991231,
            @active_start_time = 200000,
            @active_end_time = 235959,
            @schedule_uid = N'927ca9e1-7cd6-473e-95d8-1639ebe4cbf4';
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;
        EXEC @ReturnCode = msdb.dbo.sp_add_jobserver
            @job_id = @jobId,
            @server_name = N'(local)';
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;
        COMMIT TRANSACTION;
        GOTO EndSave;
        QuitWithRollback:
        IF (@@TRANCOUNT > 0)
            ROLLBACK TRANSACTION;
        EndSave:
    END;
GO







USE [msdb];
GO

/****** Object:  Job [Totvs | DBA Cloud - Stop Job - Maintenance]    Script Date: 11/09/2024 15:25:56 ******/
BEGIN TRANSACTION;
DECLARE @ReturnCode INT;
SELECT
    @ReturnCode = 0;
/****** Object:  JobCategory [Data Collector]    Script Date: 11/09/2024 15:25:56 ******/
/****** Verificar se o Job já existe ******/
IF NOT EXISTS
    (
        SELECT
            name
        FROM
            msdb.dbo.sysjobs
        WHERE
            name = N'Totvs | DBA Cloud - Stop Job - Maintenance'
    )
    BEGIN
        IF NOT EXISTS
            (
                SELECT
                    name
                FROM
                    msdb.dbo.syscategories
                WHERE
                    name = N'Data Collector'
                    AND category_class = 1
            )
            BEGIN
                EXEC @ReturnCode = msdb.dbo.sp_add_category
                    @class = N'JOB',
                    @type = N'LOCAL',
                    @name = N'Data Collector';
                IF (
                       @@ERROR <> 0
                       OR @ReturnCode <> 0
                   )
                    GOTO QuitWithRollback;

            END;

        DECLARE @jobId BINARY(16);
        EXEC @ReturnCode = msdb.dbo.sp_add_job
            @job_name = N'Totvs | DBA Cloud - Stop Job - Maintenance',
            @enabled = 1,
            @notify_level_eventlog = 0,
            @notify_level_email = 0,
            @notify_level_netsend = 0,
            @notify_level_page = 0,
            @delete_level = 0,
            @description = N'Verifica se o job Totvs | DBA Cloud - Stop Job - Maintenance está em execução e o finaliza.',
            @category_name = N'Data Collector',
            @owner_login_name = N'JCStack',
            @job_id = @jobId OUTPUT;
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;
        /****** Object:  Step [Rebuild]    Script Date: 11/09/2024 15:25:56 ******/
        EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
            @job_id = @jobId,
            @step_name = N'Rebuild',
            @step_id = 1,
            @cmdexec_success_code = 0,
            @on_success_action = 3,
            @on_success_step_id = 0,
            @on_fail_action = 2,
            @on_fail_step_id = 0,
            @retry_attempts = 0,
            @retry_interval = 0,
            @os_run_priority = 0,
            @subsystem = N'TSQL',
            @command = N'declare @jobName sysname = ''Totvs | DBA Cloud - Maintenance - Rebuild'';

if exists (
	SELECT
		A.job_id,
		C.name AS job_name,
		E.name AS job_category,
		C.[enabled],
		C.[description],
		A.start_execution_date,
		A.last_executed_step_date,
		A.next_scheduled_run_date,
		CONVERT(VARCHAR, CONVERT(VARCHAR, DATEADD(SECOND, ( DATEDIFF(SECOND, A.start_execution_date, GETDATE()) % 86400 ), 0), 114)) AS time_elapsed,
		ISNULL(A.last_executed_step_id, 0) + 1 AS current_executed_step_id,
		D.step_name
	FROM
		msdb.dbo.sysjobactivity                 A   WITH(NOLOCK)
		LEFT JOIN msdb.dbo.sysjobhistory        B   WITH(NOLOCK)    ON  A.job_history_id = B.instance_id
		JOIN msdb.dbo.sysjobs                   C   WITH(NOLOCK)    ON  A.job_id = C.job_id
		JOIN msdb.dbo.sysjobsteps               D   WITH(NOLOCK)    ON  A.job_id = D.job_id AND ISNULL(A.last_executed_step_id, 0) + 1 = D.step_id
		JOIN msdb.dbo.syscategories             E   WITH(NOLOCK)    ON  C.category_id = E.category_id
	WHERE
		A.session_id = ( SELECT TOP 1 session_id FROM msdb.dbo.syssessions    WITH(NOLOCK) ORDER BY agent_start_date DESC ) 
		AND A.start_execution_date IS NOT NULL 
		AND A.stop_execution_date IS NULL
		AND C.name = @jobName
) 
BEGIN
	-- PARA O JOB...
	EXEC msdb..sp_stop_job @jobName;

	-- NOTIFICA O OPERADOR DBACLOUD, CASO EXISTA...
	if exists (SELECT 1 from msdb..sysoperators where name = ''Operator_DBACloud'')
	begin
		DECLARE @body nvarchar(MAX);
		DECLARE @operEmail nvarchar(512);
		DECLARE @subject nvarchar(100);

		set @body = ''O job '' + QUOTENAME(@jobName) + '' foi interrompido na instância '' + QUOTENAME(@@SERVERNAME) + '', pois ainda estava em execução às 07:10AM.'';

		select @operEmail = email_address
		from msdb..sysoperators
		where name = ''Operator_DBACloud'';

		set @subject = ''Interrupção do job '' + QUOTENAME(@jobName);

		exec msdb.dbo.sp_send_dbmail
			@profile_name = ''DBACLOUD_DatabaseMail'',
			@recipients = @operEmail,
			@subject = @subject,
			@body = @body;
	end
END
'       ,
            @database_name = N'master',
            @flags = 0;
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;
        /****** Object:  Step [Stop job Totvs | DBA Cloud - Maintenance]    Script Date: 11/09/2024 15:25:56 ******/
        EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
            @job_id = @jobId,
            @step_name = N'Stop job Totvs | DBA Cloud - Maintenance',
            @step_id = 2,
            @cmdexec_success_code = 0,
            @on_success_action = 1,
            @on_success_step_id = 0,
            @on_fail_action = 2,
            @on_fail_step_id = 0,
            @retry_attempts = 0,
            @retry_interval = 0,
            @os_run_priority = 0,
            @subsystem = N'TSQL',
            @command = N'declare @jobName sysname = ''Totvs | DBA Cloud - Maintenance'';

if exists (
	SELECT
		A.job_id,
		C.name AS job_name,
		E.name AS job_category,
		C.[enabled],
		C.[description],
		A.start_execution_date,
		A.last_executed_step_date,
		A.next_scheduled_run_date,
		CONVERT(VARCHAR, CONVERT(VARCHAR, DATEADD(SECOND, ( DATEDIFF(SECOND, A.start_execution_date, GETDATE()) % 86400 ), 0), 114)) AS time_elapsed,
		ISNULL(A.last_executed_step_id, 0) + 1 AS current_executed_step_id,
		D.step_name
	FROM
		msdb.dbo.sysjobactivity                 A   WITH(NOLOCK)
		LEFT JOIN msdb.dbo.sysjobhistory        B   WITH(NOLOCK)    ON  A.job_history_id = B.instance_id
		JOIN msdb.dbo.sysjobs                   C   WITH(NOLOCK)    ON  A.job_id = C.job_id
		JOIN msdb.dbo.sysjobsteps               D   WITH(NOLOCK)    ON  A.job_id = D.job_id AND ISNULL(A.last_executed_step_id, 0) + 1 = D.step_id
		JOIN msdb.dbo.syscategories             E   WITH(NOLOCK)    ON  C.category_id = E.category_id
	WHERE
		A.session_id = ( SELECT TOP 1 session_id FROM msdb.dbo.syssessions    WITH(NOLOCK) ORDER BY agent_start_date DESC ) 
		AND A.start_execution_date IS NOT NULL 
		AND A.stop_execution_date IS NULL
		AND C.name = @jobName
) 
BEGIN
	-- PARA O JOB...
	EXEC msdb..sp_stop_job @jobName;

	-- NOTIFICA O OPERADOR DBACLOUD, CASO EXISTA...
	if exists (SELECT 1 from msdb..sysoperators where name = ''Operator_DBACloud'')
	begin
		DECLARE @body nvarchar(MAX);
		DECLARE @operEmail nvarchar(512);
		DECLARE @subject nvarchar(100);

		set @body = ''O job '' + QUOTENAME(@jobName) + '' foi interrompido na instância '' + QUOTENAME(@@SERVERNAME) + '', pois ainda estava em execução às 06:00AM.'';

		select @operEmail = email_address
		from msdb..sysoperators
		where name = ''Operator_DBACloud'';

		set @subject = ''Interrupção do job '' + QUOTENAME(@jobName);

		exec msdb.dbo.sp_send_dbmail
			@profile_name = ''DBACLOUD_DatabaseMail'',
			@recipients = @operEmail,
			@subject = @subject,
			@body = @body;
	end
END
'       ,
            @database_name = N'master',
            @flags = 0;
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;
        EXEC @ReturnCode = msdb.dbo.sp_update_job
            @job_id = @jobId,
            @start_step_id = 1;
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;
        EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule
            @job_id = @jobId,
            @name = N'Diario_6AM',
            @enabled = 1,
            @freq_type = 4,
            @freq_interval = 1,
            @freq_subday_type = 1,
            @freq_subday_interval = 0,
            @freq_relative_interval = 0,
            @freq_recurrence_factor = 0,
            @active_start_date = 20210101,
            @active_end_date = 99991231,
            @active_start_time = 61000,
            @active_end_time = 235959,
            @schedule_uid = N'a0b8317b-cc98-471c-ba64-c90cabcd0687';
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;
        EXEC @ReturnCode = msdb.dbo.sp_add_jobserver
            @job_id = @jobId,
            @server_name = N'(local)';
        IF (
               @@ERROR <> 0
               OR @ReturnCode <> 0
           )
            GOTO QuitWithRollback;
        COMMIT TRANSACTION;
        GOTO EndSave;
        QuitWithRollback:
        IF (@@TRANCOUNT > 0)
            ROLLBACK TRANSACTION;
        EndSave:
    END;
GO
