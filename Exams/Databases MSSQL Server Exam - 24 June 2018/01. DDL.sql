-CREATE TABLE Cities (
	Id		    INT IDENTITY,
	[Name]	    NVARCHAR(20) NOT NULL,
	CountryCode CHAR(2)		 NOT NULL,

	CONSTRAINT PK_Cities
	PRIMARY KEY(Id)
)

CREATE TABLE Hotels (
	Id			  INT IDENTITY,
	[Name]		  NVARCHAR(30)  NOT NULL,
	EmployeeCount INT		    NOT NULL,
	BaseRate	  DECIMAL(15, 2),
	CityId 	      INT		    NOT NULL,

	CONSTRAINT PK_Hotels
	PRIMARY KEY(Id),

	--CONSTRAINT CHK_Hotels_EmployeeCount
	--CHECK (EmployeeCount >= 0),

	CONSTRAINT FK_Hotels_Cities_CityId
	FOREIGN KEY(CityId)
	REFERENCES Cities(Id)
)

CREATE TABLE Rooms (
	Id      INT IDENTITY,
	Price   DECIMAL(15, 2) NOT NULL,
	[Type]  NVARCHAR(20)   NOT NULL,
	Beds    INT			   NOT NULL,
	HotelId INT			   NOT NULL,

	CONSTRAINT PK_Rooms
	PRIMARY KEY(Id),

	--CONSTRAINT CHK_Rooms_Price
	--CHECK (Price >= 0),

	--CONSTRAINT CHK_Rooms_Beds
	--CHECK (Beds >= 0),

	CONSTRAINT FK_Rooms_Hotels_HotelId
	FOREIGN KEY(HotelId)
	REFERENCES Hotels(Id)
)

CREATE TABLE Trips (
	Id		    INT IDENTITY,
	BookDate    DATE NOT NULL,
	ArrivalDate DATE NOT NULL,
	ReturnDate  DATE NOT NULL,
	CancelDate  DATE,
	RoomId	    INT  NOT NULL,

	CONSTRAINT PK_Trips
	PRIMARY KEY(Id),

	CONSTRAINT CHK_Trips_BookDate
	CHECK (BookDate < ArrivalDate),

	CONSTRAINT CHK_Trips_ArrivalDate
	CHECK (ArrivalDate < ReturnDate),
	
	--CONSTRAINT CHK_Trips_CancelDate
	--CHECK (CancelDate < BookDate),

	CONSTRAINT FK_Trips_Rooms_RoomId
	FOREIGN KEY(RoomId)
	REFERENCES Rooms(Id)
)

CREATE TABLE Accounts (
	Id		   INT IDENTITY,
	FirstName  NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(20),
	LastName   NVARCHAR(50) NOT NULL,
	BirthDate  DATE		    NOT NULL,
	Email	   VARCHAR(100) NOT NULL,
	CityId	   INT		    NOT NULL,

	CONSTRAINT PK_Accounts
	PRIMARY KEY(Id),

	CONSTRAINT UQ_Accounts_Email
	UNIQUE(Email),

	CONSTRAINT FK_Accounts_Cities_CityId
	FOREIGN KEY(CityId)
	REFERENCES Cities(Id)
)

CREATE TABLE AccountsTrips (
	AccountId INT NOT NULL,
	TripId    INT NOT NULL,
	Luggage   INT NOT NULL,

	CONSTRAINT PK_AccountsTrips
	PRIMARY KEY(AccountId, TripId),

	CONSTRAINT FK_AccountsTrips_Accounts_AccountId
	FOREIGN KEY(AccountId)
	REFERENCES Accounts(Id),

	CONSTRAINT FK_AccountsTrips_Trips_TripId
	FOREIGN KEY(TripId)
	REFERENCES Trips(Id),

	CONSTRAINT CHK_AccountsTrips_Luggage
	CHECK (Luggage >= 0)
)