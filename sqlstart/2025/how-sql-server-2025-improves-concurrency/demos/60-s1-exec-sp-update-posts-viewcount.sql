------------------------------------------------------------------------
-- Event:        SQL Start 2025 - June 13                             --
--               https://www.sqlstart.it/                             --
--                                                                    --
-- Session:      How SQL Server 2025 improves concurrency             --
--               with Transaction ID Locking and LAQ                  --
--                                                                    --
-- Demo:         EXEC sp_update_posts_viewcount session 1             --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

/*
USE [StackOverflow2010];
GO
*/

/*
SELECT @@SPID;
GO
*/


/* Session 1 */

-- Azure SQL default time zone is UTC
WAITFOR TIME '11:53';

BEGIN TRANSACTION;

EXEC dbo.sp_update_posts_viewcount;

COMMIT;
GO