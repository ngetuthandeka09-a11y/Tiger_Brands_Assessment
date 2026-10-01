SELECT *
FROM ngetu.tiger_brands.vw_model;

--UNDERSTANDING GROWTH % AND AUP

SELECT Category,
        SUM(Value_2026) AS Value_2026,
        SUM(Value_2025) AS Value_2025,
        ROUND((SUM(Value_2026) - SUM(Value_2025)) / NULLIF(SUM(Value_2025), 0) * 100, 1) AS Value_Growth_Pct,
        SUM(Volume_2026) AS Volume_2026,
        SUM(Volume_2025) AS Volume_2025,
        ROUND((SUM(Volume_2026) - SUM(Volume_2025)) / NULLIF(SUM(Volume_2025), 0) * 100, 1) AS Volume_Growth_Pct,
        ROUND(SUM(Value_2025) / NULLIF(SUM(Volume_2025), 0), 2) AS AUP_2025,
        ROUND(SUM(Value_2026) / NULLIF(SUM(Volume_2026), 0), 2) AS AUP_2026
FROM ngetu.tiger_brands.vw_model
GROUP BY Category
ORDER BY Value_2026 DESC;

--WHICH CATEGORY CONTRIBUTED TO GROWTH

WITH seg AS (
    SELECT
        Category,
        SUM(Value_2026) - SUM(Value_2025) AS Rand_Change,
        SUM(Value_2025) AS Value_2025
    FROM ngetu.tiger_brands.vw_model
    GROUP BY Category
)
SELECT
    Category,
    ROUND(Rand_Change, 0) AS Rand_Change,
    ROUND(Rand_Change / SUM(Rand_Change) OVER () * 100, 1) AS Share_Of_Total_Change_Pct,
    ROUND(Rand_Change / SUM(Value_2025) OVER () * 100, 2) AS Points_Of_Growth
FROM seg
ORDER BY Rand_Change DESC;

--PRICE, MIX AND VOLUME EFFECT

WITH seg AS (
    SELECT
        Category,
        SUM(Value_2026) - SUM(Value_2025) AS Rand_Change,
        SUM(Value_2025) AS Value_2025
    FROM ngetu.tiger_brands.vw_model
    GROUP BY Category
)
SELECT
    Category,
    ROUND(Rand_Change, 0) AS Rand_Change,
    ROUND(Rand_Change / SUM(Rand_Change) OVER () * 100, 1) AS Share_Of_Total_Change_Pct,
    ROUND(Rand_Change / SUM(Value_2025) OVER () * 100, 2) AS Points_Of_Growth
FROM seg
ORDER BY Rand_Change DESC;

--GAP RATE
SELECT
    Retailer,
    Region,
    COUNT(*) AS rows_total,
    ROUND(AVG(Ranging_Gap) * 100, 1) AS Ranging_Gap_Pct,
    ROUND(AVG(Availability_Gap) * 100, 1) AS Availability_Gap_Pct,
    ROUND(AVG(Pricing_Gap) * 100, 1) AS Pricing_Gap_Pct
FROM ngetu.tiger_brands.vw_model
GROUP BY Retailer, Region
ORDER BY  Retailer, Region;

SELECT
    Store_Name, Retailer, Region,
    ROUND(SUM(Value_2026) - SUM(Value_2025), 0) AS Rand_Change,
    ROUND((SUM(Value_2026) - SUM(Value_2025)) / NULLIF(SUM(Value_2025), 0) * 100, 1) AS Value_Growth_Pct,
    ROUND(AVG(Ranging_Gap) * 100, 1) AS Ranging_Gap_Pct,
    ROUND(AVG(Availability_Gap) * 100, 1) AS Availability_Gap_Pct,
    ROUND(AVG(Pricing_Gap) * 100, 1) AS Pricing_Gap_Pct
FROM ngetu.tiger_brands.vw_model
GROUP BY Store_Name, Retailer, Region
ORDER BY Rand_Change ASC;

SELECT *
FROM ngetu.tiger_brands.vw_model;
