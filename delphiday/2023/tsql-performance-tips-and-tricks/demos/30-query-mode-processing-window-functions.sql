------------------------------------------------------------------------
-- Event:        Delphi Day 2023 - June 06-07                          -
--               https://www.delphiday.it/                             -
--                                                                     -
-- Session:      T-SQL performance tips & tricks!                      -
--                                                                     -
-- Demo:         Query mode execution and columnstore indexes          -
--               https://bit.ly/3F6ctvb                                -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [AdventureWorks2017];
GO

-- Row mode execution vs. Batch mode execution



-- dbo.bigTransactionHistory records of each purchase order, sales order,
-- or work order transaction

-- The sql script to create dbo.bigTransactionHistory table
-- is available here: http://dataeducation.com/thinking-big-adventure/

SELECT COUNT(*) FROM dbo.bigTransactionHistory;
SELECT TOP 10 * FROM dbo.bigTransactionHistory;
GO




-- Running total over Quantity partitioned by ProductID and TransactionID

-- ProductID   TransactionID Quantity    RT_Quantity
------------- ------------- ----------- -----------
-- 1001        1             64          64
-- 1001        26369         27          91   = (27 + 64)
-- 1001        50401         21          112  = (21 + 91)
-- 1001        76769         64          176  = (64 + 112)
-- 1001        100801        53          229  = ....
-- 1001        127169        87          316
-- 1001        151201        43          359
-- 1001        177569        25          384
-- 1001        201601        53          437
-- 1001        227969        76          513

-- (1) Row mode execution
-- 43 seconds with the query option discard results after execution
SELECT
  ProductID
  ,TransactionID
  ,Quantity
  ,RT_Quantity =
    SUM(Quantity) OVER(PARTITION BY ProductID
                       ORDER BY TransactionID
                       ROWS
                         BETWEEN UNBOUNDED PRECEDING
                             AND CURRENT ROW)
FROM
  dbo.bigTransactionHistory
ORDER BY
  ProductID, TransactionID;
GO

-- Row mode execution is a query processing method used with traditional
-- tables, where data is stored in row format


-- SQL Server 2012 introduced columnstore indexes to accelerate
-- analytical workloads

-- Up to SQL Server 2017 batch mode processing requires a columnstore index
-- to be enabled

-- Starting with SQL Server 2019 and in Azure SQL Database,
-- batch mode execution no longer requires columnstore indexes,
-- the feature is called Batch mode on rowstore!

-- NCC index
/*
DROP INDEX IF EXISTS dbo.bigTransactionHistory.NCCX_bigTransactionHistory_TransactionID;
GO
*/

CREATE NONCLUSTERED COLUMNSTORE INDEX NCCX_bigTransactionHistory_TransactionID
  ON dbo.bigTransactionHistory(TransactionID)
  WHERE (TransactionID = -1 AND TransactionID = -2);
GO

-- (2) Batch mode execution
-- 29 seconds with the query option discard results after execution
SELECT
  ProductID
  ,TransactionID
  ,Quantity
  ,RT_Quantity =
    SUM(Quantity) OVER(PARTITION BY ProductID
                       ORDER BY TransactionID
                       ROWS
                         BETWEEN UNBOUNDED PRECEDING
                             AND CURRENT ROW)
FROM
  dbo.bigTransactionHistory
ORDER BY
  ProductID, TransactionID;
GO

-- Batch mode execution is a query processing method used to process
-- multiple rows together



-- POC index
/*
DROP INDEX IF EXISTS dbo.bigTransactionHistory.IX_bigTransactionHistory_ProductID_TransactionID;
GO
*/

CREATE NONCLUSTERED INDEX IX_bigTransactionHistory_ProductID_TransactionID
  ON dbo.bigTransactionHistory(ProductID, TransactionID)
  INCLUDE(Quantity);
GO

-- (3) Batch mode execution with POC index
-- 18 seconds with the query option discard results after execution
SELECT
  ProductID
  ,TransactionID
  ,Quantity
  ,RT_Quantity =
    SUM(Quantity) OVER(PARTITION BY ProductID
                       ORDER BY TransactionID
                       ROWS
                         BETWEEN UNBOUNDED PRECEDING
                             AND CURRENT ROW)
FROM
  dbo.bigTransactionHistory
ORDER BY
  ProductID, TransactionID;
GO