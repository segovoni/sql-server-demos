------------------------------------------------------------------------
-- Event:        Global Azure 2025 Veneto, May 09, Vicenza            --
--               https://veneto.globalazure.it/                       --
--                                                                    --
-- Session:      Optimized Locking in Azure SQL Database:             --
--               Concurrency and performance at the next level!       --
--                                                                    --
-- Demo:         Setup database on Azure SQL                          --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

-- Connect to Azure SQL

/*
USE [master];
GO
*/

/*
ALTER DATABASE CURRENT SET ACCELERATED_DATABASE_RECOVERY = ON;
ALTER DATABASE CURRENT SET READ_COMMITTED_SNAPSHOT ON;
ALTER DATABASE CURRENT SET OPTIMIZED_LOCKING = ON;
GO
*/

-- OptimizedLocking
IF ((SELECT database_id FROM sys.databases WHERE [name] = 'OptimizedLocking') IS NOT NULL)
BEGIN
	DROP DATABASE [OptimizedLocking];
END
GO

WAITFOR DELAY '00:00:20';
GO

CREATE DATABASE [OptimizedLocking];
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
-- In the Standard edition, we have S0 to S12 service objectives (example SERVICE_OBJECTIVE = 'S1')
-- For the Premium tier, you have P1 to P15 service objects
ALTER DATABASE [OptimizedLocking] MODIFY(EDITION = 'Basic');
GO

-- Is optimized locking enabled?
SELECT
  IsOptimizedLockingOn = DATABASEPROPERTYEX(DB_NAME(), 'IsOptimizedLockingOn');
GO

-- Optimized locking builds on other database features:
-- 1. Accelerated database recovery (ADR)
-- 2. For the most benefit: Read committed snapshot isolation (RCSI) should be enabled for the database
SELECT
  name
  ,IsOptimizedLockingOn = DATABASEPROPERTYEX(DB_NAME(), 'IsOptimizedLockingOn')
  ,RCSI = is_read_committed_snapshot_on
  ,ADR  = is_accelerated_database_recovery_on
 FROM
   sys.databases
 GO

-- Read committed snapshot is not a distinct isolation level,
-- so showing "read committed" is correct.
-- Read committed snapshot is a database option that changes the behavior of READ COMMITTED
SELECT
  CASE transaction_isolation_level 
    WHEN 0 THEN 'Unspecified' 
    WHEN 1 THEN 'ReadUncommitted' 
    WHEN 2 THEN 'ReadCommitted' 
    WHEN 3 THEN 'Repeatable' 
    WHEN 4 THEN 'Serializable' 
    WHEN 5 THEN 'Snapshot'
  END AS TRANSACTION_ISOLATION_LEVEL 
FROM
  sys.dm_exec_sessions 
where
  (session_id = @@SPID);
GO