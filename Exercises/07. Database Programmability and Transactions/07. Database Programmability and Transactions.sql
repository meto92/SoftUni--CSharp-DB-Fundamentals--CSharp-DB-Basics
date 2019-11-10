-- 01. Employees with Salary Above 35000

CREATE PROC usp_GetEmployeesSalaryAbove35000 
AS
BEGIN
	SELECT FirstName AS [First Name],
		   LastName AS [Last Name]
	  FROM Employees
	 WHERE Salary > 35000
END


-- 02. Employees with Salary Above Number

CREATE PROC usp_GetEmployeesSalaryAboveNumber @MinSalary DECIMAL(18, 4)
AS
BEGIN
	SELECT FirstName AS [First Name],
		   LastName AS [Last Name]
	  FROM Employees
	 WHERE Salary >= @MinSalary
END


-- 03. Town Names Starting With

CREATE PROC usp_GetTownsStartingWith @TownNameStart NVARCHAR(50)
AS
BEGIN
	SELECT [Name]
	  FROM Towns
	 WHERE [Name] LIKE @TownNameStart + '%'
END


-- 04. Employees from Town

CREATE PROC usp_GetEmployeesFromTown @TownName NVARCHAR(50)
AS
BEGIN
	SELECT FirstName AS [First Name],
		   LastName AS [Last Name]
	  FROM Employees AS e
		   INNER JOIN Addresses AS a
		   ON a.AddressID = e.AddressID
		   JOIN Towns AS t
		   ON t.TownID = a.TownID
	 WHERE t.[Name] = @TownName
END


-- 05. Salary Level Function

CREATE FUNCTION ufn_GetSalaryLevel(@Salary DECIMAL(18, 4))
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @result VARCHAR(10)

	SET @result =
	CASE
	WHEN @Salary < 30000 THEN 'Low'
	WHEN @Salary <= 50000 THEN 'Average'
	ELSE 'High'
	END

	RETURN @result
END


-- 06. Employees by Salary Level

CREATE PROC usp_EmployeesBySalaryLevel @SalaryLevel VARCHAR(10)
AS
BEGIN
	SELECT FirstName AS [First Name],
		   LastName AS [Last Name]
	  FROM Employees
	 WHERE dbo.ufn_GetSalaryLevel(Salary) = @SalaryLevel
END


-- 07. Define Function

CREATE FUNCTION ufn_IsWordComprised(@SetOfLetters NVARCHAR(MAX), @Word NVARCHAR(MAX))
RETURNS BIT
AS
BEGIN
	DECLARE @wordLength INT = LEN(@Word)
	DECLARE @index INT = 1
	DECLARE @char NCHAR

	WHILE (@index <= @wordLength)
	BEGIN	
		SET @char = SUBSTRING(@Word, @index, 1)

		IF (CHARINDEX(@char, @SetOfLetters) = 0)
		   RETURN 0
	
		SET @index += 1
	END

	RETURN 1
END


-- 08. Delete Employees and Departments

CREATE PROC usp_DeleteEmployeesFromDepartment @DepartmentId INT
AS
BEGIN
	DELETE FROM EmployeesProjects
	 WHERE EmployeeId IN
		   (SELECT EmployeeID
			  FROM Employees
			 WHERE DepartmentId = @DepartmentId)

	ALTER TABLE Departments
	ALTER COLUMN ManagerID INT

	UPDATE Employees
	   SET ManagerID = NULL
	 WHERE ManagerID IN
		   (SELECT EmployeeID
			  FROM Employees
			 WHERE DepartmentId = @DepartmentId)

	UPDATE Departments
	   SET ManagerID = NULL
	 WHERE ManagerID IN
		   (SELECT EmployeeID
			  FROM Employees
			 WHERE DepartmentId = @DepartmentId)

  	DELETE FROM Employees
	 WHERE DepartmentID = @DepartmentId
  
	DELETE FROM Departments
	 WHERE DepartmentID = @DepartmentId  

	 SELECT COUNT(*)
	   FROM Employees
	  WHERE DepartmentID = @DepartmentId
END


-- 09. Find Full Name

CREATE PROC usp_GetHoldersFullName
AS
BEGIN
	SELECT FirstName + ' ' + LastName AS [Full Name]
	  FROM AccountHolders
END


-- 10. People with Balance Higher Than

CREATE PROC usp_GetHoldersWithBalanceHigherThan @MinBalance DECIMAL(15, 2)
AS
BEGIN
	SELECT ah.FirstName AS [First Name],
		   ah.LastName AS [Last Name]
	  FROM AccountHolders AS ah
		   JOIN Accounts AS a
		   ON a.AccountHolderId = ah.Id
	 GROUP BY ah.FirstName,
		   ah.LastName
	HAVING SUM(a.Balance) > @MinBalance
