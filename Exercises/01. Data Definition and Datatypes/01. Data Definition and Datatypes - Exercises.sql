-- 01. Create Database

CREATE DATABASE Minions


-- 02. Create Tables

CREATE TABLE Minions (
	Id	   INT		   NOT NULL,
	[Name] VARCHAR(50) NOT NULL,
	Age    INT CHECK(Age >= 0),

	CONSTRAINT PK_Minions_Id
	PRIMARY KEY(Id)
)

CREATE TABLE Towns (
	Id	   INT		   NOT NULL,
	[Name] VARCHAR(50) NOT NULL,
	
	CONSTRAINT PK_Towns_Id
	PRIMARY KEY(Id)
)


-- 03. Alter Minions Table

ALTER TABLE Minions
ADD TownId INT

ALTER TABLE Minions
ADD CONSTRAINT FK_Minions_Towns
FOREIGN KEY (TownId) 
REFERENCES Towns(Id);


-- 04. Insert Records in Both Tables

INSERT INTO Towns
	   (Id, [Name])
VALUES (1, 'Sofia'),
	   (2, 'Plovdiv'),
	   (3, 'Varna')
			
INSERT INTO Minions
	   (Id, [Name], Age, TownId)
VALUES (1, 'Kevin', 22, 1),
	   (2, 'Bob', 15, 3),
	   (3, 'Steward', NULL, 2)


-- 05. Truncate Table Minions			

TRUNCATE TABLE Minions


-- 06. Drop All Tables

DROP TABLE Minions

DROP TABLE Towns


-- 07. Create Table People

CREATE TABLE People (
	Id		  INT PRIMARY KEY IDENTITY,
	[Name]    NVARCHAR(200) NOT NULL,
	Picture   VARBINARY(MAX),
	Height    DECIMAL(3, 2),
	[Weight]  DECIMAL(5, 2),
	Gender	  CHAR			NOT NULL,
	Birthdate DATE			NOT NULL,
	Biography VARCHAR(MAX),

	CONSTRAINT CHK_Picture
	CHECK(DATALENGTH(Picture) <= 2048 * 1024),
	CONSTRAINT CHK_Height
	CHECK(Height > 0),
	CONSTRAINT CHK_Weight
	CHECK(Weight > 0),
	CONSTRAINT CHK_Gender
	CHECK(Gender IN('m', 'f'))
)

INSERT INTO People
	   ([Name], Height, [Weight], Gender, Birthdate)
VALUES ('Berk Mayer', 1.68, 81, 'm', '04/06/1979'),
	   ('Elvis Salas	', 1.61, 78, 'm', '05/23/1980'),
	   ('Thomas Gardner', 1.51, 86, 'm', '04/17/1978'),
	   ('Quinn Bass', 1.77, 71, 'f', '12/21/1971'),
	   ('Ali Petty', 1.66, 52, 'm', '05/16/1987')


-- 08. Create Table Users

CREATE TABLE Users (
	Id			   BIGINT IDENTITY,
	Username	   VARCHAR(30) NOT NULL,
	[Password]	   VARCHAR(26) NOT NULL,
	ProfilePicture VARBINARY(MAX),
	LastLoginTime  SMALLDATETIME,
	IsDeleted	   BIT DEFAULT(0)
	
	CONSTRAINT PK_Users_Id
	PRIMARY KEY(Id),
	CONSTRAINT UQ_Password
	UNIQUE([Password]), 
	CONSTRAINT CHK_ProfilePicture
	CHECK(DATALENGTH(ProfilePicture) <= 900 * 1024)
)

INSERT INTO Users
	   (Username, [Password])
VALUES ('Kermit', '12345'),
	   ('Ciaran', 'password'),
	   ('Lane', 'bestpassword'),
	   ('Keane', 'hello'),
	   ('Herman', 'goodbye')
	
			
-- 09. Change Primary Key

ALTER TABLE Users
DROP CONSTRAINT PK_Users_Id

ALTER TABLE Users
ADD CONSTRAINT PK_Users 
PRIMARY KEY (Id, Username)


-- 10. Add Check Constraint

ALTER TABLE Users
ADD CONSTRAINT CHK_Password 
CHECK (LEN([Password]) >= 5)


