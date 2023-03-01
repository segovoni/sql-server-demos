------------------------------------------------------------------------
-- Event:    Data Saturday Pordenone 2023 - February 25               --
--           https://datasaturdays.com/2023-02-25-datasaturday0031/   --
--                                                                    --
-- Session:  SQL Server 2022 Degree of Parallelism Feedback           --
-- Demo:     CXPACKET                                                 --
-- Author:   Sergio Govoni                                            --
-- Notes:    --                                                       --
------------------------------------------------------------------------

USE [master];
GO

/*
-- sys.dm_os_waiting_tasks
SELECT * FROM sys.dm_os_waiting_tasks WHERE (session_id > 50);
GO
*/


-- Waiting task for CXPACKET
-- Looking for the underline root cause
SELECT
  r.session_id
  ,w.blocking_session_id
  ,r.last_wait_type AS r_last_wait_type
  ,r.wait_type AS r_wait_type
  ,w.wait_type AS w_wait_type
  ,t.text
  ,p.query_plan
  ,w.waiting_task_address
  ,w.blocking_task_address
  ,w.wait_duration_ms
  ,w.resource_description
  ,w.resource_address
FROM
  sys.dm_exec_requests AS r
JOIN
  sys.dm_os_waiting_tasks AS w ON w.session_id = r.session_id
CROSS APPLY
  sys.dm_exec_sql_text(r.sql_handle) AS t
CROSS APPLY
  sys.dm_exec_query_plan(r.plan_handle) AS p
WHERE
  (r.session_id > 50);
GO