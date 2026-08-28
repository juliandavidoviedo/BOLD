-- CONSULTA OPERATIVA COOPICRÉDITO - 42 MERCHANTS
-- Athena / Trino
-- Ejecutar en agosto de 2026 o cambiar solo los parámetros del bloque parametros.
-- El bloque merchants_coopicredito contiene exclusivamente el universo del archivo.

WITH
parametros AS (
    SELECT
        CAST('2026-08-01' AS date) AS inicio_mes,
        date_add('month', 1, CAST('2026-08-01' AS date)) AS inicio_mes_siguiente,
        CAST('2026-08-28' AS date) AS fecha_reporte,
        'ENTERPRISE' AS canal_destino,
        'jeyson.salazar@bold.co' AS ejecutivo_destino
),

merchants_coopicredito (source_row, merchant_id) AS (
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

-- Primera transacción aprobada HISTÓRICA por merchant y serial; después se
-- conserva únicamente el serial cuya primera transacción cae en el mes de gestión.
tx_por_serial AS (
    SELECT
        m.source_row,
        cast(t.merchant_id AS varchar) AS merchant_id,
        upper(trim(cast(t.terminal_serial AS varchar))) AS serial,
        min(t.creation_datetime) AS primera_tx_serial,
        sum(CASE WHEN t.creation_datetime >= p.inicio_mes
                  AND t.creation_datetime < p.inicio_mes_siguiente
                 THEN coalesce(t.tpv, 0) ELSE 0 END) AS tpv_m0_serial,
        count(CASE WHEN t.creation_datetime >= p.inicio_mes
                    AND t.creation_datetime < p.inicio_mes_siguiente
                   THEN 1 END) AS transacciones_m0_serial
    FROM merchants_coopicredito m
    INNER JOIN awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction t
        ON m.merchant_id = cast(t.merchant_id AS varchar)
    CROSS JOIN parametros p
    WHERE t.terminal_serial IS NOT NULL
      AND coalesce(t.tpv, 0) > 0
    GROUP BY
        m.source_row,
        cast(t.merchant_id AS varchar),
        upper(trim(cast(t.terminal_serial AS varchar))),
        p.inicio_mes,
        p.inicio_mes_siguiente
    HAVING min(t.creation_datetime) >= p.inicio_mes
       AND min(t.creation_datetime) < p.inicio_mes_siguiente
),

terminal_elegible AS (
    SELECT *
    FROM (
        SELECT
            x.*,
            row_number() OVER (
                PARTITION BY x.merchant_id
                ORDER BY x.primera_tx_serial ASC, x.serial
            ) AS rn
        FROM tx_por_serial x
    ) y
    WHERE rn = 1
),

terminal_detail AS (
    SELECT *
    FROM (
        SELECT
            te.*,
            coalesce(mt.terminal_model, mt.model_name_category) AS producto,
            mt.current_terminal_status AS estado_terminal,
            mt.last_terminal_match_date,
            mt.load_datetime,
            row_number() OVER (
                PARTITION BY te.merchant_id, te.serial
                ORDER BY mt.last_terminal_match_date DESC, mt.load_datetime DESC
            ) AS rn_mt
        FROM terminal_elegible te
        LEFT JOIN awsdatacatalog.bold_gold_terminals.mart_terminal_enrich mt
            ON te.merchant_id = cast(mt.last_terminal_match_merchant_id AS varchar)
           AND te.serial = upper(trim(cast(mt.terminal_serial AS varchar)))
    ) z
    WHERE rn_mt = 1
),

client_actual AS (
    SELECT *
    FROM (
        SELECT
            cast(c.merchant_id AS varchar) AS merchant_id,
            c.merchant_name,
            c.merchant_acquisition_channel_source AS canal_source,
            c.merchant_acquisition_channel_value AS canal_vinculacion,
            c.merchant_acquisition_channel_sales_agent_email AS ejecutivo_actual,
            c.status AS merchant_status,
            c.onboarding_status,
            c.onboarding_completion_date,
            row_number() OVER (
                PARTITION BY c.merchant_id
                ORDER BY c.last_update_event_date DESC, c.creation_date DESC
            ) AS rn
        FROM awsdatacatalog.bold_gold_growth.dim_client c
        INNER JOIN merchants_coopicredito m
            ON cast(c.merchant_id AS varchar) = m.merchant_id
    ) x
    WHERE rn = 1
),

onboarding_actual AS (
    SELECT *
    FROM (
        SELECT
            cast(o.merchant_id AS varchar) AS merchant_id,
            o.onboarding_completion_date,
            o.onboarding_completed_date,
            o.acquisition_channel_sales_agent_email AS ejecutivo_onboarding,
            o.status AS onboarding_source_status,
            row_number() OVER (
                PARTITION BY o.merchant_id
                ORDER BY o.onboarding_completed_date DESC, o.onboarding_completion_date DESC
            ) AS rn
        FROM awsdatacatalog.bold_gold_growth.dim_merchant_onboarding o
        INNER JOIN merchants_coopicredito m
            ON cast(o.merchant_id AS varchar) = m.merchant_id
    ) x
    WHERE rn = 1
)

SELECT
    date_format(p.fecha_reporte, '%d/%m/%Y') AS fecha_reporte,
    m.merchant_id,
    coalesce(nullif(c.canal_source, ''), nullif(c.canal_vinculacion, ''), 'SIN_CANAL') AS canal_actual,
    td.serial,
    td.producto,
    td.tpv_m0_serial AS tpv_m0,
    p.canal_destino AS asignar_a_canal,
    p.ejecutivo_destino AS ejecutivo,
    c.merchant_name AS nombre_comercio,
    c.ejecutivo_actual,
    o.ejecutivo_onboarding,
    coalesce(o.onboarding_completed_date, o.onboarding_completion_date) AS fecha_onboarding,
    CASE WHEN coalesce(o.onboarding_completed_date, o.onboarding_completion_date) >= p.inicio_mes
           AND coalesce(o.onboarding_completed_date, o.onboarding_completion_date) < p.inicio_mes_siguiente
         THEN true ELSE false END AS onboarding_en_agosto,
    td.primera_tx_serial AS primera_transaccion_agosto,
    td.transacciones_m0_serial AS transacciones_m0,
    td.estado_terminal,
    c.merchant_status,
    c.onboarding_status,
    CASE WHEN upper(coalesce(c.canal_source, c.canal_vinculacion, '')) = p.canal_destino
         THEN false ELSE true END AS requiere_cambio_canal,
    CASE WHEN td.serial IS NULL THEN 'SIN_PRIMERA_TX_EN_AGOSTO'
         WHEN upper(coalesce(c.canal_source, c.canal_vinculacion, '')) = p.canal_destino
              THEN 'YA_EN_ENTERPRISE'
         ELSE 'ELEGIBLE_CAMBIO_A_ENTERPRISE' END AS estado_solicitud
FROM merchants_coopicredito m
CROSS JOIN parametros p
LEFT JOIN client_actual c ON m.merchant_id = c.merchant_id
LEFT JOIN onboarding_actual o ON m.merchant_id = o.merchant_id
LEFT JOIN terminal_detail td ON m.merchant_id = td.merchant_id
ORDER BY m.source_row;