-- 11. Set Default Value of a Field

ALTER TABLE Users
ADD DEFAULT GETDATE()
FOR LastLoginTime 

-- 12. Set Unique Field

ALTER TABLE Users
DROP CONSTRAINT PK_Users

ALTER TABLE Users
ADD CONSTRAINT PK_Users_Id 
PRIMARY KEY (Id)

-- 13. Movies Database

CREATE DATABASE Movies

CREATE TABLE Directors (
	Id			 INT IDENTITY,
	DirectorName VARCHAR(50) NOT NULL,
	Notes		 VARCHAR(MAX)
	
	CONSTRAINT PK_Directors_Id
	PRIMARY KEY(Id),
	CONSTRAINT UQ_DirectorName
	UNIQUE(DirectorName)
)

CREATE TABLE Genres (
	Id		  INT IDENTITY,
	GenreName VARCHAR(50) NOT NULL,
	Notes	  VARCHAR(MAX)
	
	CONSTRAINT PK_Genres_Id
	PRIMARY KEY(Id),
	CONSTRAINT UQ_GenreName
	UNIQUE(GenreName)
)

CREATE TABLE Categories (
	Id			 INT IDENTITY,
	CategoryName VARCHAR(50) NOT NULL,
	Notes		 VARCHAR(MAX)
	
	CONSTRAINT PK_Categories_Id
	PRIMARY KEY(Id),
	CONSTRAINT UQ_CategoryName
	UNIQUE(CategoryName)
)

CREATE TABLE Movies (
	Id			  INT IDENTITY,
	Title		  VARCHAR(100) NOT NULL,
	CopyrightYear INT		   NOT NULL,
	[Length]	  INT		   NOT NULL,
	Rating		  DECIMAL(3, 1),
	Notes		  VARCHAR(MAX),
	DirectorId	  INT		   NOT NULL,
	GenreId		  INT		   NOT NULL,
	CategoryId	  INT		   NOT NULL
	
	CONSTRAINT PK_Movies_Id
	PRIMARY KEY(Id),
	CONSTRAINT CHK_Length
	CHECK([Length] > 0),
	CONSTRAINT CHK_Rating
	CHECK(Rating BETWEEN 0 AND 10),
	CONSTRAINT FK_Movies_Directors
	FOREIGN KEY(DirectorId)
	REFERENCES Directors(Id),
	CONSTRAINT FK_Movies_Genres
	FOREIGN KEY(GenreId)
	REFERENCES Genres(Id),
	CONSTRAINT FK_Movies_Categories
	FOREIGN KEY(CategoryId)
	REFERENCES Categories(Id)
)

INSERT INTO Directors
	   (DirectorName)
VALUES ('Taika Waititi'),
	   ('James Ponsoldt'),
	   ('Dean Devlin'),
	   ('Rupert Sanders'),
	   ('Luc Besson')

INSERT INTO Genres
	   (GenreName)
VALUES ('Fantasy'),
	   ('Action'),
	   ('Drama'),
	   ('Thriller'),
	   ('Science fiction')

INSERT INTO Categories
	   (CategoryName)
VALUES ('Favourites'),
	   ('C2'),
	   ('C3'),
	   ('C4'),
	   ('C5')

INSERT INTO Movies
	   (Title, CopyrightYear, [Length], Rating, DirectorId, GenreId, CategoryId)
VALUES ('Thor: Ragnarok', 2017, 130, 7.9, 1, 1, 1),
	   ('The circle', 2017, 110, 5.3, 2, 5, 1),
	   ('Geostorm', 2017, 109, 5.4, 3, 2, 1),
	   ('Ghost in the Shell', 2017, 107, 6.4, 4, 3, 1),
	   ('Valerian and the City of a Thousand Planets', 2017, 137, 6.5, 5, 1, 1)


-- 14. Car Rental Database

CREATE DATABASE CarRental

