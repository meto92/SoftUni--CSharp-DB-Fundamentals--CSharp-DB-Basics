-- 17. Find My Ride

CREATE FUNCTION udf_CheckForVehicle(@TownName NVARCHAR(50), @SeatsNumber INT)
RETURNS NVARCHAR(100)
AS
BEGIN
	DECLARE @result NVARCHAR(100) =
			(SELECT ISNULL(
					(SELECT TOP (1) o.[Name] + ' - ' + m.Model
					   FROM Offices AS o
						    JOIN Towns AS t
						    ON t.Id = o.TownId
						    JOIN Vehicles AS v
						    ON v.OfficeId = o.Id
							   AND o.TownId = t.Id
						    JOIN Models AS m
						    ON m.Id = v.ModelId
					  WHERE m.Seats = @SeatsNumber
					    AND t.[Name] = @TownName
					  ORDER BY o.[Name]
					), 'NO SUCH VEHICLE FOUND')
			)
	 RETURN @result
END


-- 18. Move a Vehicle

CREATE PROC usp_MoveVehicle @VehicleId INT, @OfficeId INT
AS
BEGIN
	DECLARE @parkingPlaces INT =
			(SELECT ParkingPlaces
			   FROM Offices
			  WHERE Id = @OfficeId)
	DECLARE @carsInParking INT =
			(SELECT COUNT(*) 
			   FROM Vehicles 
			  WHERE OfficeId = @OfficeId)
	IF (@carsInParking >= @parkingPlaces)
	BEGIN
		RAISERROR('Not enough room in this office!', 16, 1)
		RETURN
	END

	UPDATE Vehicles
	   SET OfficeId = @OfficeId
	 WHERE Id = @VehicleId
END


-- 19. Move the Tally

CREATE TRIGGER tr_OrdersInsert
ON Orders
AFTER UPDATE
AS
BEGIN
	IF ((SELECT TotalMileage 
		   FROM deleted
		) IS NOT NULL)
		RETURN

	UPDATE Vehicles
	   SET Mileage += 
		   (SELECT TotalMileage 
			  FROM inserted)
	 WHERE Id =
		   (SELECT VehicleId
			  FROM inserted)
END