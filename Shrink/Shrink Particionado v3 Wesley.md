Shrink particionado versão Wesley

Documentação: Script de Shrink Particionado em Blocos de 20GB


📋 Descrição do Script


Script T-SQL para redução gradual de arquivos de banco de dados em blocos de 20GB, mantendo uma margem de segurança de 10% acima do espaço utilizado.

⚙️ Parâmetros Configuráveis

Parâmetro: @GbShrink
Valor Padrão:  20000 MB 
Descrição: Tamanho de cada bloco de redução (20GB)

Parâmetro: Margem de Segurança
Valor Padrão: 10% 
Descrição: Espaço adicional mínimo além do utilizado
 

⚠️ Recomendações de Uso


📅 Quando Executar

- Horário: Períodos de baixa utilização do banco
- Frequência: Apenas quando necessário para liberação de espaço
- Verifique se o database está comprimido. 

🔄 Versionamento

Data
Versão
Alterações
21/08/2025
1.0
Versão inicial do script
21/08/2025
1.1

Adição de margem de segurança de 10%
⚠️ AVISO: Este script deve ser executado por profissionais qualificados. Teste sempre em ambiente de desenvolvimento antes de usar em produção.


📊 Geração da tabela tbl_SHRINK

O script de particionamento funciona coletando informações da tabela tbl_SHRINK

```
select
        DBName,
        [Filename],
        FileType,
        FilegroupName,
        FilePath,
        TotalSize_MB,
        SpaceUsed_MB,
        CAST((SpaceUsed_MB *100/TotalSize_MB) as decimal(18,2)) as [Used (%)],
        CAST((TotalSize_MB - SpaceUsed_MB) as decimal(18,2)) as FreeSpace_MB,
        CAST((TotalSize_MB - SpaceUsed_MB) * 100 / TotalSize_MB as decimal(18,2)) as [Free (%)],
        AutoGrowth_Value,
        MaxSize
into tbl_SHRINK
    from
    (
        select
            DB_NAME() as DBName,
            sf.name [Filename],
            CASE sf.STATUS & 0x40
                WHEN 0x40 THEN 'LOG' ELSE 'ROWS' END FileType,
            sds.name as FilegroupName,
            sf.filename [FilePath],
            CAST(IIF((sf.size/128) < 1, 1, (sf.size/128)) as decimal(18,2)) AS [TotalSize_MB],
            CAST(FILEPROPERTY(sf.name, 'SpaceUsed')/128 as decimal(18,2)) [SpaceUsed_MB],
            CASE STATUS & 0x100000
                WHEN 0x100000 THEN convert(VARCHAR(3), sf.growth) + '%'
                ELSE cast((sf.growth/128) as varchar) + ' MB' END [AutoGrowth_Value],
            CASE maxsize
                WHEN -1 THEN
                    CASE sf.growth WHEN 0 THEN 'Restricted' ELSE 'Unlimited' END
                ELSE CAST((sf.maxsize/128) as varchar) + ' MB' END [MaxSize]
        from sysfiles sf
        inner join sys.database_files sdf on sdf.file_id = sf.fileid
        left outer join sys.data_spaces sds on sds.data_space_id = sdf.data_space_id
    ) FileInformation
```

<img width="1145" height="413" alt="image" src="https://github.com/user-attachments/assets/412f41e9-bc94-4d74-b9df-de0e4d8f47ef" />



📝 Exemplo de Saída Esperada


```
==================================================
-- ARQUIVO: TCloudWatch
==================================================
-- DADOS ATUAIS:
--   Tamanho atual: 1211831 MB
--   Espaço usado: 930583 MB
--   Espaço livre: 281248 MB
--   Percentual usado: 76%
 
-- CÁLCULOS DE SEGURANÇA:
--   Margem de 10%: 93059 MB
--   TAMANHO MÍNIMO SEGURO: 1023642 MB
--   Espaço que pode liberar: 188189 MB
--   Blocos de 20GB: 9 blocos completos
 
-- COMANDOS DE SHRINK:
-- Reduzindo em blocos de 20GB:
 
-- Bloco 1: Reduzindo para 1191831 MB
DBCC SHRINKFILE(N'TCloudWatch', 1191831);
GO
 
-- Bloco 2: Reduzindo para 1171831 MB
DBCC SHRINKFILE(N'TCloudWatch', 1171831);
GO
 
[...]
 
-- COMANDO FINAL:
--   Reduzindo para tamanho mínimo seguro
--   Tamanho final: 1023642 MB
DBCC SHRINKFILE(N'TCloudWatch', 1023642);
GO
 
-- RESUMO FINAL:
--   Total de blocos: 9
--   Espaço total liberado: 188189 MB
--   Novo tamanho: 1023642 MB
--   Nova margem livre: 93059 MB
==================================================
```

📊 O que é a Margem de 10%?


