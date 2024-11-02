------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2024, Nov 23                     --
--               https://bit.ly/datasatparma24                        --
--                                                                    --
-- Session:      SQL Server Deadlocks: Techniques to identify         --
--               and resolve them!                                    --
--                                                                    --
-- Demo:         dbo.sp_AddVote session 1                             --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [StackOverflow2010];
GO

BEGIN TRANSACTION;

-- InvisibleBacon (UserID = 139760) votes the post ID 3712827
EXEC sp_AddVote @PostId = 3712827, @UserId = 139760, @VoteTypeId = 2;

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
  P.ID IN (3712827);
*/