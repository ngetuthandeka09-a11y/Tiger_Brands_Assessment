# Retail Category Performance Analysis

An end-to-end analytics project that takes raw store-level sales data, joins it to store and shelf-gap data in Databricks and turns it into a Power BI report for category leadership.

The aim was to answer a practical question: **where is growth coming from, how healthy is it and where is value being lost?**

> The data comes from a case study dataset. It is not live client data.

---

## Headline findings

| Area | What the data shows |
|---|---|
| Overall | Value grew 6.6% (R7.89M to R8.42M), but volume fell 2.0%. Price per unit rose 8.8%, so growth is price-led. |
| Categories | Beverages are 24% of value but deliver about half of all growth. Two tea SKUs account for 51% of it. |
| Cereals and snacks | 60% of value, but units are down about 5% on every SKU. |
| Retailers | Pick n Pay grew on value and volume. Makro grew value (+11.9%) while losing volume (-3.0%). Shoprite declined on both (-9.9% value, -12.8% volume). |
| Shelf gaps | 25% of store-product rows have a ranging, availability or pricing gap. Those rows are down 11.1% in value and 18.5% in volume, while rows with no gap are up 12.5% and 3.5%. |
| Stores | 13 Shoprite stores account for about 60% of Shoprite's value decline. |
| Regions | The Eastern Cape and Limpopo & Mpumalanga underperform for all three retailers. |
| Pricing | Every pricing exception is overpricing, with shelf price more than 5% above recommended price (RSP). 100 of the 157 are at Makro, and those rows lose about 10 points more volume than the rest. |

---

## Business questions

1. What are the three most important messages for category leadership?
2. Which categories, sub-categories, brands and SKUs drive growth or decline?
3. How do retailers compare on value, volume and growth, and why do value and volume diverge?
4. Which divisions, regions and stores need intervention, and how should they be prioritised?
5. How do shelf gaps (ranging, availability, pricing) relate to performance?
6. How does the average unit price (AUP) compare with the recommended selling price (RSP), and what is the effect on volume, value and shopper demand?

---

## Tools used

- **Databricks SQL** for data preparation, joins and analysis
- **Power BI** (DAX measures) for the report
- **Excel** for store and gap source files, and for a supporting analysis workbook

---

## Data

Three sources were combined:

| Source | Grain | Key columns |
|---|---|---|
| Sales performance | Store and product | Store_Code, Barcode, Product_Description, 2025 and 2026 value and volume |
| Store master | Store | Store_Code, Division, Region, Retailer |
| Perfect Outlet gaps | Store and product | Ranging_Gap, Availability_Gap, Pricing_Gap, AUP, RSP |

The final dataset has 1,440 rows (120 stores x 12 products), covering 3 retailers, 4 categories, 7 sub-categories and 5 brands.

**Columns added during preparation**

- `Category` and `Sub_Category`, mapped from the product description
- `Brand`, taken from the first word of the product name
- `Any_Gap`, flagging rows with at least one gap
- `Price_Variance_Pct` and `Price_Band`, comparing AUP with RSP

---

## Approach

**1. Add categories and sub-categories.** A `CASE` statement maps each product to its category and sub-category, saved in a view so the source table stays untouched.

**2. Join the store and gap data.** Both joins are `LEFT JOIN`s, so no sales rows are lost. The gaps file is joined on Store_Code and Barcode together, because joining on store alone would multiply rows. Duplicate keys and unmatched rows were checked before relying on the join.

```sql
SELECT f.*,
       COALESCE(g.Ranging_Gap, 0)      AS Ranging_Gap,
       COALESCE(g.Availability_Gap, 0) AS Availability_Gap,
       COALESCE(g.Pricing_Gap, 0)      AS Pricing_Gap
FROM sales_performance_full f
LEFT JOIN perfect_outlet_gaps g
       ON f.Store_Code = g.Store_Code
      AND f.Barcode    = g.Barcode;
```

**3. Calculate growth from totals, never from percentages.** Growth is recalculated from summed values at whatever level is being shown. Averaging or adding row-level percentages gives the wrong answer when rows have different sizes.

```sql
ROUND((SUM(`2026_Value`) - SUM(`2025_Value`)) * 100.0
      / NULLIF(SUM(`2025_Value`), 0), 2) AS Value_Growth_Pct
```

**4. Separate price from volume.** Value growth is split into volume, price and mix effects to show whether growth comes from selling more or charging more.

**5. Test the gap effect.** Rows with a gap are compared with rows without one, by retailer, to see whether gaps are linked to weaker volume and value.

**6. Prioritise store exceptions.** Stores are ranked on rand impact, severity against their own retailer's average, breadth of decline across products, and whether the cause is fixable.

**7. Clean the AUP and RSP columns.** These loaded as text with a decimal comma, so they were converted to numbers before comparing.

```sql
TRY_CAST(REPLACE(REGEXP_REPLACE(AUP, '[^0-9,.-]', ''), ',', '.') AS DOUBLE) AS AUP
```

---

## Power BI report

| Page | Purpose |
|---|---|
| Executive summary | Slicers, KPI cards (value, value growth, volume growth, price change) and the three key messages |
| Retailer performance | Value and volume growth by retailer, volume, mix and price effects, and a summary table |
| Growth drivers | Category, sub-category and SKU contribution to growth |
| Price vs volume | Scatter of value against volume growth, AUP vs RSP bands |
| Execution gaps | Gap rates by retailer, performance with and without gaps, region by retailer heatmap |
| Store priorities | Ranked store list and the stores losing the most value |

Core measures include Value Growth %, Volume Growth %, Price per Unit, Price Change %, Share of Growth %, gap rates and a retailer-relative growth measure.

## Power BI Dashboard
[View the Tiger Brands dashboard]( https://app.powerbi.com/links/lJ-xmFlhOa?ctid=00bd19a8-d097-47fe-901b-b8cd0085ad7b&pbi_source=linkShare&bookmarkGuid=37b9bd3a-92fb-438f-93c2-98f11f0454e7)
---

## Limitations

- **Gap data is a point-in-time snapshot,** while sales cover a full period.
- **The findings show association, not proof of cause.** A product may be out of stock because it was already selling badly.
- **Price per unit is blended,** so it mixes real price changes with changes in products and pack sizes.
- **Thresholds are judgement calls.** The 15% decline cut-off for store priority and the 5% pricing tolerance are adjustable.

---

## Suggested repository structure

```
├── README.md
├── sql/
│   ├── 01_category_mapping.sql
│   ├── 02_joins_and_views.sql
│   ├── 03_growth_and_price_volume.sql
│   ├── 04_gap_analysis.sql
│   └── 05_pricing_analysis.sql
├── data/
│   └── sample_dataset.csv
├── powerbi/
│   └── retail_performance.pbix
└── images/
    └── report_screenshots.png
```

---

## Author

**Thandeka Ngetu**
 | [ngetu.thandeka09@gmail.com](#)
