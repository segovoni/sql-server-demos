------------------------------------------------------------------------
-- Event:        SQL Saturday #829 Pordenone, February 23, 2019        -
-- Session:      SQL Server Query Optimizer end-to-end                 -
-- https://www.sqlsaturday.com/829/Sessions/Details.aspx?sid=88183     -
-- Demo:         Optimization process                                  -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------


USE [AdventureWorks2017];
GO

------------------------------------------------------------------------
-- The Optimization Process                                            -
------------------------------------------------------------------------


DBCC FREEPROCCACHE;
GO

DBCC TRACEON(3604);

SET STATISTICS TIME ON;
SET STATISTICS IO ON;


DECLARE
  @_msparam_0 NVARCHAR(4000) = N'1'
  ,@_msparam_1 NVARCHAR(4000) = N'dm_exec_plan_attributes'
  ,@_msparam_2 NVARCHAR(4000) = N'sys'

-- TF 8675 will show optimization phases and search times
-- TF 2372 and 2373 show memory consumption during the optimization process
SELECT
  udf.name AS [Name],
  udf.object_id AS [ID],
  udf.create_date AS [CreateDate],
  udf.modify_date AS [DateLastModified],
  ISNULL(sudf.name, N'') AS [Owner],
  CAST(case when udf.principal_id is null then 1 else 0 end AS bit) AS [IsSchemaOwned],
  SCHEMA_NAME(udf.schema_id) AS [Schema],
  CAST(
    case
    when udf.is_ms_shipped = 1 then 1
    when (
          select 
            major_id 
          from 
            sys.extended_properties 
          where 
            major_id = udf.object_id and 
            minor_id = 0 and 
            class = 1 and 
            name = N'microsoft_database_tools_support'
         ) 
         is not null then 1
    else 0
  END AS bit) AS [IsSystemObject],
  usrt.name AS [DataType],
  s1ret_param.name AS [DataTypeSchema],
  ISNULL(baset.name, N'') AS [SystemType],
  CAST(CASE WHEN baset.name IN (N'nchar', N'nvarchar') AND ret_param.max_length <> -1 THEN ret_param.max_length/2 ELSE ret_param.max_length END AS int) AS [Length],
  CAST(ret_param.precision AS int) AS [NumericPrecision],
  CAST(ret_param.scale AS int) AS [NumericScale],
  ISNULL(xscret_param.name, N'') AS [XmlSchemaNamespace],
  ISNULL(s2ret_param.name, N'') AS [XmlSchemaNamespaceSchema],
  ISNULL( (case ret_param.is_xml_document when 1 then 2 else 1 end), 0) AS [XmlDocumentConstraint],
  CASE WHEN usrt.is_table_type = 1 THEN N'structured' ELSE N'' END AS [UserType],
  CAST(ISNULL(OBJECTPROPERTYEX(udf.object_id,N'ExecIsAnsiNullsOn'),0) AS bit) AS [AnsiNullsStatus],
  CAST(ISNULL(OBJECTPROPERTYEX(udf.object_id, N'IsSchemaBound'),0) AS bit) AS [IsSchemaBound],
  CAST(CASE WHEN ISNULL(smudf.definition, ssmudf.definition) IS NULL THEN 1 ELSE 0 END AS bit) AS [IsEncrypted],
  case when amudf.object_id is null then N'' else asmbludf.name end AS [AssemblyName],
  case when amudf.object_id is null then N'' else amudf.assembly_class end AS [ClassName],
  case when amudf.object_id is null then N'' else amudf.assembly_method end AS [MethodName],
  CAST(case when amudf.object_id is null then CAST(smudf.null_on_null_input AS bit) else amudf.null_on_null_input end AS bit) AS [ReturnsNullOnNullInput],
  case when amudf.object_id is null then case isnull(smudf.execute_as_principal_id, -1) when -1 then 1 when -2 then 2 else 3 end else case isnull(amudf.execute_as_principal_id, -1) when -1 then 1 when -2 then 2 else 3 end end AS [ExecutionContext],
  case when amudf.object_id is null then ISNULL(user_name(smudf.execute_as_principal_id),N'') else user_name(amudf.execute_as_principal_id) end AS [ExecutionContextPrincipal],
  CAST(OBJECTPROPERTYEX(udf.object_id, N'IsDeterministic') AS bit) AS [IsDeterministic],
  (case when 'FN' = udf.type then 1 when 'FS' = udf.type then 1 when 'IF' = udf.type then 3 when 'TF' = udf.type then 2 when 'FT' = udf.type then 2 else 0 end) AS [FunctionType],
  CASE WHEN udf.type IN ('FN','IF','TF') THEN 1 WHEN udf.type IN ('FS','FT') THEN 2 ELSE 1 END AS [ImplementationType],
  CAST(ISNULL(OBJECTPROPERTYEX(udf.object_id,N'ExecIsQuotedIdentOn'),0) AS bit) AS [QuotedIdentifierStatus],
  ret_param.name AS [TableVariableName],
  ISNULL(sm.uses_native_compilation,0) AS [IsNativelyCompiled],
  ISNULL(smudf.definition, ssmudf.definition) AS [Definition]
