-- ============================================================
-- COOPICRÉDITO | TPV MENSUAL Y CANAL
-- Entrada: "Coopicrédito Agosto Merchants" (48 merchant_id)
-- Athena / Trino desde Metabase. Solo lectura.
--
-- Para reutilizarla cada mes, cambiar únicamente inicio_mes y
-- fin_mes_exclusivo en parametros. El intervalo es [inicio, fin).
-- ============================================================

WITH parametros AS (
    SELECT
        CAST('2026-08-01' AS date) AS inicio_mes,
        CAST('2026-09-01' AS date) AS fin_mes_exclusivo
),

merchant_scope_raw (merchant_id) AS (
    VALUES
        ('JA82FIY0Z4'),
        ('BTJHGRLYXZ'),
        ('9I8LY96BBG'),
        ('H7H258JKKS'),
        ('GSYCJJ0ZMX'),
        ('TR2KLJUVZ6'),
        ('75H2G3UNCN'),
        ('LZ4FUN0WQD'),
        ('VUSTI8DA46'),
        ('54LXJZBNZ9'),
        ('XOP5AO97MP'),
        ('BVDN5HUB7R'),
        ('0BE18WOVV2'),
        ('NIV028B3MZ'),
        ('J7IML9IM9I'),
        ('3K2UR9MQ3O'),
        ('VS2MRZDVZL'),
        ('9OYGZJX2JZ'),
        ('IFZJ8WSLSE'),
        ('AVGU6FEYZ7'),
        ('NFBG4DGNTU'),
        ('NZ911L9FFZ'),
        ('HW9F3DLU6Y'),
        ('X12JGJK6HD'),
        ('6T666ZC1PC'),
        ('ND9E9BVEFH'),
        ('D3CSCWAZSN'),
        ('OL7HSSUC3Q'),
        ('3CH8FBJ9AN'),
        ('9O6561CJE9'),
        ('Z1OH7VNMNP'),
        ('GH9NAMTKQE'),
        ('8A1O5ELS22'),
        ('R1MFU4VEUU'),
        ('LNZJWX2CJM'),
        ('RINNZMPT6N'),
        ('JWB364BYJT'),
        ('U215EU8J7D'),
        ('J9QFIT63EE'),
        ('91VH6IUNEA'),
        ('MLMHGPOYCP'),
        ('AKKHBLNCCA'),
        ('GHYHY5RPOS'),
        ('NFUSJ7NQ96'),
        ('GSYCJJ0ZMX'),
        ('O1ZWI9P1IS'),
        ('VXJZXFZCK5'),
        ('0XV9992C0O')
),

merchant_scope AS (
    SELECT DISTINCT merchant_id
    FROM merchant_scope_raw
),

client_ranked AS (
    SELECT
        trim(cast(c.merchant_id AS varchar)) AS merchant_id,
        c.merchant_name,
        c.merchant_identification_document_type AS document_type,
        cast(c.merchant_identification_document_number AS varchar) AS document_number,
        c.merchant_acquisition_channel_source AS acquisition_channel_source,
        c.merchant_acquisition_channel_value AS acquisition_channel_value,
        c.sales_source,
        c.merchant_acquisition_channel_sales_agent_email AS sales_agent_email,
        c.status AS merchant_status,
        c.onboarding_status,
        c.last_update_event_date,
        row_number() OVER (
            PARTITION BY c.merchant_id
            ORDER BY c.last_update_event_date DESC NULLS LAST, c.creation_date DESC NULLS LAST
        ) AS rn
    FROM awsdatacatalog.bold_gold_growth.dim_client c
    INNER JOIN merchant_scope s
        ON trim(cast(c.merchant_id AS varchar)) = s.merchant_id
),

client_current AS (
    SELECT
        merchant_id,
        merchant_name,
        document_type,
        document_number,
        coalesce(
            nullif(upper(trim(acquisition_channel_source)), ''),
            nullif(upper(trim(acquisition_channel_value)), ''),
            nullif(upper(trim(sales_source)), ''),
            'SIN_CANAL'
        ) AS canal_actual,
        CASE
            WHEN nullif(upper(trim(acquisition_channel_source)), '') IS NOT NULL THEN 'DIM_CLIENT_SOURCE'
            WHEN nullif(upper(trim(acquisition_channel_value)), '') IS NOT NULL THEN 'DIM_CLIENT_VALUE'
            WHEN nullif(upper(trim(sales_source)), '') IS NOT NULL THEN 'DIM_CLIENT_SALES_SOURCE'
            ELSE 'SIN_FUENTE'
        END AS canal_fuente_utilizada,
        sales_agent_email,
        merchant_status,
        onboarding_status,
        last_update_event_date
    FROM client_ranked
    WHERE rn = 1
),

