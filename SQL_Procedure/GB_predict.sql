USE [day2database]
GO
/****** Object:  UserDefinedFunction [dbo].[GB_Predict]    Script Date: 2023/7/29 下午 02:49:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER  FUNCTION [dbo].[GB_Predict] 
(	
	-- Add the parameters for the function here
	@company varchar(10),
	@money real,
	@start_date date
)
RETURNS @tmp_table TABLE 
(
	-- 交易日期
	date date,
	-- 交易日期之收盤價
	price real,
	-- 買or賣
	buy_or_sell int,
	-- 持有股數
	stock_num int,
	-- 手頭現金
	money int,
	-- 資產總值
	total_value int
)
begin
	
	declare @trade_date date
	declare @close_price real
	declare @buy_or_sell int
	declare @stock_num int
	set @stock_num = 0

	declare @trade_day as table(
		date date,
		buy_or_sell int
	)
	
	-- 取兩個指標篩選出來之交易日的交集認定為交易日
	insert into @trade_day select * from GB_UPBREAK(@company) intersect select date, buy_or_sell from GB_KD(@company)
	
	-- Join 歷史股價和交易日
	declare cur cursor local for
		select a.date, c, buy_or_sell from historytop as a join @trade_day as b on a.date = b.date and a.stock_code = @company and a.date > @start_date
	open cur

	-- 將開始的日期後的第一個工作日和現有資產放入暫存表
	insert into @tmp_table select @start_date, c, 0, 0, @money, @money from historytop where stock_code=@company and date in (select * from find_last_date(@start_date))

	fetch next from cur into @trade_date, @close_price, @buy_or_sell

	WHILE @@FETCH_STATUS = 0 BEGIN
		-- 每次買入都買入1000股，如果錢不足以買1000股則買到現在可以買的極限股數
		if(@buy_or_sell = 1)
		begin
			if(@money >= 1000 * @close_price)
			begin
				set @money = @money - @close_price * 1000
				set @stock_num = @stock_num + 1000
			end
			else if(@money > 0)
			begin
				set @stock_num = @stock_num + (@money/@close_price)
				set @money = @money - (@money/@close_price)*@close_price
			end
			insert into @tmp_table values (@trade_date, @close_price, @buy_or_sell, @stock_num, @money, @money+@stock_num*@close_price)
		end
		-- 每次賣出都賣出1000股，如果股數不足以賣到1000股則賣出手頭全部的股票
		else
		begin
			if(@stock_num >= 1000)
			begin
				set @money = @money + @close_price * 1000
				set @stock_num = @stock_num - 1000
			end
			else if(@stock_num > 0)
			begin
				set @money = @money + @stock_num*@close_price
				set @stock_num = 0
			end
			insert into @tmp_table values (@trade_date, @close_price, @buy_or_sell, @stock_num, @money, @money+@stock_num*@close_price)
		end

		fetch next from cur into @trade_date, @close_price, @buy_or_sell
	end

	return
end
