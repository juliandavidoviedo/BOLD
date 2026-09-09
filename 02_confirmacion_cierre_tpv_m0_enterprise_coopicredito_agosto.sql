WITH parametros AS (
    SELECT
        CAST('2026-08-01' AS date) AS inicio_mes,
        CAST('2026-09-01' AS date) AS fin_mes_exclusivo,
        date_add('month', -6, CAST('2026-08-01' AS date)) AS inicio_ventana_reactivacion
),

merchant_scope_raw (merchant_id) AS (
    VALUES
        ('JA82FIY0Z4'), ('BTJHGRLYXZ'), ('9I8LY96BBG'), ('H7H258JKKS'), ('GSYCJJ0ZMX'),
        ('TR2KLJUVZ6'), ('75H2G3UNCN'), ('LZ4FUN0WQD'), ('VUSTI8DA46'), ('54LXJZBNZ9'),
        ('XOP5AO97MP'), ('BVDN5HUB7R'), ('0BE18WOVV2'), ('NIV028B3MZ'), ('J7IML9IM9I'),
        ('3K2UR9MQ3O'), ('VS2MRZDVZL'), ('9OYGZJX2JZ'), ('IFZJ8WSLSE'), ('AVGU6FEYZ7'),
        ('NFBG4DGNTU'), ('NZ911L9FFZ'), ('HW9F3DLU6Y'), ('X12JGJK6HD'), ('6T666ZC1PC'),
        ('ND9E9BVEFH'), ('D3CSCWAZSN'), ('OL7HSSUC3Q'), ('3CH8FBJ9AN'), ('9O6561CJE9'),
        ('Z1OH7VNMNP'), ('GH9NAMTKQE'), ('8A1O5ELS22'), ('R1MFU4VEUU'), ('LNZJWX2CJM'),
        ('RINNZMPT6N'), ('JWB364BYJT'), ('U215EU8J7D'), ('J9QFIT63EE'), ('91VH6IUNEA'),
        ('MLMHGPOYCP'), ('AKKHBLNCCA'), ('GHYHY5RPOS'), ('NFUSJ7NQ96'), ('GSYCJJ0ZMX'),
        ('O1ZWI9P1IS'), ('VXJZXFZCK5'), ('0XV9992C0O')
),

merchant_scope AS (
    SELECT DISTINCT trim(cast(merchant_id AS varchar)) AS merchant_id
    FROM merchant_scope_raw
),

client_ranked AS (
    SELECT
        trim(cast(c.merchant_id AS varchar)) AS merchant_id,
        c.merchant_name,
        c.creation_date AS merchant_creation_date,
        c.onboarding_completion_date,
        c.status AS merchant_status,
        c.onboarding_status,
        c.merchant_acquisition_channel_source,
        c.merchant_acquisition_channel_value,
        c.sales_source,
        c.merchant_acquisition_channel_sales_agent_email AS ejecutivo_dim,
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
    SELECT
        merchant_id,
        merchant_name,
        merchant_creation_date,
        onboarding_completion_date,
        merchant_status,
        onboarding_status,
        coalesce(
            nullif(upper(trim(merchant_acquisition_channel_source)), ''),
            nullif(upper(trim(merchant_acquisition_channel_value)), ''),
            nullif(upper(trim(sales_source)), ''),
            'SIN_CANAL'
        ) AS canal_dim,
        ejecutivo_dim
    FROM client_ranked
    WHERE rn = 1
),

opportunity_ranked AS (
    SELECT
        s.merchant_id,
        cast(o.opportunity_id AS varchar) AS opportunity_id,
        o.status AS opportunity_status,
        o.lost_status,
        o.sales_channel AS opportunity_sales_channel,
        o.opportunity_type,
        o.management_type,
        o.is_terminal_reassignment,
        o.previous_user,
        o.origin_name,
        o.origin_description,
        o.creation_date AS opportunity_creation_date,
        o.won_date,
        o.activation_date,
        cast(o.user_id AS varchar) AS opportunity_user_id,
        o.last_update_date,
        o.load_datetime,
        row_number() OVER (
            PARTITION BY s.merchant_id
            ORDER BY
                CASE
                    WHEN o.activation_date >= p.inicio_mes AND o.activation_date < p.fin_mes_exclusivo THEN 1
                    WHEN o.won_date >= p.inicio_mes AND o.won_date < p.fin_mes_exclusivo THEN 2
                    WHEN o.creation_date >= p.inicio_mes AND o.creation_date < p.fin_mes_exclusivo THEN 3
                    ELSE 4
                END,
                coalesce(o.activation_date, o.won_date, o.creation_date, o.last_update_date) DESC NULLS LAST,
                o.load_datetime DESC NULLS LAST
        ) AS rn
    FROM merchant_scope s
    CROSS JOIN parametros p
    LEFT JOIN awsdatacatalog.bold_gold_sales.dim_crm_opportunities o
        ON s.merchant_id = trim(cast(coalesce(o.product_merchant_id, o.metadata_merchant_id) AS varchar))
),

