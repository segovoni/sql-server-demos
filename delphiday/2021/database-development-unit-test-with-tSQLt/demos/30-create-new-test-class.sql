-------------------------------------------------------------------------
-- Event:       Delphi Day 2021 - Digital edition, June 22-25           -
--              https://www.delphiday.it/                               -
--                                                                      -
-- Session:     Database development unit test with tSQLt               -
-- Demo:        Create new test class                                   -
-- Author:      Sergio Govoni                                           -
-- Notes:       --                                                      -
-------------------------------------------------------------------------

USE [AdventureWorks2017];
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
GO


-- Cleanup
--EXEC tSQLt.DropClass 'UnitTestTRProductSafetyStockLevel';
--GO