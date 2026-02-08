------------------------------------------------------------------------
-- Event:        Delphi Day 2025 - June 19-20                         --
--               https://www.delphiday.it/                            --
--                                                                    --
-- Session:      SQL Server 2025: What's new in the database Engine   --
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


/* Session 2 */

-- Azure SQL default time zone is UTC
WAITFOR TIME '17:43';

BEGIN TRANSACTION;

EXEC dbo.sp_update_posts_viewcount;

COMMIT;
GO