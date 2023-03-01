------------------------------------------------------------------------
-- Event:    Data Saturday Pordenone 2023 - February 25               --
--           https://datasaturdays.com/2023-02-25-datasaturday0031/   --
--                                                                    --
-- Session:  SQL Server 2022 Degree of Parallelism Feedback           --
-- Demo:     DOP Feedback                                             --
-- Author:   Sergio Govoni                                            --
-- Notes:    --                                                       --
------------------------------------------------------------------------

USE [master];
GO

-- Generate the workload

-- Install RML Utilities for SQL Server that contains ostress.exe
-- RML Utilities for SQL Server is available for download from the
-- Microsoft Download Center here https://bit.ly/3PmuRnS 

-- After you install the RML Utilities you will find the RML tools
-- present in the c:\Program Files\Microsoft Corporation\RMLUtils folder

-- Open cmd
-- Move to the folder that contains ostress.exe with
-- cd "c:\Program Files\Microsoft Corporation\RMLUtils"

-- Execute
-- ostress.exe -E -Q"EXEC Warehouse.GetStockItemsbySupplier 4;" -n1 -r15 -q -oC:\SQL\ostresslog\workload_wwi_regress -dWideWorldImporters -T146

-- -n number of connections processing each input file/query - stress mode
-- -r number of iterations for each connection to execute its input file/query
-- -q quiet mode; suppress all query output
-- -o output directory to write query results and log file
-- -d database name

-- "c:\Program Files\Microsoft Corporation\RMLUtils\ostress" -E -Q"EXEC Warehouse.GetStockItemsbySupplier 4;" -n1 -r15 -q -oC:\SQL\ostresslog\workload_wwi_regress -dWideWorldImporters -T146


SELECT
  qsp.query_plan_hash
  ,avg_duration/1000 as avg_duration_ms
  ,avg_cpu_time/1000 as avg_cpu_ms
  ,last_dop
  ,min_dop
  ,max_dop
FROM
  sys.query_store_runtime_stats qsrs
JOIN
  sys.query_store_plan qsp ON qsrs.plan_id = qsp.plan_id
    and qsp.query_plan_hash = CONVERT(varbinary(8), cast(4128150668158729174 as bigint))
ORDER by
  qsrs.last_execution_time;
GO

SELECT * FROM sys.query_store_plan_feedback;
GO