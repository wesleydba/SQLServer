DECLARE
@CmdUpdateJob VARCHAR(MAX) = ''
DECLARE @user VARCHAR(MAX)
set @user = 'dominio\usuario' 

-- Seleciona todos os database que estao configurados com o @user e ira alterar o sa
SELECT @CmdUpdateJob += 'USE '+'['+[name]+']'+ ' EXEC dbo.sp_changedbowner @loginame = N''sa'' '
FROM sys.databases
WHERE SUSER_SNAME(owner_sid) = @user

exec(@CmdUpdateJob)