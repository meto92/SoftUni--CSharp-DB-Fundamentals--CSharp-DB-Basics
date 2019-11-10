-- 01. Employee Address

SELECT TOP (5) e.EmployeeID,
	   e.JobTitle,
	   a.AddressID,
	   a.AddressText
  FROM Employees AS e
	   INNER JOIN Addresses AS a
	   ON a.AddressID = e.AddressID
 ORDER BY a.AddressID


-- 02. Addresses with Towns

SELECT TOP (50) e.FirstName,
	   e.LastName,
	   t.[Name] AS Town,
	   a.AddressText
  FROM Employees AS e
	   INNER JOIN Addresses AS a
	   ON a.AddressID = e.AddressID	   
	   INNER JOIN Towns AS t
	   ON t.TownID = a.TownID
 ORDER BY e.FirstName, 
	   e.LastName


-- 03. Sales Employee

SELECT e.EmployeeID,
	   e.FirstName,
	   e.LastName,
	   d.[Name] AS DepartmentName
  FROM Employees AS e
	   INNER JOIN Departments AS d
	   ON d.DepartmentID = e.DepartmentID
 WHERE d.[Name] = 'Sales'
 ORDER BY e.EmployeeID


-- 04. Employee Departments

SELECT TOP (5) e.EmployeeID,
	   e.FirstName,
	   e.Salary,
	   d.[Name] AS DepartmentName
  FROM Employees AS e
	   INNER JOIN Departments AS d
	   ON d.DepartmentID = e.DepartmentID
 WHERE e.Salary > 15000
 ORDER BY d.DepartmentID
 

-- 05. Employees Without Project

SELECT TOP (3) e.EmployeeID,
	   e.FirstName
  FROM Employees AS e
	   LEFT OUTER JOIN EmployeesProjects AS ep
	   ON e.EmployeeID = ep.EmployeeID
 WHERE ep.EmployeeID IS NULL
 ORDER BY e.EmployeeID


-- 06. Employees Hired After

SELECT e.FirstName,
	   e.LastName,
	   e.HireDate,
	   d.[Name] AS DeptName
  FROM Employees AS e
	   INNER JOIN Departments AS d
	   ON d.DepartmentID = e.DepartmentID
 WHERE e.HireDate > '1/1/1999'
   AND d.[Name] IN ('Sales', 'Finance')
 ORDER BY e.HireDate


-- 07. Employees with Project

SELECT TOP (5) e.EmployeeID,
	   e.FirstName,
	   p.[Name] AS ProjectName
  FROM Employees AS e
	   INNER JOIN EmployeesProjects AS ep
	   ON e.EmployeeID = ep.EmployeeID
	   INNER JOIN Projects AS p
	   ON p.ProjectID = ep.ProjectID
 WHERE p.StartDate > '08/13/2002'
   AND p.EndDate IS NULL
 ORDER BY e.EmployeeID


-- 08. Employee 24

SELECT e.EmployeeID,
	   e.FirstName,
	   ProjectName = 
	   CASE
	   WHEN DATEPART(YEAR, p.StartDate) >= 2005 THEN NULL
	   ELSE p.[Name]
	   END
  FROM Employees AS e
	   INNER JOIN EmployeesProjects AS ep
	   ON e.EmployeeID = ep.EmployeeID
	   INNER JOIN Projects AS p
	   ON p.ProjectID = ep.ProjectID
 WHERE e.EmployeeID = 24


-- 09. Employee Manager

SELECT e.EmployeeID,
	   e.FirstName,
	   e.ManagerID,
	   m.FirstName
  FROM Employees AS e
	   INNER JOIN Employees AS m
	   ON m.EmployeeID = e.ManagerID
 WHERE e.ManagerID IN (3, 7)
 ORDER BY e.EmployeeID


-- 10. Employee Summary

SELECT TOP (50) e.EmployeeID,
	   e.FirstName + ' ' + e.LastName AS EmployeeName,
	   m.FirstName + ' ' + m.LastName AS ManagerName,
	   d.[Name] AS DepartmentName
  FROM Employees AS e
	   INNER JOIN Employees AS m
	   ON m.EmployeeID = e.ManagerID
	   INNER JOIN Departments AS d
	   ON d.DepartmentID = e.DepartmentID
 ORDER BY e.EmployeeID


-- 11. Min Average Salary

SELECT MIN(AverageSalary) 
  FROM (SELECT AVG(Salary) AS AverageSalary
		  FROM Employees
		 GROUP BY DepartmentID) AS AverageSalaries


-- 12. Highest Peaks in Bulgaria

SELECT c.CountryCode,
	   m.MountainRange,
	   p.PeakName,
	   p.Elevation
  FROM Countries AS c
	   INNER JOIN MountainsCountries AS mc
	   ON mc.CountryCode = c.CountryCode
	   INNER JOIN Mountains AS m
	   ON m.Id = mc.MountainId
	   INNER JOIN Peaks AS p
	   ON m.Id = p.MountainId
 WHERE c.CountryName = 'Bulgaria'
   AND p.Elevation > 2835
 ORDER BY p.Elevation DESC


-- 13. Count Mountain Ranges

