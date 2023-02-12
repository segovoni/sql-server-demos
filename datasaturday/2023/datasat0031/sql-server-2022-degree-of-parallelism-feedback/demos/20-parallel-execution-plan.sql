------------------------------------------------------------------------
-- Event:    Data Saturday Pordenone 2023 - February 25               --
--           https://datasaturdays.com/2023-02-25-datasaturday0031/   --
--                                                                    --
-- Session:  SQL Server 2022 Degree of Parallelism Feedback           --
-- Demo:     Parallel Execution Plan                                  --
-- Author:   Sergio Govoni                                            --
-- Notes:    -                                                        --
------------------------------------------------------------------------

USE [AdventureWorks2019]
GO

-- Parallel plan for running total calculation
SELECT
  T.ProductID
  ,T.TransactionDate
  ,T.TransactionType
  ,CASE (T.TransactionType)
     WHEN 'S' THEN (T.Quantity * -1)
     ELSE (T.Quantity)
   END AS Quantity
  ,SUM(
         CASE (T1.TransactionType)
           WHEN 'S' THEN (T1.Quantity * -1)
		   ELSE (T1.Quantity)
	     END
	  ) AS StockLevel
FROM
  Production.TransactionHistory AS T
JOIN
  Production.TransactionHistory AS T1
  ON (T.ProductID = T1.ProductID)
     AND (T1.TransactionID <= T.TransactionID)
GROUP BY
  T.ProductID
  ,T.TransactionDate
  ,T.TransactionType
  ,T.Quantity
  ,T.TransactionID
ORDER BY
  T.ProductID
  ,T.TransactionID;
GO 5


-- Parallel region due to TOP
SELECT
  T.ProductID
  ,T.TransactionDate
  ,T.TransactionType
  ,CASE (T.TransactionType)
     WHEN 'S' THEN (T.Quantity * -1)
     ELSE (T.Quantity)
   END AS Quantity
  ,SUM(
         CASE (T1.TransactionType)
           WHEN 'S' THEN (T1.Quantity * -1)
		   ELSE (T1.Quantity)
	     END
	  ) AS StockLevel
FROM
  (
    SELECT TOP (2000000) *
	FROM Production.TransactionHistory
  ) T
JOIN
  Production.TransactionHistory AS T1
  ON (T.ProductID = T1.ProductID)
     AND (T1.TransactionID <= T.TransactionID)
GROUP BY
  T.ProductID
  ,T.TransactionDate
  ,T.TransactionType
  ,T.Quantity
  ,T.TransactionID
ORDER BY
  T.ProductID
  ,T.TransactionID;
GO


-- Parallel region due to query global aggregate
SELECT
  SUM(X.Quantity) AS QuantitySUM
FROM
(
SELECT
  T.ProductID
  ,T.TransactionDate
  ,T.TransactionType
  ,CASE (T.TransactionType)
     WHEN 'S' THEN (T.Quantity * -1)
     ELSE (T.Quantity)
   END AS Quantity
  ,SUM(
         CASE (T1.TransactionType)
           WHEN 'S' THEN (T1.Quantity * -1)
		   ELSE (T1.Quantity)
	     END
	  ) AS StockLevel
FROM
  Production.TransactionHistory AS T
JOIN
  Production.TransactionHistory AS T1
  ON (T.ProductID = T1.ProductID)
     AND (T1.TransactionID <= T.TransactionID)
GROUP BY
  T.ProductID
  ,T.TransactionDate
  ,T.TransactionType
  ,T.Quantity
  ,T.TransactionID
) X
OPTION (QUERYTRACEON 8649);
--OPTION(USE HINT('ENABLE_PARALLEL_PLAN_PREFERENCE'));
GO