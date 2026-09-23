------------------------------------------------------------------------
-- Event:        1nn0vAI 2026 - Pordenone, September  26              --
--               https://www.1nn0vai.it/                              --
--                                                                    --
-- Session:      SQL Server 2025 and Azure SQL: AI comes where        --
--               business data lives                                  --
--                                                                    --
-- Demo:         Refresh ai_demo.PostSearchDocuments                  --
-- Author:       Sergio Govoni                                        --
-- Notes:        On-demand update/insert + re-embedding; Agent job    --
------------------------------------------------------------------------

/*
USE [StackOverflowMini];
GO
*/

CREATE OR ALTER PROCEDURE [ai_demo].[usp_RefreshPostSearchDocuments]
  @BatchSize INT = 25
  ,@RebuildVectorIndex BIT = 1
  ,@MaxNewDocuments INT = NULL
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE
    @Rows INT = 1
    ,@InsertLimit INT
    ,@RowsInserted INT = 0
    ,@RowsUpdated INT = 0
    ,@RowsReembedded INT = 0
    ,@IndexDropped BIT = 0
    ,@IndexRebuilt BIT = 0
    ,@EmbeddedDocuments INT
    ,@TotalDocuments INT
    ,@PercentComplete DECIMAL(5, 2)
    ,@ProgressBar NVARCHAR(20)
    ,@ProgressMessage NVARCHAR(200);

  IF OBJECT_ID(N'ai_demo.PostSearchDocuments', N'U') IS NULL
  BEGIN
    THROW 51000, 'Required table [ai_demo].[PostSearchDocuments] does not exist. Run 50-create-semantic-search-table.sql first.', 1;
  END;

  IF OBJECT_ID(N'ai_demo.vw_PostSearchDocumentSource', N'V') IS NULL
  BEGIN
    THROW 51004, 'Required view [ai_demo].[vw_PostSearchDocumentSource] does not exist. Run 50-create-semantic-search-table.sql first.', 1;
  END;

  IF NOT EXISTS
  (
    SELECT
      1
    FROM
      sys.external_models
    WHERE
      [name] = N'AzureOpenAI_text_embedding_ada_002'
  )
  BEGIN
    THROW 51001, 'Required external model [AzureOpenAI_text_embedding_ada_002] does not exist. Run 40-create-external-models.sql first.', 1;
  END;

  IF (@BatchSize IS NULL OR @BatchSize < 1)
  BEGIN
    THROW 51005, '@BatchSize must be greater than 0.', 1;
  END;

  IF (@MaxNewDocuments IS NOT NULL AND @MaxNewDocuments < 1)
  BEGIN
    THROW 51006, '@MaxNewDocuments must be NULL or greater than 0.', 1;
  END;

  SET @InsertLimit = ISNULL(@MaxNewDocuments, 2147483647);

  IF EXISTS
  (
    SELECT
      1
    FROM
      sys.indexes
    WHERE
      [object_id] = OBJECT_ID(N'ai_demo.PostSearchDocuments')
      AND [name] = N'IDX_VECTOR_PostSearchDocuments_Embedding'
  )
  BEGIN
    DROP INDEX [IDX_VECTOR_PostSearchDocuments_Embedding] ON [ai_demo].[PostSearchDocuments];
    SET @IndexDropped = 1;
  END;

  UPDATE
    T
  SET
    T.AcceptedAnswerId = S.AcceptedAnswerId
    ,T.Title = S.Title
    ,T.Tags = S.Tags
    ,T.QuestionScore = S.QuestionScore
    ,T.AcceptedAnswerScore = S.AcceptedAnswerScore
    ,T.ViewCount = S.ViewCount
    ,T.AnswerCount = S.AnswerCount
    ,T.QuestionCreationDate = S.QuestionCreationDate
    ,T.QuestionBody = S.QuestionBody
    ,T.AcceptedAnswerBody = S.AcceptedAnswerBody
    ,T.DocumentText = S.DocumentText
    ,T.Embedding = CASE
      WHEN T.DocumentText <> S.DocumentText THEN NULL
      ELSE T.Embedding
    END
    ,T.EmbeddedAt = CASE
      WHEN T.DocumentText <> S.DocumentText THEN NULL
      ELSE T.EmbeddedAt
    END
  FROM
    [ai_demo].[PostSearchDocuments] AS T
  JOIN
    [ai_demo].[vw_PostSearchDocumentSource] AS S ON S.QuestionId = T.QuestionId
  WHERE
    T.AcceptedAnswerId <> S.AcceptedAnswerId
    OR T.Title <> S.Title
    OR T.Tags <> S.Tags
    OR T.QuestionScore <> S.QuestionScore
    OR T.AcceptedAnswerScore <> S.AcceptedAnswerScore
    OR T.ViewCount <> S.ViewCount
    OR ISNULL(T.AnswerCount, -1) <> ISNULL(S.AnswerCount, -1)
    OR T.QuestionCreationDate <> S.QuestionCreationDate
    OR T.QuestionBody <> S.QuestionBody
    OR T.AcceptedAnswerBody <> S.AcceptedAnswerBody
    OR T.DocumentText <> S.DocumentText;

  SET @RowsUpdated = @@ROWCOUNT;

  INSERT INTO [ai_demo].[PostSearchDocuments]
  (
    QuestionId
    ,AcceptedAnswerId
    ,Title
    ,Tags
    ,QuestionScore
    ,AcceptedAnswerScore
    ,ViewCount
    ,AnswerCount
    ,QuestionCreationDate
    ,QuestionBody
    ,AcceptedAnswerBody
    ,DocumentText
  )
  SELECT
    TOP (@InsertLimit)
    S.QuestionId
    ,S.AcceptedAnswerId
    ,S.Title
    ,S.Tags
    ,S.QuestionScore
    ,S.AcceptedAnswerScore
    ,S.ViewCount
    ,S.AnswerCount
    ,S.QuestionCreationDate
    ,S.QuestionBody
    ,S.AcceptedAnswerBody
    ,S.DocumentText
  FROM
    [ai_demo].[vw_PostSearchDocumentSource] AS S
  WHERE
    NOT EXISTS
    (
      SELECT
        1
      FROM
        [ai_demo].[PostSearchDocuments] AS T
      WHERE
        T.QuestionId = S.QuestionId
    )
  ORDER BY
    S.QuestionScore DESC
    ,S.ViewCount DESC;

  SET @RowsInserted = @@ROWCOUNT;

  SELECT
    @TotalDocuments = COUNT(*)
    ,@EmbeddedDocuments = SUM(CASE WHEN Embedding IS NOT NULL THEN 1 ELSE 0 END)
  FROM
    [ai_demo].[PostSearchDocuments];

  SET @PercentComplete =
    CASE
      WHEN @TotalDocuments = 0 THEN 100.00
      ELSE CONVERT(DECIMAL(5, 2), @EmbeddedDocuments * 100.0 / @TotalDocuments)
    END;

  SET @ProgressBar = CONCAT(
    REPLICATE(N'#', CONVERT(INT, FLOOR(@PercentComplete / 5.0)))
    ,REPLICATE(N'.', 20 - CONVERT(INT, FLOOR(@PercentComplete / 5.0)))
  );

  SET @ProgressMessage = CONCAT(
    N'Embedding progress ['
    ,@ProgressBar
    ,N'] '
    ,CONVERT(NVARCHAR(20), @PercentComplete)
    ,N'% ('
    ,CONVERT(NVARCHAR(20), @EmbeddedDocuments)
    ,N'/'
    ,CONVERT(NVARCHAR(20), @TotalDocuments)
    ,N')'
  );

  PRINT @ProgressMessage;

  WHILE @Rows > 0
  BEGIN
    UPDATE
      TOP (@BatchSize) D
    SET
      D.Embedding = AI_GENERATE_EMBEDDINGS
                    (
                      D.DocumentText
                      USE MODEL [AzureOpenAI_text_embedding_ada_002]
                    )
      ,D.EmbeddedAt = SYSUTCDATETIME()
    FROM
      [ai_demo].[PostSearchDocuments] AS D
    WHERE
      D.Embedding IS NULL;

    SET @Rows = @@ROWCOUNT;
    SET @RowsReembedded = @RowsReembedded + @Rows;

    SELECT
      @EmbeddedDocuments = SUM(CASE WHEN Embedding IS NOT NULL THEN 1 ELSE 0 END)
    FROM
      [ai_demo].[PostSearchDocuments];

    SET @PercentComplete =
      CASE
        WHEN @TotalDocuments = 0 THEN 100.00
        ELSE CONVERT(DECIMAL(5, 2), @EmbeddedDocuments * 100.0 / @TotalDocuments)
      END;

    SET @ProgressBar = CONCAT(
      REPLICATE(N'#', CONVERT(INT, FLOOR(@PercentComplete / 5.0)))
      ,REPLICATE(N'.', 20 - CONVERT(INT, FLOOR(@PercentComplete / 5.0)))
    );

    SET @ProgressMessage = CONCAT(
      N'Embedding progress ['
      ,@ProgressBar
      ,N'] '
      ,CONVERT(NVARCHAR(20), @PercentComplete)
      ,N'% ('
      ,CONVERT(NVARCHAR(20), @EmbeddedDocuments)
      ,N'/'
      ,CONVERT(NVARCHAR(20), @TotalDocuments)
      ,N'), batch rows: '
      ,CONVERT(NVARCHAR(20), @Rows)
    );

    PRINT @ProgressMessage;

    IF @Rows > 0
      WAITFOR DELAY '00:00:01';
  END;

  IF
  (
    @RebuildVectorIndex = 1
    AND
    (
      SELECT
        COUNT(*)
      FROM
        [ai_demo].[PostSearchDocuments]
      WHERE
        Embedding IS NOT NULL
    ) >= 100
  )
  BEGIN
    CREATE VECTOR INDEX [IDX_VECTOR_PostSearchDocuments_Embedding] ON [ai_demo].[PostSearchDocuments]
    (
      [Embedding]
    )
    WITH
    (
      METRIC = 'cosine'
      ,TYPE = 'diskann'
    );

    SET @IndexRebuilt = 1;
  END;

  SELECT
    @RowsInserted AS RowsInserted
    ,@RowsUpdated AS RowsUpdated
    ,@RowsReembedded AS RowsReembedded
    ,@IndexDropped AS VectorIndexDropped
    ,@IndexRebuilt AS VectorIndexRebuilt
    ,@TotalDocuments AS TotalDocuments
    ,@EmbeddedDocuments AS EmbeddedDocuments;
