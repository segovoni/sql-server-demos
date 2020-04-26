------------------------------------------------------------------------
-- Event:        SQL Saturday Parma 2016, November 26                 --
--               http://www.sqlsaturday.com/566/EventHome.aspx        --
-- Session:      Common non-configured options on a Database Server   --
-- Demo:         Allocation contention on tempdb                      --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------


/*
-T 1118 global only

DBCC TRACESTATUS;
GO
*/

USE [master];
GO


-- Where are tempdb data files?
SELECT
  name
  ,physical_name AS CurrentLocation
  ,*
FROM
  sys.master_files
WHERE
  (database_id = DB_ID(N'tempdb'));
GO


------------------------------------------------------------------------
-- Test SP dbo.usp_loop_populate_temp_table                           --
------------------------------------------------------------------------

USE [TestLatchDB];
GO


-- Execute the procedure
SET NOCOUNT ON;
GO
EXECUTE dbo.usp_loop_stress_tempdb;
GO
SET NOCOUNT OFF;
GO



------------------------------------------------------------------------
-- Using ostress.exe (RML tool)                                       --
------------------------------------------------------------------------

/*

ostress.exe -Q"EXECUTE TestLatchDB.dbo.usp_loop_stress_tempdb;" -n100 -q

*/


-- Latch, Allocation contention on tempdb
SELECT
  *
FROM
  sys.dm_os_waiting_tasks
WHERE
  (resource_description = '2:1:1')
  OR (resource_description = '2:1:2')
  OR (resource_description = '2:1:3');
GO


-- PAGELATCH_*
SELECT
  *
FROM
  sys.dm_os_wait_stats
WHERE
  (wait_type LIKE 'PAGELATCH%')
ORDER BY
  wait_time_ms DESC;
GO




-- Clear the wait statistics
-- !! Don't run this on production servers !!
DBCC SQLPERF('sys.dm_os_wait_stats', 'clear');
GO




-- Alter the tempdb files size
-- Data file
ALTER DATABASE tempdb
  MODIFY FILE
  (
    NAME = 'tempdev'
    ,SIZE = 512MB
  );
GO

-- Log file
ALTER DATABASE tempdb
  MODIFY FILE
  (
    NAME = 'templog'
    ,SIZE = 512MB
  );
GO


-- Let's try to add data file to tempdb
-- They must have the same size
ALTER DATABASE tempdb
  ADD FILE
  (
    NAME = 'tempdev2'
    ,SIZE = 512MB
    ,FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdev2.ndf'
  );
GO

-- Add an additional data file to tempdb
ALTER DATABASE tempdb
  ADD FILE
  (
    NAME = 'tempdev3'
    ,SIZE = 512MB
    ,FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdev3.ndf'
  );
GO

-- One more :)
ALTER DATABASE tempdb
  ADD FILE
  (
    NAME = 'tempdev4'
    ,SIZE = 512MB
    ,FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdev4.ndf'
  );
GO


-- Where are tempdb data files?
SELECT
  name
  ,physical_name AS CurrentLocation
  ,*
FROM
  sys.master_files
WHERE
  (database_id = DB_ID(N'tempdb'));
GO






-- Now, the problem is:
-- SQL Server is not able to cache the temp table ??

USE [TestLatchDB];
GO


-- Performance Counters from DMVs
SELECT
  *
FROM
  sys.dm_os_performance_counters
WHERE
  (counter_name LIKE '%Tables%');
GO



-- Let's check the performance counter "Temp Tables Creation Rate"
BEGIN
  DECLARE
    @temp_tables_creation_rate_before BIGINT = 0
	,@temp_tables_creation_rate_after BIGINT = 0;

  -- Save the current value of "Temp Tables Creation Rate"
  SELECT
    @temp_tables_creation_rate_before = cntr_value
  FROM
    sys.dm_os_performance_counters
  WHERE
    (counter_name = 'Temp Tables Creation Rate');

  SET NOCOUNT ON;
  
  DECLARE @i INTEGER = 0;

  -- Execute the stored procedure
  WHILE (@i < 10)
  BEGIN
    EXECUTE dbo.usp_loop_stress_tempdb;
	SET @i += 1; 
  END;

  SET NOCOUNT OFF;

  -- Read again the performance counter "Temp Tables Creation Rate"
  SELECT
    @temp_tables_creation_rate_after = cntr_value
  FROM
    sys.dm_os_performance_counters
  WHERE
    (counter_name = 'Temp Tables Creation Rate');

  PRINT ('@temp_tables_creation_rate_before: ' + CAST(@temp_tables_creation_rate_before AS VARCHAR(20)));
  PRINT ('@temp_tables_creation_rate_after: ' + CAST(@temp_tables_creation_rate_after AS VARCHAR(20)));
  PRINT ('Temp Tables Created: ' + CAST(@temp_tables_creation_rate_after AS VARCHAR(20)) + ' - ' + CAST(@temp_tables_creation_rate_before AS VARCHAR(20)) + ' = ' + CAST(@temp_tables_creation_rate_after - @temp_tables_creation_rate_before AS VARCHAR(20)));
END;
GO


-- Let's change the stored procedure, so that temporary object can be reused
ALTER PROCEDURE dbo.usp_stress_tempdb
AS
BEGIN
  -- Create temporary table
  CREATE TABLE dbo.#TempTable
  (
    Col1 INTEGER IDENTITY(1, 1) NOT NULL
	  PRIMARY KEY (Col1) -- !!!!!!!!!!
	,Col2 CHAR(4000)
	,Col3 CHAR(4000)
  );

  -- Create unique clustered index
  --CREATE UNIQUE CLUSTERED INDEX uq_clidx_temptable_col1 ON dbo.#TempTable(Col1);

  -- Insert 10 records into the temporary table
  DECLARE
    @i INTEGER = 0;
  WHILE
    (@i < 10)
  BEGIN
    INSERT INTO dbo.#TempTable VALUES ('SQL Saturday Parma 2016', '#sqlsat566');
	SET @i = (@i + 1);
  END;
END;
GO