É um espaço adicional de segurançaque o script mantém além do espaço realmente utilizado pelos dados.


🎯 Como Funciona na Prática:


Seus dados atuais:

- Espaço usado: 930.583 MB
- Margem de 10%: 93.058 MB
- Tamanho mínimo seguro:930.583 + 93.058 = 1.023.641 MB

⚠️ Por que a Margem é Necessária?


1. Evitar Falhas por Espaço Insuficiente


Impede que o arquivo fique tão pequeno que não haja espaço para operações normais do SQL Server


2. Permitir Crescimento Temporário


Durante operações de manutenção, índices ou transações grandes podem precisar de espaço extra


3. Prevenir Fragmentação Excessiva


Se reduzir até o limite exato do espaço usado, qualquer inserção futura causará fragmentação imediata


4. Dar Tempo para o AutoGrow


Se o auto crescimento estiver configurado, a margem dá tempo para ele funcionar sem impactar performance


📈 Exemplo com Seus Números:



```
-- Espaço usado: 930.583 MB
-- Margem de 10%: 93.058 MB  
-- TAMANHO MÍNIMO SEGURO: 1.023.641 MB ← O script não reduz abaixo disso

-- Espaço livre atual: 281.248 MB
-- Espaço que pode liberar: 1.211.831 - 1.023.641 = 188.190 MB
-- Blocos de 20GB: 188.190 / 20.000 = 9 blocos completos
```

🔄 Posso Ajustar a Margem?


Sim! Basta modificar esta linha no script:

-- Para 5% de margem:
```
SET @TargetSize = CEILING(@SpaceUsed_MB * 1.05)

-- Para 15% de margem:  
SET @TargetSize = CEILING(@SpaceUsed_MB * 1.15)

-- Para 20% de margem:
SET @TargetSize = CEILING(@SpaceUsed_MB * 1.20)
```

💡 Recomendação:


Mantenha pelo menos 10%- é um bom equilíbrio entre liberar espaço e manter a segurança do banco.

A margem é sua "rede de segurança" contra problemas operacionais! 🛡️
---

🎯 Script para gerar o Shrink Particionado


