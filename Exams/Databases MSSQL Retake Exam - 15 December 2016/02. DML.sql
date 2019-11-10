-- 02. Insert

INSERT INTO [Messages]
	   (Content, SentOn, ChatId, UserId)
SELECT CONCAT(u.Age, '-', u.Gender, '-', l.Latitude, '-', l.Longitude),
	   GETDATE(),
	   CEILING(
	   CASE
	   WHEN u.Gender = 'F' THEN SQRT(u.Age * 2 )
	   WHEN u.Gender = 'M' THEN POWER(u.Age / 18, 3)
	   END),
	   u.Id
  FROM Users AS u
	   JOIN Locations AS l
	   ON l.Id = u.LocationId
 WHERE u.Id BETWEEN 10 AND 20


-- 03. Update

UPDATE Chats
   SET StartDate =
	   (SELECT TOP (1) SentOn
	      FROM [Messages]
		 WHERE ChatId = Chats.Id
		 ORDER BY SentOn)
 WHERE StartDate >
	   (SELECT TOP (1) SentOn
	      FROM [Messages]
		 WHERE ChatId = Chats.Id
		 ORDER BY SentOn)


-- 04. Delete

DELETE FROM Locations
 WHERE Id NOT IN
	   (SELECT LocationId
	      FROM Users
		 WHERE LocationId IS NOT NULL)