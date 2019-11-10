-- 01. Number of Users for Email Provider

SELECT [Email Provider],
	   [Number Of Users] = 
	   (SELECT COUNT(*)
	      FROM Users
		 WHERE Email LIKE '%' + [Email Provider])
  FROM (SELECT DISTINCT SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email) - CHARINDEX('@', Email)) AS [Email Provider]
		  FROM Users) AS t
 ORDER BY [Number Of Users] DESC,
	   [Email Provider]


-- 02. All User in Games

SELECT g.[Name] AS Game,
	   gt.[Name] AS [Game Type],
	   u.Username,
	   ug.[Level],
	   ug.Cash,
	   c.[Name] AS [Character]
  FROM Games AS g
	   JOIN GameTypes AS gt
	   ON gt.Id = g.GameTypeId
	   JOIN UsersGames AS ug
	   ON ug.GameId = g.Id
	   JOIN Users AS u
	   ON u.Id = ug.UserId
	   JOIN Characters AS c
	   ON c.Id = ug.CharacterId
 ORDER BY ug.[Level] DESC,
	   u.Username,
	   g.[Name]


-- 03. Users in Games with Their Items

SELECT u.Username,
	   g.[Name] AS Game,
	   COUNT(i.Id) AS [Items Count],
	   SUM(i.Price) AS [Items Price]
  FROM Users AS u
	   JOIN UsersGames AS ug
	   ON ug.UserId = u.Id
	   JOIN Games AS g
	   ON g.Id = ug.GameId
	   JOIN UserGameItems AS ugi
	   ON ugi.UserGameId = ug.Id
	   JOIN Items AS i
	   ON i.Id = ugi.ItemId
 GROUP BY u.Username,
	   g.[Name]
HAVING COUNT(i.Id) >= 10
 ORDER BY [Items Count] DESC,
	   [Items Price] DESC,
	   u.Username


-- 04. User in Games with Their Statistics

SELECT u.Username,
	   g.[Name] AS Game,
	   [Character] = MAX(c.[Name]),
	   Strength = SUM([is].Strength) + MAX(gts.Strength) + MAX(cs.Strength),
	   Defence = SUM([is].Defence) + MAX(gts.Defence) + MAX(cs.Defence),
	   Speed = SUM([is].Speed) + MAX(gts.Speed) + MAX(cs.Speed),
	   Mind = SUM([is].Mind) + MAX(gts.Mind) + MAX(cs.Mind),
	   Luck = SUM([is].Luck) + MAX(gts.Luck) + MAX(cs.Luck)
  FROM Users AS u
	   JOIN UsersGames AS ug
	   ON ug.UserId = u.Id
	   JOIN Games AS g
	   ON g.Id = ug.GameId
	   JOIN GameTypes AS gt
	   ON gt.Id = g.GameTypeId
	   JOIN UserGameItems AS ugi
	   ON ugi.UserGameId = ug.Id
	   JOIN Characters AS c
	   ON c.Id = ug.CharacterId
	   JOIN Items AS i
	   ON i.Id = ugi.ItemId
	   JOIN [Statistics] AS [is]
	   ON [is].Id = i.StatisticId
	   JOIN [Statistics] AS gts
	   ON gts.Id = gt.BonusStatsId
	   JOIN [Statistics] AS cs
	   ON cs.Id = c.StatisticId
 GROUP BY u.Username,
	   g.[Name]
 ORDER BY Strength DESC,
	   Defence DESC,
	   Speed DESC,
	   Mind DESC,
	   Luck DESC


-- 05. All Items with Greater than Average Statistics

DECLARE @AverageValues AS TABLE (
	AverageSpeed FLOAT,
	AverageMind FLOAT,
	AverageLuck FLOAT
)

INSERT INTO @AverageValues
SELECT AVG(CAST(Speed AS FLOAT)) AS AvgSpeed ,
	   AVG(CAST(Mind AS FLOAT)) AS AvgMind,
	   AVG(CAST(Luck AS FLOAT)) AS AvgLuck
  FROM [Statistics] AS s 
	   JOIN Items AS i 
	   ON i.StatisticId = s.Id

SELECT i.[Name],
	   i.Price,
	   i.MinLevel,
	   s.Strength,
	   s.Defence,
	   s.Speed,
	   s.Luck,
	   s.Mind
  FROM Items AS i
	   JOIN [Statistics] AS s
	   ON s.Id = i.StatisticId
 WHERE s.Speed > (SELECT AverageSpeed FROM @AverageValues)
   AND s.Mind > (SELECT AverageMind FROM @AverageValues)
   AND s.Luck > (SELECT AverageLuck FROM @AverageValues)
 ORDER BY [Name]


