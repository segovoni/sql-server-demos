------------------------------------------------------------------------
-- Event:        SQL Saturday #777 Parma, November 24, 2018            -
-- Session:      SQL Server Query Optimizer end-to-end                 -
-- https://www.sqlsaturday.com/777/Sessions/Details.aspx?sid=79997     -
-- Demo:         Undocumented DBCC options                             -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

DBCC HELP('TRACEON');
GO

DBCC HELP('?');
GO

DBCC HELP('help');
GO

-- Unlock undocumented commands for DBCC HELP
DBCC TRACEON(2588);
GO

DBCC HELP('?');
GO




------------------------------------------------------------------------
-- Hypothetical Indexes DBCC AUTOPILOT                                 -
------------------------------------------------------------------------

USE [AdventureWorks2017];
GO

-- Enables output in the messages page
DBCC TRACEOFF(3604);
GO


DBCC HELP('AUTOPILOT');
GO


SELECT
  T.*
FROM
  [Production].[TransactionHistory] AS T
INNER JOIN
  [Production].[Product] AS P ON P.ProductID=T.ProductID
WHERE
  T.Quantity = 10
GO


CREATE NONCLUSTERED INDEX [IDX_Production_TransactionHistory_Qty] ON [Production].[TransactionHistory]
(
  [Quantity]
)
INCLUDE
(
  [ProductID]
  ,[ReferenceOrderID]
  ,[ReferenceOrderLineID]
  ,[TransactionDate]
  ,[TransactionType]
  ,[ActualCost]
  ,[ModifiedDate]
)
WITH STATISTICS_ONLY = -1;
GO


/*
DROP INDEX [Production].[TransactionHistory].[IDX_Production_TransactionHistory_Qty];
GO

EXEC sp_helpindex '[Production].[TransactionHistory]'
GO
*/


SELECT DB_ID(), OBJECT_ID('[Production].[TransactionHistory]');
GO

SELECT
  is_hypothetical
  ,* 
FROM
  sys.indexes 
WHERE
  [object_id] = OBJECT_ID('[Production].[TransactionHistory]');
GO


-- Parameters: 0, DBID, ObjectID, IndexID
DBCC AUTOPILOT(0, 6, 1230627427, 5);
GO


SET AUTOPILOT ON;
GO
-- TF 9481 forces the legacy CE
SELECT
  T.*
FROM
  [Production].[TransactionHistory] AS T
INNER JOIN
  [Production].[Product] AS P ON P.ProductID=T.ProductID
WHERE
  T.Quantity = 10
--OPTION (QUERYTRACEON 9481);
GO
SET AUTOPILOT OFF;
GO




------------------------------------------------------------------------
-- DBCC DUMPTRIGGER                                                    -
------------------------------------------------------------------------

DBCC HELP('dumptrigger');
GO

-- Switch to ON the trace flags for full dump 
DBCC TRACEON(2544, -1) 
DBCC TRACEON(2546, -1) 
GO

DBCC DUMPTRIGGER('SET', 802);
GO

DBCC DUMPTRIGGER('DISPLAY');
GO

DBCC DUMPTRIGGER('CLEAR', 802);
GO



------------------------------------------------------------------------
-- Optimizer Heuristics On/Off                                         -
------------------------------------------------------------------------

USE [WideWorldImporters];
GO

DBCC TRACEON(3604);
GO

DBCC SHOWONRULES;
DBCC SHOWOFFRULES;

-- JNtoNL: Join to Nested Loop
-- LOJNtoNL: Left Outer Join to Nested Loop
-- JNtoSM: Join to Sort Merge

DBCC RULEOFF('JNtoSM');
DBCC RULEON('JNtoSM');
GO
