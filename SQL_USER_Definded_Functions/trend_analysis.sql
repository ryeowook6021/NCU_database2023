USE [day2database]
GO
/****** Object:  StoredProcedure [dbo].[trend_analysis]    Script Date: 2023/7/29 下午 02:43:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[trend_analysis]
	-- Add the parameters for the stored procedure here
	@company varchar(10),
	@Day int output,
	@Result char(50) output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @c real
	declare @MA5 real
	declare @MA10 real
	declare @MA20 real
	declare @trend int
	declare @dailytrend int	

	declare cur cursor local for 
	select c,MA5,MA10,MA20 from historytop where stock_code= @company order by date desc
	open cur

	fetch next from cur into @c,@MA5,@MA10,@MA20
	set @Day=0
	while @@FETCH_STATUS=0
	begin 
		if (@c >@MA5 and @MA5>@MA10 and @MA10>@MA20)
			set @dailytrend =1;
		else if (@c <@MA5 and @MA5<@MA10 and @MA10<@MA20)
			set @dailytrend =-1;
		else  
			set @dailytrend =0;
		if(@Day=0)
			set @trend=@dailytrend;
		else if (@trend !=@dailytrend)
			break;
		set @Day=@Day+1
		fetch next from cur into @c,@MA5,@MA10,@MA20
	end

	if (@trend=1)
		set @Result='Up trend';
	else if (@trend=-1)
		set @Result='Doen trend';
	else 
		set @Result='Consolidate';
	close cur
	deallocate cur

    
END
