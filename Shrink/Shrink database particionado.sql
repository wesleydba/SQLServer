-- SHRINK DE FILES PARTICIONADO / SHRINK PARTICIONADO
--Single Database
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


---- Script que irá gerar o shrink
declare @Target int,
        @TSQL varchar(max) = '',
        @Filename sysname,
        @TotalSize_Mb int,
        @SpaceUsed_Mb int,
        @Used_Pct int
declare cr_looping cursor keyset for
select [Filename], TotalSize_MB, SpaceUsed_MB, [Used (%)]
from tbl_SHRINK
where FileType = 'ROWS'
open cr_looping

fetch first from cr_looping into @Filename, @TotalSize_Mb, @SpaceUsed_Mb, @Used_Pct
while @@FETCH_STATUS = 0
begin

    if (@Used_Pct < 80) and (@TotalSize_Mb - @SpaceUsed_Mb >= 5000)
     begin

        set @Target = @TotalSize_Mb
        while @Target >=  (@SpaceUsed_Mb + @SpaceUsed_Mb * 0.3) + 5000
         begin

            set @TSQL = 'DBCC SHRINKFILE(''' + @Filename + ''',' + cast(@Target - 1000 as varchar) + ')' + CHAR(13)+CHAR(10) + 'GO'
            set @Target = @Target - 1000
            print @TSQL

        end
    --while

    end
    --if
    fetch next from cr_looping into @Filename, @TotalSize_Mb, @SpaceUsed_Mb, @Used_Pct
end
close cr_looping
deallocate cr_looping