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

-- DROP NCC index
DROP INDEX IF EXISTS dbo.bigTransactionHistory.NCCX_bigTransactionHistory_TransactionID;
GO

-- COMPATIBILITY_LEVEL { 150 | 140 | 130 | 120 | 110 | 100 | 90 | 80 }
-- 140 for SQL Server 2017
-- 150 for SQL Server 2019
ALTER DATABASE [AdventureWorks2017] SET COMPATIBILITY_LEVEL = 150;
GO

-- Enabling batch mode on rowstore
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ON_ROWSTORE = ON;
GO


-- Running total
-- ProductID   TransactionID Quantity    RT_Quantity
-- ----------- ------------- ----------- -----------
-- 1001        1             64          64
-- 1001        26369         27          91   = (27 + 64)
-- 1001        50401         21          112  = (21 + 91)
-- 1001        76769         64          176  = (64 + 112)
-- 1001        100801        53          229  = ....
-- 1001        127169        87          316  = ....
-- 1001        151201        43          359
-- 1001        177569        25          384
-- 1001        201601        53          437
-- 1001        227969        76          513

-- Batch mode execution
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



-- Disabling batch mode on rowstore
/*
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ON_ROWSTORE = OFF;
GO
*/