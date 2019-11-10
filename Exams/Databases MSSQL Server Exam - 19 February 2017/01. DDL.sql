-- 01. DDL

CREATE TABLE Countries (
	Id	   INT IDENTITY,
	[Name] NVARCHAR(50) NOT NULL,

	CONSTRAINT PK_Countries
	PRIMARY KEY(Id),

	CONSTRAINT UQ_Countries_Name
	UNIQUE([Name])
)

CREATE TABLE Customers (
	Id		    INT IDENTITY,
	FirstName   NVARCHAR(25) NOT NULL,
	LastName    NVARCHAR(25) NOT NULL,
	Gender	    CHAR		 NOT NULL,
	Age		    INT			 NOT NULL,
	PhoneNumber CHAR(10)	 NOT NULL,
	CountryId   INT			 NOT NULL,

	CONSTRAINT PK_Customers
	PRIMARY KEY(Id),

	CONSTRAINT CHK_Customers_Gender
	CHECK(Gender IN ('M', 'F')),

	CONSTRAINT CHK_Customers_Age
	CHECK(Age >= 0),

	CONSTRAINT FK_Customers_Countries_CountryId
	FOREIGN KEY(CountryId)
	REFERENCES Countries(Id)
)

CREATE TABLE Products (
	Id			  INT IDENTITY,
	[Name]		  NVARCHAR(25)  NOT NULL,
	[Description] NVARCHAR(250) NOT NULL,
	Recipe		  NVARCHAR(MAX) NOT NULL,
	Price		  MONEY NOT NULL,

	CONSTRAINT PK_Products
	PRIMARY KEY(Id),

	CONSTRAINT UQ_Products_Name
	UNIQUE([Name]),

	CONSTRAINT CHK_Products_Price
	CHECK(Price >= 0)
)

CREATE TABLE Feedbacks (
	Id			  INT IDENTITY,
	[Description] NVARCHAR(255)  NOT NULL,
	Rate		  DECIMAL(4, 2)  NOT NULL,
	ProductId	  INT			 NOT NULL,
	CustomerId	  INT			 NOT NULL,

	CONSTRAINT PK_Feedbacks
	PRIMARY KEY(Id),

	CONSTRAINT CHK_Feedbacks_Rate
	CHECK(Rate BETWEEN 0 AND 10),

	CONSTRAINT FK_Feedbacks_Products_ProductId
	FOREIGN KEY(ProductId)
	REFERENCES Products(Id),

	CONSTRAINT FK_Feedbacks_Customers_CustomerId
	FOREIGN KEY(CustomerId)
	REFERENCES Customers(Id)
)

CREATE TABLE Distributors (
	Id			INT IDENTITY,
	[Name]		NVARCHAR(25) NOT NULL,
	AddressText NVARCHAR(30),
	Summary		NVARCHAR(200),
	CountryId   INT			 NOT NULL,

	CONSTRAINT PK_Distributors
	PRIMARY KEY(Id),

	CONSTRAINT UQ_Distributors_Name
	UNIQUE([Name]),

	CONSTRAINT FK_Distributors_Countries_CountryId
	FOREIGN KEY(CountryId)
	REFERENCES Countries(Id)
)

CREATE TABLE Ingredients (
	Id			    INT IDENTITY,
	[Name]		    NVARCHAR(30)  NOT NULL,
	[Description]   NVARCHAR(200) NOT NULL,
	OriginCountryId	INT			  NOT NULL,
	DistributorId   INT			  NOT NULL,

	CONSTRAINT PK_Ingredients
	PRIMARY KEY(Id),

	CONSTRAINT FK_Ingredients_Countries_OriginCountryId
	FOREIGN KEY(OriginCountryId)
	REFERENCES Countries(Id),

	CONSTRAINT FK_Ingredients_Distributors_DistributorId
	FOREIGN KEY(DistributorId)
	REFERENCES Distributors(Id)
)

CREATE TABLE ProductsIngredients (
	ProductId    INT,
	IngredientId INT,

	CONSTRAINT PK_ProductsIngredients
	PRIMARY KEY(ProductId, IngredientId),

	CONSTRAINT FK_ProductsIngredients_Products_ProductId
	FOREIGN KEY(ProductId)
	REFERENCES Products(Id),

	CONSTRAINT FK_ProductsIngredients_Ingredients_IngredientId
	FOREIGN KEY(IngredientId)
	REFERENCES Ingredients(Id)
)