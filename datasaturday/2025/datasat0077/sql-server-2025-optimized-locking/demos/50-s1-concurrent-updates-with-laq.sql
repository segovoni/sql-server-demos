------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2025, November 29                --
--               https://bit.ly/43exQYm                               --
--                                                                    --
-- Session:      SQL Server 2025: Optimized Locking in action         --
--                                                                    --
-- Demo:         Concurrent updates with LAQ (Session 1)              --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [OptimizedLocking];
GO


DROP TABLE IF EXISTS dbo.SalesOrder;
GO

CREATE TABLE dbo.SalesOrder
(
  SalesOrderID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
  OrderDate DATETIME NOT NULL,
  [Status] CHAR(1) NOT NULL CHECK ([Status] IN ('N', 'P', 'S', 'C')),
  SalesOrderNumber NVARCHAR(32),
  CustomerID INT NOT NULL,
  TotalDue MONEY NOT NULL
)
GO

INSERT INTO dbo.SalesOrder
  (OrderDate, [Status], SalesOrderNumber, CustomerID, TotalDue)
VALUES
  ('2025-10-20', 'N', N'SO-10001', 123, 1500.00),
  ('2025-10-21', 'P', N'SO-10002', 123, 2200.00),
  ('2025-10-22', 'N', N'SO-10003', 123, 450.00),
  ('2025-10-23', 'S', N'SO-10004', 124, 800.00),
  ('2025-10-24', 'C', N'SO-10005', 125, 600.00);
GO


SELECT * FROM dbo.SalesOrder;
GO


/* Session 1 */

BEGIN TRANSACTION;

UPDATE
  dbo.SalesOrder
SET
  [Status] = 'S'
WHERE
  (CustomerID = 123)
  AND (TotalDue > 1000);


SELECT
  resource_type
  ,resource_database_id
  ,resource_description
  ,request_mode
  ,request_type
  ,request_status
  ,request_session_id
  ,resource_associated_entity_id
FROM
  sys.dm_tran_locks
WHERE
  request_session_id IN (166, @@SPID) -- Replace
  AND resource_type IN ('PAGE', 'RID', 'KEY', 'XACT');


SELECT %%lockres%% AS [Lockres], * FROM [dbo].[SalesOrder];


ROLLBACK;
GO


/*

      BEGIN TRAN
           |
           |
   Read committed version (base/VS)
           |
           |
   Check for active TID lock|
           |
   ||||||||||||||||
   |              |
No |              | Yes
   |              |
Take X lock    Wait on S@XACT(TID)
Update row        |
Release X         |
                  |
               Other TX ends
                  |
               Requalify or restart
                  |
               Take X lock on row
                  |
               Update
                  |
               Release X

*/