SELECT c.CountryCode,
	   COUNT(m.MountainRange) AS MountainRanges
  FROM Countries AS c
	   INNER JOIN MountainsCountries AS mc
	   ON mc.CountryCode = c.CountryCode
	   INNER JOIN Mountains AS m
	   ON m.Id = mc.MountainId
 GROUP BY c.CountryCode
HAVING c.CountryCode IN 
	   (SELECT CountryCode
		  FROM Countries
		 WHERE CountryName IN ('United States', 'Russia', 'Bulgaria'))


-- 14. Countries with Rivers

SELECT TOP (5) c.CountryName,
	   r.RiverName
  FROM Countries AS c
	   LEFT OUTER JOIN CountriesRivers AS cr
	   ON cr.CountryCode = c.CountryCode
	   LEFT OUTER JOIN Rivers AS r
	   ON r.Id = cr.RiverId
 WHERE c.ContinentCode =
	   (SELECT ContinentCode
	      FROM Continents
		 WHERE ContinentName = 'Africa')
 ORDER BY c.CountryName
		 

-- 15. Continents and Currencies

SELECT t.ContinentCode,
	   t.CurrencyCode,
	   t.CurrencyUsage
  FROM (SELECT c.ContinentCode,
			   CurrencyCode =
			   (SELECT c2.CurrencyCode
				  FROM Countries AS c2
				 GROUP BY c2.ContinentCode,
					   c2.CurrencyCode
				HAVING c2.ContinentCode = c.ContinentCode
				   AND c2.CurrencyCode = c.CurrencyCode
				   AND COUNT(c2.CurrencyCode) =
					   (SELECT MAX(usage)
						  FROM (SELECT COUNT(CurrencyCode) AS usage
								  FROM Countries AS c3
								 GROUP BY c3.CurrencyCode, 
									   c3.ContinentCode
								HAVING c3.ContinentCode = c.ContinentCode
							   ) AS t2
					   )
			   ),
			   CurrencyUsage =
			   (SELECT MAX(usage)
				  FROM (SELECT COUNT(CurrencyCode) AS usage
				  FROM Countries AS c3
				 GROUP BY c3.CurrencyCode, 
					   c3.ContinentCode
				HAVING c3.ContinentCode = c.ContinentCode
				   AND COUNT(CurrencyCode) > 1
					   ) AS t3
			   )
		  FROM Countries AS c
		 GROUP BY ContinentCode,
			   CurrencyCode
	   ) AS t
 WHERE t.CurrencyCode IS NOT NULL
   AND t.CurrencyUsage IS NOT NULL


-- 16. Countries without any Mountains

SELECT CountryCode = COUNT(c.CountryCode) - COUNT(mc.CountryCode)
  FROM Countries AS c
	   LEFT OUTER JOIN 	MountainsCountries AS mc
	   ON mc.CountryCode = c.CountryCode


-- 17. Highest Peak and Longest River by Country

SELECT TOP (5) c.CountryName,
	   HighestPeakElevation =
	   (SELECT MAX(p.Elevation)
	      FROM Peaks AS p
			   INNER JOIN Mountains AS m
			   ON m.Id = p.MountainId
			   INNER JOIN MountainsCountries AS mc
			   ON mc.MountainId = m.Id
			   AND mc.CountryCode = c.CountryCode
	   ),
	   LongestRiverLength =
	   (SELECT MAX(r.[Length])
	      FROM Rivers AS r
			   INNER JOIN CountriesRivers AS cr
			   ON cr.CountryCode = c.CountryCode
			   AND cr.RiverId = r.Id)
  FROM Countries AS c
 ORDER BY HighestPeakElevation DESC,
	   LongestRiverLength DESC


-- 18. Highest Peak Name and Elevation by Country

SELECT TOP (5) c.CountryName AS Country,
	   [Highest Peak Name] = ISNULL(
	   (SELECT PeakName
	      FROM Peaks
		 WHERE Elevation =
			   (SELECT MAX(p.Elevation)
				  FROM Peaks AS p
					   INNER JOIN Mountains AS m
					   ON m.Id = p.MountainId
					   INNER JOIN MountainsCountries AS mc
					   ON mc.MountainId = m.Id
					   AND mc.CountryCode = c.CountryCode)
	   ), '(no highest peak)'),
	   [Highest Peak Elevation] = ISNULL(
	   (SELECT Elevation
	      FROM Peaks
		 WHERE Elevation = 
			   (SELECT MAX(Elevation)
			      FROM Peaks AS p
					   INNER JOIN Mountains AS m
					   ON m.Id = p.MountainId
					   INNER JOIN MountainsCountries AS mc
					   ON mc.CountryCode = c.CountryCode
					   AND mc.MountainId = m.Id)
	   ), 0),
	   Mountain = ISNULL(
	   (SELECT MountainRange
	      FROM Mountains AS m
			   INNER JOIN Peaks AS p
			   ON p.MountainId = m.Id
			   AND p.PeakName = 
			   (SELECT PeakName
				  FROM Peaks
				 WHERE Elevation =
					   (SELECT MAX(p.Elevation)
						  FROM Peaks AS p
							   INNER JOIN Mountains AS m
							   ON m.Id = p.MountainId
							   INNER JOIN MountainsCountries AS mc
							   ON mc.MountainId = m.Id
							   AND mc.CountryCode = c.CountryCode))
	   ), '(no mountain)')
  FROM Countries AS c
 ORDER BY c.CountryName,
	   [Highest Peak Name]