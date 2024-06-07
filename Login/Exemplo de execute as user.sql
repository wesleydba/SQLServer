execute as user ='wesley'
select count(*) from AA3010
SELECT
    ORIGINAL_LOGIN() AS [ORIGINAL_LOGIN],
    USER_NAME() AS [USER_NAME],
    SUSER_NAME() AS [SUSER_NAME],
    SUSER_SNAME() AS [SUSER_SNAME],
    SYSTEM_USER AS [SYSTEM_USER],
    IS_SRVROLEMEMBER('sysadmin') AS [isSysAdmin]