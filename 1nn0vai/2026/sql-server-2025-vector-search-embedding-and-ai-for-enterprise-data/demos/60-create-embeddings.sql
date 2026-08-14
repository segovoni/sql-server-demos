------------------------------------------------------------------------
-- Event:        1nn0vAI 2026 - Pordenone, September  26              --
--               https://www.1nn0vai.it/                              --
--                                                                    --
-- Session:      SQL Server 2025 and Azure SQL: AI comes where        --
--               business data lives                                  --
--                                                                    --
-- Demo:         Create embeddings for ai_demo.PostSearchDocuments    --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [StackOverflowMini];
GO

SET NOCOUNT ON;
GO

IF OBJECT_ID(N'ai_demo.PostSearchDocuments', N'U') IS NULL
BEGIN
  THROW 51000, 'Required table [ai_demo].[PostSearchDocuments] does not exist. Run 50-create-semantic-search-table.sql first.', 1;
END;
GO

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
GO


-- Test
SELECT
  AI_GENERATE_EMBEDDINGS
  (
    N'Quick embedding model test for StackOverflow SQL Server questions.'
    USE MODEL [AzureOpenAI_text_embedding_ada_002]
  ) AS TestEmbedding;
GO


DECLARE
  @BatchSize INT = 25
  ,@Rows INT = 1
  ,@TotalDocuments INT
  ,@EmbeddedDocuments INT
  ,@MissingDocuments INT
  ,@PercentComplete DECIMAL(5,2)
  ,@ProgressBar NVARCHAR(20)
  ,@ProgressMessage NVARCHAR(200);

SELECT
  @TotalDocuments = COUNT(*)
  ,@EmbeddedDocuments = SUM(CASE WHEN Embedding IS NOT NULL THEN 1 ELSE 0 END)
  ,@MissingDocuments = SUM(CASE WHEN Embedding IS NULL THEN 1 ELSE 0 END)
FROM
  [ai_demo].[PostSearchDocuments];

SET @PercentComplete = 
  CASE
    WHEN @TotalDocuments = 0 THEN 100.00
  ELSE
    CONVERT(DECIMAL(5, 2), @EmbeddedDocuments * 100.0 / @TotalDocuments)
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

  SELECT
    @EmbeddedDocuments = SUM(CASE WHEN Embedding IS NOT NULL THEN 1 ELSE 0 END)
    ,@MissingDocuments = SUM(CASE WHEN Embedding IS NULL THEN 1 ELSE 0 END)
  FROM
    [ai_demo].[PostSearchDocuments];

  SET @PercentComplete = CASE
    WHEN @TotalDocuments = 0 THEN 100.00
    ELSE CONVERT(DECIMAL(5,2), @EmbeddedDocuments * 100.0 / @TotalDocuments)
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
GO


SELECT
  COUNT(*) AS TotalDocuments
  ,SUM(CASE WHEN Embedding IS NOT NULL THEN 1 ELSE 0 END) AS EmbeddedDocuments
  ,SUM(CASE WHEN Embedding IS NULL THEN 1 ELSE 0 END) AS MissingEmbeddings
FROM
  [ai_demo].[PostSearchDocuments];
GO


SELECT
  *
FROM
  [ai_demo].[PostSearchDocuments]
WHERE
  Embedding IS NOT NULL;
GO