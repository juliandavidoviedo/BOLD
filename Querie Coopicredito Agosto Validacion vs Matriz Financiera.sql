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



----
#	merchant_id	merchant_name	sales_source	sales_agent_email	merchant_creation_date	primera_transaccion_historica	primera_transaccion_agosto	ultima_transaccion_agosto	tpv_agosto	paid_tpv_agosto	net_tpv_agosto	transacciones_agosto	transacciones_historicas	merchant_status	onboarding_status	last_update_event_date	datos_actualizados_hasta	clasificacion_tpv_m0
1	0GRNI5F4QF	Droguería San Antero 	ENTERPRISE	jeyson.salazar@bold.co	2026-09-05 14:48:29.483				0.0000	0.0000	0.0000	0	0	ENABLED	APPROVED	2026-09-05 15:21:26.994		SIN_TPV_AGOSTO
2	1AZSEMKA27	Salud Family	ENTERPRISE		2026-08-15 12:25:15.276	2026-09-05 16:52:18.858000			0.0000	0.0000	0.0000	0	87	ENABLED	APPROVED	2026-09-07 17:59:04.211		SIN_TPV_AGOSTO
3	BLGLVBLPF7	Drogueria Farma Pacho	ENTERPRISE		2026-08-24 16:32:32.699				0.0000	0.0000	0.0000	0	0	ENABLED	APPROVED	2026-09-07 17:52:51.748		SIN_TPV_AGOSTO
4	C9IQZXGV5Z	FarMarce la 15	ENTERPRISE		2026-08-27 16:16:46.149	2026-09-03 14:13:14.010000			0.0000	0.0000	0.0000	0	31	ENABLED	APPROVED	2026-09-07 17:57:15.508		SIN_TPV_AGOSTO
5	F9KOCP2I9P	Negocio de Marleny	ENTERPRISE	jeyson.salazar@bold.co	2026-09-04 15:52:17.705	2026-09-08 17:02:52.836982			0.0000	0.0000	0.0000	0	12	ENABLED	APPROVED	2026-09-08 18:09:26.622		SIN_TPV_AGOSTO
6	IDM1B3H7F5	Droguería Pharmalife Centro	ENTERPRISE		2026-08-31 16:36:05.498				0.0000	0.0000	0.0000	0	0	ENABLED	APPROVED	2026-09-07 17:55:50.766		SIN_TPV_AGOSTO
7	KSZEX7BW2B	Negocio de Alfonso Rafael	ENTERPRISE	jeyson.salazar@bold.co	2026-09-05 15:17:54.675				0.0000	0.0000	0.0000	0	0	ENABLED	APPROVED	2026-09-05 18:44:26.762		SIN_TPV_AGOSTO
8	L7H1W2PHU6	Negocio de Mónica Yohana	ENTERPRISE		2026-08-19 15:20:59.769				0.0000	0.0000	0.0000	0	0	ENABLED	APPROVED	2026-09-07 17:55:55.146		SIN_TPV_AGOSTO
9			ENTERPRISE		2026-09-02 18:29:25.355				0.0000	0.0000	0.0000	0	0		FULFILLED	2026-09-09 14:40:28.673		SIN_TPV_AGOSTO

