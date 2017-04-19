------------------------------------------------------------------------
-- Event:        SQL Saturday #589 Pordenone, February 25, 2017        -
--               http://www.sqlsaturday.com/589/eventhome.aspx         -
-- Session:      DMVs for Performance Tuning                           -
-- Demo:         Most costly databases                                 -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [master];
GO


-- Utilizzo della Buffer Pool per database
SELECT
  database_name = dbs.[name]
  ,cached_pages = count(*)
  ,cached_pages_mb = count(*) * 8 / 1024.0
FROM
  sys.dm_os_buffer_descriptors AS os_bd
INNER JOIN
  sys.databases AS dbs ON os_bd.database_id = dbs.database_id
GROUP BY
  dbs.name
ORDER BY
  cached_pages_mb DESC;
GO


-- Statistiche di I/O
SELECT * FROM sys.dm_io_virtual_file_stats(NULL, NULL);
GO


WITH IO_stats AS
(
  SELECT
    DB_NAME(dm_io_stats.database_id) AS [database_name]
	,db_files.type_desc AS file_type
	-- Total I/O
	,SUM(dm_io_stats.num_of_bytes_read + dm_io_stats.num_of_bytes_written) AS io_read_write
	-- Total I/O stall in ms
	,SUM(dm_io_stats.io_stall_read_ms + dm_io_stats.io_stall_write_ms) AS io_stall_ms -- equal to dm_io_stats.io_stall
  FROM
    sys.dm_io_virtual_file_stats(NULL, NULL) AS dm_io_stats
  JOIN
    sys.master_files AS db_files ON db_files.database_id = dm_io_stats.database_id AND
	                                db_files.file_id = dm_io_stats.file_id
  GROUP BY
    DB_NAME(dm_io_stats.database_id), db_files.type_desc
)
SELECT
  IO_stats.[database_name]
  ,IO_stats.file_type
  ,[io (MB)] = CAST((IO_stats.io_read_write / 1024.0 / 1024.0) AS DECIMAL(15, 2))
  ,[io_stall (sec)] = CAST((IO_stats.io_stall_ms / 1000.0) AS DECIMAL(15, 2))
  ,[io_stall (%)] = CAST((IO_stats.io_stall_ms * 100.0)/SUM(IO_stats.io_stall_ms) OVER() AS DECIMAL(5, 2))
FROM
  IO_stats
ORDER BY
  IO_stats.io_stall_ms DESC;
GO



-- Query from Paul Randal
-- http://www.sqlskills.com/blogs/paul/how-to-examine-io-subsystem-latencies-from-within-sql-server/

-- I/O Latency
SELECT
  [ReadLatency] = CASE WHEN [num_of_reads] = 0 THEN 0 ELSE ([io_stall_read_ms] / [num_of_reads]) END
  ,[WriteLatency] = CASE WHEN [num_of_writes] = 0 THEN 0 ELSE ([io_stall_write_ms] / [num_of_writes]) END
  ,[Latency] = CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0 ELSE ([io_stall] / ([num_of_reads] + [num_of_writes])) END
  --avg bytes per IOP 
  ,[AvgBPerRead] = CASE WHEN [num_of_reads] = 0 THEN 0 ELSE ([num_of_bytes_read] / [num_of_reads]) END
  ,[AvgBPerWrite] = CASE WHEN [io_stall_write_ms] = 0 THEN 0 ELSE ([num_of_bytes_written] / [num_of_writes]) END
  ,[AvgBPerTransfer] = CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0 ELSE (([num_of_bytes_read] + [num_of_bytes_written]) / ([num_of_reads] + [num_of_writes])) END
  ,LEFT ([mf].[physical_name], 2) AS [Drive]
  ,DB_NAME ([vfs].[database_id]) AS [DB]
  ,[mf].[physical_name]
FROM
  sys.dm_io_virtual_file_stats (NULL,NULL) AS [vfs]
JOIN
  sys.master_files AS [mf] ON [vfs].[database_id] = [mf].[database_id] AND [vfs].[file_id] = [mf].[file_id]
-- WHERE [vfs].[file_id] = 2 -- log files -- 
ORDER BY
  [Latency] DESC
-- ORDER BY [ReadLatency] DESC ORDER BY [WriteLatency] DESC;
GO