USE MASTER
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE DBO.SEARCH_OBJECT
(
    @SEARCH_PROC VARCHAR(50) = NULL,
    @SEARCH_PROC_FLAG BIT = NULL,
    @SP_HELPTEXT_FLAG BIT = NULL,
    @SEARCH_TABLE VARCHAR(50) = NULL,
    @SEARCH_TABLE_FLAG BIT = NULL,
    @QUERY_TABLE_FLAG BIT = NULL,
    @QUERY_TABLE_STRUCTURE BIT = NULL
)
/*************************************************************************************************************************
* Author: Pankaj Dwivedi                                                                                                 *
* Description: This script will be used to search procedure or table name in all databases.                              *
* Use case:When you have multiple databases and you are not sure about a procedure that in which database it is residing.*
**************************************************************************************************************************
*/

AS

DECLARE COUNTER1 INT,COUNTER2 INT
DECLARE @NAME VARCHAR(50)
DECLARE @SQL NVARCHAR(MAX)
DECLARE @SQL2 NVARCHAR(MAX)

BEGIN TRY
IF (@SEARCH_PROC IS NULL AND @SEARCH_TABLE IS NULL)
BEGIN
    RAISERROR('PROCESS FAILED! PASS ATLEAST ONE OBJECT TO SEARCH',11,1)
END

IF(@SEARCH_PROC IS NOT NULL AND @SEARCH_TABLE IS NOT NULL)
BEGIN
    RAISERROR('PROCESS FAILED! SEARCH TABLE FLAG IS NULL',11,1)
END

IF(@SEARCH_PROC IS NOT NULL AND (@SEARCH_TABLE_FLAG IS NOT NULL OR @QUERY_TABLE_STRUCTURE IS NOT NULL))
BEGIN
    RAISERROR('PROCESS FAILED! SEARCHING PROC WITH PARAMETERS TABLE FLAG OR TABLE STRUCTURE NOT ALLOWED.',11,1)
END

IF(@SEARCH_TABLE IS NOT NULL AND (@SEARCH_PROC_FLAG IS NOT NULL OR @SP_HELPTEXT_FLAG IS NOT NULL))
BEGIN
    RAISERROR('PROCESS FAILED! SEARCHING PROC WITH PARAMETERS TABLE FLAG OR TABLE STRUCTURE NOT ALLOWED.',11,1)
END

IF(@SEARCH_PROC IS NOT NULL AND @SEARCH_PROC_FLAG IS NULL)
BEGIN
    RAISERROR('PROCESS FAILED! SEARCH PROC FLAG IS NULL.',11,1)
END

CREATE TABLE #RESULTS
(OBJ_NAME VARCHAR(50),NAME VARCHAR(50),TYPE_DES VARCHAR(50),CREATE_DATE DATETIME,MODIFY_DATE DATETIME)

SELECT @COUNTER1 = MIN(database_id),@COUNTER2 = MAX(database_id) from sys.databases
WHILE(@COUNTER1 <= @COUNTER2)
BEGIN
    SET @NAME = (SELECT name FROM sys.databases WHERE database_id = @COUNTER1)
        BEGIN
            IF(@SEARCH_PROC_FLAG = 1 AND (@SEARCH_TABLE_FLAG = 0 OR @SEARCH_TABLE_FLAG IS NULL))
            BEGIN
                SET @SQL = 'use '+@NAME+' '+'insert into #RESULTS select DB_NAME() as DB,name,type_desc,create_date,modify_date from sys.procedures where name like ''%'+@SEARCH_PROC+'%'''
            END
            ELSE IF(@SEARCH_TABLE_FLAG = 1 AND (@SEARCH_PROC_FLAG = 0 OR @SEARCH_PROC_FLAG IS NULL))
            BEGIN
                SET @SQL = 'use '+@NAME+' '+'insert into #RESULTS select DB_NAME() as DB,name,type_desc,create_date,modify_date from sys.procedures where name like ''%'+@SEARCH_TABLE+'%'''
            END
            ELSE
            BEGIN
                RETURN -1
            END
        EXECUTE sp_executesql @SQL
        END
SET @COUNTER1 = @COUNTER1 + 1
END


SELECT * FROM #RESULTS

IF @QUERY_TABLE_STRUCTURE = 1
BEGIN
    SELECT TOP 1 @NAME = OBJ_NAME from #RESULTS
    SELECT TOP 1 @SEARCH_TABLE = NAME FROM #RESULTS
    SET @SQL2 = 'exec '+@NAME+'.dbo.sp_help '+@SEARCH_TABLE
    SELECT '********************TABLE DESCRIPTION*************************'
    EXECUTE sp_executesql @SQL2
END

IF(@SP_HELPTEXT_FLAG = 1 AND (@QUERY_TABLE_FLAG = 0 OR @QUERY_TABLE_FLAG IS NULL))
    BEGIN
    SELECT TOP 1 @NAME = OBJ_NAME FROM #RESULTS
    SELECT TOP 1 @SEARCH_PROC = NAME FROM #RESULTS
    SET @SQL = 'exec '+@NAME+'.DBO.SP_HELPTEXT '+@SEARCH_PROC
    SELECT '********************PROC DEFINITION*************************'
    EXECUTE sp_executesql @SQL
END

IF(@QUERY_TABLE_FLAG = 1 AND (@SP_HELPTEXT_FLAG = 0 OR @SP_HELPTEXT_FLAG IS NULL))
    BEGIN
    SELECT TOP 1 @NAME = OBJ_NAME FROM #RESULTS
    SELECT TOP 1 @SEARCH_TABLE = NAME FROM #RESULTS
    SET @SQL = 'select top 100 * from '+@NAME+'..'+@SEARCH_TABLE
    SELECT '********************TABLE DATA BELOW*************************'
    EXECUTE sp_executesql @SQL
END

DROP TABLE #RESULTS
END TRY

BEGIN catch
DECLARE @MESSGAGE VARCHAR(MAX) = ERROR_MESSAGE(),
        @SEVERITY INT = ERROR_SEVERITY(),
        @STATE SMALLINT = ERROR_STATE()

    RAISERROR(@MESSGAGE,@SEVERITY,@STATE)
END catch