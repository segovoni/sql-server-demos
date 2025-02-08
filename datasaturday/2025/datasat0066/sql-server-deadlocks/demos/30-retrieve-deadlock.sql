------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2025, Feb 22                 --
--               https://bit.ly/datasatpordenone25                    --
--                                                                    --
-- Session:      SQL Server Deadlocks: Techniques to identify         --
--               and resolve them!                                    --
--                                                                    --
-- Demo:         Retrieve deadlock from error log                     --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [msdb];
GO

-- Query deadlock from error log (trace flag 1222 output to error log)
EXEC sp_readerrorlog;
GO


-- Query deadlock from extended events system_health session
SELECT
  deadlock = CAST(event_data AS XML).query('(event/data[@name="xml_report"]/value/deadlock)[1]')
  ,object_name
  ,timestamp_utc
FROM
  sys.fn_xe_file_target_read_file('system_health*xel', NULL, NULL, NULL)
WHERE
  (object_name = 'xml_deadlock_report')
ORDER BY
  timestamp_utc DESC
GO