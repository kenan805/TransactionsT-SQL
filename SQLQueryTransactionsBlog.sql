CREATE PROCEDURE AddCommentMark
	@comid AS int,
	@userid AS int,
	@mark AS int
AS
BEGIN
	BEGIN TRAN CommentMark

	INSERT INTO CommentRating(IdComment, IdUser, Mark)
	VALUES(@comid, @userid, @mark)

	IF(@@ERROR != 0)
	BEGIN
		PRINT 'Error in insert'
		ROLLBACK TRAN CommentMark
	END
	ELSE
	BEGIN
		PRINT 'Insert ok'

		UPDATE Comments
		SET Rating = (
			SELECT CAST(SUM(MARK) AS float) / COUNT(*)
			FROM Comments INNER JOIN CommentRating
			ON Comments.Id = CommentRating.IdComment
			WHERE Comments.Id = @comid
		)
		WHERE Comments.Id = @comid

		UPDATE Users
		SET Rating = (
			((SELECT SUM(Rating) FROM Posts
			WHERE IdUser = @userid) +
			(SELECT SUM(Rating) FROM Comments
			WHERE IdUser = @userid)) / 2
			)
		WHERE Users.Id = @userid
		
		IF(@@ERROR != 0)
		BEGIN
			PRINT 'Error in update'
			ROLLBACK TRAN CommentMark
		END
		ELSE
		BEGIN
			PRINT 'Update ok'
			COMMIT TRAN CommentMark
		END

	END
END

EXEC AddCommentMark 3,2,3


CREATE PROCEDURE AddPostMark
	@postid AS int,
	@userid AS int,
	@mark AS int
AS
BEGIN
	BEGIN TRAN PostMark

	INSERT INTO PostRating(IdPost, IdUser, Mark)
	VALUES(@postid, @userid, @mark)

	IF(@@ERROR != 0)
	BEGIN
		PRINT 'Error in insert'
		ROLLBACK TRAN PostMark
	END
	ELSE
	BEGIN
		PRINT 'Insert ok'

		UPDATE Posts
		SET Rating = (
			SELECT CAST(SUM(MARK) AS float) / COUNT(*)
			FROM Posts INNER JOIN PostRating
			ON Posts.Id = PostRating.IdPost
			WHERE Posts.Id = @postid
		)
		WHERE Posts.Id = @postid

		UPDATE Users
		SET Rating = (
			((SELECT SUM(Rating) FROM Posts
			WHERE IdUser = @userid) +
			(SELECT SUM(Rating) FROM Comments
			WHERE IdUser = @userid)) / 2
			)
		WHERE Users.Id = @userid
		
		IF(@@ERROR != 0)
		BEGIN
			PRINT 'Error in update'
			ROLLBACK TRAN PostMark
		END
		ELSE
		BEGIN
			PRINT 'Update ok'
			COMMIT TRAN PostMark
		END

	END
END

EXEC AddPostMark 1, 1, 3