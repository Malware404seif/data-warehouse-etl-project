CREATE OR ALTER PROCEDURE bronze.load_bronze as
BEGIN
   TRUNCATE TABLE bronze.crm_cust_info;
   TRUNCATE TABLE bronze.crm_prd_info;
   TRUNCATE TABLE bronze.crm_sales_details;
   TRUNCATE TABLE bronze.erp_cust_az12;
   TRUNCATE TABLE bronze.erp_loc_a101;
   TRUNCATE TABLE bronze.erp_px_cat_g1v2;
   PRINT'tables are truncated';

   DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
   BEGIN TRY
      SET @batch_start_time=GETDATE();
	  print 'loading bronze layer';
	  print' ---------------------';
	  print'loading crm tables';


	 SET @start_time=GETDATE();
	 BULK INSERT bronze.crm_cust_info
	 FROM 'C:\Users\Seif\Desktop\personal projects\data_projects\seif version\datasets\source_crm\cust_info.csv'
	 WITH (
	   FIRSTROW = 2,
	   FIELDTERMINATOR=',',
	   TABLOCK
	 );
	 SET @end_time =GETDATE();
	 PRINT 'load duartion: ' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' Seconds';
	 PRINT 'bronze.crm_cust_info table is loaded';



	 SET @start_time=GETDATE()
	 BULK INSERT bronze.crm_prd_info
	 FROM 'C:\Users\Seif\Desktop\personal projects\data_projects\seif version\datasets\source_crm\prd_info.csv'
	 WITH (
	   FIRSTROW = 2,
	   FIELDTERMINATOR=',',
	   TABLOCK
	 );
	 SET @end_time =GETDATE();
	 PRINT 'load duartion: ' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' Seconds';
	 PRINT 'bronze.crm_prd_info table is loaded';


	  SET @start_time=GETDATE()
	 BULK INSERT bronze.crm_sales_details
	 FROM 'C:\Users\Seif\Desktop\personal projects\data_projects\seif version\datasets\source_crm\sales_details.csv'
	 WITH (
	   FIRSTROW = 2,
	   FIELDTERMINATOR=',',
	   TABLOCK
	 );
	 SET @end_time =GETDATE();
	 PRINT 'load duartion: ' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' Seconds';
	 PRINT 'bronze.crm_sales_details table is loaded';


	 SET @start_time=GETDATE();
	 BULK INSERT bronze.erp_cust_az12
	 FROM 'C:\Users\Seif\Desktop\personal projects\data_projects\seif version\datasets\source_erp\CUST_AZ12.csv'
	  WITH( 
	    FIRSTROW = 2,
		FIELDTERMINATOR=',',
		TABLOCK
      );
	  SET @end_time=GETDATE();
	  PRINT 'load duration '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+ ' Seconds';
	  PRINT 'bronze.erp_cust_az12 is loaded';



	   SET @start_time=GETDATE();
	 BULK INSERT bronze.erp_loc_a101
	 FROM 'C:\Users\Seif\Desktop\personal projects\data_projects\seif version\datasets\source_erp\LOC_A101.csv'
	  WITH( 
	    FIRSTROW = 2,
		FIELDTERMINATOR=',',
		TABLOCK
      );
	  SET @end_time=GETDATE();
	  PRINT 'load duration '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+ ' Seconds';
	  PRINT 'bronze.erp_loc_a101 is loaded';


	  
	   SET @start_time=GETDATE();
	 BULK INSERT bronze.erp_px_cat_g1v2
	 FROM 'C:\Users\Seif\Desktop\personal projects\data_projects\seif version\datasets\source_erp\PX_CAT_G1V2.csv'
	  WITH( 
	    FIRSTROW = 2,
		FIELDTERMINATOR=',',
		TABLOCK
      );
	  SET @end_time=GETDATE();
	  PRINT 'load duration '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+ ' Seconds';
	  PRINT 'bronze.erp_px_cat_g1v2 is loaded';

	  SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='

      END TRY
	 BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
 

 bronze.load_bronze
