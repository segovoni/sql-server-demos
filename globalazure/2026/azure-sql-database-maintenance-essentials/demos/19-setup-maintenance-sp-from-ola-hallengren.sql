------------------------------------------------------------------------
-- Event:        Global Azure 2026 - Pordenone, April 18              --
--               https://globalazure.net/                             --
--                                                                    --
-- Session:      Azure SQL Database Maintenance Essentials            --
--                                                                    --
-- Demo:         Setup maintenance solution of Ola Hallengren         --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

-- https://ola.hallengren.com/

-- Connect to Azure SQL Database you want to maintain and run the
-- following script to create the maintenance solution of Ola Hallengren

/*

1 - CommandExecute.sql: Stored procedure to execute and log commands

2 - DatabaseIntegrityCheck.sql: Stored procedure to check the integrity of databases

3 - CommandLog.sql: Table to log commands

4 - Queue.sql: Table for processing databases in parallel

5 - QueueDatabase.sql: Table for processing databases in parallel

6 - IndexOptimize.sql: Stored procedure to rebuild and reorganize indexes and update statistics

*/