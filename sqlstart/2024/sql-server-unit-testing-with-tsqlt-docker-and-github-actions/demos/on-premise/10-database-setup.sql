-------------------------------------------------------------------------
-- Event:      SQL Start 2024 - June 14                                --
--             https://www.sqlstart.it/                                --
--                                                                     --
-- Session:    SQL Server unit testing with tSQLt, Docker and          --
--             GitHub Actions                                          --
--                                                                     --
-- Demo:       Database setup                                          --
-- Author:     Sergio Govoni                                           --
-- Notes:      --                                                      --
-------------------------------------------------------------------------

-- Full backup of AdventureWorks2022
-- https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks


USE [master];
GO

-- Drop Database
IF (DB_ID('AdventureWorks2022') IS NOT NULL)
BEGIN
  ALTER DATABASE [AdventureWorks2022]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [AdventureWorks2022];
END;
GO

RESTORE DATABASE [AdventureWorks2022]
  FROM DISK = N'C:\SQL\DBs\Backup\AdventureWorks2022.bak'
  WITH
    FILE = 1
    ,MOVE N'AdventureWorks2022' TO N'C:\SQL\DBs\AdventureWorks2022.mdf'
    ,MOVE N'AdventureWorks2022_log' TO N'C:\SQL\DBs\AdventureWorks2022_log.ldf'
    ,NOUNLOAD
    ,STATS = 5;
GO

USE [AdventureWorks2022];
GO


DECLARE @user AS SYSNAME;
SELECT
  @user = QUOTENAME(SL.Name)
FROM
  master..sysdatabases AS SD
INNER JOIN
  master..syslogins AS SL ON SD.SID = SL.SID
WHERE
  SD.Name = DB_NAME();
EXEC('EXEC sp_changedbowner ' + @user);
GO


CREATE OR ALTER PROCEDURE Production.usp_Raiserror_SafetyStockLevel
(
  @Message NVARCHAR(256)
)
AS
BEGIN
  ROLLBACK;
  RAISERROR(@Message, 16, 1);
END;
GO


CREATE OR ALTER TRIGGER Production.TR_Product_SafetyStockLevel
  ON Production.Product
AFTER INSERT AS
BEGIN
  /* 
     Avoid to insert products with safety stock level lower than 10!
  */
  DECLARE @SafetyStockLevel SMALLINT;

  SELECT
    @SafetyStockLevel = SafetyStockLevel
  FROM
    inserted;

  IF (@SafetyStockLevel < 10)
  BEGIN
    -- Error!!
    EXEC Production.usp_Raiserror_SafetyStockLevel
      @Message = 'Safety stock level cannot be lower than 10!';
  END;
END;
GO

/*
BEGIN TRAN;
  INSERT INTO Production.Product
  (
    [Name]
    ,ProductNumber
    ,MakeFlag
    ,FinishedGoodsFlag
    ,SafetyStockLevel
    ,ReorderPoint
    ,StandardCost
    ,ListPrice
    ,DaysToManufacture
    ,SellStartDate
    ,rowguid
    ,ModifiedDate
  )
  VALUES
  (
    N'Carbon Bar 1'
    ,N'CB-0001'
    ,0
    ,0
    ,15 /* SafetyStockLevel */
    ,750
    ,0.0000
    ,78.0000
    ,0
    ,GETDATE()
    ,NEWID()
    ,GETDATE()
  ),
  (
    N'Carbon Bar 3'
    ,N'CB-0003'
    ,0
    ,0
    ,3 /* SafetyStockLevel */
    ,750
    ,0.0000
    ,78.0000
    ,0
    ,GETDATE()
    ,NEWID()
    ,GETDATE()
  );

  SELECT * FROM Production.Product ORDER BY SafetyStockLevel ASC;
ROLLBACK;
GO
*/