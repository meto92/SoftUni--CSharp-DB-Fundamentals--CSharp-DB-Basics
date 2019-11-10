-- 01. One-To-One Relationship

CREATE TABLE Persons (
	PersonID   INT IDENTITY,
	FirstName  NVARCHAR(50)   NOT NULL,
	Salary     DECIMAL(15, 2) NOT NULL,
	PassportID INT NOT NULL	
)

CREATE TABLE Passports (
	PassportID     INT IDENTITY(101, 1),
	PassportNumber CHAR(8)

	CONSTRAINT PK_Passports_PassportID 
	PRIMARY KEY(PassportID)
)
		
INSERT INTO Persons
VALUES ('Roberto', 43300, 102),
	   ('Tom', 56100, 103),
	   ('Yana', 60200, 101)

INSERT INTO Passports
VALUES ('N34FG21B'),
	   ('K65LO4R7'),
	   ('ZE657QP2')
	   
ALTER TABLE Persons
ADD CONSTRAINT PK_Persons_PersonID 
PRIMARY KEY(PersonID)

ALTER TABLE Persons
ADD CONSTRAINT FK_Persons_Passports_PassportID
FOREIGN KEY (PassportID) 
REFERENCES Passports(PassportID)

ALTER TABLE Persons
ADD CONSTRAINT UQ_PassportID 
UNIQUE(PassportID)


-- 02. One-To-Many Relationship

CREATE TABLE Manufacturers (
	ManufacturerID INT IDENTITY,
	[Name]		   NVARCHAR(50) NOT NULL,
	EstablishedOn  DATETIME2    NOT NULL,

	CONSTRAINT PK_Manufacturers_ManufacturerID 
	PRIMARY KEY(ManufacturerID)
)

CREATE TABLE Models (
	ModelID		   INT IDENTITY(101, 1),
	[Name]		   NVARCHAR(50) NOT NULL,
	ManufacturerID INT

	CONSTRAINT PK_Models_ModelID 
	PRIMARY KEY(ModelID),
	CONSTRAINT FK_Models_Manufacturers_ManufacturerID
	FOREIGN KEY(ManufacturerID) 
	REFERENCES Manufacturers(ManufacturerID)
)

INSERT INTO Manufacturers
VALUES ('BMW', '07/03/1916'),
	   ('Tesla', '01/01/2003'),
	   ('Lada', '01/05/1966')

INSERT INTO Models
VALUES ('X1', 1),	   
	   ('i6', 1),
	   ('Model S', 2),
	   ('Model X', 2),
	   ('Model 3', 2),
	   ('Nova', 3)


-- 03. Many-To-Many Relationship

CREATE TABLE Students (
	StudentID INT IDENTITY,
	[Name]    NVARCHAR(50)

	CONSTRAINT PK_Students_StudentID
	PRIMARY KEY(StudentID)
)

CREATE TABLE Exams (
	ExamID INT IDENTITY(101, 1),
	[Name] NVARCHAR(50)

	CONSTRAINT PK_Exams_ExamID
	PRIMARY KEY(ExamID)
)

CREATE TABLE StudentsExams (
	StudentID INT NOT NULL,
	ExamID    INT NOT NULL

	CONSTRAINT PK_StudentsExams
	PRIMARY KEY(StudentID, ExamID),
	CONSTRAINT FK_StudentsExams_Students_StudentID 
	FOREIGN KEY(StudentID)
	REFERENCES Students(StudentID),
	CONSTRAINT FK_StudentsExams_Exams_ExamID
	FOREIGN KEY(ExamID)
	REFERENCES Exams(ExamID)
)

INSERT INTO Students
VALUES ('Mila'),
	   ('Toni'),
	   ('Ron')
	   
INSERT INTO Exams
VALUES ('SpringMVC'),
	   ('Neo4j'),
	   ('Oracle 11g')

INSERT INTO StudentsExams
VALUES (1, 101),
	   (1, 102),
	   (2, 101),
	   (3, 103),
	   (2, 102),
	   (2, 103)


-- 04. Self-Referencing 

CREATE TABLE Teachers (
	TeacherID INT IDENTITY(101, 1),
	[Name]    NVARCHAR(50) NOT NULL,
	ManagerID INT

	CONSTRAINT PK_Teachers_TeacherID
	PRIMARY KEY(TeacherID),
	CONSTRAINT FK_Teachers_Teachers_ManagerID
	FOREIGN KEY(ManagerID)
	REFERENCES Teachers(TeacherID)
)

INSERT INTO Teachers
VALUES ('John', NULL),
	   ('Maya', 106),
	   ('Silvia', 106),
	   ('Ted', 105),
	   ('Mark', 101),
	   ('Greta', 101)


-- 05. Online Store Database

--CREATE DATABASE OnlineStore

