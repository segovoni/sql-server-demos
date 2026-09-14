------------------------------------------------------------------------
-- Event:        1nn0vAI 2026 - Pordenone, September  26              --
--               https://www.1nn0vai.it/                              --
--                                                                    --
-- Session:      SQL Server 2025 and Azure SQL: AI comes where        --
--               business data lives                                  --
--                                                                    --
-- Demo:         Vector search on Azure SQL Database                  --
-- Author:       Sergio Govoni                                        --
-- Notes:        Requires Azure SQL vector index latest version       --
------------------------------------------------------------------------

USE [];
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


-- REFRESH DATABASE SCOPED CREDENTIAL


-- 01 - Create the DiskANN vector index with the latest Azure SQL implementation
/*
IF NOT EXISTS
(
  SELECT
    1
  FROM
    sys.indexes
  WHERE
    [object_id] = OBJECT_ID(N'ai_demo.PostSearchDocuments')
    AND [name] = N'IDX_VECTOR_PostSearchDocuments_Embedding'
)
*/
BEGIN
  CREATE VECTOR INDEX IDX_VECTOR_PostSearchDocuments_Embedding ON [ai_demo].[PostSearchDocuments]
  (
    [Embedding]
  )
  WITH
  (
    METRIC = 'cosine'
    ,TYPE = 'diskann'
  );
END;
GO


-- 02 - Verify vector index version. Version 3 is the latest format
SELECT
  I.[name] AS IndexName
  ,T.[name] AS TableName
  ,JSON_VALUE(VI.build_parameters, '$.Version') AS VectorIndexVersion
FROM
  sys.vector_indexes AS VI
JOIN
  sys.indexes AS I ON I.[object_id] = VI.[object_id]
  AND I.index_id = VI.index_id
JOIN
  sys.tables AS T ON T.[object_id] = VI.[object_id]
WHERE
  I.[name] = N'IDX_VECTOR_PostSearchDocuments_Embedding';
GO


-- 03 - DML test. Latest Azure SQL vector indexes support DML
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
GO


-- 04 - Approximate semantic search with SELECT TOP (...) WITH APPROXIMATE
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
  TOP (10) WITH APPROXIMATE
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
  ) AS S
ORDER BY
  S.distance;
GO


-- 05 - Approximate semantic search with iterative relational filtering
DECLARE
  @SearchText NVARCHAR(MAX) =
  N'Find questions about SQL Server date and datetime conversion.';
DECLARE
  @qv VECTOR(1536) = AI_GENERATE_EMBEDDINGS
                     (
                       @SearchText 
                       USE MODEL [AzureOpenAI_text_embedding_ada_002]
                     );

SELECT
  TOP (10) WITH APPROXIMATE
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
  ) AS S
WHERE
  T.QuestionScore >= 5
ORDER BY
  S.distance;
GO