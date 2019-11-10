-- 16. Customers with Countries

CREATE VIEW v_UserWithCountries 
AS
(SELECT cm.FirstName + ' ' + cm.LastName AS CustomerName,
 	    cm.Age,
 	    cm.Gender,
 	    c.[Name] AS CountryName
   FROM Customers AS cm
 	    JOIN Countries AS c
 	    ON cm.CountryId = c.Id)

-- 17. Feedback by Product Name

CREATE FUNCTION udf_GetRating(@ProductName NVARCHAR(25))
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @productId INT =
			(SELECT Id
			   FROM Products
			   WHERE [Name] = @ProductName)
	DECLARE @productAverageRate DECIMAL(4, 2) =
			(SELECT AVG(Rate)
			   FROM Feedbacks
			  WHERE ProductId = @productId)
		 
	DECLARE @result VARCHAR(10) =
			CASE
			WHEN @productAverageRate IS NULL THEN 'No rating'
			WHEN @productAverageRate < 5 THEN 'Bad'
			WHEN @productAverageRate <= 8 THEN 'Average'
			ELSE 'Good'
			END

	RETURN @result
END


-- 18. Send Feedback

CREATE PROC usp_SendFeedback @CustomerId INT, @ProductId INT, @Rate DECIMAL(4, 2), @Description NVARCHAR(255)
AS
BEGIN
	BEGIN TRANSACTION
		INSERT INTO Feedbacks
			   (CustomerId, ProductId, Rate, [Description])
		VALUES (@CustomerId, @ProductId, @Rate, @Description)

		DECLARE @userFeedbacksFoProduct INT =
				(SELECT COUNT(*)
				   FROM Feedbacks
				  GROUP BY CustomerId,
					    ProductId
				 HAVING CustomerId = @CustomerId
					AND ProductId = @ProductId)

		IF (@userFeedbacksFoProduct > 3)
		BEGIN
			ROLLBACK
			RAISERROR('You are limited to only 3 feedbacks per product!', 16, 1)
			RETURN
		END
	COMMIT
END


-- 19. Delete Products

CREATE TRIGGER tr_ProductsDelete
ON Products
INSTEAD OF DELETE
AS
BEGIN
	DELETE FROM Feedbacks
	 WHERE ProductId IN
		   (SELECT Id
			  FROM deleted)
	
	DELETE FROM ProductsIngredients
	 WHERE ProductId IN
		   (SELECT Id
			  FROM deleted)

	DELETE FROM Products
	 WHERE Id IN
		   (SELECT Id
			  FROM deleted)
END