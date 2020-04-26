------------------------------------------------------------------------
-- Event:        SQL Saturday #264 - Ancona
-- Session:      Trigger: Utili o Dannosi?
-- Demo:         Operazioni multi-riga
-- Author:       Sergio Govoni
-- Notes:        -
------------------------------------------------------------------------

USE [AdventureWorks2012];
GO

------------------------------------------------------------------------
-- Operazioni su più righe
------------------------------------------------------------------------

-- Un'occhiata ai dati
SELECT
  SafetyStockLevel
  ,ListPrice
  ,*
FROM
  Production.Product;
GO




-- Richiesta di implementazione:

-- Impedire l'inserimento di prodotti con SafetyStockLevel minore o uguale a zero
-- oppure con ListPrice minore di zero















CREATE TRIGGER Production.TR_Product_StockLevel_ListPrice ON Production.Product
AFTER INSERT AS
BEGIN
  /*
    Impedisce l'inserimento di prodotti con Scorta di Sicurezza
    minore o uguale a zero oppure con prezzo minore di zero
  */
  BEGIN TRY
    DECLARE
      @SafetyStockLevel SMALLINT
      ,@ListPrice MONEY;

    SELECT
      @SafetyStockLevel = SafetyStockLevel
      ,@ListPrice = ListPrice
    FROM
      inserted;

    IF (@SafetyStockLevel <= 0)
      THROW 50000, N'Safety Stock Level cannot be less then or equal to ZERO', 1;

    IF (@ListPrice < 0)
      THROW 50001,  N'List Price cannot be less then ZERO', 1;
  END TRY
  BEGIN CATCH
    IF (@@TRANCOUNT > 0)
      ROLLBACK;
    THROW; -- rethrow dell'errore
  END CATCH;
END;
GO


-- Insert di una riga corretta
INSERT INTO Production.Product
(
  Name, ProductNumber, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint
  ,StandardCost, ListPrice, DaysToManufacture, SellStartDate, rowguid, ModifiedDate
)
VALUES
(
  N'BigBike', N'BB-5381', 0, 0, 10/*SafetyStockLevel*/, 750, 0.0000, 100.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
);
GO


-- Insert di due righe corrette
INSERT INTO Production.Product
(
  Name, ProductNumber, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint
  ,StandardCost, ListPrice, DaysToManufacture, SellStartDate, rowguid, ModifiedDate
)
VALUES
(
  N'BigBike1', N'BB-5382', 0, 0, 4/*SafetyStockLevel*/, 750, 0.0000, 70.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
),
(
  N'BigBike2', N'BB-5383', 0, 0, 6/*SafetyStockLevel*/, 750, 0.0000, 130.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
);
GO


-- Insert di una riga errata
INSERT INTO Production.Product
(
  Name, ProductNumber, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint
  ,StandardCost, ListPrice, DaysToManufacture, SellStartDate, rowguid, ModifiedDate
)
VALUES
(
  N'BigBike4', N'BB-5384', 0, 0, 0/*SafetyStockLevel*/, 750, 0.0000, 90.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
);
GO


-- Insert di una riga errata e una corretta, l'ordine delle righe non ha importanza, vero?
INSERT INTO Production.Product
(
  Name, ProductNumber, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint
  ,StandardCost, ListPrice, DaysToManufacture, SellStartDate, rowguid, ModifiedDate
)
VALUES
(
  N'BigBike5', N'BB-5385', 0, 0, 4/*SafetyStockLevel*/, 750, 0.0000, -1.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
),
(
  N'BigBike6', N'BB-5386', 0, 0, 5/*SafetyStockLevel*/, 750, 0.0000, 78.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
);
GO


-- Questo Insert andrà a buon fine??
INSERT INTO Production.Product
(
  Name, ProductNumber, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint
  ,StandardCost, ListPrice, DaysToManufacture, SellStartDate, rowguid, ModifiedDate
)
VALUES
(
  N'BigBike6', N'BB-5386', 0, 0, 5/*SafetyStockLevel*/, 750, 0.0000, 78.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
),
(
  N'BigBike5', N'BB-5385', 0, 0, 4/*SafetyStockLevel*/, 750, 0.0000, -1.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
),
(
  N'BigBike7', N'BB-5387', 0, 0, 0/*SafetyStockLevel*/, 750, 0.0000, -2.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
);
GO


SELECT
  Name
  ,ProductNumber
  ,SafetyStockLevel
  ,ListPrice