END


-- 11. Future Value Function

CREATE FUNCTION ufn_CalculateFutureValue(@InitialSum DECIMAL(15, 2), @YearlyInterestRate FLOAT, @Years INT)
RETURNS DECIMAL(17, 4)
AS
BEGIN
	DECLARE @futureValue DECIMAL(17, 4)
	SET @futureValue = @InitialSum * (POWER(1 + @YearlyInterestRate, @Years))
	RETURN @futureValue
END


-- 12. Calculating Interest

CREATE PROC usp_CalculateFutureValueForAccount @AccountId INT, @YearlyInterestRate FLOAT
AS
BEGIN
	SELECT @AccountId AS [Account Id],
		   ah.FirstName AS [First Name],
		   ah.LastName AS [Last Name],
		   a.Balance AS [Current Balance],
		   dbo.ufn_CalculateFutureValue(a.Balance, 0.1, 5) AS [Balance in 5 years]
	  FROM Accounts AS a
		   JOIN AccountHolders AS ah
		   ON ah.Id = a.AccountHolderId
	 WHERE a.Id = @AccountId
END


-- 13. Scalar Function: Cash in User Games Odd Rows

CREATE FUNCTION ufn_CashInUsersGames(@GameName VARCHAR(50))
RETURNS TABLE
AS
	RETURN (SELECT SUM(Cash) AS SumCash
			  FROM (SELECT Cash,
						   ROW_NUMBER() OVER(ORDER BY Cash DESC) AS RowNumber
					  FROM UsersGames
					 WHERE GameId = 
						   (SELECT Id
							  FROM Games
							 WHERE [Name] = @GameName
						   )
				   ) AS t
			 WHERE RowNumber % 2 = 1
		   )
		   

-- 14. Create Table Logs

CREATE TABLE Logs (
	LogId     INT IDENTITY,
	OldSum    DECIMAL(15, 2) NOT NULL,
	NewSum	  DECIMAL(15, 2) NOT NULL,
	AccountId INT		     NOT NULL,

	CONSTRAINT PK_Logs_LogId
	PRIMARY KEY(LogId),
	CONSTRAINT FK_Logs_Accounts
	FOREIGN KEY(AccountId)
	REFERENCES Accounts(Id)
)

CREATE TRIGGER tr_AccountsUpdate
ON Accounts
AFTER UPDATE 
AS
BEGIN
	INSERT INTO Logs
		   (AccountId, OldSum, NewSum)
	SELECT i.Id, 
		   d.Balance, 
		   i.Balance
	  FROM inserted AS i
		   JOIN deleted AS d
		   ON i.Id = d.Id
END


-- 15. Create Table Emails

CREATE TABLE NotificationEmails (
	Id        INT IDENTITY,
	Recipient INT NOT NULL,
	[Subject] NVARCHAR(MAX) NOT NULL,
	Body	  NVARCHAR(MAX) NOT NULL
)

CREATE TRIGGER tr_LogsInsert
ON Logs
AFTER INSERT
AS
BEGIN
	INSERT INTO NotificationEmails
		   (Recipient, [Subject], Body)
	SELECT i.AccountId,
		   'Balance change for account: ' + CAST(i.AccountId AS VARCHAR),
		   'On ' + CAST(GETDATE() AS VARCHAR(19)) + ' your balance was changed from ' + CAST(i.OldSum AS VARCHAR) + ' to ' + CAST(i.NewSum AS VARCHAR) + '.'
	  FROM inserted AS i
END


-- 16. Deposit Money

CREATE PROC usp_DepositMoney @AccountId INT, @MoneyAmount DECIMAL(17, 4)
AS
BEGIN
	--IF (@MoneyAmount <= 0)
	--BEGIN
	--	RAISERROR('Money amount cannot be equal or less than 0!', 16, 1)
	--	RETURN
	--END
	BEGIN TRANSACTION
	UPDATE Accounts
	   SET Balance += @MoneyAmount
	 WHERE Id = @AccountId
	IF (@@ROWCOUNT <> 1)
	BEGIN
		ROLLBACK
		RAISERROR('Invalid account id!', 16, 2)
		RETURN
	END
	COMMIT
END


-- 16. Withdraw Money

