SELECT CONVERT(DECIMAL(10,2),(SUM(size * 8.00) / 1024.00 / 1024.00)) As "Tamanho Todos Bancos de Dados - GB"
FROM master.sys.master_files
WHERE database_id > 4

---
-- separa por rows e log 

SELECT type_desc,
    (CASE WHEN type_desc = 'ROWS' THEN CONVERT(DECIMAL(10,2),(SUM(size * 8.00) / 1024.00 / 1024.00)) ELSE 0 END) AS Total_Rows
    , (CASE WHEN type_desc = 'LOG' THEN CONVERT(DECIMAL(10,2),(SUM(size * 8.00) / 1024.00 / 1024.00)) ELSE 0 END) AS Total_Logs
FROM
    master.sys.master_files
WHERE 
    database_id > 4
group by type_desc