------------------------------------------------------------------------
-- Event:        Delphi Day 2026 - June 09-10                         --
--               https://www.delphiday.it/                            --
--                                                                    --
-- Session:      Azure SQL Database Essentials                        --
--                                                                    --
-- Demo:         Database firewall                                    --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

-- Connect to Azure SQL Database logical instance for maintenance
-- azure-sql-delphi-day-2026

/*
USE [AdventureWorksLT];
GO
*/

-- https://learn.microsoft.com/sql/relational-databases/system-stored-procedures/sp-set-database-firewall-rule-azure-sql-database

EXECUTE sp_set_database_firewall_rule
  @name = N'Delphi Day 2026 database firewall rule'
  ,@start_ip_address = '72.146.34.126'
  ,@end_ip_address = '72.146.34.126';
GO



-- https://learn.microsoft.com/sql/relational-databases/system-catalog-views/sys-firewall-rules-azure-sql-database
-- Returns information about the server-level firewall settings
SELECT
  *
FROM
  master.sys.firewall_rules;
GO


-- https://learn.microsoft.com/sql/relational-databases/system-catalog-views/sys-database-firewall-rules-azure-sql-database
SELECT
  *
FROM
  sys.database_firewall_rules;
GO



/*
EXECUTE sp_delete_database_firewall_rule
  @name = N'Delphi Day 2026 database firewall rule';
GO
*/


-- Private endpoint configuration

-- nslookup azure-sql-delphi-day-2026.database.windows.net