CREATE PROC usp_WithdrawMoney  @AccountId INT, @MoneyAmount DECIMAL(17, 4)
AS
BEGIN
	--IF (@MoneyAmount <= 0)
	--BEGIN
	--	RAISERROR('Money amount cannot be equal or less than 0!', 16, 1)
	--	RETURN
	--END
	DECLARE @oldBalance DECIMAL(15, 2) =
			(SELECT Balance 
			   FROM Accounts 
			  WHERE Id = @AccountId)
	IF (@oldBalance - @MoneyAmount < 0)
	BEGIN
		RAISERROR('Insufficient funds.', 16, 2)
		RETURN
	END
	BEGIN TRANSACTION
	UPDATE Accounts
	   SET Balance -= @MoneyAmount
	 WHERE Id = @AccountId
	IF (@@ROWCOUNT <> 1)
	BEGIN
		ROLLBACK
		RAISERROR('Invalid account id!', 16, 3)
		RETURN
	END
	COMMIT
END


-- 18. Money Transfer

CREATE PROC usp_TransferMoney @SenderId INT, @ReceiverId INT, @Amount DECIMAL(17, 4)
AS
BEGIN
	BEGIN TRANSACTION
		EXEC usp_WithdrawMoney @SenderId, @Amount
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK
			RETURN
		END
		EXEC usp_DepositMoney @ReceiverId, @Amount
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK
			RETURN
		END
	COMMIT
END


-- 19. Trigger

CREATE TRIGGER tr_UserGameItemsInsert
ON UserGameItems
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @minLevel INT =
			(SELECT i.MinLevel
			   FROM Items AS i
					JOIN inserted
					ON inserted.ItemId = i.Id
			  WHERE i.Id = inserted.ItemId)
	DECLARE @userLevel INT =
			(SELECT ug.[Level]
			   FROM UsersGames AS ug
					JOIN inserted AS i
					ON i.UserGameId = ug.Id)
	IF (@userLevel < @minLevel)
		RETURN
	DECLARE @itemPrice DECIMAL(15, 2) =
			(SELECT i.Price
			   FROM Items AS i
					JOIN inserted  
					ON inserted.ItemId = i.Id)
	DECLARE @cash DECIMAL(15, 2) =
			(SELECT Cash
			   FROM UsersGames AS ug
					JOIN inserted AS i
					ON i.UserGameId = ug.Id)
	IF (@cash < @itemPrice)
		RETURN
	INSERT INTO UserGameItems
		   (ItemId, UserGameId)
	SELECT i.ItemId,
		   i.UserGameId
	  FROM inserted AS i
	UPDATE UsersGames
	   SET Cash -= @itemPrice
	 WHERE Id = 
		   (SELECT UserGameId
		      FROM inserted)
END

DECLARE @user1Id INT =
		(SELECT Id 
		   FROM Users 
		  WHERE Username = 'baleremuda')
DECLARE @user2Id INT =
		(SELECT Id 
		   FROM Users 
		  WHERE Username = 'loosenoise')
DECLARE @user3Id INT =
		(SELECT Id 
		   FROM Users 
		  WHERE Username = 'inguinalself')
DECLARE @user4Id INT =
		(SELECT Id 
		   FROM Users 
		  WHERE Username = 'buildingdeltoid')
DECLARE @user5Id INT =
		(SELECT Id 
		   FROM Users 
		  WHERE Username = 'monoxidecos')
DECLARE @gameId INT =
		(SELECT Id 
		   FROM Games 
		  WHERE [Name] = 'Bali')

UPDATE UsersGames
   SET Cash += 50000
 WHERE GameId = @gameId	   
   AND UserId IN (@user1Id, @user2Id, @user3Id, @user4Id, @user5Id)

DECLARE @user1GameId INT = 
		(SELECT Id 
		   FROM UsersGames 
		  WHERE GameId = @gameId 
		    AND UserId = @user1Id)
DECLARE @user2GameId INT =
		(SELECT Id 
		   FROM UsersGames 
		  WHERE GameId = @gameId 
		    AND UserId = @user2Id)
DECLARE @user3GameId INT =
		(SELECT Id 
		   FROM UsersGames 
		  WHERE GameId = @gameId 
		    AND UserId = @user3Id)
DECLARE @user4GameId INT =
		(SELECT Id 
		   FROM UsersGames 
		  WHERE GameId = @gameId 
		    AND UserId = @user4Id)
DECLARE @user5GameId INT =
		(SELECT Id 
		   FROM UsersGames 
		  WHERE GameId = @gameId 
		    AND UserId = @user5Id)
DECLARE @itemId INT = 251

