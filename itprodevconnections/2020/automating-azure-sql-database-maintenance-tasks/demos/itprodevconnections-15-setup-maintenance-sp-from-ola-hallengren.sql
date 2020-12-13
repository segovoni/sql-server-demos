-------------------------------------------------------------------------
-- Event:       IT PRO DEV Connections 2020 - December 12, 2020         -
--              https://www.itprodevconnections.gr/                     -
--                                                                      -
-- Session:     Automating Azure SQL Database maintenance tasks         -
-- Demo:        Setup Ola Hallengren's maintenance stored procedures    -
-- Author:      Sergio Govoni                                           -
-- Notes:       --                                                      -
-------------------------------------------------------------------------

-- https://ola.hallengren.com/


USE [ToBeMaintained];
GO

/*

1 - CommandExecute.sql: Stored procedure to execute and log commands
2 - DatabaseIntegrityCheck.sql: Stored procedure to check the integrity of databases
3 - CommandLog.sql: Table to log commands
4 - Queue.sql: Table for processing databases in parallel
5 - QueueDatabase.sql: Table for processing databases in parallel
6 - IndexOptimize.sql: Stored procedure to rebuild and reorganize indexes and update statistics

*/
