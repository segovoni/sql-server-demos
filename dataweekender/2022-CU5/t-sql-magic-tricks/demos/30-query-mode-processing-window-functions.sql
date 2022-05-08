------------------------------------------------------------------------
-- Event:        #DataWeekender CU5 - May 14th 2022                    -
--               A Pop-up and Online Microsoft Data Conference         -
--               https://www.dataweekender.com/                        -
-- Session:      T-SQL magic tricks!                                   -
--                                                                     -
-- Demo:         Query mode execution and columnstore indexes          -
--               https://bit.ly/3F6ctvb                                -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [AdventureWorks2017];
GO

-- SQL Server 2012 introduced columnstore indexes to accelerate
-- analytical workloads


-- The sql script to create dbo.bigTransactionHistory table
-- is available here: http://dataeducation.com/thinking-big-adventure/


SELECT COUNT(*) FROM dbo.bigTransactionHistory;
SELECT TOP 10 * FROM dbo.bigTransactionHistory;
GO



-- Running total
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
-- RDBMS tables, where data is stored in row format

-- The execution tree operators and child operators read each required row,
-- across all the columns specified in the table schema

-- From each row that is read, SQL Server then retrieves the columns
-- that are required



-- NCC index
DROP INDEX IF EXISTS dbo.bigTransactionHistory.NCCX_bigTransactionHistory_TransactionID;
GO

-- SQL Server 2016 enables the creation of EMPTY FILTERED columnstore indexes

-- Up to SQL Server 2017 batch mode processing requires a columnstore index to be enabled

-- Starting with SQL Server 2019 and in Azure SQL Database,
-- batch mode execution no longer requires columnstore indexes,
-- the feature is called Batch mode on rowstore!

CREATE NONCLUSTERED COLUMNSTORE INDEX NCCX_bigTransactionHistory_TransactionID
  ON dbo.bigTransactionHistory(TransactionID)
  WHERE (TransactionID = -1 AND TransactionID = -2);
GO

-- (2) Batch mode execution
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

-- Each column within a batch is stored as a vector in a separate memory area

-- Batch mode processing operates on compressed data when possible,
-- and eliminates the exchange operator used by row mode execution,
-- better parallelism and faster performance



-- POC index
DROP INDEX IF EXISTS dbo.bigTransactionHistory.IX_bigTransactionHistory_ProductID_TransactionID;
GO

CREATE NONCLUSTERED INDEX IX_bigTransactionHistory_ProductID_TransactionID
  ON dbo.bigTransactionHistory(ProductID, TransactionID)
  INCLUDE(Quantity);
GO

-- (3) Batch mode execution with POC index
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