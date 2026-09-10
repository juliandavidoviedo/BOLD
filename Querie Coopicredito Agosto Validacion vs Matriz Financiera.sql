WITH parametros AS (
    SELECT
        TIMESTAMP '2026-08-01 00:00:00' AS inicio_mes,
        TIMESTAMP '2026-09-01 00:00:00' AS fin_mes_exclusivo
),

enterprise_merchants AS (
    SELECT
        trim(cast(c.merchant_id AS varchar)) AS merchant_id,
        max_by(c.merchant_name, c.last_update_event_date) AS merchant_name,
        max_by(c.sales_source, c.last_update_event_date) AS sales_source,
        max_by(c.merchant_acquisition_channel_sales_agent_email, c.last_update_event_date) AS sales_agent_email,
        min(c.creation_date) AS merchant_creation_date,
        max(c.last_update_event_date) AS last_update_event_date,
        max_by(c.status, c.last_update_event_date) AS merchant_status,
        max_by(c.onboarding_status, c.last_update_event_date) AS onboarding_status
    FROM awsdatacatalog.bold_gold_growth.dim_client c
    WHERE upper(trim(c.sales_source)) = 'ENTERPRISE'
    GROUP BY 1
),

tpv_historico AS (
    SELECT
        trim(cast(t.merchant_id AS varchar)) AS merchant_id,
        min(t.creation_datetime) AS primera_transaccion_historica,
        count(DISTINCT t.transaction_id) AS transacciones_historicas,
        sum(coalesce(t.tpv, 0)) AS tpv_historico
    FROM awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction t
    INNER JOIN enterprise_merchants e
        ON trim(cast(t.merchant_id AS varchar)) = e.merchant_id
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
    INNER JOIN enterprise_merchants e
        ON trim(cast(t.merchant_id AS varchar)) = e.merchant_id
    WHERE t.creation_datetime >= p.inicio_mes
      AND t.creation_datetime < p.fin_mes_exclusivo
    GROUP BY 1
)

SELECT
    e.merchant_id,
    e.merchant_name,
    e.sales_source,
    e.sales_agent_email,
    e.merchant_creation_date,
    h.primera_transaccion_historica,
    a.primera_transaccion_agosto,
    a.ultima_transaccion_agosto,
    coalesce(a.tpv_agosto, 0) AS tpv_agosto,
    coalesce(a.paid_tpv_agosto, 0) AS paid_tpv_agosto,
    coalesce(a.net_tpv_agosto, 0) AS net_tpv_agosto,
    coalesce(a.transacciones_agosto, 0) AS transacciones_agosto,
    coalesce(h.transacciones_historicas, 0) AS transacciones_historicas,
    e.merchant_status,
    e.onboarding_status,
    e.last_update_event_date,
    a.datos_actualizados_hasta,
    CASE
        WHEN a.merchant_id IS NULL THEN 'SIN_TPV_AGOSTO'
        WHEN date_trunc('month', h.primera_transaccion_historica) = DATE '2026-08-01'
             AND date_trunc('month', e.merchant_creation_date) = DATE '2026-08-01'
            THEN 'M0_NUEVO_ENTERPRISE'
        WHEN date_trunc('month', h.primera_transaccion_historica) = DATE '2026-08-01'
            THEN 'M0_PRIMERA_TX_AGOSTO_CREACION_OTRO_MES'
        ELSE 'NO_NUEVO_CARTERA_O_REACTIVADO'
    END AS clasificacion_tpv_m0
FROM enterprise_merchants e
LEFT JOIN tpv_historico h
    ON h.merchant_id = e.merchant_id
LEFT JOIN tpv_agosto a
    ON a.merchant_id = e.merchant_id
ORDER BY tpv_agosto DESC, e.merchant_id
