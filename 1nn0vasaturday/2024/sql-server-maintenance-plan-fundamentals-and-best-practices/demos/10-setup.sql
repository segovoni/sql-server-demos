-------------------------------------------------------------------------
-- Event:      1nn0va Saturday 2024 - September 28                     --
--             https://1nn0vasat2024.1nn0va.it/agenda.html             --
--                                                                     --
-- Session:    SQL Server Maintenance Plan: Fundamentals and best      --
--             practices                                               --
--                                                                     --
-- Script:     Setup                                                   --
-- Author:     Sergio Govoni                                           --
-- Notes:      --                                                      --
-------------------------------------------------------------------------

USE [master];
GO

/*
Stack Overflow SQL Server Database - Tiny: 1.5GB database as of 2009

For more information and the latest release:
https://www.brentozar.com/archive/2015/10/how-to-download-the-stack-overflow-database-via-bittorrent/

Imported using the Stack Overflow Data Dump Importer:
https://github.com/BrentOzarULTD/soddi

What's inside the StackOverflow Database

* All tables have a clustered index
* No nonclustered or full text indexes are included
* The log file is small, and you should grow it out if you plan to modify data
* It's distributed as an mdf/ldf so you don't need space to restore it
* It only includes StackOverflow.com data, not data for other Stack sites

License:  https://creativecommons.org/licenses/by-sa/4.0/

More information about license attribution here: https://archive.org/details/stackexchange
*/

USE [master];
GO

/*
  StackOverflowMini-LiveDemo-Check-Restore
*/
IF (DB_ID('StackOverflowMini-LiveDemo-Check-Restore') IS NOT NULL)
BEGIN
  ALTER DATABASE [StackOverflowMini-LiveDemo-Check-Restore]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [StackOverflowMini-LiveDemo-Check-Restore];
END;
GO

/*
  StackOverflowMini
*/
IF (DB_ID('StackOverflowMini') IS NOT NULL)
BEGIN
  ALTER DATABASE [StackOverflowMini]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [StackOverflowMini];
END;
GO

RESTORE DATABASE [StackOverflowMini]
  FROM DISK = N'C:\SQL\DBs\Backup\StackOverflowMini.bak'
  WITH
    FILE = 1
    ,MOVE N'StackOverflowMini' TO N'C:\SQL\DBs\StackOverflowMini.mdf'
    ,MOVE N'StackOverflowMini_log' TO N'C:\SQL\DBs\StackOverflowMini_log.ldf'
    ,NOUNLOAD
    ,STATS = 5;
GO

-- COMPATIBILITY_LEVEL { 160 | 150 | 140 | 130 | 120 | 110 | 100 | 90 | 80 }
-- 130 for SQL Server 2016
-- 140 for SQL Server 2017
-- 150 for SQL Server 2019
-- 160 for SQL Server 2022
ALTER DATABASE [StackOverflowMini] SET COMPATIBILITY_LEVEL = 160;
GO

ALTER DATABASE [StackOverflowMini] SET PAGE_VERIFY NONE WITH NO_WAIT;
GO

ALTER DATABASE [StackOverflowMini] SET RECOVERY SIMPLE WITH NO_WAIT;
GO


/*
  StackOverflowMini-LiveDemo
*/
IF (DB_ID('StackOverflowMini-LiveDemo') IS NOT NULL)
BEGIN
  ALTER DATABASE [StackOverflowMini-LiveDemo]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [StackOverflowMini-LiveDemo];
END;
GO

RESTORE DATABASE [StackOverflowMini-LiveDemo]
  FROM DISK = N'C:\SQL\DBs\Backup\StackOverflowMini.bak'
  WITH
    FILE = 1
    ,MOVE N'StackOverflowMini' TO N'C:\SQL\DBs\StackOverflowMini-LiveDemo.mdf'
    ,MOVE N'StackOverflowMini_log' TO N'C:\SQL\DBs\StackOverflowMini-LiveDemo_log.ldf'
    ,NOUNLOAD
    ,STATS = 5;
GO

