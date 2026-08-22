CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    -- Declare timing variables as requested
    DECLARE @start_time DATETIME, 
            @end_time DATETIME, 
            @batch_start_time DATETIME, 
            @batch_end_time DATETIME;

    SET @batch_start_time = GETDATE();

    -- ===== 1. crm_cust_info =====
    SET @start_time = GETDATE();
    PRINT 'Truncating Table silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;
    PRINT 'Inserting Data Into: silver.crm_cust_info';

    INSERT INTO silver.crm_cust_info (cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date)
    SELECT 
    cst_id,
    cst_key,
    trim(cst_firstname) as cst_firstname,
    trim(cst_lastname) as last_name,
    CASE 
            WHEN UPPER(cst_marital_status) = 'S' THEN 'Single'
            WHEN UPPER(cst_marital_status) = 'M' THEN 'Married'
            ELSE 'Empty'
        END AS cst_marital_status,
     CASE 
            WHEN UPPER(cst_gndr) = 'F' THEN 'Female'
            WHEN UPPER(cst_gndr) = 'M' THEN 'Male'
            ELSE 'Empty'
        END AS cst_cst_gndr,
    cst_create_date
    from(
    select *,
    ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last
    from bronze.crm_cust_info
    )
    t where flag_last = 1 and cst_id is not null;

    SET @end_time = GETDATE();
    PRINT '  -> Completed in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

    -- ===== 2. crm_prd_info =====
    SET @start_time = GETDATE();
    PRINT 'Truncating Table silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;
    PRINT 'Inserting Data Into: silver.crm_prd_info';

    INSERT INTO silver.crm_prd_info(prd_id,prd_cat,prd_key,prd_num,prd_cost,prd_line,prd_start_date,prd_end_date)
    SELECT 
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
        SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
        TRIM(prd_num) AS prd_num,
        ISNULL(prd_cost, 0) AS prd_cost,
        CASE 
            WHEN TRIM(UPPER(prd_line)) = 'R' THEN 'Road'
            WHEN TRIM(UPPER(prd_line)) = 'M' THEN 'Mountain'
            WHEN TRIM(UPPER(prd_line)) = 'S' THEN 'Other sales'
            WHEN TRIM(UPPER(prd_line)) = 'T' THEN 'Touring'
            ELSE 'Empty'
        END AS prd_line,
        prd_start_date,
        DATEADD(day, -1, LEAD(prd_start_date) OVER (
            PARTITION BY prd_key 
            ORDER BY prd_start_date
        )) AS prd_end_date
    FROM bronze.crm_prd_info;

    SET @end_time = GETDATE();
    PRINT '  -> Completed in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

    -- ===== 3. crm_sales_details =====
    SET @start_time = GETDATE();
    PRINT 'Truncating Table silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;
    PRINT 'Inserting Data Into: silver.crm_sales_details';

    insert into silver.crm_sales_details(sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price)
    SELECT 
                sls_ord_num,
                sls_prd_key,
                sls_cust_id,
                CASE 
                    WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                    ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
                END AS sls_order_dt,
                CASE 
                    WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                    ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
                END AS sls_ship_dt,
                CASE 
                    WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                    ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
                END AS sls_due_dt,
                CASE 
                    WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
                        THEN sls_quantity * ABS(sls_price)
                    ELSE sls_sales
                END AS sls_sales, 
                sls_quantity,
                CASE 
                    WHEN sls_price IS NULL OR sls_price <= 0 
                        THEN sls_sales / NULLIF(sls_quantity, 0)
                    ELSE sls_price  
                END AS sls_price
            FROM bronze.crm_sales_details;

    SET @end_time = GETDATE();
    PRINT '  -> Completed in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

    -- ===== 4. erp_cust_az12 =====
    SET @start_time = GETDATE();
    PRINT 'Truncating Table silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12;
    PRINT 'Inserting Data Into: silver.erp_cust_az12';

    INSERT INTO silver.erp_cust_az12(cid,bdate,gen)
    select 
    case when cid like 'NAS%' then substring(cid,4,len(cid))
    ELSE cid
    END AS cid,
    case when bdate > GETDATE() then null
    ELSE bdate
    END AS bdate,
    case when upper(gen)='F' then 'Female'
         when upper(gen)='M' then 'Male' 
         when gen is null or gen ='' then 'Empty' 
         ELSE gen
         END AS gen
    from bronze.erp_cust_az12;

    SET @end_time = GETDATE();
    PRINT '  -> Completed in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

    -- ===== 5. erp_loc_a101 =====
    SET @start_time = GETDATE();
    PRINT 'Truncating Table silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101;
    PRINT 'Inserting Data Into: silver.erp_loc_a101';

    INSERT INTO silver.erp_loc_a101(cid,cntry)
    SELECT 
    REPLACE(cid,'-','') as cid,
    CASE
            WHEN cntry IN ('USA', 'US') THEN 'United States'
            WHEN cntry = 'DE' THEN 'Germany'
            WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'Empty'
            ELSE cntry
        END AS cntry
    FROM bronze.erp_loc_a101;

    SET @end_time = GETDATE();
    PRINT '  -> Completed in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

    -- ===== 6. erp_px_cat_g1v2 =====
    SET @start_time = GETDATE();
    PRINT 'Truncating Table silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    PRINT 'Inserting Data Into: silver.erp_px_cat_g1v2';

    INSERT INTO silver.erp_px_cat_g1v2(id,cat,subcat,maintenance)
    SELECT
    id,
    cat,
    subcat,
    maintenance
    FROM bronze.erp_px_cat_g1v2;

    SET @end_time = GETDATE();
    PRINT '  -> Completed in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

    -- Total procedure time
    SET @batch_end_time = GETDATE();
    PRINT '========================================';
    PRINT 'Total procedure execution time: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR) + ' seconds.';
END;
GO