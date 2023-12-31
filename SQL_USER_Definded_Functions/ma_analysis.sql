USE [day2database]
GO
/****** Object:  StoredProcedure [dbo].[ma_analysis]    Script Date: 2023/7/29 下午 02:45:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[ma_analysis]
	-- Add the parameters for the stored procedure here
	@company varchar(10),
	@whichma1 varchar(10),
	@whichma2 varchar(10),
	@Result char(50) output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @stock_code VARCHAR(10)
	DECLARE @c FLOAT,
			@MA1 FLOAT, 
			@MA2 FLOAT,
			@Day INT = 0, 
			@dailytrend INT = 0, 
			@trend INT = 0;


DECLARE cur CURSOR LOCAL FOR 
	SELECT c, 
		CASE @whichma1
			WHEN 'ma5' THEN ma5
			WHEN 'ma10' THEN ma10
			WHEN 'ma20' THEN ma20
			WHEN 'ma60' THEN ma60
			WHEN 'ma120' THEN ma120
			WHEN 'ma240' THEN ma240
		END AS ma1,
		CASE @whichma2
			WHEN 'ma5' THEN ma5
			WHEN 'ma10' THEN ma10
			WHEN 'ma20' THEN ma20
			WHEN 'ma60' THEN ma60
			WHEN 'ma120' THEN ma120
			WHEN 'ma240' THEN ma240
		END AS ma2
	FROM historytop 
	WHERE stock_code = @company 
	ORDER BY date DESC;

OPEN cur;

FETCH NEXT FROM cur INTO @c, @MA1, @MA2;

WHILE @@FETCH_STATUS = 0
BEGIN 
	IF ( @MA1 > @MA2)
		SET @dailytrend = 1;
	ELSE IF ( @MA1 < @MA2)
		SET @dailytrend = -1;
	ELSE  
		SET @dailytrend = 0;
	IF (@Day = 0)
		SET @trend = @dailytrend;
	ELSE IF (@trend != @dailytrend)
		BREAK;
	SET @Day = @Day + 1;
	FETCH NEXT FROM cur INTO @c, @MA1, @MA2;
END;

IF (@trend = 1)
	SET @Result = @whichma1 +'Over '+ @whichma2 + ' ' + CONVERT(VARCHAR(10), @Day) + ' days';
ELSE IF (@trend = -1)
	SET @Result = @whichma1 +'Down '+ @whichma2 + ' ' + CONVERT(VARCHAR(10), @Day) + ' days';
ELSE 
	SET @Result = @whichma1 +'Consolidate'+ @whichma2 + ' ' + CONVERT(VARCHAR(10), @Day) + ' days';

CLOSE cur;
DEALLOCATE cur;

END