-- COMPATIBILITY_LEVEL { 160 | 150 | 140 | 130 | 120 | 110 | 100 | 90 | 80 }
-- 130 for SQL Server 2016
-- 140 for SQL Server 2017
-- 150 for SQL Server 2019
-- 160 for SQL Server 2022
ALTER DATABASE [StackOverflowMini-LiveDemo] SET COMPATIBILITY_LEVEL = 160;
GO

ALTER DATABASE [StackOverflowMini-LiveDemo] SET PAGE_VERIFY NONE WITH NO_WAIT;
GO

ALTER DATABASE [StackOverflowMini-LiveDemo] SET RECOVERY SIMPLE WITH NO_WAIT;
GO


/*
  StackOverflowMini-Corrupted
*/
/*
IF (DB_ID('StackOverflowMini-Corrupted') IS NOT NULL)
BEGIN
  ALTER DATABASE [StackOverflowMini-Corrupted]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [StackOverflowMini-Corrupted];
END;
GO

RESTORE DATABASE [StackOverflowMini-Corrupted]
  FROM DISK = N'C:\SQL\DBs\Backup\StackOverflowMini-Corrupted.bak'
  WITH
    FILE = 1
    ,MOVE N'StackOverflowMini' TO N'C:\SQL\DBs\StackOverflowMini-Corrupted.mdf'
    ,MOVE N'StackOverflowMini_log' TO N'C:\SQL\DBs\StackOverflowMini-Corrupted_log.ldf'
    ,NOUNLOAD
    ,STATS = 5;
GO

-- COMPATIBILITY_LEVEL { 160 | 150 | 140 | 130 | 120 | 110 | 100 | 90 | 80 }
-- 130 for SQL Server 2016
-- 140 for SQL Server 2017
-- 150 for SQL Server 2019
-- 160 for SQL Server 2022
ALTER DATABASE [StackOverflowMini-Corrupted] SET COMPATIBILITY_LEVEL = 160;
GO

ALTER DATABASE [StackOverflowMini-Corrupted] SET PAGE_VERIFY NONE WITH NO_WAIT;
GO

ALTER DATABASE [StackOverflowMini-Corrupted] SET RECOVERY SIMPLE WITH NO_WAIT;
GO
*/


USE [StackOverflowMini-LiveDemo];
GO

UPDATE
  dbo.Posts
SET
  Body = LEFT(Body, 500);
GO

DELETE FROM dbo.Posts
WHERE Body IN (SELECT Body FROM dbo.Posts GROUP BY Body HAVING COUNT(ID) > 1);
GO

ALTER TABLE dbo.Posts ALTER COLUMN Body NVARCHAR(500);
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_Posts_Body ON dbo.Posts
(
  [Body]
);
GO


/*
  ShrinkDemo
*/
IF (DB_ID('ShrinkDemo') IS NOT NULL)
BEGIN
  ALTER DATABASE [ShrinkDemo]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [ShrinkDemo];
END
GO

CREATE DATABASE [ShrinkDemo];
GO

ALTER DATABASE [ShrinkDemo] SET RECOVERY SIMPLE WITH NO_WAIT;
GO


USE [ShrinkDemo];
GO

SET NOCOUNT ON;
GO 

-- Create table dbo.TabA (100MB)
CREATE TABLE dbo.TabA
(
  ID INT IDENTITY(1, 1)
  ,ColA CHAR(8000) DEFAULT 'Something'
);
GO

CREATE CLUSTERED INDEX IDX__TabA on dbo.TabA(ID);
GO

INSERT INTO dbo.TabA DEFAULT VALUES;
GO 12800

-- Create table dbo.TabB (100MB)
CREATE TABLE dbo.TabB
(
  ID INT IDENTITY(1, 1)
  ,ColB CHAR(8000) DEFAULT 'SOMETHING ELSE'
);
GO

CREATE CLUSTERED INDEX IDX__TabB on dbo.TabB(ID);
GO

INSERT INTO dbo.TabB DEFAULT VALUES;
GO 12800 

-- Check fragmentation 
SELECT
  avg_fragmentation_in_percent
  ,page_count
  ,*
FROM
  sys.dm_db_index_physical_stats(DB_ID('ShrinkDemo'), OBJECT_ID('ShrinkDemo.dbo.TabB'), NULL, NULL, 'DETAILED');
GO 

-- Drop table dbo.TabA
DROP TABLE dbo.TabA
GO