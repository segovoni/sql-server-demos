------------------------------------------------------------------------
-- Event:        SQL Start 2025 - June 13                             --
--               https://www.sqlstart.it/                             --
--                                                                    --
-- Session:      How SQL Server 2025 improves concurrency             --
--               with Transaction ID Locking and LAQ                  --
--                                                                    --
-- Demo:         Setup database on SQL Server 2022                    --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

/*
Stack Overflow SQL Server Database - Mini 2010 Version

For more information and the latest release:
http://www.brentozar.com/go/querystack

Imported from the Stack Exchange Data Dump about 2010
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
-- COMPATIBILITY_LEVEL { 170 | 160 | 150 | 140 | 130 | 120 | 110 | 100 | 90 | 80 }
-- 160 for SQL Server 2022
-- 170 for SQL Server 2025
ALTER DATABASE [StackOverflow2010] SET COMPATIBILITY_LEVEL = 160 
GO
ALTER DATABASE [StackOverflow2010] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [StackOverflow2010] SET PAGE_VERIFY CHECKSUM 
GO
ALTER DATABASE [StackOverflow2010] SET ACCELERATED_DATABASE_RECOVERY = ON;
GO
ALTER DATABASE [StackOverflow2010] SET READ_COMMITTED_SNAPSHOT ON;
GO
/*
ALTER DATABASE [StackOverflow2010] SET OPTIMIZED_LOCKING = ON;
GO
*/

-- OptimizedLocking
IF (DB_ID('OptimizedLocking') IS NOT NULL)
BEGIN
  ALTER DATABASE [OptimizedLocking]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [OptimizedLocking];
END;
GO

CREATE DATABASE [OptimizedLocking]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'OptimizedLocking', FILENAME = N'C:\SQL\DBs\OptimizedLocking.mdf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'OptimizedLocking_log', FILENAME = N'C:\SQL\DBs\OptimizedLocking_log.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
 WITH LEDGER = OFF
GO
-- COMPATIBILITY_LEVEL { 170 | 160 | 150 | 140 | 130 | 120 | 110 | 100 | 90 | 80 }
-- 160 for SQL Server 2022
-- 170 for SQL Server 2025
ALTER DATABASE [OptimizedLocking] SET COMPATIBILITY_LEVEL = 160 
GO
ALTER DATABASE [OptimizedLocking] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [OptimizedLocking] SET PAGE_VERIFY CHECKSUM 
GO
ALTER DATABASE [OptimizedLocking] SET ACCELERATED_DATABASE_RECOVERY = ON;
GO
ALTER DATABASE [OptimizedLocking] SET READ_COMMITTED_SNAPSHOT ON;
GO
/*
ALTER DATABASE [OptimizedLocking] SET OPTIMIZED_LOCKING = ON;
GO
*/

USE [OptimizedLocking]
GO

IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [OptimizedLocking] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO

USE [master];
GO

SELECT
  name
  ,ADR  = is_accelerated_database_recovery_on
  ,RCSI = is_read_committed_snapshot_on
 FROM
   sys.databases
 GO