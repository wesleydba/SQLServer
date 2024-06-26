-- Necessario criar um linked server chamado LK_USER para que seja possivel utilizar os comandos abaixo, no qual ira listar usuario com sid diferente, senha diferente, quantidade de login em cada host.
--Query para verificar quais usuários estão com nome igual porém o SID diferente entre os nodes primario e secundario.

SELECT
    lo.name as 'name primario'
       , lk.name as 'name secundário'
       , lo.sid as 'sid primario'
       , lk.sid as 'sid secundário'
       , lo.password_hash as 'password primario'
       , lk.password_hash as 'password secundário'
FROM sys.sql_logins lo
    INNER JOIN LK_USER.master.sys.sql_logins lk ON lk.name = lo.name
WHERE lo.name = lk.name
    AND lo.sid <> lk.sid
    AND lo.name NOT LIKE '#%'
order by 1

-- Query para verificar no primario quantos usuários existem.

select count(*) as 'quant. de usuario primario'
from sys.sql_logins
where name NOT LIKE '#%'

-- Query para verificar no secundario quantos usuários existem.

select count(*) as 'quant. de usuario secundário'
from LK_USER.master.sys.sql_logins
where name NOT LIKE '#%'

--- Count que verifica os usuários com o mesmo sid e nome , se o total bate com o número de usuários em ambos os nodes.

SELECT
    count(*) as quantidade_usuario
FROM sys.sql_logins lo
    INNER JOIN LK_USER.master.sys.sql_logins lk ON lk.name = lo.name
WHERE lo.name = lk.name
    AND lo.sid = lk.sid
    AND lo.name NOT LIKE '#%'
order by 1

-- Query para verificar a diferença de usuario que existe entre  primario x secundario.
select *
from sys.sql_logins
where name  not in (select name
from LK_USER.master.sys.sql_logins)

-- Query para verificar a diferença de usuario que existe entre secundario x primario.

select *
from LK_USER.master.sys.sql_logins
where name  not in (select name
from sys.sql_logins)

--- Query que verifica o nome de usuario porém com senha diferente entre os nodes.

SELECT
    lo.name as 'name primario'
       , lk.name as 'name secundário'
       , lo.sid as 'sid primario'
       , lk.sid as 'sid secundário'
       , lo.password_hash as 'password primario'
       , lk.password_hash as 'password secundário'
FROM sys.sql_logins lo
    INNER JOIN LK_USER.master.sys.sql_logins lk ON lk.name = lo.name
WHERE lo.name = lk.name
    AND lo.password_hash <> lk.password_hash
    AND lo.name NOT LIKE '#%'
    and lo.name <> 'Totvs'
order by 1