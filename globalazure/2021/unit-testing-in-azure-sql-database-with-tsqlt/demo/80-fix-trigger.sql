-------------------------------------------------------------------------
-- Event:       Global Azure 2021                                       -
--              Apr 15th-17th 2021 - Virtual                            -
--              https://globalazure.net/                                -
--                                                                      -
-- Session:     Unit testing in Azure SQL Database with tSQLt           -
-- Demo:        Fix the Trigger                                         -
-- Author:      Sergio Govoni                                           -
-- Notes:       --                                                      -
-------------------------------------------------------------------------

/*
USE [AdventureWorks2017];
GO
*/

CREATE OR ALTER TRIGGER Production.TR_Product_StockLevel ON Production.Product
AFTER INSERT AS
BEGIN
  /* 
     Avoid to insert products safety stock level lower than 10
  */

  /*
  DECLARE @SafetyStockLevel SMALLINT;

  SELECT
    @SafetyStockLevel = SafetyStockLevel
  FROM
    inserted;

  IF (@SafetyStockLevel < 10)
    -- Error!!
    EXEC Production.usp_raiserror_safety_stock_level
      @Message = 'Safety stock level cannot be lower than 10!';
  */

  -- Testing all rows in the Inserted virtual table
  IF EXISTS (
             SELECT ProductID
             FROM inserted
             WHERE (SafetyStockLevel < 10)
            )
    -- Error!!
    EXEC Production.usp_Raiserror_SafetyStockLevel
      @Message = 'Safety stock level cannot be lower than 10!';
END;
GO