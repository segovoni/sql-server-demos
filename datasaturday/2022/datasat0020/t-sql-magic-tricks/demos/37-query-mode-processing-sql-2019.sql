------------------------------------------------------------------------
-- Event:        DATA SATURDAY #20 - Pordenone 2022                    -
--               http://datasaturdays.com/2022-02-26-datasaturday0020/ -
-- Session:      T-SQL magic tricks!                                   -
--                                                                     -
-- Demo:         Batch mode processing on rowstore in SQL 2019         -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [AdventureWorks2017];
GO

DROP INDEX NCCX_bigTransactionHistory_TransactionID ON dbo.bigTransactionHistory;
GO

ALTER DATABASE [AdventureWorks2017] SET COMPATIBILITY_LEVEL = 150;
GO

SELECT
  ProductID
  ,Quantity
  ,SUM(Quantity) OVER(PARTITION BY ProductID ORDER BY TransactionID
                        --RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                        --ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                     )
FROM
  dbo.bigTransactionHistory
ORDER BY
  ProductID;
GO

-- Disabling batch mode on rowstore
/*
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ON_ROWSTORE = OFF;
*/

-- Enabling batch mode on rowstore
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ON_ROWSTORE = ON;
GO