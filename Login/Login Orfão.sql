/*1 - Executar o primeiro comando no database */
EXEC sp_change_users_login @Action='Report';

/*2- pegar o nome do login retornado no primeiro comando e informar substituindo 'NOME' */
EXEC sp_change_users_login 'auto_fix', 'NOME'