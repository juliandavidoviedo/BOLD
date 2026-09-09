WITH parametros AS (
    SELECT
        CAST('2026-08-01' AS timestamp) AS inicio_mes,
        CAST('2026-09-01' AS timestamp) AS fin_mes_exclusivo,
        lower('jeyson.salazar@bold.co') AS ejecutivo_objetivo
),
merchant_scope (merchant_id) AS (
    VALUES
        ('GSYCJJ0ZMX'), ('0XV9992C0O'), ('GHTNMF7727'), ('TR2KLJUVZ6'),
        ('75H2G3UNCN'), ('LZ4FUN0WQD'), ('VUSTI8DA46'), ('54LXJZBNZ9'),
        ('XOP5AO97MP'), ('BVDN5HUB7R'), ('0BE18WOVV2'), ('NIV028B3MZ'),
        ('J7IML9IM9I'), ('3K2UR9MQ3O'), ('VS2MRZDVZL'), ('9OYGZJX2JZ'),
        ('IFZJ8WSLSE'), ('AVGU6FEYZ7'), ('NFBG4DGNTU'), ('NZ911L9FFZ'),
        ('HW9F3DLU6Y'), ('X12JGJK6HD'), ('6T666ZC1PC'), ('ND9E9BVEFH'),
        ('D3CSCWAZSN'), ('OL7HSSUC3Q'), ('3CH8FBJ9AN'), ('9O6561CJE9'),
        ('Z1OH7VNMNP'), ('GH9NAMTKQE'), ('8A1O5ELS22'), ('R1MFU4VEUU'),
        ('LNZJWX2CJM'), ('RINNZMPT6N'), ('JWB364BYJT'), ('U215EU8J7D'),
        ('J9QFIT63EE'), ('91VH6IUNEA'), ('MLMHGPOYCP'), ('AKKHBLNCCA'),
        ('GHYHY5RPOS'), ('NFUSJ7NQ96'), ('XMABPI8SDB'), ('O1ZWI9P1IS'),
        ('1KQZPLFRVW'), ('VXJZXFZCK5'), ('JXLFJ824NO'), ('PL0B5ER5G3')
),
merchant_base AS (
    SELECT
        trim(cast(m.id AS varchar)) AS merchant_id,
        m.name AS merchant_name,
        m.sales_source,
        lower(trim(coalesce(m.sales_agent_email, ''))) AS sales_agent_email,
        m.status__status_code AS status_code,
        m.manual_verification_status__reason_code AS verification_status_code,
        e._1st_transaction_approved_date AS primera_tx_historica,
        e.last_transaction_approved_date AS ultima_tx_historica
    FROM awsdatacatalog.bold_gold_payments.dim_merchant m
    INNER JOIN merchant_scope s
        ON trim(cast(m.id AS varchar)) = s.merchant_id
    LEFT JOIN awsdatacatalog.bold_gold_growth.mart_merchant_enrich e
        ON trim(cast(e.merchant_id AS varchar)) = trim(cast(m.id AS varchar))
    CROSS JOIN parametros p
    WHERE upper(trim(coalesce(m.sales_source, ''))) = 'ENTERPRISE'
      AND lower(trim(coalesce(m.sales_agent_email, ''))) = p.ejecutivo_objetivo
),
tpv_agosto AS (
    SELECT
        trim(cast(t.merchant_id AS varchar)) AS merchant_id,
        sum(coalesce(t.tpv, 0)) AS tpv_bruto_agosto,
        sum(coalesce(t.paid_tpv, 0)) AS tpv_pagado_agosto,
        sum(coalesce(t.net_tpv, 0)) AS tpv_neto_agosto,
        count(DISTINCT t.transaction_id) AS transacciones_agosto,
        min(t.creation_datetime) AS primera_tx_observada_agosto,
        max(t.creation_datetime) AS ultima_tx_observada_agosto
    FROM awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction t
    INNER JOIN merchant_base m
        ON trim(cast(t.merchant_id AS varchar)) = m.merchant_id
    CROSS JOIN parametros p
    WHERE t.creation_datetime >= p.inicio_mes
      AND t.creation_datetime < p.fin_mes_exclusivo
      AND t.terminal_serial IS NOT NULL
      AND coalesce(t.tpv, 0) > 0
    GROUP BY 1
),
detalle AS (
    SELECT
        m.*,
        a.tpv_bruto_agosto,
        a.tpv_pagado_agosto,
        a.tpv_neto_agosto,
        a.transacciones_agosto,
        a.primera_tx_observada_agosto,
        a.ultima_tx_observada_agosto,
        CASE
            WHEN m.primera_tx_historica >= CAST('2026-08-01' AS timestamp)
             AND m.primera_tx_historica < CAST('2026-09-01' AS timestamp)
             AND coalesce(a.tpv_bruto_agosto, 0) > 0
                THEN 'M0_ENTERPRISE_JEYSON'
            WHEN m.ultima_tx_historica < CAST('2026-02-01' AS timestamp)
             AND coalesce(a.tpv_bruto_agosto, 0) > 0
                THEN 'REACTIVACION_ENTERPRISE_JEYSON'
            WHEN coalesce(a.tpv_bruto_agosto, 0) > 0
                THEN 'CARTERA_ENTERPRISE_JEYSON'
            ELSE 'ENTERPRISE_JEYSON_SIN_TPV'
        END AS clasificacion_validacion
    FROM merchant_base m
    LEFT JOIN tpv_agosto a ON a.merchant_id = m.merchant_id
)
SELECT
    d.*,
    count(*) OVER () AS merchants_enterprise_jeyson,
    sum(CASE WHEN d.clasificacion_validacion = 'M0_ENTERPRISE_JEYSON' THEN 1 ELSE 0 END) OVER () AS merchants_m0_enterprise_jeyson,
    sum(coalesce(d.tpv_bruto_agosto, 0)) OVER () AS tpv_enterprise_jeyson_bruto,
    sum(coalesce(d.tpv_pagado_agosto, 0)) OVER () AS tpv_enterprise_jeyson_pagado,
    sum(CASE WHEN d.clasificacion_validacion = 'M0_ENTERPRISE_JEYSON' THEN coalesce(d.tpv_bruto_agosto, 0) ELSE 0 END) OVER () AS tpv_m0_enterprise_jeyson_bruto,
    sum(CASE WHEN d.clasificacion_validacion = 'M0_ENTERPRISE_JEYSON' THEN coalesce(d.tpv_pagado_agosto, 0) ELSE 0 END) OVER () AS tpv_m0_enterprise_jeyson_pagado
FROM detalle d
ORDER BY d.clasificacion_validacion, d.tpv_bruto_agosto DESC NULLS LAST, d.merchant_id
