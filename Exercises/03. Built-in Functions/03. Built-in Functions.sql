-- 01. Find Names of All Employees by First Name

SELECT FirstName,
	   LastName
  FROM Employees
 WHERE FirstName LIKE 'Sa%'


-- 02. Find Names of All employees by Last Name 

SELECT FirstName,
	   LastName
  FROM Employees
 WHERE LastName LIKE '%ei%'


-- 03. Find First Names of All Employees

SELECT FirstName
  FROM Employees
 WHERE DepartmentID IN (3, 10) 
   AND DATEPART(YEAR, HireDate) BETWEEN 1995 AND 2005


-- 04. Find All Employees Except Engineers

SELECT FirstName,
	   LastName
  FROM Employees
 WHERE JobTitle NOT LIKE '%engineer%'


-- 05. Find Towns with Name Length

SELECT [Name]
  FROM Towns
 WHERE LEN([Name]) IN (5, 6)
 ORDER BY [Name]


-- 06. Find Towns Starting With

SELECT *
  FROM Towns
 WHERE [Name] LIKE '[MKBE]%'
 ORDER BY [Name]


-- 07. Find Towns Not Starting With

SELECT *
  FROM Towns
 WHERE [Name] LIKE '[^RBD]%'
 ORDER BY [Name]


-- 08. Create View Employees Hired After 2000 Year

CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName,
	   LastName
  FROM Employees
 WHERE DATEPART(YEAR, HireDate) > 2000


-- 09. Length of Last Name

SELECT FirstName,
	   LastName
  FROM Employees
 WHERE LEN(LastName) = 5

 
-- 10. Countries Holding 'A' 3 or More Times

SELECT CountryName,
	   IsoCode AS [ISO Code]
  FROM Countries
 WHERE LEN(CountryName) - LEN(REPLACE(CountryName, 'a', '')) >= 3
 ORDER BY IsoCode


-- 11. Mix of Peak and River Names

SELECT p.PeakName,
	   r.RiverName,
	   Mix = LOWER(p.PeakName + RIGHT(r.RiverName, LEN(r.RiverName) - 1))
  FROM Peaks AS p, 
	   Rivers AS r
 WHERE LOWER(RIGHT(p.PeakName, 1)) = LOWER(LEFT(r.RiverName, 1))
 ORDER BY Mix


-- 12. Games from 2011 and 2012 year

SELECT TOP 50 [Name],
	   [Start] = CONCAT(
		   DATEPART(YEAR, [Start]),
		   '-',
		   RIGHT('0' + CAST(DATEPART(MONTH, [Start]) AS VARCHAR(2)), 2),
		   '-',
		   RIGHT('0' + CAST(DATEPART(DAY, [Start]) AS VARCHAR(2)), 2)) 
  FROM Games
 WHERE DATEPART(YEAR, [Start]) IN (2011, 2012)
 ORDER BY [Start],
	   [Name]


-- 13. User Email Providers

SELECT Username,
	   RIGHT(Email, LEN(Email) - CHARINDEX('@', Email)) AS [Email Provider]
  FROM Users
 ORDER BY [Email Provider],
	   Username


-- 14. Get Users with IPAdress Like Pattern

SELECT Username,
	   IpAddress
  FROM Users
 WHERE IpAddress LIKE '___.1_%._%.___'
 ORDER BY Username


-- 15. Show All Games with Duration and Part of the Day

SELECT g.[Name] AS Game,
	   [Part of the Day] = 
	   CASE
	   WHEN DATEPART(HOUR, g.[Start]) BETWEEN 0 AND 11 THEN 'Morning'
	   WHEN DATEPART(HOUR, g.[Start]) BETWEEN 12 AND 17 THEN 'Afternoon'
	   ELSE 'Evening'
	   END,
	   Duration =
	   CASE
	   WHEN g.Duration <= 3 THEN 'Extra Short'
	   WHEN g.Duration BETWEEN 4 AND 6 THEN 'Short'
	   WHEN g.Duration > 6 THEN 'Long'
	   ELSE 'Extra Long'
	   END
  FROM Games AS g
 ORDER BY Game,
	   Duration,
	   [Part of the Day]


-- 16. Orders Table

SELECT ProductName,
	   OrderDate,
	   [Pay Due] = DATEADD(DAY, 3, OrderDate),
	   [Deliver Due] = DATEADD(MONTH, 1, OrderDate)
  FROM Orders


-- 17. People Table

CREATE TABLE People (
	Id INT IDENTITY,
	[Name] NVARCHAR(50) NOT NULL,
	Birthdate DATETIME2 NOT NULL

	CONSTRAINT PK_People_Id PRIMARY KEY(Id)
)

INSERT INTO People
VALUES ('Victor', '2000-12-07'),
	   ('Steven', '1992-09-10'),
	   ('Stephen', '1910-09-19'),
	   ('John', '2010-01-06')

SELECT [Name],
	   [Age in Years] = DATEDIFF(YEAR, Birthdate, GETDATE()),
	   [Age in Months] = DATEDIFF(MONTH, Birthdate, GETDATE()),
	   [Age in Days] = DATEDIFF(DAY, Birthdate, GETDATE()),
	   [Age in Minutes] = DATEDIFF(MINUTE, Birthdate, GETDATE())
  FROM People