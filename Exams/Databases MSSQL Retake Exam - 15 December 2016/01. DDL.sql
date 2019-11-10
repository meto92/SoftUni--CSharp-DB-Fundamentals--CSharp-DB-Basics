-- 01. DDL

CREATE TABLE Locations (
	Id		  INT IDENTITY,
	Latitude  FLOAT NOT NULL,
	Longitude FLOAT NOT NULL,

	CONSTRAINT PK_Locations
	PRIMARY KEY(Id)
)

CREATE TABLE [Credentials] (
	Id		   INT IDENTITY,
	Email	   VARCHAR(30) NOT NULL,
	[Password] VARCHAR(20) NOT NULL,

	CONSTRAINT PK_Credentials
	PRIMARY KEY(Id)
) 

CREATE TABLE Users (
	Id			  INT IDENTITY,
	Nickname	  VARCHAR(25) NOT NULL,
	Gender		  CHAR		  NOT NULL,
	Age			  INT		  NOT NULL,
	LocationId	  INT,
	CredentialId  INT		  NOT NULL,

	CONSTRAINT PK_Users
	PRIMARY KEY(Id),

	CONSTRAINT CHK_Users_Age
	CHECK(Age >= 0),

	CONSTRAINT FK_Users_Locations_LocationId
	FOREIGN KEY(LocationId)
	REFERENCES Locations(Id),
	
	CONSTRAINT FK_Users_Credentials_CredentialId
	FOREIGN KEY(CredentialId)
	REFERENCES [Credentials](Id),

	CONSTRAINT UQ_Users_CredentialId
	UNIQUE(CredentialId)
)

CREATE TABLE Chats (
	Id        INT IDENTITY,
	Title     VARCHAR(32) NOT NULL,
	StartDate DATE		  NOT NULL,
	IsActive  BIT		  NOT NULL,

	CONSTRAINT PK_Chats
	PRIMARY KEY(Id)
)

CREATE TABLE [Messages] (
	Id      INT IDENTITY,
	Content VARCHAR(200) NOT NULL,
	SentOn  DATE		 NOT NULL,
	ChatId  INT			 NOT NULL,
	UserId  INT			 NOT NULL,

	CONSTRAINT PK_Messages
	PRIMARY KEY(Id),

	CONSTRAINT FK_Messages_Chats_ChatId
	FOREIGN KEY(ChatId)
	REFERENCES Chats(Id),

	CONSTRAINT FK_Messages_Users_UserId
	FOREIGN KEY(UserId)
	REFERENCES Users(Id)
)

CREATE TABLE UsersChats (
	ChatId INT,
	UserId INT,

	CONSTRAINT PK_UsersChats
	PRIMARY KEY(ChatId, UserId),

	CONSTRAINT FK_UsersChats_Chats_ChatId
	FOREIGN KEY(ChatId)
	REFERENCES Chats(Id),
	
	CONSTRAINT FK_UsersChats_Users_UserId
	FOREIGN KEY(UserId)
	REFERENCES Users(Id)
)