FROM
  Production.Product
WHERE
  Name LIKE 'BigBike%'
  --AND ((SafetyStockLevel <= 0) OR (ListPrice < 0));
GO


DELETE FROM Production.Product
WHERE Name LIKE 'BigBike%';
GO


ALTER TRIGGER Production.TR_Product_StockLevel_ListPrice ON Production.Product
AFTER INSERT AS
BEGIN
  BEGIN TRY
    /*
    DECLARE
      @SafetyStockLevel SMALLINT
      ,@ListPrice MONEY;

    SELECT
      @SafetyStockLevel = SafetyStockLevel
      ,@ListPrice = ListPrice
    FROM
      inserted;

    IF (@SafetyStockLevel <= 0)
      THROW 50000, N'Safety Stock Level cannot be less then or equal to ZERO', 1;

    IF (@ListPrice < 0)
      THROW 50001,  N'List Price cannot be less then ZERO', 1;
    */

    -- Test SafetyStockLevel
    IF EXISTS (
                SELECT ProductID
                FROM inserted
                WHERE (SafetyStockLevel <= 0)
              )
      THROW 50000, N'Safety Stock Level cannot be less then or equal to ZERO', 1;

    -- Test ListPrice
    IF EXISTS (
                SELECT ProductID
                FROM inserted
                WHERE (ListPrice < 0)
              )
      THROW 50001,  N'List Price cannot be less then ZERO', 1;

  END TRY
  BEGIN CATCH
    IF (@@TRANCOUNT > 0)
      ROLLBACK;
    THROW; -- rethrow dell'errore
  END CATCH;
END;
GO


-- Insert di una riga corretta
INSERT INTO Production.Product
(
  Name, ProductNumber, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint
  ,StandardCost, ListPrice, DaysToManufacture, SellStartDate, rowguid, ModifiedDate
)
VALUES
(
  N'BigBike', N'BB-5381', 0, 0, 10/*SafetyStockLevel*/, 750, 0.0000, 100.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
);
GO
-- Insert di due righe corrette
INSERT INTO Production.Product
(
  Name, ProductNumber, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint
  ,StandardCost, ListPrice, DaysToManufacture, SellStartDate, rowguid, ModifiedDate
)
VALUES
(
  N'BigBike1', N'BB-5382', 0, 0, 4/*SafetyStockLevel*/, 750, 0.0000, 70.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
),
(
  N'BigBike2', N'BB-5383', 0, 0, 6/*SafetyStockLevel*/, 750, 0.0000, 130.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
);
GO
-- Insert di una riga errata
INSERT INTO Production.Product
(
  Name, ProductNumber, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint
  ,StandardCost, ListPrice, DaysToManufacture, SellStartDate, rowguid, ModifiedDate
)
VALUES
(
  N'BigBike4', N'BB-5384', 0, 0, 0/*SafetyStockLevel*/, 750, 0.0000, 90.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
);
GO
-- Insert di una riga errata e una corretta, l'ordine delle righe non ha importanza vero?
INSERT INTO Production.Product
(
  Name, ProductNumber, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint
  ,StandardCost, ListPrice, DaysToManufacture, SellStartDate, rowguid, ModifiedDate
)
VALUES
(
  N'BigBike5', N'BB-5385', 0, 0, 4/*SafetyStockLevel*/, 750, 0.0000, -1.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
),
(
  N'BigBike6', N'BB-5386', 0, 0, 5/*SafetyStockLevel*/, 750, 0.0000, 78.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
);
GO
-- Questo Insert andrà a buon fine??
INSERT INTO Production.Product
(
  Name, ProductNumber, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint
  ,StandardCost, ListPrice, DaysToManufacture, SellStartDate, rowguid, ModifiedDate
)
VALUES
(
  N'BigBike6', N'BB-5386', 0, 0, 5/*SafetyStockLevel*/, 750, 0.0000, 78.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
),
(
  N'BigBike5', N'BB-5385', 0, 0, 4/*SafetyStockLevel*/, 750, 0.0000, -1.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
),
(
  N'BigBike7', N'BB-5387', 0, 0, 0/*SafetyStockLevel*/, 750, 0.0000, -2.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
);
GO


SELECT
  Name
  ,ProductNumber
  ,SafetyStockLevel
  ,ListPrice
FROM
  Production.Product
WHERE
  Name LIKE 'BigBike%'
  --AND ((SafetyStockLevel <= 0) OR (ListPrice < 0));
