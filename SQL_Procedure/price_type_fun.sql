USE [day2database]
GO
/****** Object:  UserDefinedFunction [dbo].[price_type_fun]    Script Date: 2023/7/29 下午 02:50:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[price_type_fun](
    @company_input VARCHAR(10),
    @settings_days INT,
    @setting_date DATE
)
Returns @price_type TABLE(
    High_low INT
)
AS
BEGIN


DECLARE @stock_temp as TABLE(
    company_temp VARCHAR(10),
    date_temp DATE,
    c_temp BIGINT
)

DECLARE @IsWorkingDay INT
DECLARE @High_def FLOAT
DECLARE @Low_def FLOAT
DECLARE @type INT

SET @type = 99

SELECT @IsWorkingDay = day_of_stock from dbo.calendar where date = @setting_date;
IF(@IsWorkingDay = -1) RETURN;

SELECT @High_def = high, @Low_def = low from dbo.table_tradingPrice_def WHERE compare_with = @settings_days

INSERT INTO @stock_temp(company_temp, date_temp, c_temp) SELECT top(@settings_days) stock_code, date, c from historytop where stock_code = @company_input and date <= @setting_date order by date desc


DECLARE @temp INT
SELECT @temp = ROWID from
(SELECT ROW_NUMBER() OVER(ORDER BY c_temp desc) AS  ROWID,*from @stock_temp) T1
where T1.date_temp = @setting_date

if(@temp <= @settings_days*@High_def)
    set @type = 1;
else if(@temp >= @settings_days - (@settings_days*@Low_def))
    set @type = -1
ELSE
    set @type = 0
INSERT into @price_type(High_low) select @type

return

END
