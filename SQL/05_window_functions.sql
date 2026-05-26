-- Deal-level ranking with running totals and peer comparison
WITH deal_ranked AS (
    SELECT
        deal_id,
        parent_company,
        acquired_company,
        acquisition_year,
        acquisition_month,
        country,
        price_millions,
        COALESCE(category, business, 'Uncategorized') AS sector,
        RANK() OVER (
            ORDER BY price_millions DESC NULLS LAST)  AS global_price_rank,
        RANK() OVER (PARTITION BY parent_company
            ORDER BY price_millions DESC
            NULLS LAST)                               AS company_price_rank,
        NTILE(4) OVER (
            ORDER BY price_millions DESC
            NULLS LAST)                               AS price_quartile,
        ROUND(SUM(price_millions) OVER (
            PARTITION BY parent_company
            ORDER BY acquisition_year,
                     deal_id
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW)::NUMERIC, 2)             AS cumulative_spend_m,
        ROUND(AVG(price_millions) OVER (
            PARTITION BY parent_company)
            ::NUMERIC, 2)                             AS company_avg_deal_m,
        ROUND((price_millions - AVG(price_millions)
            OVER (PARTITION BY parent_company))
            ::NUMERIC, 2)                             AS vs_company_avg_m
    FROM acquisitions
    WHERE price_millions IS NOT NULL
)
SELECT *
FROM deal_ranked
ORDER BY global_price_rank;