-- Query necessaria para verificar o espaco no inicio e final do datafile, no qual pode causar erros na execucao do backup efetuado via ferramenta de terceiros sem ser pelo o sql serve. Exemplo de ferramenta que apresenta erro Rubrik
-- lista nome com espaço
SELECT sys.master_files.name LogicalName , '#' + sys.databases.name + '#' Logical_Name , '#' + physical_name + '#' Physical_Name
FROM sys.databases JOIN sys.master_files on
(sys.databases.database_id = sys.master_files.database_id )
WHERE physical_name LIKE '%\\ %' OR physical_name LIKE '% '
    OR sys.databases.name LIKE '% '
    OR sys.databases.name LIKE ' %'
ORDER BY sys.databases.name ASC;


---

-- lista nome com espaço
SELECT
    sys.databases.name as 'Database'
    , sys.master_files.name LogicalName
       , '#' + sys.databases.name + '#' Logical_Name
       , '#' + physical_name + '#' Physical_Name
FROM sys.databases
    JOIN sys.master_files ON (sys.databases.database_id = sys.master_files.database_id)
WHERE physical_name LIKE '%\\ %'
    OR physical_name LIKE '% '
    OR physical_name LIKE '%\ %'
    OR sys.databases.name LIKE '% '
    OR sys.databases.name LIKE ' %'
ORDER BY sys.databases.name ASC;