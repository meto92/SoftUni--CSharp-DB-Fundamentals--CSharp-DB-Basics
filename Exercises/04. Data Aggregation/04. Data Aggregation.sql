-- 01. Records’ Count

SELECT COUNT(*) AS [Count]
  FROM WizzardDeposits


-- 02. Longest Magic Wand

SELECT MAX(MagicWandSize) AS LongestMagicWand
  FROM WizzardDeposits


-- 03. Longest Magic Wand per Deposit Groups

SELECT DepositGroup,
	   MAX(MagicWandSize) AS LongestMagicWand
  FROM WizzardDeposits
 GROUP BY DepositGroup


-- 04. Smallest Deposit Group per Magic Wand Size

SELECT TOP 2 DepositGroup
  FROM WizzardDeposits
 GROUP BY DepositGroup
 ORDER BY AVG(MagicWandSize)


-- 05. Deposits Sum

SELECT DepositGroup,
	   SUM(DepositAmount) AS TotalSum
  FROM WizzardDeposits
 GROUP BY DepositGroup


-- 06. Deposits Sum for Ollivander Family

SELECT DepositGroup,
	   TotalSum = SUM(DepositAmount)
  FROM WizzardDeposits
 WHERE MagicWandCreator = 'Ollivander family'
 GROUP BY DepositGroup


-- 07. Deposits Filter

SELECT DepositGroup,
	   TotalSum = SUM(DepositAmount)
  FROM WizzardDeposits
 WHERE MagicWandCreator = 'Ollivander family'
 GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
 ORDER BY TotalSum DESC


-- 08. Deposit Charge

SELECT DepositGroup,
	   MagicWandCreator,
	   MinDepositCharge = MIN(DepositCharge)
  FROM WizzardDeposits
 GROUP BY DepositGroup, 
	   MagicWandCreator
 ORDER BY MagicWandCreator,
	   DepositGroup
		 

-- 09. Age Groups
    
SELECT AgeGroup =
	   CASE
	   WHEN Age >= 61 THEN '[61+]'
	   WHEN Age % 10 = 0 THEN CONCAT('[', Age / 10 - 1, '1', '-', Age / 10, '0', ']')
	   ELSE CONCAT('[', Age / 10, '1', '-', Age / 10 + 1, '0', ']')
	   END,
 COUNT (Age)
  FROM WizzardDeposits
 GROUP BY
	   CASE
	   WHEN Age >= 61 THEN '[61+]'
	   WHEN Age % 10 = 0 THEN CONCAT('[', Age / 10 - 1, '1', '-', Age / 10, '0', ']')
	   ELSE CONCAT('[', Age / 10, '1', '-', Age / 10 + 1, '0', ']')
	   END


-- 10. First Letter

SELECT LEFT(FirstName, 1) AS FirstLetter
  FROM WizzardDeposits
 WHERE DepositGroup = 'Troll Chest'
 GROUP BY LEFT(FirstName, 1)


-- 11. Average Interest

SELECT DepositGroup,
	   IsDepositExpired,
	   AverageInterest = AVG(DepositInterest)
  FROM WizzardDeposits
 WHERE DepositStartDate > '01/01/1985'
 GROUP BY DepositGroup,
	   IsDepositExpired
 ORDER BY DepositGroup DESC,
	   IsDepositExpired


-- 12. Rich Wizard, Poor Wizard

--SELECT SUM([Difference]) AS SumDifference
--  FROM (SELECT [Difference] = HostWizardDepositAmount - GuestWizardDepositAmount
--		  FROM (SELECT DepositAmount AS HostWizardDepositAmount, 
--					   LEAD(DepositAmount) OVER(ORDER BY Id) AS GuestWizardDepositAmount
--				  FROM WizzardDeposits
--			   ) AS t
--	   ) AS t2

DECLARE @hostsCursor CURSOR
DECLARE @guestsCursor CURSOR
DECLARE @hostWizardName VARCHAR(50)
DECLARE @hostWizardDepositAmount DECIMAL(15, 2)
DECLARE @guestWizardName VARCHAR(50)
DECLARE @guestWizardDepositAmount DECIMAL(15, 2)
DECLARE @sumDifference DECIMAL(15, 2) = 0
DECLARE @t AS TABLE (
	[Host Wizard]		   VARCHAR(50),
	[Host Wizard Deposit]  DECIMAL(15, 2),
	[Guest Wizard]		   VARCHAR(50),
	[Guest Wizard Deposit] VARCHAR(50),
	[Difference]		   DECIMAL(15, 2)
)

