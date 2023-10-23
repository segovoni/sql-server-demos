------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2023 - November 18               --
--               https://bit.ly/3tKmyMM                               --
--                                                                    --
-- Session:      T-SQL performance tips & tricks!                     --
--                                                                    --
-- Demo:         Dynamic sorting                                      --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [AdventureWorks2022];
GO


-- Let's consider this query
SELECT
  ProductID, [Name], ProductNumber, ListPrice
FROM
  dbo.bigProduct
ORDER BY
  --ProductID;
  --[Name];
  [ProductNumber];
  --[ListPrice];
GO


/*
DBCC TRACEON(3604);
DBCC TRACEON(8605);
DBCC TRACEON(8675);
GO
*/


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
      OPTION (RECOMPILE, QUERYTRACEON 3604, QUERYTRACEON 8605);
  END
  ELSE BEGIN
    RAISERROR(N'The column name is unknown', 16, 1);
    RETURN;
  END;
END;

-- Check dynamic SQL security
EXEC dbo.GetSortedProducts N'-- DELETE..';


-- AncOp_PrjEl COL: Expr1002 
--   ScaOp_Convert money,Null,ML=8
--     ScaOp_Identifier QCOL: [AdventureWorks2017].[dbo].[bigProduct].ProductID
EXEC dbo.GetSortedProducts N'ProductID';

-- AncOp_PrjEl COL: Expr1002 
--   ScaOp_Convert money,Null,ML=8
--     ScaOp_Identifier QCOL: [AdventureWorks2017].[dbo].[bigProduct].Name
-- Cannot convert a char value to money. The char value has incorrect syntax
EXEC dbo.GetSortedProducts N'Name';

EXEC dbo.GetSortedProducts N'ProductNumber';
EXEC dbo.GetSortedProducts N'ListPrice';
GO

-- Have you already faced this problem?
-- How did you solve it?


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
      OPTION (RECOMPILE, QUERYTRACEON 3604, QUERYTRACEON 8605);
  END
  ELSE BEGIN
    RAISERROR(N'The column name is unknown', 16, 1);
    RETURN;
  END
END;


-- AncOp_PrjEl COL: Expr1002 
--   ScaOp_Convert sql_variant,Null,Var,ML=8016
--     ScaOp_Identifier QCOL: [AdventureWorks2017].[dbo].[bigProduct].ProductID
EXEC dbo.GetSortedProducts N'ProductID';

-- AncOp_PrjEl COL: Expr1002 
--   ScaOp_Convert sql_variant,Null,Var,ML=8016
--     ScaOp_Identifier QCOL: [AdventureWorks2017].[dbo].[bigProduct].Name
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
    OPTION (RECOMPILE, QUERYTRACEON 3604, QUERYTRACEON 8605);
  END
  ELSE BEGIN
    RAISERROR(N'The column name is unknown', 16, 1);
    RETURN;
  END
END;


-- AncOp_PrjList 
--   AncOp_PrjEl COL: Expr1002 
--     ScaOp_Identifier QCOL: [AdventureWorks2017].[dbo].[bigProduct].ProductID
--   AncOp_PrjEl COL: Expr1003 
--     ScaOp_Const TI(nvarchar collate 872468488,Null,Var,Trim,ML=160) XVAR(nvarchar,Not Owned,Value=NULL)
--   AncOp_PrjEl COL: Expr1004 
--     ScaOp_Const TI(nvarchar collate 872468488,Null,Var,Trim,ML=112) XVAR(nvarchar,Not Owned,Value=NULL)
--   AncOp_PrjEl COL: Expr1005 
--     ScaOp_Const TI(money,Null,ML=8) XVAR(money,Not Owned,Value=NULL)
EXEC dbo.GetSortedProducts N'ProductID';

EXEC dbo.GetSortedProducts N'Name';
EXEC dbo.GetSortedProducts N'ProductNumber';
EXEC dbo.GetSortedProducts N'ListPrice';
GO

/*
DBCC DBREINDEX ('dbo.bigProduct');
GO
*/