-- 05. Bulgarian Cities

SELECT Id,
	   [Name]
  FROM Cities
 WHERE CountryCode = 'BG'
 ORDER BY [Name]

-- 06. People Born After 1991

SELECT CONCAT(FirstName, ' ', ISNULL(MiddleName + ' ', ''), LastName) AS [Full Name],
	   YEAR(BirthDate) AS BirthYear
  FROM Accounts
 WHERE YEAR(BirthDate) > 1991
 ORDER BY BirthYear DESC,
	   FirstName


-- 07. EEE-Mails

SELECT a.FirstName,
	   a.LastName,
	   FORMAT(a.BirthDate, 'MM-dd-yyyy'),
	   c.[Name] AS Hometown,
	   a.Email
  FROM Accounts AS a
	   JOIN Cities AS c
	   ON c.Id = a.CityId
 WHERE a.Email LIKE 'e%'
 ORDER BY c.[Name] DESC


-- 08. City Statistics

SELECT c.[Name] AS City,
	   Hotels = COUNT(h.Id)
  FROM Cities AS c
	   LEFT OUTER JOIN Hotels As h
	   ON h.CityId = c.Id
 GROUP BY C.[Name]
 ORDER BY Hotels DESC,
	   City


-- 09. Expensive First-Class Rooms

SELECT r.Id,
	   r.Price,
	   h.[Name] AS Hotel,
	   c.[Name] AS City
  FROM Rooms AS r
	   JOIN Hotels AS h
	   ON h.Id = r.HotelId
	   JOIN Cities AS c
	   ON c.Id = h.CityId
 WHERE r.[Type] = 'First Class'
 ORDER BY r.Price DESC,
	   r.Id


-- 10. Longest and Shortest Trips

SELECT a.Id AS AccountId,
	   a.FirstName + ' ' + a.LastName AS FullName,
	   LongestTrip = MAX(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)),
	   ShortestTrip = MIN(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate))
  FROM Accounts AS a
	   JOIN AccountsTrips AS [at]
	   ON [at].AccountId = a.Id
	   JOIN Trips AS t
	   ON t.Id = [at].TripId
 WHERE a.MiddleName IS NULL
   AND t.CancelDate IS NULL
 GROUP BY a.Id,
	   a.FirstName + ' ' + a.LastName
 ORDER BY LongestTrip DESC,
	   a.Id


-- 11. Metropolis

SELECT TOP (5) c.Id,
	   c.[Name] AS City,
	   c.CountryCode AS Country,
	   Accounts = COUNT(a.Id)
  FROM Cities AS c
	   JOIN Accounts AS a
	   ON a.CityId = c.Id
 GROUP BY c.Id,
	   c.[Name],
	   c.CountryCode
 ORDER BY Accounts DESC


-- 12. Romantic Getaways

SELECT a.Id,
	   a.Email,
	   c.[Name] AS City,
	   COUNT([at].TripId) AS Trips
  FROM Accounts AS a
	   JOIN Cities AS c
	   ON c.Id = a.CityId
	   JOIN AccountsTrips AS [at]
	   ON [at].AccountId = a.Id
	   JOIN Trips AS t
	   ON t.Id = [at].TripId
	   JOIN Rooms AS r
	   ON r.Id = t.RoomId
	   JOIN Hotels AS h
	   ON h.Id = r.HotelId
	   JOIN Cities AS vc
	   ON vc.Id = h.CityId
 WHERE vc.[Name] = c.[Name]
 GROUP BY a.Id,
	   a.Email,
	   c.[Name]
 ORDER BY Trips DESC,
	   a.Id


-- 13. Lucrative Destinations

SELECT TOP (10) c.Id,
	   c.[Name],
	   [Total Revenue] = SUM(h.BaseRate + r.Price),
	   Trips = COUNT(DISTINCT t.Id)
  FROM Cities AS c
	   JOIN Hotels AS h
	   ON h.CityId = c.Id
	   JOIN Rooms AS r
	   ON r.HotelId = h.Id
	   JOIN Trips AS t
	   ON t.RoomId = r.Id
 WHERE YEAR(t.BookDate) = 2016
 GROUP BY C.Id,
	   c.[Name]
 ORDER BY [Total Revenue] DESC,
	   Trips DESC


-- 14. Trip Revenues

SELECT t.Id,
	   h.[Name] AS HotelName,
	   r.[Type] AS RoomType,
	   Revenue =
	   CASE
	   WHEN t.CancelDate IS NOT NULL THEN 0
	   ELSE SUM(h.BaseRate + r.Price)
	   END
  FROM Trips AS t
	   JOIN Rooms AS r
	   ON r.Id = t.RoomId
	   JOIN Hotels AS h
	   ON h.Id = r.HotelId
	   JOIN AccountsTrips AS [at]
	   ON [at].TripId = t.Id
 GROUP BY t.Id,
	   h.[Name],
	   r.Type,
	   t.CancelDate
 ORDER BY r.[Type],
	   t.Id
	
	
