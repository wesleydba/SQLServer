;with
    tcpip
    as
    (
        select value_data as [Porta]
        from sys.dm_server_registry
        WHERE value_name = 'TcpPort' and registry_key like '%\IPAll'

    ),
    infodb
    as
    (
        select
            name as [Database Name],
            state_desc as [Status do Banco],
            case is_read_only 
		when 0 Then 'Escrita/Leitura'
		when 1 Then 'Somente leitura'
	end as [Read-Only?]
        from sys.databases
        where database_id > 4 and name not like '%DBACloudControle%'
    )
select @@SERVERNAME as [Instância], [Database Name], [Status do Banco], [Read-Only?] , '172.19.107.29,' + CONVERT(VARCHAR(12), [Porta], 101) as [IP/Porta]  
, '' as [Ativo?], '' as [Cliente] , '' as [Observação]

from infodb , tcpip
order by [Database Name] asc