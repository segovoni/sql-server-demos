------------------------------------------------------------------------
-- Event:        Delphi Day 2026 - June 09-10                         --
--               https://www.delphiday.it/                            --
--                                                                    --
-- Session:      Azure SQL Database Essentials                        --
--                                                                    --
-- Demo:         Generate some fragmentation                          --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

-- Connect to Azure SQL Database logical instance for maintenance
-- azure-sql-delphi-day-2026

/*
USE [AdventureWorksLT];
GO
*/


SELECT
  D.[NAME] AS DatabaseName
  ,S.*
FROM
  sys.database_service_objectives AS S
JOIN
  sys.databases AS D ON S.database_id = D.database_id
GO

-- Change the pricing tier
-- The edition is the tier like Basic, Standard, Premium

-- The Basic edition has only Basic as a service object

-- In the Standard edition, we have S0 to S12 service objectives

-- For the Premium tier, you have P1 to P15 service objects
ALTER DATABASE [AdventureWorksLT]
  MODIFY(EDITION = 'Standard', SERVICE_OBJECTIVE = 'S1');
GO


-- Generate some fragmentation on AdventureWorksLT
SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS dbo.TabA;
GO

-- Create table dbo.TabA
CREATE TABLE dbo.TabA
(
  ID INT IDENTITY(1, 1)
  ,ColA CHAR(8000) DEFAULT 'Azure SQL Database Essentials'
);
GO

CREATE CLUSTERED INDEX IDX_TabA on dbo.TabA(ID);
GO

INSERT INTO dbo.TabA DEFAULT VALUES;
GO 12800


DROP TABLE IF EXISTS dbo.TabB;
GO

-- Create table dbo.TabB
CREATE TABLE dbo.TabB
(
  ID INT IDENTITY(1, 1)
  ,ColB CHAR(8000) DEFAULT 'Delphi Day 2026 - Piacenza edition'
);
GO

CREATE CLUSTERED INDEX IDX_TabB on dbo.TabB(ID);
GO


INSERT INTO dbo.TabB DEFAULT VALUES;
GO 12800 



-- Check fragmentation 
SELECT
  avg_fragmentation_in_percent
  ,[db_name] = DB_NAME(database_id)
  ,[object_name] = OBJECT_NAME([object_id])
  ,*
FROM
  sys.dm_db_index_physical_stats(DB_ID('AdventureWorksLT')
                                 ,OBJECT_ID('dbo.TabB')
                                 ,NULL
                                 ,NULL
                                 ,'DETAILED');
GO 


-- Drop table dbo.TabA
DROP TABLE IF EXISTS dbo.TabA;
GO


-- Shrink DB
DBCC SHRINKDATABASE('AdventureWorksLT');
GO


-- Check fragmentation 
SELECT
  avg_fragmentation_in_percent
  ,[db_name] = DB_NAME(database_id)
  ,[object_name] = OBJECT_NAME([object_id])
  ,*
FROM
  sys.dm_db_index_physical_stats(DB_ID('AdventureWorksLT')
                                 ,OBJECT_ID('dbo.TabB')
                                 ,NULL
                                 ,NULL
                                 ,'DETAILED');
GO


SELECT * FROM dbo.CommandLog;
GO


ALTER DATABASE [AdventureWorksLT]
  MODIFY(EDITION = 'Basic');
GO


SELECT
  D.[NAME] AS DatabaseName
  ,S.*
FROM
  sys.database_service_objectives AS S
JOIN
  sys.databases AS D ON S.database_id = D.database_id
GO