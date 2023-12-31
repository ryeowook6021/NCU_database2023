USE [day2database]
GO
/****** Object:  StoredProcedure [dbo].[find_dayoveryearproceduredny_sql]    Script Date: 2023/7/29 下午 02:47:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

ALTER PROCEDURE [dbo].[find_dayoveryearproceduredny_sql] 
    @putdate DATE,
    @coutday INT,
    @inday INT,
    @forward INT

AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX), @params NVARCHAR(MAX);
    
    SET @sql = N'
        select * from find_dateoveryear(@putdate,@coutday,@inday,@forward) 
    ';
    SET @params = N'@putdate DATE, @coutday INT, @inday INT, @forward INT';
    
    EXEC sp_executesql @sql, @params, @putdate, @coutday, @inday, @forward;
END