-- CONSULTA BASE MENSUAL: terminales y cambios de canal
-- Athena / Trino SQL
--
-- Único insumo variable: tabla de entrada bold_gold_growth.input_merchant_ids.
-- Columnas mínimas requeridas:
--   merchant_id      varchar
--   lote             varchar/date  (ej. '2026-08-28')
--   fecha_reporte    date
--   nombre_fuente    varchar (opcional)
--
-- Para cada mes se carga un nuevo lote en esa tabla. No se editan merchant_id
-- dentro de esta consulta.

WITH
parametros AS (
    SELECT
        CAST('2026-08-01' AS date) AS inicio_mes_gestion,
        date_add('month', 1, CAST('2026-08-01' AS date)) AS inicio_mes_siguiente,
        CAST('2026-08-28' AS date) AS fecha_reporte,
        upper('ENTERPRISE') AS canal_destino,
        lower('jeyson.salazar@bold.co') AS ejecutivo_destino,
        '2026-08-28' AS lote_consulta
),

merchant_ids AS (
    SELECT
        row_number() OVER (ORDER BY cast(i.merchant_id AS varchar)) AS source_row,
        upper(trim(cast(i.merchant_id AS varchar))) AS merchant_id,
        i.nombre_fuente,
        i.lote,
        i.fecha_reporte
    FROM awsdatacatalog.bold_gold_growth.input_merchant_ids i
    CROSS JOIN parametros p
    WHERE i.merchant_id IS NOT NULL
      AND cast(i.lote AS varchar) = p.lote_consulta
),

client_actual AS (
    SELECT *
    FROM (
        SELECT
            cast(c.merchant_id AS varchar) AS merchant_id,
            c.merchant_name,
            c.merchant_acquisition_channel_source AS canal_source,
            c.merchant_acquisition_channel_value AS canal_vinculacion,
            c.merchant_acquisition_channel_sales_agent_email AS ejecutivo_adquisicion,
            c.status AS merchant_status,
            c.onboarding_status,
            c.last_update_event_date,
            row_number() OVER (
                PARTITION BY c.merchant_id
                ORDER BY c.last_update_event_date DESC, c.creation_date DESC
            ) AS rn
        FROM awsdatacatalog.bold_gold_growth.dim_client c
        INNER JOIN merchant_ids m
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
            o.economic_activity_category_id AS categoria_id_onboarding,
            o.economic_activity_name AS categoria_onboarding,
            o.economic_activity_description AS subcategoria_onboarding,
            o.status AS onboarding_source_status,
            row_number() OVER (
                PARTITION BY o.merchant_id
                ORDER BY o.onboarding_completed_date DESC, o.onboarding_completion_date DESC
            ) AS rn
        FROM awsdatacatalog.bold_gold_growth.dim_merchant_onboarding o
        INNER JOIN merchant_ids m
            ON cast(o.merchant_id AS varchar) = m.merchant_id
    ) x
    WHERE rn = 1
),

terminal_mes AS (
    SELECT *
    FROM (
        SELECT
            m.source_row,
            m.merchant_id,
            cast(t.terminal_key AS varchar) AS terminal_key,
            cast(t.terminal_serial AS varchar) AS serial,
            coalesce(t.terminal_model, t.model_name_category) AS producto,
            t.current_terminal_status AS estado_terminal,
            cast(t."_1st_transaction_approved_date" AS timestamp) AS primera_tx_aprobada,
            coalesce(t.tpv_m0_since_terminal_activation, cast(0 AS decimal(38,4))) AS tpv_m0,
            t.last_terminal_match_date,
            t.terminal_sales_source,
            t.terminal_sales_executive,
            t.load_datetime,
            row_number() OVER (
                PARTITION BY m.merchant_id
                ORDER BY cast(t."_1st_transaction_approved_date" AS timestamp) ASC,
                         t.last_terminal_match_date ASC,
                         t.load_datetime DESC,
                         t.terminal_key
            ) AS rn
        FROM merchant_ids m
        INNER JOIN awsdatacatalog.bold_gold_terminals.mart_terminal_enrich t
            ON m.merchant_id = cast(t.last_terminal_match_merchant_id AS varchar)
        CROSS JOIN parametros p
        WHERE t.terminal_key IS NOT NULL
          AND t."_1st_transaction_approved_date" >= p.inicio_mes_gestion
          AND t."_1st_transaction_approved_date" < p.inicio_mes_siguiente
    ) x
    WHERE rn = 1
),

