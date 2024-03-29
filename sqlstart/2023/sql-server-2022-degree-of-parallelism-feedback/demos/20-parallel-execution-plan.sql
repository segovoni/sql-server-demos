------------------------------------------------------------------------
-- Event:    SQL Start 2023, June 16                                  --
--           https://www.sqlstart.it/2023/Speakers/Sergio-Govoni      --
--                                                                    --
-- Session:  SQL Server 2022 Degree of Parallelism Feedback           --
-- Demo:     Parallel Execution Plan                                  --
-- Author:   Sergio Govoni                                            --
-- Notes:    -                                                        --
------------------------------------------------------------------------

USE [AdventureWorks2022]
GO

-- Parallel plan for running total calculation

SET STATISTICS IO ON;

SELECT COUNT_BIG(*) FROM dbo.bigTransactionHistory;
GO 10

SELECT COUNT_BIG(*) FROM dbo.bigTransactionHistory OPTION (MAXDOP 1);
GO


-- Query in another connection 
SELECT
  OSTSK.scheduler_id
  ,qp.node_id
  ,qp.physical_operator_name
FROM
  sys.dm_os_tasks OSTSK
LEFT JOIN
  sys.dm_os_workers OSWRK ON OSTSK.worker_address=OSWRK.worker_address
LEFT JOIN
  sys.dm_exec_query_profiles qp ON OSWRK.task_address=qp.task_address
WHERE
  OSTSK.session_id=55
ORDER BY
  scheduler_id, node_id;
GO


-- Another parallel query
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
GO


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



USE [WideWorldImporters];
GO

-- Waiting task for CXPACKET
EXEC Warehouse.GetStockItemsbySupplier 4;
GO 15