opportunity_current AS (
    SELECT *
    FROM opportunity_ranked
    WHERE rn = 1
),

crm_user_ranked AS (
    SELECT
        cast(u.user_id AS varchar) AS user_id,
        lower(trim(u.email)) AS ejecutivo_oportunidad,
        cast(u.parent_id AS varchar) AS team_lead_user_id,
        u.role,
        u.sales_channel,
        u.status,
        row_number() OVER (
            PARTITION BY cast(u.user_id AS varchar)
            ORDER BY CASE WHEN upper(u.status) = 'ACTIVE' THEN 1 ELSE 0 END DESC,
                     u.load_datetime DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_sales.dim_crm_users u
),

crm_user_current AS (
    SELECT user_id, ejecutivo_oportunidad, team_lead_user_id, role, sales_channel, status
    FROM crm_user_ranked
    WHERE rn = 1
),

tx_historico AS (
    SELECT
        trim(cast(t.merchant_id AS varchar)) AS merchant_id,
        min(t.creation_datetime) AS primera_tx_historica,
        max(CASE WHEN t.creation_datetime < p.inicio_mes THEN t.creation_datetime END) AS ultima_tx_antes_agosto,
        count(DISTINCT CASE WHEN t.creation_datetime < p.inicio_mes THEN t.transaction_id END) AS transacciones_antes_agosto
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
    WHERE t.creation_datetime >= cast(p.inicio_mes AS timestamp)
      AND t.creation_datetime < cast(p.fin_mes_exclusivo AS timestamp)
      AND t.terminal_serial IS NOT NULL
      AND coalesce(t.tpv, 0) > 0
    GROUP BY 1
),

base AS (
    SELECT
        s.merchant_id,
        c.merchant_name,
        c.merchant_creation_date,
        c.onboarding_completion_date,
        c.merchant_status,
        c.onboarding_status,
        c.canal_dim,
        c.ejecutivo_dim,
        o.opportunity_id,
        o.opportunity_status,
        o.opportunity_sales_channel,
        o.opportunity_type,
        o.management_type,
        o.is_terminal_reassignment,
        o.previous_user,
        o.origin_name,
        o.opportunity_creation_date,
        o.won_date,
        o.activation_date,
        u.ejecutivo_oportunidad,
        u.role AS oportunidad_role,
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
    LEFT JOIN crm_user_current u ON u.user_id = o.opportunity_user_id
    LEFT JOIN tx_historico h ON h.merchant_id = s.merchant_id
    LEFT JOIN tx_agosto a ON a.merchant_id = s.merchant_id
),

clasificado AS (
    SELECT
        b.*,
        CASE
            WHEN b.primera_tx_historica >= CAST('2026-08-01' AS timestamp)
             AND b.primera_tx_historica <  CAST('2026-09-01' AS timestamp)
             AND b.merchant_creation_date >= CAST('2026-08-01' AS timestamp)
             AND b.merchant_creation_date <  CAST('2026-09-01' AS timestamp)
             AND coalesce(b.activation_date, b.won_date, b.opportunity_creation_date) >= CAST('2026-08-01' AS timestamp)
             AND coalesce(b.activation_date, b.won_date, b.opportunity_creation_date) <  CAST('2026-09-01' AS timestamp)
                THEN 'NUEVO_PURO_ENTERPRISE_PENDIENTE_VALIDAR_VINCULACION'
            WHEN b.ultima_tx_antes_agosto IS NOT NULL
             AND b.ultima_tx_antes_agosto < CAST('2026-02-01' AS timestamp)
             AND b.transacciones_agosto > 0
                THEN 'REACTIVACION'
            WHEN upper(coalesce(b.opportunity_type, '')) LIKE '%EXPANS%'
              OR upper(coalesce(b.management_type, '')) LIKE '%EXPANS%'
                THEN 'EXPANSION'
            WHEN b.previous_user IS NOT NULL
              OR upper(cast(b.is_terminal_reassignment AS varchar)) IN ('TRUE', '1', 'YES')
                THEN 'ASIGNADO_MISION'
            WHEN b.transacciones_agosto > 0
                THEN 'CARTERA_EXISTENTE_O_ASIGNADA_REVISAR'
            ELSE 'VINCULADO_SIN_PRIMERA_TX'
        END AS categoria_principal,
        CASE
            WHEN b.opportunity_id IS NULL THEN 'SIN_OPORTUNIDAD_CRM'
            WHEN b.primera_tx_historica IS NULL THEN 'SIN_TX_HISTORICA'
            WHEN coalesce(b.transacciones_agosto, 0) = 0 THEN 'SIN_TX_AGOSTO'
            WHEN b.canal_dim = 'ENTERPRISE' OR upper(coalesce(b.opportunity_sales_channel, '')) = 'ENTERPRISE'
                THEN 'ATRIBUCION_ENTERPRISE_EN_ALGUNA_FUENTE'
            ELSE 'REVISAR_CANAL_ORIGEN'
        END AS estado_evidencia
    FROM base b
)

SELECT
    c.*,
    coalesce(c.tpv_bruto_agosto, 0) AS tpv_gestionado_bruto,
    coalesce(c.tpv_pagado_agosto, 0) AS tpv_gestionado_pagado,
    CASE
        WHEN c.categoria_principal LIKE 'NUEVO_PURO%' THEN 'NUEVO_PURO'
        WHEN c.categoria_principal = 'REACTIVACION' THEN 'RECUPERADO'
        WHEN c.categoria_principal IN ('ASIGNADO_MISION', 'EXPANSION') THEN 'GESTION_SOBRE_BASE_EXISTENTE'
        WHEN c.categoria_principal = 'VINCULADO_SIN_PRIMERA_TX' THEN 'RIESGO_ACTIVACION'
        ELSE 'CARTERA_NO_NUEVA'
    END AS grupo_cierre,
    CASE
        WHEN c.transacciones_agosto IS NULL OR c.transacciones_agosto = 0 THEN 'RIESGO_SIN_TX'
        WHEN c.categoria_principal = 'REACTIVACION' AND c.tpv_bruto_agosto IS NULL THEN 'RIESGO_REACTIVACION'
        WHEN c.opportunity_id IS NULL THEN 'RIESGO_SIN_OPORTUNIDAD'
        WHEN c.canal_dim IS NULL OR c.canal_dim = 'SIN_CANAL' THEN 'RIESGO_SIN_CANAL_DIM'
        ELSE 'OK_PARA_REVISION'
    END AS riesgo_operativo,
    count(*) OVER (
        PARTITION BY
        CASE
            WHEN c.categoria_principal LIKE 'NUEVO_PURO%' THEN 'NUEVO_PURO'
            WHEN c.categoria_principal = 'REACTIVACION' THEN 'RECUPERADO'
            WHEN c.categoria_principal IN ('ASIGNADO_MISION', 'EXPANSION') THEN 'GESTION_SOBRE_BASE_EXISTENTE'
            WHEN c.categoria_principal = 'VINCULADO_SIN_PRIMERA_TX' THEN 'RIESGO_ACTIVACION'
            ELSE 'CARTERA_NO_NUEVA'
        END
    ) AS merchants_grupo_cierre,
    sum(coalesce(c.tpv_bruto_agosto, 0)) OVER (
        PARTITION BY
        CASE
            WHEN c.categoria_principal LIKE 'NUEVO_PURO%' THEN 'NUEVO_PURO'
            WHEN c.categoria_principal = 'REACTIVACION' THEN 'RECUPERADO'
            WHEN c.categoria_principal IN ('ASIGNADO_MISION', 'EXPANSION') THEN 'GESTION_SOBRE_BASE_EXISTENTE'
            WHEN c.categoria_principal = 'VINCULADO_SIN_PRIMERA_TX' THEN 'RIESGO_ACTIVACION'
            ELSE 'CARTERA_NO_NUEVA'
        END
    ) AS tpv_grupo_cierre_bruto,
    sum(coalesce(c.tpv_pagado_agosto, 0)) OVER (
        PARTITION BY
        CASE
            WHEN c.categoria_principal LIKE 'NUEVO_PURO%' THEN 'NUEVO_PURO'
            WHEN c.categoria_principal = 'REACTIVACION' THEN 'RECUPERADO'
            WHEN c.categoria_principal IN ('ASIGNADO_MISION', 'EXPANSION') THEN 'GESTION_SOBRE_BASE_EXISTENTE'
            WHEN c.categoria_principal = 'VINCULADO_SIN_PRIMERA_TX' THEN 'RIESGO_ACTIVACION'
            ELSE 'CARTERA_NO_NUEVA'
        END
    ) AS tpv_grupo_cierre_pagado,
    sum(coalesce(c.tpv_bruto_agosto, 0)) OVER () AS tpv_total_scope_bruto,
    sum(coalesce(c.tpv_pagado_agosto, 0)) OVER () AS tpv_total_scope_pagado
FROM clasificado c
ORDER BY grupo_cierre, tpv_gestionado_bruto DESC NULLS LAST, c.merchant_id