tpv_mes AS (
    SELECT
        trim(cast(t.merchant_id AS varchar)) AS merchant_id,
        sum(coalesce(t.tpv, 0)) AS tpv_periodo,
        sum(coalesce(t.paid_tpv, 0)) AS tpv_pagado_periodo,
        sum(coalesce(t.net_tpv, 0)) AS tpv_neto_periodo,
        count(DISTINCT t.transaction_id) AS transacciones_periodo,
        min(t.creation_datetime) AS primera_tx_periodo,
        max(t.creation_datetime) AS ultima_tx_periodo,
        max(t.load_datetime) AS datos_actualizados_hasta
    FROM awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction t
    INNER JOIN merchant_scope s
        ON trim(cast(t.merchant_id AS varchar)) = s.merchant_id
    CROSS JOIN parametros p
    WHERE t.creation_datetime >= cast(p.inicio_mes AS timestamp)
      AND t.creation_datetime < cast(p.fin_mes_exclusivo AS timestamp)
    GROUP BY 1
)

SELECT
    s.merchant_id,
    c.merchant_name,
    c.document_type,
    c.document_number,
    c.canal_actual,
    c.canal_fuente_utilizada,
    c.sales_agent_email,
    c.merchant_status,
    c.onboarding_status,
    coalesce(t.tpv_periodo, 0) AS tpv_periodo,
    coalesce(t.tpv_pagado_periodo, 0) AS tpv_pagado_periodo,
    coalesce(t.tpv_neto_periodo, 0) AS tpv_neto_periodo,
    coalesce(t.transacciones_periodo, 0) AS transacciones_periodo,
    t.primera_tx_periodo,
    t.ultima_tx_periodo,
    t.datos_actualizados_hasta,
    CASE
        WHEN c.merchant_id IS NULL THEN 'SIN_MATCH_DIM_CLIENT'
        WHEN t.merchant_id IS NULL THEN 'SIN_TPV_EN_PERIODO'
        ELSE 'CON_TPV_EN_PERIODO'
    END AS estado_tpv,
    c.last_update_event_date AS merchant_actualizado
FROM merchant_scope s
LEFT JOIN client_current c
    ON c.merchant_id = s.merchant_id
LEFT JOIN tpv_mes t
    ON t.merchant_id = s.merchant_id
ORDER BY tpv_periodo DESC, s.merchant_id;


----Answer

