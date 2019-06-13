------------------------------------------------------------------------
-- Event:        Delphi Day 2019, Piacenza, June 6 2019               --
--               https://www.delphiday.it/                            --
-- Session:      SQL Server Query Store e Automatic Tuning            --
-- Demo:         Enable the Query Store                               --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------


USE [QueryStore];
GO


-- Enables the Query Store
-- https://msdn.microsoft.com/en-us/library/bb522682.aspx


SELECT * FROM sys.database_query_store_options;
GO


ALTER DATABASE [QueryStore] SET QUERY_STORE = ON
(
  -- Describes the operation mode of the query store
  OPERATION_MODE = READ_WRITE

  -- STALE_QUERY_THRESHOLD_DAYS determines the number of days for which the information
  -- for a query is retained in the query store
  ,CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 15)

  -- Set the time interval at which runtime execution statistics data
  -- is aggregated into the Query Store
  ,INTERVAL_LENGTH_MINUTES = 1

  -- Determines the frequency at which data written to the query store is persisted to disk
  ,DATA_FLUSH_INTERVAL_SECONDS = 60
);
GO

-- Cleaning up the space
DBCC FREEPROCCACHE;
GO

ALTER DATABASE [QueryStore] SET QUERY_STORE CLEAR;
GO

-- Query Store options for the current database
SELECT * FROM sys.database_query_store_options;
GO