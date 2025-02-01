------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2025, Feb 22                 --
--               https://bit.ly/datasatpordenone25                    --
--                                                                    --
-- Session:      Optimized Locking in Azure SQL Database:             --
--               Concurrency and performance at the next level!       --
--                                                                    --
-- Demo:         EXEC sp_update_posts_viewcount session 2             --
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

-- Azure SQL default time zone is UTC
WAITFOR TIME '00:43';

BEGIN TRANSACTION;

EXEC dbo.sp_update_posts_viewcount;

COMMIT;
GO