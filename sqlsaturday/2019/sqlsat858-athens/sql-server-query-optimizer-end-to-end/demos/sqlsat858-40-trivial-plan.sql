------------------------------------------------------------------------
-- Event:        SQL Saturday #858 Athens, June 15 2019                -
-- Session:      SQL Server Query Optimizer end-to-end                 -
-- https://www.sqlsaturday.com/858/Sessions/Details.aspx?sid=90801     -
-- Demo:         Trivial Plan                                          -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [WideWorldImporters];
GO

-- Trivial Plan is the phase in which the Query Optimizer will check
-- if the query is qualified for a trivial plan

-- If this is the case a trivial execution plan is returned and the
-- optimization process ends immediately


SELECT
  P.StockItemID
  ,P.StockItemName
FROM
  Warehouse.StockItems AS P
WHERE
  (P.StockItemID = 50);
GO



-- TF 3604 enables output in the messages page
-- TF 8757 is used to skip the trivial plan, it forces the full optimization
SELECT
  P.StockItemID
  ,P.StockItemName
FROM
  Warehouse.StockItems AS P
WHERE
  (P.StockItemID = 50)
OPTION(RECOMPILE, QUERYTRACEON 3604, QUERYTRACEON 8757);
GO