CREATE TABLE Categories (
	Id		     INT IDENTITY,
	CategoryName VARCHAR(50) NOT NULL,
	DailyRate	 DECIMAL(10, 2),
	WeeklyRate   DECIMAL(10, 2),
	MonthlyRate  DECIMAL(10, 2),
	WeekendRate  DECIMAL(10, 2)

	CONSTRAINT PK_Categories_Id
	PRIMARY KEY(Id),
	CONSTRAINT CHK_Rates CHECK(
			   DailyRate > 0  AND 
			   WeeklyRate > 0 AND 
			   MonthlyRate > 0 AND 
			   WeekendRate > 0)
)

CREATE TABLE Cars (
	Id			 INT IDENTITY,
	PlateNumber  VARCHAR(15) NOT NULL,
	Manufacturer VARCHAR(50) NOT NULL,
	Model		 VARCHAR(50) NOT NULL,
	CarYear		 INT		 NOT NULL,
	Doors		 INT		 NOT NULL,
	Picture		 VARBINARY(MAX),
	Condition	 VARCHAR(MAX),
	Available	 BIT DEFAULT(1),
	CategoryId   INT

	CONSTRAINT PK_Cars_Id
	PRIMARY KEY(Id),
	CONSTRAINT CHK_Picture
	CHECK(DATALENGTH(Picture) <= 5 * 1024 * 1024),
	CONSTRAINT FK_Cars_Categories
	FOREIGN KEY(CategoryId)
	REFERENCES Categories(Id)
)

CREATE TABLE Employees (
	Id		  INT IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName  NVARCHAR(50) NOT NULL,
	Title	  VARCHAR(50),
	Notes	  VARCHAR(MAX) 

	CONSTRAINT PK_Employees_Id
	PRIMARY KEY(Id)
)

CREATE TABLE Customers (
	Id					INT IDENTITY,
	DriverLicenceNumber CHAR(10),
	FullName			VARCHAR(100) NOT NULL,
	[Address]		    VARCHAR(100) NOT NULL,
	City				VARCHAR(50) NOT NULL,
	ZIPCode				INT,
	Notes				VARCHAR(MAX)

	CONSTRAINT PK_Customers_Id
	PRIMARY KEY(Id)
)

CREATE TABLE RentalOrders (
	Id				 INT IDENTITY,
	TankLevel		 DECIMAL(2, 1),
	KilometrageStart INT NOT NULL,
	KilometrageEnd   INT NOT NULL,
	TotalKilometrage AS KilometrageEnd - KilometrageStart,
	StartDate		 DATETIME2 NOT NULL,
	EndDate			 DATETIME2 NOT NULL,
	TotalDays		 AS DATEDIFF(DAY, StartDate, EndDate),
	RateApplied		 DECIMAL(10, 2),
	TaxRate			 DECIMAL(10, 2),
	OrderStatus		 VARCHAR(100),
	Notes			 VARCHAR(MAX),
	EmployeeId		 INT NOT NULL,
	CustomerId		 INT NOT NULL,
	CarId			 INT NOT NULL

	CONSTRAINT PK_RentalOrders_Id
	PRIMARY KEY(Id),
	CONSTRAINT CHK_TankLevel
	CHECK(TankLevel BETWEEN 0 AND 1),
	CONSTRAINT CHK_KilometrageStart
	CHECK(KilometrageStart > 0),
	CONSTRAINT CHK_Dates
	CHECK(EndDate >= StartDate),
	CONSTRAINT CHK_KilometrageEnd
	CHECK(KilometrageEnd > KilometrageStart),
	CONSTRAINT FK_RentalOrders_Employees
	FOREIGN KEY(EmployeeId)
	REFERENCES Employees(Id),
	CONSTRAINT FK_RentalOrders_Customers
	FOREIGN KEY(CustomerId)
	REFERENCES Customers(Id),
	CONSTRAINT FK_RentalOrders_Cars
	FOREIGN KEY(CarId)
	REFERENCES Cars(Id)
)

INSERT INTO Categories
	   (CategoryName)
VALUES ('C1'),
	   ('C2'),
	   ('C3')

INSERT INTO Cars
	   (PlateNumber, Manufacturer, Model, CarYear, Doors)
VALUES ('111', 'MF1', 'M1', 2001, 5),
	   ('222', 'MF2', 'M2', 2002, 5),
	   ('333', 'MF3', 'M3', 2003, 5)

INSERT INTO Employees 
	   (FirstName, LastName)
