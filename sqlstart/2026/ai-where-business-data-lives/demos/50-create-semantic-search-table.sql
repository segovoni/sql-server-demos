------------------------------------------------------------------------
-- Event:        SQL Start 2026 - Ancona, September  18               --
--               https://www.sqlstart.it/                             --
--                                                                    --
-- Session:      SQL Server 2025 and Azure SQL: AI comes where        --
--               business data lives                                  --
--                                                                    --
-- Demo:         Create ai_demo.PostSearchDocuments table             --
-- Author:       Sergio Govoni                                        --
-- Notes:        Create a SQL Server Q&A semantic search table        --
------------------------------------------------------------------------

USE [StackOverflowMini];
GO


DROP TABLE IF EXISTS [ai_demo].[PostSearchDocuments];
GO


CREATE TABLE [ai_demo].[PostSearchDocuments]
(
  DocumentId INT IDENTITY(1, 1) NOT NULL CONSTRAINT PK_PostSearchDocuments PRIMARY KEY CLUSTERED
  ,QuestionId INT NOT NULL
  ,AcceptedAnswerId INT NOT NULL
  ,Title NVARCHAR(500) NOT NULL
  ,Tags NVARCHAR(300) NOT NULL
  ,QuestionScore INT NOT NULL
  ,AcceptedAnswerScore INT NOT NULL
  ,ViewCount INT NOT NULL
  ,AnswerCount INT NULL
  ,QuestionCreationDate DATETIME NOT NULL
  ,QuestionBody NVARCHAR(4000) NOT NULL
  ,AcceptedAnswerBody NVARCHAR(4000) NOT NULL
  ,DocumentText NVARCHAR(MAX) NOT NULL
  ,Embedding VECTOR(1536) NULL
  ,CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_PostSearchDocuments_CreatedAt DEFAULT SYSUTCDATETIME()
  ,EmbeddedAt DATETIME2(0) NULL
  ,CONSTRAINT UQ_PostSearchDocuments_QuestionId UNIQUE (QuestionId)
);
GO


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
-- Keep the corpus small enough for live embedding generation
SELECT
  TOP (1000)
  Q.Id AS QuestionId
  ,Q.AcceptedAnswerId
  ,Q.Title
  ,Q.Tags
  ,Q.Score AS QuestionScore
  ,A.Score AS AcceptedAnswerScore
  ,Q.ViewCount
  ,Q.AnswerCount
  ,Q.CreationDate AS QuestionCreationDate
  -- Body columns intentionally keep the original StackOverflow HTML
  ,LEFT(Q.Body, 4000) AS QuestionBody
  ,LEFT(A.Body, 4000) AS AcceptedAnswerBody
  ,CONCAT(
    N'Title: '
    ,Q.Title
    ,CHAR(13)
    ,CHAR(10)
    ,N'Tags: '
    ,Q.Tags
    ,CHAR(13)
    ,CHAR(10)
    ,N'Question score: '
    ,CONVERT(NVARCHAR(20), Q.Score)
    ,CHAR(13)
    ,CHAR(10)
    ,N'Accepted answer score: '
    ,CONVERT(NVARCHAR(20), A.Score)
    ,CHAR(13)
    ,CHAR(10)
    ,N'Views: '
    ,CONVERT(NVARCHAR(20), Q.ViewCount)
    ,CHAR(13)
    ,CHAR(10)
    ,N'Question: '
    ,LEFT(Q.Body, 3000)
    ,CHAR(13)
    ,CHAR(10)
    ,N'Accepted answer: '
    ,LEFT(A.Body, 3000)
  ) AS DocumentText
FROM
  dbo.Posts AS Q
JOIN
  dbo.Posts AS A ON A.Id = Q.AcceptedAnswerId
WHERE
  Q.PostTypeId = 1
  AND Q.AcceptedAnswerId IS NOT NULL
  AND Q.Tags LIKE N'%<sql-server>%'
  AND Q.Title IS NOT NULL
ORDER BY
  Q.Score DESC
  ,Q.ViewCount DESC;
GO


CREATE INDEX IX_PostSearchDocuments_QuestionScore_ViewCount ON [ai_demo].[PostSearchDocuments]
(
  QuestionScore
  ,ViewCount
)
INCLUDE
(
  QuestionId
  ,AcceptedAnswerId
  ,Title
  ,Tags
  ,AcceptedAnswerScore
);
GO


CREATE INDEX IX_PostSearchDocuments_Tags ON [ai_demo].[PostSearchDocuments]
(
  Tags
)
INCLUDE
(
  QuestionId
  ,Title
  ,QuestionScore
  ,AcceptedAnswerScore
);
GO


SELECT
  COUNT(*) AS SearchDocuments
FROM
  [ai_demo].[PostSearchDocuments];
GO


SELECT
  COUNT(*) AS SearchDocuments
FROM
  [ai_demo].[PostSearchDocuments]
WHERE
  Embedding IS NOT NULL;
GO
