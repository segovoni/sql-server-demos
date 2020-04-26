------------------------------------------------------------------------
-- Event:        SQL Saturday #858 Athens, June 15 2019                -
-- Session:      SQL Server Query Optimizer end-to-end                 -
-- https://www.sqlsaturday.com/858/Sessions/Details.aspx?sid=90801     -
-- Demo:         Setup on-prem                                         -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

-- Full backup of WideWorldImporters sample database is available on GitHub
-- https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0


-- Documentation about WideWorldImporters sample database for SQL Server
-- and Azure SQL Database
-- https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/wide-world-importers


--Full backup of AdventureWorks2017 sample database is available on GitHub
-- https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks



USE [master];
GO


-- Drop Database
IF (DB_ID('WideWorldImporters') IS NOT NULL)
BEGIN
  ALTER DATABASE [WideWorldImporters]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [WideWorldImporters];
END;
GO

-- Restore DB
RESTORE DATABASE [WideWorldImporters]
  FROM  DISK = N'C:\SQL\DBs\Backup\WideWorldImporters-Full.bak' WITH  FILE = 1
  ,MOVE N'WWI_Primary' TO N'C:\SQL\DBs\WideWorldImporters.mdf'
  ,MOVE N'WWI_UserData' TO N'C:\SQL\DBs\WideWorldImporters_UserData.ndf'
  ,MOVE N'WWI_Log' TO N'C:\SQL\DBs\WideWorldImporters.ldf'
  ,MOVE N'WWI_InMemory_Data_1' TO N'C:\SQL\DBs\WideWorldImporters_InMemory_Data_1'
  ,NOUNLOAD
  ,STATS = 5;
GO


USE [WideWorldImporters];
GO

ALTER TABLE Warehouse.Colors WITH CHECK
  ADD CONSTRAINT CK_Warehouse_Colors_ColorName_Gray
  CHECK (ColorName <> 'Gray');
GO



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

/*
ALTER AUTHORIZATION ON DATABASE::AdventureWorks2017 TO [MARCONI\AdventureWorks2017]
GO
*/