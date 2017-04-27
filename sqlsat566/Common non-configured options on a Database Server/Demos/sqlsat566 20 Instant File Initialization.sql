------------------------------------------------------------------------
-- Event:        SQL Saturday Parma 2016, November 26                 --
--               http://www.sqlsaturday.com/566/EventHome.aspx        --
-- Session:      Common non-configured options on a Database Server   --
-- Demo:         Instant file initialization                          --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------


-- lusrmgr.msc

-- secpol.msc

-- "NT SERVICE\MSSQLSERVER"


-- Undocumented trace flags
-- TF 3004 shows information about backups and file creations
-- TF 3604 prints the output to result window
-- TF 3605 redirects the output to the SQL Server error log
DBCC TRACEON(3004, 3604, 3605, -1) WITH NO_INFOMSGS;
GO

DBCC TRACESTATUS;
GO

USE [master];
GO

RESTORE DATABASE [AdventureWorks2016]
  FROM DISK = N'C:\SQL\DBs\Backup\AdventureWorks2016CTP3.bak'
  WITH FILE = 1,
  MOVE N'AdventureWorks2016CTP3_Data' TO N'C:\SQL\DBs\AdventureWorks2016CTP3_Data.mdf',
  MOVE N'AdventureWorks2016CTP3_Log' TO N'C:\SQL\DBs\AdventureWorks2016CTP3_Log.ldf',
  MOVE N'AdventureWorks2016CTP3_mod' TO N'C:\SQL\DBs\AdventureWorks2016CTP3_mod',
  NOUNLOAD,
  STATS = 5;
GO


-- You will see PREEMPTIVE_OS_SETFILEVALIDDATA wait type
-- in sys.dm_exec_requests while the growth occurs

EXEC sp_readerrorlog;
GO


-- Turn off trace flags
DBCC TRACEOFF(3004, 3604, 3605, -1) WITH NO_INFOMSGS;
GO

DBCC TRACESTATUS;
GO