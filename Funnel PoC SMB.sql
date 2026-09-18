WITH latest_leads AS (
    SELECT
        t.*,
        ROW_NUMBER() OVER (
            PARTITION BY lead_id
            ORDER BY event_timestamp DESC, last_update_date DESC
        ) AS rn
    FROM bold_gold_sales.fact_crm_leads_status_change t
    WHERE event_timestamp >= TIMESTAMP '2026-09-01 00:00:00'
      AND event_timestamp <  TIMESTAMP '2026-10-01 00:00:00'
      AND UPPER(TRIM(sales_channel)) = 'SMB'
)
SELECT *
FROM latest_leads
WHERE rn = 1;

---

WITH latest_opportunities AS (
    SELECT
        t.*,
        ROW_NUMBER() OVER (
            PARTITION BY opportunity_id
            ORDER BY event_timestamp DESC, last_update_date DESC
        ) AS rn
    FROM bold_gold_sales.fact_crm_opportunities_status_change t
    WHERE event_timestamp >= TIMESTAMP '2026-09-01 00:00:00'
      AND event_timestamp <  TIMESTAMP '2026-10-01 00:00:00'
      AND UPPER(TRIM(sales_channel)) = 'SMB'
)
SELECT *
FROM latest_opportunities
WHERE rn = 1;


----

AND (
    user_email IS NULL
    OR LOWER(TRIM(user_email)) NOT IN (
        'nohora.meneses@bold.co',
        'rafael.gonzalez@bold.co'
    )
)


----
