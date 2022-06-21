------------------------------------------------------------------------
-- Event:    Delphi Day 2022 - Digital edition, June 21-23            --
--           https://www.delphiday.it/                                --
--                                                                    --
-- Session:  SQL Server 2022 Parameter Sensitive Plan Optimization    --
-- Demo:     Setup database                                           --
-- Author:   Sergio Govoni                                            --
-- Notes:    --                                                       --
------------------------------------------------------------------------

USE [master];
GO

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE WITH OVERRIDE;
GO
EXEC sp_configure 'max degree of parallelism', 0;
RECONFIGURE WITH OVERRIDE;
GO
EXEC sp_configure 'cost threshold for parallelism', 5;
RECONFIGURE WITH OVERRIDE;
GO
EXEC sp_configure 'optimize for ad hoc workloads', 0;
RECONFIGURE WITH OVERRIDE;
GO

-- View sp_cacheobjects
-- From Kalen Delaney (www.SQLServerInternals.com)
CREATE OR ALTER VIEW sp_cacheobjects(bucketid, cacheobjtype, objtype, objid, dbid, dbidexec, uid, refcounts, 

                        usecounts, pagesused, setopts, langid, dateformat, status, lasttime, maxexectime, avgexectime, lastreads,

                        lastwrites, sqlbytes, sql) 
AS
            -- From Kalen Delaney (www.SQLServerInternals.com)
            SELECT            pvt.bucketid, CONVERT(nvarchar(19), pvt.cacheobjtype) as cacheobjtype, pvt.objtype, 
                                    CONVERT(int, pvt.objectid)as object_id, CONVERT(smallint, pvt.dbid) as dbid,
                                    CONVERT(smallint, pvt.dbid_execute) as execute_dbid, CONVERT(smallint, pvt.user_id) as user_id,
                                    pvt.refcounts, pvt.usecounts, pvt.size_in_bytes / 8192 as size_in_bytes,
                                    CONVERT(int, pvt.set_options) as setopts, CONVERT(smallint, pvt.language_id) as langid,
                                    CONVERT(smallint, pvt.date_format) as date_format, CONVERT(int, pvt.status) as status,
                                    CONVERT(bigint, 0), CONVERT(bigint, 0), CONVERT(bigint, 0), CONVERT(bigint, 0), CONVERT(bigint, 0), 
                                    CONVERT(int, LEN(CONVERT(nvarchar(max), fgs.text)) * 2), CONVERT(nvarchar(3900), fgs.text)

            FROM (SELECT ecp.*, epa.attribute, epa.value
                        FROM sys.dm_exec_cached_plans ecp 
                OUTER APPLY sys.dm_exec_plan_attributes(ecp.plan_handle) epa) as ecpa
                   PIVOT (MAX(ecpa.value) for ecpa.attribute IN ([set_options], [objectid], [dbid], [dbid_execute], [user_id], [language_id], [date_format], [status])) as pvt
                       OUTER APPLY sys.dm_exec_sql_text(pvt.plan_handle) fgs
         WHERE cacheobjtype like 'Compiled%';
GO

USE [master];
GO

-- Drop database PSP if exists
IF (DB_ID('PSP') IS NOT NULL)
BEGIN
  ALTER DATABASE [PSP]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [PSP];
END;
GO

-- Create database PSP
CREATE DATABASE [PSP]
  ON PRIMARY 
  (
    NAME = N'PSPData'
    ,FILENAME = N'C:\SQL\DBs\PSPData.mdf'
  )
  LOG ON 
  (
    NAME = N'PSPLog'
	   ,FILENAME = N'C:\SQL\DBs\PSPLog.ldf'
  );
GO

-- Set recovery model to SIMPLE
ALTER DATABASE [PSP] SET RECOVERY SIMPLE;
GO

USE [PSP];
GO

DROP TABLE IF EXISTS dbo.Tab_A;
GO

CREATE TABLE dbo.Tab_A
(
  Col1 INTEGER
  ,Col2 INTEGER
  ,Col3 BINARY(2000)
);
GO

-- Insert some data into the sample table
SET NOCOUNT ON;

BEGIN
  BEGIN TRANSACTION;

  DECLARE @i INTEGER = 0;

  WHILE (@i < 10000)
  BEGIN
    INSERT INTO dbo.Tab_A (Col1, Col2) VALUES (@i, @i);
	   SET @i+=1;
  END;

  COMMIT TRANSACTION;
END;
GO

-- There are much more rows with value 1 than rows with other values
--INSERT INTO dbo.Tab_A (Col1, Col2) VALUES (1, 1)
--GO 500000

