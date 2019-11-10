-- 01. Create Database

CREATE DATABASE Bank
	   COLLATE Cyrillic_General_100_CI_AS


-- 02. Create Tables

CREATE TABLE Clients (
	Id		  INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	lAStName  NVARCHAR(50) NOT NULL
)

CREATE TABLE AccountTypes (
	Id	   INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Accounts (
	Id			  INT PRIMARY KEY IDENTITY,
	Balance		  DECIMAL(15, 2) DEFAULT(0) NOT NULL,
	AccountTypeId INT FOREIGN KEY REFERENCES AccountTypes(Id),
	ClientId	  INT FOREIGN KEY REFERENCES Clients(Id)
)


-- 03. Insert Sample Data into Database

INSERT INTO Clients 
	   (FirstName, LastName) 
VALUES ('Gosho', 'Ivanov'),
	   ('Pesho', 'Petrov'),
	   ('Ivan', 'Iliev'),
	   ('Merry', 'Ivanova')

INSERT INTO AccountTypes 
	   ([Name]) 
VALUES ('Checking'),
	   ('Savings')

INSERT INTO Accounts 
	   (ClientId, AccountTypeId, Balance) 
VALUES (1, 1, 175),
	   (2, 1, 275.56),
	   (3, 1, 138.01),
	   (4, 1, 40.30),
	   (4, 2, 375.50)


-- 04. Create a Function

CREATE FUNCTION udf_CalculateClientBalance(@ClientID INT)
RETURNS DECIMAL(15, 2)
AS
BEGIN
	DECLARE @clientBalance DECIMAL(15, 2) = 
      (SELECT SUM(Balance)
		 FROM Accounts 
		WHERE ClientId = @ClientID);

	RETURN @clientBalance;
END


-- 05. Create Procedures

CREATE PROC usp_AddAccount @ClientID INT, @AccountTypeID INT
AS
BEGIN
	INSERT INTO Accounts
		   (ClientId, AccountTypeId)
	VALUES (@ClientID, @AccountTypeID)
END

CREATE PROC usp_Deposit @AccountId INT, @Amount DECIMAL(15, 2) 
AS
BEGIN
	IF(@Amount <= 0)
	BEGIN
      RAISERROR('Amount should be greater than 0!', 10, 1);
	  RETURN;
	END

	UPDATE Accounts
	   SET Balance += @Amount
	 WHERE Id = @AccountId
END

CREATE PROC usp_Withdraw @AccountId INT, @Amount DECIMAL(15, 2) 
AS
BEGIN
	IF(@Amount <= 0)
	BEGIN
      RAISERROR('Amount should be greater than 0!', 10, 1);
	  RETURN;
	END
  
	DECLARE @oldBalance DECIMAL(15, 2) =
			(SELECT Balance 
			  FROM Accounts
			 WHERE Id = @AccountId);

	IF(@oldBalance - @Amount < 0)
	BEGIN
	  RAISERROR('Insufficient funds!', 10, 1);
	  RETURN;
	END

	UPDATE Accounts
       SET Balance -= @Amount
	 WHERE Id = @AccountId
END


-- 06. Create Transactions Table and a Trigger

CREATE TABLE Transactions (
	Id		   INT PRIMARY KEY IDENTITY,
	OldBalance DECIMAL(15, 2) NOT NULL,
	NewBalance DECIMAL(15, 2) NOT NULL,
	Amount	   AS NewBalance - OldBalance,
	[DateTime] DATETIME2,
	AccountId  INT FOREIGN KEY REFERENCES Accounts(Id)
)

CREATE TRIGGER tr_AccountsUpdate ON Accounts AFTER UPDATE
AS
	INSERT INTO Transactions
		   (AccountId, OldBalance, NewBalance, [DateTime])
	SELECT inserted.Id,
		   deleted.Balance,
		   inserted.Balance,
		   GETDATE()
	  FROM inserted
		   JOIN deleted 
		   ON deleted.Id = inserted.Id