-- 05. Products by Price

SELECT [Name],
	   Price,
	   [Description]
  FROM Products
 ORDER BY Price DESC,
	   [Name]


-- 06. Ingredients

SELECT [Name],
	   [Description],
	   OriginCountryId
  FROM Ingredients
 WHERE OriginCountryId IN (1, 10, 20)
 ORDER BY Id


-- 07. Ingredients from Bulgaria and Greece

SELECT TOP (15) i.[Name],
	   i.[Description],
	   oc.[Name] AS CountryName
  FROM Ingredients AS i
       JOIN Countries AS oc
	   ON oc.Id = i.OriginCountryId
 WHERE oc.[Name] IN ('Bulgaria', 'Greece')
 ORDER BY i.[Name],
	   oc.[Name]


-- 08. Best Rated Products

SELECT TOP (10) p.[Name],
	   p.[Description],
	   AVG(f.Rate) AS AverageRate,
	   COUNT(f.Id) AS FeedbacksAmount
  FROM Products AS p
	   JOIN Feedbacks AS f
	   ON f.ProductId = p.Id
 GROUP BY p.[Name],
	   p.[Description]
 ORDER BY AverageRate DESC,
	   FeedbacksAmount DESC


-- 09. Negative Feedback

SELECT f.ProductId,
	   f.Rate,
	   f.[Description],
	   f.CustomerId,
	   c.Age,
	   c.Gender
  FROM Feedbacks AS f
	   JOIN Customers AS C
	   ON c.Id = f.CustomerId
 WHERE f.Rate < 5
 ORDER BY f.ProductId DESC,
	   f.Rate


-- 10. Customers without Feedback

SELECT CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
	   c.PhoneNumber,
	   c.Gender
  FROM Customers AS c
 WHERE (SELECT COUNT(*)
	      FROM Feedbacks
		 WHERE CustomerId = c.Id) = 0
 ORDER BY c.Id


-- 11. Honorable Mentions

SELECT f.ProductId,
	   c.FirstName + ' ' + c.LastName AS CustomerName,
	   ISNULL(f.[Description], '') AS FeedbackDescription
  FROM Feedbacks AS f
	   JOIN Customers AS c
	   On c.Id = f.CustomerId
 WHERE (SELECT COUNT(f2.Id)
	      FROM Feedbacks AS f2
			   JOIN Customers AS c2
			   ON c2.Id = f2.CustomerId
		 GROUP BY c2.FirstName + ' ' + c2.LastName
		HAVING c2.FirstName + ' ' + c2.LastName = c.FirstName + ' ' + c.LastName) >= 3
 ORDER BY ProductId,
	   CustomerName,
	   f.Id


-- 12. Customers by Criteria

SELECT cm.FirstName,
	   cm.Age,
	   cm.PhoneNumber
  FROM Customers AS cm
	   JOIN Countries AS c
	   ON cm.CountryId = c.Id
 WHERE (cm.Age >= 21 AND cm.FIrstName LIKE '%an%')
    OR (cm.PhoneNumber LIKE '%38' AND c.[Name] <> 'Greece')
 ORDER BY FirstName,
	   Age DESC


-- 13. Middle Range Distributors

SELECT d.[Name] AS DistributorName,
	   i.[Name] AS IngredientName,
	   p.[Name] AS ProductName,
	   AVG(f.Rate) AS AverageRate
  FROM Distributors AS d
	   JOIN Ingredients AS i
	   On i.DistributorId = d.Id
	   JOIN ProductsIngredients AS [pi]
	   ON [pi].IngredientId = i.Id
	   JOIN Products AS p
	   ON p.Id = [pi].ProductId
	   JOIN Feedbacks AS f
	   On f.ProductId = p.Id
 GROUP BY d.[Name],
	   i.[Name],
	   p.[Name]
HAVING AVG(f.Rate) BETWEEN 5 AND 8
 ORDER BY DistributorName,
	   IngredientName,
	   ProductName


-- 14. The Most Positive Country

SELECT TOP (1) WITH TIES c.[Name] AS CountryName,
	   FeedbackRate = AVG(f.Rate)
  FROM Countries AS c
	   JOIN Customers AS cm
	   ON cm.CountryId = c.Id
	   JOIN Feedbacks AS f
	   ON f.CustomerId = cm.Id
 GROUP BY c.[Name]
 ORDER BY FeedbackRate DESC


-- 15. Country Representative

SELECT c.[Name] AS CountryName,
	   d.[Name] AS DistributorName
  FROM Countries AS c
	   JOIN Distributors AS d
	   ON d.CountryId = c.Id
	   LEFT OUTER JOIN Ingredients AS i
	   ON i.DistributorId = d.Id
 GROUP BY c.[Name],
	   d.[Name]
HAVING COUNT(i.Id) =
	   (SELECT TOP (1) COUNT(i2.id)
	      FROM Ingredients AS i2
		       RIGHT OUTER JOIN Distributors AS d2
			   ON d2.Id = i2.DistributorId
			   JOIN Countries AS c2
			   ON c2.Id = d2.CountryId
		 GROUP BY c2.[Name],
			   d2.[Name]
		HAVING c2.[Name] = c.[Name]
		 ORDER BY COUNT(i2.Id) DESC)
 ORDER BY CountryName,
	   DistributorName


-- 20. Products by One Distributor
SELECT * FROM Products where name = 'Rock'
select * from ProductsIngredients where ProductId = 23

SELECT p.[Name] AS ProductName,
	   AVG(f.Rate) AS ProductAverageRate,
	   d.[Name] AS DistributorName,
	   c.[Name] AS DistributorCountry
  FROM Products AS p
	   LEFT OUTER JOIN Feedbacks AS f
	   ON f.ProductId = p.Id
	   JOIN ProductsIngredients AS [pi]
	   ON [pi].ProductId = p.Id
	   JOIN Ingredients AS i
	   ON i.Id = [pi].IngredientId
	   JOIN Distributors AS d
	   ON d.Id = i.DistributorId
	   JOIN Countries AS c
	   On c.Id = d.CountryId
 WHERE (SELECT COUNT(DISTINCT i2.DistributorId)
	      FROM ProductsIngredients AS pi2
			   JOIN Ingredients AS i2
			   ON i2.Id = pi2.IngredientId
		 GROUP BY pi2.ProductId
		HAVING pi2.ProductId = p.Id) = 1
 GROUP BY p.Id,
	   p.[Name],
	   d.[Name],
	   c.[Name]
 ORDER BY p.Id