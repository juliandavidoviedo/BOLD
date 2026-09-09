WITH parametros AS (
    SELECT
        CAST('2026-08-01' AS date) AS inicio_mes,
        CAST('2026-09-01' AS date) AS fin_mes_exclusivo,
        CAST('2026-02-01' AS date) AS corte_reactivacion
),

merchant_scope (source_row, merchant_id, reporte_ejecutivo) AS (
    VALUES
        (1, 'GSYCJJ0ZMX', 'NO NUEVO'),
        (2, '0XV9992C0O', 'NUEVO'),
        (3, 'GHTNMF7727', 'NUEVO'),
        (4, 'TR2KLJUVZ6', 'NUEVO'),
        (5, '75H2G3UNCN', 'NO NUEVO'),
        (6, 'LZ4FUN0WQD', 'NUEVO'),
        (7, 'VUSTI8DA46', 'NUEVO'),
        (8, '54LXJZBNZ9', 'NUEVO'),
        (9, 'XOP5AO97MP', 'NUEVO'),
        (10, 'BVDN5HUB7R', 'NUEVO'),
        (11, '0BE18WOVV2', 'NUEVO'),
        (12, 'NIV028B3MZ', 'NUEVO'),
        (13, 'J7IML9IM9I', 'NUEVO'),
        (14, '3K2UR9MQ3O', 'NUEVO'),
        (15, 'VS2MRZDVZL', 'NUEVO'),
        (16, '9OYGZJX2JZ', 'NUEVO'),
        (17, 'IFZJ8WSLSE', 'NUEVO'),
        (18, 'AVGU6FEYZ7', 'NUEVO'),
        (19, 'NFBG4DGNTU', 'NUEVO'),
        (20, 'NZ911L9FFZ', 'NUEVO'),
        (21, 'HW9F3DLU6Y', 'NUEVO'),
        (22, 'X12JGJK6HD', 'NUEVO'),
        (23, '6T666ZC1PC', 'NUEVO'),
        (24, 'ND9E9BVEFH', 'NUEVO'),
        (25, 'D3CSCWAZSN', 'NUEVO'),
        (26, 'OL7HSSUC3Q', 'NUEVO'),
        (27, '3CH8FBJ9AN', 'NUEVO'),
        (28, '9O6561CJE9', 'NUEVO'),
        (29, 'Z1OH7VNMNP', 'NUEVO'),
        (30, 'GH9NAMTKQE', 'NUEVO'),
        (31, '8A1O5ELS22', 'NUEVO'),
        (32, 'R1MFU4VEUU', 'NUEVO'),
        (33, 'LNZJWX2CJM', 'NUEVO'),
        (34, 'RINNZMPT6N', 'NUEVO'),
        (35, 'JWB364BYJT', 'NUEVO'),
        (36, 'U215EU8J7D', 'NUEVO'),
        (37, 'J9QFIT63EE', 'NUEVO'),
        (38, '91VH6IUNEA', 'NUEVO'),
        (39, 'MLMHGPOYCP', 'NUEVO'),
        (40, 'AKKHBLNCCA', 'NUEVO'),
        (41, 'GHYHY5RPOS', 'NUEVO'),
        (42, 'NFUSJ7NQ96', 'NUEVO'),
        (43, 'XMABPI8SDB', 'NUEVO'),
        (44, 'O1ZWI9P1IS', 'NUEVO'),
        (45, '1KQZPLFRVW', 'NUEVO'),
        (46, 'VXJZXFZCK5', 'NUEVO'),
        (47, 'JXLFJ824NO', 'NUEVO'),
        (48, 'PL0B5ER5G3', 'SIN_CLASIFICAR')
),

client_ranked AS (
    SELECT
        trim(cast(c.merchant_id AS varchar)) AS merchant_id,
        c.merchant_name,
        CAST(c.creation_date AS date) AS merchant_creation_date,
        CAST(c.onboarding_completion_date AS date) AS onboarding_completion_date,
        c.status AS merchant_status,
        c.onboarding_status,
        c.sales_source,
        c.merchant_acquisition_channel_source AS acquisition_channel_source,
        c.merchant_acquisition_channel_value AS acquisition_channel_value,
        c.merchant_acquisition_channel_sales_agent_email AS ejecutivo_dim,
        c.last_update_event_date,
        row_number() OVER (
            PARTITION BY trim(cast(c.merchant_id AS varchar))
            ORDER BY c.last_update_event_date DESC NULLS LAST,
                     c.creation_date DESC NULLS LAST
        ) AS rn
    FROM awsdatacatalog.bold_gold_growth.dim_client c
    INNER JOIN merchant_scope s
        ON trim(cast(c.merchant_id AS varchar)) = s.merchant_id
),

