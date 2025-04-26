USE StackOverflow2010

DROP INDEX IF EXISTS IX1 ON dbo.Users


CREATE INDEX IX1 ON dbo.Users (CREATIONDATE,reputation)
include (Displayname)
with (fillfactor=100)
-- ESPACIO
sp_spaceused 'dbo.Users'

--ALOCACION
select 
Coalesce(Object_Schema_Name(indexes.object_id) + '.', '')
       + Coalesce(Object_Name(indexes.object_id) + '/', '')
       + Coalesce(indexes.name, 'Heap'), 
  Str(avg_fragmentation_in_percent, 10,1) AS [avg_fragmentation_%],
  Str(avg_page_space_used_in_percent, 10,1) AS [avg_page_space_used_%],
  fill_factor,
  Str((avg_record_size_in_bytes * record_count) / (1024.0 * 1024), 10,2) AS [IndexSize_(MB)],
  D.page_count
from sys.dm_db_index_physical_stats(db_id(),
object_id(N'dbo.USERS'),null,null,'SAMPLED') as d
INNER JOIN sys.indexes
 ON indexes.index_id = D.index_id AND indexes.object_id = D.object_id
 WHERE 
  --ObjectProperty(indexes.object_id, 'DBO.TEST1') = 1 AND 
  index_level=0 --leaf level 
  and indexes.name in('IX1')
  and alloc_unit_type_desc = 'IN_ROW_DATA'

-- OCUPACION EN RAM
SELECT fg.name AS [Filegroup Name], 
SCHEMA_NAME(o.schema_id) AS [Schema Name],
OBJECT_NAME(p.[object_id]) AS [Object Name], 
I.name, 
p.index_id, 
CAST(COUNT(*)/128.0 AS DECIMAL(10, 2)) AS [Buffer size(MB)],  
COUNT(*) AS [BufferCount], p.[rows] AS [Row Count],
p.data_compression_desc AS [Compression Type]
FROM sys.allocation_units AS a WITH (NOLOCK)
INNER JOIN sys.dm_os_buffer_descriptors AS b WITH (NOLOCK)
ON a.allocation_unit_id = b.allocation_unit_id
INNER JOIN sys.partitions AS p WITH (NOLOCK)
ON a.container_id = p.hobt_id
INNER JOIN sys.objects AS o WITH (NOLOCK)
ON p.object_id = o.object_id
INNER JOIN sys.database_files AS f WITH (NOLOCK)
ON b.file_id = f.file_id
INNER JOIN sys.filegroups AS fg WITH (NOLOCK)
ON f.data_space_id = fg.data_space_id
INNER JOIN SYS.indexes I
ON I.index_id = p.index_id
AND I.object_id = P.object_id 
WHERE b.database_id = CONVERT(int, DB_ID())
AND OBJECT_NAME(p.[object_id]) ='Users'
AND I.NAME='IX1'
GROUP BY fg.name, o.schema_id, p.[object_id], p.index_id, 
         p.data_compression_desc, p.[rows],I.name 
ORDER BY [BufferCount] DESC OPTION (RECOMPILE);


ALTER INDEX IX1 ON DBO.USERS REBUILD WITH (FILLFACTOR=50)

sp_spaceused 'dbo.Users'

--ALOCACION
select 
Coalesce(Object_Schema_Name(indexes.object_id) + '.', '')
       + Coalesce(Object_Name(indexes.object_id) + '/', '')
       + Coalesce(indexes.name, 'Heap'), 
  Str(avg_fragmentation_in_percent, 10,1) AS [avg_fragmentation_%],
  Str(avg_page_space_used_in_percent, 10,1) AS [avg_page_space_used_%],
  fill_factor,
  Str((avg_record_size_in_bytes * record_count) / (1024.0 * 1024), 10,2) AS [IndexSize_(MB)],
  D.page_count
from sys.dm_db_index_physical_stats(db_id(),
object_id(N'dbo.USERS'),null,null,'SAMPLED') as d
INNER JOIN sys.indexes
 ON indexes.index_id = D.index_id AND indexes.object_id = D.object_id
 WHERE 
  --ObjectProperty(indexes.object_id, 'DBO.TEST1') = 1 AND 
  index_level=0 --leaf level 
  and indexes.name in('IX1')
  and alloc_unit_type_desc = 'IN_ROW_DATA'

