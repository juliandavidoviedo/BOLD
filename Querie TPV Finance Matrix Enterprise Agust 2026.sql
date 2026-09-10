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
        trim(cast(l.parent_merchant_id AS varchar)) AS parent_merchant_id
    FROM awsdatacatalog.bold_gold_growth.mart_master_merchant_lineage l
    INNER JOIN merchant_scope s
        ON trim(cast(l.merchant_id AS varchar)) = s.merchant_id
),

payment_dim AS (
    SELECT
        trim(cast(d.merchant_id AS varchar)) AS merchant_id,
        d.onboarding_end_date,
        d.document_type,
        d.document_number,
        d.merchant_category_key
    FROM awsdatacatalog.bold_gold_payments.dim_merchant d
    INNER JOIN merchant_scope s
        ON trim(cast(d.merchant_id AS varchar)) = s.merchant_id
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

tpv_historico AS (
    SELECT
        trim(cast(t.merchant_id AS varchar)) AS merchant_id,
        min(t.creation_datetime) AS primera_transaccion_historica,
        count(DISTINCT t.transaction_id) AS transacciones_historicas
    FROM awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction t
    INNER JOIN merchant_scope s
        ON trim(cast(t.merchant_id AS varchar)) = s.merchant_id
    GROUP BY 1
),

tpv_agosto AS (
    SELECT
        trim(cast(t.merchant_id AS varchar)) AS merchant_id,
        sum(coalesce(t.tpv, 0)) AS tpv_agosto,
        sum(coalesce(t.paid_tpv, 0)) AS paid_tpv_agosto,
        sum(coalesce(t.net_tpv, 0)) AS net_tpv_agosto,
        count(DISTINCT t.transaction_id) AS transacciones_agosto,
        min(t.creation_datetime) AS primera_transaccion_agosto,
        max(t.creation_datetime) AS ultima_transaccion_agosto,
        max(t.load_datetime) AS datos_actualizados_hasta
    FROM awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction t
    CROSS JOIN parametros p
    INNER JOIN merchant_scope s
        ON trim(cast(t.merchant_id AS varchar)) = s.merchant_id
    WHERE t.creation_datetime >= p.inicio_mes
      AND t.creation_datetime < p.fin_mes_exclusivo
    GROUP BY 1
)

SELECT
    s.merchant_id,
    coalesce(l.parent_merchant_id, s.merchant_id) AS parent_merchant_id,
    c.merchant_name,
    c.sales_source,
    c.sales_agent_email,
    c.merchant_creation_date,
    p.onboarding_end_date,
    p.document_type,
    p.document_number,
    p.merchant_category_key,
    h.primera_transaccion_historica,
    a.primera_transaccion_agosto,
    a.ultima_transaccion_agosto,
    coalesce(a.tpv_agosto, 0) AS tpv_agosto,
    coalesce(a.paid_tpv_agosto, 0) AS paid_tpv_agosto,
    coalesce(a.net_tpv_agosto, 0) AS net_tpv_agosto,
    coalesce(a.transacciones_agosto, 0) AS transacciones_agosto,
    coalesce(h.transacciones_historicas, 0) AS transacciones_historicas,
    c.merchant_status,
    c.onboarding_status,
    c.last_update_event_date,
    a.datos_actualizados_hasta,
    CASE
        WHEN upper(trim(c.sales_source)) = 'ENTERPRISE'
             AND date_trunc('month', h.primera_transaccion_historica) = DATE '2026-08-01'
             AND date_trunc('month', coalesce(p.onboarding_end_date, c.merchant_creation_date)) = DATE '2026-08-01'
            THEN 'M0_NUEVO_ENTERPRISE_ESTRICTO'
        WHEN date_trunc('month', h.primera_transaccion_historica) = DATE '2026-08-01'
             AND date_trunc('month', coalesce(p.onboarding_end_date, c.merchant_creation_date)) = DATE '2026-08-01'
            THEN 'M0_NUEVO_PERO_CANAL_NO_ENTERPRISE'
        WHEN date_trunc('month', h.primera_transaccion_historica) = DATE '2026-08-01'
            THEN 'M0_PRIMERA_TX_AGOSTO_NO_NUEVO_CLIENTE'
        WHEN a.merchant_id IS NULL THEN 'SIN_TPV_AGOSTO'
        ELSE 'NO_NUEVO_CARTERA_O_REACTIVADO'
    END AS clasificacion_validacion
FROM merchant_scope s
LEFT JOIN lineage l
    ON l.merchant_id = s.merchant_id
LEFT JOIN payment_dim p
    ON p.merchant_id = s.merchant_id
LEFT JOIN client_current c
    ON c.merchant_id = s.merchant_id
LEFT JOIN tpv_historico h
    ON h.merchant_id = s.merchant_id
LEFT JOIN tpv_agosto a
    ON a.merchant_id = s.merchant_id
ORDER BY tpv_agosto DESC, s.merchant_id
