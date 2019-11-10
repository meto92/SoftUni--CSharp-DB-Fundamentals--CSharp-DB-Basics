-- 01. DDL

CREATE TABLE Users (
	Id		   INT IDENTITY,
	Username   NVARCHAR(30) NOT NULL,
	[Password] NVARCHAR(50) NOT NULL,
	[Name]	   NVARCHAR(50),
	Gender	   CHAR,
	BirthDate  DATETIME2,
	Age		   INT,
	Email	   NVARCHAR(50) NOT NULL,

	CONSTRAINT PK_Users
	PRIMARY KEY(Id),

	CONSTRAINT UQ_Username 
	UNIQUE(Username),

	CONSTRAINT CHK_Users_Gender 
	CHECK (Gender IN ('M', 'F')),

	CONSTRAINT CHK_Users_Age 
	CHECK (Age >= 0)
)

CREATE TABLE Departments (
	Id	   INT IDENTITY,
	[Name] NVARCHAR(50) NOT NULL,

	CONSTRAINT PK_Departments
	PRIMARY KEY(Id)
)

CREATE TABLE Employees (
	Id			 INT IDENTITY,
	FirstName	 NVARCHAR(25),
	LastName	 NVARCHAR(25),
	Gender		 CHAR,
	BirthDate	 DATETIME2,
	Age			 INT,
	DepartmentId INT NOT NULL,

	CONSTRAINT PK_Employees
	PRIMARY KEY(Id),

	CONSTRAINT CHK_Employees_Gender 
	CHECK (Gender IN ('M', 'F')),

	CONSTRAINT CHK_Employees_Age
	CHECK (Age >= 0),

	CONSTRAINT FK_Employees_Departments_DepartmentId
	FOREIGN KEY(DepartmentId)
	REFERENCES Departments(Id)
)

CREATE TABLE Categories (
	Id			 INT IDENTITY,
	[Name]		 VARCHAR(50) NOT NULL,
	DepartmentId INt,

	CONSTRAINT PK_Categories
	PRIMARY KEY(Id),
	CONSTRAINT FK_Categories_Departments_DepartmentId
	FOREIGN KEY(DepartmentId)
	REFERENCES Departments(Id)
)

CREATE TABLE [Status] (
	Id	  INT IDENTITY,
	Label VARCHAR(30) NOT NULL,

	CONSTRAINT PK_Status
	PRIMARY KEY(Id)
)

CREATE TABLE Reports (
	Id			  INT IDENTITY,
	OpenDate	  DATETIME2	   NOT NULL,
	CloseDate	  DATETIME2,
	[Description] VARCHAR(200),
	CategoryId	  INT		   NOT NULL,
	StatusId	  INT		   NOT NULL,
	UserId		  INT		   NOT NULL,
	EmployeeId	  INT,
	
	CONSTRAINT PK_Reports
	PRIMARY KEY(Id),

	CONSTRAINT FK_Reports_Categories_CategoryId
	FOREIGN KEY(CategoryId)
	REFERENCES Categories(Id),

	CONSTRAINT FK_Reports_Status_StatusId
	FOREIGN KEY(StatusId)
	REFERENCES Status(Id),

	CONSTRAINT FK_Reports_Users_UserId
	FOREIGN KEY(UserId)
	REFERENCES Users(Id),

	CONSTRAINT FK_Reports_Employees_EmployeeId
	FOREIGN KEY(EmployeeId)
	REFERENCES Employees(Id)
)