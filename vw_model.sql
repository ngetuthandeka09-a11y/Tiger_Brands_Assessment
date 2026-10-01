-- I'VE VIEWED THE TABLES BEFORE UPLOADING THEM. I AM TRYING TO UNDERSTAND THE DATASET AND CLEAN UP.
-- I WILL BE COMBINING ALL MY TABLES TO GET A CLEAR VIEW.

CREATE OR REPLACE VIEW ngetu.tiger_brands.vw_model AS
SELECT
    s.Store_Code,
    s.Store_Name,
    sm.Division,
    sm.Region,
    sm.Retailer,
    s.Barcode,
    s.Product_Description,
    pm.Brand,
    pm.SKU,
    pm.Category,
    pm.Sub_Category,
    s.`2026_Value`  AS Value_2026,
    s.`2025_Value`  AS Value_2025,
    s.`2026_Volume` AS Volume_2026,
    s.`2025_Volume` AS Volume_2025,
    COALESCE(g.Ranging_Gap, 0)      AS Ranging_Gap,
    COALESCE(g.Availability_Gap, 0) AS Availability_Gap,
    COALESCE(g.Pricing_Gap, 0)      AS Pricing_Gap,
    TRY_CAST(REPLACE(g.AUP, ',', '.') AS DOUBLE) AS AUP,
    TRY_CAST(REPLACE(g.RSP, ',', '.') AS DOUBLE) AS RSP
FROM ngetu.tiger_brands.sales_performance s
LEFT JOIN ngetu.tiger_brands.store_master sm
    ON s.Store_Code = sm.Store_Code
LEFT JOIN ngetu.tiger_brands.product_master pm
    ON s.Barcode = pm.Barcode
LEFT JOIN ngetu.tiger_brands.perfect_outlet_gaps g
    ON s.Store_Code = g.Store_Code
   AND s.Barcode = g.Barcode;

--CHECKING IF THE ABOVE CODE WORKED

SELECT *
FROM ngetu.tiger_brands.vw_model;

--CHECKING FOR DUPLICATE STORES AND BARCODES 
SELECT Store_Code, COUNT(*) 
FROM ngetu.tiger_brands.store_master GROUP BY Store_Code HAVING COUNT(*) > 1;

SELECT Barcode, COUNT(*) 
FROM ngetu.tiger_brands.product_master GROUP BY Barcode HAVING COUNT(*) > 1;

SELECT Store_Code, Barcode, COUNT(*) 
FROM ngetu.tiger_brands.perfect_outlet_gaps GROUP BY Store_Code, Barcode HAVING COUNT(*) > 1;

-- CHECKING IF NUMBER OF ROWS MATCH TOTAL VALUE
SELECT COUNT(*), 
       SUM(`2026_Value`)
FROM ngetu.tiger_brands.sales_performance;

SELECT COUNT(*), 
        SUM(Value_2026)
FROM ngetu.tiger_brands.vw_model;

-- CHECKING FOR UNMATCHED STORES AND BARCODES

SELECT COUNT(*) 
FROM ngetu.tiger_brands.vw_model 
WHERE Retailer IS NULL;

SELECT COUNT(*) 
FROM ngetu.tiger_brands.vw_model 
WHERE Brand IS NULL;

---THEY WAY I LOADED THE BARCODE DIDN'T MATCH TO IT BROUGHT IN NULL
--I UPDATED THE BARCODE TYPE
CREATE OR REPLACE VIEW ngetu.tiger_brands.vw_model AS
SELECT
    s.Store_Code,
    s.Store_Name,
    sm.Division,
    sm.Region,
    sm.Retailer,
    s.Barcode,
    s.Product_Description,
    pm.Brand,
    pm.SKU,
    pm.Category,
    pm.Sub_Category,
    s.`2026_Value`  AS Value_2026,
    s.`2025_Value`  AS Value_2025,
    s.`2026_Volume` AS Volume_2026,
    s.`2025_Volume` AS Volume_2025,
    COALESCE(g.Ranging_Gap, 0)      AS Ranging_Gap,
    COALESCE(g.Availability_Gap, 0) AS Availability_Gap,
    COALESCE(g.Pricing_Gap, 0)      AS Pricing_Gap,
    TRY_CAST(g.AUP AS DOUBLE)       AS AUP,
    TRY_CAST(g.RSP AS DOUBLE)       AS RSP