--USE OnlineStore

CREATE TABLE Cities (
	CityID INT IDENTITY,
	[Name] VARCHAR(50) NOT NULL

	CONSTRAINT PK_Cities_CityID
	PRImARY KEY(CityID)
)

CREATE TABLE Customers (
	CustomerID INT IDENTITY,
	[Name]	   VARCHAR(50) NOT NULL,
	Birthday   DATE		   NOT NULL,
	CityID     INT

	CONSTRAINT PK_Customers_CustomerID
	PRImARY KEY(CustomerID),
	CONSTRAINT FK_Customers_Cities_CityID
	FOREIGN KEY(CityID)
	REFERENCES Cities(CityID)
)

CREATE TABLE Orders (
	OrderID	   INT IDENTITY,
	CustomerID INT

	CONSTRAINT PK_Orders_OrderID
	PRImARY KEY(OrderID),
	CONSTRAINT FK_Orders_Customers_CustomerID
	FOREIGN KEY(CustomerID)
	REFERENCES Customers(CustomerID)
)

CREATE TABLE ItemTypes (
	ItemTypeID INT IDENTITY,
	[Name]	   VARCHAR(50) NOT NULL

	CONSTRAINT PK_ItemTypes_ItemTypeID
	PRImARY KEY(ItemTypeID)
)

CREATE TABLE Items (
	ItemID	   INT IDENTITY,
	[Name]	   VARCHAR(50) NOT NULL,
	ItemTypeID INT

	CONSTRAINT PK_Items_ItemID
	PRImARY KEY(ItemID),
	CONSTRAINT FK_Items_ItemTypes_ItemTypeID
	FOREIGN KEY(ItemTypeID)
	REFERENCES ItemTypes(ItemTypeID)
)

CREATE TABLE OrderItems (
	OrderID INT NOT NULL,
	ItemID  INT NOT NULL

	CONSTRAINT PK_OrderItems
	PRIMARY KEY(OrderID, ItemID),
	CONSTRAINT FK_OrderItems_Orders_OrderID
	FOREIGN KEY(OrderID)
	REFERENCES Orders(OrderID),
	CONSTRAINT FK_OrderItems_Items_ItemID
	FOREIGN KEY(ItemID)
	REFERENCES Items(ItemID)
)


-- 06. University Database

-- CREATE DATABASE University
--COLLATE Cyrillic_General_100_CI_AI

--USE University

CREATE TABLE Majors (
	MajorID INT IDENTITY,
	[Name]	NVARCHAR(50) NOT NULL

	CONSTRAINT PK_Majors_MajorID
	PRIMARY KEY(MajorID)
)

CREATE TABLE Subjects (
	SubjectID   INT IDENTITY,
	SubjectName	NVARCHAR(50) NOT NULL

	CONSTRAINT PK_Subjects_SubjectID
	PRIMARY KEY(SubjectID)
)

CREATE TABLE Students (
	StudentID	  INT IDENTITY,
	StudentNumber CHAR(11) NOT NULL,
	StudentName	  NVARCHAR(50) NOT NULL,
	MajorID		  INT

	CONSTRAINT PK_Students_StudentID
	PRIMARY KEY(StudentID),
	CONSTRAINT FK_Students_Majors_MajorID
	FOREIGN KEY(MajorID)
	REFERENCES Majors(MajorID)
)

CREATE TABLE Agenda (
	StudentID INT NOT NULL,
	SubjectID INT NOT NULL

	CONSTRAINT PK_Agenda
	PRIMARY KEY(StudentID, SubjectID),
	CONSTRAINT FK_Agenda_Students_StudentID
	FOREIGN KEY(StudentID)
	REFERENCES Students(StudentID),
	CONSTRAINT FK_Agenda_Subjects_SubjectID
	FOREIGN KEY(SubjectID)
	REFERENCES Subjects(SubjectID)
)

CREATE TABLE Payments (
	PaymentID	  INT IDENTITY,
	PaymentDate   DATETIME DEFAULT(GETDATE()),
	PaymentAmount DECIMAL(15, 2) NOT NULL,
	StudentID     INT			 NOT NULL

	CONSTRAINT PK_Payments_PaymentID
	PRIMARY KEY(PaymentID),
	CONSTRAINT FK_Payments_Students_StudentID
	FOREIGN KEY(StudentID)
	REFERENCES Students(StudentID)
)


-- 09. Peaks in Rila

SELECT m.MountainRange,
	   p.PeakName,
	   p.Elevation
  FROM Peaks AS p
	   INNER JOIN Mountains AS m
	   ON m.Id = p.MountainId
 WHERE m.Id =
	   (SELECT Id 
	      FROM Mountains
		 WHERE MountainRange = 'Rila'
	   )
 ORDER BY p.Elevation DESC