-- 15. Top Travelers

WITH Travellers_CTE
AS
(
	SELECT a.Id AS AccountId,
		   a.Email,
		   c.CountryCode,
		   Trips = COUNT(t.Id),
		   RowNumber = ROW_NUMBER() OVER(PARTITION BY c.CountryCode ORDER BY COUNT(t.Id) DESC)
	  FROM Accounts AS a
		   JOIN AccountsTrips AS [at]
		   ON [at].AccountId = a.Id 
		   JOIN Trips AS t
		   ON t.Id = [at].TripId
		   JOIN Rooms AS r
		   ON r.Id = t.RoomId
		   JOIN Hotels AS h
		   On h.Id = r.HotelId
		   JOIN Cities AS c
		   ON c.Id = h.CityId
	 GROUP BY a.Id,
		   a.Email,
		   c.CountryCode
)

SELECT AccountId,
	   Email,
	   CountryCode,
	   Trips
  FROM Travellers_CTE
 WHERE RowNumber = 1
 ORDER BY Trips DESC,
	   AccountId


--SELECT AccountId,
--	   Email,
--	   CountryCode,
--	   Trips
--FROM (SELECT a.Id AS AccountId,
--			 a.Email,
--			 c.CountryCode,
--			 Trips = COUNT(c.Id),
--			 RowNumber = ROW_NUMBER() OVER (PARTITION BY c.CountryCode ORDER BY COUNT(c.Id) DESC)
--	    FROM Accounts AS a
--	         JOIN AccountsTrips AS [at]
--	         ON [at].AccountId = a.Id
--	         JOIN Trips AS t
--	         ON t.Id = [at].TripId
--	         JOIN Rooms AS r
--	         ON r.Id = t.RoomId
--	         JOIN Hotels AS h
--	         ON h.Id = r.HotelId
--	         JOIN Cities AS c
--	         ON c.Id = h.CityId
--	   GROUP BY a.Id,
--			 a.Email,
--			 c.CountryCode
--	  HAVING COUNT(c.Id) =
--			 (SELECT TOP (1) COUNT(c2.Id)
--				FROM Accounts AS a2
--					 JOIN AccountsTrips AS at2
--					 ON at2.AccountId = a2.Id
--					 JOIN Trips AS t2
--					 ON t2.Id = at2.TripId
--					 JOIN Rooms AS r2
--					 ON r2.Id = t2.RoomId
--					 JOIN Hotels AS h2
--					 ON h2.Id = r2.HotelId
--					 JOIN Cities AS c2
--					 ON c2.Id = h2.CityId
--			   GROUP BY a2.Id,
--					 a2.Email,
--					 c2.CountryCode
--			  HAVING c2.CountryCode = c.CountryCode
--			   ORDER BY COUNT(c2.Id) DESC
--	   )) AS t
-- WHERE RowNumber = 1
-- ORDER BY Trips DESC,
--	   AccountId


-- 16. Luggage Fees

SELECT t.Id AS TripId,
	   Luggage = SUM([at].Luggage),
	   Fee = CONCAT('$', 
	   CASE 
	   WHEN SUM([at].Luggage) > 5 THEN 5 * SUM([at].Luggage)
	   ELSE 0
	   END)
  FROM Trips AS t
	   JOIN AccountsTrips AS [at]
	   ON [at].TripId = t.Id
 GROUP BY t.Id
HAVING SUM([at].Luggage) > 0
 ORDER BY SUM([at].Luggage) DESC


-- 17. GDPR Violation

SELECT t.Id,
	   CONCAT(a.FirstName, ' ', ISNULL(a.MiddleName + ' ', ''), a.LastName) AS [Full Name],
	   c.[Name] AS [From],
	   hc.[Name] AS [To],
	   Duration =
	   CASE
	   WHEN t.CancelDate IS NOT NULL THEN 'Canceled'
	   ELSE CONCAT(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate), ' days')
	   END
  FROM Trips AS t
	   JOIN AccountsTrips AS [at]
	   ON [at].TripId = t.Id
	   JOIN Accounts AS a
	   ON a.Id = [at].AccountId
	   JOIN Cities AS c
	   ON c.Id = a.CityId
	   JOIN Rooms AS r
	   ON r.Id = t.RoomId
	   JOIN Hotels AS h
	   ON h.Id = r.HotelId
	   JOIN Cities AS hc
	   ON hc.Id = h.CityId
 ORDER BY [Full Name],
	   t.Id