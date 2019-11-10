CREATE TABLE Clients (
	Id			 INT IDENTITY,
	FirstName    NVARCHAR(30) NOT NULL,
	LastName	 NVARCHAR(30) NOT NULL,
	Gender	     CHAR,
	BirthDate    DATETIME,
	CreditCard   NVARCHAR(30) NOT NULL,
	CardValidity DATETIME,
	Email		 NVARCHAR(50) NOT NULL

	CONSTRAINT PK_Clients
	PRIMARY KEY(Id),

	CONSTRAINT CHK_Gender
	CHECK (Gender IN ('M', 'F'))
)

CREATE TABLE Towns (
	Id INT IDENTITY,
	[Name] NVARCHAR(50) NOT NULL

	CONSTRAINT PK_Towns
	PRIMARY KEY(Id)
)

CREATE TABLE Offices (
	Id INT IDENTITY,
	[Name] NVARCHAR(40) NOT NULL,
	ParkingPlaces INT,
	TownId INT NOT NULL

	CONSTRAINT PK_Offices
	PRIMARY KEY(Id),

	CONSTRAINT FK_Offices_Towns_TownId
	FOREIGN KEY(TownId)
	REFERENCES Towns(Id)
)

CREATE TABLE Models (
	Id INT IDENTITY,
	Manufacturer   NVARCHAR(50) NOT NULL,
	Model		   NVARCHAR(50) NOT NULL,
	ProductionYear DATETIME,
	Seats		   INT,
	Class		   NVARCHAR(10),
	Consumption    DECIMAL(14, 2)

	CONSTRAINT PK_Models
	PRIMARY KEY(Id)
)

CREATE TABLE Vehicles (
	Id		 INT IDENTITY,
	Mileage  INT,
	ModelId  INT NOT NULL,
	OfficeId INT NOT NULL

	CONSTRAINT PK_Vehicles
	PRIMARY KEY(Id),

	CONSTRAINT FK_Vehicles_Models_ModelId
	FOREIGN KEY(ModelId)
	REFERENCES Models(Id),

	CONSTRAINT FK_Vehicles_Offices_OfficeId
	FOREIGN KEY(OfficeId)
	REFERENCES Offices(Id)
)

CREATE TABLE Orders (
	Id			       INT IDENTITY,
	CollectionDate     DATETIME		  NOT NULL,
	ReturnDate		   DATETIME,
	Bill			   DECIMAL(14, 2),
	TotalMileage	   INT,
	ClientId		   INT		      NOT NULL,
	TownId			   INT			  NOT NULL,
	VehicleId		   INT			  NOT NULL,
	CollectionOfficeId INT			  NOT NULL,
	ReturnOfficeId     INT

	CONSTRAINT PK_Orders
	PRIMARY KEY(Id),

	CONSTRAINT FK_Orders_Clients_ClientId
	FOREIGN KEY(ClientId)
	REFERENCES Clients(Id),

	CONSTRAINT FK_Orders_Towns_TownId
	FOREIGN KEY(TownId)
	REFERENCES Towns(Id),

	CONSTRAINT FK_Orders_Vehicles_VehicleId
	FOREIGN KEY(VehicleId)
	REFERENCES Vehicles(Id),

	CONSTRAINT FK_Orders_Offices_CollectionOfficeId
	FOREIGN KEY(CollectionOfficeId)
	REFERENCES Offices(Id),

	CONSTRAINT FK_Orders_Offices_ReturnOfficeId
	FOREIGN KEY(ReturnOfficeId)
	REFERENCES Offices(Id)
)