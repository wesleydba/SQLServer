select *
from sys.databases
where database_id > 4 and name not like  '%CloudControle%'

/*Select para listar todos os database em uma unica linha separados por virgula*/
DECLARE @Nomes VARCHAR(MAX)
SELECT
    @Nomes = COALESCE(@Nomes + ', ', '') + name
from
    sys.databases
where database_id > 4 and name not like  '%CloudControle%'
SELECT @Nomes
go
