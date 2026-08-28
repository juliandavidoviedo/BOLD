-- Athena / Trino SQL
-- Salida operativa: Fecha de Reporte, Merchant ID, Canal Actual,
-- Serial / producto, TPV M0, Asignar a canal y Ejecutivo.
-- Regla: seleccionar el terminal actualmente registrado al merchant cuya
-- primera transacción aprobada cae dentro del mes de gestión.

WITH
parametros AS (
    SELECT
        current_date AS fecha_reporte,
        date_trunc('month', current_date) AS inicio_mes_gestion,
        date_add('month', 1, date_trunc('month', current_date)) AS inicio_mes_siguiente,
        upper('ENTERPRISE') AS canal_destino,
        lower('juan.salgado@bold.co') AS ejecutivo_destino
),

merchants_fuente (source_row, merchant_id) AS (
    VALUES
        (1, 'GSYCJJ0ZMX'), (2, '0XV9992C0O'), (3, 'GHTNMF7727'),
        (4, 'TR2KLJUVZ6'), (5, '75H2G3UNCN'), (6, 'LZ4FUN0WQD'),
        (7, 'VUSTI8DA46'), (8, '54LXJZBNZ9'), (9, 'XOP5AO97MP'),
        (10, 'BVDN5HUB7R'), (11, '0BE18WOVV2'), (12, 'NIV028B3MZ'),
        (13, 'J7IML9IM9I'), (14, '3K2UR9MQ3O'), (15, 'VS2MRZDVZL'),
        (16, '9OYGZJX2JZ'), (17, 'IFZJ8WSLSE'), (18, 'AVGU6FEYZ7'),
        (19, 'NFBG4DGNTU'), (20, 'NZ911L9FFZ'), (21, 'HW9F3DLU6Y'),
        (22, 'X12JGJK6HD'), (23, '6T666ZC1PC'), (24, 'ND9E9BVEFH'),
        (25, 'D3CSCWAZSN'), (26, 'OL7HSSUC3Q'), (27, '3CH8FBJ9AN'),
        (28, '9O6561CJE9'), (29, 'Z1OH7VNMNP'), (30, 'GH9NAMTKQE'),
        (31, '8A1O5ELS22'), (32, 'R1MFU4VEUU'), (33, 'LNZJWX2CJM'),
        (34, 'RINNZMPT6N'), (35, 'JWB364BYJT'), (36, 'U215EU8J7D'),
        (37, 'J9QFIT63EE'), (38, '91VH6IUNEA'), (39, 'MLMHGPOYCP'),
        (40, 'AKKHBLNCCA'), (41, 'GHYHY5RPOS'), (42, 'NFUSJ7NQ96')
),

-- Se conserva el snapshot más reciente por merchant.
client_actual AS (
    SELECT *
    FROM (
        SELECT
            cast(c.merchant_id AS varchar) AS merchant_id,
            c.merchant_name,
            c.merchant_acquisition_channel_source AS canal_actual_fuente,
            c.merchant_acquisition_channel_value AS canal_actual_valor,
            c.merchant_acquisition_channel_sales_agent_email AS ejecutivo_actual_email,
            c.last_update_event_date,
            row_number() OVER (
                PARTITION BY c.merchant_id
                ORDER BY c.last_update_event_date DESC, c.creation_date DESC
            ) AS rn
        FROM awsdatacatalog.bold_gold_growth.dim_client c
        INNER JOIN merchants_fuente mf
            ON cast(c.merchant_id AS varchar) = mf.merchant_id
    ) x
    WHERE rn = 1
),

-- La columna _1st_transaction_approved_date es la fecha de primera transacción
-- aprobada del terminal en mart_terminal_enrich.
terminal_mes_ranked AS (
    SELECT
        mf.source_row,
        mf.merchant_id,
        cast(t.terminal_key AS varchar) AS terminal_key,
        cast(t.terminal_serial AS varchar) AS terminal_serial,
        coalesce(t.terminal_model, t.model_name_category) AS producto,
        t.current_terminal_status AS estado_terminal,
        cast(t."_1st_transaction_approved_date" AS timestamp) AS primera_transaccion_aprobada,
        coalesce(t.tpv_m0_since_terminal_activation, cast(0 AS decimal(38, 4))) AS tpv_m0,
        t.terminal_sales_source,
        t.terminal_sales_executive,
        t.load_datetime,
        row_number() OVER (
            PARTITION BY mf.merchant_id
            ORDER BY
                cast(t."_1st_transaction_approved_date" AS timestamp) ASC,
                t.last_terminal_match_date ASC,
                t.load_datetime DESC,
                t.terminal_key
        ) AS rn
    FROM merchants_fuente mf
    INNER JOIN awsdatacatalog.bold_gold_terminals.mart_terminal_enrich t
        ON mf.merchant_id = cast(t.last_terminal_match_merchant_id AS varchar)
    CROSS JOIN parametros p
    WHERE t.terminal_key IS NOT NULL
      AND t."_1st_transaction_approved_date" >= p.inicio_mes_gestion
      AND t."_1st_transaction_approved_date" < p.inicio_mes_siguiente
),
terminal_elegible AS (
    SELECT * FROM terminal_mes_ranked WHERE rn = 1
),

