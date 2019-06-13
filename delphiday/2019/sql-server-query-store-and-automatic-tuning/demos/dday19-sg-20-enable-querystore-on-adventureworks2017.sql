------------------------------------------------------------------------
-- Event:        Delphi Day 2019, Piacenza, June 6 2019               --
--               https://www.delphiday.it/                            --
-- Session:      SQL Server Query Store e Automatic Tuning            --
-- Demo:         Enable the Query Store AdventureWorks2017            --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------


USE [AdventureWorks2017];
GO


-- Enables the Query Store
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-set-options?view=sql-server-2017


SELECT * FROM sys.database_query_store_options;
GO


ALTER DATABASE [AdventureWorks2017] SET QUERY_STORE = ON
(
  -- Describes the operation mode of the query store
  OPERATION_MODE = READ_WRITE

  -- STALE_QUERY_THRESHOLD_DAYS determines the number of days for which the information
  -- for a query is retained in the query store
  ,CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 15)

  -- Set the time interval at which runtime execution statistics data
  -- is aggregated into the Query Store
  ,INTERVAL_LENGTH_MINUTES = 60

  -- Determines the frequency at which data written to the query store is persisted to disk
  ,DATA_FLUSH_INTERVAL_SECONDS = 120
);
GO


-- Cleaning up the space
DBCC FREEPROCCACHE;
GO

ALTER DATABASE [AdventureWorks2017] SET QUERY_STORE CLEAR;
GO

-- Query Store options for the current database
SELECT * FROM sys.database_query_store_options;
GO


/*

-- Generate the workload

cmd (admin mode)

C:\Tools\QueryStoreWorkLoad.exe -usa -pPassword -sServerName -dAdventureWorks2017
C:\Tools\StressSQLDB4D.exe -usa -pPassword -sServerName -dAdventureWorks2017

*/