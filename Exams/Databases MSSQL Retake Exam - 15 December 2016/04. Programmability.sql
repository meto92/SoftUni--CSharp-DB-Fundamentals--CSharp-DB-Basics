-- 15. Radians

CREATE FUNCTION udf_GetRadians(@Degrees FLOAT)
RETURNS FLOAT
AS
BEGIN
	DECLARE @radians FLOAT = @Degrees * PI() / 180

	RETURN @radians
END
  

-- 16. Change Password

CREATE PROC udp_ChangePassword(@Email VARCHAR(30), @NewPassword VARCHAR(20))
AS
BEGIN
	DECLARE @credentialId INT =
			(SELECT Id
			   FROM [Credentials]
			  WHERE Email = @Email)

	IF (@credentialId IS NULL)
	BEGIN
		RAISERROR('The email does''t exist!', 16, 1)
		RETURN
	END

	UPDATE [Credentials]
	   SET [Password] = @NewPassword
	 WHERE Id = @credentialId
END


-- 17. Send Message

CREATE PROC udp_SendMessage @UserId INT, @ChatId INT, @Content VARCHAR(200)
AS
BEGIN
	DECLARE @hasUserWithGivenChat BIT =
			(SELECT COUNT(*)
			   FROM UsersChats
			  WHERE UserId = @UserId
			    AND ChatId = @ChatId)

	IF (@hasUserWithGivenChat = 0)
	BEGIN
		RAISERROR('There is no chat with that user!', 16, 1)
		RETURN
	END
	
	INSERT INTO [Messages]
		   (Content, SentOn, ChatId, UserId)
	VALUES (@Content, GETDATE(), @ChatId, @UserId)
END


-- 18. Log Messages

CREATE TABLE MessageLogs (
	Id INT		   NOT NULL,
	Content   VARCHAR(200) NOT NULL,
	SentOn    DATE		   NOT NULL,
	ChatId    INT		   NOT NULL,
	UserId    INT		   NOT NULL,
)

CREATE TRIGGER tr_MessagesDelete
ON [Messages]
AFTER DELETE
AS
BEGIN
	INSERT INTO MessageLogs
		   (Id, Content, SentOn, ChatId, UserId)
	SELECT Id,
		   Content,
		   SentOn,
		   ChatId,
		   UserId
	  FROM deleted
END


-- 19. Delete users

CREATE TRIGGER tr_UsersDelete
ON Users
INSTEAD OF DELETE
AS
BEGIN
	DELETE FROM [Messages]
	 WHERE UserId IN
		   (SELECT Id
		     FROM deleted)

	DELETE FROM UsersChats
	 WHERE UserId IN
		   (SELECT Id
		     FROM deleted)

	DELETE FROM Users
	 WHERE Id IN
		   (SELECT Id
		     FROM deleted)
END