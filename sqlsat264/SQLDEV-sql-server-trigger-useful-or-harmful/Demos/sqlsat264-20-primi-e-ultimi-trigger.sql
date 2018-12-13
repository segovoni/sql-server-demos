------------------------------------------------------------------------
-- Event:        SQL Saturday #264 - Ancona
-- Session:      Trigger: Utili o Dannosi?
-- Demo:         Primi e Ultimi Trigger
-- Author:       Sergio Govoni
-- Notes:        -
------------------------------------------------------------------------

USE [AdventureWorks2012];
GO


------------------------------------------------------------------------
-- Primi e ultimi trigger
------------------------------------------------------------------------

-- Drop
IF OBJECT_ID('Production.TR_Product_INSERT_1', 'TR') IS NOT NULL
  DROP TRIGGER Production.TR_Product_INSERT_1;
GO
IF OBJECT_ID('Production.TR_Product_INSERT_2', 'TR') IS NOT NULL
  DROP TRIGGER Production.TR_Product_INSERT_2;
GO
IF OBJECT_ID('Production.TR_Product_INSERT_3', 'TR') IS NOT NULL
  DROP TRIGGER Production.TR_Product_INSERT_3;
GO


-- Elenco trigger per tabella
EXEC sp_helptrigger 'Production.Product';
GO


CREATE TRIGGER Production.TR_Product_INSERT_2 ON Production.Product
AFTER INSERT
AS
  PRINT('Message from trigger TR_Product_INSERT_2');
GO

CREATE TRIGGER Production.TR_Product_INSERT_3 ON Production.Product
AFTER INSERT
AS
  PRINT('Message from trigger TR_Product_INSERT_3');
GO

CREATE TRIGGER Production.TR_Product_INSERT_1 ON Production.Product
AFTER INSERT
AS
  PRINT('Message from trigger TR_Product_INSERT_1');
GO


INSERT INTO Production.Product
(
  Name, ProductNumber, MakeFlag, FinishedGoodsFlag, Color, SafetyStockLevel, ReorderPoint
  ,StandardCost, ListPrice, Size, SizeUnitMeasureCode, WeightUnitMeasureCode, Weight
  ,DaysToManufacture, ProductLine, Class, Style, ProductSubcategoryID, ProductModelID
  ,SellStartDate, SellEndDate, DiscontinuedDate, rowguid, ModifiedDate)
VALUES
(
  N'CityBike', N'CB-5381', 0, 0, NULL, 1000/*SafetyStockLevel*/, 750, 0.0000, 20.0000/*ListPrice*/
  , NULL, NULL, NULL, NULL
  ,0, NULL, NULL, NULL, NULL, NULL, GETDATE(), NULL, NULL, NEWID(), GETDATE());
GO


-- E' necessario garantire che il Trigger TR_Product_INSERT_3 sia il primo ad attivarsi
EXEC sp_settriggerorder
  @triggername = 'Production.TR_Product_INSERT_3'
 ,@order = 'First'
 ,@stmttype = 'INSERT';
GO


INSERT INTO Production.Product
(
  Name, ProductNumber, MakeFlag, FinishedGoodsFlag, Color, SafetyStockLevel, ReorderPoint
  ,StandardCost, ListPrice, Size, SizeUnitMeasureCode, WeightUnitMeasureCode, Weight
  ,DaysToManufacture, ProductLine, Class, Style, ProductSubcategoryID, ProductModelID
  ,SellStartDate, SellEndDate, DiscontinuedDate, rowguid, ModifiedDate)
VALUES
(
  N'CityBike PRO', N'CB-5382', 0, 0, NULL, 1000/*SafetyStockLevel*/, 750, 0.0000, 30.0000/*ListPrice*/
  , NULL, NULL, NULL, NULL
  ,0, NULL, NULL, NULL, NULL, NULL, GETDATE(), NULL, NULL, NEWID(), GETDATE());
GO


-- Possiamo garantire anche l'attivazione dell'ultimo Trigger
EXEC sp_settriggerorder
@triggername = 'Production.TR_Product_INSERT_2'
,@order = 'Last'
,@stmttype = 'INSERT';
GO


INSERT INTO Production.Product
(
  Name, ProductNumber, MakeFlag, FinishedGoodsFlag, Color, SafetyStockLevel, ReorderPoint
  ,StandardCost, ListPrice, Size, SizeUnitMeasureCode, WeightUnitMeasureCode, Weight
  ,DaysToManufacture, ProductLine, Class, Style, ProductSubcategoryID, ProductModelID
  ,SellStartDate, SellEndDate, DiscontinuedDate, rowguid, ModifiedDate)
VALUES
(
  N'CityBike PRO-4', N'CB-5385', 0, 0, NULL, 1000/*SafetyStockLevel*/, 750, 0.0000, 0.0000/*ListPrice*/
  , NULL, NULL, NULL, NULL
  ,0, NULL, NULL, NULL, NULL, NULL, GETDATE(), NULL, NULL, NEWID(), GETDATE());
GO