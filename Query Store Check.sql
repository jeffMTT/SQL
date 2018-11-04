DECLARE @SQL AS NVARCHAR(MAX) =''

 

SELECT @SQL += REPLACE('USE [{{DBName}}]

                IF EXISTS (SELECT * FROM sys.database_query_store_options WHERE actual_state=3)

                BEGIN

                                BEGIN TRY

                                                ALTER DATABASE [{{DBName}}] SET QUERY_STORE = OFF

                                                Exec [QDS].dbo.sp_query_store_consistency_check

                                                ALTER DATABASE [{{DBName}}] SET QUERY_STORE = ON

                                                ALTER DATABASE [{{DBName}}] SET QUERY_STORE (OPERATION_MODE = READ_WRITE)

                                END TRY

                                BEGIN CATCH

                                                SELECT

                                                                ERROR_NUMBER() AS ErrorNumber

                                                                ,ERROR_SEVERITY() AS ErrorSeverity

                                                                ,ERROR_STATE() AS ErrorState

                                                                ,ERROR_PROCEDURE() AS ErrorProcedure

                                                                ,ERROR_LINE() AS ErrorLine

                                                                ,ERROR_MESSAGE() AS ErrorMessage;

                                END CATCH;

                END'

                ,'{{DBName}}', name)

FROM sys.databases

WHERE is_query_store_on = 1

;

 
print @sql;
--EXEC (@SQL);