opportunity_actual AS (
    SELECT *
    FROM (
        SELECT
            cast(coalesce(o.product_merchant_id, o.metadata_merchant_id) AS varchar) AS merchant_id,
            upper(trim(o.status)) AS opportunity_status,
            o.sales_channel AS opportunity_channel,
            cast(o.user_id AS varchar) AS opportunity_user_id,
            o.won_date,
            o.last_update_date,
            row_number() OVER (
                PARTITION BY coalesce(o.product_merchant_id, o.metadata_merchant_id)
                ORDER BY o.last_update_date DESC, o.load_datetime DESC
            ) AS rn
        FROM awsdatacatalog.bold_gold_sales.dim_crm_opportunities o
        INNER JOIN merchant_ids m
            ON m.merchant_id = cast(coalesce(o.product_merchant_id, o.metadata_merchant_id) AS varchar)
    ) x
    WHERE rn = 1
),

crm_users_actual AS (
    SELECT *
    FROM (
        SELECT
            cast(u.user_id AS varchar) AS user_id,
            lower(trim(u.email)) AS email_key,
            u.email,
            cast(u.parent_id AS varchar) AS parent_id,
            u.role,
            u.status,
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
    m.merchant_id,
    coalesce(c.canal_source, c.canal_vinculacion, oa.opportunity_channel, t.terminal_sales_source, 'SIN_CANAL') AS canal_actual,
    t.serial,
    t.producto,
    t.tpv_m0,
    p.canal_destino AS asignar_a_canal,
    p.ejecutivo_destino AS ejecutivo,
    c.merchant_name AS nombre_comercio,
    c.ejecutivo_adquisicion,
    o.ejecutivo_onboarding,
    o.onboarding_completion_date,
    o.onboarding_completed_date,
    CASE WHEN coalesce(o.onboarding_completed_date, o.onboarding_completion_date) >= p.inicio_mes_gestion
           AND coalesce(o.onboarding_completed_date, o.onboarding_completion_date) < p.inicio_mes_siguiente
         THEN true ELSE false END AS onboarding_en_mes_gestion,
    t.primera_tx_aprobada,
    CASE WHEN t.primera_tx_aprobada IS NOT NULL THEN true ELSE false END AS primera_tx_en_mes_gestion,
    oa.opportunity_status,
    ou.email AS ejecutivo_oportunidad_actual,
    manager.email AS manager_oportunidad_actual,
    CASE WHEN upper(coalesce(c.canal_source, c.canal_vinculacion, oa.opportunity_channel, t.terminal_sales_source, '')) <> p.canal_destino
          AND t.terminal_key IS NOT NULL
         THEN true ELSE false END AS requiere_cambio_canal,
    CASE WHEN t.terminal_key IS NULL THEN 'SIN_TERMINAL_PRIMERA_TX_MES'
         WHEN upper(coalesce(c.canal_source, c.canal_vinculacion, oa.opportunity_channel, t.terminal_sales_source, '')) = p.canal_destino
             THEN 'YA_EN_ENTERPRISE'
         ELSE 'ELEGIBLE_CAMBIO_A_ENTERPRISE' END AS estado_solicitud
FROM merchant_ids m
CROSS JOIN parametros p
LEFT JOIN client_actual c ON m.merchant_id = c.merchant_id
LEFT JOIN onboarding_actual o ON m.merchant_id = o.merchant_id
LEFT JOIN terminal_mes t ON m.merchant_id = t.merchant_id
LEFT JOIN opportunity_actual oa ON m.merchant_id = oa.merchant_id
LEFT JOIN crm_users_actual ou ON oa.opportunity_user_id = ou.user_id
LEFT JOIN crm_users_actual manager ON ou.parent_id = manager.user_id
ORDER BY m.source_row;
