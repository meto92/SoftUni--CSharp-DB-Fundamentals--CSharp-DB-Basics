-- 05. Showroom

SELECT Manufacturer,
	   Model
  FROM MODELS
 ORDER BY Manufacturer,
	   Id DESC


-- 06. Y Generation

SELECT FirstName,
	   LastName
  FROM Clients
 WHERE DATEPART(YEAR, BirthDate) BETWEEN 1977 AND 1994
 ORDER BY FirstName,
	   LastName,
	   Id


-- 07. Spacious Office

SELECT t.[Name] AS TownName,
	   o.[Name] AS OfficeName,
	   o.ParkingPlaces
  FROM Offices AS o
	   JOIN Towns AS t
	   ON t.Id = o.TownId
 WHERE o.ParkingPlaces > 25
 ORDER BY t.[Name],
	   o.Id


-- 08. Available Vehicles

SELECT m.Model,
	   m.Seats,
	   v.Mileage
  FROM Models AS m
	   JOIN Vehicles AS v
	   ON v.ModelId = m.id
	   LEFT OUTER JOIN ORders AS o
	   ON o.VehicleId = v.Id
 WHERE (SELECT COUNT(*) 
		  FROM Orders AS o2
		 WHERE o2.VehicleId = v.Id) = 0
    OR (SELECT TOP (1) o3.ReturnDate
		  FROM Orders AS o3
		 WHERE o3.VehicleId = v.Id
		 ORDER BY o3.ReturnDate) IS NOT NULL
 GROUP BY m.Model,
	   m.Seats,
	   v.Mileage,
	   m.Id
 ORDER BY v.Mileage,
	   m.Seats DESC,
	   m.Id


-- 09. Offices per Town

SELECT t.[Name] AS TownName,
	   COUNT(*) AS OfficesNumber
  FROM Towns AS t
	   JOIN Offices AS o
	   ON o.TownId = t.Id
 GROUP BY t.[Name]
 ORDER BY OfficesNumber DESC,
	   t.[Name]


-- 10. Buyers Best Choice 

SELECT m.Manufacturer,
	   m.Model,
	   TimesOrdered = ISNULL(
	   (SELECT COUNT(*)
		  FROM Orders AS o
			   JOIN Vehicles AS v
			   ON v.Id = o.VehicleId
			   JOIN Models AS m2
			   ON m2.Id = v.ModelId
		 GROUP BY m2.Id
		HAVING m2.Id = m.Id), 0)
  FROM Models AS m
 ORDER BY TimesOrdered DESC,
	   m.Manufacturer DESC,
	   m.Model
	   

-- 11. Kinda Person

SELECT Names,
	   Class
  FROM (SELECT c.FirstName + ' ' + c.LastName AS Names,
			   m.Class,
			   c.Id
		  FROM Clients AS c
			   JOIN Orders AS o
			   ON o.ClientId = c.Id
			   JOIN Vehicles AS v
			   ON v.Id = o.VehicleId
			   JOIN Models AS m
			   ON m.Id = v.ModelId
		 GROUP BY c.FirstName + ' ' + c.LastName,
			   m.Class,
			   c.Id
		HAVING COUNT(o.Id) =
			   (SELECT TOP (1) COUNT(o2.Id) AS [Count]
			   	  FROM Orders AS o2
			   		   JOIN Vehicles AS v2
			   		   ON v2.Id = o2.VehicleId
			   		   JOIN Models AS m2
			   		   ON m2.Id = v2.ModelId
			   	 GROUP BY o2.ClientId,
			   		   m2.Class
			    HAVING o2.ClientId = c.Id
			     ORDER BY [Count] DESC
			   )
	   ) AS t
 ORDER BY t.Names,
	   t.Class,
	   t.Id


-- 12. Age Groups Revenue

SELECT AgeGroup,
	   SUM(Bill) AS Revenue,
	   AverageMileage = AVG(TotalMileage)
	   FROM 
	   (SELECT o.ClientId,
	   	       o.Bill,
	   	       o.TotalMileage,
	   	       AgeGroup = 
	   	       CASE
	   	       WHEN DATEPART(YEAR, c.BirthDate) BETWEEN 1970 AND 1979 THEN '70''s'
	   	       WHEN DATEPART(YEAR, c.BirthDate) BETWEEN 1980 AND 1989 THEN '80''s'
	   	       WHEN DATEPART(YEAR, c.BirthDate) BETWEEN 1990 AND 1999 THEN '90''s'
	   	       ELSE 'Others'
	   	       END
	      FROM Orders AS o
			   JOIN Clients AS c
			   ON c.Id = o.ClientId) AS T
 GROUP BY AgeGroup
 ORDER BY AgeGroup


