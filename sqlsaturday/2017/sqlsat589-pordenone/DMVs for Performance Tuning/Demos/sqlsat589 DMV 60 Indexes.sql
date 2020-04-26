------------------------------------------------------------------------
-- Event:        SQL Saturday #589 Pordenone, February 25, 2017        -
--               http://www.sqlsaturday.com/589/eventhome.aspx         -
-- Session:      DMVs for Performance Tuning                           -
-- Demo:         Indici                                                -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [TPC-E];
GO

-- Quali sono le tabelle più grandi nei database critici per l'azienda?
-- Come sono indicizzate?
EXEC sp_spaceused '';
GO


WITH spaceused AS
(
  SELECT
    sys.dm_db_partition_stats.object_id
    ,reservedpages = SUM(reserved_page_count)
    ,it_reservedpages = SUM(ISNULL(its.it_reserved_page_count, 0))
    ,usedpages = SUM(used_page_count)
    ,it_usedpages = SUM(ISNULL(its.it_used_page_count, 0))
    ,pages = SUM(CASE
                   WHEN (index_id < 2) THEN (in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count)
                   ELSE lob_used_page_count + row_overflow_used_page_count
                 END
                )
    ,row_Count = SUM(CASE WHEN (index_id < 2) THEN row_count ELSE 0 END)
  FROM
    sys.dm_db_partition_stats
  JOIN
    sys.objects ON sys.objects.object_id=sys.dm_db_partition_stats.object_id
  OUTER APPLY
    (SELECT
       reserved_page_count AS it_reserved_page_count
       ,used_page_count AS it_used_page_count
     FROM
       sys.internal_tables AS it
     WHERE
		   it.parent_id = object_id
		   AND it.internal_type IN (202,204,211,212,213,214,215,216)
		   AND object_id = it.object_id
		) AS its
  WHERE
    sys.objects.type IN ('U', 'V')
  GROUP BY
    sys.dm_db_partition_stats.object_id
)
SELECT
  name = OBJECT_NAME (object_id)
  ,rows = convert (char(11), row_Count)
  ,reserved = LTRIM (STR (reservedpages * 8, 15, 0) + ' KB')
  ,it_reserved = LTRIM (STR (it_reservedpages * 8, 15, 0) + ' KB')
  ,tot_reserved = LTRIM (STR ( (reservedpages + it_reservedpages) * 8, 15, 0) + ' KB')
  ,data = LTRIM (STR (pages * 8, 15, 0) + ' KB')
  ,data_MB = LTRIM (STR ((pages * 8) / 1000.0, 15, 0) + ' MB')
  ,index_size = LTRIM (STR ((CASE WHEN usedpages > pages THEN (usedpages - pages) ELSE 0 END) * 8, 15, 0) + ' KB')
  ,it_index_size = LTRIM (STR ((CASE WHEN it_usedpages > pages THEN (it_usedpages - pages) ELSE 0 END) * 8, 15, 0) + ' KB')
  ,tot_index_size = LTRIM (STR ((CASE WHEN (usedpages + it_usedpages) > pages THEN ((usedpages + it_usedpages) - pages) ELSE 0 END) * 8, 15, 0) + ' KB')
  ,unused = LTRIM (STR ((CASE WHEN reservedpages > usedpages THEN (reservedpages - usedpages) ELSE 0 END) * 8, 15, 0) + ' KB')
FROM
  spaceused
ORDER BY
  pages DESC
OPTION (RECOMPILE);
GO


-- Come è indicizzata la tabella più grande del DB?
EXEC sp_helpindex 'E_TRADE';
GO


-- Statistiche di utilizzo letture/scritture
SELECT
  OBJECT_NAME(s.[object_id]) AS [ObjectName]
  ,i.name AS [IndexName]
  ,i.index_id
  ,reads = (user_seeks + user_scans + user_lookups)
  ,writes = user_updates
  ,i.type_desc AS IndexType
  ,i.fill_factor AS [FillFactor]
FROM
  sys.dm_db_index_usage_stats AS s
INNER JOIN
  sys.indexes AS i ON s.[object_id] = i.[object_id]
LEFT OUTER JOIN
  sys.objects o on i.[object_id] = o.[object_id]
WHERE
  i.[type] <> 0
  AND o.[type] in ('U', 'V')
  AND i.index_id = s.index_id
  AND s.database_id = DB_ID()
ORDER BY
  OBJECT_NAME(s.[object_id])
  ,writes DESC
  ,reads DESC
OPTION (RECOMPILE);
GO


-- Indici non utilizzati (no read, no write)
SELECT
  [Table Name] = OBJECT_NAME(i.[object_id])
  ,[Index Name] = i.name
FROM
  sys.indexes AS i
INNER JOIN
  sys.objects AS o ON i.[object_id] = o.[object_id]
WHERE
  NOT EXISTS (SELECT
                s.index_id
              FROM
                sys.dm_db_index_usage_stats AS s
              WHERE
                s.[object_id] = i.[object_id]
                AND i.index_id = s.index_id
                AND database_id = DB_ID()
			 )
  AND o.[type] IN ('U', 'V')
