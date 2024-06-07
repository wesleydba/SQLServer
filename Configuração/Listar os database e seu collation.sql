--Listar as bases de dados e seus collations:
select name, collation_name from sys.databases where name = 'CNP5AU_115552_PR_PRO'
--Verificar o Collation do servidor:
select SERVERPROPERTY('collation') as Servidor