BEGIN
    SET @hostsCursor = CURSOR FOR
    SELECT TOP (SELECT COUNT(*) - 1 FROM WizzardDeposits) FirstName, DepositAmount FROM WizzardDeposits
	
	SET @guestsCursor = CURSOR FOR
	SELECT FirstName, DepositAmount 
	FROM WizzardDeposits 
	ORDER BY Id 
	OFFSET 1 ROWS 
	FETCH NEXT (SELECT COUNT(*) - 1 FROM WizzardDeposits) ROWS ONLY

    OPEN @hostsCursor
    FETCH NEXT FROM @hostsCursor
    INTO @hostWizardName, @hostWizardDepositAmount

	OPEN @guestsCursor
    FETCH NEXT FROM @guestsCursor
    INTO @guestWizardName, @guestWizardDepositAmount

    WHILE @@FETCH_STATUS = 0
    BEGIN
	  DECLARE @difference DECIMAL(15, 2) = @hostWizardDepositAmount - @guestWizardDepositAmount;

	  INSERT INTO @t
		   VALUES (@hostWizardName, @hostWizardDepositAmount, @guestWizardName, @guestWizardDepositAmount, @difference)

	  SET @sumDifference += @difference

	  FETCH NEXT FROM @hostsCursor
	  INTO @hostWizardName, @hostWizardDepositAmount

      FETCH NEXT FROM @guestsCursor
      INTO @guestWizardName, @guestWizardDepositAmount
    END

    CLOSE @hostsCursor
    CLOSE @guestsCursor
    DEALLOCATE @hostsCursor
    DEALLOCATE @guestsCursor
END

--SELECT * FROM @t
SELECT @sumDifference AS SumDifference


-- 13. Departments Total Salaries

SELECT DepartmentID,
	   SUM(Salary) AS TotalSalary
  FROM Employees
 GROUP BY DepartmentID


-- 14. Employees Minimum Salaries

SELECT DepartmentID,
	   MIN(Salary) AS MinimumSalary
  FROM Employees
 WHERE DepartmentID IN (2, 5, 7) 
   AND HireDate > '01/01/2000'
 GROUP BY DepartmentID


-- 15. Employees Average Salaries 

SELECT *
  INTO EmployeesCopy
  FROM Employees
WHERE Salary > 30000
  
DELETE EmployeesCopy
 WHERE ManagerID = 42

UPDATE EmployeesCopy
   SET Salary += 5000
 WHERE DepartmentID = 1

SELECT DepartmentID,
	   AVG(Salary) AS AverageSalary
  FROM EmployeesCopy
 GROUP BY DepartmentID


-- 16. Employees Maximum Salaries

SELECT DepartmentID,
	   MAX(Salary) AS MaxSalary 
  FROM Employees
 GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000


-- 17. Employees Count Salaries

SELECT COUNT(*) AS Count
  FROM Employees
 WHERE ManagerID IS NULL


-- 18. 3rd Highest Salary

SELECT DISTINCT DepartmentID,
	   (SELECT DISTINCT Salary 
	      FROM Employees AS e2 
	     WHERE e2.DepartmentID = e.DepartmentID 
	     ORDER BY e2.Salary DESC 
	    OFFSET 2 ROWS
	     FETCH NEXT 1 ROWS ONLY) AS ThirdHighestSalary
  FROM Employees AS e
 WHERE (SELECT COUNT(DISTINCT(Salary)) 
		  FROM Employees AS e3 
		 WHERE e3.DepartmentID = e.DepartmentID) >= 3


-- 19. Salary Challenge

SELECT TOP (10) e.FirstName,
	   e.LastName,
	   e.DepartmentID
  FROM Employees AS e
 WHERE e.Salary >
	   (SELECT AVG(Salary)
	      FROM Employees AS e2
		 WHERE e2.DepartmentID = e.DepartmentID
		 GROUP BY e2.DepartmentID)
-- ORDER BY e.DepartmentID