VALUES ('Sawyer', 'Ramirez'),
	   ('Hedley', 'Moss'),
	   ('Francis', 'Wiggins')

INSERT INTO Customers
	   (FullName, [Address], City)
VALUES ('Dorian Schwartz', '43 Rocky River Ave.', 'Mason'),
	   ('Dorian Schwartz', '31 Mayflower Street', 'Oklahoma '),
	   ('Dorian Schwartz', '8092 North Hall Ave.', 'Kansas')

INSERT INTO RentalOrders
	   (KilometrageStart, KilometrageEnd, StartDate, EndDate, EmployeeId, CustomerId, CarId)
VALUES (50000, 80000, CONVERT(DATETIME2, '22/05/2017', 103), CONVERT(DATETIME2, '30/09/2017', 103), 1, 2, 3),
	   (70000, 120000, CONVERT(DATETIME2, '11/04/2017', 103), CONVERT(DATETIME2, '30/04/2017', 103), 3, 1, 2),
	   (1000, 5000, CONVERT(DATETIME2, '01/01/2017', 103), CONVERT(DATETIME2, '31/03/2017', 103), 1, 3, 2)


-- 15. Hotel Database

CREATE DATABASE Hotel

CREATE TABLE Employees (
	Id		  INT IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName  VARCHAR(50) NOT NULL,
	Title	  VARCHAR(50),
	Notes	  VARCHAR(MAX)

	CONSTRAINT PK_Employees_Id
	PRIMARY KEY(Id)
)

CREATE TABLE Customers (
	Id				INT IDENTITY,
	AccountNumber   VARCHAR(50) NOT NULL,
	FirstName	    VARCHAR(50) NOT NULL,
	LastName	    VARCHAR(50) NOT NULL,
	PhoneNumbe	    VARCHAR(50) NOT NULL,
	EmergencyName   VARCHAR(50),
	EmergencyNumber VARCHAR(50),
	Notes			VARCHAR(MAX)

	CONSTRAINT PK_Customers_Id
	PRIMARY KEY(Id)
)

CREATE TABLE RoomStatus (
	Id		   INT IDENTITY,
	RoomStatus VARCHAR(50) NOT NULL,
	Notes	   VARCHAR(MAX)

	CONSTRAINT PK_RoomStatus_Id
	PRIMARY KEY(Id)
)

CREATE TABLE RoomTypes (
	Id		 INT IDENTITY,
	RoomType VARCHAR(50) NOT NULL,
	Notes	 VARCHAR(MAX)

	CONSTRAINT PK_RoomTypes_Id
	PRIMARY KEY(Id)
)

CREATE TABLE BedTypes (
	Id		INT IDENTITY,
	BedType VARCHAR(50) NOT NULL,
	Notes   VARCHAR(MAX)

	CONSTRAINT PK_BedTypes_Id
	PRIMARY KEY(Id)
)

CREATE TABLE Rooms (
	Id		   INT IDENTITY,
	RoomNumber INT		   NOT NULL,
	RoomType   VARCHAR(50) NOT NULL,
	BedType    VARCHAR(50) NOT NULL,
	Rate	   VARCHAR(50),
	RoomStatus VARCHAR(50) NOT NULL,
	Notes	   VARCHAR(MAX)

	CONSTRAINT PK_Rooms_Id
	PRIMARY KEY(Id),
	CONSTRAINT CHK_Rate
	CHECK(Rate BETWEEN 0 AND 10)
)

CREATE TABLE Payments (
	Id				 INT IDENTITY,
	PaymentDate		  DATETIME2 DEFAULT(GETDATE()),
	AccountNumber	  VARCHAR(50)	 NOT NULL,
	FirstDateOccupied DATETIME2		 NOT NULL,
	LastDateOccupied  DATETIME2		 NOT NULL,
	TotalDays		  AS DATEDIFF(DAY, FirstDateOccupied, LastDateOccupied),
	AmountCharged	  DECIMAL(15, 2) NOT NULL,
	TaxRate			  DECIMAL(4, 2)  NOT NULL,
	TaxAmount		  AS AmountCharged * TaxRate / 100,
	PaymentTotal	  AS AmountCharged * (1 + TaxRate / 100),
	Notes			  VARCHAR(MAX),
	EmployeeId		  INT NOT NULL

	CONSTRAINT PK_Payments_Id
	PRIMARY KEY(Id),
	CONSTRAINT CHK_Dates
	CHECK(LastDateOccupied > FirstDateOccupied),
	CONSTRAINT CHK_AmountCharged
	CHECK(AmountCharged > 0),
	CONSTRAINT CHK_TaxRate
	CHECK(TaxRate BETWEEN 0 AND 100),
	CONSTRAINT FK_Payments_Employees
	FOREIGN KEY(EmployeeId)
	REFERENCES Employees(Id)
)

