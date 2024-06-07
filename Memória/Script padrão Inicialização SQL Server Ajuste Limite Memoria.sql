-- Configuração edge

--Script Padrão Inicialização SQL Server | Ajuste Limite Memória

declare 
    @PhysicalMemory_MB int,
    @MinServerMemory smallint = 2048,
    @MaxServerMemory int


SELECT
    @PhysicalMemory_MB = physical_memory_kb/1024
FROM [sys].[dm_os_sys_info]

select @MaxServerMemory = case    
        when (@PhysicalMemory_MB = 8192) then (@PhysicalMemory_MB - 4096) --8GB
        when (@PhysicalMemory_MB > 8192 and @PhysicalMemory_MB <= 12288) then (@PhysicalMemory_MB - 4096) --between 8GB and 12GB
        when (@PhysicalMemory_MB > 12288 and @PhysicalMemory_MB <= 16384) then (@PhysicalMemory_MB - 6144) --between 12GB and 16GB
        when (@PhysicalMemory_MB > 16384 and @PhysicalMemory_MB <= 24576) then (@PhysicalMemory_MB - 8192) --between 16GB and 24GB
        when (@PhysicalMemory_MB > 24576 and @PhysicalMemory_MB <= 32768) then (@PhysicalMemory_MB - 10240) --between 24GB and 32GB
        when (@PhysicalMemory_MB > 32768 and @PhysicalMemory_MB <= 65536) then (@PhysicalMemory_MB - 12288) --between 32GB and 64GB
        when (@PhysicalMemory_MB > 65536 and @PhysicalMemory_MB <= 98304) then (@PhysicalMemory_MB - 16384) --between 64GB and 96GB
        when (@PhysicalMemory_MB > 98304 and @PhysicalMemory_MB <= 131072) then (@PhysicalMemory_MB - 20480) --between 96GB and 128GB
        when (@PhysicalMemory_MB > 131072) then (@PhysicalMemory_MB - (@PhysicalMemory_MB * 15 / 100)) -- >128GB
    end

EXEC sys.sp_configure N'show advanced options', N'1'
RECONFIGURE WITH OVERRIDE
EXEC sys.sp_configure N'min server memory (MB)', @MinServerMemory
EXEC sys.sp_configure N'max server memory (MB)' ,@MaxServerMemory
RECONFIGURE WITH OVERRIDE;
EXEC sys.sp_configure N'show advanced options', N'0'
RECONFIGURE WITH OVERRIDE
GO