FROM
  sys.all_objects AS udf
LEFT OUTER JOIN
  sys.database_principals AS sudf ON sudf.principal_id = ISNULL(udf.principal_id, (OBJECTPROPERTY(udf.object_id, 'OwnerId')))
LEFT OUTER JOIN
  sys.all_parameters AS ret_param ON ret_param.object_id = udf.object_id and ret_param.is_output = @_msparam_0
LEFT OUTER JOIN
  sys.types AS usrt ON usrt.user_type_id = ret_param.user_type_id
LEFT OUTER JOIN
  sys.schemas AS s1ret_param ON s1ret_param.schema_id = usrt.schema_id
LEFT OUTER JOIN
  sys.types AS baset ON (baset.user_type_id = ret_param.system_type_id and baset.user_type_id = baset.system_type_id) or ((baset.system_type_id = ret_param.system_type_id) and (baset.user_type_id = ret_param.user_type_id) and (baset.is_user_defined = 0) and (baset.is_assembly_type = 1)) 
LEFT OUTER JOIN
  sys.xml_schema_collections AS xscret_param ON xscret_param.xml_collection_id = ret_param.xml_collection_id
LEFT OUTER JOIN
  sys.schemas AS s2ret_param ON s2ret_param.schema_id = xscret_param.schema_id
LEFT OUTER JOIN
  sys.sql_modules AS smudf ON smudf.object_id = udf.object_id
LEFT OUTER JOIN
  sys.system_sql_modules AS ssmudf ON ssmudf.object_id = udf.object_id
LEFT OUTER JOIN
  sys.assembly_modules AS amudf ON amudf.object_id = udf.object_id
LEFT OUTER JOIN
  sys.assemblies AS asmbludf ON asmbludf.assembly_id = amudf.assembly_id
LEFT OUTER JOIN
  sys.all_sql_modules AS sm ON sm.object_id = udf.object_id
WHERE
  (udf.type in ('TF', 'FN', 'IF', 'FS', 'FT'))
  AND (udf.name = @_msparam_1 AND SCHEMA_NAME(udf.schema_id) = @_msparam_2)
OPTION
  (RECOMPILE, QUERYTRACEON 8675/*, QUERYTRACEON 2372, QUERYTRACEON 2373*/);
GO

/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
End of simplification, time: 0.024 net: 0.024 total: 0 net: 0.024

end exploration, tasks: 2148 no total cost time: 0.027 net: 0.027 total: 0 net: 0.051

end exploration, tasks: 2149 no total cost time: 0 net: 0 total: 0 net: 0.052

end exploration, tasks: 7532 no total cost time: 0.021 net: 0.021 total: 0 net: 0.073

end exploration, tasks: 7533 no total cost time: 0 net: 0 total: 0 net: 0.074

end search(0),  cost: 1.41516 tasks: 7533 time: 0 net: 0 total: 0 net: 0.074

*** Optimizer time out abort at task 7533 ***

End of post optimization rewrite, time: 0.002 net: 0.002 total: 0 net: 0.076

End of query plan compilation, time: 0.004 net: 0.004 total: 0 net: 0.08

SQL Server parse and compile time: 
   CPU time = 86 ms, elapsed time = 86 ms.

(1 row affected)
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'sysschobjs'. Scan count 3, logical reads 105, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'sysclsobjs'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'sysnsobjs'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'sysscalartypes'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'syscolpars'. Scan count 1, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'syscolpars'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'syspalnames'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'sysowners'. Scan count 0, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'syssingleobjrefs'. Scan count 1, logical reads 8, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