CREATE TABLE Occupancies (
	Id			  INT IDENTITY,
	DateOccupied  DATETIME2,
	AccountNumber VARCHAR(50) NOT NULL,
	RoomNumber    INT		  NOT NULL,
	RateApplied	  DECIMAL(15, 2),
	PhoneCharge	  DECIMAL(15, 2),
	Notes		  VARCHAR(MAX),
	EmployeeId    INT		  NOT NULL

	CONSTRAINT PK_Occupancies_Id
	PRIMARY KEY(Id),
	CONSTRAINT FK_Occupancies_Employees
	FOREIGN KEY(EmployeeId)
	REFERENCES Employees(Id)
)

INSERT INTO Employees
	   (FirstName, LastName)
VALUES ('Zahir', 'Pearson	'),
	   ('Isaac', 'Hinton'),
	   ('Kelly', 'Hester')

INSERT INTO Customers
	   (AccountNumber, FirstName, LastName, PhoneNumber)
VALUES ('954343896229', 'Laith', 'Fry', '202-555-0190'),
	   ('055744076567', 'Gareth', 'Butler', '202-555-0130'),
	   ('113130121161', 'Drake', 'Rollins', '202-555-0172')

INSERT INTO RoomStatus
	   (RoomStatus)
VALUES ('Vacant and ready'),
	   ('Occupied'),
	   ('Do Not Disturb')

INSERT INTO RoomTypes
	   (RoomType)
VALUES ('Single'),
	   ('Double'),
	   ('Studio')

INSERT INTO BedTypes
	   (BedType)
VALUES ('Platform'),
	   ('Panel'),
	   ('Folding')

INSERT INTO Rooms
	   (RoomNumber, RoomType, BedType, RoomStatus)
VALUES (118, (SELECT RoomType FROM RoomTypes WHErE Id = 1), (SELECT BedType FROM BedTypes WHErE Id = 2), (SELECT RoomStatus FROM RoomStatus WHErE Id = 3)),
	   (230, (SELECT RoomType FROM RoomTypes WHErE Id = 2), (SELECT BedType FROM BedTypes WHErE Id = 3), (SELECT RoomStatus FROM RoomStatus WHErE Id = 1)),
	   (122, (SELECT RoomType FROM RoomTypes WHErE Id = 1), (SELECT BedType FROM BedTypes WHErE Id = 3), (SELECT RoomStatus FROM RoomStatus WHErE Id = 1))

INSERT INTO Payments
	   (AccountNumber, FirstDateOccupied, LastDateOccupied, AmountCharged, TaxRate, EmployeeId)
VALUES ((SELECT AccountNumber FROM Customers WHERE Id = 1), CONVERT(DATETIME2, '01/05/2018', 103), CONVERT(DATETIME2, '05/05/2018', 103), 120, 20, 1),
	   ((SELECT AccountNumber FROM Customers WHERE Id = 2), CONVERT(DATETIME2, '03/05/2018', 103), CONVERT(DATETIME2, '08/05/2018', 103), 150, 20, 2),
	   ((SELECT AccountNumber FROM Customers WHERE Id = 1), CONVERT(DATETIME2, '10/05/2018', 103), CONVERT(DATETIME2, '20/05/2018', 103), 300, 20, 3)

INSERT INTO Occupancies
	   (AccountNumber, RoomNumber, EmployeeId)
VALUES ((SELECT AccountNumber FROM Customers WHERE Id = 1), 118, 1),
	   ((SELECT AccountNumber FROM Customers WHERE Id = 2), 230, 1),
	   ((SELECT AccountNumber FROM Customers WHERE Id = 3), 122, 2)


