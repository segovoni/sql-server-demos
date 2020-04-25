-------------------------------------------------------------------------
-- Event:       Global Azure 2020 Virtual - April 24, 2020              -
--              https://cloudgen.it/global-azure/                       -
-- Session:     Automating Azure SQL Database maintenance tasks         -
-- Demo:        Setup new DB in Azure SQL                               -
-- Author:      Sergio Govoni                                           -
-- Notes:       --                                                      -
-------------------------------------------------------------------------

-- Connect to an Azure SQL Database instance


USE [master];
GO

IF (DB_ID('Maintenance') IS NOT NULL)
BEGIN
  ALTER DATABASE [Maintenance]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [Maintenance];
END
GO

CREATE DATABASE [Maintenance];
GO


USE [Maintenance];
GO

SET NOCOUNT ON;
GO 

-- Create table dbo.TabA
CREATE TABLE dbo.TabA
(
  ID INT IDENTITY(1, 1)
  ,ColA CHAR(8000) DEFAULT 'Azure DB Maintenance'
);
GO

CREATE CLUSTERED INDEX IDX_TabA on dbo.TabA(ID);
GO

INSERT INTO dbo.TabA DEFAULT VALUES;
GO 12800



-- Create table dbo.TabB
CREATE TABLE dbo.TabB
(
  ID INT IDENTITY(1, 1)
  ,ColB CHAR(8000) DEFAULT 'SOMETHING ELSE'
);
GO

CREATE CLUSTERED INDEX IDX_TabB on dbo.TabB(ID);
GO


INSERT INTO dbo.TabB DEFAULT VALUES;
GO 12800 


-- Check fragmentation 
SELECT
  *
FROM
  sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.TabB'), NULL, NULL, 'DETAILED');
GO 


-- Drop table dbo.TabA
DROP TABLE IF EXISTS dbo.TabA;
GO


-- Shrink DB
DBCC SHRINKDATABASE('Maintenance');
GO 


-- Check fragmentation 
SELECT
  *
FROM
  sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.TabB'), NULL, NULL, 'DETAILED');
GO


-- Reindex dbo.TabB
--DBCC DBREINDEX('dbo.TabB');
--GO