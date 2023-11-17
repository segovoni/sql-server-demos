------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2023 - November 18               --
--               https://bit.ly/3tKmyMM                               --
--                                                                    --
-- Session:      T-SQL performance tips & tricks!                     --
--                                                                    --
-- Demo:         Sargable predicates and NULLs                        --
--               https://bit.ly/3F2iOb0                               --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [WideWorldImporters];
GO


-- Wikipedia (https://en.wikipedia.org/wiki/Sargable)

-- A condition (or predicate) in a query is said to be sargable
-- if the DBMS engine can take advantage of an index to speed up the
-- execution of the query

-- The term is derived from a contraction of Search ARGument ABLE

-- One of the steps in query optimization is to convert predicates
-- to be sargable


-- SARGable
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  -- This predicate can be evaluated/executed using a Seek
  (StockItemID = 104);
GO


-- Non-SARGable query
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  -- This predicate can NOT be evaluated/executed using a Seek
  (StockItemID + 1 = 104);
GO


-- ?
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  StockItemID = (105 - 1);
GO


-- ? :)
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  StockItemID + 0 = 104;
GO



-- Consider this query on PurchaseOrders
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
    -- Is this predicate sargable or not?
    -- Can we relying on the index on ExpectedDeliveryDate?
    WHEN (ExpectedDeliveryDate IS NOT NULL) THEN 0 ELSE 1
  END;
GO


SELECT
  PurchaseOrderID, ExpectedDeliveryDate, 0 AS SortOrder
FROM
  Purchasing.PurchaseOrders
WHERE
  ExpectedDeliveryDate IS NOT NULL
UNION ALL
SELECT
  PurchaseOrderID, ExpectedDeliveryDate, 1 AS SortOrder
FROM
  Purchasing.PurchaseOrders
WHERE
  ExpectedDeliveryDate IS NULL
ORDER BY
  SortOrder, ExpectedDeliveryDate;
GO


CREATE OR ALTER PROCEDURE Purchasing.sp_purchaseorders_deliverydate
  (
    @DeliveryDate Date
  )
AS BEGIN
  SELECT
    PurchaseOrderID, ExpectedDeliveryDate
  FROM
    Purchasing.PurchaseOrders
  WHERE
    (ExpectedDeliveryDate = @DeliveryDate);
END;
GO


EXEC Purchasing.sp_purchaseorders_deliverydate @DeliveryDate = '20140827';
GO


-- Undefined deliverydate
-- Does NULL input is supported?
EXEC Purchasing.sp_purchaseorders_deliverydate @DeliveryDate = NULL;
GO


-- The conventional solution is the use of ISNULL function
CREATE OR ALTER PROCEDURE Purchasing.sp_purchaseorders_deliverydate
  (
    @DeliveryDate Date
  )
AS BEGIN
  SELECT
    PurchaseOrderID, ExpectedDeliveryDate
  FROM
    Purchasing.PurchaseOrders
  WHERE
    ISNULL(ExpectedDeliveryDate, '99991231') = ISNULL(@DeliveryDate, '99991231');
END;
GO

EXEC Purchasing.sp_purchaseorders_deliverydate @DeliveryDate = NULL;
GO



CREATE OR ALTER PROCEDURE Purchasing.sp_purchaseorders_deliverydate
  (
    @DeliveryDate Date
  )
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

EXEC Purchasing.sp_purchaseorders_deliverydate @DeliveryDate = NULL;
GO


-- Credits to Itzik Ben-Gan
CREATE OR ALTER PROCEDURE Purchasing.sp_purchaseorders_deliverydate
  (
    @DeliveryDate Date
  )
AS BEGIN
  SELECT
    PurchaseOrderID, ExpectedDeliveryDate
  FROM
    Purchasing.PurchaseOrders
  WHERE
    EXISTS (SELECT ExpectedDeliveryDate
            INTERSECT
            SELECT @DeliveryDate);
END;
GO

EXEC Purchasing.sp_purchaseorders_deliverydate @DeliveryDate = NULL;
GO


------------------------------------------------------------------------
-- More Sargable/Non-sargable predicates                              --
------------------------------------------------------------------------

USE [WideWorldImporters];
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


-- Non-SARGable
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  UPPER(StockItemName) = UPPER('DBA joke mug - it depends (Black)');
GO


-- Non-SARGable
SELECT
  COUNT(*)
FROM
  Warehouse.StockItems
WHERE
  LEFT(StockItemName, 3) = 'DBA';
GO


-- Non-SARGable
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


-- ? 
SELECT
  COUNT(*)
FROM
  Warehouse.StockItems
WHERE
  StockItemName LIKE 'DBA%';
GO


-- ?
SELECT
  COUNT(*)
FROM
  Warehouse.StockItems
WHERE
  ISNULL(Size, 'M') = 'M';
GO


-- ?
SELECT
  COUNT(*)
FROM
  Warehouse.StockItems
WHERE
  (Size = 'M') OR (Size IS NULL);
GO