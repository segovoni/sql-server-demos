------------------------------------------------------------------------
-- Event:        1nn0vAI 2026 - Pordenone, September  26              --
--               https://www.1nn0vai.it/                              --
--                                                                    --
-- Session:      SQL Server 2025: Vector Search, Embedding, and AI    --
--               for Enterprise Data                                  --
--                                                                    --
-- Demo:         Setup database                                       --
-- Author:       Sergio Govoni                                        --
-- Notes:        Build a SQL Server Q&A semantic search environment   --
------------------------------------------------------------------------


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
  StackOverflowMini
*/
IF (DB_ID(N'StackOverflowMini') IS NOT NULL)
BEGIN
  ALTER DATABASE [StackOverflowMini]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [StackOverflowMini];
END;
GO

/*
  File paths used in this script are specific to the demo workstation.

  Before running this script on a different machine, update:
  - backup file paths
  - data file paths
  - log file paths

  Expected local folder layout:
  C:\SQL\DBs\Backup\
  C:\SQL\DBs\
*/

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
-- 170 for SQL Server 2025
ALTER DATABASE [StackOverflowMini] SET COMPATIBILITY_LEVEL = 170;
GO
ALTER DATABASE [StackOverflowMini] SET RECOVERY SIMPLE WITH NO_WAIT;
GO
ALTER DATABASE [StackOverflowMini] SET PAGE_VERIFY CHECKSUM WITH NO_WAIT;
GO

CREATE LOGIN [AIModelAppUser]
  WITH
    PASSWORD=N'P@ssw0rd!'
    ,DEFAULT_DATABASE=[StackOverflowMini];
GO


USE [StackOverflowMini];
GO


-- In order to use CREATE VECTOR INDEX statement,
-- we must enable the PREVIEW_FEATURES database scoped configuration option
ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON;
GO

IF SCHEMA_ID(N'ai_demo') IS NULL
BEGIN
  EXEC(N'CREATE SCHEMA [ai_demo];');
END;
GO

CREATE USER [AIModelAppUser] FOR LOGIN [AIModelAppUser]
  WITH
    DEFAULT_SCHEMA=[ai_demo];
GO


USE [master];
GO

/*
AdventureWorks sample databases

Download AdventureWorksLT2025
https://learn.microsoft.com/sql/samples/adventureworks-install-configure
*/ 

IF (DB_ID(N'AdventureWorksLT2025') IS NOT NULL)
BEGIN
  ALTER DATABASE [AdventureWorksLT2025]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [AdventureWorksLT2025];
END;
GO

RESTORE DATABASE [AdventureWorksLT2025]
  FROM DISK = N'C:\SQL\DBs\Backup\AdventureWorksLT2025.bak'
  WITH
    FILE = 1
    ,MOVE N'AdventureWorksLT2022_Data' TO N'C:\SQL\DBs\AdventureWorksLT2025_Data.mdf'
    ,MOVE N'AdventureWorksLT2022_Log' TO N'C:\SQL\DBs\AdventureWorksLT2025_Log.ldf'
    ,NOUNLOAD
    ,STATS = 5;
GO

-- COMPATIBILITY_LEVEL { 170 | 160 | 150 | 140 | 130 | 120 | 110 | 100 | 90 | 80 }
-- 170 for SQL Server 2025
ALTER DATABASE [AdventureWorksLT2025] SET COMPATIBILITY_LEVEL = 170;
GO
ALTER DATABASE [AdventureWorksLT2025] SET RECOVERY SIMPLE WITH NO_WAIT;
GO
ALTER DATABASE [AdventureWorksLT2025] SET PAGE_VERIFY CHECKSUM WITH NO_WAIT;
GO