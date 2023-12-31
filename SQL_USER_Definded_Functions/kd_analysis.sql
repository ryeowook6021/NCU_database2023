USE [day2database]
GO
/****** Object:  StoredProcedure [dbo].[kd_analy]    Script Date: 2023/7/29 下午 02:46:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[kd_analy]
	@inputstock_code varchar(10)
AS
BEGIN
	declare @date date,
			@sqltext nvarchar(1000),
			@parmdefinition nvarchar(500)
	select @date = max(date) from historytop
	declare @stock_code varchar(10),
			@i int,
			@id varchar(10),
			@yesterday_k  real,
			@yesterday_d  real,
			@today_k  real,
			@today_d real,
			@result int=0,
			@result_str nvarchar(50),
			@k_value REAL,
            @d_value REAL
	
	set @yesterday_k=50
	set @yesterday_d=50

	create table #stock_temp(
	id INT IDENTITY(1,1),
	stock_code varchar(10),
	date date not null,
	K_Value real not null,
	D_Value real not null
	) 

	create table #stock(
	stock_code varchar(10),
	date date not null,
	yesterday_k real not null,
	yesterday_d real not null,
	today_k real not null,
	today_d real not null,
	result_str nvarchar(50) not null
	) 

	
    DECLARE cur CURSOR LOCAL FOR SELECT  row_number() over(order by date asc)
	as id,stock_code,date, K_Value,D_Value FROM historytop 
	where stock_code=@inputstock_code
    OPEN cur

    FETCH NEXT FROM cur INTO @id, @stock_code, @date, @k_value, @d_value


    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @date_input date
                

        SET @sqltext = N'SELECT  row_number() over(order by date asc)
						as id, stock_code, date, K_Value, D_Value
						FROM dbo.historytop 
						WHERE date IN (SELECT date FROM find_dateoveryear(@date_input, 2, 0, 0)) and stock_code=@input
						ORDER BY date'

        SET @parmdefinition = N'@date_input date, @input varchar(10)' 

		DELETE FROM #stock_temp
		INSERT INTO #stock_temp (id ,stock_code, date, K_Value, D_Value)  EXEC sp_executesql @sqltext, @parmdefinition, @date_input = @date,@input=@inputstock_code

		SELECT TOP (1) @id = id, @inputstock_code = stock_code, @date = date, @yesterday_k = K_Value, @yesterday_d = D_Value FROM #stock_temp 
		DELETE #stock_temp WHERE id = (SELECT TOP 1 id FROM #stock_temp ORDER BY date)


        WHILE EXISTS (SELECT * FROM #stock_temp)
        BEGIN 
            SELECT TOP(1) @i=id,@inputstock_code=stock_code,@date = date, @today_k = K_Value, @today_d = D_Value FROM #stock_temp
        
            IF (@yesterday_k <= @yesterday_d and @today_k > @today_d)
                SET @result = 1
            ELSE IF (@yesterday_k >= @yesterday_d and @today_k < @today_d)
                SET @result = -1
            ELSE
                SET @result = 0

            IF (@result = 1)
                SET @result_str = '黃金交叉'
            ELSE IF (@result = -1)
                SET @result_str = '死亡交叉'
            ELSE
                SET @result_str = ''

            IF (@result <> 0)
            BEGIN 
                INSERT INTO #stock (stock_code, date, yesterday_k, yesterday_d, today_k, today_d, result_str)
                VALUES (@inputstock_code, @date, @yesterday_k, @yesterday_d, @today_k, @today_d, @result_str)
				break
			END

            SET @yesterday_k = @today_k
            SET @yesterday_d = @today_d 
            delete #stock_temp where id = (select top 1 id from #stock_temp order by date)
        END

        FETCH NEXT FROM cur INTO @id, @stock_code, @date, @k_value, @d_value

    END

    CLOSE cur
    DEALLOCATE cur
    SELECT * FROM #stock
END