Liberar espaço em disco de forma controlada e segura, evitando impacto excessivo no desempenho do SQL Server durante operações de shrink.
- Neste exemplo está considerando 10% de margem de segurança
- E o parâmetro @GbShrink = 20GB , caso queria alterar a configuração. 
```
DECLARE @TSQL VARCHAR(MAX) = '',
        @Filename SYSNAME,
        @TotalSize_MB INT,
        @SpaceUsed_MB INT,
        @Used_Pct INT,
        @FreeSpaceMB INT,
        @GbShrink INT = 20000, -- 20GB em MB
        @CurrentSize INT,
        @TargetSize INT,
        @Counter INT = 1,
        @MarginMB INT,
        @SpaceToFreeMB INT,
        @TotalBlocks INT

DECLARE cr_looping CURSOR KEYSET FOR
SELECT [Filename], TotalSize_MB, SpaceUsed_MB, [Used (%)], FreeSpace_MB
FROM tbl_SHRINK
WHERE FileType = 'ROWS'

OPEN cr_looping
  
FETCH NEXT FROM cr_looping INTO @Filename, @TotalSize_MB, @SpaceUsed_MB, @Used_Pct, @FreeSpaceMB

WHILE @@FETCH_STATUS = 0
BEGIN
    IF (@FreeSpaceMB >= @GbShrink)
    BEGIN
        -- Cálculos detalhados
        SET @MarginMB = CEILING(@SpaceUsed_MB * 0.1)
        SET @TargetSize = @SpaceUsed_MB + @MarginMB
        SET @SpaceToFreeMB = @TotalSize_MB - @TargetSize
        SET @TotalBlocks = @SpaceToFreeMB / @GbShrink
        
        PRINT '=================================================='
        PRINT '-- ARQUIVO: ' + @Filename
        PRINT '=================================================='
        PRINT '-- DADOS ATUAIS:'
        PRINT '--   Tamanho atual: ' + CAST(@TotalSize_MB AS VARCHAR) + ' MB'
        PRINT '--   Espaço usado: ' + CAST(@SpaceUsed_MB AS VARCHAR) + ' MB'
        PRINT '--   Espaço livre: ' + CAST(@FreeSpaceMB AS VARCHAR) + ' MB'
        PRINT '--   Percentual usado: ' + CAST(@Used_Pct AS VARCHAR) + '%'
        PRINT ''
        PRINT '-- CÁLCULOS DE SEGURANÇA:'
        PRINT '--   Margem de 10%: ' + CAST(@MarginMB AS VARCHAR) + ' MB'
        PRINT '--   TAMANHO MÍNIMO SEGURO: ' + CAST(@TargetSize AS VARCHAR) + ' MB'
        PRINT '--   Espaço que pode liberar: ' + CAST(@SpaceToFreeMB AS VARCHAR) + ' MB'
        PRINT '--   Blocos de 20GB: ' + CAST(@TotalBlocks AS VARCHAR) + ' blocos completos'
        PRINT ''
        PRINT '-- COMANDOS DE SHRINK:'
        PRINT '-- Reduzindo em blocos de 20GB:'
        PRINT ''
        
        SET @CurrentSize = @TotalSize_MB
        
        WHILE (@CurrentSize - @GbShrink) >= @TargetSize
        BEGIN
            SET @CurrentSize = @CurrentSize - @GbShrink
            SET @TSQL = 'DBCC SHRINKFILE(N''' + @Filename + ''', ' + 
                        CAST(@CurrentSize AS VARCHAR) + ');'
            
            PRINT '-- Bloco ' + CAST(@Counter AS VARCHAR) + ': Reduzindo para ' + 
                  CAST(@CurrentSize AS VARCHAR) + ' MB'
            PRINT @TSQL
            PRINT 'GO'
            PRINT ''
            
            SET @Counter = @Counter + 1
        END
        
        -- Comando final para ajuste preciso
        IF @CurrentSize > @TargetSize
        BEGIN
            SET @TSQL = 'DBCC SHRINKFILE(N''' + @Filename + ''', ' + 
                        CAST(@TargetSize AS VARCHAR) + ');'
            
            PRINT '-- COMANDO FINAL:'
            PRINT '--   Reduzindo para tamanho mínimo seguro'
            PRINT '--   Tamanho final: ' + CAST(@TargetSize AS VARCHAR) + ' MB'
            PRINT @TSQL
            PRINT 'GO'
            PRINT ''
        END
        
        PRINT '-- RESUMO FINAL:'
        PRINT '--   Total de blocos: ' + CAST(@Counter - 1 AS VARCHAR)
        PRINT '--   Espaço total liberado: ' + CAST(@TotalSize_MB - @TargetSize AS VARCHAR) + ' MB'
        PRINT '--   Novo tamanho: ' + CAST(@TargetSize AS VARCHAR) + ' MB'
        PRINT '--   Nova margem livre: ' + CAST(@TargetSize - @SpaceUsed_MB AS VARCHAR) + ' MB'
        PRINT '=================================================='
        PRINT ''
    END
    ELSE
    BEGIN
        PRINT '-- Arquivo: ' + @Filename + ' - Não requer shrink'
        PRINT '-- Motivo: Espaço livre insuficiente (' + CAST(@FreeSpaceMB AS VARCHAR) + ' MB)'
        PRINT '-- Mínimo necessário: ' + CAST(@GbShrink AS VARCHAR) + ' MB'
        PRINT ''
    END
    
    SET @Counter = 1
    FETCH NEXT FROM cr_looping INTO @Filename, @TotalSize_MB, @SpaceUsed_MB, @Used_Pct, @FreeSpaceMB
END

CLOSE cr_looping
DEALLOCATE cr_looping
```

Exemplo de que o script não irá passar o shrink se a margem de segurança for atinginda. 

<img width="1143" height="392" alt="image" src="https://github.com/user-attachments/assets/f21ac918-9d3a-4b11-927c-7888dc5ea391" />

Como estava o database antes do shrink.

<img width="697" height="354" alt="image" src="https://github.com/user-attachments/assets/9edba3a1-9f98-454a-be3e-8730f714b111" />

Segue o calculo para a geração do comando de shrink, neste exemplo de acordo com a margem de segurança não irá liberar os 20Gb que foi efetuado a configuração e SIM apenas 10GB que será efetuado o shrink.
```
==================================================
-- ARQUIVO: TCloudWatch
==================================================
-- DADOS ATUAIS:
--   Tamanho atual: 1031831 MB
--   Espaço usado: 928855 MB
--   Espaço livre: 102976 MB
--   Percentual usado: 90%
 
-- CÁLCULOS DE SEGURANÇA:
--   Margem de 10%: 92886 MB
--   TAMANHO MÍNIMO SEGURO: 1021741 MB
--   Espaço que pode liberar: 10090 MB
--   Blocos de 20GB: 0 blocos completos
 
-- COMANDOS DE SHRINK:
-- Reduzindo em blocos de 20GB:
 
-- COMANDO FINAL:
--   Reduzindo para tamanho mínimo seguro
--   Tamanho final: 1021741 MB
DBCC SHRINKFILE(N'TCloudWatch', 1021741);
GO
 
-- RESUMO FINAL:
--   Total de blocos: 0
--   Espaço total liberado: 10090 MB
--   Novo tamanho: 1021741 MB
--   Nova margem livre: 92886 MB
==================================================
```

Como ficou após o shrink database, deixando assim 90Gb de espaço livre no database como espaço de segurança.

<img width="700" height="357" alt="image" src="https://github.com/user-attachments/assets/fbbc138e-85b6-49a7-b5c6-6136c1187504" />

