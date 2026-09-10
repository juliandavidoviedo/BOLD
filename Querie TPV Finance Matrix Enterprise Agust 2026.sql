WITH merchant_scope (merchant_id) AS (
    VALUES
        ('TR2KLJUVZ6'),
        ('GSYCJJ0ZMX'),
        ('75H2G3UNCN'),
        ('0XV9992C0O'),
        ('GHTNMF7727'),
        ('XMABPI8SDB'),
        ('PL0B5ER5G3'),
        ('JXLFJ824NO')
),

lineage AS (
    SELECT
        trim(cast(l.merchant_id AS varchar)) AS merchant_id,
        trim(cast(l.parent_merchant_id AS varchar)) AS parent_merchant_id
    FROM awsdatacatalog.bold_gold_growth.mart_master_merchant_lineage l
    INNER JOIN merchant_scope s
        ON trim(cast(l.merchant_id AS varchar)) = s.merchant_id
),

client_current AS (
    SELECT
        merchant_id,
        merchant_name,
        sales_source,
        sales_agent_email,
        merchant_creation_date,
        merchant_status,
        onboarding_status,
        last_update_event_date
    FROM (
        SELECT
            trim(cast(c.merchant_id AS varchar)) AS merchant_id,
            c.merchant_name,
            c.sales_source,
            c.merchant_acquisition_channel_sales_agent_email AS sales_agent_email,
            c.creation_date AS merchant_creation_date,
            c.status AS merchant_status,
            c.onboarding_status,
            c.last_update_event_date,
            row_number() OVER (
                PARTITION BY trim(cast(c.merchant_id AS varchar))
                ORDER BY c.last_update_event_date DESC NULLS LAST, c.creation_date DESC NULLS LAST
            ) AS rn
        FROM awsdatacatalog.bold_gold_growth.dim_client c
        INNER JOIN merchant_scope s
            ON trim(cast(c.merchant_id AS varchar)) = s.merchant_id
    )
    WHERE rn = 1
),

tpv_agosto AS (
    SELECT
        trim(cast(t.merchant_id AS varchar)) AS merchant_id,
        sum(coalesce(t.tpv, 0)) AS tpv_agosto,
        count(DISTINCT t.transaction_id) AS transacciones_agosto,
        min(t.creation_datetime) AS primera_transaccion_agosto,
        max(t.creation_datetime) AS ultima_transaccion_agosto
    FROM awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction t
    INNER JOIN merchant_scope s
        ON trim(cast(t.merchant_id AS varchar)) = s.merchant_id
    WHERE t.creation_datetime >= TIMESTAMP '2026-08-01 00:00:00'
      AND t.creation_datetime < TIMESTAMP '2026-09-01 00:00:00'
    GROUP BY 1
),

primera_tx AS (
    SELECT
        trim(cast(t.merchant_id AS varchar)) AS merchant_id,
        min(t.creation_datetime) AS primera_transaccion_historica
    FROM awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction t
    INNER JOIN merchant_scope s
        ON trim(cast(t.merchant_id AS varchar)) = s.merchant_id
    GROUP BY 1
)

SELECT
    s.merchant_id,
    coalesce(l.parent_merchant_id, s.merchant_id) AS parent_merchant_id,
    c.merchant_name,
    c.sales_source,
    c.sales_agent_email,
    c.merchant_creation_date,
    p.primera_transaccion_historica,
    a.primera_transaccion_agosto,
    a.ultima_transaccion_agosto,
    coalesce(a.tpv_agosto, 0) AS tpv_agosto,
    coalesce(a.transacciones_agosto, 0) AS transacciones_agosto,
    c.merchant_status,
    c.onboarding_status,
    CASE
        WHEN upper(trim(c.sales_source)) = 'ENTERPRISE'
            THEN 'CANAL_ENTERPRISE'
        WHEN c.sales_source IS NULL
            THEN 'SIN_DIM_CLIENT'
        ELSE 'CANAL_NO_ENTERPRISE'
    END AS validacion_canal,
    CASE
        WHEN date_trunc('month', p.primera_transaccion_historica) = DATE '2026-08-01'
             AND date_trunc('month', c.merchant_creation_date) = DATE '2026-08-01'
            THEN 'M0_NUEVO'
        WHEN date_trunc('month', p.primera_transaccion_historica) = DATE '2026-08-01'
            THEN 'M0_PRIMERA_TX_NO_NUEVO'
        WHEN a.merchant_id IS NULL
            THEN 'SIN_TPV_AGOSTO'
        ELSE 'NO_NUEVO'
    END AS validacion_m0
FROM merchant_scope s
LEFT JOIN lineage l
    ON l.merchant_id = s.merchant_id
LEFT JOIN client_current c
    ON c.merchant_id = s.merchant_id
LEFT JOIN primera_tx p
    ON p.merchant_id = s.merchant_id
LEFT JOIN tpv_agosto a
    ON a.merchant_id = s.merchant_id
ORDER BY tpv_agosto DESC, s.merchant_id