(1 row affected)

 SQL Server Execution Times:
   CPU time = 32 ms,  elapsed time = 68 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
*/
GO


DECLARE
  @_msparam_3 NVARCHAR(4000) = N'1'
  ,@_msparam_4 NVARCHAR(4000) = N'dm_exec_plan_attributes'
  ,@_msparam_5 NVARCHAR(4000) = N'sys'


-- TF 8671 prevents the optimization process stopping due to a "Good Enough Plan found"
-- TF 8675 will show optimization phases and search times
-- TF 8780 gives "more time" to the Query Optimizer
-- TF 2372 and 2373 show memory consumption during the optimization process
SELECT
  udf.name AS [Name],
  udf.object_id AS [ID],
  udf.create_date AS [CreateDate],
  udf.modify_date AS [DateLastModified],
  ISNULL(sudf.name, N'') AS [Owner],
  CAST(case when udf.principal_id is null then 1 else 0 end AS bit) AS [IsSchemaOwned],
  SCHEMA_NAME(udf.schema_id) AS [Schema],
  CAST(
    case
    when udf.is_ms_shipped = 1 then 1
    when (
          select 
            major_id 
          from 
            sys.extended_properties 
          where 
            major_id = udf.object_id and 
            minor_id = 0 and 
            class = 1 and 
            name = N'microsoft_database_tools_support'
         ) 
         is not null then 1
    else 0
  END AS bit) AS [IsSystemObject],
  usrt.name AS [DataType],
  s1ret_param.name AS [DataTypeSchema],
  ISNULL(baset.name, N'') AS [SystemType],
  CAST(CASE WHEN baset.name IN (N'nchar', N'nvarchar') AND ret_param.max_length <> -1 THEN ret_param.max_length/2 ELSE ret_param.max_length END AS int) AS [Length],
  CAST(ret_param.precision AS int) AS [NumericPrecision],
  CAST(ret_param.scale AS int) AS [NumericScale],
  ISNULL(xscret_param.name, N'') AS [XmlSchemaNamespace],
  ISNULL(s2ret_param.name, N'') AS [XmlSchemaNamespaceSchema],
  ISNULL( (case ret_param.is_xml_document when 1 then 2 else 1 end), 0) AS [XmlDocumentConstraint],
  CASE WHEN usrt.is_table_type = 1 THEN N'structured' ELSE N'' END AS [UserType],
  CAST(ISNULL(OBJECTPROPERTYEX(udf.object_id,N'ExecIsAnsiNullsOn'),0) AS bit) AS [AnsiNullsStatus],
  CAST(ISNULL(OBJECTPROPERTYEX(udf.object_id, N'IsSchemaBound'),0) AS bit) AS [IsSchemaBound],
  CAST(CASE WHEN ISNULL(smudf.definition, ssmudf.definition) IS NULL THEN 1 ELSE 0 END AS bit) AS [IsEncrypted],
  case when amudf.object_id is null then N'' else asmbludf.name end AS [AssemblyName],
  case when amudf.object_id is null then N'' else amudf.assembly_class end AS [ClassName],
  case when amudf.object_id is null then N'' else amudf.assembly_method end AS [MethodName],
  CAST(case when amudf.object_id is null then CAST(smudf.null_on_null_input AS bit) else amudf.null_on_null_input end AS bit) AS [ReturnsNullOnNullInput],
  case when amudf.object_id is null then case isnull(smudf.execute_as_principal_id, -1) when -1 then 1 when -2 then 2 else 3 end else case isnull(amudf.execute_as_principal_id, -1) when -1 then 1 when -2 then 2 else 3 end end AS [ExecutionContext],
  case when amudf.object_id is null then ISNULL(user_name(smudf.execute_as_principal_id),N'') else user_name(amudf.execute_as_principal_id) end AS [ExecutionContextPrincipal],
  CAST(OBJECTPROPERTYEX(udf.object_id, N'IsDeterministic') AS bit) AS [IsDeterministic],
  (case when 'FN' = udf.type then 1 when 'FS' = udf.type then 1 when 'IF' = udf.type then 3 when 'TF' = udf.type then 2 when 'FT' = udf.type then 2 else 0 end) AS [FunctionType],
  CASE WHEN udf.type IN ('FN','IF','TF') THEN 1 WHEN udf.type IN ('FS','FT') THEN 2 ELSE 1 END AS [ImplementationType],
  CAST(ISNULL(OBJECTPROPERTYEX(udf.object_id,N'ExecIsQuotedIdentOn'),0) AS bit) AS [QuotedIdentifierStatus],
  ret_param.name AS [TableVariableName],
  ISNULL(sm.uses_native_compilation,0) AS [IsNativelyCompiled],
  ISNULL(smudf.definition, ssmudf.definition) AS [Definition]
