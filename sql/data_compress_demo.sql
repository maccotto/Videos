-- Data Compression

use AdventureWorks2022 
go

-- creamos tabla
DROP TABLE IF EXISTS DBO.BigSalesOrderDetail

SELECT TOP 1000000 
D.* INTO dbo.BigSalesOrderDetail
FROM Sales.SalesOrderDetail D
CROSS JOIN sys.columns ;

CREATE CLUSTERED INDEX CI ON dbo.BigSalesOrderDetail(SalesOrderID)

CREATE INDEX IX1 ON dbo.BigSalesOrderDetail (PRODUCTID)

DECLARE @CANTIDAD INT = 0

WHILE @CANTIDAD <= 24000000
BEGIN

INSERT INTO [dbo].[BigSalesOrderDetail]
           (SalesOrderID, 
		   SalesOrderDetailID ,
            [CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[LineTotal]
           ,[rowguid]
           ,[ModifiedDate])
select TOP 1000000
            SalesOrderID ,
			SalesOrderDetailID ,
            CarrierTrackingNumber
           ,OrderQty
           ,ProductID
           ,SpecialOfferID
           ,UnitPrice
           ,UnitPriceDiscount
           ,LineTotal
           ,rowguid
           ,ModifiedDate
FROM Sales.SalesOrderDetail D
CROSS JOIN sys.columns ;

SELECT @CANTIDAD = COUNT(1) FROM dbo.BigSalesOrderDetail 

END


--- creamos tablas comprimidas

DROP TABLE IF EXISTS DBO.BigSalesOrderDetail_page
DROP TABLE IF EXISTS DBO.BigSalesOrderDetail_row

-- creamos dos tablas iguales para luego comprimir
SELECT 
* INTO dbo.BigSalesOrderDetail_page
FROM dbo.BigSalesOrderDetail 

SELECT 
* INTO dbo.BigSalesOrderDetail_row
FROM dbo.BigSalesOrderDetail 


CREATE CLUSTERED INDEX CI ON dbo.BigSalesOrderDetail_page(SalesOrderID)
CREATE INDEX IX1 ON dbo.BigSalesOrderDetail_page(PRODUCTID)

CREATE CLUSTERED INDEX CI ON dbo.BigSalesOrderDetail_row(SalesOrderID)
CREATE INDEX IX1 ON dbo.BigSalesOrderDetail_row(PRODUCTID)


-- espacios

exec sp_spaceused 'BigSalesOrderDetail'
exec sp_spaceused 'BigSalesOrderDetail_row'
exec sp_spaceused 'BigSalesOrderDetail_page'


-- comprimimos en page

ALTER TABLE [dbo].[BigSalesOrderDetail_page] 
REBUILD PARTITION = ALL
WITH
(DATA_COMPRESSION = PAGE
)

ALTER INDEX [IX1] 
ON [dbo].[BigSalesOrderDetail_page] 
REBUILD PARTITION = ALL WITH 
(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, 
ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, 
DATA_COMPRESSION = PAGE)


-- comprimimos en row
ALTER TABLE [dbo].[BigSalesOrderDetail_row] 
REBUILD PARTITION = ALL
WITH
(DATA_COMPRESSION = row
)

ALTER INDEX [IX1] 
ON [dbo].[BigSalesOrderDetail_row] 
REBUILD PARTITION = ALL WITH 
(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, 
ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, 
DATA_COMPRESSION = row)


----------------------
--- demos
-----------------------

-- espacios

exec sp_spaceused 'BigSalesOrderDetail'
exec sp_spaceused 'BigSalesOrderDetail_row'
exec sp_spaceused 'BigSalesOrderDetail_page'

SELECT 
OBJECT_NAME(p.object_id) AS [Table Name],
CAST(SUM(ps.reserved_page_count) * 8.0 / 1024 AS DECIMAL(19,2)) AS [Object Size (MB)],
SUM(p.rows) AS [Row Count], 
p.data_compression_desc AS [Compression Type]
FROM sys.objects AS o WITH (NOLOCK)
INNER JOIN sys.partitions AS p WITH (NOLOCK)
ON p.object_id = o.object_id
INNER JOIN sys.dm_db_partition_stats AS ps WITH (NOLOCK)
ON p.object_id = ps.object_id
WHERE ps.index_id < 2 -- ignore the partitions from the non-clustered indexes if any
AND p.index_id < 2    -- ignore the partitions from the non-clustered indexes if any
AND o.type_desc = N'USER_TABLE'
and OBJECT_NAME(p.object_id) in ('BigSalesOrderDetail','BigSalesOrderDetail_row','BigSalesOrderDetail_page')
GROUP BY  SCHEMA_NAME(o.schema_id), 
p.object_id, ps.reserved_page_count, p.data_compression_desc


-- table scan

select * from BigSalesOrderDetail
select * from BigSalesOrderDetail_row
select * from BigSalesOrderDetail_page

select count(*) from BigSalesOrderDetail
select count(*) from BigSalesOrderDetail_row
select count(*) from BigSalesOrderDetail_page

update top(1000000) BigSalesOrderDetail set OrderQty = OrderQty * 2
update top(1000000) BigSalesOrderDetail_row set OrderQty = OrderQty * 2
update top(1000000) BigSalesOrderDetail_page set OrderQty = OrderQty * 2

DELETE TOP (1000000) FROM BigSalesOrderDetail
DELETE TOP (1000000) FROM BigSalesOrderDetail_row
DELETE TOP (1000000) FROM BigSalesOrderDetail_PAGE


SELECT TOP 1000000 C.*
INTO #T
FROM SYS.COLUMNS C CROSS JOIN SYS.OBJECTS O


INSERT INTO dbo.BigSalesOrderDetail 
(SalesOrderID, 
 SalesOrderDetailID, 
 CarrierTrackingNumber, 
 OrderQty, 
 ProductID, 
 SpecialOfferID, 
 UnitPrice, 
 UnitPriceDiscount, 
 LineTotal, 
 rowguid, 
 ModifiedDate)
SELECT 
43659, 1, 'triggerdb.com', 1, 776, 1, 2024.9940, 0, 100, NEWID(), GETDATE()
FROM #T 


INSERT INTO dbo.BigSalesOrderDetail_ROW 
(SalesOrderID, 
 SalesOrderDetailID, 
 CarrierTrackingNumber, 
 OrderQty, 
 ProductID, 
 SpecialOfferID, 
 UnitPrice, 
 UnitPriceDiscount, 
 LineTotal, 
 rowguid, 
 ModifiedDate)
SELECT 
43659, 1, 'triggerdb.com', 1, 776, 1, 2024.9940, 0, 100, NEWID(), GETDATE()
FROM #T 

INSERT INTO dbo.BigSalesOrderDetail_PAGE 
(SalesOrderID, 
 SalesOrderDetailID, 
 CarrierTrackingNumber, 
 OrderQty, 
 ProductID, 
 SpecialOfferID, 
 UnitPrice, 
 UnitPriceDiscount, 
 LineTotal, 
 rowguid, 
 ModifiedDate)
SELECT TOP 1000000
43659, 1, 'triggerdb.com', 1, 776, 1, 2024.9940, 0, 100, NEWID(), GETDATE()
FROM #T