WHILE (@itemId < 540)
BEGIN
	INSERT INTO UserGameItems
	VALUES (@itemId, @user1GameId)
	INSERT INTO UserGameItems
	VALUES (@itemId, @user2GameId)
	INSERT INTO UserGameItems
	VALUES (@itemId, @user3GameId)
	INSERT INTO UserGameItems
	VALUES (@itemId, @user4GameId)
	INSERT INTO UserGameItems
	VALUES (@itemId, @user5GameId)

	--INSERT INTO UserGameItems
	--	   (ItemId, UserGameId)
	--VALUES (@itemId, @user1GameId),
	--	   (@itemId, @user2GameId),
	--	   (@itemId, @user3GameId),
	--	   (@itemId, @user4GameId),
	--	   (@itemId, @user5GameId)

	SET @itemId +=  1
	IF (@itemId = 300)
		SET @itemId = 501
END

SELECT u.Username,
	   g.[Name],
	   ug.Cash,
	   i.[Name] AS [Item Name]
  FROM UsersGames AS ug
	   JOIN Users AS u
	   ON u.Id = ug.UserId
	   JOIN Games AS g
	   ON g.Id = ug.GameId
	   JOIN UserGameItems AS ugi
	   ON ugi.UserGameId = ug.Id
	   JOIN Items AS i
	   ON i.Id = ugi.ItemId
 WHERE g.[Name] = 'Bali'
 ORDER BY u.Username,
	   i.[Name]


-- 20. Massive Shopping

DECLARE @userGameId INT =
	(SELECT Id
	   FROM UsersGames AS ug
	  WHERE ug.UserId = 
		    (SELECT Id
			   FROM Users
			  WHERE Username = 'Stamat')
		AND ug.GameId = 
			(SELECT Id
			   FROM Games
			  WHERE [Name] = 'Safflower'))

BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO UserGameItems
			   (ItemId, UserGameId)
		SELECT Id,
			   @userGameId
		  FROM Items
		 WHERE MinLevel IN (11, 12)

		 UPDATE UsersGames
		    SET Cash -=
			    (SELECT SUM(Price)
			       FROM Items
				  WHERE MinLevel IN (11, 12))
		  WHERE Id = @userGameId
	COMMIT	
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH

BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO UserGameItems
			   (ItemId, UserGameId)
		SELECT Id,
			   @userGameId
		  FROM Items
		 WHERE MinLevel IN (19, 20, 21)

		 UPDATE UsersGames
		    SET Cash -=
			    (SELECT SUM(Price)
			       FROM Items
				  WHERE MinLevel IN (19, 20, 21))
		  WHERE Id = @userGameId
	COMMIT	
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH

SELECT i.[Name] AS [Item Name]
  FROM Items AS i
	   JOIN UserGameItems AS ugi
	   ON ugi.ItemId = i.Id
	   JOIN UsersGames AS ug
	   ON ug.Id = ugi.UserGameId
	   JOIN Games AS g
	   ON g.Id = ug.GameId
	   JOIN Users AS u
	   ON u.Id = ug.UserId
 WHERE g.[Name] = 'Safflower'
   AND u.[Username] = 'Stamat'
 ORDER BY i.[Name]


-- 21. Employees with Three Projects

CREATE PROC usp_AssignProject @EmployeeId INT, @ProjectId INT
AS
BEGIN
	BEGIN TRANSACTION
		INSERT INTO EmployeesProjects
			   (EmployeeID, ProjectID)
		VALUES (@EmployeeId, @ProjectId)
		DECLARE @employeeProjectsCount INT =
				(SELECT COUNT(*)
				   FROM EmployeesProjects
				  WHERE EmployeeID = @EmployeeId)
		IF (@employeeProjectsCount > 3)
		BEGIN
			ROLLBACK
			RAISERROR('The employee has too many projects!', 16, 1)
			RETURN
		END
	COMMIT
END


-- 22. Delete Employees

CREATE TABLE Deleted_Employees (
	EmployeeId   INT IDENTITY,
	FirstName    NVARCHAR(50),
	LastName     NVARCHAR(50),
	MiddleName   NVARCHAR(50),
	JobTitle	 NVARCHAR(50),
	Salary		 DECIMAL(15, 2),
	DepartmentId INT

	CONSTRAINT PK_Deleted_Employees_EmployeeId
	PRIMARY KEY(EmployeeId)
)

CREATE TRIGGER tr_EmployeesDelete
ON Employees
AFTER DELETE
AS
BEGIN
	INSERT INTO Deleted_Employees
		   (FirstName, LastName, MiddleName, JobTitle, Salary, DepartmentId)
	SELECT FirstName,
		   LastName,
		   MiddleName,
		   JobTitle,
		   Salary,
		   DepartmentID
	  FROM deleted
END