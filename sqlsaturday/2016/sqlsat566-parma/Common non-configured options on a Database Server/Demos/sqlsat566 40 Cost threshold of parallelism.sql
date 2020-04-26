------------------------------------------------------------------------
-- Event:        SQL Saturday Parma 2016, November 26                 --
--               http://www.sqlsaturday.com/566/EventHome.aspx        --
-- Session:      Common non-configured options on a Database Server   --
-- Demo:         Cost threshold of parallelism                        --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [AdventureWorks2016];
GO

DBCC FREEPROCCACHE;
GO

-- Running total
-- Traditional set-based solution with parallelism
SELECT
  T.ProductID
  ,T.TransactionDate
  ,T.TransactionType
  ,CASE (T.TransactionType)
     WHEN 'S' THEN (T.Quantity * -1)
     ELSE (T.Quantity)
   END AS Quantity
  ,SUM(
         CASE (T1.TransactionType)
           WHEN 'S' THEN (T1.Quantity * -1)
		   ELSE (T1.Quantity)
	     END
	  ) AS StockLevel
FROM
  Production.TransactionHistory AS T
JOIN
  Production.TransactionHistory AS T1
  ON (T.ProductID = T1.ProductID)
     AND (T1.TransactionID <= T.TransactionID)
GROUP BY
  T.ProductID
  ,T.TransactionDate
  ,T.TransactionType
  ,T.Quantity
  ,T.TransactionID
ORDER BY
  T.ProductID
  ,T.TransactionID;
GO



-- sys.dm_os_waiting_tasks
SELECT * FROM sys.dm_os_waiting_tasks WHERE (session_id > 50);
GO

-- Waiting task
SELECT
  s.session_id
  ,w.blocking_session_id
  ,r.last_wait_type AS r_last_wait_type
  ,r.wait_type AS r_wait_type
  ,w.wait_type AS w_wait_type
  ,t.text
  ,p.query_plan
  ,s.program_name
  ,s.last_request_start_time
  ,w.waiting_task_address
  ,w.blocking_task_address
  ,w.wait_duration_ms
  ,w.resource_description
  ,w.resource_address
  ,s.login_time
  ,s.host_name
FROM
  sys.dm_exec_requests AS r
JOIN
  sys.dm_exec_sessions AS s ON s.session_id=r.session_id
JOIN
  sys.dm_os_waiting_tasks AS w ON w.session_id = r.session_id
CROSS APPLY
  sys.dm_exec_sql_text(r.sql_handle) AS t
CROSS APPLY
  sys.dm_exec_query_plan(r.plan_handle) AS p
WHERE
  (s.is_user_process = 1);
GO


------------------------------------------------------------------------
-- Cost threshold for parallelism                                      -
------------------------------------------------------------------------

USE [master];
GO

EXEC sp_configure;
GO

EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

-- Test, test, test and test again!!
EXEC sp_configure 'cost threshold for parallelism', 50 /* or 40 or 30 */;
GO
RECONFIGURE;
GO



-- Revert to default
EXEC sp_configure 'cost threshold for parallelism', 5
GO
RECONFIGURE;
GO
EXEC sp_configure 'show advanced options', 0;
GO
RECONFIGURE;
GO