------------------------------------------------------------------------
-- Event:        Global Azure 2026 - Pordenone, April 18              --
--               https://globalazure.net/                             --
--                                                                    --
-- Session:      Azure SQL Database Maintenance Essentials            --
--                                                                    --
-- Demo:         Setup database on-premises                           --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [master];
GO

/*
AdventureWorks sample databases

Download AdventureWorksLT2025
https://learn.microsoft.com/sql/samples/adventureworks-install-configure
*/ 

IF (DB_ID('AdventureWorksLT2025') IS NOT NULL)
BEGIN
  ALTER DATABASE AdventureWorksLT2025
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE AdventureWorksLT2025;
END;
GO

RESTORE DATABASE AdventureWorksLT2025
  FROM DISK = N'C:\SQL\DBs\Backup\AdventureWorksLT2025.bak'
  WITH
    FILE = 1
    ,MOVE N'AdventureWorksLT2022_Data' TO N'C:\SQL\DBs\AdventureWorksLT2025_Data.mdf'
    ,MOVE N'AdventureWorksLT2022_Log' TO N'C:\SQL\DBs\AdventureWorksLT2025_Log.ldf'
    ,NOUNLOAD
    ,STATS = 5;
GO

-- COMPATIBILITY_LEVEL { 170 | 160 | 150 | 140 | 130 | 120 | 110 | 100 | 90 | 80 }
-- 160 for SQL Server 2022
-- 170 for SQL Server 2025
ALTER DATABASE [AdventureWorksLT2025] SET COMPATIBILITY_LEVEL = 170 
GO
ALTER DATABASE [AdventureWorksLT2025] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [AdventureWorksLT2025] SET PAGE_VERIFY CHECKSUM 
GO


USE [AdventureWorksLT2025];
GO

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