Only one sql statement is allowed. Got: -- ============================================================ -- COOPICRÉDITO | TPV MENSUAL Y CANAL -- Entrada: "Coopicrédito Agosto Merchants" (48 merchant_id) -- Athena / Trino desde Metabase. Solo lectura. -- -- Para reutilizarla cada mes, cambiar únicamente inicio_mes y -- fin_mes_exclusivo en parametros. El intervalo es [inicio, fin). -- ============================================================ WITH parametros AS ( SELECT CAST('2026-08-01' AS date) AS inicio_mes, CAST('2026-09-01' AS date) AS fin_mes_exclusivo ), merchant_scope_raw (merchant_id) AS ( VALUES ('JA82FIY0Z4'), ('BTJHGRLYXZ'), ('9I8LY96BBG'), ('H7H258JKKS'), ('GSYCJJ0ZMX'), ('TR2KLJUVZ6'), ('75H2G3UNCN'), ('LZ4FUN0WQD'), ('VUSTI8DA46'), ('54LXJZBNZ9'), ('XOP5AO97MP'), ('BVDN5HUB7R'), ('0BE18WOVV2'), ('NIV028B3MZ'), ('J7IML9IM9I'), ('3K2UR9MQ3O'), ('VS2MRZDVZL'), ('9OYGZJX2JZ'), ('IFZJ8WSLSE'), ('AVGU6FEYZ7'), ('NFBG4DGNTU'), ('NZ911L9FFZ'), ('HW9F3DLU6Y'), ('X12JGJK6HD'), ('6T666ZC1PC'), ('ND9E9BVEFH'), ('D3CSCWAZSN'), ('OL7HSSUC3Q'), ('3CH8FBJ9AN'), ('9O6561CJE9'), ('Z1OH7VNMNP'), ('GH9NAMTKQE'), ('8A1O5ELS22'), ('R1MFU4VEUU'), ('LNZJWX2CJM'), ('RINNZMPT6N'), ('JWB364BYJT'), ('U215EU8J7D'), ('J9QFIT63EE'), ('91VH6IUNEA'), ('MLMHGPOYCP'), ('AKKHBLNCCA'), ('GHYHY5RPOS'), ('NFUSJ7NQ96'), ('GSYCJJ0ZMX'), ('O1ZWI9P1IS'), ('VXJZXFZCK5'), ('0XV9992C0O') ), merchant_scope AS ( SELECT DISTINCT merchant_id FROM merchant_scope_raw ), client_ranked AS ( SELECT trim(cast(c.merchant_id AS varchar)) AS merchant_id, c.merchant_name, c.merchant_identification_document_type AS document_type, cast(c.merchant_identification_document_number AS varchar) AS document_number, c.merchant_acquisition_channel_source AS acquisition_channel_source, c.merchant_acquisition_channel_value AS acquisition_channel_value, c.sales_source, c.merchant_acquisition_channel_sales_agent_email AS sales_agent_email, c.status AS merchant_status, c.onboarding_status, c.last_update_event_date, row_number() OVER ( PARTITION BY c.merchant_id ORDER BY c.last_update_event_date DESC NULLS LAST, c.creation_date DESC NULLS LAST ) AS rn FROM awsdatacatalog.bold_gold_growth.dim_client c INNER JOIN merchant_scope s ON trim(cast(c.merchant_id AS varchar)) = s.merchant_id ), client_current AS ( SELECT merchant_id, merchant_name, document_type, document_number, coalesce( nullif(upper(trim(acquisition_channel_source)), ''), nullif(upper(trim(acquisition_channel_value)), ''), nullif(upper(trim(sales_source)), ''), 'SIN_CANAL' ) AS canal_actual, CASE WHEN nullif(upper(trim(acquisition_channel_source)), '') IS NOT NULL THEN 'DIM_CLIENT_SOURCE' WHEN nullif(upper(trim(acquisition_channel_value)), '') IS NOT NULL THEN 'DIM_CLIENT_VALUE' WHEN nullif(upper(trim(sales_source)), '') IS NOT NULL THEN 'DIM_CLIENT_SALES_SOURCE' ELSE 'SIN_FUENTE' END AS canal_fuente_utilizada, sales_agent_email, merchant_status, onboarding_status, last_update_event_date FROM client_ranked WHERE rn = 1 ), tpv_mes AS ( SELECT trim(cast(t.merchant_id AS varchar)) AS merchant_id, sum(coalesce(t.tpv, 0)) AS tpv_periodo, sum(coalesce(t.paid_tpv, 0)) AS tpv_pagado_periodo, sum(coalesce(t.net_tpv, 0)) AS tpv_neto_periodo, count(DISTINCT t.transaction_id) AS transacciones_periodo, min(t.creation_datetime) AS primera_tx_periodo, max(t.creation_datetime) AS ultima_tx_periodo, max(t.load_datetime) AS datos_actualizados_hasta FROM awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction t INNER JOIN merchant_scope s ON trim(cast(t.merchant_id AS varchar)) = s.merchant_id CROSS JOIN parametros p WHERE t.creation_datetime >= cast(p.inicio_mes AS timestamp) AND t.creation_datetime < cast(p.fin_mes_exclusivo AS timestamp) GROUP BY 1 ) SELECT s.merchant_id, c.merchant_name, c.document_type, c.document_number, c.canal_actual, c.canal_fuente_utilizada, c.sales_agent_email, c.merchant_status, c.onboarding_status, coalesce(t.tpv_periodo, 0) AS tpv_periodo, coalesce(t.tpv_pagado_periodo, 0) AS tpv_pagado_periodo, coalesce(t.tpv_neto_periodo, 0) AS tpv_neto_periodo, coalesce(t.transacciones_periodo, 0) AS transacciones_periodo, t.primera_tx_periodo, t.ultima_tx_periodo, t.datos_actualizados_hasta, CASE WHEN c.merchant_id IS NULL THEN 'SIN_MATCH_DIM_CLIENT' WHEN t.merchant_id IS NULL THEN 'SIN_TPV_EN_PERIODO' ELSE 'CON_TPV_EN_PERIODO' END AS estado_tpv, c.last_update_event_date AS merchant_actualizado FROM merchant_scope s LEFT JOIN client_current c ON c.merchant_id = s.merchant_id LEFT JOIN tpv_mes t ON t.merchant_id = s.merchant_id ORDER BY tpv_periodo DESC, s.merchant_id; -- Control opcional: reemplazar el SELECT final por este para validar el alcance. -- SELECT count(*) AS merchants_entrada, -- count(DISTINCT merchant_id) AS merchants_distintos -- FROM merchant_scope_raw;

-- Control opcional: reemplazar el SELECT final por este para validar el alcance.
-- SELECT count(*) AS merchants_entrada,
--        count(DISTINCT merchant_id) AS merchants_distintos
-- FROM merchant_scope_raw;
