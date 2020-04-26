------------------------------------------------------------------------
-- Event:        SQL Saturday #264 - Ancona
-- Session:      Trigger: Utili o Dannosi?
-- Demo:         Trigger Debug
-- Author:       Sergio Govoni
-- Notes:        -
------------------------------------------------------------------------

USE [AdventureWorks2012];
GO




-- Vi ricordate il trigger che aggiorna il totale documento in funzione
-- dei totali parziali di riga ??

-- Vi hanno segnalato un problema che non riuscite a riprodurre...
-- l'ideale sarebbe poter andare in debug sul trigger :)








ALTER TRIGGER Sales.TR_MyOrderDetail_H_TotalDue_Calc ON Sales.MyOrderDetail
AFTER INSERT, UPDATE, DELETE /* Ora attivo anche per il comando DELETE */ AS
BEGIN
  /*
    Impedisce la memorizzazione di un ordine con totale documento minore di zero;
    aggiorna il totale documento in funzione dei totali parziali di riga
  */
  BEGIN TRY

    -- Impedisce la memorizzazione di un ordine con totale documento minore di zero
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

    -- Aggiorna il totale documento in funzione dei totali parziali di riga
    WITH Total AS
    (
      SELECT
        M.OrderNumber
        ,COALESCE(SUM(D.RowTotal), 0) AS SumRowTotal
      FROM
        (
          SELECT OrderNumber
          FROM   inserted

          UNION

          SELECT OrderNumber
          FROM   deleted
        ) AS M
      LEFT OUTER JOIN
        Sales.MyOrderDetail AS D ON M.OrderNumber=D.OrderNumber
      GROUP BY
        M.OrderNumber
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


EXEC sp_helptrigger 'Sales.MyOrderDetail';
GO


------------------------------------------------------------------------
-- Come fare il debug di un trigger
------------------------------------------------------------------------

-- Per prima cosa dovete creare un stored procedure in grado di
-- far scattare il trigger

IF OBJECT_ID('Sales.usp_Debug_Trigger_MyOrderDetail') IS NOT NULL
  DROP PROCEDURE Sales.usp_Debug_Trigger_MyOrderDetail;
GO


CREATE PROCEDURE Sales.usp_Debug_Trigger_MyOrderDetail
AS BEGIN
  -- Inseriamo l'ordine CD_0007
  INSERT INTO Sales.MyOrderHeader (OrderNumber)
  VALUES ('CD_0010');

  -- Questo INSERT farà scattare il trigger TR_MyOrderDetail_H_TotalDue_Calc
  INSERT INTO Sales.MyOrderDetail(OrderNumber, RowNumber, RowTotal)
  VALUES
    ('CD_0010', '1',  1000)
    ,('CD_0010', '2', 1000)
    ,('CD_0010', '3', 1000)
    ,('CD_0010', '4', -2500);
END;
GO


-- Ora ci spostiamo su Visual Studio..