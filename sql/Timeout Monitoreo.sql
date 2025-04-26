-- query store moniroting Timeout
ALTER DATABASE [AdventureWorksDW2016_EXT]
SET QUERY_STORE = ON
    (
      OPERATION_MODE = READ_WRITE,
      CLEANUP_POLICY = ( STALE_QUERY_THRESHOLD_DAYS = 90 ),
      DATA_FLUSH_INTERVAL_SECONDS = 900,
      MAX_STORAGE_SIZE_MB = 1024,
      INTERVAL_LENGTH_MINUTES = 60,
      SIZE_BASED_CLEANUP_MODE = AUTO,
      MAX_PLANS_PER_QUERY = 200,
      QUERY_CAPTURE_MODE = ALL
    );
use AdventureWorksDW2016_EXT 
go

BEGIN TRAN
 DECLARE @OnlineSalesKey INT
 select * from FactResellerSalesXL WITH (UPDLOCK)

rollback tran 


-- ponemos en 5 segundos el timeput y en otra sesion corremos
use AdventureWorksDW2016_EXT 
go
select * from FactResellerSalesXL 


-- buscamos el timeput en la base
use AdventureWorksDW2016_EXT 
SELECT
 qst.query_sql_text,
 qrs.execution_type,
 qrs.execution_type_desc,
 qpx.query_plan_xml,
 qrs.count_executions,
 qrs.last_execution_time
FROM sys.query_store_query AS qsq
JOIN sys.query_store_plan AS qsp on qsq.query_id=qsp.query_id
JOIN sys.query_store_query_text AS qst on qsq.query_text_id=qst.query_text_id
OUTER APPLY (SELECT TRY_CONVERT(XML, qsp.query_plan) AS query_plan_xml) AS qpx
JOIN sys.query_store_runtime_stats qrs on qsp.plan_id = qrs.plan_id
WHERE qrs.execution_type =3
ORDER BY qrs.last_execution_time DESC;
GO
----------------------------------------------------------
-------------------- con extended event
-----------------------------------------------------------


CREATE EVENT SESSION [triggerdb_timeout] ON SERVER
ADD EVENT sqlserver.attention(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,
      sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.server_principal_name,
      sqlserver.sql_text,sqlserver.username))
ADD TARGET package0.asynchronous_file_target
(SET filename = N'timeout.xel',
     metadatafile = N'timeout.xem',
     max_file_size=(65536),
     max_rollover_files=5)
WITH (MAX_MEMORY = 4096KB, 
      EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS, 
	  MAX_DISPATCH_LATENCY = 30 SECONDS, 
	  MAX_EVENT_SIZE = 0KB, MEMORY_PARTITION_MODE = NONE, 
	  TRACK_CAUSALITY = OFF, STARTUP_STATE = ON) 
	  

GO

ALTER EVENT SESSION [TRIGGERDB_timeout] ON SERVER STATE = START 

-- generamos timeout

use AdventureWorksDW2016_EXT 
go

BEGIN TRAN
 DECLARE @OnlineSalesKey INT
 select * from FactResellerSalesXL WITH (UPDLOCK)

rollback tran 


-- ponemos en 5 segundos el timeput y en otra sesion corremos
use AdventureWorksDW2016_EXT 
go
select * from FactResellerSalesXL 


-- ver timeout

with qry as (
select
theNodes.event_data.value('(action[@name="database_name"]/value)[1]','varchar(50)')
           as database_name,
theNodes.event_data.value('(action[@name="client_hostname"]/value)[1]','varchar(50)')
           as client_hostname,
theNodes.event_data.value('(action[@name="client_app_name"]/value)[1]','varchar(50)')
           as client_app_name,
theNodes.event_data.value('(data[@name="duration"]/value)[1]','bigint') as duration,
theNodes.event_data.value('(action[@name="sql_text"]/value)[1]','varchar(4000)') as sql_text,
theNodes.event_data.value('(action[@name="user_name"]/value)[1]','varchar(50)') as user_name,
theNodes.event_data.value('(action[@name="is_system"]/value)[1]','varchar(50)') as is_system,
theNodes.event_data.value('(action[@name="nt_user_name"]/value)[1]','varchar(50)')
           as nt_user_name,
theNodes.event_data.value('(action[@name="server_principal_name"]/value)[1]','varchar(50)')
           as server_principal_name,
DATEADD(mi,
    DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP),
    theNodes.event_data.value('(@timestamp)[1]', 'datetime2')) AS [event time] 
from
      (select convert(xml,event_data) event_data
            from
       sys.fn_xe_file_target_read_file('timeout_*.xel', 'timeout.xem', NULL, NULL)) as theData
cross apply theData.event_data.nodes('//event') theNodes(event_data)
       )
select  * FROM QRY      
order by [event time] desc
