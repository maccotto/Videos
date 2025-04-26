SELECT * FROM SYS.DM_EXEC_SESSIONS 
WHERE PROGRAM_NAME IS NOT NULL
AND SESSION_ID <> @@SPID 


USE [master]
GO
CREATE LOGIN [DEMOAPP] WITH PASSWORD=N'12345678', 
DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO



-- CREAMOS UN TRIGGER DDL LOGON 

CREATE TRIGGER [connection_limit_trigger]
ON ALL SERVER 
FOR LOGON
AS 

 set nocount on 

-- con este trigger que el login DemoApp solo pueda ser usado desde nuestra app

 BEGIN
 IF SUSER_SNAME() = 'DEMOAPP' and APP_NAME() <> 'Miaplicacion'
    ROLLBACK;
 END;
 GO 

GO 

SET QUOTED_IDENTIFIER OFF
GO 

ENABLE TRIGGER [connection_limit_trigger] ON ALL SERVER
GO 

DISABLE TRIGGER [connection_limit_trigger] ON ALL SERVER



