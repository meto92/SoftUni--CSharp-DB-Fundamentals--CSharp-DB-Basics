CREATE TABLE Clients (
	ClientId  INT IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName  VARCHAR(50) NOT NULL,
	Phone	  CHAR(12)    NOT NULL,

	CONSTRAINT PK_Clients
	PRIMARY KEY(ClientId)
)

CREATE TABLE Mechanics (
	MechanicId INT IDENTITY,
	FirstName  VARCHAR(50)  NOT NULL, 
	LastName   VARCHAR(50)  NOT NULL,
	[Address]  VARCHAR(255) NOT NULL,

	CONSTRAINT PK_Mechanics
	PRIMARY KEY(MechanicId)
)

CREATE TABLE Models (
	ModelId INT IDENTITY,
	[Name]  VARCHAR(50) NOT NULL,

	CONSTRAINT PK_Models
	PRIMARY KEY(ModelId),

	CONSTRAINT UQ_Models_Name
	UNIQUE([Name])
)

CREATE TABLE Jobs (
	JobId	   INT IDENTITY,
	[Status]   VARCHAR(11) NOT NULL,
	IssueDate  DATE		   NOT	NULL,
	FinishDate DATE,
	ModelId	   INT		   NOT NULL,
	ClientId   INT		   NOT NULL,
	MechanicId INT,

	CONSTRAINT PK_Jobs
	PRIMARY KEY(JobId),

	CONSTRAINT CHK_Jobs_Status
	CHECK ([Status] IN ('Pending', 'In Progress', 'Finished')),

	CONSTRAINT FK_Jobs_Models_ModelId
	FOREIGN KEY(ModelId)
	REFERENCES Models(ModelId),

	CONSTRAINT FK_Jobs_Clients_ClientId
	FOREIGN KEY(ClientId)
	REFERENCES Clients(ClientId),

	CONSTRAINT FK_Jobs_Mechanics_MechanicId
	FOREIGN KEY(MechanicId)
	REFERENCES Mechanics(MechanicId)
)

ALTER TABLE Jobs
ADD CONSTRAINT DF_Jobs_Status
DEFAULT 'Pending'
FOR [Status]

CREATE TABLE Orders (
	OrderId   INT IDENTITY,
	IssueDate DATE,
	Delivered BIT NOT NULL,
	JobId     INT NOT NULL,

	CONSTRAINT PK_Orders
	PRIMARY KEY(OrderId),
	CONSTRAINT FK_Orders_Jobs_JobId
	FOREIGN KEY(JobId)
	REFERENCES Jobs(JobId)
)

ALTER TABLE Orders
ADD CONSTRAINT DF_Orders_Delivered
DEFAULT 0
FOR Delivered

CREATE TABLE Vendors (
	VendorId INT IDENTITY,
	[Name]   VARCHAR(50) NOT NULL,

	CONSTRAINT PK_Vendors
	PRIMARY KEY(VendorId),

	CONSTRAINT UQ_Vendors_Name
	UNIQUE([Name])
)

CREATE TABLE Parts (
	PartId		  INT IDENTITY,
	SerialNumber  VARCHAR(50)   NOT NULL,
	[Description] VARCHAR(255),
	Price		  DECIMAL(6, 2) NOT NULL,
	StockQty	  INT			NOT NULL,
	VendorId      INT			NOT NULL,

	CONSTRAINT PK_Parts
	PRIMARY KEY(PartId),

	CONSTRAINT UQ_Parts_SerialNumber
	UNIQUE(SerialNumber),

	CONSTRAINT CHK_Parts_Price
	CHECK (Price > 0),

	CONSTRAINT CHK_Parts_StockQty
	CHECK (StockQty >= 0),

	CONSTRAINT FK_Parts_Vendors_VendorId
	FOREIGN KEY(VendorId)
	REFERENCES Vendors(VendorId)
)

ALTER TABLE Parts
ADD CONSTRAINT DF_Parts_StockQty
DEFAULT 0
FOR StockQty

CREATE TABLE OrderParts (
	OrderId  INT,
	PartId   INT,
	Quantity INT NOT NULL,

	CONSTRAINT PK_OrderParts
	PRIMARY KEY(OrderId, PartId),
	CONSTRAINT FK_OrderParts_Orders_OrderId
	FOREIGN KEY(OrderId)
	REFERENCES Orders(OrderId),
	CONSTRAINT FK_OrderParts_Parts_PartId
	FOREIGN KEY(PartId)
	REFERENCES Parts(PartId),
	CONSTRAINT CHK_OrderParts_Quantity
	CHECK (Quantity > 0)
)

ALTER TABLE OrderParts
ADD CONSTRAINT DF_OrderParts_Quantity
DEFAULT 1
FOR Quantity

CREATE TABLE PartsNeeded (
	JobId    INT,
	PartId   INT,
	Quantity INT NOT NULL,

	CONSTRAINT PK_PartsNeeded
	PRIMARY KEY(JobId, PartId),

	CONSTRAINT FK_PartsNeeded_Jobs_JobId
	FOREIGN KEY(JobId)
	REFERENCES Jobs(JobId),

	CONSTRAINT FK_PartsNeeded_Parts_PartId
	FOREIGN KEY(PartId)
	REFERENCES Parts(PartId),

	CONSTRAINT CHK_PartsNeeded_Quantity
	CHECK (Quantity > 0)
)

ALTER TABLE PartsNeeded
ADD CONSTRAINT DF_PartsNeeded_Quantity
DEFAULT 1
FOR Quantity