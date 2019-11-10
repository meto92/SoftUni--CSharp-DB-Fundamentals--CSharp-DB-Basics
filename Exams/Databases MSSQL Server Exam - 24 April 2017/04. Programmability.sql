-- 17. Cost of Order

CREATE FUNCTION udf_GetCost(@JobId INT)
RETURNS DECIMAL(15, 2)
AS
BEGIN
	DECLARE @total DECIMAL(15, 2) =
			(SELECT SUM(p.Price * op.Quantity)
			   FROM Parts AS p
					JOIN OrderParts AS op
					ON op.PartId = p.PartId
					JOIN Orders AS o
					ON o.OrderId = op.OrderId
					JOIN Jobs AS j
					ON j.JobId = o.JobId
			  WHERE j.JobId = @JobId)

	RETURN ISNULL(@total, 0)
END


-- 18. Place Order

CREATE PROC usp_PlaceOrder @JobId INT, @PartSerialNumber VARCHAR(50), @Quantity INT
AS
BEGIN
	IF (@Quantity <= 0)
		THROW 50012, 'Part quantity must be more than zero!', 1

	DECLARE @jobStatus VARCHAR(11) =
			(SELECT [Status]
			   FROM Jobs
			  WHERE JobId = @JobId)
			  
	IF (@jobStatus = 'Finished')
		THROW 50011, 'This job is not active!', 1
		
	IF (@jobStatus IS NULL)
		THROW 50013, 'Job not found!', 1

	DECLARE @partId INT =
			(SELECT PartId
				FROM Parts
			   WHERE SerialNumber = @PartSerialNumber)

	IF (@partId IS NULL)
		THROW 50014, 'Part not found!', 1
		
	DECLARE @orderId INT =
			(SELECT OrderId
			   FROM Orders
			  WHERE JobId = @JobId
			    AND IssueDate IS NULL)
	
	IF (@orderId IS NOT NULL)
	BEGIN
		UPDATE OrderParts
		   SET Quantity += @Quantity
		 WHERE OrderId = @orderId
		   AND PartId = @partId

		IF (@@ROWCOUNT = 0)
		BEGIN
			INSERT INTO OrderParts
				   (OrderId, PartId, Quantity)
			VALUES (@orderId, @partId, @Quantity)
		END
	END
	ELSE
	BEGIN
		INSERT INTO Orders
			   (IssueDate, JobId)
		VALUES (NULL, @JobId)

		DECLARE @newOrderId INT =
				(SELECT OrderId
				   FROM Orders
				  WHERE IssueDate IS NULL
				    AND JobId = @JobId)

		INSERT INTO OrderParts
			   (OrderId, PartId, Quantity)
		VALUES (@newOrderId, @partId, @Quantity)
	END
END


-- 19. Detect Delivery

CREATE TRIGGER tr_OrdersUpdate
ON ORDERS
AFTER UPDATE
AS
BEGIN
	UPDATE Parts
	   SET StockQty += t.Quantity
	  FROM (SELECT op.PartId,
				   op.Quantity
			  FROM OrderParts AS op
				   JOIN inserted AS i
				   ON i.OrderId = op.OrderId
				   JOIN deleted AS d
				   ON d.OrderId = op.OrderId
			 WHERE d.Delivered = 0
			   AND i.Delivered = 1) AS t
		   JOIN Parts
		   ON Parts.PartId = t.PartId
END


-- 20. Vendor Preference

SELECT *,
	   Preference =
	   CONCAT(CAST(Parts * 100.0 / 
	   (SELECT SUM(op.Quantity)
	      FROM Mechanics AS m
			   JOIN Jobs AS j
			   ON j.MechanicId = m.MechanicId
			   JOIN Orders AS o
			   ON o.JobId = j.JobId
			   JOIN OrderParts As op
			   ON op.OrderId = o.OrderId
	     GROUP BY m.FirstName + ' ' + m.LastName
	    HAVING m.FirstName + ' ' + m.LastName = Mechanic) AS INT), '%')
  FROM (SELECT m.FirstName + ' ' + m.LastName AS Mechanic,
	   		   v.[Name] As Vendor,
	   		   Parts = SUM(op.Quantity)
	      FROM Mechanics AS m
	   		   JOIN Jobs AS j
	   		   ON j.MechanicId = m.MechanicId
	   		   JOIN Orders AS o
	   		   ON o.JobId = j.JobId
	   		   JOIN OrderParts As op
	   		   ON op.OrderId = o.OrderId
	   		   JOIN Parts AS p
	   		   ON p.PartId = op.PartId
	   		   JOIN Vendors AS v
	   		   ON v.VendorId = p.VendorId
		 GROUP BY m.FirstName + ' ' + m.LastName,
	   		   v.[Name]
	   ) AS t
 ORDER BY Mechanic,
	   Parts DESC,
	   Vendor