------------------------------------------------------------------------
-- Event:    Data Saturday Parma 2022, November 26                    --
--           https://datasaturdays.com/2022-11-26-datasaturday0022/   --
--                                                                    --
-- Session:  SQL Server 2022 Parameter Sensitive Plan Optimization    --
--                                                                    --
-- Demo:     Parameter Sensitive Plan (PSP) Optimization              --
-- Author:   Sergio Govoni                                            --
-- Notes:    --                                                       --
------------------------------------------------------------------------

USE [PSP];
GO


CREATE OR ALTER PROCEDURE dbo.Tab_A_Search
(
  @ACol1 INTEGER
  ,@ACol2 INTEGER
)
AS BEGIN
  SELECT * FROM dbo.Tab_A WHERE (Col1 = @ACol1) AND (Col2 = @ACol2);
END;
GO


-- The following query shows the histogram steps that portray
-- the data distribution on the Col1 column
SELECT
  sh.* 
FROM
  sys.stats AS s
CROSS APPLY
  sys.dm_db_stats_histogram(s.object_id, s.stats_id) AS sh
WHERE
  (name = 'IDX_Tab_A_Col1')
  AND (s.object_id = OBJECT_ID('dbo.Tab_A'));
GO


-- Similar situation for the IDX_Tab_A_Col2 index
SELECT
  sh.* 
FROM
  sys.stats AS s
CROSS APPLY
  sys.dm_db_stats_histogram(s.object_id, s.stats_id) AS sh
WHERE
  (name = 'IDX_Tab_A_Col2')
  AND (s.object_id = OBJECT_ID('dbo.Tab_A'));
GO

SET STATISTICS IO ON;
GO


EXEC dbo.Tab_A_Search @ACol1 = 33, @ACol2 = 33;
GO 3

--  <ParameterList>
--    <ColumnReference Column="@ACol2" ParameterDataType="int" ParameterCompiledValue="(33)" />
--    <ColumnReference Column="@ACol1" ParameterDataType="int" ParameterCompiledValue="(33)" />
--  </ParameterList>


-- Let's search the rows with Col1 equal to 1 and Col2 equal to 1
EXEC dbo.Tab_A_Search @ACol1 = 1, @ACol2 = 1;
GO

-- (500001 rows affected)
-- Table 'Tab_A'. Scan count 1, logical reads 501121, physical reads 0...
-- Table 'Worktable'. Scan count 0, logical reads 0...

SELECT (501121 * 8)/1000.0/1000.0 AS GB;
GO


--  <ParameterList>
--    <ColumnReference Column="@ACol2" ParameterDataType="int" ParameterCompiledValue="(33)" ParameterRuntimeValue="(1)" />
--    <ColumnReference Column="@ACol1" ParameterDataType="int" ParameterCompiledValue="(33)" ParameterRuntimeValue="(1)" />
--  </ParameterList>


EXEC dbo.Tab_A_Search @ACol1 = 33, @ACol2 = 25;
GO 4

--  <ParameterList>
--    <ColumnReference Column="@ACol2" ParameterDataType="int" ParameterCompiledValue="(33)" ParameterRuntimeValue="(25)" />
--    <ColumnReference Column="@ACol1" ParameterDataType="int" ParameterCompiledValue="(33)" ParameterRuntimeValue="(33)" />
--  </ParameterList>


SELECT
  usecounts
  ,plan_handle
  ,objtype
  ,text
FROM
  sys.dm_exec_cached_plans 
CROSS APPLY
  sys.dm_exec_sql_text (plan_handle)
WHERE
  (text LIKE '%Tab_A%')
--AND
--  (objtype = 'Prepared');
GO

SELECT * FROM sp_cacheobjects WHERE dbid = DB_ID('PSP');
GO



SELECT
  qs.execution_count,  
  SUBSTRING(qt.text,qs.statement_start_offset/2 +1,   
             (CASE WHEN qs.statement_end_offset = -1   
                   THEN LEN(CONVERT(nvarchar(max), qt.text)) * 2   
              ELSE qs.statement_end_offset end -  
                qs.statement_start_offset  
             )/2  
           ) AS query_text,
  qs.query_hash,
  qs.query_plan_hash,
  qs.plan_handle,
  qs.sql_handle,
  qp.query_plan,
  qt.text
FROM
  sys.dm_exec_query_stats AS qs   
CROSS APPLY
  sys.dm_exec_sql_text(qs.sql_handle) AS qt
CROSS APPLY
  sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE
  (qt.text like '%Tab_A%')
ORDER BY
  qs.execution_count DESC; 
GO


-- Min/Max/Last rows
SELECT
  qs.query_plan_hash,
  qs.query_hash,
  qs.execution_count,
  qs.min_rows,
  qs.max_rows,
  qs.last_rows,
  qp.query_plan