client_current AS (
    SELECT *
    FROM client_ranked
    WHERE rn = 1
),

tx_historico AS (
    SELECT
        trim(cast(t.merchant_id AS varchar)) AS merchant_id,
        min(t.creation_datetime) AS primera_tx_historica,
        max(CASE WHEN t.creation_datetime < CAST(p.inicio_mes AS timestamp)
                 THEN t.creation_datetime END) AS ultima_tx_antes_agosto,
        count(DISTINCT CASE WHEN t.creation_datetime < CAST(p.inicio_mes AS timestamp)
                            THEN t.transaction_id END) AS transacciones_antes_agosto
    FROM awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction t
    INNER JOIN merchant_scope s
        ON trim(cast(t.merchant_id AS varchar)) = s.merchant_id
    CROSS JOIN parametros p
    WHERE t.terminal_serial IS NOT NULL
      AND coalesce(t.tpv, 0) > 0
    GROUP BY 1
),

tx_agosto AS (
    SELECT
        trim(cast(t.merchant_id AS varchar)) AS merchant_id,
        sum(coalesce(t.tpv, 0)) AS tpv_bruto_agosto,
        sum(coalesce(t.paid_tpv, 0)) AS tpv_pagado_agosto,
        sum(coalesce(t.net_tpv, 0)) AS tpv_neto_agosto,
        count(DISTINCT t.transaction_id) AS transacciones_agosto,
        min(t.creation_datetime) AS primera_tx_agosto,
        max(t.creation_datetime) AS ultima_tx_agosto,
        max(t.load_datetime) AS datos_actualizados_hasta
    FROM awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction t
    INNER JOIN merchant_scope s
        ON trim(cast(t.merchant_id AS varchar)) = s.merchant_id
    CROSS JOIN parametros p
    WHERE t.creation_datetime >= CAST(p.inicio_mes AS timestamp)
      AND t.creation_datetime < CAST(p.fin_mes_exclusivo AS timestamp)
      AND t.terminal_serial IS NOT NULL
      AND coalesce(t.tpv, 0) > 0
    GROUP BY 1
),

opportunity_ranked AS (
    SELECT
        trim(cast(coalesce(o.product_merchant_id, o.metadata_merchant_id) AS varchar)) AS merchant_id,
        cast(o.opportunity_id AS varchar) AS opportunity_id,
        o.status AS opportunity_status,
        o.sales_channel AS opportunity_sales_channel,
        o.opportunity_type,
        o.management_type,
        cast(o.user_id AS varchar) AS opportunity_user_id,
        o.creation_date AS opportunity_creation_date,
        o.won_date,
        o.activation_date,
        row_number() OVER (
            PARTITION BY trim(cast(coalesce(o.product_merchant_id, o.metadata_merchant_id) AS varchar))
            ORDER BY coalesce(o.activation_date, o.won_date, o.creation_date, o.last_update_date) DESC NULLS LAST,
                     o.load_datetime DESC NULLS LAST
        ) AS rn
    FROM awsdatacatalog.bold_gold_sales.dim_crm_opportunities o
    INNER JOIN merchant_scope s
        ON trim(cast(coalesce(o.product_merchant_id, o.metadata_merchant_id) AS varchar)) = s.merchant_id
),

opportunity_current AS (
    SELECT *
    FROM opportunity_ranked
    WHERE rn = 1
),

base AS (
    SELECT
        s.source_row,
        s.merchant_id,
        s.reporte_ejecutivo,
        c.merchant_name,
        c.merchant_creation_date,
        c.onboarding_completion_date,
        c.merchant_status,
        c.onboarding_status,
        c.sales_source,
        c.acquisition_channel_source,
        c.acquisition_channel_value,
        c.ejecutivo_dim,
        o.opportunity_id,
        o.opportunity_status,
        o.opportunity_sales_channel,
        o.opportunity_type,
        o.management_type,
        o.opportunity_creation_date,
        o.won_date,
        o.activation_date,
        h.primera_tx_historica,
        h.ultima_tx_antes_agosto,
        h.transacciones_antes_agosto,
        a.tpv_bruto_agosto,
        a.tpv_pagado_agosto,
        a.tpv_neto_agosto,
        a.transacciones_agosto,
        a.primera_tx_agosto,
        a.ultima_tx_agosto,
        a.datos_actualizados_hasta
    FROM merchant_scope s
    LEFT JOIN client_current c ON c.merchant_id = s.merchant_id
    LEFT JOIN opportunity_current o ON o.merchant_id = s.merchant_id
    LEFT JOIN tx_historico h ON h.merchant_id = s.merchant_id
    LEFT JOIN tx_agosto a ON a.merchant_id = s.merchant_id
),

