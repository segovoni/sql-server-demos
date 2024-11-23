------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2024, Nov 23                     --
--               https://bit.ly/datasatparma24                        --
--                                                                    --
-- Session:      SQL Server Deadlocks: Techniques to identify         --
--               and resolve them!                                    --
--                                                                    --
-- Demo:         dbo.sp_AddVote v3                                    --
-- Author:       Sergio Govoni                                        --
-- Notes:        Credits to Brent Ozar                                --
------------------------------------------------------------------------

USE [StackOverflow2010];
GO

CREATE OR ALTER PROCEDURE dbo.sp_AddVote
  -- ID of the question or answer
  @PostId INTEGER
  -- ID of the user voting
  ,@UserId INTEGER
  -- Vote type: UpMod (2), DoMod (3), ..., see dbo.VoteTypes
  ,@VoteTypeId INTEGER
AS
BEGIN
  /*
    v3/sp_AddVote
  */
  DECLARE
    @TranCount INTEGER = @@TRANCOUNT;

  BEGIN TRY
    IF (@TranCount = 0)
      -- Open an explicit transaction to avoid auto commits
      BEGIN TRANSACTION;
  
    DECLARE
      @OwnerUserId INTEGER;
  
    -- Check if the user has already voted for this post
    IF EXISTS (SELECT 1 FROM dbo.Votes WHERE PostId = @PostId AND UserId = @UserId)
    BEGIN
      RAISERROR ('User has already voted for this post.', 16, 1);
      RETURN;
    END;
  
    -- Get the ID of the owner user for the post
    SELECT
      @OwnerUserId = OwnerUserId
    FROM
      dbo.Posts
    WHERE
      Id = @PostId;
  
    IF @OwnerUserId IS NULL
    BEGIN
      RAISERROR ('Invalid PostId or post not found.', 16, 1);
      RETURN;
    END;
  
    -- Update LastAccessDate and Reputation
    UPDATE
      USR
    SET
      -- Update LastAccessDate of the user who voted
      USR.LastAccessDate =
        CASE WHEN (USR.Id = @UserId)
          THEN GETDATE()
          ELSE USR.LastAccessDate 
        END
      -- Update reputation of the post owner
      ,USR.Reputation =
        CASE WHEN (USR.Id = @OwnerUserId) 
          THEN USR.Reputation + CASE
                                  WHEN @VoteTypeId = 2 THEN 10
                                  WHEN @VoteTypeId = 3 THEN -2
                                  ELSE 0
                                END
          ELSE USR.Reputation
        END
    FROM
      dbo.Users AS USR
    WHERE
      (
        -- LastAccessDate of the user who voted
        (USR.Id = @UserId) OR
        -- Reputation of the post owner
        (USR.Id = @OwnerUserId)
      );
  
    WAITFOR DELAY '00:00:10';
  
    -- Insert the vote into the Votes table
    INSERT INTO
      dbo.Votes (PostId, UserId, VoteTypeId, CreationDate)
    VALUES
      (@PostId, @UserId, @VoteTypeId, GETDATE());
  
    -- Update score of the post
    UPDATE
      dbo.Posts
    SET
      Score = Score + CASE
                        WHEN @VoteTypeId = 2 THEN 1
                        WHEN @VoteTypeId = 3 THEN -1
                        ELSE 0
                      END
    WHERE
      Id = @PostId;
    
    -- Select the ID of the newly added vote
    SELECT
      SCOPE_IDENTITY() AS VoteId;
  
    -- If no previous transaction, commit the current transaction
    IF (@TranCount = 0) AND (@@ERROR = 0)
      COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    -- Rollback transaction in case of error
    IF (@TranCount = 0) AND (@@TRANCOUNT <> 0) --AND (XACT_STATE() <> 0)  -- Check this XACT_STATE() <> 0
      ROLLBACK TRANSACTION;

    THROW;
  END CATCH
END;
GO
