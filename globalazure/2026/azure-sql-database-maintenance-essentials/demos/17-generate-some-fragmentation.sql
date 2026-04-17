------------------------------------------------------------------------
-- Event:        Global Azure 2026 - Pordenone, April 18              --
--               https://globalazure.net/                             --
--                                                                    --
-- Session:      Azure SQL Database Maintenance Essentials            --
--                                                                    --
-- Demo:         Generate some fragmentation                          --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

-- Connect to Azure SQL Database logical instance for maintenance database

/*
USE [AdventureWorksLT2025];
GO
*/


-- Generate some fragmentation on AdventureWorksLT2025
SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS dbo.TabA;
GO

-- Create table dbo.TabA
CREATE TABLE dbo.TabA
(
  ID INT IDENTITY(1, 1)
  ,ColA CHAR(8000) DEFAULT 'Azure SQL Database Maintenance Essentials'
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
  ,ColB CHAR(8000) DEFAULT 'Global Azure 2026 - Pordenone edition'
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
  sys.dm_db_index_physical_stats(DB_ID('AdventureWorksLT2025')
                                 ,OBJECT_ID('dbo.TabB')
                                 ,NULL
                                 ,NULL
                                 ,'DETAILED');
GO 


-- Drop table dbo.TabA
DROP TABLE IF EXISTS dbo.TabA;
GO


-- Shrink DB
DBCC SHRINKDATABASE('AdventureWorksLT2025');
GO


-- Check fragmentation 
SELECT
  avg_fragmentation_in_percent
  ,[db_name] = DB_NAME(database_id)
  ,[object_name] = OBJECT_NAME([object_id])
  ,*
FROM
  sys.dm_db_index_physical_stats(DB_ID('AdventureWorksLT2025')
                                 ,OBJECT_ID('dbo.TabB')
                                 ,NULL
                                 ,NULL
                                 ,'DETAILED');
GO

SELECT * FROM dbo.CommandLog;