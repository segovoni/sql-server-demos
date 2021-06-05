-------------------------------------------------------------------------
-- Event:       SQL Start 2021, June 11                                 -
--              https://www.sqlstart.it/2021/Speakers/Sergio-Govoni     -
--                                                                      -
-- Session:     Database development unit test with tSQLt               -
-- Demo:        Test case: Try to insert multiple rows ordered          -
-- Author:      Sergio Govoni                                           -
-- Notes:       --                                                      -
-------------------------------------------------------------------------

USE [AdventureWorks2017];
GO


CREATE OR ALTER PROCEDURE UnitTestTRProductSafetyStockLevel.[test try to insert multiple rows ordered]
AS
BEGIN
  /*
    Arrange:
    Spy the procedure Production.usp_Raiserror_SafetyStockLevel
  */
  EXEC tSQLt.SpyProcedure 'Production.usp_Raiserror_SafetyStockLevel';

  /*
    Act:
    Try to insert multiple rows
    The first product has a right value for SafetyStockLevel column,
    whereas the value in second one is wrong
  */
  INSERT INTO Production.Product
  (
    [Name]
    ,ProductNumber
    ,MakeFlag
    ,FinishedGoodsFlag
    ,SafetyStockLevel
    ,ReorderPoint
    ,StandardCost
    ,ListPrice
    ,DaysToManufacture
    ,SellStartDate
    ,rowguid
    ,ModifiedDate
  )
  VALUES
  (
    N'Carbon Bar 1'
    ,N'CB-0001'
    ,0
    ,0
    ,15 /* SafetyStockLevel */
    ,750
    ,0.0000
    ,78.0000
    ,0
    ,GETDATE()
    ,NEWID()
    ,GETDATE()
  ),
  (
    N'Carbon Bar 3'
    ,N'CB-0003'
    ,0
    ,0
    ,3 /* SafetyStockLevel */
    ,750
    ,0.0000
    ,78.0000
    ,0
    ,GETDATE()
    ,NEWID()
    ,GETDATE()
  );

  /*
    Assert
  */
  IF NOT EXISTS (SELECT _id_ FROM Production.usp_Raiserror_SafetyStockLevel_SpyProcedureLog)
    EXEC tSQLt.Fail
      @Message0 = 'Production.usp_Raiserror_SafetyStockLevel_SpyProcedureLog is empty! usp_Raiserror_SafetyStockLevel has not been called!';
END;
GO

/*
EXEC tSQLt.Run 'UnitTestTRProductSafetyStockLevel.[test try to insert multiple rows ordered]';
GO
*/