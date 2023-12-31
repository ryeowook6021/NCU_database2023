USE [day2database]
GO
/****** Object:  UserDefinedFunction [dbo].[GB_rule1_5]    Script Date: 2023/7/29 下午 02:48:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER FUNCTION [dbo].[GB_rule1_5]
(
	@company varchar(10)
)
RETURNS @GB_rule1_table TABLE
(
	company varchar(10),
	date date,
	yesterday_c real,
	today_c	 real,
	yesterday_MA real,
	today_MA real, 
	trend INT,
	buy_or_sell int
)
AS
BEGIN
	DECLARE @result_table TABLE (company varchar(10),date date,yesterday_c real,today_c	 real,yesterday_MA real,today_MA real, trend INT)
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
		@buy_or_sell int

	set  @prev_trend=0

	DECLARE cur CURSOR FOR
		SELECT date, trend, yesterday_c, today_c, yesterday_MA, today_MA
		FROM @result_table
		ORDER BY date ASC

		OPEN cur

		FETCH NEXT FROM cur INTO @date, @trend, @yesterday_c, @today_c, @yesterday_MA, @today_MA
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF (@prev_trend=-1) AND (@trend >= 0) AND (@today_c > @today_MA)
			BEGIN
				set @buy_or_sell =1
				INSERT INTO @GB_rule1_table(company,date ,yesterday_c,today_c,yesterday_MA,today_MA,trend,buy_or_sell)
				VALUES (@company,@date,@yesterday_c,@today_c, @yesterday_MA,@today_MA,@trend,@buy_or_sell)					
			END
			else if (@prev_trend=1) AND (@trend <= 0) AND (@today_c < @today_MA)
			BEGIN
				set @buy_or_sell =-1
				INSERT INTO @GB_rule1_table(company,date ,yesterday_c,today_c,yesterday_MA,today_MA,trend,buy_or_sell)
				VALUES (@company,@date,@yesterday_c,@today_c, @yesterday_MA,@today_MA,@trend,@buy_or_sell)					
			END

			SET @prev_trend = @trend
			FETCH NEXT FROM cur INTO @date, @trend, @yesterday_c, @today_c, @yesterday_MA, @today_MA
			end
				CLOSE cur
				DEALLOCATE cur

	
		return
END