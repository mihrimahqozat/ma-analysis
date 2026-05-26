-- Annual deal volume and pricing trends
WITH annual_deals AS (
    SELECT
        parent_company,
        acquisition_year,
        COUNT(deal_id)                              AS total_deals,
        COUNT(CASE WHEN price_millions IS NOT NULL
              THEN 1 END)                           AS priced_deals,
        ROUND(AVG(price_millions)::NUMERIC, 2)      AS avg_deal_price_m,
        ROUND(SUM(price_millions)::NUMERIC, 2)      AS total_deal_value_m,
        ROUND(MAX(price_millions)::NUMERIC, 2)      AS largest_deal_m
    FROM acquisitions
    WHERE acquisition_year IS NOT NULL
    GROUP BY 
		parent_company, 
		acquisition_year
),
volume_with_growth AS (
    SELECT *,
        LAG(total_deals) OVER (
            PARTITION BY parent_company
            ORDER BY acquisition_year)              AS prev_year_deals,
        ROUND((total_deals -
            LAG(total_deals) OVER (
                PARTITION BY parent_company
                ORDER BY acquisition_year)
            ) * 100.0 /
            NULLIF(LAG(total_deals) OVER (
                PARTITION BY parent_company
                ORDER BY acquisition_year), 0)
            ::NUMERIC, 2)                           AS yoy_deal_growth_pct
    FROM annual_deals
)
SELECT *
FROM volume_with_growth
ORDER BY 
	parent_company, 
	acquisition_year;