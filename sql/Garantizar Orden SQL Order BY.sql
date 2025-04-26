USE AdventureWorks2022 
GO

--- GARANTIZAR O

sp_helpindex 'production.product'

SELECT ProductID, 
       [Name],
       [ProductNumber]
FROM [Production].[Product]

DROP INDEX IF EXISTS IX1 ON [Production].[Product]

create index 
ix1 on [Production].[Product] (name,productnumber)

SELECT ProductID, 
       [Name],
       [ProductNumber]
FROM [Production].[Product]

SELECT ProductID, 
       [Name],
       [ProductNumber]
FROM [Production].[Product]
ORDER BY ProductID 

SELECT *
FROM [Production].[Product]
where name like 'Chain%'

SELECT *
FROM [Production].[Product]
where name like 'Chain%'
ORDER BY  productnumber 

SELECT *
FROM [Production].[Product]
where name like 'Chain%'
ORDER BY ProductID   

SELECT ProductID, 
       [Name],
       [ProductNumber]
FROM [Production].[Product]
where color= 'Red'

SELECT ProductID, 
       [Name],
       [ProductNumber]
FROM [Production].[Product]
where color= 'Red'

--- demo clustered no seq
DROP TABLE IF EXISTS DBO.PRODUCTOS_2

SELECT 
NEWID() AS PK1,
* 
INTO  DBO.PRODUCTOS_2
FROM PRODUCTION.Product 


CREATE CLUSTERED INDEX CI ON  DBO.PRODUCTOS_2(PK1)

create index 
ix2 on [DBO].[ProductOS_2] (name,productnumber,PRODUCTID)

SELECT PK1,
       ProductID, 
       [Name],
       [ProductNumber]
FROM [DBO].[ProductOS_2]

SELECT PK1,
       ProductID, 
       [Name],
       [ProductNumber]
FROM [DBO].[ProductOS_2]
ORDER BY ProductID 