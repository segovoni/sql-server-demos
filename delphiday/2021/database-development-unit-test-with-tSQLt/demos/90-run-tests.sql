-------------------------------------------------------------------------
-- Event:       Delphi Day 2021 - Digital edition, June 22-25           -
--              https://www.delphiday.it/                               -
--                                                                      -
-- Session:     Database development unit test with tSQLt               -
-- Demo:        Run all test cases                                      -
-- Author:      Sergio Govoni                                           -
-- Notes:       --                                                      -
-------------------------------------------------------------------------

USE [AdventureWorks2017];
GO

-- Run all tests in the class
EXEC tSQLt.RunTestClass 'UnitTestTRProductSafetyStockLevel';
GO