END;
GO


-- On-demand:
-- EXEC [ai_demo].[usp_RefreshPostSearchDocuments];
-- EXEC [ai_demo].[usp_RefreshPostSearchDocuments] @MaxNewDocuments = 50;


-- SQL Agent is not available on Azure SQL Database (EngineEdition = 5)
IF (CONVERT(INT, SERVERPROPERTY(N'EngineEdition')) <> 5)
BEGIN
  DECLARE
    @JobName SYSNAME = N'StackOverflowMini - Refresh PostSearchDocuments'
    ,@ScheduleName SYSNAME = N'StackOverflowMini - Refresh PostSearchDocuments - Daily 02:00'
    ,@JobId UNIQUEIDENTIFIER;

  IF EXISTS
  (
    SELECT
      1
    FROM
      msdb.dbo.sysjobs
    WHERE
      [name] = @JobName
  )
  BEGIN
    EXEC msdb.dbo.sp_delete_job
      @job_name = @JobName
      ,@delete_unused_schedule = 1;
  END;

  EXEC msdb.dbo.sp_add_job
    @job_name = @JobName
    ,@enabled = 1
    ,@description = N'Refresh ai_demo.PostSearchDocuments from dbo.Posts, re-embed changed documents, rebuild the vector index.'
    ,@job_id = @JobId OUTPUT;

  EXEC msdb.dbo.sp_add_jobstep
    @job_id = @JobId
    ,@step_name = N'Refresh PostSearchDocuments'
    ,@subsystem = N'TSQL'
    ,@command = N'EXEC [ai_demo].[usp_RefreshPostSearchDocuments];'
    ,@database_name = N'StackOverflowMini'
    ,@on_success_action = 1
    ,@on_fail_action = 2;

  EXEC msdb.dbo.sp_add_schedule
    @schedule_name = @ScheduleName
    ,@enabled = 1
    ,@freq_type = 4
    ,@freq_interval = 1
    ,@active_start_time = 20000;

  EXEC msdb.dbo.sp_attach_schedule
    @job_id = @JobId
    ,@schedule_name = @ScheduleName;

  EXEC msdb.dbo.sp_add_jobserver
    @job_id = @JobId
    ,@server_name = N'(local)';
END;
GO
