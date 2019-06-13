------------------------------------------------------------------------
-- Event:        Delphi Day 2019, Piacenza, June 6 2019               --
--               https://www.delphiday.it/                            --
-- Session:      SQL Server Query Store e Automatic Tuning            --
-- Demo:         Query Store in action                                --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------


/*

DBCC FREEPROCCACHE;

SELECT * FROM dbo.Tab_A WHERE (col1= 1) AND (col2= 1) 

*/


USE [QueryStore];
GO


SELECT * FROM sys.query_store_query_text;
GO


-- Take a look into the Query Store
WITH CTE_Query_Store AS
(
  SELECT
    --TOP 50
    SUM(rs.count_executions) AS count_exec
    ,q.query_text_id
    ,q.query_id
    ,p.plan_id
    ,SUM(rs.avg_cpu_time * rs.count_executions)/1000.0/1000.0 AS total_cpu_sec

    -- The avarerage in second concerning the use of CPU
	,SUM(rs.avg_cpu_time * rs.count_executions)/SUM(count_executions) AS avg_cpu
    ,SUM(rs.avg_cpu_time * rs.count_executions)/SUM(count_executions)/1000.0/1000.0 AS avg_cpu_sec
    ,MAX(max_cpu_time)/1000.0/1000.0 AS max_cpu_sec
		  
    ,COUNT(DISTINCT p.plan_id) AS count_of_plans
    ,SUM(rs.avg_rowcount * rs.count_executions)/SUM(rs.count_executions) AS avg_rowcount
    ,SUM(rs.avg_physical_io_reads * rs.count_executions) AS total_physical_io_reads
    ,SUM(rs.avg_physical_io_reads * rs.count_executions)/SUM(rs.count_executions) AS avg_physical_io_reads
    ,SUM(rs.avg_logical_io_reads  * rs.count_executions) AS total_logical_io_reads
    ,SUM(rs.avg_logical_io_reads  * rs.count_executions)/SUM(rs.count_executions) AS avg_logical_io_reads
    ,SUM(rs.avg_dop * rs.count_executions)/SUM(rs.count_executions) AS avg_dop
  FROM
    sys.query_store_query_text AS qt
  INNER JOIN
    sys.query_store_query AS q ON qt.query_text_id = q.query_text_id
  INNER JOIN
    sys.query_store_plan p ON q.query_id = p.query_id
  INNER JOIN
    sys.query_store_runtime_stats rs ON p.plan_id = rs.plan_id
  WHERE
    (qt.query_sql_text NOT LIKE '%query_store%')
    -- QueryStore Or TPC-E database
	AND ( (qt.query_sql_text LIKE '%Tab_A%') OR (qt.query_sql_text LIKE '%E_TRADE%') )
  GROUP BY
    q.query_text_id
	,q.query_id
	,p.plan_id
),
CTE_Query_Store_Text AS
(
  SELECT
    qs_text.query_sql_text
	,CAST(qs_plan.query_plan AS XML) query_plan_xml
	,CTE_Query_Store.*
  FROM
    CTE_Query_Store
  CROSS APPLY
    (
	  SELECT qsst.query_sql_text
	  FROM sys.query_store_query_text AS qsst
	  WHERE qsst.query_text_id=CTE_Query_Store.query_text_id
	) AS qs_text
  CROSS APPLY
    (
	  SELECT qsp.query_plan
	  FROM sys.query_store_plan AS qsp
	  WHERE qsp.plan_id=CTE_Query_Store.plan_id
	) AS qs_plan
)
SELECT
  *
FROM
  CTE_Query_Store_Text
ORDER BY
  query_id, total_cpu_sec
GO






-- Force a plan @plan_id=1 for a particular query @query_id=1
EXEC sp_query_store_force_plan @query_id = 1, @plan_id = 1;
GO




-- View all the forced plans
SELECT
  CAST(query_plan AS XML) AS xml_query_plan
  ,*
FROM
  sys.query_store_plan
WHERE
  (is_forced_plan = 1);
GO



-- Unforce a plan for a particular query
--EXEC sp_query_store_unforce_plan @query_id = 1, @plan_id = 1;
--GO




-- Whoever loves T-SQL language will find this CTE interesting
-- Growth rate
WITH QS_Growth_Rate AS
(
  SELECT
    ROW_NUMBER() OVER(PARTITION BY q.query_text_id ORDER BY SUM(rs.avg_cpu_time * rs.count_executions)/SUM(count_executions)/1000.0/1000.0 ASC) AS rnumb
    ,SUM(rs.count_executions) AS count_exec
    ,q.query_text_id
    ,q.query_id
    ,p.plan_id
    -- The avarerage in second concerning the use of CPU
    --,CAST(SUM(rs.avg_cpu_time * rs.count_executions)/1000.0/1000.0 AS DECIMAL(11, 6)) AS total_cpu_sec
    ,CAST(SUM(rs.avg_cpu_time * rs.count_executions)/SUM(count_executions)/1000.0/1000.0 AS DECIMAL(11, 6)) AS avg_cpu_sec
  FROM
    sys.query_store_query_text AS qt
  INNER JOIN
    sys.query_store_query AS q ON qt.query_text_id = q.query_text_id
  INNER JOIN
    sys.query_store_plan p ON q.query_id = p.query_id
  INNER JOIN
    sys.query_store_runtime_stats rs ON p.plan_id = rs.plan_id
  WHERE
    (qt.query_sql_text NOT LIKE '%query_store%')
    -- QueryStore Or TPC-E database
	AND ( (qt.query_sql_text LIKE '%Tab_A%') OR (qt.query_sql_text LIKE '%E_TRADE%') )
  GROUP BY
    q.query_text_id
	,q.query_id
	,p.plan_id
),
QS_Growth_Rate_Text AS
(
  SELECT
    SUM(C.rnumb) OVER (PARTITION BY C.query_text_id) AS sum_rnumb
    ,qs_text.query_sql_text
	,CAST(qs_plan.query_plan AS XML) query_plan_xml
    ,LAG(C.avg_cpu_sec, 1, NULL) OVER (PARTITION BY C.query_text_id ORDER BY C.avg_cpu_sec ASC) AS [avg_cpu_sec - 1]
	,C.*
  FROM
    QS_Growth_Rate AS C
  -- Query text
  CROSS APPLY
    (SELECT qsst.query_sql_text FROM sys.query_store_query_text AS qsst WHERE qsst.query_text_id=C.query_text_id) AS qs_text
  -- Query plan
  CROSS APPLY
    (SELECT qsp.query_plan FROM sys.query_store_plan AS qsp WHERE qsp.plan_id=C.plan_id) AS qs_plan
)
SELECT
  C1.query_sql_text
  ,C1.query_plan_xml
  ,C1.rnumb
  ,C1.sum_rnumb
  ,C1.count_exec
  ,C1.query_text_id
  ,C1.plan_id
  ,C1.avg_cpu_sec
  ,C1.[avg_cpu_sec - 1]
  -- Growth rate: ((present - past) / past) * 100
  ,[growth_rate %] = CAST(ROUND(((C1.avg_cpu_sec - C1.[avg_cpu_sec - 1]) / C1.[avg_cpu_sec - 1]) * 100, 0) AS DECIMAL(10, 0))
FROM
  QS_Growth_Rate_Text AS C1
WHERE
  (avg_cpu_sec <> 0.0)
  AND sum_rnumb > 1
ORDER BY
  query_id, avg_cpu_sec;
GO