------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2025, November 29                --
--               https://bit.ly/43exQYm                               --
--                                                                    --
-- Session:      SQL Server 2025: Optimized Locking in action         --
--                                                                    --
-- Demo:         EXEC sp_update_posts_viewcount session 1             --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [StackOverflow2010];
GO


/*
SELECT @@SPID;
GO
*/


/* Session 1 */

-- Be careful, Azure SQL default time zone is UTC
WAITFOR TIME '11:53';

BEGIN TRANSACTION;

EXEC dbo.sp_update_posts_viewcount;

COMMIT;
GO