-- https://www.codeproject.com/Tips/811875/Generating-Desired-Amount-of-Rows-in-SQL-using-CTE
WITH InfiniteRows (RowNumber) AS
(
  SELECT 1 AS RowNumber
  UNION ALL
  SELECT a.RowNumber + 1 AS RowNumber
  FROM InfiniteRows a
  WHERE a.RowNumber < 500000
)
INSERT INTO dbo.Tab_A
(
  Col1
  ,Col2
)
SELECT
  1 AS MyCol1
  ,1 AS MyCol2
FROM
  InfiniteRows
OPTION (MAXRECURSION 0);
GO


SET NOCOUNT OFF;
GO

-- Create indexes
CREATE INDEX IDX_Tab_A_Col1 ON dbo.Tab_A
(
  [Col1]
);
GO

CREATE INDEX IDX_Tab_A_Col2 ON dbo.Tab_A
(
  [Col2]
);
GO

USE [master]
GO

ALTER DATABASE [PSP] SET COMPATIBILITY_LEVEL = 150;
GO

-- Enables the Query Store
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-set-options
ALTER DATABASE [PSP] SET QUERY_STORE = ON
(
  -- Describes the operation mode of the query store
  OPERATION_MODE = READ_WRITE

  -- STALE_QUERY_THRESHOLD_DAYS determines the number of days for which the information
  -- for a query is retained in the query store
  ,CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 180)

  -- Set the time interval at which runtime execution statistics data
  -- is aggregated into the Query Store
  ,INTERVAL_LENGTH_MINUTES = 1

  -- Determines the frequency at which data written to the query store is persisted to disk
  ,DATA_FLUSH_INTERVAL_SECONDS = 60

  ,QUERY_CAPTURE_MODE = ALL
);
GO

ALTER DATABASE [PSP] SET QUERY_STORE CLEAR ALL
GO


-- Full backup of AdventureWorks2019
-- https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure


-- Drop Database
IF (DB_ID('AdventureWorks2019') IS NOT NULL)
BEGIN
  ALTER DATABASE [AdventureWorks2019]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [AdventureWorks2019];
END;
GO

RESTORE DATABASE [AdventureWorks2019]
  FROM DISK = N'C:\SQL\DBs\Backup\AdventureWorks2019.bak'
  WITH
    FILE = 1
    ,MOVE N'AdventureWorks2017' TO N'C:\SQL\DBs\AdventureWorks2019.mdf'
    ,MOVE N'AdventureWorks2017_log' TO N'C:\SQL\DBs\AdventureWorks2019_log.ldf'
    ,NOUNLOAD
    ,STATS = 5;
GO

ALTER DATABASE [AdventureWorks2019] SET COMPATIBILITY_LEVEL = 150;
GO
-- Enables the Query Store
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-set-options
ALTER DATABASE [AdventureWorks2019] SET QUERY_STORE = ON
(
  -- Describes the operation mode of the query store
  OPERATION_MODE = READ_WRITE

  -- STALE_QUERY_THRESHOLD_DAYS determines the number of days for which the information
  -- for a query is retained in the query store
  ,CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 180)

  -- Set the time interval at which runtime execution statistics data
  -- is aggregated into the Query Store
  ,INTERVAL_LENGTH_MINUTES = 1

  -- Determines the frequency at which data written to the query store is persisted to disk
  ,DATA_FLUSH_INTERVAL_SECONDS = 60

  ,QUERY_CAPTURE_MODE = ALL
);
GO

ALTER DATABASE [AdventureWorks2019] SET QUERY_STORE CLEAR ALL
GO
-- Default PARAMETERIZATION for AdventureWorks database
ALTER DATABASE [AdventureWorks2019] SET PARAMETERIZATION SIMPLE;
GO


USE [PSP]
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE  
GO

/*
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SENSITIVE_PLAN_OPTIMIZATION = OFF
GO
*/


USE [AdventureWorks2019]
GO

-- dbo.myTransactionHistory
IF OBJECT_ID('dbo.myTransactionHistory', 'U') IS NOT NULL
  DROP TABLE dbo.myTransactionHistory;
GO

SELECT * INTO dbo.myTransactionHistory
FROM Production.TransactionHistory;
GO

SELECT Quantity, count(Quantity) FROM dbo.myTransactionhistory GROUP BY Quantity;
SELECT * FROM dbo.myTransactionhistory;

CREATE UNIQUE INDEX IDXU_myTansactionHistory_ID ON dbo.myTransactionHistory
(
  [TransactionID]
);
GO

CREATE NONCLUSTERED INDEX IDX_myTansactionHistory_Quantity ON dbo.myTransactionHistory
(
  [Quantity]
);
GO