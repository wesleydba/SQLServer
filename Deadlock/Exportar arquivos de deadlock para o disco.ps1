/*
versao w com filtro de data funcionando 
https://claudioessilva.eu/2020/05/25/Export-Deadlocks-to-file-from-system_health-Extended-Event-using-PowerShell/
*/

$outputDirectory = "D:\Deadlocks\Date_filtro"

$query = @"
DECLARE @LogPath NVARCHAR(255) = (SELECT CAST(SERVERPROPERTY('ErrorLogFileName') AS NVARCHAR(255)))
SET @LogPath = SUBSTRING(@LogPath, 1, CHARINDEX('\ERRORLOG', @LogPath) - 1)

DECLARE @DataInicial DATETIME = '2023-10-23 13:15:51.223'
DECLARE @DataFinal DATETIME = '2023-10-23 15:21:51.239'

SELECT
    CONVERT(xml, event_data).query('/event/data/value/child::*') as deadlock,
    CONVERT(xml, event_data).value('(event[@name="xml_deadlock_report"]/@timestamp)[1]','datetime') AS Execution_Time
FROM sys.fn_xe_file_target_read_file(@LogPath + '\system_health*.xel', null, null, null)
WHERE 
    object_name like 'xml_deadlock_report'
    AND CONVERT(xml, event_data).value('(event[@name="xml_deadlock_report"]/@timestamp)[1]','datetime') >= @DataInicial
    AND CONVERT(xml, event_data).value('(event[@name="xml_deadlock_report"]/@timestamp)[1]','datetime') <= @DataFinal;
"@


$InstanciaName = Connect-DbaInstance -SqlInstance 'VDBAPRIMEAG261B\PIMS'

# Executar a consulta SQL usando a conexão criada
$results = Invoke-DbaQuery -SqlInstance $InstanciaName -Query $query

# Criar uma pasta para salvar os arquivos
New-Item -Path $outputDirectory -Type Directory -Force

# Salvar cada XML como arquivo xdl no sistema de arquivos
$results | ForEach-Object {
    $_.deadlock | Out-File -FilePath "$outputDirectory\deadlock$($_.Execution_Time.ToString("yyyyMMddHHmmss")).xdl"
}


/*versao w 2 funcionando*/ 

$outputDirectory = "D:\Deadlocks\New folder"

$query = @"
DECLARE @LogPath NVARCHAR(255) = (SELECT CAST(SERVERPROPERTY('ErrorLogFileName') AS NVARCHAR(255)))
SET @LogPath = SUBSTRING(@LogPath, 1, charindex('\ERRORLOG', @LogPath) - 1)

SELECT
    CONVERT(xml, event_data).query('/event/data/value/child::*') as deadlock,
    CONVERT(xml, event_data).value('(event[@name="xml_deadlock_report"]/@timestamp)[1]','datetime') AS Execution_Time
FROM sys.fn_xe_file_target_read_file(@LogPath + '\system_health*.xel', null, null, null)
WHERE object_name like 'xml_deadlock_report'
"@


$InstanciaName = Connect-DbaInstance -SqlInstance 'VDBAPRIMEAG261B\PIMS'

# Executar a consulta SQL usando a conexão criada
$results = Invoke-DbaQuery -SqlInstance $InstanciaName -Query $query

# Criar uma pasta para salvar os arquivos
New-Item -Path $outputDirectory -Type Directory -Force

# Salvar cada XML como arquivo xdl no sistema de arquivos
$results | ForEach-Object {
    $_.deadlock | Out-File -FilePath "$outputDirectory\deadlock$($_.Execution_Time.ToString("yyyyMMddHHmmss")).xdl"
}

/*versao 1*/
$outputDirectory = "D:\tmp"

$query = @"
DECLARE @LogPath NVARCHAR(255) = (SELECT CAST(SERVERPROPERTY('ErrorLogFileName') AS NVARCHAR(255)))
SET @LogPath = SUBSTRING(@LogPath, 1, charindex('\ERRORLOG', @LogPath) - 1)

SELECT
    CONVERT(xml, event_data).query('/event/data/value/child::*') as deadlock,
    CONVERT(xml, event_data).value('(event[@name="xml_deadlock_report"]/@timestamp)[1]','datetime') AS Execution_Time
FROM sys.fn_xe_file_target_read_file(@LogPath + '\system_health*.xel', null, null, null)
WHERE object_name like 'xml_deadlock_report'
"@


# Informe o nome da instância 
$InstanciaManual = "PROTHEUS"
$InstanciaName = Connect-DbaInstance -SqlInstance $env:computername\$InstanciaManual

# Executar a consulta SQL usando a conexão criada
$results = Invoke-DbaQuery -SqlInstance $InstanciaName -Query $query

# Criar uma pasta para salvar os arquivos
New-Item -Path $outputDirectory -Type Directory -Force

# Salvar cada XML como arquivo xdl no sistema de arquivos
$results | ForEach-Object {
    $_.deadlock | Out-File -FilePath "$outputDirectory\deadlock$($_.Execution_Time.ToString("yyyyMMddHHmmss")).xdl"
}

/*https://claudioessilva.eu/2020/05/25/Export-Deadlocks-to-file-from-system_health-Extended-Event-using-PowerShell/*/


/*notebook wesley*/

$outputDirectory = "C:\Temp\tmp"

$query = @"
DECLARE @LogPath NVARCHAR(255) = (SELECT CAST(SERVERPROPERTY('ErrorLogFileName') AS NVARCHAR(255)))
SET @LogPath = SUBSTRING(@LogPath, 1, charindex('\ERRORLOG', @LogPath) - 1)

SELECT
    CONVERT(xml, event_data).query('/event/data/value/child::*') as deadlock,
    CONVERT(xml, event_data).value('(event[@name="xml_deadlock_report"]/@timestamp)[1]','datetime') AS Execution_Time
FROM sys.fn_xe_file_target_read_file(@LogPath + '\system_health*.xel', null, null, null)
WHERE object_name like 'xml_deadlock_report'
"@


# Informe o nome da instância se existir mais de uma instancia no servidor

$InstanciaName = Connect-DbaInstance -SqlInstance 'WESLEYCARDOSO\SQL2019' -TrustServerCertificate

# Executar a consulta SQL usando a conexão criada
$results = Invoke-DbaQuery -SqlInstance $InstanciaName -Query $query

# Criar uma pasta para salvar os arquivos
New-Item -Path $outputDirectory -Type Directory -Force

# Salvar cada XML como arquivo xdl no sistema de arquivos
$results | ForEach-Object {
    $_.deadlock | Out-File -FilePath "$outputDirectory\deadlock$($_.Execution_Time.ToString("yyyyMMddHHmmss")).xdl"
}