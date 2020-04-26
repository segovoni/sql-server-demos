------------------------------------------------------------------------
-- Event:        SQL Saturday #858 Athens, June 15 2019                -
-- Session:      SQL Server Query Optimizer end-to-end                 -
-- https://www.sqlsaturday.com/858/Sessions/Details.aspx?sid=90801     -
-- Demo:         Parsing and binding                                   -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------


USE [WideWorldImporters];
GO

-- When PARSEONLY option is turned ON, SQL Server only parses the statement
SET PARSEONLY ON;
GO

-- Examines the syntax of the statement and returns any error messages
-- without compiling or executing the statement
-- We can not get the execution plan
SELECT * FROM Warehouse.StockItems;
GO


-- This statement is valid from the syntax point of view,
-- but the query can not be executed because both table
-- and column don't exist
SELECT InvalidColumn FROM MySchema.InvalidTable;
GO


-- Let's come back to the default value (OFF) of PARSEONLY
SET PARSEONLY OFF;
GO


-- When FMTONLY option is turned ON, SQL Server performs the parsing and binding
-- phases for the statement
-- No execution plan is generated
-- No rows are processed or sent to the client
SET FMTONLY ON;
GO

SELECT
  P.StockItemID
  ,P.StockItemName
  ,P.MarketingComments
  ,C.ColorName
FROM
  Warehouse.StockItems AS P
JOIN
  Warehouse.Colors AS C ON P.ColorID=C.ColorID
WHERE
  (P.ColorID IS NOT NULL);
GO

-- Because the binding phase is now executed, this statement is invalid
SELECT InvalidColumn FROM MySchema.InvalidTable;
GO


SET FMTONLY OFF;
GO


-- Data type resolution
-- Because StockItemID and ColorID have the same data type
-- we can union the results together
SELECT
  StockItemID
FROM
  Warehouse.StockItems
UNION ALL
SELECT
  ColorID
FROM
  Warehouse.Colors;
GO


-- Data type error
-- Sending this query to the optimizer it makes no sense
SELECT
  StockItemID
FROM
  Warehouse.StockItems
UNION ALL
SELECT
  ColorName
FROM
  Warehouse.Colors;
GO


------------------------------------------------------------------------
-- Trace Flag                                                          -
------------------------------------------------------------------------

-- TF 3604 enables output in the messages page
DBCC TRACEON(3604);
GO


-- TF 8605 will output the "Converted Tree"
SELECT
  P.StockItemID
  ,P.StockItemName
  ,P.MarketingComments
FROM
  Warehouse.StockItems AS P
OPTION (RECOMPILE, QUERYTRACEON 8605);
GO


-- WHERE clause in the "Converted Tree"
SELECT
  P.StockItemID
  ,P.StockItemName
  ,P.MarketingComments
FROM
  Warehouse.StockItems AS P
WHERE
  (P.StockItemID = 50)
OPTION (RECOMPILE, QUERYTRACEON 8605);
GO


-- WHERE clause with LIKE
SELECT
  P.StockItemID
  ,P.StockItemName
  ,P.MarketingComments
FROM
  Warehouse.StockItems AS P
WHERE
  (P.StockItemName LIKE 'DBA%')
OPTION (RECOMPILE, QUERYTRACEON 8605);
GO


-- Disable output in the messages page
DBCC TRACEOFF(3604);
GO