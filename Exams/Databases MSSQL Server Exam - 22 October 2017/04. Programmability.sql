--17. Employee's Load

CREATE FUNCTION udf_GetReportsCount(@EmployeeId INT, @StatusId INT)
RETURNS INT
AS
BEGIN
	DECLARE @reportsCount INT =
			(SELECT COUNT(*)
			   FROM Reports
			  WHERE EmployeeId = @EmployeeId
				AND StatusId = @StatusId)

	RETURN @reportsCount
END


--18. Assign Employee

CREATE PROC usp_AssignEmployeeToReport @EmployeeId INT, @ReportId INT
AS
BEGIN
	BEGIN TRANSACTION
		UPDATE Reports
		   SET EmployeeId = @EmployeeId
		 WHERE Id = @ReportId

		DECLARE @employeeDepartmmentId INT =
				(SELECT DepartmentId
				   FROM Employees
				  WHERE Id = @EmployeeId)
		DECLARE @reportCategoryDepartmmentId INT =
				(SELECT c.DepartmentId
				   FROM Categories AS c
						JOIN Reports AS r
						ON r.CategoryId = c.Id
				  WHERE r.Id = @ReportId)
		
		IF (@employeeDepartmmentId <> @reportCategoryDepartmmentId)
		BEGIN
			ROLLBACK;
			RAISERROR('Employee doesn''t belong to the appropriate department!', 16, 1)
			RETURN
		END
	COMMIT
END


--19. Close Reports

CREATE TRIGGER tr_ReportsUpdate
ON Reports
AFTER UPDATE
AS
BEGIN
	UPDATE Reports
	   SET StatusId =
		   (SELECT Id
		      FROM [Status]
			 WHERE Label = 'completed')
	 WHERE Id =
		   (SELECT i.Id
		      FROM inserted AS i
				   JOIN deleted AS d
				   ON d.CloseDate IS NULL
				      AND i.CloseDate IS NOT NULL)
END


-- 20. Categories Revision

SELECT [Category Name],
	   [Reports Number],
	   [Main Status] =
	   CASE
	   WHEN [Waiting Number] = [Reports Number] / 2.0 THEN 'equal'
	   WHEN [Waiting Number] > [Reports Number] - [Waiting Number] THEN 'waiting'
	   ELSE 'in progress'
	   END
  FROM (SELECT c.[Name] AS [Category Name],
			   [Reports Number] = COUNT(*),
			   [Waiting Number] =
			   (SELECT COUNT(*)
			      FROM Reports AS r2
					   JOIN Categories AS c2
					   ON c2.Id = r2.CategoryId
					   JOIN [Status] AS s2
					   ON s2.Id = r2.StatusId
				 WHERE c2.[Name] = c.[Name]
				   AND s2.Label = 'waiting')
		  FROM Categories AS c
			   JOIN Reports AS r
			   ON r.CategoryId = c.Id
			   JOIN [Status] AS s
			   ON s.Id = r.StatusId
		 WHERE s.Label IN ('waiting', 'in progress')
		 GROUP BY c.[Name]
	   ) AS t
 ORDER BY [Category Name],
	   [Reports Number],
	   [Main Status]