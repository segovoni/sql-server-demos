------------------------------------------------------------------------
-- Event:        DATA SATURDAY #20 - Pordenone 2022                    -
--               http://datasaturdays.com/2022-02-26-datasaturday0020/ -
-- Session:      T-SQL magic tricks!                                   -
--                                                                     -
-- Demo:         Search ARGument predicate and NULLs                   -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [WideWorldImporters];
GO


SELECT
  PurchaseOrderID, ExpectedDeliveryDate
FROM
  Purchasing.PurchaseOrders
ORDER BY
  ExpectedDeliveryDate;
GO


SELECT
  PurchaseOrderID, ExpectedDeliveryDate
FROM
  Purchasing.PurchaseOrders
ORDER BY
  CASE
    WHEN (ExpectedDeliveryDate IS NOT NULL) THEN 0 ELSE 1
  END;
GO

SELECT
  PurchaseOrderID, ExpectedDeliveryDate, SortOrder = 0
FROM
  Purchasing.PurchaseOrders
WHERE
  ExpectedDeliveryDate IS NOT NULL
UNION ALL
SELECT
  PurchaseOrderID, ExpectedDeliveryDate, SortOrder = 1
FROM
  Purchasing.PurchaseOrders
WHERE
  ExpectedDeliveryDate IS NULL
ORDER BY
  SortOrder, ExpectedDeliveryDate;
GO


CREATE PROCEDURE Purchasing.sp_undefined_deliverydate
(@DeliveryDate Date)
AS BEGIN
  SELECT
    PurchaseOrderID, ExpectedDeliveryDate
  FROM
    Purchasing.PurchaseOrders
  WHERE
    ExpectedDeliveryDate = @DeliveryDate;
END;
GO

EXEC Purchasing.sp_undefined_deliverydate @DeliveryDate = NULL;
GO

ALTER PROCEDURE Purchasing.sp_undefined_deliverydate
(@DeliveryDate Date)
AS BEGIN
  SELECT
    PurchaseOrderID, ExpectedDeliveryDate
  FROM
    Purchasing.PurchaseOrders
  WHERE
    ISNULL(ExpectedDeliveryDate, '99991231') = ISNULL(@DeliveryDate, '99991231');
END;
GO

EXEC Purchasing.sp_undefined_deliverydate @DeliveryDate = NULL;
GO

CREATE OR ALTER PROCEDURE Purchasing.sp_undefined_deliverydate
(@DeliveryDate Date)
AS BEGIN
  SELECT
    PurchaseOrderID, ExpectedDeliveryDate
  FROM
    Purchasing.PurchaseOrders
  WHERE
    (ExpectedDeliveryDate = @DeliveryDate)
    OR (ExpectedDeliveryDate IS NULL AND @DeliveryDate IS NULL);
END;
GO

EXEC Purchasing.sp_undefined_deliverydate @DeliveryDate = NULL;
GO

ALTER PROCEDURE Purchasing.sp_undefined_deliverydate
(@DeliveryDate Date)
AS BEGIN
  SELECT
    PurchaseOrderID, ExpectedDeliveryDate
  FROM
    Purchasing.PurchaseOrders
  WHERE
    EXISTS(SELECT ExpectedDeliveryDate INTERSECT SELECT @DeliveryDate);
END;
GO

EXEC Purchasing.sp_undefined_deliverydate @DeliveryDate = NULL;
GO

--DECLARE @DeliveryDate Date = NULL

--SELECT PurchaseOrderID, ExpectedDeliveryDate
--FROM Purchasing.PurchaseOrders
--WHERE EXISTS(SELECT ExpectedDeliveryDate INTERSECT SELECT @DeliveryDate);


SELECT * FROM Warehouse.StockItems;
GO


-- SARGable
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  StockItemID = 104;
GO


-- SARGable?
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  StockItemID + 1 = 104;
GO


-- SARGable?
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  StockItemID = (105 - 1);
GO


-- SARGable?
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  StockItemID + 0 = 104;
GO



-- SARGable
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  StockItemName = 'DBA joke mug - it depends (Black)';
GO


-- NON SARGable
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  UPPER(StockItemName) = UPPER('DBA joke mug - it depends (Black)');
GO


-- NON SARGable
SELECT
  COUNT(*)
FROM
  Warehouse.StockItems
WHERE
  LEFT(StockItemName, 3) = 'DBA';
GO


-- NON SARGable
SELECT
  COUNT(*)
FROM
  Warehouse.StockItems
WHERE
  YEAR(ValidFrom) = YEAR(GETDATE());
GO


/*
SELECT DATEDIFF(yy, 0, GETDATE());
SELECT DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
SELECT DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, 0)
*/


-- SARGable
SELECT
  COUNT(*)
FROM
  Warehouse.StockItems
WHERE
  ValidFrom >= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
	AND ValidFrom < DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, 0);
GO


-- SARGable?? 
SELECT
  COUNT(*)
FROM
  Warehouse.StockItems
WHERE
  StockItemName LIKE 'DBA%';
GO


-- NON SARGable
SELECT
  COUNT(*)
FROM
  Warehouse.StockItems
WHERE
  ISNULL(Size, 'M') = 'M';
GO


-- SARGable
SELECT
  COUNT(*)
FROM
  Warehouse.StockItems
WHERE
  (Size = 'M') OR (Size IS NULL);
GO