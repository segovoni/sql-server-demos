------------------------------------------------------------------------
-- Event:        SQL Start 2026 - Ancona, September  18               --
--               https://www.sqlstart.it/                             --
--                                                                    --
-- Session:      SQL Server 2025 and Azure SQL: AI comes where        --
--               business data lives                                  --
--                                                                    --
-- Demo:         Setup SQL Server options                             --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [master];
GO


-- In order to call external REST endpoint, we must enable the
-- 'external rest endpoint enabled' server configuration option
EXEC sp_configure 'external rest endpoint enabled', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO

EXEC sp_configure 'external rest endpoint enabled';
GO


-- Full-Text Search
-- Evaluate if it is needed for a search comparison with vector search