select name , 'DENY CONNECT SQL TO ' + '['+name+']' , 'ALTER LOGIN ' + '['+name+']' + ' DISABLE'
from sys.sql_logins
where is_disabled = 0 and name not in ('Totvs','sa')

select name , 'DENY CONNECT SQL TO ' + '['+name+']' , 'ALTER LOGIN ' + '['+name+']' + ' DISABLE'
from sys.sql_logins
where [name] like 'aprm_%' or [name] like 'usr_%'