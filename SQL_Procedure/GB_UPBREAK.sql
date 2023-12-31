USE [day2database]
GO
/****** Object:  UserDefinedFunction [dbo].[GB_UPBREAK]    Script Date: 2023/7/29 下午 02:51:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[GB_UPBREAK]
(
	@company varchar(10)
)
RETURNS @tmp TABLE
(
	date DATE,
    buy_or_sell INT
)
AS
BEGIN
	DECLARE @stock_temp TABLE (stock_code varchar(10),date date not null,yesterdayma5 real,ma5 real,yesterdayma10 real,ma10 real,yesterdayma20 real,ma20 real ,yesterdayma60 real,ma60 real ,yesterdayma120 real ,ma120 real ,yesterdayma240 real ,ma240 real,trend int,buy_or_sell int)
	declare @stock table(
		stock_code varchar(10),
		date date not null,
		result_str nvarchar(50) not null,
		trend int,
		buy_or_sell int
	)
	declare @date date,
			@result_str nvarchar(50),
			@buy_or_sell int,
			@trend int,
			@yesterdayma5 real ,
			@ma5 real,
			@yesterdayma10 real,
			@ma10 real,
			@yesterdayma20 real,
			@ma20 real,
			@yesterdayma60 real,
			@ma60 real,
			@yesterdayma120 real,
			@ma120 real,
			@yesterdayma240 real,
			@ma240 real,
			@stock_code varchar(10)
	--我是先插入資料與更新資料表的資料
	INSERT INTO @stock_temp(stock_code,date,yesterdayma5 ,ma5,yesterdayma10,ma10,yesterdayma20,ma20,yesterdayma60,ma60,yesterdayma120,ma120,yesterdayma240,ma240,trend,buy_or_sell)
	SELECT stock_code, date, LAG(ma5)over (order by date asc) AS yesterdayma5,ma5, LAG(ma10) over (order by date asc) AS yesterdayma10, ma10, 
			LAG(ma20) over (order by date asc) AS yesterdayma20, ma20, LAG(ma60) over (order by date asc) AS yesterdayma60, ma60, 
			LAG(ma120) over (order by date asc) AS yesterdayma120, ma120, LAG(ma240) over (order by date asc) AS yesterdayma240, ma240,null,0
	FROM historytop where stock_code = @company
	ORDER BY date ASC
	UPDATE g
			SET trend = m.trend
			FROM  @stock_temp g
			INNER JOIN (
				SELECT company, date, trend
				FROM dbo.find_MA_updown(@company, 8, 6)
			) m ON g.stock_code = m.company AND g.date = m.date;

	DECLARE cur CURSOR FOR
		SELECT stock_code,date,yesterdayma5 ,ma5,yesterdayma10,ma10,yesterdayma20,ma20,yesterdayma60,ma60,yesterdayma120,ma120,yesterdayma240,ma240,trend,buy_or_sell	
		FROM @stock_temp
		ORDER BY stock_code,date ASC

	open cur
	fetch next from cur into @stock_code,@date,@yesterdayma5 ,@ma5,@yesterdayma10,@ma10,@yesterdayma20,@ma20,@yesterdayma60,@ma60,@yesterdayma120,@ma120,@yesterdayma240,@ma240,@trend,@buy_or_sell	
		
	while @@FETCH_STATUS=0
	begin
	--判斷的標準因為如果全部的ma線全看，符合所有條件的資料是0個，所以我就用5天(ma5).兩個月(ma60)的來比較
	----符合趨勢上升且有5天均線(ma5)突破兩個月(ma60)均線材是黃金交叉
	if @trend=1 and (@yesterdayma5<@yesterdayma60 and @ma5>@ma60 )
		begin
		INSERT INTO  @stock(stock_code,date,result_str,trend,buy_or_sell) 
		SELECT stock_code, date, '黃金交叉', trend,1
		FROM @stock_temp AS T
		WHERE @date=date and @stock_code=stock_code and NOT EXISTS (
            SELECT 1 FROM @stock WHERE stock_code = T.stock_code AND date = T.date
        )
		ORDER BY date ASC
		DELETE TOP(1) FROM @stock_temp
		end
----符合趨勢下降且有5天均線(ma5)跌破兩個月(ma60)均線材是黃金交叉
	else if @trend=-1 and(@yesterdayma5>@yesterdayma60 and @ma5<@ma60)
		begin
		INSERT INTO  @stock(stock_code,date,result_str,trend,buy_or_sell) 
		SELECT stock_code, date, '死亡交叉', trend,-1
		FROM  @stock_temp  AS T
		WHERE @date=date and @stock_code=stock_code and NOT EXISTS (
            SELECT 1 FROM @stock WHERE stock_code = T.stock_code AND date = T.date
        )
		ORDER BY date ASC
		DELETE TOP(1) FROM @stock_temp
		end
	else 
		DELETE TOP(1) FROM @stock_temp
	fetch next from cur into @stock_code,@date,@yesterdayma5,@ma5,@yesterdayma10,@ma10,@yesterdayma20,@ma20,@yesterdayma60,@ma60,@yesterdayma120,@ma120,@yesterdayma240,@ma240,@trend,@buy_or_sell	
	end
	close cur
	deallocate cur

	--我想要把資料插入表格資，先新增資料表
	--接著插入資料，我是先把判斷黃金交叉死亡交叉還有GB_rule2_6假突破、跌破的資料先做交集，接著把1.3.4.5.7.8的結果聯集
	INSERT INTO @tmp (date, buy_or_sell)
		SELECT t.date, t.buy_or_sell
		FROM ( SELECT company, date, buy_or_sell FROM GB_rule2_6(@company, 5)) AS t

		JOIN ( SELECT stock_code, date, buy_or_sell FROM @stock) AS u 
		ON t.company = u.stock_code AND t.date = u.date AND t.buy_or_sell = u.buy_or_sell

		UNION ALL SELECT date, buy_or_sell FROM GB_rule1_5(@company)

		UNION ALL SELECT date, buy_or_sell FROM GB_rule3_7(@company, 2, 8, 3, 5, 3)

		UNION ALL SELECT date, buy_or_sell FROM GB_rule4_8(@company, 15, -10) ORDER BY date ASC

	RETURN 
END