USE [day2database]
GO
/****** Object:  StoredProcedure [dbo].[find_dayupprocedure3]    Script Date: 2023/7/29 下午 02:47:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[find_dayupprocedure3]
	-- Add the parameters for the stored procedure here
	@putdate date,
	@coutday int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select stock_code 
	from (
		select * from find_dayup1(@putdate, @coutday) 
	) result
	where result.Days >= @coutday
END
