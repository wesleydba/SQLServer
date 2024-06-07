/*Todo usuário deve estar com o "Enforce password policy" marcado , então caso seja necessário criar / alterar um usuário sempre marque está opção. Lembrando que irá solicitar uma senha forte.

1 - Script  serve para verificar quais os usuários que estão sem o CHECK_POLICY=ON e gera o comando de alter login para deixar a opção marcada.*/

select name, is_disabled, is_policy_checked, is_expiration_checked ,
    'ALTER LOGIN ' + QuoteName(name) + ' WITH CHECK_POLICY = ON;' as 'Comando a executar'
FROM sys.sql_logins
WHERE is_policy_checked = 0
ORDER BY name;

/*2 - Script abaixo serve para auxilar a descobrir qual o client (ip / host) q está conectando com a senha errada e assim bloqueando o usuário.
Ele verificar as últimas 24 horas.*/

DECLARE @start DATETIME = DATEADD(HOUR, -2 ,GETDATE())
DECLARE @end   DATETIME = GETDATE()
EXEC master.dbo.xp_readerrorlog 0, 1, N'Password did not match that for the login provided', null, @start, @end