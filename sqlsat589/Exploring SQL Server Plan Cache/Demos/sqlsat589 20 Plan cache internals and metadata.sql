------------------------------------------------------------------------
-- Event:        SQL Saturday #589 Pordenone, February 25, 2017        -
--               http://www.sqlsaturday.com/589/eventhome.aspx         -
-- Session:      Exploring SQL Server Plan Cache                       -
-- Demo:         Plan Cache Internals                                  -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [master];
GO



SELECT
  pages_mb = (pages_kb/1000.00)
  ,*
FROM
  sys.dm_os_memory_cache_counters
WHERE
  type IN ('CACHESTORE_OBJCP', 'CACHESTORE_SQLCP', 'CACHESTORE_PHDR', 'CACHESTORE_XPROC');
GO


-- Each plan cache store contains a hash table to keep track of all the plans in that particular store
SELECT
  * 
FROM
  sys.dm_os_memory_cache_hash_tables
WHERE
  type IN ('CACHESTORE_OBJCP', 'CACHESTORE_SQLCP', 'CACHESTORE_PHDR', 'CACHESTORE_XPROC');
GO


SELECT * FROM sys.dm_exec_cached_plans;
GO



------------------------------------------------------------------------
-- View sp_cacheobjects                                                -
-- Credits to Kalen Delaney (www.SQLServerInternals.com)               -
------------------------------------------------------------------------

IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'sp_cacheobjects')
  DROP VIEW sp_cacheobjects;
GO

CREATE VIEW sp_cacheobjects(bucketid, cacheobjtype, objtype, objid, dbid, dbidexec, uid, refcounts, 

                        usecounts, pagesused, setopts, langid, dateformat, status, lasttime, maxexectime, avgexectime, lastreads,

                        lastwrites, sqlbytes, sql) 
AS
            -- Credits to Kalen Delaney (www.SQLServerInternals.com)
            SELECT            pvt.bucketid, CONVERT(nvarchar(19), pvt.cacheobjtype) as cacheobjtype, pvt.objtype, 
                                    CONVERT(int, pvt.objectid)as object_id, CONVERT(smallint, pvt.dbid) as dbid,
                                    CONVERT(smallint, pvt.dbid_execute) as execute_dbid, CONVERT(smallint, pvt.user_id) as user_id,
                                    pvt.refcounts, pvt.usecounts, pvt.size_in_bytes / 8192 as size_in_bytes,
                                    CONVERT(int, pvt.set_options) as setopts, CONVERT(smallint, pvt.language_id) as langid,
                                    CONVERT(smallint, pvt.date_format) as date_format, CONVERT(int, pvt.status) as status,
                                    CONVERT(bigint, 0), CONVERT(bigint, 0), CONVERT(bigint, 0), CONVERT(bigint, 0), CONVERT(bigint, 0), 
                                    CONVERT(int, LEN(CONVERT(nvarchar(max), fgs.text)) * 2), CONVERT(nvarchar(3900), fgs.text)

            FROM (SELECT ecp.*, epa.attribute, epa.value
                        FROM sys.dm_exec_cached_plans ecp 
                OUTER APPLY sys.dm_exec_plan_attributes(ecp.plan_handle) epa) as ecpa
                   PIVOT (MAX(ecpa.value) for ecpa.attribute IN ([set_options], [objectid], [dbid], [dbid_execute], [user_id], [language_id], [date_format], [status])) as pvt
                       OUTER APPLY sys.dm_exec_sql_text(pvt.plan_handle) fgs
         WHERE cacheobjtype like 'Compiled%';
GO



USE [AdventureWorks];
GO


SELECT * FROM sp_cacheobjects WHERE dbid = DB_ID('AdventureWorks');
GO
