-------------------------------------------------------------------------
-- Event:       Global Azure 2021                                       -
--              Apr 15th-17th 2021 - Virtual                            -
--              https://globalazure.net/                                -
--                                                                      -
-- Session:     Unit testing in Azure SQL Database with tSQLt           -
-- Demo:        Run all test cases                                      -
-- Author:      Sergio Govoni                                           -
-- Notes:       --                                                      -
-------------------------------------------------------------------------

/*
USE [AdventureWorks2017];
GO
*/

-- Run all tests in the class
EXEC tSQLt.RunTestClass 'UnitTestTRProductSafetyStockLevel';
GO

SELECT * FROM tSQLt.TestResult;
GO

SELECT * FROM tSQLt.Run_LastExecution;
GO