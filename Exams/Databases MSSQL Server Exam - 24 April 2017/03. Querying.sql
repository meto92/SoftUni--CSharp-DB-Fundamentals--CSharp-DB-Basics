-- 05. Clients by Name

SELECT FirstName,
	   LastName,
	   Phone
  FROM Clients
 ORDER BY LastName,
	   ClientId


-- 06. Job Status

SELECT [Status],
	   IssueDate
  FROM Jobs
 WHERE [Status] <> 'Finished'
 ORDER BY IssueDate,
	   JobId


-- 07. Mechanic Assignments

SELECT m.FirstName + ' ' + m.LastName AS Mechanic,
	   j.[Status],
	   j.IssueDate
  FROM Mechanics AS m
	   JOIN Jobs AS j
	   ON j.MechanicId = m.MechanicId
 ORDER BY m.MechanicId,
	   j.IssueDate,
	   j.JobId


-- 08. Current Clients

SELECT c.FirstName + ' ' + c.LastName AS Client,
	   DATEDIFF(DAY, j.IssueDate, CONVERT(DATETIME, '24/04/2017', 103)) AS [Days going],
	   j.[Status]
  FROM Clients AS c
	   JOIN Jobs AS j
	   ON j.ClientId = c.ClientId
 WHERE j.[Status] <> 'Finished'
 ORDER BY [Days going] DESC,
	   c.ClientId


-- 09. Mechanic Performance

SELECT m.FirstName + ' ' + m.LastName AS Mechanic,
	   AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) AS [Average Days]
  FROM Mechanics AS m
	   JOIN Jobs AS j
	   ON j.MechanicId = m.MechanicId
 GROUP BY m.FirstName + ' ' + m.LastName,
	   m.MechanicId
 ORDER BY m.MechanicId


-- 10. Hard Earners

SELECT TOP (3) m.FirstName + ' ' + m.LastName AS Mechanic,
	   COUNT(*) AS Jobs
  FROM Mechanics AS m
	   JOIN Jobs AS j
	   ON j.MechanicId = m.MechanicId
 WHERE j.[Status] <> 'Finished'
 GROUP BY m.FirstName + ' ' + m.LastName,
	   m.MechanicId
HAVING COUNT(*) > 1
 ORDER BY Jobs DESC,
	   m.MechanicId


-- 11. Available Mechanics

SELECT m.FirstName + ' ' + m.LastName AS Available
  FROM Mechanics AS m
	   LEFT OUTER JOIN Jobs AS j
	   ON j.MechanicId = m.MechanicId
 GROUP BY m.FirstName + ' ' + m.LastName,
	   m.MechanicId
 HAVING COUNT(*) = 0
     OR NOT 
	    (SELECT COUNT(*)
		  FROM Jobs
		 WHERE MechanicId = m.MechanicId
		   AND [Status] <> 'Finished') > 0 
 ORDER BY m.MechanicId


-- 12. Parts Cost

SELECT ISNULL(SUM(p.Price * op.Quantity), 0) AS [Parts Total]
  FROM Parts AS p
	   JOIN OrderParts AS op
	   ON op.PartId = p.PartId
	   JOIN Orders AS o
	   ON o.OrderId = op.OrderId
 WHERE DATEDIFF(WEEK, o.IssueDate, '2017/04/24') <= 3


-- 13. Past Expenses

SELECT j.JobId,
	   Total = ISNULL(SUM(p.Price * op.Quantity), 0)
  FROM Jobs AS j
	   LEFT OUTER JOIN Orders AS o
	   ON o.JobId = j.JobId
	   LEFT OUTER JOIN OrderParts AS op
	   ON op.OrderId = o.OrderId
	   LEFT OUTER JOIN Parts AS p
	   ON p.PartId = op.PartId
 WHERE j.[Status] = 'Finished'
 GROUP BY j.JobId
 ORDER BY Total DESC,
	   j.JobId


-- 14. Model Repair Time

SELECT m.ModelId,
	   m.[Name],
	   [Average Service Time] = CONCAT(AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)), ' days')
  FROM Models AS m
	   JOIN Jobs AS j
	   ON j.ModelId = m.ModelId
 GROUP BY m.ModelId,
	   m.[Name]
 ORDER BY AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate))


-- 15. Faultiest Model

SELECT TOP (1) WITH TIES m.[Name] AS Model,
	   [Times Serviced] = COUNT(DISTINCT j.JobId),
	   [Parts Total] = ISNULL(SUM(p.Price * op.Quantity), 0)
  FROM Models AS m
	   JOIN Jobs AS j
	   ON j.ModelId = m.ModelId
	   LEFT OUTER JOIN Orders AS o
	   ON o.JobId = j.JobId
	   LEFT OUTER JOIN OrderParts AS op
	   ON op.OrderId = o.OrderId
	   LEFT OUTER JOIN Parts AS p
	   ON p.PartId = op.PartId
 GROUP BY m.[Name]
 ORDER BY [Times Serviced] DESC


-- 16. Missing Parts

--SELECT *
--  FROM (SELECT p.PartId,
--			   p.[Description],
--			   [Required] = SUM(pn.Quantity),
--			   [In Stock] = p.StockQty,
--			   Ordered = ISNULL(
--			   (SELECT SUM(pn2.Quantity)
--				  FROM Orders AS o2
--					   JOIN Jobs AS j2
--					   ON j2.JobId = o2.JobId
--					   JOIN PartsNeeded AS pn2
--					   ON pn2.JobId = j2.JobId
--				 WHERE pn2.PartId = p.PartId
--				   AND o2.Delivered = 0), 0)
--	      FROM Parts As p
--	         JOIN PartsNeeded AS pn
--	         ON pn.PartId = p.PartId 
--	         JOIN Jobs AS j
--	         ON j.JobId = pn.JobId
--	         LEFT OUTER JOIN Orders AS o
--	         ON o.JobId = j.JobId
--	         LEFT OUTER JOIN OrderParts AS op
--	         ON op.OrderId = o.OrderId
--	            AND op.PartId = p.PartId
--	   WHERE j.[Status] <> 'Finished'
--	   GROUP BY p.PartId,
--	   	     p.[Description],
--	   	     p.StockQty
--	   ) AS t
-- WHERE [Required] > [In Stock] + Ordered
-- ORDER BY PartId

SELECT p.PartId,
 	   p.[Description],
 	   [Required] = SUM(pn.Quantity),
 	   [In Stock] = SUM(p.StockQty),
 	   Ordered = ISNULL(SUM(op.Quantity), 0)
  FROM Parts As p
       JOIN PartsNeeded AS pn
       ON pn.PartId = p.PartId 
       JOIN Jobs AS j
       ON j.JobId = pn.JobId
       LEFT OUTER JOIN Orders AS o
       ON o.JobId = j.JobId
       LEFT OUTER JOIN OrderParts AS op
       ON op.OrderId = o.OrderId
          AND op.PartId = p.PartId
 WHERE j.[Status] <> 'Finished'
 GROUP BY p.PartId,
	   p.[Description]
HAVING SUM(pn.Quantity) > SUM(p.StockQty) + ISNULL(SUM(op.Quantity), 0)
 ORDER BY PartId