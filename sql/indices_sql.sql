
SELECT SalesOrderDetailID, OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID = 897;
 

SELECT SalesOrderDetailID, OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID +1  = 898;

SELECT SalesOrderDetailID, OrderQty
FROM Sales.SalesOrderDetail
WHERE upper(ProductID) = '897';


 
SELECT SalesOrderDetailID, OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID = 870;

SELECT SalesOrderDetailID, OrderQty
FROM Sales.SalesOrderDetail
WITH (INDEX=ix_salesorderdetail_productid)
WHERE ProductID = 870;