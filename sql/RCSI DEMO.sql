-- SQL RCSI

-- READ COMMITTED

USE AdventureWorks2019 
GO

SELECT COLOR FROM PRODUCTION.Product 
WHERE ProductID =1

-- DEMO 1
BEGIN TRANSACTION
 UPDATE PRODUCTION.Product 
 SET COLOR='RED'

 -- EN OTRA VENTANA
USE AdventureWorks2019 
GO
SELECT COLOR FROM PRODUCTION.Product 
WHERE ProductID =1

SELECT COLOR FROM PRODUCTION.Product (NOLOCK)
WHERE ProductID =1

ROLLBACK TRAN

-- USANDO RCSI
USE [master]
GO
ALTER DATABASE [AdventureWorks2019] SET READ_COMMITTED_SNAPSHOT ON 
WITH ROLLBACK IMMEDIATE

-- REPEMIIMOS DEMO
-- DEMO 1
USE AdventureWorks2019 
GO

BEGIN TRANSACTION
 UPDATE PRODUCTION.Product 
 SET COLOR='RED'

 -- EN OTRA VENTANA
USE AdventureWorks2019 
GO
SELECT COLOR FROM PRODUCTION.Product 
WHERE ProductID =1

SELECT COLOR FROM PRODUCTION.Product (NOLOCK)
WHERE ProductID =1

-- MONITOREO TEMPDB
USE tempdb
  
SELECT SUM (version_store_reserved_page_count) AS Version_Store_Reserved,
SUM (user_object_reserved_page_count) AS User_Object_Reserverd,
SUM (internal_object_reserved_page_count) AS Internal_Object_Reserved,
SUM (mixed_extent_page_count) AS Mixed_Extent
FROM sys.dm_db_file_space_usage

ROLLBACK TRAN
