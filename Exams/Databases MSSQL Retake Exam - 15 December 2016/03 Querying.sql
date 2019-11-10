-- 05. Age Range

SELECT Nickname,
	   Gender,
	   Age
  FROM Users
 WHERE AGe BETWEEN 22 AND 37


-- 06. Messages

SELECT Content,
	   SentOn
  FROM [Messages]
 WHERE SentOn > '2014/05/12'
   AND Content LIKE '%just%'
 ORDER BY Id DESC


-- 07. Chats

SELECT Title,
	   IsActive
  FROM Chats
 WHERE IsActive = 0
   AND LEN(Title) < 5 
    OR Title LIKE '__tl%'
 ORDER BY Title DESC


-- 08. Chat Messages

SELECT c.Id,
	   c.Title,
	   m.Id
  FROM Chats AS c
	   JOIN [Messages] AS m
	   ON m.ChatId = c.Id
 WHERE m.SentOn < '2012/03/26'
   AND c.Title LIKE '%x'
 ORDER BY c.Id,
	   m.Id


-- 09. Message Count

SELECT TOP (5) c.Id,
	   COUNT(m.Id) AS TotalMessages
  FROM Chats AS c
	   RIGHT OUTER JOIN [Messages] AS m
	   ON m.ChatId = c.Id
 WHERE m.Id < 90
 GROUP BY c.Id
 ORDER BY TotalMessages DESC,
	   c.Id


-- 10. Credentials

SELECT u.Nickname,
	   c.Email,
	   c.[Password]
  FROM Users AS u
	   JOIN [Credentials] AS c
	   ON c.Id = u.CredentialId
 WHERE c.Email LIKE '%co.uk'
 ORDER BY c.Email


-- 11. Locations

SELECT Id,
	   Nickname,
	   Age
  FROM Users
 WHERE LocationId IS NULL	   


-- 12. Left Users

SELECT m.Id,
	   m.ChatId,
	   m.UserId
  FROM [Messages] AS m
	   JOIN Chats AS c
	   ON c.Id = m.ChatId
	   LEFT OUTER JOIN UsersChats AS uc
	   ON uc.UserId = m.UserId
		  AND uc.ChatId = m.ChatId
 WHERE m.ChatId = 17
   AND uc.UserId IS NULL
 ORDER BY m.Id DESC


-- 13. Users in Bulgaria

SELECT u.Nickname,
	   c.Title,
	   l.Latitude,
	   l.Longitude
  FROM Users AS u
	   JOIN UsersChats AS uc
	   ON uc.UserId = u.Id
	   JOIN Chats AS c
	   ON c.Id = uc.ChatId
	   JOIN Locations AS l
	   ON l.Id = u.LocationId
 WHERE l.Latitude BETWEEN 41.14 AND 44--CAST(44.13 AS NUMERIC)
   AND l.Longitude BETWEEN 22.21 AND 28--CAST(28.36 AS NUMERIC)
 ORDER BY c.Title


-- 14. Last Chat

SELECT TOP (1) WITH TIES c.Title,
	   m.Content
  FROM Chats AS c
	   LEFT OUTER JOIN [Messages] AS m
	   ON m.ChatId = c.Id
 ORDER BY c.StartDate DESC