FROM
  sys.dm_exec_query_stats AS qs   
CROSS APPLY
  sys.dm_exec_sql_text(qs.sql_handle) AS qt
CROSS APPLY
  sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE
  (qt.text like '%Tab_A%')
ORDER BY
  qs.execution_count DESC; 
GO


SELECT
  qs.query_plan_hash,
  qs.query_hash,
  qs.execution_count,
  qs.min_elapsed_time,
  qs.max_elapsed_time,
  qs.last_elapsed_time,
  qs.min_rows,
  qs.max_rows,
  qs.last_rows,
  qs.last_dop,
  qs.last_grant_kb,
  qs.last_worker_time,
  qp.query_plan
FROM
  sys.dm_exec_query_stats AS qs   
CROSS APPLY
  sys.dm_exec_sql_text(qs.sql_handle) AS qt
CROSS APPLY
  sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE
  (qt.text like '%Tab_A%')
ORDER BY
  qs.execution_count DESC; 
GO


USE [master]
GO

ALTER DATABASE [PSP] SET COMPATIBILITY_LEVEL = 160;
GO
ALTER DATABASE [PSP] SET QUERY_STORE CLEAR ALL
GO

USE [PSP]
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE  
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SENSITIVE_PLAN_OPTIMIZATION = ON
GO


EXEC dbo.Tab_A_Search @ACol1 = 33, @ACol2 = 33;
GO 3

--  <Statements>
--    <StmtSimple StatementCompId="4" StatementEstRows="1" StatementId="1" StatementOptmLevel="FULL" StatementOptmEarlyAbortReason="GoodEnoughPlanFound" CardinalityEstimationModelVersion="160" StatementSubTreeCost="0.00657038" StatementText="SELECT * FROM dbo.Tab_A WHERE (Col1 = @ACol1) AND (Col2 = @ACol2) option 
--    (PLAN PER VALUE(QueryVariantID = 1, predicate_range([PSP].[dbo].[Tab_A].[Col1] = @ACol1, 100.0, 100000.0)))" StatementType="SELECT" QueryHash="0x06F4EC29D5E7DA88" QueryPlanHash="0x2D54CD0E9A78A6AB" RetrievedFromCache="true" StatementSqlHandle="0x090054C2647C2659877392796D2C39CC73000000000000000000000000000000000000000000000000000000" DatabaseContextSettingsId="1" ParentObjectId="0" StatementParameterizationType="1" SecurityPolicyApplied="false">

-- <Dispatcher>
--   <ParameterSensitivePredicate LowBoundary="100" HighBoundary="100000">
--     <StatisticsInfo Database="[PSP]" Schema="[dbo]" Table="[Tab_A]" Statistics="[IDX_Tab_A_Col1]" ModificationCount="0" SamplingPercent="100" LastUpdate="2022-06-02T15:40:49.72" />
--     <Predicate>
--       <ScalarOperator ScalarString="[PSP].[dbo].[Tab_A].[Col1]=[@ACol1]">
--         <Compare CompareOp="EQ">
--           <ScalarOperator>
--             <Identifier>
--               <ColumnReference Database="[PSP]" Schema="[dbo]" Table="[Tab_A]" Column="Col1" />
--             </Identifier>
--           </ScalarOperator>
--           <ScalarOperator>
--             <Identifier>
--               <ColumnReference Column="@ACol1" />
--             </Identifier>
--           </ScalarOperator>
--         </Compare>
--       </ScalarOperator>
--     </Predicate>
--   </ParameterSensitivePredicate>
-- </Dispatcher>


-- Let's search the rows with Col1 equal to 1 and Col2 equal to 2
EXEC dbo.Tab_A_Search @ACol1 = 1, @ACol2 = 1;
GO

--  <Statements>
--    <StmtSimple StatementCompId="2" StatementEstRows="495075" StatementId="1" StatementOptmLevel="FULL" CardinalityEstimationModelVersion="160" StatementSubTreeCost="126.494" StatementText="SELECT * FROM dbo.Tab_A WHERE (Col1 = @ACol1) AND (Col2 = @ACol2) option
--   (PLAN PER VALUE(QueryVariantID = 3, predicate_range([PSP].[dbo].[Tab_A].[Col1] = @ACol1, 100.0, 100000.0)))" StatementType="SELECT" QueryHash="0x06F4EC29D5E7DA88" QueryPlanHash="0xDCC85C0CAA276B99" RetrievedFromCache="true" StatementSqlHandle="0x0900CFF9A016931582F884C2E60143D25C320000000000000000000000000000000000000000000000000000" DatabaseContextSettingsId="1" ParentObjectId="0" StatementParameterizationType="1" SecurityPolicyApplied="false">

