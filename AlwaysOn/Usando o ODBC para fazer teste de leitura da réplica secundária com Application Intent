Usando o ODBC para fazer teste de leitura da réplica secundária com Application Intent, para fazer o teste é 

$conn = New-Object System.Data.Odbc.OdbcConnection("DSN=INFORMA_NOME_ODBC;Uid=INFORMA_USUARIO;Pwd=INFORMA_SENHA")
$conn.open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "select @@SERVERNAME"
$reader = $cmd.ExecuteReader()
$reader.Read()
$reader[0]
$reader.Close()
$conn.Close()