clasificado AS (
    SELECT
        b.*,
        CASE WHEN upper(trim(coalesce(b.sales_source, ''))) = 'ENTERPRISE'
             THEN true ELSE false END AS sales_source_enterprise,
        CASE
            WHEN upper(trim(coalesce(b.sales_source, ''))) = 'ENTERPRISE'
             AND b.primera_tx_historica >= CAST('2026-08-01' AS timestamp)
             AND b.primera_tx_historica < CAST('2026-09-01' AS timestamp)
             AND b.merchant_creation_date >= CAST('2026-08-01' AS date)
             AND b.merchant_creation_date < CAST('2026-09-01' AS date)
             AND coalesce(b.tpv_bruto_agosto, 0) > 0
                THEN 'M0_ENTERPRISE_VALIDADO'
            WHEN upper(trim(coalesce(b.sales_source, ''))) = 'ENTERPRISE'
             AND b.primera_tx_historica >= CAST('2026-08-01' AS timestamp)
             AND b.primera_tx_historica < CAST('2026-09-01' AS timestamp)
             AND coalesce(b.tpv_bruto_agosto, 0) > 0
             AND (
                    b.merchant_creation_date IS NULL
                 OR b.merchant_creation_date < CAST('2026-08-01' AS date)
                 OR b.merchant_creation_date >= CAST('2026-09-01' AS date)
                 OR b.opportunity_id IS NULL
                 OR upper(trim(coalesce(b.reporte_ejecutivo, ''))) = 'NUEVO'
             )
                THEN 'M0_ENTERPRISE_PENDIENTE_VALIDACION'
            WHEN upper(trim(coalesce(b.sales_source, ''))) = 'ENTERPRISE'
             AND b.ultima_tx_antes_agosto IS NOT NULL
             AND b.ultima_tx_antes_agosto < CAST('2026-02-01' AS timestamp)
             AND coalesce(b.tpv_bruto_agosto, 0) > 0
                THEN 'REACTIVACION_ENTERPRISE'
            WHEN upper(trim(coalesce(b.sales_source, ''))) = 'ENTERPRISE'
             AND coalesce(b.tpv_bruto_agosto, 0) > 0
                THEN 'CARTERA_EXISTENTE_ENTERPRISE'
            WHEN upper(trim(coalesce(b.sales_source, ''))) = 'ENTERPRISE'
             AND coalesce(b.tpv_bruto_agosto, 0) = 0
                THEN 'ENTERPRISE_SIN_TPV_AGOSTO'
            WHEN coalesce(b.tpv_bruto_agosto, 0) > 0
                THEN 'TPV_SIN_SALES_SOURCE_ENTERPRISE'
            WHEN upper(trim(coalesce(b.reporte_ejecutivo, ''))) = 'NUEVO'
                THEN 'NUEVO_REPORTADO_SIN_SALES_SOURCE'
            ELSE 'SIN_TPV'
        END AS clasificacion_cierre,
        CASE
            WHEN b.opportunity_id IS NULL THEN 'SIN_OPORTUNIDAD_EPIC'
            WHEN upper(trim(coalesce(b.opportunity_status, ''))) IN ('WON', 'CLOSED_WON', 'GANADA')
                THEN 'OPORTUNIDAD_CERRADA'
            ELSE 'OPORTUNIDAD_ABIERTA_O_NO_GANADA'
        END AS estado_epic
    FROM base b
)

SELECT
    c.*,
    coalesce(c.tpv_bruto_agosto, 0) AS tpv_gestionado_bruto,
    coalesce(c.tpv_pagado_agosto, 0) AS tpv_gestionado_pagado,
    count(*) OVER (PARTITION BY c.clasificacion_cierre) AS merchants_clasificacion,
    sum(coalesce(c.tpv_bruto_agosto, 0)) OVER (PARTITION BY c.clasificacion_cierre) AS tpv_clasificacion_bruto,
    sum(coalesce(c.tpv_pagado_agosto, 0)) OVER (PARTITION BY c.clasificacion_cierre) AS tpv_clasificacion_pagado,
    sum(coalesce(c.tpv_bruto_agosto, 0)) OVER () AS tpv_total_scope_bruto,
    sum(coalesce(c.tpv_pagado_agosto, 0)) OVER () AS tpv_total_scope_pagado
FROM clasificado c
ORDER BY c.clasificacion_cierre, c.tpv_bruto_agosto DESC NULLS LAST, c.merchant_id
