-- 05. Users by Age

SELECT Username,
	   Age
  FROM Users
 ORDER BY Age,
	   Username DESC


-- 06. Unassigned Reports

SELECT [Description],
	   OpenDate
  FROM Reports
 WHERE EmployeeId IS NULL
 ORDER BY OpenDate,
	   [Description]


-- 07. Employees & Reports

SELECT e.FirstName,
	   e.LastName,
	   r.[Description],
	   FORMAT(r.OpenDate, 'yyyy-MM-dd') AS OpenDate
  FROM Reports AS r
	   JOIN Employees AS e
	   ON e.Id = r.EmployeeId
 ORDER BY e.Id,
	   r.OpenDate,
	   r.Id


-- 08. Most reported Category

SELECT c.[Name] AS CategoryName,
	   ReportsNumber = COUNT(r.Id)
  FROM Categories AS c
	   JOIN Reports AS r
	   ON r.CategoryId = c.Id
 GROUP BY c.[Name]
 ORDER BY ReportsNumber DESC,
	   CategoryName


-- 09. Employees in Category

SELECT c.[Name] AS CategoryName,
	   [Employees Number] = COUNT(e.Id)
  FROM Categories AS c
	   JOIN Departments AS d
	   ON d.Id = c.DepartmentId
	   JOIN Employees AS e
	   ON e.DepartmentId = d.Id
 GROUP BY c.[Name]
 ORDER BY CategoryName


-- 10. Users per Employee 

SELECT e.FirstName + ' ' + e.LastName AS [Name],
	   [Users Number] = COUNT(DISTINCT r.UserId)
  FROM Employees AS e
	   LEFT OUTER JOIN Reports AS r
	   ON r.EmployeeId = e.Id
 GROUP BY e.FirstName + ' ' + e.LastName
 ORDER BY [Users Number] DESC,
	   [Name]


-- 11. Emergency Patrol

SELECT r.OpenDate,
	   r.[Description],
	   u.Email AS [Reporter Email]
  FROM Reports AS r
	   JOIN Users AS u
	   ON u.Id = r.UserId
	   JOIN Categories AS c
	   ON c.Id = r.CategoryId
	   JOIN Departments AS d
	   ON d.Id = c.DepartmentId
 WHERE r.CloseDate IS NULL
   AND LEN(r.[Description]) > 20
   AND CHARINDEX('str', r.[Description]) > 0
   AND d.[Name] IN ('Infrastructure', 'Emergency', 'Roads Maintenance')
 ORDER BY r.OpenDate,
	   u.Email,
	   r.Id


-- 12. Birthday Report

SELECT DISTINCT c.[Name] AS [Category Name]
  FROM Categories AS c
	   JOIN Reports AS r
	   ON r.CategoryId = c.Id
	   JOIN Users AS u
	   ON u.Id = r.UserId
	      AND DAY(u.BirthDate) = DAY(r.OpenDate)
	      AND MONTH(u.BirthDate) = MONTH(r.OpenDate)
 ORDER BY [Category Name]


-- 13. Numbers Coincidence

SELECT u.Username
  FROM Users AS u
 WHERE u.Username LIKE '[0-9]%'
   AND (SELECT COUNT(*)
		  FROM Reports
		 WHERE UserId = u.Id 
		   AND CategoryId = SUBSTRING(Username, 1, 1)) > 0
	OR u.Username LIKE '%[0-9]'
   AND (SELECT COUNT(*)
		  FROM Reports
		 WHERE UserId = u.Id 
		   AND CategoryId = SUBSTRING(u.Username, LEN(u.Username), 1)) > 0
ORDER BY u.Username


-- 14. Open/Closed Statistics

SELECT [Name],
	   CONCAT(ClosedReports, '/', OpenReports) AS [Closed Open Reports]
  FROM (SELECT DISTINCT e.FirstName + ' ' + e.LastName AS [Name],
			   e.Id AS EmployeeId,
			   ClosedReports =
			   (SELECT COUNT(*)
			      FROM Reports AS r2
				 WHERE r2.EmployeeId = e.Id
				   AND YEAR(r2.CloseDate) = 2016),
			   OpenReports =
			   (SELECT COUNT(*)
			      FROM Reports AS r3
				 WHERE r3.EmployeeId = e.Id
				   AND YEAR(r3.OpenDate) = 2016)
		  FROM Employees AS e
			   JOIN Reports AS r
			   ON r.EmployeeId = e.Id
		 WHERE YEAR(r.OpenDate) = 2016
		    OR YEAR(r.CloseDate) = 2016
	   ) AS t
 ORDER BY [Name],
	   EmployeeId


-- 15. Average Closing Time

SELECT d.[Name] AS [Department Name],
	   [Average Duration] = ISNULL(CAST(AVG(DATEDIFF(DAY, r.OpenDate, r.CloseDate)) AS VARCHAR), 'no info')
  FROM Departments AS d
	   JOIN Categories AS c
	   ON c.DepartmentId = d.Id
	   JOIN Reports AS r
	   ON r.CategoryId = c.Id
 GROUP BY d.[Name]
 ORDER BY [Department Name]


-- 16. Favorite Categories

SELECT [Department Name],
	   [Category Name],
	   [Percentage] = CAST(ROUND(CategoryReportsCount * 100.0 / DepartmentReportsCount, 0) AS INT)
  FROM (SELECT d.[Name] AS [Department Name],
			   c.[Name] AS [Category Name],
			   COUNT(*) AS CategoryReportsCount,
			   DepartmentReportsCount =
			   (SELECT COUNT(*)
				  FROM Reports AS r2
					   JOIN Categories As c2
					   ON c2.Id = r2.CategoryId
				 WHERE c2.DepartmentId = d.Id)
		  FROM Departments AS d
			   JOIN Categories AS c
			   ON c.DepartmentId = d.Id
			   JOIN Reports AS r
			   ON r.CategoryId = c.Id
		 GROUP BY d.Id,
			   d.[Name],
			   c.Id,
			   c.[Name]
	   ) AS t
 ORDER BY [Department Name],
	   [Category Name],
	   [Percentage]