-- (500001 rows affected)
-- Table 'Tab_A'. Scan count 1, logical reads 170006, physical reads 0...

SELECT (128339 * 8)/1000.0/1000.0 AS GB;
GO

SELECT
  qs.execution_count,  
  SUBSTRING(qt.text,qs.statement_start_offset/2 +1,   
             (CASE WHEN qs.statement_end_offset = -1   
                   THEN LEN(CONVERT(nvarchar(max), qt.text)) * 2   
              ELSE qs.statement_end_offset end -  
                qs.statement_start_offset  
             )/2  
           ) AS query_text,
  qs.query_hash,
  qs.query_plan_hash,
  qs.plan_handle,
  qs.sql_handle,
  qp.query_plan,
  qt.text
FROM
  sys.dm_exec_query_stats AS qs   
CROSS APPLY
  sys.dm_exec_sql_text(qs.sql_handle) AS qt
CROSS APPLY
  sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE
  (qt.text like '%Tab_A%')
ORDER BY
  qs.execution_count DESC; 
GO

-- Min/Max/Last rows
SELECT
  qs.query_plan_hash,
  qs.query_hash,
  qs.execution_count,
  qs.min_rows,
  qs.max_rows,
  qs.last_rows,
  qp.query_plan
FROM
  sys.dm_exec_query_stats AS qs   
CROSS APPLY
  sys.dm_exec_sql_text(qs.sql_handle) AS qt
CROSS APPLY
  sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE
  (qt.text like '%Tab_A%')
ORDER BY
  qs.execution_count DESC; 
GO


SELECT
  qs.query_plan_hash,
  qs.query_hash,
  qs.execution_count,
  qs.min_elapsed_time,
  qs.max_elapsed_time,
  qs.last_elapsed_time,
  qs.min_rows,
  qs.max_rows,
  qs.last_rows,
  qs.last_dop,
  qs.last_grant_kb,
  qs.last_worker_time,
  qp.query_plan
FROM
  sys.dm_exec_query_stats AS qs   
CROSS APPLY
  sys.dm_exec_sql_text(qs.sql_handle) AS qt
CROSS APPLY
  sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE
  (qt.text like '%Tab_A%')
ORDER BY
  qs.execution_count DESC; 
GO


SELECT * FROM sys.query_store_query_variant;
GO

EXEC sp_helptext 'sys.query_store_query_variant';
GO

/*
CREATE VIEW sys.query_store_query_variant
AS  
  SELECT  
    QM.query_variant_query_id
	,QM.parent_query_id
	,QM.dispatcher_plan_id  
  FROM
    sys.plan_persist_query_variant_in_memory QM
  WHERE
    query_variant_query_id < -1  
  UNION ALL  
  SELECT  
    QV.query_variant_query_id
	,QV.parent_query_id
	,QV.dispatcher_plan_id  
     -- NOLOCK to prevent potential deadlock between QDS_STATEMENT_STABILITY lock and index locks  
  FROM
    sys.plan_persist_query_variant QV WITH (NOLOCK)  
  LEFT OUTER JOIN (  
    SELECT TOP 0   
      query_variant_query_id
	  ,parent_query_id
	  ,dispatcher_plan_id  
    FROM
	  sys.plan_persist_query_variant_in_memory) QVM ON  
    QVM.query_variant_query_id = QV.query_variant_query_id;
GO
*/

-- Dispatcher plan
SELECT 
  p.usecounts
  ,p.cacheobjtype
  ,p.objtype
  ,p.size_in_bytes
  ,t.[text]
  ,qp.query_plan
FROM
  sys.dm_exec_cached_plans p
CROSS APPLY
  sys.dm_exec_sql_text(p.plan_handle) t
CROSS APPLY
  sys.dm_exec_query_plan(p.plan_handle) AS qp 
WHERE
  t.[text] like '%Tab_A%'
--AND
--  p.objtype = 'Prepared'
ORDER BY
  p.objtype DESC;
GO


-- There are currently 38 reasons listed in the XE "psp_skipped_reason_enum"
SELECT
  [name]
  ,map_value
FROM
  sys.dm_xe_map_values 
WHERE
  name = 'psp_skipped_reason_enum' 
ORDER BY
  map_key;
GO


/*
-- Generate the workload for testing parameter sensitive plan (PSP) optimization

-- Download sqlcmdcli from Github https://github.com/segovoni/sqlcmdcli
-- Extract sqlcmdcli to a local folder such as \SQL\Tools\sqlcmdcli
-- Open cmd
-- Move to the folder that contains sqlcmdcli with cd C:\SQL\Tools\sqlcmdcli

-- Execute the sample workload with psp flag
-- sqlcmdcli.exe querystoreworkload -servername:SQL2022 -databasename:PSP -username:sgovoni -password:sgadmin -psp -verbose
*/