------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2023 - November 18               --
--               https://bit.ly/3tKmyMM                               --
--                                                                    --
-- Session:      T-SQL performance tips & tricks!                     --
--                                                                    --
-- Demo:         Contentions on tempdb                                --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [TestLatchDB];
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


-- Execute the procedure
SET NOCOUNT ON;
GO
EXECUTE dbo.usp_loop_stress_tempdb;
GO
SET NOCOUNT OFF;
GO



-- Using ostress.exe (RML tool)
/*

ostress.exe -E -SDEV -dTestLatchDB -Q"EXECUTE TestLatchDB.dbo.usp_loop_stress_tempdb;" -n300 -q -T146

1m 46s

*/

SELECT
  *
FROM
  sys.dm_os_waiting_tasks;
GO

-- Object allocation contention
-- Contention on wait resource 2:8:1 is tempdb contention
-- tempdb database is always database id 2,
-- there is contention on file ID #8 with GAM contention
-- (page #1 is the PFS, #2 is the GAM, and #3 is SGAM)
-- 2:1:1, 2:1:2, 2:1:3 the PFS, GAM, and SGAM on the file ID #1
SELECT
  session_id AS SessionID, 
  wait_duration_ms AS Wait_Time_In_Milliseconds, 
  resource_description AS Type_of_Allocation_Contention 
FROM
  sys.dm_os_waiting_tasks 
WHERE
  --wait_type LIKE 'PAGELATCH_%' 
  /*AND*/ (resource_description LIKE '2:%:1' 
  OR resource_description LIKE '2:%:2' 
  OR resource_description LIKE '2:%:3')


-- Metadata contention
-- Contention occurring on index and data pages and the page number in the wait resource
-- will be a higher value such as 2:1:111, 2:1:118, or 2:1:122
SELECT
  session_id AS SessionID, 
  wait_duration_ms AS Wait_Time_In_Milliseconds, 
  resource_description AS Type_of_Allocation_Contention 
FROM
  sys.dm_os_waiting_tasks 
WHERE
  wait_type LIKE 'PAGELATCH_%' 
  AND (resource_description LIKE '2:%:%' 
  OR resource_description LIKE '2:%:%' 
  OR resource_description LIKE '2:%:%');
 GO

 EXEC sp_whoisactive


-- PAGELATCH_*
/*
SELECT
  *
FROM
  sys.dm_os_wait_stats
WHERE
  (wait_type LIKE 'PAGELATCH%')
ORDER BY
  wait_time_ms DESC;
GO
*/


-- Clear the wait statistics
-- !! Don't run this on production servers !!
DBCC SQLPERF('sys.dm_os_wait_stats', 'clear');
GO



-- SQL Server is not able to cache the temp table?


-- Performance Counters from DMVs
SELECT
  *
FROM
  sys.dm_os_performance_counters
WHERE
  (counter_name LIKE '%Tables%');
GO

-- 20019


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
    INSERT INTO dbo.#TempTable VALUES ('Data Saturday Parma', '#DataSat37');
	SET @i = (@i + 1);
  END;
END;
GO