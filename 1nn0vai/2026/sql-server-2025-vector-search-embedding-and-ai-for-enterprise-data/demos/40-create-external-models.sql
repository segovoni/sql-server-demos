------------------------------------------------------------------------
-- Event:        1nn0vAI 2026 - Pordenone, September  26              --
--               https://www.1nn0vai.it/                              --
--                                                                    --
-- Session:      SQL Server 2025 and Azure SQL: AI comes where        --
--               business data lives                                  --
--                                                                    --
-- Demo:         Create external models to interact with an LLM       --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [StackOverflowMini];
GO


-- https://learn.microsoft.com/sql/t-sql/statements/create-master-key-transact-sql
IF NOT EXISTS
(
  SELECT
    1
  FROM
    sys.symmetric_keys
  WHERE
    [name] = N'##MS_DatabaseMasterKey##'
)
BEGIN
  CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<STRONG_DATABASE_MASTER_KEY_PASSWORD>';
END;
GO


IF EXISTS
(
  SELECT
    1
  FROM
    sys.database_scoped_credentials
  WHERE
    [name] = N'https://<AZURE_OPENAI_ENDPOINT>/'
)
BEGIN
  ALTER DATABASE SCOPED CREDENTIAL [https://<AZURE_OPENAI_ENDPOINT>/]
  WITH
    IDENTITY = 'HTTPEndpointHeaders'
    ,SECRET = '{"api-key":"<AZURE_OPENAI_API_KEY>"}';
END
ELSE
BEGIN
  CREATE DATABASE SCOPED CREDENTIAL [https://<AZURE_OPENAI_ENDPOINT>/]
  WITH
    IDENTITY = 'HTTPEndpointHeaders'
    ,SECRET = '{"api-key":"<AZURE_OPENAI_API_KEY>"}';
END;
GO


IF EXISTS
(
  SELECT
    1
  FROM
    sys.external_models
  WHERE
    [name] = N'AzureOpenAI_text_embedding_ada_002'
)
BEGIN
  DROP EXTERNAL MODEL [AzureOpenAI_text_embedding_ada_002];
END;
GO


CREATE EXTERNAL MODEL [AzureOpenAI_text_embedding_ada_002]
WITH
(
  LOCATION = 'https://{endpoint}/openai/deployments/{deployment-id}/embeddings?api-version={date}'
  ,API_FORMAT = 'Azure OpenAI'
  ,MODEL_TYPE = EMBEDDINGS
  ,MODEL = 'text-embedding-ada-002'
  ,CREDENTIAL = [https://<AZURE_OPENAI_ENDPOINT>/]
);
GO


-- Grant permission to use an external model
GRANT EXECUTE ON EXTERNAL MODEL::[AzureOpenAI_text_embedding_ada_002] TO [AIModelAppUser];

-- Revoke permissions when no longer needed
-- REVOKE EXECUTE ON EXTERNAL MODEL::[AzureOpenAI_text_embedding_ada_002] FROM [AIModelAppUser];


SELECT
  EM.[name] AS ExternalModelName
  ,EM.model_type_desc AS ModelTypeDescription
  ,EM.[model] AS ModelName
  ,EM.[api_format] AS ApiFormat
  ,EM.[location] AS Location
  ,DSC.[name] AS CredentialName
FROM
  sys.external_models AS EM
LEFT JOIN
  sys.database_scoped_credentials AS DSC ON DSC.credential_id = EM.credential_id
WHERE
  EM.[name] = N'AzureOpenAI_text_embedding_ada_002';
GO


SELECT
  AI_GENERATE_EMBEDDINGS(N'Log file is full in sql server' USE MODEL [AzureOpenAI_text_embedding_ada_002]);
GO