ORDER BY
  OBJECT_NAME(i.[object_id]) ASC
OPTION (RECOMPILE);
GO


-- Indici non efficienti (writes > reads)
SELECT
  OBJECT_NAME(s.[object_id]) AS [ObjectName]
  ,i.name AS [IndexName]
  ,i.index_id
  ,reads = (user_seeks + user_scans + user_lookups)
  ,writes = user_updates
  ,difference = user_updates - (user_seeks + user_scans + user_lookups)
  ,i.type_desc AS IndexType
  ,i.fill_factor AS [FillFactor]
FROM
  sys.dm_db_index_usage_stats AS s
INNER JOIN
  sys.indexes AS i ON s.[object_id] = i.[object_id]
LEFT OUTER JOIN
  sys.objects o on i.[object_id] = o.[object_id]
WHERE
  i.[type] <> 0
  AND o.[type] in ('U', 'V')
  AND i.index_id = s.index_id
  AND user_updates > (user_seeks + user_scans + user_lookups)
  AND s.database_id = DB_ID()
ORDER BY
  difference
  ,reads
  ,writes
OPTION (RECOMPILE);
GO



-- Missing indexes (sulla base delle query in cache)

-- sys.dm_db_missing_index_groups
-- sys.dm_db_missing_index_group_stats
-- sys.dm_db_missing_index_details

SELECT
  database_name = DB_NAME(d.database_id)
  ,d.statement as fully_qualified_object
  ,d.equality_columns
  ,d.inequality_columns
  ,d.included_columns
  ,gs.user_seeks
  ,gs.avg_user_impact
  ,gs.last_user_seek
  ,gs.last_user_scan
  ,total_columns_to_index = (SELECT COUNT(*) FROM sys.dm_db_missing_index_columns(d.index_handle))
FROM 
  sys.dm_db_missing_index_groups g 
LEFT OUTER JOIN 
  sys.dm_db_missing_index_group_stats gs ON gs.group_handle = g.index_group_handle 
LEFT OUTER JOIN 
  sys.dm_db_missing_index_details d ON g.index_handle = d.index_handle
ORDER BY
  user_seeks DESC
OPTION (RECOMPILE);
GO


SELECT
  *
FROM
  sys.dm_db_missing_index_details;
GO



--CREATE NONCLUSTERED INDEX NCI_E_TRADE_T_CA_ID_T_DTS ON dbo.E_TRADE
--(
--  [T_CA_ID] ASC
--  ,[T_DTS] ASC
--);
--GO


-- Reset wait statistics
-- Eseguire solo in ambiente di test
--DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);
GO



-- Gli indici creati ad-hoc vengono utilizzati da SQL Server?
-- Con quale modalità di accesso?
SELECT 
  [schema_name] = s.[name]
  ,[object_name] = o.[name]
  ,[object_type] = o.[type]
  ,[object_type_desc] = o.[type_desc]
  ,[index_name] = i.[name]
  ,[index_type] = i.[type]
  ,[index_type_desc] = i.[type_desc]
  ,os.[singleton_lookup_count]
  ,os.[range_scan_count]
  ,os.[page_io_latch_wait_count]
  ,os.[page_io_latch_wait_in_ms]
  ,os.[page_lock_wait_count]
FROM 
  sys.dm_db_index_operational_stats(DB_ID(), OBJECT_ID('dbo.E_TRADE'), NULL, NULL) os
JOIN
  sys.indexes i ON i.[object_id] = os.[object_id] AND i.index_id = os.index_id
LEFT OUTER JOIN
  sys.objects o ON i.[object_id] = o.[object_id]
LEFT OUTER JOIN
  sys.schemas s ON o.[schema_id] = s.[schema_id]
ORDER BY
  i.[type]
  ,o.[name]
  ,i.[name]
OPTION (RECOMPILE);
GO


-- Frammentazione indici
-- Query from Glenn Berry
SELECT
  DB_NAME(ps.database_id) AS [Database Name]
  ,OBJECT_NAME(ps.OBJECT_ID) AS [Object Name]
  ,i.name AS [Index Name]
  ,ps.index_id
  ,ps.index_type_desc
  ,ps.avg_fragmentation_in_percent
  ,ps.fragment_count
  ,ps.page_count
  ,i.fill_factor
  ,i.has_filter
  ,i.filter_definition
FROM
  sys.dm_db_index_physical_stats(DB_ID(),NULL, NULL, NULL , N'LIMITED') AS ps
INNER JOIN
  sys.indexes AS i WITH (NOLOCK) ON ps.[object_id] = i.[object_id] AND ps.index_id = i.index_id
WHERE
  ps.database_id = DB_ID()
  AND ps.page_count > 2500
ORDER BY
  ps.avg_fragmentation_in_percent DESC
OPTION (RECOMPILE);
GO