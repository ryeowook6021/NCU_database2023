USE [day2database]
GO
/****** Object:  StoredProcedure [dbo].[kd_value]    Script Date: 2023/7/29 下午 02:45:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[kd_value]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	declare @K_Value float,
			@D_Value float,
			@today_c float,
			@rsi real,
			@row_number int,
			@stock_code varchar(100),
			@date date,
			@yesterday_k float,
			@yesterday_d float
	set @yesterday_k=50
	set @yesterday_d=50
    -- Insert statements for procedure here
	declare cur cursor for
	select row_number() over (partition by stock_code order by date asc )
	as row_id,stock_code,date,c from historytop
	open cur

	fetch next from cur into @row_number,@stock_code,@date,@today_c
	while @@fetch_status =0
	begin
	SET NOCOUNT ON;
	if (@row_number=1)
	begin 
		set @yesterday_k =50
		set @yesterday_d=50
	end

	select @rsi=(@today_c-min([l]))/(max(h)-min([l]))*100
	from historytop
	where stock_code =@stock_code and date in (select date from find_dateoveryear(@date,9,1,0))
	group by stock_code

	set @K_Value =(2/3.0)*@yesterday_k+(1/3.0)*@rsi
	set	@D_Value =(2/3.0)*@yesterday_d +(1/3.0)*@K_Value
	update historytop
	set K_Value=@K_Value,D_Value=@D_Value
	where stock_code =@stock_code and date=@date
	set @yesterday_k=@K_Value
	set @yesterday_d=@D_Value
	fetch next from cur into  @row_number,@stock_code,@date,@today_c
	end
	close cur
	deallocate cur
	
END
