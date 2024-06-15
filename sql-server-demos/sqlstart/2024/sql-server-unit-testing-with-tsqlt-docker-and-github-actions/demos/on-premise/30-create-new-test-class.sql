-------------------------------------------------------------------------
-- Event:      SQL Start 2024 - June 14                                --
--             https://www.sqlstart.it/                                --
--                                                                     --
-- Session:    SQL Server unit testing with tSQLt, Docker and          --
--             GitHub Actions                                          --
--                                                                     --
-- Demo:       Create new test class                                   --
-- Author:     Sergio Govoni                                           --
-- Notes:      --                                                      --
-------------------------------------------------------------------------

USE [AdventureWorks2022];
GO


-- Create new test class
-- The test class collects test cases for this class
EXEC tSQLt.NewTestClass 'UnitTestTRProductSafetyStockLevel';
GO

SELECT
  SCHEMA_NAME
  ,objtype
  ,name
  ,value
FROM
  INFORMATION_SCHEMA.SCHEMATA SC
CROSS APPLY
  fn_listextendedproperty (NULL, 'schema', NULL, NULL, NULL, NULL, NULL) OL
WHERE
  OL.objname=sc.SCHEMA_NAME COLLATE Latin1_General_CI_AI
  AND SCHEMA_NAME = 'UnitTestTRProductSafetyStockLevel';


-- Cleanup
--EXEC tSQLt.DropClass 'UnitTestTRProductSafetyStockLevel';
--GO