-- 06. Display All Items with Information about Forbidden Game Type

SELECT i.[Name] AS Item,
	   i.Price,
	   i.MinLevel,
	   gt.[Name] AS [Forbidden Game Type]
  FROM Items AS i
	   LEFT OUTER JOIN GameTypeForbiddenItems AS gtfi
	   ON gtfi.ItemId = i.Id
	   LEFT OUTER JOIN GameTypes AS gt
	   ON gt.Id = gtfi.GameTypeId
 ORDER BY gt.[Name] DESC,
	   i.[Name]


-- 07. Buy Items for User in Game

DECLARE @userGameId INT = 
	    (SELECT Id 
		   FROM UsersGames 
		  WHERE UserId =
			    (SELECT Id 
				  FROM Users 
				 WHERE Username = 'Alex')
			AND GameId = 
				(SELECT Id 
				   FROM Games 
				  WHERE [Name] = 'Edinburgh')
		)

DECLARE @level INT =
		(SELECT [Level]
		   FROM UsersGames
		  WHERE Id = @userGameId)

DECLARE @items AS TABLE (
	Id INT,
	Price DECIMAL(15, 2),
	MinLevel INT
)

INSERT INTO @items
SELECT Id,
	   Price,
	   MinLevel
  FROM Items 
 WHERE [Name] IN ('Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)', 'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet')

DECLARE @itemId INT
DECLARE @itemPrice DECIMAL(15, 2)
DECLARE @itemMinLevel INT
DECLARE @itemsCursor CURSOR

BEGIN
	SET @itemsCursor = CURSOR FOR
	SELECT * FROM @items

	OPEN @itemsCursor
    FETCH NEXT FROM @itemsCursor
    INTO @itemId, @itemPrice, @itemMinLevel

	WHILE @@FETCH_STATUS = 0
    BEGIN
		DECLARE @cash DECIMAL(15, 2) =
				(SELECT Cash 
				   FROM UsersGames 
				  WHERE Id = @userGameId)

		--IF (@level >= @itemMinLevel AND @cash >= @itemPrice)
		IF (@cash >= @itemPrice)
		BEGIN
			UPDATE UsersGames
			   SET Cash -= @itemPrice
			 WHERE Id = @userGameId

			INSERT INTO UserGameItems
				   (ItemId, UserGameId)
			VALUES (@itemId, @userGameId)
		END

		FETCH NEXT FROM @itemsCursor
		INTO @itemId, @itemPrice, @itemMinLevel
    END

    CLOSE @itemsCursor
    DEALLOCATE @itemsCursor
END

SELECT u.Username,
	   g.[Name],
	   ug.Cash,
	   i.[Name] AS [Item Name]
  FROM Users AS u
	   JOIN UsersGames AS ug
	   ON ug.UserId = u.Id
	   JOIN Games AS g
	   ON g.Id = ug.GameId
	   JOIN UserGameItems AS ugi
	   ON ugi.UserGameId = ug.Id
	   JOIN Items AS i
	   ON i.Id = ugi.ItemId
 WHERE g.[Name] = 'Edinburgh'
 ORDER BY [Item Name]


-- 08. Peaks and Mountains

SELECT p.PeakName,
	   m.MountainRange AS Mountain,
	   p.Elevation
  FROM Peaks AS p
	   JOIN Mountains AS m
	   ON m.Id = p.MountainId
 ORDER BY p.Elevation DESC,
	   p.PeakName


-- 09. Peaks with Their Mountain, Country and Continent

SELECT p.PeakName,
	   m.MountainRange AS Mountain,
	   countr.CountryName,
	   cont.ContinentName
  FROM Peaks AS p
	   JOIN Mountains AS m
	   ON m.Id = p.MountainId
	   JOIN MountainsCountries AS mc
	   ON mc.MountainId = m.Id
	   JOIN Countries AS countr
	   ON countr.CountryCode = mc.CountryCode
	   JOIN Continents AS cont
	   ON cont.ContinentCode = countr.ContinentCode
 ORDER BY p.PeakName,
	   countr.CountryName  


-- 10. Rivers by Country

