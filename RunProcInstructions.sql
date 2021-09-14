/* Run proc instructions*/

exec DBO.SEARCH_OBJECT @SEARCH_PROC = 'myproc',@SEARCH_PROC_FLAG = 1  --This will search the proc in all db
exec DBO.SEARCH_OBJECT @SEARCH_PROC = 'myproc',@SEARCH_PROC_FLAG = 1,@SP_HELPTEXT_FLAG = 1 --this will search proc in all db and will give top 1 procedure text in case of multiple procedures
exec DBO.SEARCH_OBJECT @SEARCH_TABLE ='mytable',@SEARCH_TABLE_FLAG = 1 --this will search table in all dbs
exec DBO.SEARCH_OBJECT @SEARCH_TABLE ='mytable',@SEARCH_TABLE_FLAG = 1,@QUERY_TABLE_FLAG = 1 --this will search table and query the top 100 rows in db
exec DBO.SEARCH_OBJECT @SEARCH_TABLE ='mytable',@SEARCH_TABLE_FLAG = 1, @QUERY_TABLE_STRUCTURE = 1 --this will query table and describe table structure 