-- Se obtiene el ejecutivo asociado a la oportunidad más reciente del merchant.
opportunity_actual AS (
    SELECT *
    FROM (
        SELECT
            cast(coalesce(o.product_merchant_id, o.metadata_merchant_id) AS varchar) AS merchant_id,
            o.sales_channel AS canal_oportunidad,
            cast(o.user_id AS varchar) AS opportunity_user_id,
            upper(trim(o.status)) AS opportunity_status,
            o.last_update_date,
            row_number() OVER (
                PARTITION BY coalesce(o.product_merchant_id, o.metadata_merchant_id)
                ORDER BY o.last_update_date DESC, o.load_datetime DESC
            ) AS rn
        FROM awsdatacatalog.bold_gold_sales.dim_crm_opportunities o
        INNER JOIN merchants_fuente mf
            ON cast(coalesce(o.product_merchant_id, o.metadata_merchant_id) AS varchar) = mf.merchant_id
    ) x
    WHERE rn = 1
),
crm_user_actual AS (
    SELECT *
    FROM (
        SELECT
            cast(u.user_id AS varchar) AS user_id,
            lower(trim(u.email)) AS email_key,
            u.email,
            row_number() OVER (
                PARTITION BY u.user_id
                ORDER BY CASE WHEN upper(u.status) = 'ACTIVE' THEN 1 ELSE 0 END DESC,
                         u.load_datetime DESC
            ) AS rn
        FROM awsdatacatalog.bold_gold_sales.dim_crm_users u
    ) x
    WHERE rn = 1
)

SELECT
    date_format(p.fecha_reporte, '%d/%m/%Y') AS fecha_reporte,
    mf.merchant_id,
    coalesce(
        nullif(ce.canal_actual_fuente, ''),
        nullif(ce.canal_actual_valor, ''),
        nullif(oa.canal_oportunidad, ''),
        nullif(te.terminal_sales_source, ''),
        'SIN_CANAL'
    ) AS canal_actual,
    te.terminal_serial AS serial,
    te.producto,
    te.tpv_m0,
    p.canal_destino AS asignar_a_canal,
    p.ejecutivo_destino AS ejecutivo,
    te.primera_transaccion_aprobada,
    te.estado_terminal,
    te.terminal_sales_executive,
    ce.ejecutivo_actual_email,
    ou.email AS ejecutivo_oportunidad_actual,
    oa.opportunity_status,
    CASE
        WHEN te.terminal_key IS NULL THEN 'SIN_TERMINAL_CON_PRIMERA_TX_EN_MES'
        WHEN te.primera_transaccion_aprobada >= p.inicio_mes_gestion
         AND te.primera_transaccion_aprobada < p.inicio_mes_siguiente
            THEN 'CUMPLE_REGLA_PRIMERA_TX_MES_GESTION'
        ELSE 'NO_CUMPLE_REGLA'
    END AS estado_regla_terminal,
    CASE
        WHEN te.terminal_key IS NOT NULL
         AND te.primera_transaccion_aprobada >= p.inicio_mes_gestion
         AND te.primera_transaccion_aprobada < p.inicio_mes_siguiente
            THEN true
        ELSE false
    END AS incluir_en_solicitud_cambio
FROM merchants_fuente mf
CROSS JOIN parametros p
LEFT JOIN client_actual ce
    ON mf.merchant_id = ce.merchant_id
LEFT JOIN terminal_elegible te
    ON mf.merchant_id = te.merchant_id
LEFT JOIN opportunity_actual oa
    ON mf.merchant_id = oa.merchant_id
LEFT JOIN crm_user_actual ou
    ON oa.opportunity_user_id = ou.user_id
ORDER BY mf.source_row;