SELECT countr.CountryName,
	   cont.ContinentName,
	   RiversCount = COUNT(r.Id),
	   TotalLength = ISNULL(SUM(r.[Length]), 0)
  FROM Countries AS countr
	   JOIN Continents AS cont
	   ON cont.ContinentCode = countr.ContinentCode
	   LEFT OUTER JOIN CountriesRivers AS cr
	   ON cr.CountryCode = countr.CountryCode
	   LEFT OUTER JOIN Rivers AS r
	   ON r.Id = cr.RiverId
 GROUP BY countr.CountryName,
	   cont.ContinentName
 ORDER BY RiversCount DESC,
	   TotalLength DESC,
	   countr.CountryName


-- 11. Count of Countries by Currency

SELECT c.CurrencyCode,
	   c.[Description] AS Currency,
	   NumberOfCountries =
	   (SELECT COUNT(*)
	      FROM Countries
		 WHERE CurrencyCode = c.CurrencyCode)
  FROM Currencies AS c
 ORDER BY NumberOfCountries DESC,
	   Currency


-- 12. Population and Area by Continent

SELECT cont.ContinentName,
	   CountriesArea = SUM(countr.AreaInSqKm),
	   CountriesPopulation = SUM(CAST(countr.[Population] AS BIGINT))
  FROM Continents AS cont
	   JOIN Countries AS countr
	   ON countr.ContinentCode = cont.ContinentCode
 GROUP BY cont.ContinentName
 ORDER BY CountriesPopulation DESC
	   

-- 13. Monasteries by Country

CREATE TABLE Monasteries (
	Id INT IDENTITY,
	[Name] NVARCHAR(50),
	CountryCode CHAR(2),

	CONSTRAINT PK_Monasteries_Id
	PRIMARY KEY(Id),
	CONSTRAINT FK_Monasteries_Countries_CountryCode
	FOREIGN KEY(CountryCode)
	REFERENCES Countries(CountryCode)
)

INSERT INTO Monasteries
	   ([Name], CountryCode) 
VALUES ('Rila Monastery “St. Ivan of Rila”', 'BG'), 
	   ('Bachkovo Monastery “Virgin Mary”', 'BG'),
	   ('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
	   ('Kopan Monastery', 'NP'),
	   ('Thrangu Tashi Yangtse Monastery', 'NP'),
	   ('Shechen Tennyi Dargyeling Monastery', 'NP'),
	   ('Benchen Monastery', 'NP'),
	   ('Southern Shaolin Monastery', 'CN'),
	   ('Dabei Monastery', 'CN'),
	   ('Wa Sau Toi', 'CN'),
	   ('Lhunshigyia Monastery', 'CN'),
	   ('Rakya Monastery', 'CN'),
	   ('Monasteries of Meteora', 'GR'),
	   ('The Holy Monastery of Stavronikita', 'GR'),
	   ('Taung Kalat Monastery', 'MM'),
	   ('Pa-Auk Forest Monastery', 'MM'),
	   ('Taktsang Palphug Monastery', 'BT'),
	   ('Sümela Monastery', 'TR')

--ALTER TABLE Countries
--ADD IsDeleted BIT

--ALTER TABLE Countries
--ADD CONSTRAINT DF_Countries_IsDeleted 
--DEFAULT 0
--FOR IsDeleted

--UPDATE Countries
--   SET IsDeleted = 0

UPDATE Countries
   SET IsDeleted = 1
 WHERE (SELECT COUNT(cr.RiverId)
	      FROM CountriesRivers AS cr
		 WHERE cr.CountryCode = Countries.CountryCode) > 3

SELECT m.[Name] AS Monastery,
	   c.CountryName AS Country
  FROM Monasteries AS m
	   JOIN Countries AS c
	   ON c.CountryCode = m.CountryCode
 WHERE c.IsDeleted = 0
 ORDER BY Monastery


-- 14. Monasteries by Continents and Countries

UPDATE Countries
   SET CountryName = 'Burma'
 WHERE CountryName = 'Myanmar'

INSERT INTO Monasteries
	   ([Name], CountryCode)
VALUES ('Hanga Abbey', (SELECT CountryCode FROM Countries WHERE CountryName = 'Tanzania')),
	   ('Myin-Tin-Daik', (SELECT CountryCode FROM Countries WHERE CountryName = 'Myanmar'))

SELECT cont.ContinentName,
	   countr.CountryName,
	   MonasteriesCount = COUNT(m.Id)
  FROM Continents AS cont
	   JOIN Countries AS countr
	   ON countr.ContinentCode = cont.ContinentCode
	   LEFT OUTER JOIN Monasteries AS m
	   ON m.CountryCode = countr.CountryCode
 WHERE countr.IsDeleted = 0
 GROUP BY cont.ContinentName,
	   countr.CountryName
 ORDER BY MonasteriesCount DESC,
	   countr.CountryName