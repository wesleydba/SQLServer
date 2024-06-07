SELECT is_broker_enabled
FROM sys.databases
WHERE name = 'msdb';
GO

SELECT *
FROM sys.configurations
WHERE name = 'Database Mail XPs'
GO

SELECT *
FROM sys.configurations
where name ='show advanced options'
GO

/*Fontes :  https://www.brentozar.com/blitz/database-mail-configuration/
            https://www.dirceuresende.com/blog/como-habilitar-enviar-monitorar-emails-pelo-sql-server-sp_send_dbmail/
            https://www.brunodba.com/2018/08/22/database-mail/
*/





/* Para o funcionamento correto do e-mail é necessário que o Relay esteja habilitado para o servidor desejado.  Exemplo abaixo da tela de relay onde está restrito ao servidor*/


