USE [day2database]
GO
/****** Object:  UserDefinedFunction [dbo].[GB_rule3_7]    Script Date: 2023/7/29 下午 02:49:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER FUNCTION [dbo].[GB_rule3_7]
(
	@company varchar(10),
		@statevalue REAL,
		@forwardday int,
		@forwardstatevalue REAL,
		@backday int,
		@backstatevalue REAL
)
RETURNS @GB_rule3_7_table TABLE
(
	company varchar(10),
	date date,
	yesterday_c REAL ,
	today_c REAL ,
	yesterday_MA REAL ,
	today_MA REAL ,
	trend INT,
	todaystatevalue real,
	buy_or_sell int

)
AS
BEGIN
	DECLARE @result_table TABLE (company varchar(10),date date,yesterday_c REAL ,today_c REAL ,yesterday_MA REAL ,today_MA REAL ,trend INT,todaystatevalue real,buy_or_sell int)
	DECLARE @result_table1 TABLE (company varchar(10),date date,yesterday_c REAL ,today_c REAL ,yesterday_MA REAL ,today_MA REAL ,trend INT,todaystatevalue real,buy_or_sell int)
	DECLARE @result_table2 TABLE (company varchar(10),date date,yesterday_c REAL ,today_c REAL ,yesterday_MA REAL ,today_MA REAL ,trend INT,todaystatevalue real,buy_or_sell int)
	
	INSERT INTO @result_table(company,date,yesterday_c ,today_c,yesterday_MA ,today_MA, trend ,todaystatevalue,buy_or_sell)
	SELECT stock_code, date, LAG(c) OVER (PARTITION BY stock_code ORDER BY date) AS yesterday_c,c, LAG(ma20) OVER (PARTITION BY stock_code ORDER BY date) AS yesterday_MA, ma20,null,null,0
	FROM historytop
	WHERE stock_code = '2330'
	ORDER BY date ASC

	UPDATE g
	SET trend = m.trend
	FROM @result_table g
	INNER JOIN (
		SELECT company, date, trend
		FROM dbo.find_MA_updown('2330', 8, 6)
		) m ON g.company = m.company AND g.date = m.date;

	UPDATE @result_table
	SET todaystatevalue = ((today_c-today_MA )/today_MA)*100;

	
	DECLARE @date date, 
		@trend int , 
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
		@todaystatevalue real,
		@analyzeforward real,
		@analyzeback real,
		@todaystatevalue1 real,
		@forwardday1 int,
		@backday1 int,
		@count INT
		



	DECLARE cur CURSOR FOR
		SELECT company,date,yesterday_c ,today_c,yesterday_MA ,today_MA, trend ,todaystatevalue ,buy_or_sell			
		FROM @result_table
		ORDER BY date ASC

		OPEN cur

		FETCH NEXT FROM cur INTO @company,@date,@yesterday_c,@today_c, @yesterday_MA,@today_MA,@trend,@todaystatevalue,@buy_or_sell				


		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @trend=1 and abs(@todaystatevalue) < @statevalue
			begin
				DELETE FROM @result_table1
				INSERT INTO @result_table1(company,date,yesterday_c ,today_c,yesterday_MA ,today_MA, trend ,todaystatevalue,buy_or_sell)
				SELECT company, date, yesterday_c ,today_c,yesterday_MA ,today_MA, trend,todaystatevalue,0
				FROM @result_table
				WHERE date IN (SELECT date FROM find_dateoveryear(@date, @forwardday, 0, 0)) 
				ORDER BY date ASC

				SET @count = (SELECT COUNT(*) FROM @result_table1 WHERE (((today_c-@today_c)/@today_c)*100)> @forwardstatevalue )
 

				IF @count > 0　
					BEGIN
					DELETE FROM @result_table1
					INSERT INTO @result_table1(company,date,yesterday_c ,today_c,yesterday_MA ,today_MA, trend ,todaystatevalue,buy_or_sell)
					SELECT company, date, yesterday_c ,today_c,yesterday_MA ,today_MA, trend,todaystatevalue,0
					FROM @result_table
					WHERE date IN (SELECT date FROM find_dateoveryear(@date, @backday, 1, 1))
					ORDER BY date ASC
					SET @count = (SELECT COUNT(*) FROM @result_table1 WHERE (((today_c-@today_c)/@today_c)*100)> @backstatevalue)
					IF @count > 0 and NOT EXISTS (SELECT *　FROM @result_table1　WHERE todaystatevalue<=0)
							BEGIN
							INSERT INTO @GB_rule3_7_table (company,date,yesterday_c ,today_c,yesterday_MA ,today_MA, trend ,todaystatevalue ,buy_or_sell)
							SELECT TOP 1 company, date, yesterday_c ,today_c, yesterday_MA ,today_MA, trend, todaystatevalue, 1
							FROM @result_table1
							WHERE  (((today_c-@today_c)/@today_c)*100)> @backstatevalue  and  date NOT IN (SELECT date FROM @GB_rule3_7_table) and company=@company 
							ORDER BY date ASC
							DELETE FROM @result_table1
					END
				END
			END
			else if  @trend=-1 and abs(@todaystatevalue) < @statevalue
			begin
				DELETE FROM @result_table1
				INSERT INTO @result_table1(company,date,yesterday_c ,today_c,yesterday_MA ,today_MA, trend ,todaystatevalue,buy_or_sell)
				SELECT company, date, yesterday_c ,today_c,yesterday_MA ,today_MA, trend,todaystatevalue,0
				FROM @result_table
				WHERE date IN (SELECT date FROM find_dateoveryear(@date, @forwardday, 0, 0))   
				ORDER BY date ASC

				SET @count = (SELECT COUNT(*) FROM @result_table1 WHERE (((@today_c-today_c)/@today_c)*100)> @forwardstatevalue )

				IF  @count > 0　
					BEGIN
					DELETE FROM @result_table1

					INSERT INTO @result_table1(company,date,yesterday_c ,today_c,yesterday_MA ,today_MA, trend ,todaystatevalue,buy_or_sell)
					SELECT company, date, yesterday_c ,today_c,yesterday_MA ,today_MA, trend,todaystatevalue,0
					FROM @result_table
					WHERE date IN (SELECT date FROM find_dateoveryear(@date, @backday, 0, 1))
					ORDER BY date ASC
					SET @count = (SELECT COUNT(*) FROM @result_table1 WHERE (((@today_c-today_c)/@today_c)*100)> @backstatevalue)
					IF @count > 0 and NOT EXISTS (SELECT *FROM @result_table1　where todaystatevalue>=0 )
							BEGIN
							INSERT INTO @GB_rule3_7_table (company,date,yesterday_c ,today_c,yesterday_MA ,today_MA, trend ,todaystatevalue ,buy_or_sell)
							SELECT TOP 1 company, date, yesterday_c ,today_c, yesterday_MA ,today_MA, trend, todaystatevalue, -1
							FROM @result_table1
							WHERE (((@today_c-today_c)/@today_c)*100)> @backstatevalue and  date NOT IN (SELECT date FROM @GB_rule3_7_table)  
							ORDER BY date ASC
							DELETE FROM @result_table1
					
					END
				END
			END

		FETCH NEXT FROM cur INTO @company,@date,@yesterday_c,@today_c, @yesterday_MA,@today_MA,@trend,@todaystatevalue,@buy_or_sell				
			END	
				CLOSE cur
				DEALLOCATE cur			
	RETURN 
	
END