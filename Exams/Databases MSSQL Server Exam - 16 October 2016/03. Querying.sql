-- 01. Extract All Tickets

SELECT TicketID,
	   Price,
	   Class,
	   Seat
  FROM Tickets
 ORDER BY TicketID

-- 02. Extract All Customers 

SELECT CustomerID,
	   FirstName + ' ' + LastName AS FullName,
	   Gender
  FROM Customers
 ORDER BY FullName,
	   CustomerID


-- 03. Extract Delayed Flights

SELECT FlightID,
	   DepartureTime,
	   ArrivalTime
  FROM Flights
 WHERE [Status] = 'Delayed'
 ORDER BY FlightID


-- 04. Extract Top 5 Most Highly Rated Airlines which have any Flights

SELECT DISTINCT TOP (5) a.AirlineID,
	   a.AirlineName,
	   a.Nationality,
	   a.Rating
  FROM Airlines AS a
	   JOIN Flights AS f
	   ON f.AirlineID = a.AirlineID
 ORDER BY Rating DESC,
	   a.AirlineID


-- 05. Extract all Tickets with price below 5000, for First Class

SELECT t.TicketID,
	   a.AirportName AS Destination,
	   c.FirstName + ' ' + c.LastName AS CustomerName
  FROM Tickets AS t
	   JOIN Customers AS c
	   ON c.CustomerID = t.CustomerID
	   JOIN Flights AS f
	   ON f.FlightID = t.FlightID
	   JOIN Airports AS a
	   ON a.AirportID = f.DestinationAirportID
 WHERE t.Price < 5000
   AND t.Class = 'First'
 ORDER BY t.TicketID


-- 06. Extract all Customers which are departing from their Home Town

SELECT DISTINCT c.CustomerID,
	   c.FirstName + ' ' + c.LastName AS FullName,
	   t.TownName AS HomeTown
  FROM Customers AS c
	   JOIN Tickets AS tc
	   ON tc.CustomerID = c.CustomerID
	   JOIN Flights AS f
	   ON f.FlightID = tc.FlightID
	   JOIN Airports AS a
	   ON a.AirportID = f.OriginAirportID
	   JOIN Towns AS t
	   ON t.TownID = a.TownID
 WHERE a.TownID = c.HomeTownID
 ORDER BY c.CustomerID


-- 07. Extract all Customers which will fly

SELECT DISTINCT c.CustomerID,
	   c.FirstName + ' ' + c.LastName AS FullName,
	   Age = 2016 - YEAR(c.DateOfBirth)
  FROM Customers AS c
	   JOIN Tickets AS t
	   ON t.CustomerID = c.CustomerID
	   JOIN Flights AS f
	   ON f.FlightID = t.FlightID
 WHERE f.[Status] = 'Departing'
 ORDER BY 2016 - YEAR(c.DateOfBirth),
	   c.CustomerID


-- 08. Extract Top 3 Customers which have Delayed Flights

SELECT TOP (3) c.CustomerID,
	   c.FirstName + ' ' + c.LastName AS FullName,
	   t.Price AS TicketPrice,
	   da.AirportName AS Destination
  FROM Customers AS c
	   JOIN Tickets AS t
	   ON t.CustomerID = c.CustomerID
	   JOIN Flights AS f
	   ON f.FlightID = t.FlightID
	   JOIN Airports AS da
	   ON da.AirportID = f.DestinationAirportID
 WHERE f.[Status] = 'Delayed'
 ORDER BY TicketPrice DESC


-- 09: Extract the Last 5 Flights, which are departing

SELECT * 
  FROM (SELECT TOP(5) f.FlightID,
			   f.DepartureTime,
			   f.ArrivalTime,
			   oa.AirportName AS Origin,
			   da.AirportName AS Destination
		  FROM Flights AS f
			   JOIN Airports AS oa
			   ON oa.AirportID = f.OriginAirportID
			   JOIN Airports AS da
			   ON da.AirportID = f.DestinationAirportID
		 WHERE f.[Status] = 'Departing'
		 ORDER BY f.DepartureTime DESC
	   ) AS f 
 ORDER BY DepartureTime,
	   FlightID


-- 10: Extract all Customers below 21 years, which have already flew at least once

SELECT DISTINCT c.CustomerID,
	   c.FirstName + ' ' + c.LastName AS FullName,
	   Age = 2016 - YEAR(c.DateOfBirth)
  FROM Customers AS c
	   JOIN Tickets AS t
	   ON t.CustomerID = c.CustomerID
	   JOIN Flights AS f
	   ON f.FlightID = t.FlightID
 WHERE 2016 - YEAR(c.DateOfBirth) < 21
   AND f.[Status] = 'Arrived'
 ORDER BY Age DESC,
	   c.CustomerID


-- 11. Extract all Airports and the Count of People departing from them

SELECT a.AirportID,
	   a.AirportName,
	   Passengers = COUNT(t.TicketID)
  FROM Airports AS a
	   JOIN Flights AS f
	   ON f.OriginAirportID = a.AirportId
	   JOIN Tickets AS t
	   ON t.FlightID = f.FlightID
 WHERE f.[Status] = 'Departing'
 GROUP BY a.AirportID,
	   a.AirportName
 ORDER BY a.AirportID