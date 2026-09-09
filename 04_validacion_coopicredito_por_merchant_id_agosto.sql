WITH parametros AS (
    SELECT
        CAST('2026-08-01' AS timestamp) AS inicio_mes,
        CAST('2026-09-01' AS timestamp) AS fin_mes_exclusivo
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
merchant_dim AS (
    SELECT *
    FROM (
        SELECT
            trim(cast(m.id AS varchar)) AS merchant_id,
            m.name AS merchant_name,
            m.status__status_code AS status_code,
            m.manual_verification_status__reason_code AS verification_status_code,
            m.sales_source AS sales_source_raw,
            m.sales_agent_email,
            m.sales_reference,
            m.onboarding_end_date,
            m.document_type,
            m.document_number,
            row_number() OVER (
                PARTITION BY trim(cast(m.id AS varchar))
                ORDER BY m.onboarding_end_date DESC NULLS LAST
            ) AS rn
        FROM awsdatacatalog.bold_gold_payments.dim_merchant m
        INNER JOIN merchant_scope s
            ON trim(cast(m.id AS varchar)) = s.merchant_id
    ) x
    WHERE rn = 1
),
merchant_enrich AS (
    SELECT
        trim(cast(e.merchant_id AS varchar)) AS merchant_id,
        e.master_merchant_id,
        e.kyc_verification_status_date AS kyc_date,
        e._1st_transaction_approved_date AS primera_tx_historica,
        e.last_transaction_approved_date AS ultima_tx_historica,
        e._1st_match_date AS primera_vinculacion_historica
    FROM awsdatacatalog.bold_gold_growth.mart_merchant_enrich e
    INNER JOIN merchant_scope s
        ON trim(cast(e.merchant_id AS varchar)) = s.merchant_id
),
tpv_agosto AS (
    SELECT
        trim(cast(t.merchant_id AS varchar)) AS merchant_id,
        sum(coalesce(t.tpv, 0)) AS tpv_bruto_agosto,
        sum(coalesce(t.paid_tpv, 0)) AS tpv_pagado_agosto,
        sum(coalesce(t.net_tpv, 0)) AS tpv_neto_agosto,
        count(DISTINCT t.transaction_id) AS transacciones_agosto,
        min(t.creation_datetime) AS primera_tx_observada_agosto,
        max(t.creation_datetime) AS ultima_tx_observada_agosto,
        max(t.load_datetime) AS datos_actualizados_hasta
    FROM awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction t
    INNER JOIN merchant_scope s
        ON trim(cast(t.merchant_id AS varchar)) = s.merchant_id
    CROSS JOIN parametros p
    WHERE t.creation_datetime >= p.inicio_mes
      AND t.creation_datetime < p.fin_mes_exclusivo
      AND t.terminal_serial IS NOT NULL
      AND coalesce(t.tpv, 0) > 0
    GROUP BY 1
),
resultado AS (
    SELECT
        s.merchant_id,
        d.merchant_name,
        d.sales_source_raw,
        upper(trim(coalesce(d.sales_source_raw, 'SIN_CANAL'))) AS sales_source_normalizado,
        lower(trim(coalesce(d.sales_agent_email, ''))) AS sales_agent_email,
        d.status_code,
        d.verification_status_code,
        d.onboarding_end_date,
        d.sales_reference,
        e.master_merchant_id,
        e.kyc_date,
        e.primera_tx_historica,
        e.ultima_tx_historica,
        e.primera_vinculacion_historica,
        a.tpv_bruto_agosto,
        a.tpv_pagado_agosto,
        a.tpv_neto_agosto,
        a.transacciones_agosto,
        a.primera_tx_observada_agosto,
        a.ultima_tx_observada_agosto,
        a.datos_actualizados_hasta,
        CASE
            WHEN upper(trim(coalesce(d.sales_source_raw, ''))) = 'ENTERPRISE'
                THEN true ELSE false
        END AS sales_source_enterprise,
        CASE
            WHEN e.primera_tx_historica >= CAST('2026-08-01' AS timestamp)
             AND e.primera_tx_historica < CAST('2026-09-01' AS timestamp)
             AND coalesce(a.tpv_bruto_agosto, 0) > 0
                THEN 'M0_TRANSACCIONAL'
            WHEN e.ultima_tx_historica < CAST('2026-02-01' AS timestamp)
             AND coalesce(a.tpv_bruto_agosto, 0) > 0
                THEN 'REACTIVACION'
            WHEN coalesce(a.tpv_bruto_agosto, 0) > 0
                THEN 'CARTERA_EXISTENTE_O_TERMINAL_NUEVO'
            ELSE 'SIN_TPV_AGOSTO'
        END AS clasificacion_transaccional
    FROM merchant_scope s
    LEFT JOIN merchant_dim d ON d.merchant_id = s.merchant_id
    LEFT JOIN merchant_enrich e ON e.merchant_id = s.merchant_id
    LEFT JOIN tpv_agosto a ON a.merchant_id = s.merchant_id
)
SELECT
    r.*,
    count(*) OVER () AS merchants_scope,
    sum(CASE WHEN r.sales_source_enterprise THEN 1 ELSE 0 END) OVER () AS merchants_sales_source_enterprise,
    sum(CASE WHEN r.clasificacion_transaccional = 'M0_TRANSACCIONAL' THEN 1 ELSE 0 END) OVER () AS merchants_m0_transaccional,
    sum(coalesce(r.tpv_bruto_agosto, 0)) OVER () AS tpv_scope_bruto,
    sum(coalesce(r.tpv_pagado_agosto, 0)) OVER () AS tpv_scope_pagado,
    sum(CASE WHEN r.sales_source_enterprise THEN coalesce(r.tpv_bruto_agosto, 0) ELSE 0 END) OVER () AS tpv_sales_source_enterprise_bruto,
    sum(CASE WHEN r.sales_source_enterprise THEN coalesce(r.tpv_pagado_agosto, 0) ELSE 0 END) OVER () AS tpv_sales_source_enterprise_pagado,
    sum(CASE WHEN r.sales_source_enterprise AND r.clasificacion_transaccional = 'M0_TRANSACCIONAL' THEN coalesce(r.tpv_bruto_agosto, 0) ELSE 0 END) OVER () AS tpv_m0_enterprise_candidato_bruto,
    sum(CASE WHEN r.sales_source_enterprise AND r.clasificacion_transaccional = 'M0_TRANSACCIONAL' THEN coalesce(r.tpv_pagado_agosto, 0) ELSE 0 END) OVER () AS tpv_m0_enterprise_candidato_pagado
FROM resultado r
ORDER BY r.sales_source_enterprise DESC, r.tpv_bruto_agosto DESC NULLS LAST, r.merchant_id
