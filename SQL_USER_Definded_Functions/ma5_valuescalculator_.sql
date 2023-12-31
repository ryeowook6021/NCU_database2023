USE [day2database]
GO
/****** Object:  StoredProcedure [dbo].[ma5_calculator1]    Script Date: 2023/7/29 下午 02:44:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[ma5_calculator1]
	-- Add the parameters for the stored procedure here
	@date char(10),
	@stock_code varchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   declare @ma5 real
    -- Insert statements for procedure here
	SELECT @ma5=avg([c])
	from historytop
	where date in (select date from find_dateoveryear(@date,5,1,0)) and stock_code =@stock_code

	update historytop
	set MA5=@ma5
	where date =@date and stock_code =@stock_code
END
