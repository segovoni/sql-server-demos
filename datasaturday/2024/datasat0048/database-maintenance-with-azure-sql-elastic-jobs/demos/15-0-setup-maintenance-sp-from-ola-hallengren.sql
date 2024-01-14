------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2024 - February 24           --
--               https://bit.ly/3R8aAEM                               --
--                                                                    --
-- Session:      Database maintenance with Azure SQL Elastic Jobs     --
--                                                                    --
-- Demo:         Setup database                                       --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

-- https://ola.hallengren.com/


USE [StackOverflow2010];
GO

/*

1 - CommandExecute.sql: Stored procedure to execute and log commands
2 - DatabaseIntegrityCheck.sql: Stored procedure to check the integrity of databases
3 - CommandLog.sql: Table to log commands
4 - Queue.sql: Table for processing databases in parallel
5 - QueueDatabase.sql: Table for processing databases in parallel
6 - IndexOptimize.sql: Stored procedure to rebuild and reorganize indexes and update statistics

*/
