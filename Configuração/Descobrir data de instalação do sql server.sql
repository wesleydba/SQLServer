-- Utilizando a server_principals
SELECT create_date AS 'SQL Server Installation Date'
FROM sys.server_principals
WHERE sid = 0x010100000000000512000000
-- NT AUTHORITY\SYSTEM


-- Utilizando a syslogins
SELECT createdate as 'SQL Server Installation Date'
FROM sys.syslogins
WHERE sid = 0x010100000000000512000000
-- NT AUTHORITY\SYSTEM


-- Obtendo mais informações da instalação
SELECT
    SERVERPROPERTY('productversion') AS ProductVersion,
    SERVERPROPERTY('productlevel') AS ProductLevel,
    SERVERPROPERTY('edition') AS Edition,
    SERVERPROPERTY('MachineName') AS MachineName,
    SERVERPROPERTY('LicenseType') AS LicenseType,
    SERVERPROPERTY('NumLicenses') AS NumLicenses,
    create_date AS 'SQL Server Installation Date'
FROM
    sys.server_principals
WHERE
    sid = 0x010100000000000512000000;
-- NT AUTHORITY\SYSTEM


-- Verificando a data de expiração do SQL Server (180 dias após instalação)
SELECT
    @@SERVERNAME AS Server_Name,
    create_date as 'SQL Server Installation Date',
    DATEADD(DAY, 180, create_date) as 'SQL Server Expiration Date',
    DATEDIFF(DAY, create_date, GETDATE()) AS Days_Used,
    DATEDIFF(DAY, GETDATE(), DATEADD(DAY, 180, create_date)) AS Days_Left
FROM
    sys.server_principals
WHERE
    sid = 0x010100000000000512000000 -- NT AUTHORITY\SYSTEM


/*Fonte:  https://www.dirceuresende.com/blog/sql-server-como-descobrir-quando-a-instancia-foi-instalada-data-de-instalacao/*/


