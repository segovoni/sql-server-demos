------------------------------------------------------------------------
-- Event:        DATA SATURDAY #20 - Pordenone 2022                    -
--               http://datasaturdays.com/2022-02-26-datasaturday0020/ -
-- Session:      T-SQL magic tricks!                                   -
--                                                                     -
-- Demo:         Query mode processing                                 -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [AdventureWorks2017];
GO

-- The sql script to create dbo.bigTransactionHistory table
-- is available here: http://dataeducation.com/thinking-big-adventure/

SELECT COUNT(*) FROM dbo.bigTransactionHistory;
SELECT TOP 10 * FROM dbo.bigTransactionHistory;
GO


--SET STATISTICS IO ON;
--GO

SELECT
  ProductID
  ,TransactionID
  ,Quantity
  ,SUM(Quantity) OVER(PARTITION BY ProductID ORDER BY TransactionID
                      --RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
                      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM
  dbo.bigTransactionHistory
ORDER BY
  ProductID, TransactionID;
GO


-- NCCX
/*
DROP INDEX NCCX_bigTransactionHistory_TransactionID
*/

CREATE NONCLUSTERED COLUMNSTORE INDEX NCCX_bigTransactionHistory_TransactionID
  ON dbo.bigTransactionHistory(TransactionID)
  WHERE (TransactionID = -1 AND TransactionID = -2);
GO


-- POC index
CREATE NONCLUSTERED INDEX IX_bigTransactionHistory_ProductID_TransactionID
  ON dbo.bigTransactionHistory(ProductID, TransactionID)
  INCLUDE(Quantity);
GO


/*
USE [WideWorldImportersDW];
GO

SELECT COUNT(*) FROM [Fact].[Movement];
SELECT TOP 10 * FROM [Fact].[Movement];
GO

SET STATISTICS IO ON;


SELECT
  [Stock Item Key]
  ,[Quantity]
  ,SUM([Quantity]) OVER(PARTITION BY [Stock Item Key] ORDER BY [Movement Key], [Date Key]
                        --RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM
  [Fact].[Movement]
ORDER BY
  [Stock Item Key];
GO


CREATE NONCLUSTERED COLUMNSTORE INDEX NCCX_Fact_Movement_Stock_Item_Key
  ON [Fact].[Movement]([Stock Item Key])
  WHERE ([Stock Item Key] = -1 AND [Stock Item Key] = -2);
GO
*/