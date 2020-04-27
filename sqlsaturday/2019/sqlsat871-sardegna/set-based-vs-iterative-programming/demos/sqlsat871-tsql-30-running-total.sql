------------------------------------------------------------------------
-- Event:        SQL Saturday #871 Sardegna 2019, May 18               -
-- Session:      Set-based vs Iterative programming                    -
-- https://www.sqlsaturday.com/871/Sessions/Details.aspx?sid=94179     -
-- Demo:         Running total                                         -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [AdventureWorks2017];
GO


SELECT * FROM Production.TransactionHistory;
GO

/*

The dynamic product stock level is requested by you boss to justify
the warehouse stock level of a certain product on a certain date

ProductID   TransactionID TransactionType TransactionDate    Quantity   StockLevel
----------- ------------- --------------- ------------------ ----------- -----------
1           104764        P               2007-09-05         3           3
1           106415        P               2007-09-12         3           6
1           107547        P               2007-09-16         3           9
1           109947        P               2007-09-26         3           12
1           113417        P               2007-10-03         3           15
1           115439        P               2007-10-10         3           18
1           117122        P               2007-10-17         3           21
1           124939        P               2007-11-07         3           24
1           130673        P               2007-12-01         3           27
1           137921        P               2007-12-15         3           30
1           141295        P               2007-12-27         3           33
1           144932        P               2008-01-04         3           36
1           147420        P               2008-01-13         3           39
1           149298        P               2008-01-20         3           42
1           152136        P               2008-01-31         3           45
..          ......        ..              ..........         ..          ..

TransactionType
W = WorkOrder, S = SalesOrder, P = PurchaseOrder

*/



-- Traditional set-based solution with joins
SELECT
  T.ProductID
  ,T.TransactionDate
  ,T.TransactionType
  ,CASE (T.TransactionType)
     WHEN 'S' THEN (T.Quantity * -1)
     ELSE (T.Quantity)
   END AS Quantity
  ,SUM(CASE (T1.TransactionType)
         WHEN 'S'
         THEN (T1.Quantity * -1)
		       ELSE (T1.Quantity)
	      END
	  ) AS StockLevel
FROM
  Production.TransactionHistory AS T
JOIN
  Production.TransactionHistory AS T1 ON (T.ProductID = T1.ProductID)
                                     AND (T1.TransactionID <= T.TransactionID)
GROUP BY
  T.ProductID
  ,T.TransactionDate
  ,T.TransactionType
  ,T.Quantity
  ,T.TransactionID
ORDER BY
  T.ProductID
  ,T.TransactionID;
GO






-- Arithmetic sequence (1 + 2 + 3 + ... R) = (R + R^2)/2
-- Square complexity
-- Don't get optimized well







-- 20 sec for 113443 rows
-- ?  sec per 1,134,430 rows
-- ?  sec per 11,344,300 rows

select 20*100*100/60./60./24.


-- 240 sec for 113443 rows
select 240*100*100/60./60./24.



DBCC FREEPROCCACHE;
GO


-- Traditional solution with subqueries
SELECT
  T.ProductID
  ,T.TransactionDate
  ,T.TransactionType
  ,CASE (T.TransactionType)
     WHEN 'S' THEN (T.Quantity * -1)
     ELSE (T.Quantity)
   END AS Quantity
  ,(
     SELECT
	       SUM(CASE (T1.TransactionType)
			           WHEN 'S'
              THEN (T1.Quantity * -1)
			           ELSE (T1.Quantity)
			         END
	          )
	    FROM
	      Production.TransactionHistory AS T1
	    WHERE
	      (T.ProductID = T1.ProductID)
	      AND (T1.TransactionID <= T.TransactionID)
   ) AS StockLevel
FROM
  Production.TransactionHistory AS T
ORDER BY
  T.ProductID
  ,T.TransactionID;
GO


SET STATISTICS IO OFF;
GO


-- Execution Plan OFF


DBCC FREEPROCCACHE;
GO


-- Cursor-based solution
BEGIN
  DECLARE
    @StockLevelTab AS TABLE
    (
      ProductID INTEGER NOT NULL
	     ,TransactionID INTEGER NOT NULL
	     ,TransactionType NCHAR(1) NOT NULL
	     ,TransactionDate DATETIME NOT NULL
	     ,Quantity INTEGER NOT NULL
 	    ,StockLevel INTEGER NOT NULL
    );

  DECLARE
    @ProductID INTEGER
    ,@TransactionID INTEGER
	   ,@PrevProductID INTEGER
	   ,@Quantity INTEGER
	   ,@StockLevel BIGINT
	   ,@TransactionDate DATETIME
	   ,@TransactionType NCHAR(1);


  -- Declare cursor
  DECLARE StockByProduct CURSOR LOCAL FAST_FORWARD FOR
    SELECT
      ProductID
	     ,TransactionID
	     ,CASE (TransactionType)
	        WHEN 'S'
         THEN (Quantity * -1)
		       ELSE (Quantity)
	      END
	    ,TransactionDate
	    ,TransactionType
    FROM
      Production.TransactionHistory
    ORDER BY
      ProductID
	     ,TransactionID;

  OPEN StockByProduct;

  FETCH NEXT FROM StockByProduct INTO @ProductID, @TransactionID, @Quantity, @TransactionDate, @TransactionType;

  SELECT @PrevProductID = @ProductID, @StockLevel = 0;

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    IF (@PrevProductID <> @ProductID)
	     SELECT @PrevProductID = @ProductID, @StockLevel = 0;

    SET @StockLevel = @StockLevel + @Quantity;

    INSERT INTO @StockLevelTab
	   (
	     ProductID
	     ,TransactionID
	     ,TransactionDate
	     ,TransactionType
	     ,Quantity
	     ,StockLevel
	   )
	   VALUES
	   (
	     @ProductID
	     ,@TransactionID
	     ,@TransactionDate
	     ,@TransactionType
	     ,@Quantity
	     ,@StockLevel
	   );

    FETCH NEXT FROM StockByProduct
      INTO @ProductID, @TransactionID, @Quantity, @TransactionDate, @TransactionType;
  END

  CLOSE StockByProduct;

  DEALLOCATE StockByProduct;

  SELECT * FROM @StockLevelTab ORDER BY ProductID, TransactionID;
END;
GO

-- Cursor solution has linear complexity, but it's a very verbosity!


-- Set-based solution (SQL Server 2012+)

-- Dynamic products stock level
SELECT
  ProductID
  ,TransactionID
  ,TransactionType
  ,TransactionDate
  ,sQuantity
  ,SUM(sQuantity) OVER(PARTITION BY ProductID
                       ORDER BY TransactionID
                       ROWS BETWEEN UNBOUNDED PRECEDING
					                       AND CURRENT ROW) AS StockLevel
FROM
  Production.TransactionHistory
ORDER BY
  ProductID, TransactionID;
GO