FROM ngetu.tiger_brands.sales_performance s
LEFT JOIN ngetu.tiger_brands.store_master sm
    ON s.Store_Code = sm.Store_Code
LEFT JOIN ngetu.tiger_brands.product_master pm
    ON LOWER(TRIM(s.Product_Description)) = LOWER(TRIM(pm.SKU))
LEFT JOIN ngetu.tiger_brands.perfect_outlet_gaps g
    ON s.Store_Code = g.Store_Code
   AND s.Barcode = g.Barcode;

--CHECKING IF THE ABOVE WORKED
   SELECT COUNT(*) FROM ngetu.tiger_brands.vw_model WHERE Brand IS NULL;
   SELECT COUNT(*) FROM ngetu.tiger_brands.sales_performance;
   SELECT COUNT(*) FROM ngetu.tiger_brands.vw_model;
   SELECT DISTINCT Product_Description FROM ngetu.tiger_brands.vw_model WHERE Brand IS NULL;
   =======================================================================================================
   --I'VE JOINED ALL THE TABLES

   SELECT *
   FROM ngetu.tiger_brands.vw_model;

   SELECT Store_Code, Barcode, AUP, RSP
FROM ngetu.tiger_brands.perfect_outlet_gaps
LIMIT 20;

CREATE OR REPLACE VIEW ngetu.tiger_brands.vw_model AS
SELECT
    s.Store_Code,
    s.Store_Name,
    sm.Division,
    sm.Region,
    sm.Retailer,
    s.Barcode,
    s.Product_Description,
    pm.Brand,
    pm.SKU,
    pm.Category,
    pm.Sub_Category,
    s.`2026_Value`  AS Value_2026,
    s.`2025_Value`  AS Value_2025,
    s.`2026_Volume` AS Volume_2026,
    s.`2025_Volume` AS Volume_2025,
    COALESCE(g.Ranging_Gap, 0)      AS Ranging_Gap,
    COALESCE(g.Availability_Gap, 0) AS Availability_Gap,
    COALESCE(g.Pricing_Gap, 0)      AS Pricing_Gap,
    TRY_CAST(REPLACE(g.AUP, ',', '.') AS DOUBLE) AS AUP,
    TRY_CAST(REPLACE(g.RSP, ',', '.') AS DOUBLE) AS RSP
FROM ngetu.tiger_brands.sales_performance s
LEFT JOIN ngetu.tiger_brands.store_master sm
    ON s.Store_Code = sm.Store_Code
LEFT JOIN ngetu.tiger_brands.product_master pm
    ON LOWER(TRIM(s.Product_Description)) = LOWER(TRIM(pm.SKU))
LEFT JOIN ngetu.tiger_brands.perfect_outlet_gaps g
    ON s.Store_Code = g.Store_Code
   AND s.Barcode = g.Barcode;

SELECT
    COUNT(*) AS rows_total,
    SUM(CASE WHEN AUP IS NULL THEN 1 ELSE 0 END) AS aup_missing,
    SUM(CASE WHEN RSP IS NULL THEN 1 ELSE 0 END) AS rsp_missing,
    SUM(Pricing_Gap) AS flagged_rows,
    SUM(CASE WHEN AUP > RSP * 1.05 THEN 1 ELSE 0 END) AS rows_over_5pct
FROM ngetu.tiger_brands.vw_model;

SELECT
    Retailer,
    SUM(Value_2026) AS Value_2026,
    SUM(Value_2025) AS Value_2025,
    ROUND((SUM(Value_2026) - SUM(Value_2025)) / SUM(Value_2025) * 100, 1) AS Value_Growth_Pct,
    SUM(Volume_2026) AS Volume_2026,
    SUM(Volume_2025) AS Volume_2025,
    ROUND((SUM(Volume_2026) - SUM(Volume_2025)) / SUM(Volume_2025) * 100, 1) AS Volume_Growth_Pct,
    ROUND(SUM(Value_2026) / SUM(Volume_2026), 2) AS AUP_2026,
    ROUND(SUM(Value_2025) / SUM(Volume_2025), 2) AS AUP_2025
FROM ngetu.tiger_brands.vw_model
GROUP BY Retailer
ORDER BY Value_2026 DESC;

SELECT *
FROM ngetu.tiger_brands.vw_model;
