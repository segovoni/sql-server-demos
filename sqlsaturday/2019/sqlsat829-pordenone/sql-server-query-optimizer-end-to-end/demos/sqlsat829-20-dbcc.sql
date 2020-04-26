------------------------------------------------------------------------
-- Event:        SQL Saturday #829 Pordenone, February 23, 2019        -
-- Session:      SQL Server Query Optimizer end-to-end                 -
-- https://www.sqlsaturday.com/829/Sessions/Details.aspx?sid=88183     -
-- Demo:         DBCC TRACE* and undocumented DBCC options             -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

DBCC TRACEON(<TraceFlags>);
DBCC TRACEOFF(<TraceFlags>);
GO


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
