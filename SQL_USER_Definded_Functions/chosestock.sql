USE [day2database]
GO
/****** Object:  StoredProcedure [dbo].[chosestock]    Script Date: 2023/7/29 下午 02:47:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[chosestock]
	@ma1 varchar(50),
	@ma2 varchar(50),
	@trend int,
	@day int
AS
BEGIN
	declare @date date,
			@id varchar(10),
			@sqltext nvarchar(1000),
			@parmdefinition nvarchar(500)
	select @date = max(date) from historytop
	declare @stock_code varchar(10),
			@i int,
			@ma1_value  real,
			@ma2_value  real,
			@ma1_prevalue  real,
			@ma2_prevalue  real
	create table #stock_temp(
	id int identity(1,1),
	date date not null,
	stock_code varchar(10) not null,
	ma_1 real not null,
	ma_2 real not null
	) 

	create table #stock(
	stock_code varchar(10)

	) 

	declare cur cursor local for 
	select distinct stock_code from historytop

	open cur
	fetch next from cur into @id
	while @@FETCH_STATUS=0
	begin
	declare @date_input date,
			@duration_input int,
			@id_input varchar(10)
	set @sqltext=N'SELECT date, stock_code, '+@ma1+', '+@ma2+
	' from dbo.historytop where date in (select date from find_dateoveryear(@date_input, @duration_input, 0, 0))
	and stock_code=@id_input order by date';
	set @parmdefinition=N'@date_input date, @duration_input int, @id_input varchar(10)';

	delete from #stock_temp
	insert #stock_temp exec sp_executesql @sqltext ,@parmdefinition, @date_input=@date, @duration_input=@day, @id_input=@id
	select top(1) @i=id,@ma1_prevalue=ma_1,@ma2_prevalue=ma_2 from #stock_temp
	delete #stock_temp where id=@i

	while exists (select * from #stock_temp)
	begin 
		select top(1) @i=id,@stock_code=stock_code, @ma1_value=ma_1,@ma2_value=ma_2 from #stock_temp
		if (@trend=1 and @ma1_prevalue <@ma2_prevalue and @ma1_value>@ma2_value)
		begin 
			
			insert into #stock(stock_code)
			values (@stock_code)
			break
		end

		set @ma1_prevalue =@ma1_value 
		set @ma2_prevalue =@ma2_value 
		delete #stock_temp where id=@i
	end

	fetch next from cur into @id
	end
	close cur
	deallocate cur
	select * from #stock
END