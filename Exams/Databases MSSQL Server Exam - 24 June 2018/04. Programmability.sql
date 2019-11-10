-- 18. Available Room

CREATE FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATE, @People INT)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @hotelBaseRate DECIMAL(15, 2)=
			(SELECT BaseRate
			   FROM Hotels
			  WHERE Id = @HotelId);
	
	DECLARE @roomId INT =
			(SELECT TOP (1) r.Id
			   FROM Rooms AS r
			  WHERE r.Id NOT IN (SELECT r2.Id
								   FROM Rooms AS r2
						      		    LEFT JOIN Trips AS t
						      		    ON t.RoomId = r2.Id
								  WHERE t.CancelDate IS NULL
								    AND @Date >= t.ArrivalDate 
								    AND @Date <= t.ReturnDate
								    AND r2.HotelId = @HotelId
								    AND r2.Beds >= @People)
				AND r.HotelId = @HotelId
			    AND r.Beds >= @People
			  ORDER BY (@hotelBaseRate + r.Price) * @People DESC)

	DECLARE @result VARCHAR(100) = 'No rooms available'

	IF (@roomId IS NOT NULL)
	BEGIN
		DECLARE @roomType VARCHAR(20) =
				(SELECT [Type]
				   FROM Rooms
				  WHERE Id = @roomId)
		DECLARE @roomPrice DECIMAL(15, 2) =
				(SELECT Price
				   FROM Rooms
				  WHERE Id = @roomId)
		DECLARE @beds INT =
				(SELECT Beds
				   FROM Rooms
				  WHERE Id = @roomId)
		DECLARE @totalPrice DECIMAL(15, 2) = (@hotelBaseRate + @roomPrice) * @People
		
		SET @result = CONCAT('Room ', @roomId, ': ', @roomType, ' (', @beds, ' beds) - $', @totalPrice)
	END
	
	RETURN @result
END


-- 19. Switch Room

CREATE PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
BEGIN
	DECLARE @currentHotelId INT =
		(SELECT h.Id
		   FROM Hotels AS h
			    JOIN Rooms AS r
				ON r.HotelId = h.Id
				JOIN Trips As t
				ON t.RoomId = r.Id
		  WHERE t.Id = @TripId)
	DECLARE @targetHotelId INT =
			(SELECT HotelId
			   FROM Rooms
			  WHERE Id = @TargetRoomId)

	IF (@currentHotelId <> @targetHotelId)
	BEGIN
		RAISERROR('Target room is in another hotel!', 16, 1)
		RETURN
	END

	DECLARE @beds INT =
			(SELECT Beds
			   FROM Rooms
			  WHERe Id = @TargetRoomId)			 
	DECLARE @requiredBeds INT =
			(SELECT COUNT(AccountId)
			   FROM AccountsTrips
			  GROUP BY TripId
			 HAVING TripId = @TripId)

	IF (@beds < @requiredBeds)
	BEGIN
		RAISERROR('Not enough beds in target room!', 16, 2)
		RETURN
	END

	BEGIN TRANSACTION		
		UPDATE Trips
		   SET RoomId = @TargetRoomId
		 WHERE Id = @TripId
	 COMMIT
END


-- 20. Cancel Trip

CREATE TRIGGER tr_TripsDelete
ON Trips
INSTEAD OF DELETE
AS
BEGIN
	UPDATE Trips
	   SET CancelDate = GETDATE()
	 WHERE CancelDate IS NULL
	   AND Id IN
		   (SELECT Id
		      FROM deleted)
END