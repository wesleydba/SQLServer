SELECT
    DB_NAME() AS [Database Name]
        , sysobjects.type
        , sysobjects.name AS trigger_name
    --USER_NAME(sysobjects.uid) AS trigger_owner
    --s.name AS table_schema
    , OBJECT_NAME(parent_obj) AS table_name
    , OBJECTPROPERTY( id, 'ExecIsUpdateTrigger') AS isupdate
    , OBJECTPROPERTY( id, 'ExecIsDeleteTrigger') AS isdelete
    , OBJECTPROPERTY( id, 'ExecIsInsertTrigger') AS isinsert
    , OBJECTPROPERTY( id, 'ExecIsAfterTrigger') AS isafter
    , OBJECTPROPERTY( id, 'ExecIsInsteadOfTrigger') AS isinsteadof
    , OBJECTPROPERTY(id, 'ExecIsTriggerDisabled') AS [Status]
FROM sysobjects
    INNER JOIN sys.tables t
    ON sysobjects.parent_obj = t.object_id
    INNER JOIN sys.schemas s
    ON t.schema_id = s.schema_id
WHERE sysobjects.type = 'TR'