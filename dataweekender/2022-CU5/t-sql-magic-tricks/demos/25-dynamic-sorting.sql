------------------------------------------------------------------------
-- Event:        #DataWeekender CU5 - May 14th 2022                    -
--               A Pop-up and Online Microsoft Data Conference         -
--               https://www.dataweekender.com/                        -
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
  --ProductID;
  --[Name];
  --[ProductNumber];
  [ListPrice];
GO

DBCC TRACEON(3604);
DBCC TRACEON(8605);
--DBCC TRACEON(8675);
GO

CREATE OR ALTER PROCEDURE dbo.GetSortedProducts
(
  @SortColumnName AS NVARCHAR(256)
)
AS
BEGIN
  IF (@SortColumnName = 'ProductID')
     OR (@SortColumnName = 'Name')
     OR (@SortColumnName = 'ProductNumber')
     OR (@SortColumnName = 'ListPrice')
  BEGIN
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
      END
      OPTION (RECOMPILE, QUERYTRACEON 8605);
  END
  ELSE BEGIN
    RAISERROR(N'The column name is unknown', 16, 1);
    RETURN;
  END;
END;

-- Check dynamic SQL security
EXEC dbo.GetSortedProducts N'Class';

EXEC dbo.GetSortedProducts N'ProductID';
EXEC dbo.GetSortedProducts N'Name';
EXEC dbo.GetSortedProducts N'ProductNumber';
EXEC dbo.GetSortedProducts N'ListPrice';
GO



-- A CASE expression, a T-SQL expression, needs to return a predetermined type

-- When an operator combines expressions of different data types,
-- the data type with the lower precedence is first converted to the data type
-- with the higher precedence

-- https://docs.microsoft.com/sr-cyrl-rs/sql/t-sql/data-types/data-type-precedence-transact-sql?view=sql-server-2017



CREATE OR ALTER PROCEDURE dbo.GetSortedProducts
(
  @SortColumnName AS NVARCHAR(256)
)
AS
BEGIN
  IF (@SortColumnName = 'ProductID')
     OR (@SortColumnName = 'Name')
     OR (@SortColumnName = 'ProductNumber')
     OR (@SortColumnName = 'ListPrice')
  BEGIN
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
      END
      OPTION (RECOMPILE, QUERYTRACEON 8605);
  END
  ELSE BEGIN
    RAISERROR(N'The column name is unknown', 16, 1);
    RETURN;
  END
END;


EXEC dbo.GetSortedProducts N'ProductID';
EXEC dbo.GetSortedProducts N'Name';
EXEC dbo.GetSortedProducts N'ProductNumber';
EXEC dbo.GetSortedProducts N'ListPrice';
GO

-- Credits to Paul White
CREATE OR ALTER PROCEDURE dbo.GetSortedProducts
(
  @SortColumnName AS NVARCHAR(256)
)
AS
BEGIN
  IF (@SortColumnName = 'ProductID')
     OR (@SortColumnName = 'Name')
     OR (@SortColumnName = 'ProductNumber')
     OR (@SortColumnName = 'ListPrice')
  BEGIN
    SELECT
      ProductID, [Name], ProductNumber, ListPrice
    FROM
      dbo.bigProduct
    ORDER BY
      /*
      CASE @SortColumnName
        WHEN N'ProductID' THEN ProductID
        WHEN N'Name' THEN [Name]
        WHEN N'ProductNumber' THEN ProductNumber
        WHEN N'ListPrice' THEN ListPrice
      ELSE CAST(NULL AS sql_variant) END
      */
      CASE WHEN @SortColumnName = N'ProductID' THEN ProductID END
      ,CASE WHEN @SortColumnName = N'Name' THEN [Name] END
      ,CASE WHEN @SortColumnName = N'ProductNumber' THEN ProductNumber END
      ,CASE WHEN @SortColumnName = N'ListPrice' THEN ListPrice END
    OPTION (RECOMPILE, QUERYTRACEON 8605);
  END
  ELSE BEGIN
    RAISERROR(N'The column name is unknown', 16, 1);
    RETURN;
  END
END;


EXEC dbo.GetSortedProducts N'ProductID';
EXEC dbo.GetSortedProducts N'Name';
EXEC dbo.GetSortedProducts N'ProductNumber';
EXEC dbo.GetSortedProducts N'ListPrice';
GO

/*
DBCC DBREINDEX ('dbo.bigProduct');
GO
*/