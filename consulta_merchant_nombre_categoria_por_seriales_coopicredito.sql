-- COOPICRÉDITO | SERIAL -> MERCHANT -> COMERCIO / CATEGORÍA
-- Athena / Trino. Consulta de lectura para Metabase.
-- Grano: un registro por serial solicitado (se conserva también el serial no encontrado).
-- Categoría/subcategoría: campos de actividad económica de dim_client; validar
-- con negocio si se requiere una dimensión comercial diferente.

WITH seriales_fuente (source_row, serial_solicitado) AS (
    SELECT source_row, upper(trim(serial))
    FROM UNNEST(ARRAY[
        'N860WN30960','N860WN30961','N860WN30962','N860WN30963','N860WN30964',
        'N860WN30965','N860WN30967','N860WN30969','N860WN30977','N860WN32819',
        'N860WN32820','N860WN32822','N860WN32825','N860WN32828','N860WN32830',
        'N860WN32831','N860WN32832','N860WN32836','N860WN34738','N860WN34719',
        'N860WN34720','N860WN34721','N860WN34722','N860WN34724','N860WN34725',
        'N860WN34726','N860WN34727','N860WN34728','N860WN34729','N860WN34730',
        'N860WN34731','N860WN34732','N860WN30976','N860WN34734','N860WN34735',
        'N860WN34736','01210021202405311645','N860WN30970','N860WN30971','N860WN30973',
        'N860WN30975','N860WN32829','01210150202309030023','01210140202309040848',
        '01210140202309040991','N860WN34737','01210190202403260818','01210021202405310078',
        '01210021202405311399','38260625004123','N860WN26001','N860WN26013',
        '38260625004136','38260625004139','38260625004133','38260625004124',
        'N860WN26016','N860WN26007','N860WN34854','N860WN30978','N860WN34839',
        'N860WN31438','N860WN35462','N860WN29830','N860WN34844','N860WN34856',
        'N860WN33867','N860WN34648','N860WN34651','N860WN29811','N860WN29814',
        'N860WN34647','N860WN34649','N860WN34661','N860WN31426'
    ]) WITH ORDINALITY AS u(serial, source_row)
),

terminal_ranked AS (
    SELECT
        s.source_row,
        s.serial_solicitado,
        cast(t.terminal_key AS varchar) AS terminal_key,
        upper(trim(cast(t.terminal_serial AS varchar))) AS terminal_serial,
        cast(t.last_terminal_match_merchant_id AS varchar) AS merchant_id,
        t.terminal_model,
        t.model_name_category,
        t.current_terminal_status,
        t.last_merchant_match_status,
        t.last_terminal_match_date,
        t.last_transaction_approved_date,
        t.terminal_sales_source,
        t.terminal_sales_executive,
        t.load_datetime,
        row_number() OVER (
            PARTITION BY s.source_row
            ORDER BY
                CASE WHEN upper(trim(cast(t.terminal_serial AS varchar))) = s.serial_solicitado THEN 1 ELSE 0 END DESC,
                CASE WHEN t.last_terminal_match_merchant_id IS NOT NULL THEN 1 ELSE 0 END DESC,
                t.last_terminal_match_date DESC NULLS LAST,
                t.load_datetime DESC NULLS LAST
        ) AS rn
    FROM seriales_fuente s
    LEFT JOIN awsdatacatalog.bold_gold_terminals.mart_terminal_enrich t
        ON upper(trim(cast(t.terminal_serial AS varchar))) = s.serial_solicitado
        OR upper(trim(cast(t.terminal_key AS varchar))) = s.serial_solicitado
),

terminal_actual AS (
    SELECT *
    FROM terminal_ranked
    WHERE rn = 1
),

client_ranked AS (
    SELECT
        trim(cast(c.merchant_id AS varchar)) AS merchant_id,
        trim(cast(c.client_id AS varchar)) AS client_id,
        c.merchant_name AS nombre_comercio,
        c.merchant_person_type AS tipo_persona,
        c.merchant_identification_document_type AS tipo_documento,
        cast(c.merchant_identification_document_number AS varchar) AS numero_documento,
        cast(c.economic_activity_category_id AS varchar) AS categoria_id,
        c.economic_activity_name AS categoria,
        c.economic_activity_description AS subcategoria,
        c.economic_activity_ciiu AS ciiu,
        c.economic_activity_mcc AS mcc,
        c.merchant_acquisition_channel_sales_agent_email AS ejecutivo_email,
        c.merchant_acquisition_channel_source AS canal_fuente,
        c.merchant_acquisition_channel_value AS canal_valor,
        c.sales_source,
        c.status AS merchant_status,
        c.onboarding_status,
        c.last_update_event_date,
        row_number() OVER (
            PARTITION BY c.merchant_id
            ORDER BY c.last_update_event_date DESC NULLS LAST, c.creation_date DESC NULLS LAST
        ) AS rn
    FROM awsdatacatalog.bold_gold_growth.dim_client c
    INNER JOIN (
        SELECT DISTINCT merchant_id
        FROM terminal_actual
        WHERE merchant_id IS NOT NULL
    ) merchants
        ON trim(cast(c.merchant_id AS varchar)) = merchants.merchant_id
),

client_actual AS (
    SELECT *
    FROM client_ranked
    WHERE rn = 1
)

SELECT
    t.source_row,
    t.serial_solicitado,
    t.terminal_serial,
    t.terminal_key,
    t.merchant_id,
    c.client_id,
    c.nombre_comercio,
    c.tipo_persona,
    c.tipo_documento,
    c.numero_documento,
    c.categoria_id,
    c.categoria,
    c.subcategoria,
    c.ciiu,
    c.mcc,
    coalesce(
        nullif(upper(trim(t.terminal_sales_source)), ''),
        nullif(upper(trim(c.canal_fuente)), ''),
        nullif(upper(trim(c.canal_valor)), ''),
        nullif(upper(trim(c.sales_source)), ''),
        'SIN_CANAL'
    ) AS canal_actual,
    c.ejecutivo_email,
    t.terminal_sales_executive AS ejecutivo_terminal,
    t.terminal_model,
    t.model_name_category AS categoria_terminal,
    t.current_terminal_status AS estado_terminal,
    t.last_merchant_match_status AS estado_match_terminal,
    c.merchant_status,
    c.onboarding_status,
    t.last_terminal_match_date,
    t.last_transaction_approved_date,
    t.load_datetime AS terminal_actualizado,
    c.last_update_event_date AS merchant_actualizado,
    CASE
        WHEN t.terminal_key IS NULL AND t.terminal_serial IS NULL THEN 'SERIAL_NO_ENCONTRADO'
        WHEN t.merchant_id IS NULL THEN 'TERMINAL_SIN_MERCHANT'
        WHEN c.merchant_id IS NULL THEN 'MERCHANT_SIN_DIM_CLIENT'
        WHEN c.categoria IS NULL AND c.subcategoria IS NULL THEN 'SIN_CATEGORIA_ACTIVIDAD'
        ELSE 'TRAZABILIDAD_COMPLETA'
    END AS estado_trazabilidad
FROM terminal_actual t
LEFT JOIN client_actual c
    ON t.merchant_id = c.merchant_id
ORDER BY t.source_row;
