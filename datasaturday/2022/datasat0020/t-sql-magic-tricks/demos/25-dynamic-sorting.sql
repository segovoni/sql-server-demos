------------------------------------------------------------------------
-- Event:        DATA SATURDAY #20 - Pordenone 2022                    -
--               http://datasaturdays.com/2022-02-26-datasaturday0020/ -
-- Session:      T-SQL magic tricks!                                   -
--                                                                     -
-- Demo:         Dynamic sorting                                       -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [AdventureWorks2017];
GO

SELECT
  ProductID, [Name], ProductNumber, ListPrice
FROM
  dbo.bigProduct
ORDER BY
  ProductID;
  --[Name];
  --ProductNumber;
  --ListPrice;
GO




CREATE OR ALTER PROCEDURE dbo.GetSortedProducts
(
  @SortColumnName AS NVARCHAR(256)
)
AS BEGIN
  SELECT
    ProductID, [Name], ProductNumber, ListPrice
  FROM
    dbo.bigProduct
  ORDER BY
    CASE @SortColumnName
      WHEN N'ProductID' THEN ProductID
      WHEN N'Name' THEN [Name]
      WHEN N'ProductNumber' THEN ProductNumber
      WHEN N'ListPrice' THEN ListPrice
    END;
END;

EXEC dbo.GetSortedProducts N'ProductID';
EXEC dbo.GetSortedProducts N'Name';
EXEC dbo.GetSortedProducts N'ProductNumber';
EXEC dbo.GetSortedProducts N'ListPrice';
GO



-- A CASE expression, a T-SQL expression, needs to return a predetermined type
-- https://docs.microsoft.com/sr-cyrl-rs/sql/t-sql/data-types/data-type-precedence-transact-sql?view=sql-server-2017



CREATE OR ALTER PROCEDURE dbo.GetSortedProducts
(
  @SortColumnName AS NVARCHAR(256)
)
AS BEGIN
  SELECT
    ProductID, [Name], ProductNumber, ListPrice
  FROM
    dbo.bigProduct
  ORDER BY
    CASE @SortColumnName
      WHEN N'ProductID' THEN ProductID
      WHEN N'Name' THEN [Name]
      WHEN N'ProductNumber' THEN ProductNumber
      WHEN N'ListPrice' THEN ListPrice
    ELSE CAST(NULL AS sql_variant) -- !!! Pay attention to the cast
    END;
END;


EXEC dbo.GetSortedProducts N'ProductID';
EXEC dbo.GetSortedProducts N'Name';
EXEC dbo.GetSortedProducts N'ProductNumber';
EXEC dbo.GetSortedProducts N'ListPrice';
GO

-- Dynamic sorting by Paul White
CREATE OR ALTER PROCEDURE dbo.GetSortedProducts
(
  @SortColumnName AS NVARCHAR(256)
)
AS BEGIN
  SELECT
    ProductID, [Name], ProductNumber, ListPrice
  FROM
    dbo.bigProduct
  ORDER BY
    CASE WHEN @SortColumnName = N'ProductID' THEN ProductID END
    ,CASE WHEN @SortColumnName = N'Name' THEN [Name] END
    ,CASE WHEN @SortColumnName = N'ProductNumber' THEN ProductNumber END
    ,CASE WHEN @SortColumnName = N'ListPrice' THEN ListPrice END
OPTION (RECOMPILE);
END;

EXEC dbo.GetSortedProducts N'ProductID';
EXEC dbo.GetSortedProducts N'Name';
EXEC dbo.GetSortedProducts N'ProductNumber';
EXEC dbo.GetSortedProducts N'ListPrice';
GO

DBCC DBREINDEX ('dbo.bigProduct')