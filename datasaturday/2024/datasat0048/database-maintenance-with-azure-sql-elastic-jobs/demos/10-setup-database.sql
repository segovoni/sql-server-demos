------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2024 - February 24           --
--               https://bit.ly/3R8aAEM                               --
--                                                                    --
-- Session:      Database maintenance with Azure SQL Elastic Jobs     --
--                                                                    --
-- Demo:         Setup database                                       --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

/*
Stack Overflow SQL Server Database - Mini 2010 Version

For more information and the latest release:
http://www.brentozar.com/go/querystack

Imported from the Stack Exchange Data Dump circa 2010
https://archive.org/details/stackexchange

Imported using the Stack Overflow Data Dump Importer:
https://github.com/BrentOzarULTD/soddi

This database is in Microsoft SQL Server 2008 format, which means you can
attach it to any SQL Server 2008 or newer instance.

To keep the size small but let you get started fast:

* All tables have a clustered index
* No nonclustered or full text indexes are included
* The log file is small, and you should grow it out if you plan to modify data
* It's distributed as an mdf/ldf so you don't need space to restore it
* It only includes StackOverflow.com data, not data for other Stack sites

As with the original data dump, this is provided under cc-by-sa 3.0 license:
http://creativecommons.org/licenses/by-sa/3.0/

You are free to share this database and adapt it for any purpose, even
commercially, but you must attribute it to the original authors:
https://archive.org/details/stackexchange
*/


USE [master];
GO

-- StackOverflow2010
IF (DB_ID('StackOverflow2010') IS NOT NULL)
BEGIN
  ALTER DATABASE [StackOverflow2010]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [StackOverflow2010];
END;
GO

RESTORE DATABASE [StackOverflow2010]
  FROM DISK = N'C:\SQL\DBs\Backup\StackOverflow2010.bak'
  WITH
    FILE = 1
    ,MOVE N'StackOverflow2010' TO N'C:\SQL\DBs\StackOverflow2010.mdf'
    ,MOVE N'StackOverflow2010_log' TO N'C:\SQL\DBs\StackOverflow2010_log.ldf'
    ,NOUNLOAD
    ,STATS = 5;
GO

-- COMPATIBILITY_LEVEL { 160 | 150 | 140 | 130 | 120 | 110 | 100 | 90 | 80 }
-- 130 for SQL Server 2016
-- 140 for SQL Server 2017
-- 150 for SQL Server 2019
-- 160 for SQL Server 2022
ALTER DATABASE [StackOverflow2010] SET COMPATIBILITY_LEVEL = 160;
GO


USE [StackOverflow2010];
GO

SET NOCOUNT ON;
GO

-- Create table dbo.TabA
CREATE TABLE dbo.TabA
(
  ID INT IDENTITY(1, 1)
  ,ColA CHAR(8000) DEFAULT 'Database maintenance with Azure SQL Elastic Jobs'
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
  avg_fragmentation_in_percent
  ,[db_name] = DB_NAME(database_id)
  ,[object_name] = OBJECT_NAME([object_id])
  ,*
FROM
  sys.dm_db_index_physical_stats(DB_ID('StackOverflow2010')
                                 ,OBJECT_ID('dbo.TabB')
                                 ,NULL
                                 ,NULL
                                 ,'DETAILED');
GO 


-- Drop table dbo.TabA
DROP TABLE IF EXISTS dbo.TabA;
GO


-- Shrink DB
DBCC SHRINKDATABASE('ToBeMaintained');
GO 


-- Check fragmentation 
SELECT
  avg_fragmentation_in_percent
  ,[db_name] = DB_NAME(database_id)
  ,[object_name] = OBJECT_NAME([object_id])
  ,*
FROM
  sys.dm_db_index_physical_stats(DB_ID('StackOverflow2010')
                                 ,OBJECT_ID('dbo.TabB')
                                 ,NULL
                                 ,NULL
                                 ,'DETAILED');


-- Connect to Azure SQL Database

-- DBJobsDataSaturdayPordenone2024
IF (DB_ID('DBJobsDataSaturdayPordenone2024') IS NOT NULL)
BEGIN
  ALTER DATABASE [DBJobsDataSaturdayPordenone2024]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [DBJobsDataSaturdayPordenone2024];
END
GO

CREATE DATABASE [DBJobsDataSaturdayPordenone2024];
GO


SELECT
  D.[Name]
  ,S.*
FROM
  sys.database_service_objectives AS S
JOIN
  sys.databases AS D ON D.database_id = S.database_id
GO


-- Change the pricing tier
-- The edition is the tier like Basic, Standard, Premium
-- The Basic edition has only Basic as a service object
-- In the Standard edition, we have S0 to S12 service objectives
-- For the Premium tier, you have P1 to P15 service objects
ALTER DATABASE [DBJobsDataSaturdayPordenone2024]
  MODIFY(EDITION = 'Standard', SERVICE_OBJECTIVE = 'S1');
GO

/*
-- DBDemo
IF (DB_ID('DBDemo') IS NOT NULL)
BEGIN
  ALTER DATABASE [DBDemo]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [DBDemo];
END
GO

CREATE DATABASE [DBDemo];
GO

ALTER DATABASE [DBDemo]
  MODIFY(EDITION = 'Basic');
GO
*/