GO



-- Che metodi alternativi ci sono per implementare l'integrità di dominio?



















-- Vincolo di tipo Check (Check Constraint)
ALTER TABLE Production.Product WITH CHECK
  ADD CONSTRAINT CK_Product_ListPrice CHECK (ListPrice >= 0.00);
GO

ALTER TABLE Production.Product WITH CHECK
  ADD CONSTRAINT CK_Product_SafetyStockLevel CHECK (SafetyStockLevel > 0)
GO




-- Insert di una riga con SafetyStockLevel = 0
INSERT INTO Production.Product
(
  Name, ProductNumber, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint
  ,StandardCost, ListPrice, DaysToManufacture, SellStartDate, rowguid, ModifiedDate
)
VALUES
(
  N'BigBike4', N'BB-5384', 0, 0, 0/*SafetyStockLevel*/, 750, 0.0000, 90.0000/*ListPrice*/
  , 0, GETDATE(), NEWID(), GETDATE()
);
GO



-- Il trigger "TR_Product_StockLevel_ListPrice" è stato eseguito?
SELECT
  ts.execution_count
  ,ts.last_execution_time
FROM
  sys.dm_exec_trigger_stats AS ts
JOIN
  sys.objects AS o ON o.object_id=ts.object_id
WHERE
  (o.name = 'TR_Product_StockLevel_ListPrice');




------------------------------------------------------------------------
-- Operazioni su più righe: Verifiche e aggiornamenti su più tabelle
------------------------------------------------------------------------

SELECT * FROM Sales.MyOrderHeader;
SELECT * FROM Sales.MyOrderDetail;
GO





-- Richiesta di implementazione:

-- Calcolare e aggiornare il totale dell'ordine in funzione dei totali parziali
-- di riga, il totale dell'ordine non può essere negativo










CREATE TRIGGER Sales.TR_MyOrderDetail_H_TotalDue_Calc ON Sales.MyOrderDetail
AFTER INSERT, UPDATE AS
BEGIN
  /*
    Impedisce la memorizzazione di un ordine con totale documento minore di zero;
    aggiorna il totale documento in funzione dei totali parziali di riga
  */
  BEGIN TRY
    IF EXISTS (
                SELECT
                  D.OrderNumber
                FROM
                  Sales.MyOrderDetail AS D
                JOIN
                  inserted AS I ON I.OrderNumber=D.OrderNumber
                GROUP BY
                  d.OrderNumber
                HAVING
                  SUM(D.RowTotal) < 0
              )
      THROW 50001, 'The TotalDue is negative!', 1;

    WITH Total AS
    (
      SELECT
        D.OrderNumber, SUM(D.RowTotal) AS SumRowTotal
      FROM
        Sales.MyOrderDetail AS D
      JOIN
        inserted AS I ON I.OrderNumber=D.OrderNumber
      GROUP BY
        D.OrderNumber
    )
    UPDATE
      H
    SET
      TotalDue = Total.SumRowTotal
    FROM
      Sales.MyOrderHeader AS H
    JOIN
      Total ON Total.OrderNumber=H.OrderNumber;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK;
    THROW;
  END CATCH
END;
GO


-- Inseriamo l'ordine CD_0001
INSERT INTO Sales.MyOrderHeader(OrderNumber)
VALUES ('CD_0001');
INSERT INTO Sales.MyOrderDetail(OrderNumber, RowNumber, RowTotal)
VALUES ('CD_0001', '1', 1000);
INSERT INTO Sales.MyOrderDetail(OrderNumber, RowNumber, RowTotal)
VALUES ('CD_0001', '2', 1000);
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber = 'CD_0001';
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0001';
GO


-- Test TotalDue negativo
INSERT INTO Sales.MyOrderDetail(OrderNumber, RowNumber, RowTotal)
VALUES ('CD_0001', '3', -3000);
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber = 'CD_0001';
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0001';
GO


-- Inseriamo l'ordine CD_0002, aggiungiamo una riga all'ordine CD_0001
INSERT INTO Sales.MyOrderHeader(OrderNumber)
VALUES ('CD_0002');
-- Inserimento multiplo
INSERT INTO Sales.MyOrderDetail(OrderNumber, RowNumber, RowTotal)
VALUES
  ('CD_0001', '4', 1000)
  ,('CD_0002', '1', 1000)
  ,('CD_0002', '2', 1000)
  ,('CD_0002', '3', -2500);
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber LIKE 'CD_000%';
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber LIKE 'CD_000%';
GO