-- 16. Create SoftUni Database

CREATE DATABASE SoftUni

CREATE TABLE Towns (
	Id     INT IDENTITY,
	[Name] VARCHAR(50) NOT NULL

	CONSTRAINT PK_Towns_Id
	PRIMARY KEY(Id)
)

CREATE TABLE Addresses (
	Id			INT IDENTITY,
	AddressText VARCHAR(100) NOT NULL,
	TownId		INT			 NOT NULL

	CONSTRAINT PK_Addresses_Id
	PRIMARY KEY(Id),
	CONSTRAINT FK_Addresses_Towns
	FOREIGN KEY(TownId)
	REFERENCES Towns(Id)
)

CREATE TABLE Departments (
	Id	   INT IDENTITY,
	[Name] VARCHAR(50) NOT NULL

	CONSTRAINT PK_Departments_Id
	PRIMARY KEY(Id)
)

CREATE TABLE Employees (
	Id		     INT IDENTITY,
	FirstName    VARCHAR(50) NOT NULL,
	MiddleName   VARCHAR(50) NOT NULL,
	LastName     VARCHAR(50) NOT NULL,
	JobTitle     VARCHAR(50) NOT NULL,
	HireDate     DATETIME2 DEFAULT(GETDATE()),
	Salary	     DECIMAL(15, 2) NOT NULL,
	DepartmentId INT		 NOT NULL,
	AddressId	 INT
	
	CONSTRAINT PK_Employees_Id
	PRIMARY KEY(Id),
	CONSTRAINT CHK_Salary
	CHECK(Salary > 500),
	CONSTRAINT FK_Employees_Departments
	FOREIGN KEY(DepartmentId)
	REFERENCES Departments(Id),
	CONSTRAINT FK_Employees_Addresses
	FOREIGN KEY(AddressId)
	REFERENCES Addresses(Id)
)


-- 18. Basic Insert

INSERT INTO Towns
VALUES ('Sofia'),
	   ('Plovdiv'),
	   ('Varna'),
	   ('Burgas')

INSERT INTO Departments
VALUES ('Engineering'),
	   ('Sales'),
	   ('Marketing'),
	   ('Software Development'),
	   ('Quality Assurance')
			
INSERT INTO Employees
	   (FirstName, MiddleName, LastName, JobTitle, HireDate, Salary, DepartmentId)
VALUES ('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', CONVERT(DATETIME2, '01/02/2013', 103), 3500.00, 4),
	   ('Petar', 'Petrov', 'Petrov', 'Senior Engineer', CONVERT(DATETIME2, '02/03/2004	',	103), 4000.00, 1),
	   ('Maria', 'Petrova', 'Ivanova', 'Intern', CONVERT(DATETIME2, '28/08/2016', 103), 525.25, 5),
	   ('Georgi', 'Teziev', 'Ivanov', 'CEO', CONVERT(DATETIME2, '09/12/2007', 103), 3000.00, 2),
	   ('Peter', 'Pan', 'Pan', 'Intern', CONVERT(DATETIME2, '28/08/2016', 103), 599.88, 3)


-- 19. Basic Select All Fields

SELECT * FROM Towns

SELECT * FROM Departments

SELECT * FROM Employees


-- 20. Basic Select All Fields and Order Them

SELECT * 
  FROM Towns
 ORDER BY [Name]

SELECT * 
  FROM Departments
 ORDER BY [Name]

SELECT * 
  FROM Employees
 ORDER BY Salary DESC


-- 21. Basic Select Some Fields

SELECT [Name]
  FROM Towns
 ORDER BY [Name]

SELECT [Name]
  FROM Departments
 ORDER BY [Name]

SELECT FirstName,
	   LastName,
	   JobTitle,
	   Salary
  FROM Employees
 ORDER BY Salary DESC


-- 22. Increase Employees Salary

UPDATE Employees
   SET Salary *= 1.1

SELECT Salary
  FROM Employees


-- 23. Decrease Tax Rate

UPDATE Payments
   SET TaxRate -= TaxRate * 0.03

SELECT TaxRate
  FROM Payments


-- 24. Delete All Records

TRUNCATE TABLE Occupancies