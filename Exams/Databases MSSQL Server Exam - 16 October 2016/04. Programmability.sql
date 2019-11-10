-- 01. Review Registering Procedure

CREATE PROC usp_SubmitReview @CustomerID INT, @ReviewContent VARCHAR(255), @ReviewGrade INT, @AirlineName VARCHAR(30)
AS
BEGIN
	DECLARE @airlineID INT =
			(SELECT AirlineID
			   FROM Airlines
			  WHERE AirlineName = @AirlineName)

	IF (@airlineID IS NULL)
	BEGIN
		RAISERROR('Airline does not exist.', 16, 1)
		RETURN
	END

	DECLARE @reviewID INT = ISNULL(
			(SELECT TOP (1) ReviewID
			   FROM CustomerReviews
			  ORDER BY ReviewID DESC), 0) + 1
			  
	INSERT INTO CustomerReviews
		   (ReviewID, ReviewContent, ReviewGrade, AirlineID, CustomerID)
	VALUES (@reviewID, @ReviewContent, @ReviewGrade, @airlineID, @CustomerID)
END


-- 02. Ticket Purchase Procedure

CREATE PROC usp_PurchaseTicket @CustomerID INT, @FlightID INT, @TicketPrice DECIMAL(8, 2), @Class VARCHAR(6), @Seat VARCHAR(5)
AS
BEGIN
	DECLARE @ticketID INT = ISNULL(
			(SELECT TOP (1) TicketID
			   FROM Tickets
			  ORDER BY TicketID DESC), 0) + 1

	DECLARE @customerAccountID INT =
			(SELECT TOP (1) AccountID
			   FROM CustomerBankAccounts
			  WHERE CustomerID = @CustomerID
			  ORDER BY Balance DESC)

	DECLARE @customerBalance DECIMAL(10, 2) =
		    (SELECT Balance
			   FROM CustomerBankAccounts
			  WHERE AccountID = @customerAccountID)

	IF (@customerBalance IS NULL OR @TicketPrice > @customerBalance)
	BEGIN
		RAISERROR('Insufficient bank account balance for ticket purchase.', 16, 1)
		RETURN
	END
	
	INSERT INTO Tickets
		   (TicketID, Price, Class, Seat, CustomerID, FlightID)
	VALUES (@ticketID, @TicketPrice, @Class, @Seat, @CustomerID, @FlightID)

	UPDATE CustomerBankAccounts
	   SET Balance -= @TicketPrice
	 WHERE AccountID = @customerAccountID
END