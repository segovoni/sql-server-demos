------------------------------------------------------------------------
-- Event:        Global Azure 2025 Veneto, May 09, Vicenza            --
--               https://veneto.globalazure.it/                       --
--                                                                    --
-- Session:      Optimized Locking in Azure SQL Database:             --
--               Concurrency and performance at the next level!       --
--                                                                    --
-- Demo:         Optimized locking and transaction ID (TID) locking   --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

-- Azure SQL Database
-- Connect to OptimizedLocking database
/*
USE [OptimizedLocking];
GO
*/

/*
ALTER DATABASE CURRENT SET ACCELERATED_DATABASE_RECOVERY = ON;
ALTER DATABASE CURRENT SET READ_COMMITTED_SNAPSHOT ON;
ALTER DATABASE CURRENT SET OPTIMIZED_LOCKING = OFF;
GO
*/

-- A complete view
SELECT
  IsOptimizedLockingOn = DATABASEPROPERTYEX(DB_NAME(), 'IsOptimizedLockingOn')
  ,RCSI = is_read_committed_snapshot_on
  ,ADR  = is_accelerated_database_recovery_on
 FROM
   sys.databases
 WHERE
   (name = DB_NAME());
GO


DROP TABLE IF EXISTS dbo.SensorReadings;

CREATE TABLE dbo.SensorReadings
(
  SensorID INTEGER PRIMARY KEY NOT NULL,
  ReadingValue INTEGER NOT NULL
);

INSERT INTO dbo.SensorReadings VALUES (1, 10),(2, 20),(3, 30);
GO

-- Inspect locks with sys.dm_tran_locks on updated rows
BEGIN TRANSACTION;

UPDATE
  dbo.SensorReadings
SET
  ReadingValue = ReadingValue + 10;

SELECT
  *
FROM
  sys.dm_tran_locks
WHERE
  request_session_id = @@SPID
AND
  resource_type IN ('PAGE','RID','KEY','XACT');

ROLLBACK;
GO

DROP TABLE IF EXISTS dbo.SensorReadings;
GO