FROM
  sys.all_objects AS udf
LEFT OUTER JOIN
  sys.database_principals AS sudf ON sudf.principal_id = ISNULL(udf.principal_id, (OBJECTPROPERTY(udf.object_id, 'OwnerId')))
LEFT OUTER JOIN
  sys.all_parameters AS ret_param ON ret_param.object_id = udf.object_id and ret_param.is_output = @_msparam_3
LEFT OUTER JOIN
  sys.types AS usrt ON usrt.user_type_id = ret_param.user_type_id
LEFT OUTER JOIN
  sys.schemas AS s1ret_param ON s1ret_param.schema_id = usrt.schema_id
LEFT OUTER JOIN
  sys.types AS baset ON (baset.user_type_id = ret_param.system_type_id and baset.user_type_id = baset.system_type_id) or ((baset.system_type_id = ret_param.system_type_id) and (baset.user_type_id = ret_param.user_type_id) and (baset.is_user_defined = 0) and (baset.is_assembly_type = 1)) 
LEFT OUTER JOIN
  sys.xml_schema_collections AS xscret_param ON xscret_param.xml_collection_id = ret_param.xml_collection_id
LEFT OUTER JOIN
  sys.schemas AS s2ret_param ON s2ret_param.schema_id = xscret_param.schema_id
LEFT OUTER JOIN
  sys.sql_modules AS smudf ON smudf.object_id = udf.object_id
LEFT OUTER JOIN
  sys.system_sql_modules AS ssmudf ON ssmudf.object_id = udf.object_id
LEFT OUTER JOIN
  sys.assembly_modules AS amudf ON amudf.object_id = udf.object_id
LEFT OUTER JOIN
  sys.assemblies AS asmbludf ON asmbludf.assembly_id = amudf.assembly_id
LEFT OUTER JOIN
  sys.all_sql_modules AS sm ON sm.object_id = udf.object_id
WHERE
  (udf.type in ('TF', 'FN', 'IF', 'FS', 'FT'))
  AND (udf.name = @_msparam_4 AND SCHEMA_NAME(udf.schema_id) = @_msparam_5)
OPTION
  (RECOMPILE, /*QUERYTRACEON 2372, QUERYTRACEON 2373,*/
              QUERYTRACEON 8671, QUERYTRACEON 8675, QUERYTRACEON 8780);
GO


/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 4 ms, elapsed time = 4 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
End of simplification, time: 0.025 net: 0.025 total: 0 net: 0.025

end exploration, tasks: 2148 no total cost time: 0.031 net: 0.031 total: 0 net: 0.056

end exploration, tasks: 2149 no total cost time: 0 net: 0 total: 0 net: 0.056

end exploration, tasks: 8661 no total cost time: 0.03 net: 0.03 total: 0 net: 0.087

end exploration, tasks: 8662 no total cost time: 0 net: 0 total: 0 net: 0.087

end search(0),  cost: 1.41516 tasks: 8662 time: 0 net: 0 total: 0 net: 0.087

end exploration, tasks: 9075 Cost = 1.41516 time: 0.003 net: 0.003 total: 0 net: 0.09

end exploration, tasks: 9076 Cost = 1.41516 time: 0 net: 0 total: 0 net: 0.091

end exploration, tasks: 13817 Cost = 1.41516 time: 0.031 net: 0.031 total: 0 net: 0.122

end exploration, tasks: 13818 Cost = 1.41516 time: 0 net: 0 total: 0 net: 0.122

end search(1),  cost: 0.867731 tasks: 13818 time: 0 net: 0 total: 0 net: 0.122

end exploration, tasks: 18418 Cost = 0.867731 time: 0.088 net: 0.088 total: 0 net: 0.211

