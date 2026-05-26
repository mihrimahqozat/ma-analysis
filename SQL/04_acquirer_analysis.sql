-- Overall acquirer strategy profile
WITH acquirer_profile AS (
    SELECT
        parent_company,
        COUNT(deal_id)                               AS total_deals,
        COUNT(DISTINCT acquisition_year)             AS years_active,
        MIN(acquisition_year)                        AS first_deal_year,
        MAX(acquisition_year)                        AS last_deal_year,
        COUNT(CASE WHEN price_millions IS NOT NULL
              THEN 1 END)                            AS priced_deals,
        ROUND(AVG(price_millions)::NUMERIC, 2)       AS avg_deal_size_m,
        ROUND(SUM(price_millions)::NUMERIC, 2)       AS total_deal_value_m,
        ROUND(MAX(price_millions)::NUMERIC, 2)       AS largest_deal_m,
        COUNT(DISTINCT country)                      AS countries_targeted,
        COUNT(DISTINCT COALESCE(category, business)) AS sectors_targeted
    FROM acquisitions
    WHERE acquisition_year IS NOT NULL
    GROUP BY parent_company
)
SELECT *,
    ROUND(total_deals * 1.0 /
        NULLIF(years_active, 0)
        ::NUMERIC, 2)                               AS avg_deals_per_year,
    ROUND(priced_deals * 100.0 /
        NULLIF(total_deals, 0)
        ::NUMERIC, 2)                               AS price_disclosure_pct,
    RANK() OVER (
        ORDER BY total_deals DESC)                  AS volume_rank,
    RANK() OVER (
        ORDER BY total_deal_value_m DESC
        NULLS LAST)                                 AS value_rank
FROM acquirer_profile
ORDER BY volume_rank;