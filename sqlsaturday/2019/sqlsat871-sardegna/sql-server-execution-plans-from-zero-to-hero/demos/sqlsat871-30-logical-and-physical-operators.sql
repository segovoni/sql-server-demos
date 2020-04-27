------------------------------------------------------------------------
-- Event:        SQL Saturday #871 Sardegna 2019, May 18               -
-- Session:      SQL Server Execution Plans: From Zero to Hero         -
-- https://www.sqlsaturday.com/871/Sessions/Details.aspx?sid=91267     -
-- Demo:         Logical and physical operators (blue icons)           -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [AdventureWorks2017];
GO


-- Gli operatori logici e fisici descrivono il modo in cui
-- viene eseguita la query

-- Gli operatori logici derivano dai calcoli del query optimizer
-- per quello che potrebbe accadere in fase di esecuzione della query,
-- descrivono l'operazione algebrica relazionale

-- Gli operatori fisici rappresentano quello che è accaduto durante
-- l'esecuzione della query, descrivono l'algoritmo di implementazione
-- fisica, ad esempio un Clustered Index Scan



/*** Clustered Index Scan ***/

SELECT
  *
FROM
  Person.Person;
GO

-- Tutta la struttura B-Tree dell'indice viene letta row-by-row,
-- l'optimizer valuta più conveniente (= veloce) eseguire una
-- scansione rispetto all'utilizzo della chiave fornita dall'indice stesso

-- Clustered Index *Scan* ==> stiamo chiedendo a SQL Server
-- più righe di quelle necessarie ?

-- While...End vs WHERE

-- La restituzione di righe non necessarie è uno spreco di risorse!!





/*** Clustered Index Seek ***/

SELECT
  P.*
FROM
  Person.Person AS P
WHERE
  (P.BusinessEntityID = 20);
GO

-- Se abbiamo la necessità di estrarre il contatto con ID = 20
-- applichiamo la clausola WHERE e rendiamo molto più efficiente
-- la query precedente

-- I valori della chiave sono usati per identificare velocemente le righe





/*** Non-clustered Index Seek ***/

SELECT
  P.BusinessEntityID
FROM
  Person.Person AS P
WHERE
  (P.LastName like 'paul%');
GO

-- Uso dell'indice non-cluster per determinare le righe

-- In funzione della query e degli indici usati, l'optimizer
-- troverà tutti i dati direttamente nell'indice non-cluster
-- oppure dovrà eseguire un Key LookUp ==> I/O aggiuntive

-- Vediamo un Key LookUp...





/*** Key LookUp ***/

SELECT
  P.BusinessEntityID
  ,P.FirstName
  ,P.LastName
  ,P.EmailPromotion
  ,P.Title
FROM
  Person.Person AS P
WHERE
  (P.LastName like 'paul%');
GO

-- La prima operazione è un Index Seek

-- L'indice [IX_Person_LastName_FirstName_MiddleName] non "copre"
-- completamente la query, il QO è costretto a leggere l'indice cluster
-- (EmailPromotion e Title) ==> operazioni di I/O aggiuntive

-- Key Lookup è sempre accompagnato dall'operatore Nested Loops,
-- join che combina i risultati dei task precedenti

-- Le performance della query migliorano applicando un indice di "copertura"




-- Table Joins
SELECT
  emp.JobTitle
  ,a.City
  ,c.FirstName + ' ' + c.LastName AS Name
FROM
  HumanResources.Employee AS emp
JOIN
  Person.BusinessEntityAddress AS emp_adr ON emp_adr.BusinessEntityID=emp.BusinessEntityID
JOIN
  Person.Address AS a ON emp_adr.AddressID=a.AddressID
JOIN
  Person.Person AS c ON c.BusinessEntityID=emp.BusinessEntityID;
GO



/*** Hash Match (Join) ***/

-- Le operazioni di scan vengono combinate del Hash Match (Join)

-- Hashing and Hash Table ?

