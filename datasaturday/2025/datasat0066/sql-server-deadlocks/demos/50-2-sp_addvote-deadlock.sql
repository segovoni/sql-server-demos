------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2025, Feb 22                 --
--               https://bit.ly/datasatpordenone25                    --
--                                                                    --
-- Session:      SQL Server Deadlocks: Techniques to identify         --
--               and resolve them!                                    --
--                                                                    --
-- Demo:         dbo.sp_AddVote session 2                             --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [StackOverflow2010];
GO

BEGIN TRANSACTION;

-- Reboot (UserID = 392730) votes the post ID 4146171
EXEC sp_AddVote @PostId = 4146171, @UserId = 392730, @VoteTypeId = 2;

/*
ROLLBACK;
*/

/*
SELECT
  U.Id AS UserID
  ,U.DisplayName AS UserDisplayName
  ,U.[Location] AS UserLocation
  ,P.ID AS PostID
  ,P.Body AS PostBody
FROM
  dbo.Posts AS P
JOIN
  dbo.Users AS U ON P.OwnerUserId=U.ID
WHERE
  P.ID IN (4146171);
*/