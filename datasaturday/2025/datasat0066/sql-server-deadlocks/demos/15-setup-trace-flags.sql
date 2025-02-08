------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2025, Feb 22                 --
--               https://bit.ly/datasatpordenone25                    --
--                                                                    --
-- Session:      SQL Server Deadlocks: Techniques to identify         --
--               and resolve them!                                    --
--                                                                    --
-- Demo:         Trace flags setup                                    --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [master];
GO

-- Trace flags 1222 (and 1204) capture information about the deadlock event
-- and log it in the SQL Server error log

-- Current trace flag ststuses
DBCC TRACESTATUS;
GO

-- Enable trace flag 1222 (no globally scope by default)
DBCC TRACEON(1222);

DBCC TRACEOFF(1222);
GO

-- Enable trace flag 1222 globally
DBCC TRACEON(1222, -1)

DBCC TRACEOFF(1222, -1);
GO