USE [day2database]
GO
/****** Object:  UserDefinedFunction [dbo].[candlestick_up_down1]    Script Date: 2023/7/29 下午 02:52:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER FUNCTION [dbo].[candlestick_up_down1]
(	
	@company VARCHAR(10),
    @date VARCHAR(10)
)
RETURNS @result_table TABLE (
        company VARCHAR(10),
        date VARCHAR(10),
        up_down INT
    )
AS
BEGIN
    DECLARE @today_o REAL, @today_c REAL, @today_h REAL, @today_l REAL
    DECLARE @last_working_date date
    DECLARE @yesterday_o REAL, @yesterday_c REAL, @yesterday_h REAL, @yesterday_l REAL
    DECLARE @up_down INT

    SET @up_down = 99 -- initialiaztion

    -- get data of today
    SELECT @today_o = o, @today_c = c, @today_h = h, @today_l = l
    FROM historytop
    WHERE stock_code = @company AND date = @date

    -- get last working day
    SELECT @last_working_date = date
    FROM find_last_date(@date)

    -- get data of yesterday (last working day)
    SELECT @yesterday_o = o, @yesterday_c = c, @yesterday_h = h, @yesterday_l = l
    FROM historytop
    WHERE stock_code = @company AND date = @last_working_date

    -- there's no data of yesterday
    IF @yesterday_o IS NULL
    BEGIN
        INSERT INTO @result_table
        SELECT @company, @date, @up_down
        
        RETURN
    END
	IF @today_l > @yesterday_h 
    BEGIN
        SET @up_down = 3
    END
   
    ELSE IF @today_h < @yesterday_l
    BEGIN
        SET @up_down = -3
    END
    
    -- 完全上漲: 2
    ELSE IF @today_o > @yesterday_o AND @today_c > @yesterday_c AND @today_h > @yesterday_h AND @today_l > @yesterday_l
    BEGIN
        SET @up_down = 2
    END
    -- 完全下跌: -2
    ELSE IF @today_o < @yesterday_o AND @today_c < @yesterday_c AND @today_h < @yesterday_h AND @today_l < @yesterday_l
    BEGIN
        SET @up_down = -2
    END
    -- 上漲: 1
    ELSE IF @today_c > @yesterday_c
    BEGIN
        SET @up_down = 1
    END
    -- 下跌: -1
    ELSE IF @today_c < @yesterday_c
    BEGIN
        SET @up_down = -1
    END
    -- 一樣: 0
    ELSE IF @today_c = @yesterday_c
    BEGIN
        SET @up_down = 0
    END


    INSERT INTO @result_table
    SELECT @company, @date, @up_down
    

    RETURN
END