end exploration, tasks: 18419 Cost = 0.867731 time: 0 net: 0 total: 0 net: 0.211

end exploration, tasks: 47676 Cost = 0.867731 time: 0.213 net: 0.213 total: 0 net: 0.425

end exploration, tasks: 47677 Cost = 0.867731 time: 0 net: 0 total: 0 net: 0.425

end search(2),  cost: 0.657154 tasks: 47677 time: 0 net: 0 total: 0 net: 0.425

End of post optimization rewrite, time: 0.005 net: 0.005 total: 0 net: 0.431

End of query plan compilation, time: 0.004 net: 0.004 total: 0 net: 0.435

SQL Server parse and compile time: 
   CPU time = 438 ms, elapsed time = 445 ms.

(1 row affected)
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'sysschobjs'. Scan count 2, logical reads 47, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'syssingleobjrefs'. Scan count 1, logical reads 12, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'sysscalartypes'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'sysclsobjs'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'sysnsobjs'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'syscolpars'. Scan count 1, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'syscolpars'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'syspalnames'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'sysowners'. Scan count 0, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

(1 row affected)

 SQL Server Execution Times:
   CPU time = 16 ms,  elapsed time = 126 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
*/
GO





------------------------------------------------------------------------
-- sys.dm_exec_query_optimizer_info                                    -
------------------------------------------------------------------------


-- Returns detailed statistics about the operation of the Query Optimizer
-- All values are cumulative since the system starts

-- You can use this DMV when tuning a workload to identify query optimization 
-- problems or improvements

-- counter = The name of the optimizer event
-- occurrence = The number of occurrences of the optimization event for this counter
-- value = The average value per event occurrence

SELECT * FROM sys.dm_exec_query_optimizer_info;
GO


-- What's this query for?
-- Its goal is to understand better the workload!

-- Detailed statistics from the Query Optimizer

-- Thanks to the result of this CTE we can observe the percentage of trivial plan,
-- the percentage of plans generated by these phases: search 0, 1 and 2.

-- We can also observe the percentage of time-out, with time-out, I intend the end of the time
-- assigned to the optimization phases

WITH QO AS
(
  SELECT
    occurrence
  FROM
    sys.dm_exec_query_optimizer_info
  WHERE
    ([counter] = 'optimizations')
),
QOInfo AS
(
  SELECT
    [counter]
    ,[%] = CAST((occurrence * 100.00)/(SELECT occurrence FROM QO) AS DECIMAL(5, 2))
  FROM
    sys.dm_exec_query_optimizer_info
  WHERE
    [counter] IN (
                   'optimizations'
                   ,'trivial plan'
                   ,'no plan'
                   ,'search 0'
                   ,'search 1'
                   ,'search 2'
                   ,'timeout'
                   ,'memory limit exceeded'
                   ,'contains subquery'
                   ,'view reference'
                   ,'remote query'
                   ,'dynamic cursor request'
                   ,'fast forward cursor request'
	               )
)
SELECT
  [optimizations] AS [optimizations %]
  ,[trivial plan] AS [trivial plan %]
  ,[no plan] AS [no plan %]
  ,[search 0] AS [search 0 %]
  ,[search 1] AS [search 1 %]
  ,[search 2] AS [search 2 %]
  ,[timeout] AS [timeout %]
  ,[memory limit exceeded] AS [memory limit exceeded %]
  ,[contains subquery] AS [contains subquery %]
  ,[view reference] AS [view reference %]
  ,[remote query] AS [remote query %]
  ,[dynamic cursor request] AS [dynamic cursor request %]
  ,[fast forward cursor request] AS [fast forward cursor request %]
FROM
  QOInfo
PIVOT (MAX([%]) FOR [counter] 
  IN ([optimizations]
      ,[trivial plan]
      ,[no plan]
      ,[search 0]
      ,[search 1]
      ,[search 2]
      ,[timeout]
      ,[memory limit exceeded]
      ,[contains subquery]
      ,[view reference]
      ,[remote query]
      ,[dynamic cursor request]
      ,[fast forward cursor request])) AS p;
GO


-- Extended events mapped values
SELECT
  *
FROM
  sys.dm_xe_map_values
WHERE
  (name Like '%optimizer%');
GO