-- Una funzione Hash converte i dati in una forma simbolica,
-- ricerca facile e veloce, funzione reversibile

-- Una tabella di hash è una struttura dati che divide gli 
-- elementi (hashing) in categorie omogenee (= di pari dimensioni)

-- Hash Match (Join) è utilizzato quando SQL Server unisce due tabelle
-- attraverso una operazione di hashing sulle righe

-- E' molto efficiente quando una delle tabelle ha un numero di
-- righe notevolmente inferiore rispetto all'altra

-- La presenza di Hash Match può indicare: 
-- 1. Un indice mancante o non utilizzabile
-- 2. Clausola WHERE mancante
-- 3. Clausola WHERE con CAST o CONVERT che disabilitano l'utilizzo di
--    eventuali indici

-- Una considerazione sul numero stimato di righe e numero effettivo di
-- righe...


/* Clustered Index Seek */

-- L'operazione può costosa nel piano di esecuzione..

/* Nested Loops Join */

/* Compute Scalar */

-- Rappresenta semplicemente una operazione scalare, tipicamente un
-- calcolo o come nel nostro caso, la concatenazione della colonna
-- FirstName con la colonna LastName; Costo <> zero, ma trascurabile





/*** Merge Join ***/

SELECT
  c.CustomerID
FROM
  Sales.SalesOrderDetail AS sod
JOIN
  Sales.SalesOrderHeader AS soh ON sod.SalesOrderID=soh.SalesOrderID
JOIN
  Sales.Customer AS c ON c.CustomerID=soh.CustomerID;
GO

-- Scan per la mancanza della WHERE

-- Merge Join tra Customer e SalesOrderHeader

-- Merge Join è utilizzato quando le colonne in join sono pre-ordinate,
-- estremamente efficiente in questa situazione

-- L'optimizer può scegliere di eseguire un ordinamento prima di applicare
-- un Merge Join, ma...

-- Applica Hash Join anche se meno efficiente...





-- GROUP BY and ORDER BY clause

/*** Sort ***/

SELECT
  s.*
FROM
  sales.salesorderheader AS s
ORDER BY
  s.orderdate;
GO

-- Costo dell Sort Task in relazione al costo totale query...

-- Se il Sort Task costa più del 50% del costo totale
-- della query ==> ottimizzazione... manca la clausola WHERE?

-- E' davvero necessario ordinare il result-set?
-- Se non è necessario, evitiamo di applicare l'ORDER BY

SELECT
  s.*
FROM
  sales.salesorderheader AS s
ORDER BY
  s.salesorderid;
GO


-- Cambiando la colonna nell'ORDER BY non compare più il Sort :) Perchè?

-- Se dobbiamo ordinare grandi quantità di dati, verificare l'evento
-- "Sort Warning Event" (= Sort on tempdb), I/O...

-- Molti Sort Warning ==> aumento di RAM oppure migliorare l'accesso al tempdb!!



/*** Hash Match (Aggregate) ***/

SELECT
  a.PostalCode
  ,COUNT(a.PostalCode) AS PostalCount
FROM
  Person.Address a
GROUP BY
  a.PostalCode;
GO


-- No clausola WHERE ==> l'optimizer esegue la scansione

-- L'output viene passato a Hash Match Aggregate (<> dal join),
-- creazione di una tabella hash in memoria

-- L'aggregazione può essere onerosa, l'unica ottimizzazione
-- è verificare la presenza o meno della clausola WHERE





/*** Filter ***/

SELECT
  a.PostalCode
  ,COUNT(a.PostalCode) AS PostalCount
FROM
  Person.Address a
GROUP BY
  a.PostalCode
HAVING
  COUNT(a.PostalCode) > 210
GO


-- Clausola HAVING (per filtrare l'aggregazione), Filter nel piano
-- Filter è applicato SOLO dopo aver eseguito l'aggregazione!
-- Non miglioramenti di performance solo con l'utilizzo di HAVING, senza WHERE!
