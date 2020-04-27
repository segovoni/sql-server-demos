------------------------------------------------------------------------
-- Event:        SQL Saturday #871 Sardegna 2019, May 18               -
-- Session:      SQL Server Execution Plans: From Zero to Hero         -
-- https://www.sqlsaturday.com/871/Sessions/Details.aspx?sid=91267     -
-- Demo:         Getting started: Capture a plan                       -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [AdventureWorks2017];
GO

-- Estimated execution plans

-- In piani di esecuzione molto complessi la forma grafica
-- non permette di cercare facilmente l'operatore con il
-- maggior costo oppure gli operatori che eseguono scansioni


-- Text Execution Plan

SET SHOWPLAN_ALL ON;
GO

SELECT
  P.BusinessEntityID
  ,P.FirstName
  ,P.LastName
  ,C.AccountNumber
FROM
  Person.Person AS P
JOIN
  Sales.Customer AS C ON C.PersonID=P.BusinessEntityID;
GO

SET SHOWPLAN_ALL OFF;
GO

-- La prima riga contiene il testo del comando T-SQL, la colonna
-- type indica il tipo di statement






-- L'equivalente SHOWPLAN_TEXT mostra solo gli operatori
-- utilizzati

SET SHOWPLAN_TEXT ON;
GO

SELECT
  P.BusinessEntityID
  ,P.FirstName
  ,P.LastName
  ,C.AccountNumber
FROM
  Person.Person AS P
JOIN
  Sales.Customer AS C ON C.PersonID=P.BusinessEntityID;
GO

SET SHOWPLAN_TEXT OFF;
GO


-- Attivazione della versione testo del piano effettivo

SET STATISTICS PROFILE ON;
GO

SELECT
  P.BusinessEntityID
  ,P.FirstName
  ,P.LastName
  ,C.AccountNumber
FROM
  Person.Person AS P
JOIN
  Sales.Customer AS C ON C.PersonID=P.BusinessEntityID;
GO

SET STATISTICS PROFILE OFF;
GO





-- XML Execution Plan

-- Attivazione della versione XML per il piano di esecuzione stimato
-- Come per SHOWPLAN_ALL, attivando SHOWPLAN_XML il comando T-SQL non viene eseguito

SET SHOWPLAN_XML ON;
GO

SELECT
  P.BusinessEntityID
  ,P.FirstName
  ,P.LastName
  ,C.AccountNumber
FROM
  Person.Person AS P
JOIN
  Sales.Customer AS C ON C.PersonID=P.BusinessEntityID;
GO

SET SHOWPLAN_XML OFF;
GO

-- Diamo uno sguardo agli attributi del piano (<QueryPlan>):

-- 1. CachedPlanSize = Ddimensione del piano nella cache
-- 2. CompileTime = Tempo di compilazione
-- 3. CompileCPU = Cicli di CPU
-- 4. CompileMemory = Memoria utilizzata per il piano





-- Actual XML Plan

SET STATISTICS XML ON;
GO

SELECT
  P.BusinessEntityID
  ,P.FirstName
  ,P.LastName
  ,C.AccountNumber
FROM
  Person.Person AS P
JOIN
  Sales.Customer AS C ON C.PersonID=P.BusinessEntityID;
GO

SET STATISTICS XML OFF;
GO

-- Nel nodo <QueryPlan> ora ci sono informazioni aggiuntive:

-- 1. DegreeOfParallelism
-- 2. MemoryGrant = memoria necessaria per l'esecuzione della query

-- Altra differenza tra il piano stimato e quello effettivo
-- è la presenza dell'elemento <RunTimeInformation>


-- DMVs

-- sys.dm_exec_cached_plans
SELECT
  *
FROM
  sys.dm_exec_cached_plans;
GO

SELECT
  *
FROM
  sys.dm_exec_query_plan();
GO

SELECT
  CP.size_in_bytes
  ,CP.plan_handle
  ,CP.cacheobjtype
  ,CP.objtype
  ,QP.query_plan
  ,Qt.text
FROM
  sys.dm_exec_cached_plans AS CP
CROSS APPLY
  sys.dm_exec_query_plan(CP.plan_handle) AS QP
CROSS APPLY
  sys.dm_exec_sql_text(CP.plan_handle) AS QT;
GO