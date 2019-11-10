-- Update Trigger

CREATE TABLE ArrivedFlights (
	FlightID	INT,
	ArrivalTime DATETIME2   NOT NULL,
	Origin		VARCHAR(50) NOT NULL,
	Destination	VARCHAR(50) NOT NULL,
	Passengers  INT			NOT NULL,

	CONSTRAINT PK_ArrivedFlights_FlightID
	PRIMARY KEY(FlightID)
)

CREATE TRIGGER tr_FlightsUpdate
ON Flights
AFTER UPDATE
AS
BEGIN
	INSERT INTO ArrivedFlights
		   (FlightID, ArrivalTime, Origin, Destination, Passengers)
	SELECT i.FlightID,
		   i.ArrivalTime,
		   (SELECT t.TownName
		      FROM Towns AS t
				   JOIN Airports AS oa
				   ON oa.AirportID = i.OriginAirportID
			 WHERE oa.TownID = t.TownID
			 ),
			 (SELECT t.TownName
		       FROM Towns AS t
				    JOIN Airports AS da
				    ON da.AirportID = i.DestinationAirportID
			  WHERE t.TownID = da.TownId
			 ),
			 (SELECT COUNT(*)
			    FROM Tickets AS t
			   WHERE t.FlightID = i.FlightID)
	  FROM deleted AS d
		   JOIN inserted AS i
		   ON i.FlightID = d.FlightID 
	  WHERE i.[Status] = 'Arrived'
	    AND d.[Status] <> 'Arrived'
END