-- Inseriamo l'ordine CD_0003
INSERT INTO Sales.MyOrderHeader(OrderNumber)
VALUES ('CD_0003');
INSERT INTO Sales.MyOrderDetail(OrderNumber, RowNumber, RowTotal)
VALUES
  ('CD_0003', '1', 1000)
  ,('CD_0003', '2', 1000);
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber = 'CD_0003';
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0003';
GO

INSERT INTO Sales.MyOrderDetail(OrderNumber, RowNumber, RowTotal)
VALUES
  ('CD_0003', '3', 1000)
  ,('CD_0003', '4', 1000)
  ,('CD_0003', '5', 1000);
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber = 'CD_0003';
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0003';
GO









ALTER TRIGGER Sales.TR_MyOrderDetail_H_TotalDue_Calc ON Sales.MyOrderDetail
AFTER INSERT, UPDATE AS
BEGIN
  BEGIN TRY
    /*
    IF EXISTS (
                SELECT
                  D.OrderNumber
                FROM
                  Sales.MyOrderDetail AS D
                JOIN
                  inserted AS I ON I.OrderNumber=D.OrderNumber
                GROUP BY
                  d.OrderNumber
                HAVING
                  SUM(D.RowTotal) < 0
              )
      THROW 50001, 'The TotalDue is negative!', 1;

    WITH Total AS
    (
      SELECT
        D.OrderNumber, SUM(D.RowTotal) AS SumRowTotal
      FROM
        Sales.MyOrderDetail AS D
      JOIN
        -- >>>> Il problema sta in questo JOIN, nell'ultimo esempio
        -- >>>> la tabella virtuale Inserted contiene 3 righe, per
        -- >>>> tre volte ogni riga trova corrispondenza con le 5
        -- >>>> righe nella tabella MyOrderDetail (3 * 5 * 1000 = 15000)
        inserted AS I ON I.OrderNumber=D.OrderNumber
      GROUP BY
        D.OrderNumber
    )
    UPDATE
      H
    SET
      TotalDue = Total.SumRowTotal
    FROM
      Sales.MyOrderHeader AS H
    JOIN
      Total ON Total.OrderNumber=H.OrderNumber;
    */

    IF EXISTS (
                SELECT
                  D.OrderNumber
                FROM
                  Sales.MyOrderDetail AS D
                WHERE
                  EXISTS ( -- Uso la clausola EXISTS per mantenere corretta
                           -- la cardinalità nella query esterna
                           SELECT
                             I.OrderNumber
                           FROM
                             inserted AS I
                           WHERE
                             (I.OrderNumber=D.OrderNumber)
                         )
                GROUP BY
                  d.OrderNumber
                HAVING
                  SUM(D.RowTotal) < 0
              )
      THROW 50001, 'The TotalDue is negative!', 1;

    WITH Total AS
    (
      SELECT
        D.OrderNumber, SUM(D.RowTotal) AS SumRowTotal
      FROM
        Sales.MyOrderDetail AS D
      WHERE
        EXISTS ( --
                 SELECT
                   I.OrderNumber
                 FROM
                   inserted AS I
                 WHERE
                   (I.OrderNumber=D.OrderNumber)
               )
      GROUP BY
        D.OrderNumber
    )
    UPDATE
      H
    SET
      TotalDue = Total.SumRowTotal
    FROM
      Sales.MyOrderHeader AS H
    JOIN
      Total ON Total.OrderNumber=H.OrderNumber;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK;
    THROW;
  END CATCH
END;
GO


-- Eliminazione ordine CD_0003
DELETE FROM Sales.MyOrderDetail WHERE (OrderNumber = 'CD_0003');
DELETE FROM Sales.MyOrderHeader WHERE (OrderNumber = 'CD_0003');
GO


-- Inseriamo l'ordine CD_0003
INSERT INTO Sales.MyOrderHeader(OrderNumber)
VALUES ('CD_0003');
INSERT INTO Sales.MyOrderDetail(OrderNumber, RowNumber, RowTotal)
VALUES
  ('CD_0003', '1', 1000)
  ,('CD_0003', '2', 1000);
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber = 'CD_0003';
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0003';
GO


INSERT INTO Sales.MyOrderDetail(OrderNumber, RowNumber, RowTotal)
VALUES
  ('CD_0003', '3', 1000)
  ,('CD_0003', '4', 1000)
  ,('CD_0003', '5', 1000);
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber = 'CD_0003';
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0003';
GO


