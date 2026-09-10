WITH parametros AS (
    SELECT
        TIMESTAMP '2026-08-01 00:00:00' AS inicio_mes,
        TIMESTAMP '2026-09-01 00:00:00' AS fin_mes_exclusivo
),

merchant_scope_raw (merchant_id) AS (
    VALUES
        ('JA82FIY0Z4'), ('BTJHGRLYXZ'), ('9I8LY96BBG'), ('H7H258JKKS'),
        ('GSYCJJ0ZMX'), ('TR2KLJUVZ6'), ('75H2G3UNCN'), ('LZ4FUN0WQD'),
        ('VUSTI8DA46'), ('54LXJZBNZ9'), ('XOP5AO97MP'), ('BVDN5HUB7R'),
        ('0BE18WOVV2'), ('NIV028B3MZ'), ('J7IML9IM9I'), ('3K2UR9MQ3O'),
        ('VS2MRZDVZL'), ('9OYGZJX2JZ'), ('IFZJ8WSLSE'), ('AVGU6FEYZ7'),
        ('NFBG4DGNTU'), ('NZ911L9FFZ'), ('HW9F3DLU6Y'), ('X12JGJK6HD'),
        ('6T666ZC1PC'), ('ND9E9BVEFH'), ('D3CSCWAZSN'), ('OL7HSSUC3Q'),
        ('3CH8FBJ9AN'), ('9O6561CJE9'), ('Z1OH7VNMNP'), ('GH9NAMTKQE'),
        ('8A1O5ELS22'), ('R1MFU4VEUU'), ('LNZJWX2CJM'), ('RINNZMPT6N'),
        ('JWB364BYJT'), ('U215EU8J7D'), ('J9QFIT63EE'), ('91VH6IUNEA'),
        ('MLMHGPOYCP'), ('AKKHBLNCCA'), ('GHYHY5RPOS'), ('NFUSJ7NQ96'),
        ('O1ZWI9P1IS'), ('VXJZXFZCK5'), ('0XV9992C0O')
),

merchant_scope AS (
    SELECT DISTINCT merchant_id
    FROM merchant_scope_raw
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
    c.merchant_name,
    c.sales_source,
    c.sales_agent_email,
    c.merchant_creation_date,
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
        WHEN c.merchant_id IS NULL THEN 'NO_EN_DIM_CLIENT'
        WHEN upper(trim(c.sales_source)) <> 'ENTERPRISE' THEN 'NO_ESTA_EN_ENTERPRISE'
        WHEN a.merchant_id IS NULL THEN 'ENTERPRISE_SIN_TPV_AGOSTO'
        WHEN date_trunc('month', h.primera_transaccion_historica) = DATE '2026-08-01'
             AND date_trunc('month', c.merchant_creation_date) = DATE '2026-08-01'
            THEN 'M0_NUEVO_ENTERPRISE'
        WHEN date_trunc('month', h.primera_transaccion_historica) = DATE '2026-08-01'
            THEN 'M0_PRIMERA_TX_AGOSTO_CREACION_OTRO_MES'
        ELSE 'NO_NUEVO_CARTERA_O_REACTIVADO'
    END AS clasificacion_tpv_m0
FROM merchant_scope s
LEFT JOIN client_current c
    ON c.merchant_id = s.merchant_id
LEFT JOIN tpv_historico h
    ON h.merchant_id = s.merchant_id
LEFT JOIN tpv_agosto a
    ON a.merchant_id = s.merchant_id
ORDER BY tpv_agosto DESC, s.merchant_id
