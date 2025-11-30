------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2025, November 29                --
--               https://bit.ly/43exQYm                               --
--                                                                    --
-- Session:      SQL Server 2025: Optimized Locking in action         --
--                                                                    --
-- Demo:         Optimized locking TID internals                      --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

-- Connect to OptimizedLocking database
USE [OptimizedLocking];
GO

/*
ALTER DATABASE CURRENT SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE CURRENT SET ACCELERATED_DATABASE_RECOVERY = OFF;
ALTER DATABASE CURRENT SET READ_COMMITTED_SNAPSHOT OFF;
ALTER DATABASE CURRENT SET OPTIMIZED_LOCKING = OFF;
ALTER DATABASE CURRENT SET MULTI_USER;
GO
*/

/*
ALTER DATABASE CURRENT SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE CURRENT SET ACCELERATED_DATABASE_RECOVERY = ON;
ALTER DATABASE CURRENT SET READ_COMMITTED_SNAPSHOT ON;
ALTER DATABASE CURRENT SET OPTIMIZED_LOCKING = ON;
ALTER DATABASE CURRENT SET MULTI_USER;
GO
*/

-- A complete view on Optimized Locking activation
SELECT
  [name]
  --,OL = is_optimized_locking_on
  ,OL = DATABASEPROPERTYEX(DB_NAME(), 'IsOptimizedLockingOn')
  ,RCSI = is_read_committed_snapshot_on
  ,ADR  = is_accelerated_database_recovery_on
 FROM
   sys.databases
 WHERE
   (name = DB_NAME());
GO


-- Trace flag 3604 prints output to the console
DBCC TRACEON(3604);
-- Trace flag 1200 prints detailed lock information
-- DBCC TRACEON(1200, -1);
-- DBCC TRACEOFF(1200, -1);
-- DBCC TRACESTATUS;
GO


DROP TABLE IF EXISTS dbo.TelemetryPacket;

CREATE TABLE dbo.TelemetryPacket
(
  PacketID INT IDENTITY(1, 1)
  ,Device CHAR(8000) DEFAULT ('Something')
);
GO

BEGIN TRANSACTION;
INSERT INTO dbo.TelemetryPacket DEFAULT VALUES;
INSERT INTO dbo.TelemetryPacket DEFAULT VALUES;
INSERT INTO dbo.TelemetryPacket DEFAULT VALUES;
COMMIT;
GO 



-- Inspect page ID with sys.fn_PhysLocFormatter that helps us correlate
-- the rows returned by a SELECT with the physical location of the data
SELECT
  PageId = sys.fn_PhysLocFormatter(%%physloc%%)
  ,PacketID
  ,Device
FROM
  dbo.TelemetryPacket
GO


DBCC IND ('OptimizedLocking', 'dbo.TelemetryPacket', -1);
GO


/*
DBCC PAGE ( {'dbname' | dbid}, filenum, pagenum [, printopt={0|1|2|3} ])
*/
-- (1:2488:0)
DBCC PAGE ('OptimizedLocking', 1, 2488, 3);
GO

/*
TID = 
New TID = 
*/

-- Inspect locks with sys.dm_tran_locks on updated rows
BEGIN TRANSACTION;

UPDATE
  dbo.TelemetryPacket
SET
  Device = 'Something new from Data Saturday Parma 2025'
WHERE
  PacketID = 1;
  

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

/*
COMMIT;
GO
*/