-- Ora proviamo la modifica del numero ordine su una riga...






-- Inseriamo gli ordini CD_0004 e CD_0005
INSERT INTO Sales.MyOrderHeader(OrderNumber)
VALUES ('CD_0004'), ('CD_0005');
INSERT INTO Sales.MyOrderDetail(OrderNumber, RowNumber, RowTotal)
VALUES
  ('CD_0004', '1', -1000)
  ,('CD_0004', '2', 1000);
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber IN ('CD_0004', 'CD_0005');
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber IN ('CD_0004', 'CD_0005');
GO


-- Questo UPDATE dovrebbe fallire!
UPDATE
  Sales.MyOrderDetail
SET
  OrderNumber = 'CD_0005'
WHERE
  (OrderNumber = 'CD_0004') And (RowNumber = '2');
GO

-- :(
SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber IN ('CD_0004', 'CD_0005');
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber IN ('CD_0004', 'CD_0005');
GO




ALTER TRIGGER Sales.TR_MyOrderDetail_H_TotalDue_Calc ON Sales.MyOrderDetail
AFTER INSERT, UPDATE AS
BEGIN
  BEGIN TRY
    /*
    IF EXISTS (
                SELECT
                  D.OrderNumber
                FROM
                  Sales.MyOrderDetail AS D
                WHERE
                  EXISTS ( SELECT
                             I.OrderNumber
                           FROM
                             -- >>>> E' necessario considerare anche l'ordine che ha perso
                             -- >>>> la riga, non solo quello che l'ha acquisita
                             inserted AS I
                           WHERE
                             (I.OrderNumber=D.OrderNumber)
                         )
                GROUP BY
                  d.OrderNumber
                HAVING
                  SUM(D.RowTotal) < 0
              )
      THROW 50001, 'The TotalDue is negative!', 1;

    WITH Total AS
    (
      SELECT
        D.OrderNumber, SUM(D.RowTotal) AS SumRowTotal
      FROM
        Sales.MyOrderDetail AS D
      WHERE
        EXISTS ( --
                 SELECT
                   I.OrderNumber
                 FROM
                   inserted AS I
                 WHERE
                   (I.OrderNumber=D.OrderNumber)
               )
      GROUP BY
        D.OrderNumber
    )
    UPDATE
      H
    SET
      TotalDue = Total.SumRowTotal
    FROM
      Sales.MyOrderHeader AS H
    JOIN
      Total ON Total.OrderNumber=H.OrderNumber;
    */

    IF EXISTS (
                SELECT
                  D.OrderNumber
                FROM
                  Sales.MyOrderDetail AS D
                WHERE
                  EXISTS ( SELECT
                             OrderNumber
                           FROM
                             (
                               SELECT OrderNumber
                               FROM   inserted

                               UNION ALL

                               SELECT OrderNumber
                               FROM   deleted
                             ) AS M
                           WHERE
                             (M.OrderNumber=D.OrderNumber)
                         )
                GROUP BY
                  d.OrderNumber
                HAVING
                  SUM(D.RowTotal) < 0
              )
      THROW 50001, 'The TotalDue is negative!', 1;

    WITH Total AS
    (
      SELECT
        D.OrderNumber, SUM(D.RowTotal) AS SumRowTotal
      FROM
        Sales.MyOrderDetail AS D
      WHERE
        EXISTS ( SELECT
                   OrderNumber
                 FROM
                   (
                     SELECT OrderNumber
                     FROM   inserted

                     UNION ALL

                     SELECT OrderNumber
                     FROM   deleted
                   ) AS M
                 WHERE
                   (M.OrderNumber=D.OrderNumber)
               )
      GROUP BY
        D.OrderNumber
    )
    UPDATE
      H
    SET
      TotalDue = Total.SumRowTotal
    FROM
      Sales.MyOrderHeader AS H
    JOIN
      Total ON Total.OrderNumber=H.OrderNumber;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK;
    THROW;
  END CATCH
END;
GO


-- Eliminazione ordini CD_0004 e CD_0005
DELETE FROM Sales.MyOrderDetail WHERE (OrderNumber IN ('CD_0004', 'CD_0005'));
DELETE FROM Sales.MyOrderHeader WHERE (OrderNumber IN ('CD_0004', 'CD_0005'));
GO


-- Riproviamo la modifica del numero ordine su una riga...
INSERT INTO Sales.MyOrderHeader(OrderNumber)
VALUES ('CD_0004'), ('CD_0005');
INSERT INTO Sales.MyOrderDetail(OrderNumber, RowNumber, RowTotal)
VALUES
  ('CD_0004', '1', -1000)
  ,('CD_0004', '2', 1000);
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber IN ('CD_0004', 'CD_0005');
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber IN ('CD_0004', 'CD_0005');
GO



UPDATE
  Sales.MyOrderDetail
SET
  OrderNumber = 'CD_0005'
WHERE
  (OrderNumber = 'CD_0004') And (RowNumber = '2');
GO



-- L'UPDATE è fallito, i dati sono OK :)
SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber IN ('CD_0004', 'CD_0005');
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber IN ('CD_0004', 'CD_0005');
GO


--UPDATE
--  Sales.MyOrderDetail
--SET
--  OrderNumber = 'CD_0005'
--  ,RowTotal = (-1 * RowTotal)
--WHERE
--  (OrderNumber = 'CD_0004') And (RowNumber = '1');
--GO

--SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber IN ('CD_0004', 'CD_0005');
--SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber IN ('CD_0004', 'CD_0005');
--GO



-- Possiamo finalmente portare il trigger in produzione?



-- No, perchè non abbiamo gestito l'attivazione sul comando DELETE...


ALTER TRIGGER Sales.TR_MyOrderDetail_H_TotalDue_Calc ON Sales.MyOrderDetail
AFTER INSERT, UPDATE, DELETE /* Ora attivo anche per il comando DELETE */ AS
BEGIN
  BEGIN TRY
    IF EXISTS (
                SELECT
                  D.OrderNumber
                FROM
                  Sales.MyOrderDetail AS D
                WHERE
                  EXISTS ( SELECT
                             OrderNumber
                           FROM
                             (
                               SELECT OrderNumber
                               FROM   inserted

                               UNION ALL

                               SELECT OrderNumber
                               FROM   deleted
                             ) AS M
                           WHERE
                             (M.OrderNumber=D.OrderNumber)
                         )
                GROUP BY
                  d.OrderNumber
                HAVING
                  SUM(D.RowTotal) < 0
              )
      THROW 50001, 'The TotalDue is negative!', 1;

    WITH Total AS
    (
      SELECT
        D.OrderNumber, SUM(D.RowTotal) AS SumRowTotal
      FROM
        Sales.MyOrderDetail AS D
      WHERE
        EXISTS ( SELECT
                   OrderNumber
                 FROM
                   (
                     SELECT OrderNumber
                     FROM   inserted

                     UNION ALL

                     SELECT OrderNumber
                     FROM   deleted
                   ) AS M
                 WHERE
                   (M.OrderNumber=D.OrderNumber)
               )
      GROUP BY
        D.OrderNumber
    )
    UPDATE
      H
    SET
      TotalDue = Total.SumRowTotal
    FROM
      Sales.MyOrderHeader AS H
    JOIN
      Total ON Total.OrderNumber=H.OrderNumber;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK;
    THROW;
  END CATCH
END;
GO


-- Inseriamo l'ordine CD_0006
INSERT INTO Sales.MyOrderHeader(OrderNumber)
VALUES ('CD_0006');
GO

INSERT INTO Sales.MyOrderDetail(OrderNumber, RowNumber, RowTotal)
VALUES
  ('CD_0006', '1',  1000)
  ,('CD_0006', '2', 1000)
  ,('CD_0006', '3', 1000)
  ,('CD_0006', '4', -2500);
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber = 'CD_0006';
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0006';
GO


-- Questo DELETE causerà un TotalDue negativo
DELETE FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0006' AND RowNumber = 1;
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber = 'CD_0006';
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0006';
GO


-- Tentiamo la cancellazione di altre righe
DELETE FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0006'
AND ((RowNumber = 1) OR (RowNumber = 4));
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber = 'CD_0006';
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0006';
GO


-- Eliminiamo tutte le righe dell'ordine
DELETE FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0006';
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber = 'CD_0006';
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0006';
GO


ALTER TRIGGER Sales.TR_MyOrderDetail_H_TotalDue_Calc ON Sales.MyOrderDetail
AFTER INSERT, UPDATE, DELETE /* Ora attivo anche per il comando DELETE */ AS
BEGIN
  BEGIN TRY
    /*
    IF EXISTS (
                SELECT
                  D.OrderNumber
                FROM
                  Sales.MyOrderDetail AS D
                WHERE
                  EXISTS ( SELECT
                             OrderNumber
                           FROM
                             (
                               SELECT OrderNumber
                               FROM   inserted

                               UNION ALL

                               SELECT OrderNumber
                               FROM   deleted
                             ) AS M
                           WHERE
                             (M.OrderNumber=D.OrderNumber)
                         )
                GROUP BY
                  d.OrderNumber
                HAVING
                  SUM(D.RowTotal) < 0
              )
      THROW 50001, 'The TotalDue is negative!', 1;

    WITH Total AS
    (
      SELECT
        D.OrderNumber, SUM(D.RowTotal) AS SumRowTotal
      FROM
        -- >>>> Quando tutte le righe di un ordine vengono eliminate,
        -- >>>> la condizione nella clausola EXISTS non sarà mai verificata,
        -- >>>> l'UPDATE non avrà righe da aggiornare
        Sales.MyOrderDetail AS D
      WHERE
        EXISTS ( SELECT
                   OrderNumber
                 FROM
                   (
                     SELECT OrderNumber
                     FROM   inserted

                     UNION ALL

                     SELECT OrderNumber
                     FROM   deleted
                   ) AS M
                 WHERE
                   (M.OrderNumber=D.OrderNumber)
               )
      GROUP BY
        D.OrderNumber
    )
    UPDATE
      H
    SET
      TotalDue = Total.SumRowTotal
    FROM
      Sales.MyOrderHeader AS H
    JOIN
      Total ON Total.OrderNumber=H.OrderNumber;
    */
    IF EXISTS (
                SELECT
                  D.OrderNumber
                FROM
                  Sales.MyOrderDetail AS D
                WHERE
                  EXISTS ( SELECT
                             OrderNumber
                           FROM
                             (
                               SELECT OrderNumber
                               FROM   inserted

                               UNION ALL

                               SELECT OrderNumber
                               FROM   deleted
                             ) AS M
                           WHERE
                             (M.OrderNumber=D.OrderNumber)
                         )
                GROUP BY
                  D.OrderNumber
                HAVING
                  SUM(D.RowTotal) < 0
              )
      THROW 50001, 'The TotalDue is negative!', 1;

    WITH Total AS
    (
      SELECT
        M.OrderNumber  -- >>>> OrderNumber estratto dalla tabella virtuale M
        ,COALESCE(SUM(D.RowTotal), 0) AS SumRowTotal
      FROM
        (
          SELECT OrderNumber
          FROM   inserted

          UNION -- >>>> UNION in sostituzione di UNION ALL

          SELECT OrderNumber
          FROM   deleted
        ) AS M
      LEFT OUTER JOIN  -- >>>> Left Outer Join in sostituzione alla clausola EXISTS
        Sales.MyOrderDetail AS D ON M.OrderNumber=D.OrderNumber
      GROUP BY
        M.OrderNumber  -- >>>> OrderNumber estratto dalla tabella virtuale M
    )
    UPDATE
      H
    SET
      TotalDue = Total.SumRowTotal
    FROM
      Sales.MyOrderHeader AS H
    JOIN
      Total ON Total.OrderNumber=H.OrderNumber;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK;
    THROW;
  END CATCH
END;
GO


SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber = 'CD_0006';
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0006';
GO


-- Inseriamo le righe dell'ordine CD_0006
INSERT INTO Sales.MyOrderDetail(OrderNumber, RowNumber, RowTotal)
VALUES
  ('CD_0006', '1',  1000)
  ,('CD_0006', '2', 1000)
  ,('CD_0006', '3', 1000)
  ,('CD_0006', '4', -2500);
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber = 'CD_0006';
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0006';
GO


-- Questo DELETE causerà un TotalDue negativo
DELETE FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0006' AND RowNumber = 1;
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber = 'CD_0006';
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0006';
GO


-- Tentiamo la cancellazione di altre righe
DELETE FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0006'
AND ((RowNumber = 1) OR (RowNumber = 4));
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber = 'CD_0006';
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0006';
GO


-- Eliminiamo tutte le righe dell'ordine
DELETE FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0006';
GO

SELECT * FROM Sales.MyOrderHeader WHERE OrderNumber = 'CD_0006';
SELECT * FROM Sales.MyOrderDetail WHERE OrderNumber = 'CD_0006';
GO



------------------------------------------------------------------------
-- Determinazione righe da aggiornare
------------------------------------------------------------------------

/*
IF OBJECT_ID('Sales.TR_SalesOrderDetail_Update') IS NOT NULL
  DROP TRIGGER Sales.TR_SalesOrderDetail_Update;
GO
*/

CREATE TRIGGER Sales.TR_SalesOrderDetail_Update ON Sales.SalesOrderDetail
AFTER UPDATE
AS BEGIN
  /*
    Controllo aggiornamenti colonna UnitPrice
  */
  IF EXISTS (
              SELECT i.SalesOrderDetailID
              FROM inserted AS i
              JOIN Sales.SalesOrderHeader AS H ON i.SalesOrderID=H.SalesOrderID
              JOIN Production.ProductListPriceHistory AS LP ON LP.ProductID=i.ProductID
              WHERE (H.OrderDate BETWEEN LP.StartDate AND ISNULL(LP.EndDate, H.OrderDate))
                AND (i.UnitPrice <> LP.ListPrice)
            )
  BEGIN
    -- Update
    UPDATE
      Sales.SalesOrderDetail
    SET
      UnitPrice = (
                    SELECT LP.ListPrice
                    FROM inserted AS i
                    JOIN Sales.SalesOrderHeader AS H ON i.SalesOrderID=H.SalesOrderID
                    JOIN Production.ProductListPriceHistory AS LP ON LP.ProductID=i.ProductID
                    WHERE (H.OrderDate BETWEEN LP.StartDate AND ISNULL(LP.EndDate, H.OrderDate))
                      AND (i.UnitPrice <> LP.ListPrice)
                  )
    WHERE
      SalesOrderDetailID IN (
                              SELECT i.SalesOrderDetailID
                              FROM inserted AS i
                              JOIN Sales.SalesOrderHeader AS H ON i.SalesOrderID=H.SalesOrderID
                              JOIN Production.ProductListPriceHistory AS LP ON LP.ProductID=i.ProductID
                              WHERE (H.OrderDate BETWEEN LP.StartDate AND ISNULL(LP.EndDate, H.OrderDate))
                                AND (i.UnitPrice <> LP.ListPrice)
                       )
  END;
END;
GO


SELECT * FROM Sales.SalesOrderHeader WHERE SalesOrderID=75123;
SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID=75123;
SELECT * FROM Production.ProductListPriceHistory WHERE ProductID=707;
GO


-- Vediamo il piano di esecuzione...
UPDATE
  Sales.SalesOrderDetail
SET
  UnitPrice = 4.00
WHERE
  SalesOrderDetailID=121318;
GO


SELECT * FROM Sales.SalesOrderHeader WHERE SalesOrderID=75123;
SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID=75123;


-- Ottimizziamo il trigger
ALTER TRIGGER Sales.TR_SalesOrderDetail_Update ON Sales.SalesOrderDetail
AFTER UPDATE
AS BEGIN
  /*
  */
  IF UPDATE(UnitPrice) AND  -- La colonna UnitPrice ha subito un update?
     EXISTS (
              SELECT
                i.SalesOrderDetailID
              FROM
                inserted AS i
              JOIN
                deleted AS d ON d.SalesOrderDetailID=i.SalesOrderDetailID
              WHERE
                -- I valori sono cambiati?
                (i.UnitPrice <> d.UnitPrice)

                -- La colonna UnitPrice è NOT NULL
                -- se fosse stata nullable avrei scritto
                -- (ISNULL(i.UnitPrice, 0) <> ISNULL(d.UnitPrice,0))
            )
  BEGIN
    UPDATE
      S
    SET
      UnitPrice = LP.ListPrice
    FROM
      inserted AS I
    JOIN
      Sales.SalesOrderDetail AS S ON I.SalesOrderDetailID=S.SalesOrderDetailID
    JOIN
      Sales.SalesOrderHeader AS H ON H.SalesOrderID=S.SalesOrderID
    JOIN
      Production.ProductListPriceHistory AS LP ON LP.ProductID=I.ProductID
    WHERE
      (H.OrderDate BETWEEN LP.StartDate AND ISNULL(LP.EndDate, H.OrderDate))
      -- Il valore è diverso ?
      AND (i.UnitPrice <> LP.ListPrice)
  END;
END;
GO


CREATE INDEX IX_SalesOrderDetail_SalesOrderID ON Sales.SalesOrderDetail
(
  [SalesOrderDetailID]
)
INCLUDE
(
  [SalesOrderID]
);