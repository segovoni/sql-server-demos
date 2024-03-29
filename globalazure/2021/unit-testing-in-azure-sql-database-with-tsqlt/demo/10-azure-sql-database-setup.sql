-------------------------------------------------------------------------
-- Event:       Global Azure 2021                                       -
--              Apr 15th-17th 2021 - Virtual                            -
--              https://globalazure.net/                                -
--                                                                      -
-- Session:     Unit testing in Azure SQL Database with tSQLt           -
-- Demo:        Database setup                                          -
-- Author:      Sergio Govoni                                           -
-- Notes:       --                                                      -
-------------------------------------------------------------------------

-- Full backup of AdventureWorks2017
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


-- Migrate AdventureWorks2017 from on-premise to Azure SQL Database
-- https://docs.microsoft.com/en-us/azure/azure-sql/database/migrate-to-database-from-sql-server/?WT.mc_id=DP-MVP-4029181

-- https://github.com/MicrosoftDocs/sql-docs.it-it/blob/live/docs/samples/adventureworks-install-configure.md
