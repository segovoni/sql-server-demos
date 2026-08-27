------------------------------------------------------------------------
-- Event:        1nn0vAI 2026 - Pordenone, September  26              --
--               https://www.1nn0vai.it/                              --
--                                                                    --
-- Session:      SQL Server 2025 and Azure SQL: AI comes where        --
--               business data lives                                  --
--                                                                    --
-- Demo:         Vector search with VECTOR_SEARCH                     --
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

IF NOT EXISTS
(
  SELECT
    1
  FROM
    [ai_demo].[PostSearchDocuments]
  WHERE
    Embedding IS NOT NULL
)
BEGIN
  THROW 51002, 'No embeddings found. Run 60-create-embeddings.sql first.', 1;
END;
GO

IF
(
  SELECT
    COUNT(*)
  FROM
    [ai_demo].[PostSearchDocuments]
  WHERE
    Embedding IS NOT NULL
) < 100
BEGIN
  THROW 51003, 'At least 100 non-NULL embeddings are required to create and use the vector index demo.', 1;
END;
GO


-- Highest-scored SQL Server questions
SELECT
  TOP (10)
  QuestionId
  ,QuestionScore
  ,AcceptedAnswerScore
  ,ViewCount
  ,Tags
  ,Title
FROM
  [ai_demo].[PostSearchDocuments]
ORDER BY
  QuestionScore DESC
  ,ViewCount DESC;
GO


-- Create the DiskANN vector index for approximate search
-- Limitations and considerations
-- https://learn.microsoft.com/sql/t-sql/statements/create-vector-index-transact-sql#limitations-and-considerations

CREATE VECTOR INDEX IDX_VECTOR_PostSearchDocuments_Embedding ON [ai_demo].[PostSearchDocuments]
(
  [Embedding]
)
WITH
(
  METRIC = 'cosine'
  ,TYPE = 'diskann'
);
GO


-- Verify vector index version
SELECT
  I.[name] AS IndexName
  ,T.[name] AS TableName
  ,JSON_VALUE(VI.build_parameters, '$.Version') AS VectorIndexVersion
FROM
  sys.vector_indexes AS VI
JOIN
  sys.indexes AS I ON I.[object_id] = VI.[object_id] AND I.index_id = VI.index_id
JOIN
  sys.tables AS T ON T.[object_id] = VI.[object_id]
WHERE
  I.[name] = N'IDX_VECTOR_PostSearchDocuments_Embedding';
GO


/*
-- DML smoke test. Earlier SQL Server vector indexes can make the table read-only
BEGIN TRY
  BEGIN TRANSACTION;

  UPDATE
    TOP (1) D
  SET
    EmbeddedAt = EmbeddedAt
  FROM
    [ai_demo].[PostSearchDocuments] AS D
  WHERE
    D.Embedding IS NOT NULL;

  ROLLBACK TRANSACTION;

  SELECT
    N'DML test completed successfully.' AS DmlTestResult;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0
  BEGIN
    ROLLBACK TRANSACTION;
  END;

  /*
  SELECT
    ERROR_NUMBER() AS ErrorNumber
    ,ERROR_MESSAGE() AS ErrorMessage
    ,N'This behavior is expected with earlier SQL Server vector index implementations that make the table read-only.' AS Explanation;
  */
END CATCH;
GO
*/

-- Approximate semantic search with VECTOR_SEARCH
-- This SQL Server build uses TOP_N inside VECTOR_SEARCH
DECLARE
  @SearchText NVARCHAR(MAX) =
    N'SQL Server error log file is full';
DECLARE
  @qv VECTOR(1536) = AI_GENERATE_EMBEDDINGS
                     (
                       @SearchText 
                       USE MODEL [AzureOpenAI_text_embedding_ada_002]
                     );

SELECT
  S.distance
  ,T.QuestionId
  ,T.AcceptedAnswerId
  ,T.QuestionScore
  ,T.AcceptedAnswerScore
  ,T.ViewCount
  ,T.Tags
  ,T.Title
FROM
  VECTOR_SEARCH
  (
    TABLE = [ai_demo].[PostSearchDocuments] AS T
    ,COLUMN = Embedding
    ,SIMILAR_TO = @qv
    ,METRIC = 'cosine'
    ,TOP_N = 10
  ) AS S
ORDER BY
  S.distance;
GO


-- Approximate semantic search with an additional relational filter
-- TOP_N is intentionally larger because the relational filter is applied after the vector search result set
DECLARE
  @SearchText NVARCHAR(MAX) =
    N'How to debug a SQL Server trigger?';
DECLARE
  @qv VECTOR(1536) = AI_GENERATE_EMBEDDINGS
                     (
                       @SearchText 
                       USE MODEL [AzureOpenAI_text_embedding_ada_002]
                     );

SELECT
  TOP (10)
  S.distance
  ,T.QuestionId
  ,T.Title
  ,T.Tags
  ,T.QuestionScore
  ,T.AcceptedAnswerScore
FROM
  VECTOR_SEARCH
  (
    TABLE = [ai_demo].[PostSearchDocuments] AS T
    ,COLUMN = Embedding
    ,SIMILAR_TO = @qv
    ,METRIC = 'cosine'
    ,TOP_N = 50
  ) AS S
WHERE
  T.QuestionScore >= 5
ORDER BY
  S.distance;
GO