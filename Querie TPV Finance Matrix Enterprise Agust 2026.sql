WITH parametros AS (
    SELECT
        TIMESTAMP '2026-08-01 00:00:00' AS inicio_mes,
        TIMESTAMP '2026-09-01 00:00:00' AS fin_mes_exclusivo
),

merchant_scope (merchant_id) AS (
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
        trim(cast(l.master_merchant_id AS varchar)) AS master_merchant_id
    FROM awsdatacatalog.bold_gold_growth.mart_master_merchant_lineage l
    INNER JOIN merchant_scope s
        ON trim(cast(l.merchant_id AS varchar)) = s.merchant_id
),

client_current AS (
    SELECT *
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
    CROSS JOIN parametros p
    INNER JOIN merchant_scope s
        ON trim(cast(t.merchant_id AS varchar)) = s.merchant_id
    WHERE t.creation_datetime >= p.inicio_mes
      AND t.creation_datetime < p.fin_mes_exclusivo
    GROUP BY 1
)

SELECT
    coalesce(l.master_merchant_id, s.merchant_id) AS master_merchant_id,
    count(DISTINCT s.merchant_id) AS merchants_reportados,
    array_join(array_agg(DISTINCT s.merchant_id), ', ') AS merchant_ids,
    array_join(array_agg(DISTINCT c.merchant_name), ', ') AS merchant_names,
    array_join(array_agg(DISTINCT c.sales_source), ', ') AS sales_sources,
    sum(coalesce(a.tpv_agosto, 0)) AS tpv_agosto_master,
    sum(coalesce(a.transacciones_agosto, 0)) AS transacciones_agosto,
    min(c.merchant_creation_date) AS primera_creacion_merchant,
    min(a.primera_transaccion_agosto) AS primera_transaccion_agosto,
    max(a.ultima_transaccion_agosto) AS ultima_transaccion_agosto
FROM merchant_scope s
LEFT JOIN lineage l
    ON l.merchant_id = s.merchant_id
LEFT JOIN client_current c
    ON c.merchant_id = s.merchant_id
LEFT JOIN tpv_agosto a
    ON a.merchant_id = s.merchant_id
GROUP BY 1
ORDER BY tpv_agosto_master DESC, master_merchant_id
