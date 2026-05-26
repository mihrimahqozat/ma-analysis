-- Acquisition focus by business category
WITH sector_stats AS (
    SELECT
        parent_company,
        COALESCE(category, business,
                 'Uncategorized')                   AS sector,
        COUNT(deal_id)                              AS total_deals,
        COUNT(CASE WHEN price_millions IS NOT NULL
              THEN 1 END)                           AS priced_deals,
        ROUND(AVG(price_millions)::NUMERIC, 2)      AS avg_deal_price_m,
        ROUND(SUM(price_millions)::NUMERIC, 2)      AS total_deal_value_m,
        ROUND(MAX(price_millions)::NUMERIC, 2)      AS largest_deal_m,
        COUNT(DISTINCT country)                     AS countries_acquired_from
    FROM acquisitions
    WHERE category IS NOT NULL
       OR business IS NOT NULL
    GROUP BY parent_company,
             COALESCE(category, business, 'Uncategorized')
)
SELECT *,
    RANK() OVER (
        PARTITION BY parent_company
        ORDER BY total_deals DESC)                  AS sector_rank_by_deals,
    RANK() OVER (
        PARTITION BY parent_company
        ORDER BY total_deal_value_m DESC
        NULLS LAST)                                 AS sector_rank_by_value,
    ROUND(total_deals * 100.0 /
        SUM(total_deals) OVER (
            PARTITION BY parent_company)
        ::NUMERIC, 2)                               AS pct_of_company_deals
FROM sector_stats
ORDER BY parent_company,
         sector_rank_by_deals;