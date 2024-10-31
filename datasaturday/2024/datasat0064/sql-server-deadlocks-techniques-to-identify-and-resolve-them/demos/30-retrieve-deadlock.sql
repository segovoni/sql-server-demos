------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2024, Nov 23                     --
--               https://bit.ly/datasatparma24                        --
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
FROM
  sys.fn_xe_file_target_read_file('system_health*xel', NULL, NULL, NULL);
GO