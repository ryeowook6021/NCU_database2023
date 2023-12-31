USE [day2database]
GO
/****** Object:  UserDefinedFunction [dbo].[find_crossover_date]    Script Date: 2023/7/29 下午 02:51:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER FUNCTION [dbo].[find_crossover_date]
(
	@company varchar(10),
	@change_interval int
)
RETURNS @trend_tmp TABLE 
(
	date date not null,
	company varchar(10)　not null,
	MA_price real,
	close_price real not null,
	point_region int,
	crossover_point int,
	cur_trend int,
	counter int
)
AS
BEGIN
	insert @trend_tmp(date ,company,MA_price ,close_price)
	select date, stock_code,ma5,c
	from historytop
	where stock_code=@company
	order by date　asc

	update @trend_tmp
	set point_region=0
	where MA_price>close_price
	update @trend_tmp
	set point_region=1
	where MA_price<=close_price

	declare cur cursor local for 
		select date,company,point_region from @trend_tmp　order by date asc
	open cur
	declare @current_trend int,
			@DAY_change_count int,
			@date_tmp date,
			@company_tmp varchar(10),
			@point_region_tmp int
	fetch next from cur into @date_tmp,@company_tmp,@point_region_tmp

	set @current_trend=@point_region_tmp
	set @DAY_change_count=0
	while @@fetch_status=0 begin
		select @DAY_change_count=count(*)
		from @trend_tmp
		where point_region!=@current_trend  and date in (select date from find_dateoveryear(@date_tmp,@change_interval,1,1))

		if (@DAY_change_count>=@change_interval)
			begin 
				update @trend_tmp
				set crossover_point=1
				where date=@date_tmp  
				if (@current_trend=0)
					begin
						set @current_trend=1
					end
				else 
					begin
						set @current_trend=0
					end
			end
		update @trend_tmp
		set counter=@DAY_change_count,cur_trend=@current_trend
		where date=@date_tmp

	fetch next from cur into @date_tmp,@company_tmp,@point_region_tmp
	end 
	close cur
	DEALLOCATE cur	
	RETURN 
END