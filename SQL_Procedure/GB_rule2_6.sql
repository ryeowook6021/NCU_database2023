USE [day2database]
GO
/****** Object:  UserDefinedFunction [dbo].[GB_rule2_6]    Script Date: 2023/7/29 下午 02:48:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER FUNCTION [dbo].[GB_rule2_6] 
(
	@company varchar(10),
	@day int
)
RETURNS @GB_rule2_6_table TABLE
(
	company varchar(10),
	date date,
	yesterday_c real,
	today_c	 real ,
	yesterday_MA real ,
	today_MA real,
	trend INT,
	buy_or_sell int
)
AS
BEGIN
	DECLARE @result_table TABLE (company varchar(10),date date,yesterday_c real,today_c	 real,yesterday_MA real,today_MA real, trend INT)
	DECLARE @result_table1 TABLE (company varchar(10),date date,yesterday_c real,today_c	 real,yesterday_MA real,today_MA real, trend INT)
	INSERT INTO @result_table(company,date ,yesterday_c,today_c,yesterday_MA,today_MA,trend)
	SELECT stock_code, date, LAG(c) OVER (PARTITION BY stock_code ORDER BY date) AS yesterday_c,c, LAG(ma20) OVER (PARTITION BY stock_code ORDER BY date) AS yesterday_MA, ma20,null
	FROM historytop
	WHERE stock_code = @company 
	ORDER BY date DESC

	UPDATE g
	SET trend = m.trend
	FROM @result_table g
	INNER JOIN (
		SELECT company, date, trend
		FROM dbo.find_MA_updown(@company, 8, 6)
		) m ON g.company = m.company AND g.date = m.date;

	
	DECLARE @date date, 
		@trend int , 
		@prev_trend int ,
		@yesterday_c real,
		@today_c	 real ,
		@yesterday_MA real ,
		@today_MA real,
		@buy_or_sell int,
		@upordown_ma  real,
		@upordown_c real,
		@date_exist int,
		@company1 varchar(10) ,
		@date1 date ,
		@yesupordown_ma  real,
		@yesupordown_c real, 
		@yestrend int,
		@count INT



	DECLARE cur CURSOR FOR
		SELECT date, trend, yesterday_c, today_c, yesterday_MA, today_MA
		FROM @result_table
		ORDER BY date ASC

		OPEN cur

		FETCH NEXT FROM cur INTO @date, @trend, @yesterday_c, @today_c, @yesterday_MA, @today_MA
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF  @trend = 1 AND (@today_c < @today_MA)
			BEGIN		
			DELETE FROM @result_table1
			INSERT INTO @result_table1(company,date ,yesterday_c ,today_c,yesterday_MA ,today_MA,trend)
			SELECT company ,date ,yesterday_c ,today_c,yesterday_MA ,today_MA,trend
				from @result_table
				where date in (select date from find_dateoveryear(@date, @day, 1, 1)) and company=@company
			ORDER BY date DESC
			SET @count = (SELECT COUNT(*) FROM @result_table1 WHERE today_c> today_MA )

			IF @count > 0　
				BEGIN
				INSERT INTO @GB_rule2_6_table(company,date,yesterday_c,today_c,yesterday_MA,today_MA,trend,buy_or_sell)
					SELECT TOP 1 company, date, yesterday_c ,today_c, yesterday_MA ,today_MA, trend, 1
					FROM @result_table1
					WHERE today_c　> today_MA and  date NOT IN (SELECT date FROM  @GB_rule2_6_table) and trend=1
					ORDER BY date ASC
				end
			end
			else if  @trend = -1 AND (@today_c > @today_MA)
			BEGIN		
			DELETE FROM @result_table1
			INSERT INTO @result_table1(company,date ,yesterday_c ,today_c,yesterday_MA ,today_MA,trend)
			SELECT company ,date ,yesterday_c ,today_c,yesterday_MA ,today_MA,trend
				from @result_table
				where date in (select date from find_dateoveryear(@date, @day, 1, 1)) and company=@company
			ORDER BY date DESC
			SET @count = (SELECT COUNT(*) FROM @result_table1 WHERE today_c < today_MA )

			IF @count > 0　
				BEGIN
				INSERT INTO @GB_rule2_6_table(company,date,yesterday_c,today_c,yesterday_MA,today_MA,trend,buy_or_sell)
					SELECT TOP 1 company, date, yesterday_c ,today_c, yesterday_MA ,today_MA, trend, 1
					FROM @result_table1
					WHERE today_c < today_MA and  date NOT IN (SELECT date FROM  @GB_rule2_6_table) and trend=-1
					ORDER BY date ASC
				end
			end
			
		
		

			FETCH NEXT FROM cur INTO @date, @trend, @yesterday_c, @today_c, @yesterday_MA, @today_MA
			end
				CLOSE cur
				DEALLOCATE cur

	
	RETURN 
END
