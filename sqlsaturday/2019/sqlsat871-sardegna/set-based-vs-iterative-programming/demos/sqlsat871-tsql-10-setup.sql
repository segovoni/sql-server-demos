------------------------------------------------------------------------
-- Event:        SQL Saturday #871 Sardegna 2019, May 18               -
-- Session:      Set-based vs Iterative programming                    -
-- https://www.sqlsaturday.com/871/Sessions/Details.aspx?sid=94179     -
-- Demo:         Setup database                                        -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

-- Full backup di AdventureWorks2017 database di esempio
-- https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks


USE [master];
GO

-- Drop Database
IF (DB_ID('AdventureWorks2017') IS NOT NULL)
BEGIN
  ALTER DATABASE [AdventureWorks2017]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [AdventureWorks2017];
END;
GO

RESTORE DATABASE [AdventureWorks2017]
  FROM DISK = N'C:\SQL\DBs\Backup\AdventureWorks2017.bak'
  WITH
    FILE = 1
    ,MOVE N'AdventureWorks2017' TO N'C:\SQL\DBs\AdventureWorks2017.mdf'
    ,MOVE N'AdventureWorks2017_log' TO N'C:\SQL\DBs\AdventureWorks2017_log.ldf'
    ,NOUNLOAD
    ,STATS = 5;
GO

USE [AdventureWorks2017];
GO


-- Production.TransactionHistory

-- Add column sQuantity
ALTER TABLE Production.TransactionHistory 
  ADD sQuantity INTEGER NOT NULL DEFAULT(0);
GO

-- Update values in sQuantity
UPDATE
  Production.TransactionHistory
SET
  sQuantity = CASE WHEN (TransactionType IN ('W', 'P'))
                THEN Quantity
				            ELSE (Quantity*-1)
		            END;
GO

-- Create index
CREATE INDEX IDX__TH_ProductID_TransactionID ON Production.TransactionHistory
(
  [ProductID]
  ,[TransactionID]
);
GO


-- Sales.SalesOrderHeader
CREATE INDEX IDX__Sales_SalesOrderHeader_OrderDate ON Sales.SalesOrderHeader
(
  [OrderDate]
);
GO