-- 13. Consumption in Mind
		
SELECT Manufacturer,
	   AverageConsumption 
  FROM (SELECT Manufacturer,
			   AverageConsumption,
			   RowNumber = ROW_NUMBER() OVER (ORDER BY Sold DESC)
		  FROM (SELECT m.Manufacturer,
					   AVG(m.Consumption) AS AverageConsumption,
					   COUNT(m.ID) AS Sold
				  FROM Models AS m
					   JOIN Vehicles AS v
					   ON v.ModelId = m.Id
					   JOIN Orders AS o
					   ON o.VehicleId = v.Id
				 GROUP BY m.Manufacturer,
					   m.Id,
					   m.Consumption
				HAVING AVG(m.Consumption) BETWEEN 5 AND 15
			   ) AS t
	   ) AS t2 
 WHERE t2.RowNumber <= 3
 ORDER BY Manufacturer,
	   AverageConsumption


-- 14. Debt Hunter

SELECT Names,
	   Email,
	   Bill,
	   Town
  FROM (SELECT c.Id AS ClientId,
			   c.FirstName + ' ' + c.LastName AS Names,
			   c.Email,
			   o.Bill,
			   t.[Name] AS Town,
			   rn = ROW_NUMBER() OVER (PARTITION BY t.[Name] ORDER BY o.Bill DESC)
		  FROM Clients AS c
			   JOIN Orders AS o
			   ON o.ClientId = c.Id
			   JOIN Towns AS t
			   ON t.Id = o.TownId
		 WHERE o.Bill IS NOT NULL 
		   AND c.CardValidity < o.CollectionDate
	   ) AS t
 WHERE rn <= 2
 ORDER BY Town,
	   Bill,
	   ClientId


-- 15. Town Statistics

SELECT TownName,
	   MalePercent = NULLIF(CAST(Male * 100.0 / (Male + Female) AS INT), 0),
	   FemalePercent = NULLIF(CAST(Female * 100.0 / (Male + Female) AS INT), 0)
  FROM (SELECT t.Id,
			   t.[Name] AS TownName,
			   Male =
			   (SELECT COUNT(*)
		  FROM Orders AS o
			   JOIN Clients AS c
			   ON c.Id = o.ClientId
		 WHERE o.TownId = t.Id
		   AND c.Gender = 'M'
	   ),
	   Female =
	   (SELECT COUNT(*)
		  FROM Orders AS o
			   JOIN Clients AS c
			   ON c.Id = o.ClientId
		 WHERE o.TownId = t.Id
		   AND c.Gender = 'F'
	   )
  FROM Towns AS t
  ) AS p
 ORDER BY TownName,
	   Id


-- 16. Home Sweet Home

SELECT v.id, m.Manufacturer + ' - ' + m.Model AS Vehicle,
	   [Location] =
	   CASE
	   WHEN (SELECT COUNT(*) 
			  FROM Orders 
			 WHERE VehicleId = v.Id) = 0 THEN 'home'
	   WHEN 
	   (SELECT TOP (1) ReturnDate
			   FROM Orders AS o2
			  WHERE o2.VehicleId = v.Id
			  ORDER BY o2.CollectionDate DESC) IS NULL
			  THEN 'on a rent'
	   ELSE 
	   (SELECT TOP (1) t.[Name] + ' - ' + [of].[Name]
	      FROM Towns AS t
	      	   JOIN Offices AS [of]
	           ON [of].TownId = t.Id
	           JOIN Orders AS o3
	           ON o3.ReturnOfficeId = [of].Id
	     WHERE o3.VehicleId = v.Id
	     ORDER BY o3.CollectionDate DESC)
	   END
  FROM Vehicles AS v
	   LEFT OUTER JOIN Orders AS o
	   ON o.VehicleId = v.Id
	   JOIN Models AS m
	   ON m.Id = v.ModelId
 GROUP BY m.Manufacturer + ' - ' + m.Model,
	   v.Id,
	   v.OfficeId
 ORDER BY Vehicle,
	   v.Id