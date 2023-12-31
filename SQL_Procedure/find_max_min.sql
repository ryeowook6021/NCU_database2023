USE [day2database]
GO
/****** Object:  UserDefinedFunction [dbo].[find_max_min]    Script Date: 2023/7/29 下午 02:51:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  FUNCTION [dbo].[find_max_min]
(	
	-- Add the parameters for the function here
	@company varchar(10)
)
RETURNS @max_min_tmp TABLE
(
	date date,
	close_price real Not null,
	max_min int Not null
)
AS
BEGIN
	declare @today_date date
	declare @today_c real
	declare @today_cross int
	declare @today_trend int
	declare @max_date date
	declare @max_c real
	declare @min_date date
	declare @min_c real
	declare @yesterday_trend int

	set @max_c = -1
	set @min_c = 1000000
	
	DECLARE cur CURSOR LOCAL for
		select date, close_price, crossover_point, cur_trend from find_crossover_date(@company, 1)
	
	open cur

	FETCH next from cur into @today_date, @today_c, @today_cross, @today_trend

	WHILE @@FETCH_STATUS = 0 BEGIN
		if(@today_cross = 1)
		begin
			if(@yesterday_trend = 1)
				insert @max_min_tmp values(@max_date, @max_c, 1)
			else
				insert @max_min_tmp values(@min_date, @min_c, 0)
			set @max_c = -1
			set @min_c = 1000000
		end

		if(@today_trend = 1)
		begin
			if(@today_c > @max_c)
			begin
				set @max_date = @today_date
				set @max_c = @today_c
			end
		end
		else
		begin
			if(@min_c > @today_c)
			begin
				set @min_date = @today_date
				set @min_c = @today_c
			end
		end

		set @yesterday_trend = @today_trend
		FETCH next from cur into @today_date, @today_c, @today_cross, @today_trend
	end

	close cur
	return

end
