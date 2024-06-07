SELECT
    SERVERPROPERTY('MachineName') AS [MachineName],
    SERVERPROPERTY('ServerName') AS [ServerName],
    SERVERPROPERTY('InstanceName') AS [Instance],
    SERVERPROPERTY('IsClustered') AS [IsClustered],
    SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [ComputerNamePhysicalNetBIOS],
    CASE LEFT(CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')), 4)
        WHEN '8.00' THEN 'SQL Server 2000'
        WHEN '9.00' THEN 'SQL Server 2005'
        WHEN '10.0' THEN 'SQL Server 2008'
        WHEN '10.5' THEN 'SQL Server 2008 R2'
        WHEN '11.0' THEN 'SQL Server 2012'
        WHEN '12.0' THEN 'SQL Server 2014'
        WHEN '13.0' THEN 'SQL Server 2016'
        WHEN '14.0' THEN 'SQL Server 2017'
        WHEN '15.0' THEN 'SQL Server 2019'
        ELSE 'SQL Server 2017+'
    END AS [SQLVersionBuild],
    SERVERPROPERTY('Edition') AS [Edition],
    SERVERPROPERTY('ProductLevel') AS [ProductLevel],
    SERVERPROPERTY('ProductUpdateLevel') AS [ProductUpdateLevel],
    SERVERPROPERTY('ProductVersion') AS [ProductVersion],
    SERVERPROPERTY('ProductMajorVersion') AS [ProductMajorVersion],
    SERVERPROPERTY('ProductMinorVersion') AS [ProductMinorVersion],
    SERVERPROPERTY('ProductBuild') AS [ProductBuild],
    SERVERPROPERTY('ProductBuildType') AS [ProductBuildType],
    SERVERPROPERTY('ProductUpdateReference') AS [ProductUpdateReference],
    SERVERPROPERTY('ProcessID') AS [ProcessID],
    SERVERPROPERTY('Collation') AS [Collation],
    SERVERPROPERTY('IsFullTextInstalled') AS [IsFullTextInstalled],
    SERVERPROPERTY('IsIntegratedSecurityOnly') AS [IsIntegratedSecurityOnly],
    SERVERPROPERTY('FilestreamConfiguredLevel') AS [FilestreamConfiguredLevel],
    SERVERPROPERTY('IsHadrEnabled') AS [IsHadrEnabled],
    SERVERPROPERTY('HadrManagerStatus') AS [HadrManagerStatus],
    SERVERPROPERTY('IsXTPSupported') AS [IsXTPSupported],
    SERVERPROPERTY('BuildClrVersion') AS [Build CLR Version];

-- Parametros https://docs.microsoft.com/pt-br/sql/t-sql/functions/serverproperty-transact-sql?view=sql-server-2017

-- Fonte> https://www.dirceuresende.com/blog/sql-server-como-identificar-a-versao-e-edicao-de-todas-as-instancias-do-servidor-utilizando-xp_regread-e-powershell/