-- OCUPACION EN RAM
SELECT fg.name AS [Filegroup Name], 
SCHEMA_NAME(o.schema_id) AS [Schema Name],
OBJECT_NAME(p.[object_id]) AS [Object Name], 
I.name, 
p.index_id, 
CAST(COUNT(*)/128.0 AS DECIMAL(10, 2)) AS [Buffer size(MB)],  
COUNT(*) AS [BufferCount], p.[rows] AS [Row Count],
p.data_compression_desc AS [Compression Type]
FROM sys.allocation_units AS a WITH (NOLOCK)
INNER JOIN sys.dm_os_buffer_descriptors AS b WITH (NOLOCK)
ON a.allocation_unit_id = b.allocation_unit_id
INNER JOIN sys.partitions AS p WITH (NOLOCK)
ON a.container_id = p.hobt_id
INNER JOIN sys.objects AS o WITH (NOLOCK)
ON p.object_id = o.object_id
INNER JOIN sys.database_files AS f WITH (NOLOCK)
ON b.file_id = f.file_id
INNER JOIN sys.filegroups AS fg WITH (NOLOCK)
ON f.data_space_id = fg.data_space_id
INNER JOIN SYS.indexes I
ON I.index_id = p.index_id
AND I.object_id = P.object_id 
WHERE b.database_id = CONVERT(int, DB_ID())
AND OBJECT_NAME(p.[object_id]) ='Users'
AND I.NAME='IX1'
GROUP BY fg.name, o.schema_id, p.[object_id], p.index_id, 
         p.data_compression_desc, p.[rows],I.name 
ORDER BY [BufferCount] DESC OPTION (RECOMPILE);

-- VOLVEMOS A 100

ALTER INDEX IX1 ON DBO.USERS REBUILD WITH (FILLFACTOR=100)


SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT Id, DisplayName 
FROM dbo.Users
WHERE CreationDate >= '20100101'
AND Reputation > 6000

SET STATISTICS TIME OFF
SET STATISTICS IO OFF


ALTER INDEX IX1 ON DBO.USERS REBUILD WITH (FILLFACTOR=90)

SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT Id, DisplayName 
FROM dbo.Users
WHERE CreationDate >= '20100101'
AND Reputation > 6000

SET STATISTICS TIME OFF
SET STATISTICS IO OFF


ALTER INDEX IX1 ON DBO.USERS REBUILD WITH (FILLFACTOR=80)

ALTER INDEX IX1 ON DBO.USERS REBUILD WITH (FILLFACTOR=50)

ALTER INDEX IX1 ON DBO.USERS REBUILD WITH (FILLFACTOR=20)

ALTER INDEX IX1 ON DBO.USERS REBUILD WITH (FILLFACTOR=1)

select 
Coalesce(Object_Schema_Name(indexes.object_id) + '.', '')
       + Coalesce(Object_Name(indexes.object_id) + '/', '')
       + Coalesce(indexes.name, 'Heap'), 
  Str(avg_fragmentation_in_percent, 10,1) AS [avg_fragmentation_%],
  Str(avg_page_space_used_in_percent, 10,1) AS [avg_page_space_used_%],
  fill_factor,
  Str((avg_record_size_in_bytes * record_count) / (1024.0 * 1024), 10,2) AS [IndexSize_(MB)]
from sys.dm_db_index_physical_stats(db_id(),
object_id(N'dbo.USERS'),null,null,'SAMPLED') as d
INNER JOIN sys.indexes
 ON indexes.index_id = D.index_id AND indexes.object_id = D.object_id
 WHERE 
  --ObjectProperty(indexes.object_id, 'DBO.TEST1') = 1 AND 
  index_level=0 --leaf level 
  and indexes.name in('IX1','pk_users_id')
  and alloc_unit_type_desc = 'IN_ROW_DATA'

-- stress 200 20
-- 5% 34 / 22006 reada
-- 100% 24 / 1118

SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT Id, DisplayName 
FROM dbo.Users
WHERE CreationDate >= '20100101'
AND Reputation > 6000


-------------------
--- espacio en ram

-- Note: This query could take some time on a busy instance

-- insert
-- 5000/1

-- 26s todo 5%
-- 26s


INSERT INTO [dbo].[Users]
           ([AboutMe]
           ,[Age]
           ,[CreationDate]
           ,[DisplayName]
           ,[DownVotes]
           ,[EmailHash]
           ,[LastAccessDate]
           ,[Location]
           ,[Reputation]
           ,[UpVotes]
           ,[Views]
           ,[WebsiteUrl]
           ,[AccountId])
     VALUES
           ('SQL SERVER EXPERT'
           ,47
           ,DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 366), '2025-01-01')
           ,'MAXIACCOTTO'
           ,0
           ,'MAXI.ACCOTTO@GMAIL.COM'
           ,'20250101'
           ,'argentina'
           ,8000
           ,8000
           ,8000
           ,'www.triggerdb.com'
           ,1)
GO

delete Users 
where [CreationDate] > '20250101'