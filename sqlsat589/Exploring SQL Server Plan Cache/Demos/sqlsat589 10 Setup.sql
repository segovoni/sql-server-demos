------------------------------------------------------------------------
-- Event:        SQL Saturday #589 Pordenone, February 25, 2017        -
--               http://www.sqlsaturday.com/589/eventhome.aspx         -
-- Session:      Exploring SQL Server Plan Cache                       -
-- Demo:         Setup                                                 -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [master];
GO


EXEC sp_configure 'optimize for ad hoc workloads', 0;
RECONFIGURE;
GO

------------------------------------------------------------------------
-- View sp_cacheobjects                                                -
-- From Kalen Delaney (www.SQLServerInternals.com)                     -
------------------------------------------------------------------------

IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'sp_cacheobjects')
  DROP VIEW sp_cacheobjects;
GO

CREATE VIEW sp_cacheobjects(bucketid, cacheobjtype, objtype, objid, dbid, dbidexec, uid, refcounts, 

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


------------------------------------------------------------------------
-- AdventureWorks                                                      -
------------------------------------------------------------------------

-- Drop Database
IF (DB_ID('AdventureWorks') IS NOT NULL)
BEGIN
  ALTER DATABASE [AdventureWorks]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [AdventureWorks];
END;
GO

-- Restore database AdventureWorks from AdventureWorks2016
--RESTORE DATABASE [AdventureWorks]
--  FROM DISK = N'C:\SQL\DBs\Backup\AdventureWorks2016CTP3.bak'
--  WITH FILE = 1,  
--  MOVE N'AdventureWorks2016CTP3_Data' TO N'C:\SQL\DBs\AdventureWorks2016_Data.mdf',  
--  MOVE N'AdventureWorks2016CTP3_Log' TO N'C:\SQL\DBs\AdventureWorks2016_Log.ldf',
--  MOVE N'AdventureWorks2016CTP3_mod' TO N'C:\SQL\DBs\Mod\AdventureWorks2016_mod';
--GO

-- Restore database AdventureWorks from AdventureWorks2014
RESTORE DATABASE [AdventureWorks]
  FROM DISK = N'C:\SQL\DBs\Backup\AdventureWorks2014.bak'
  WITH FILE = 1,  
  MOVE N'AdventureWorks2014_Data' TO N'C:\SQL\DBs\AdventureWorks_Data.mdf',  
  MOVE N'AdventureWorks2014_Log' TO N'C:\SQL\DBs\AdventureWorks_Log.ldf';
GO



USE [AdventureWorks];
GO

------------------------------------------------------------------------
-- dbo.myTransactionHistory                                            -
------------------------------------------------------------------------

IF OBJECT_ID('dbo.myTransactionHistory', 'U') IS NOT NULL
  DROP TABLE dbo.myTransactionHistory;
GO

SELECT * INTO dbo.myTransactionHistory
FROM Production.TransactionHistory;
GO


SELECT Quantity, count(Quantity) FROM dbo.myTransactionhistory GROUP BY Quantity
SELECT * FROM dbo.myTransactionhistory


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

------------------------------------------------------------------------
-- Default values for:                                                 -
-- max degree of parallelism                                           -
-- cost threshold for parallelism                                      -
------------------------------------------------------------------------

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE WITH OVERRIDE;
GO

EXEC sp_configure 'max degree of parallelism', 0;
RECONFIGURE WITH OVERRIDE;
GO

EXEC sp_configure 'cost threshold for parallelism', 5;
RECONFIGURE WITH OVERRIDE;
GO

EXEC sp_configure 'show advanced options', 0;
RECONFIGURE WITH OVERRIDE;
GO
