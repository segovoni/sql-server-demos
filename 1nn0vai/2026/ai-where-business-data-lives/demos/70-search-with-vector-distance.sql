------------------------------------------------------------------------
-- Event:        1nn0vAI 2026 - Pordenone, September  26              --
--               https://www.1nn0vai.it/                              --
--                                                                    --
-- Session:      SQL Server 2025 and Azure SQL: AI comes where        --
--               business data lives                                  --
--                                                                    --
-- Demo:         Vector search with VECTOR_DISTANCE                   --
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


-- Traditional keyword search
DECLARE
  @Keyword NVARCHAR(100) = N'parameter sniffing';

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
WHERE
  Title LIKE N'%' + @Keyword + N'%'
  OR QuestionBody LIKE N'%' + @Keyword + N'%'
  OR AcceptedAnswerBody LIKE N'%' + @Keyword + N'%'
ORDER BY
  QuestionScore DESC
  ,ViewCount DESC;
GO


-- Semantic search with VECTOR_DISTANCE
DECLARE
  @SearchText NVARCHAR(MAX) = N'After a deployment, the same stored procedure ' + 
    'became slow only for some parameter values. ' +
    'It looks like SQL Server is reusing a bad execution plan.';
DECLARE
  @qv VECTOR(1536) = AI_GENERATE_EMBEDDINGS
                     (
                       @SearchText 
                       USE MODEL [AzureOpenAI_text_embedding_ada_002]
                     );

SELECT
  TOP (10)
  VECTOR_DISTANCE('cosine', @qv, Embedding) AS Distance
  ,QuestionId
  ,AcceptedAnswerId
  ,QuestionScore
  ,AcceptedAnswerScore
  ,ViewCount
  ,Tags
  ,Title
FROM
  [ai_demo].[PostSearchDocuments]
WHERE
  Embedding IS NOT NULL
ORDER BY
  Distance;
GO


-- Semantic search with VECTOR_DISTANCE and relational filtering
DECLARE
  @SearchText NVARCHAR(MAX) = N'I need to update rows in one SQL Server table ' +
    'using values from another table joined by a key.';
DECLARE
  @qv VECTOR(1536) = AI_GENERATE_EMBEDDINGS
                     (
                       @SearchText 
                       USE MODEL [AzureOpenAI_text_embedding_ada_002]
                     );

SELECT
  TOP (10)
  VECTOR_DISTANCE('cosine', @qv, Embedding) AS Distance
  ,QuestionId
  ,AcceptedAnswerId
  ,QuestionScore
  ,AcceptedAnswerScore
  ,ViewCount
  ,Tags
  ,Title
  ,LEFT(AcceptedAnswerBody, 1000) AS AcceptedAnswerPreview
FROM
  [ai_demo].[PostSearchDocuments]
WHERE
  Embedding IS NOT NULL
  AND QuestionScore >= 10
ORDER BY
  Distance;
GO


-- Semantic search with VECTOR_DISTANCE on a different SQL Server topic
DECLARE
  @SearchText NVARCHAR(MAX) = N'How can I store Unicode text in SQL Server ' +
    'and what is the difference between varchar and nvarchar?';
DECLARE
  @qv VECTOR(1536) = AI_GENERATE_EMBEDDINGS
                     (
                       @SearchText 
                       USE MODEL [AzureOpenAI_text_embedding_ada_002]
                     );

SELECT
  TOP (10)
  VECTOR_DISTANCE('cosine', @qv, Embedding) AS Distance
  ,QuestionId
  ,AcceptedAnswerId
  ,QuestionScore
  ,AcceptedAnswerScore
  ,ViewCount
  ,Tags
  ,Title
FROM
  [ai_demo].[PostSearchDocuments]
WHERE
  Embedding IS NOT NULL
  AND Tags LIKE N'%<sql-server>%'
ORDER BY
  Distance;
GO