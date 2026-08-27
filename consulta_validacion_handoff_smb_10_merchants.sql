-- Consulta de validacion Handoff Comercial SMB -> CS/KAM
-- Destinataria: Tatiana - Process Automation Developer
-- Motor esperado: Athena / Trino desde Metabase
-- Fecha: 2026-08-27
--
-- Objetivo:
-- Validar con 10 merchant_id reales de BASE_COMERCIOS si Athena/Metabase puede
-- devolver en una sola consulta los datos no cualitativos necesarios para
-- alimentar BASE_COMERCIOS / KAM360.
--
-- Importante:
-- 1. Esta consulta usa merchant_id como unica entrada de validacion.
-- 2. La salida integra datos base, TPV, terminales y productos observados.
-- 3. Los nombres de columnas/tablas deben confirmarse en Metabase antes de
--    dejarla como consulta productiva.
-- 4. La informacion cualitativa no debe salir de esta consulta; esa vive en
--    RESPUESTAS_FORM y se cruza despues por merchant_id.
-- 5. Si dim_client no tiene category_id/subcategory_id, se dejan como NULL
--    temporalmente para no bloquear la validacion de TPV y terminales.
--
-- Consulta auxiliar para encontrar columnas de categoria si fallan:
-- SELECT table_schema, table_name, column_name
-- FROM information_schema.columns
-- WHERE table_schema = 'bold_gold_growth'
--   AND (
--       lower(column_name) LIKE '%categor%'
--       OR lower(column_name) LIKE '%subcategor%'
--       OR lower(column_name) LIKE '%mcc%'
--   )
-- ORDER BY table_name, column_name;

WITH
validation_merchants (merchant_id) AS (
    VALUES
        ('0CZTLXEOXY'),
        ('7DVLTIUMHX'),
        ('RMCVFJO3D8'),
        ('60WPJO2DZX'),
        ('8R8UIAMUC6'),
        ('PA1LA4GGYD'),
        ('WFK9N0809K'),
        ('3SQNBLP4ZN'),
        ('LG773V6IUV'),
        ('VMKYJPDVD1')
),

client_ranked AS (
    SELECT
        cast(c.merchant_id AS varchar) AS merchant_id,
        c.merchant_name,
        c.merchant_identification_document_type AS document_type,
        cast(c.merchant_identification_document_number AS varchar) AS document_number,
        cast(NULL AS varchar) AS category_id,
        cast(NULL AS varchar) AS subcategory_id,
        c.city_code,
        c.city,
        c.address,
        c.email,
        c.cellphone_number,
        c.sales_agent_email,
        c.onboarding_end_date,
        c.updated_at,
        row_number() OVER (
            PARTITION BY c.merchant_id
            ORDER BY c.updated_at DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_growth.dim_client c
    INNER JOIN validation_merchants vm
        ON cast(c.merchant_id AS varchar) = vm.merchant_id
    WHERE c.merchant_id IS NOT NULL
),

client_current AS (
    SELECT
        merchant_id,
        merchant_name,
        document_type,
        document_number,
        category_id,
        subcategory_id,
        city_code,
        city,
        address,
        email,
        cellphone_number,
        sales_agent_email,
        onboarding_end_date,
        updated_at
    FROM client_ranked
    WHERE rn = 1
),

tpv_by_merchant AS (
    SELECT
        cast(t.merchant_id AS varchar) AS merchant_id,
        min(CASE WHEN t.tpv > 0 THEN t.transaction_date END) AS first_transaction_date,
        max(CASE WHEN t.tpv > 0 THEN t.transaction_date END) AS last_transaction_date,
        sum(CASE
            WHEN t.transaction_date >= date_add('day', -30, current_date)
            THEN t.tpv ELSE 0 END
        ) AS tpv_30d,
        sum(CASE
            WHEN t.transaction_date >= date_add('day', -90, current_date)
            THEN t.tpv ELSE 0 END
        ) AS tpv_90d,
        sum(CASE
            WHEN t.transaction_date >= date_add('day', -180, current_date)
            THEN t.tpv ELSE 0 END
        ) AS tpv_180d,
        max(t.tpv) AS tpv_max_daily
    FROM awsdatacatalog.bold_gold_growth.mart_tpv_daily_by_merchant t
    INNER JOIN validation_merchants vm
        ON cast(t.merchant_id AS varchar) = vm.merchant_id
    WHERE t.transaction_date >= date_add('day', -365, current_date)
    GROUP BY cast(t.merchant_id AS varchar)
),

terminal_ranked AS (
    SELECT
        cast(te.merchant_id AS varchar) AS merchant_id,
        cast(te.terminal_id AS varchar) AS terminal_id,
        cast(te.serial_number AS varchar) AS serial_number,
        te.terminal_status,
        te.terminal_model,
        te.updated_at,
        row_number() OVER (
            PARTITION BY te.merchant_id, te.terminal_id
            ORDER BY te.updated_at DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_growth.mart_terminal_enrich te
    INNER JOIN validation_merchants vm
        ON cast(te.merchant_id AS varchar) = vm.merchant_id
    WHERE te.merchant_id IS NOT NULL
),

terminal_current AS (
    SELECT
        merchant_id,
        terminal_id,
        serial_number,
        terminal_status,
        terminal_model,
        updated_at
    FROM terminal_ranked
    WHERE rn = 1
      AND upper(coalesce(terminal_status, 'UNKNOWN')) NOT IN (
          'DELETED',
          'RETURNED',
          'CANCELLED'
      )
),

terminals_by_merchant AS (
    SELECT
        merchant_id,
        count(DISTINCT terminal_id) AS numero_terminales,
        array_join(array_sort(array_distinct(array_agg(terminal_id))), ', ') AS terminales_asociadas,
        max(updated_at) AS ultima_actualizacion_terminal
    FROM terminal_current
    GROUP BY merchant_id
),

product_activity AS (
    SELECT
        cast(tx.merchant_id AS varchar) AS merchant_id,
        upper(trim(tx.product_name)) AS product_name,
        max(tx.transaction_date) AS last_activity_date
    FROM awsdatacatalog.bold_gold_growth.mart_tpv_daily_by_transaction tx
    INNER JOIN validation_merchants vm
        ON cast(tx.merchant_id AS varchar) = vm.merchant_id
    WHERE tx.transaction_date >= date_add('day', -90, current_date)
    GROUP BY
        cast(tx.merchant_id AS varchar),
        upper(trim(tx.product_name))
),

products_by_merchant AS (
    SELECT
        merchant_id,
        max(CASE WHEN regexp_like(product_name, 'POS|MPOS') THEN true ELSE false END) AS tiene_pos,
        max(CASE WHEN regexp_like(product_name, 'LINK') THEN true ELSE false END) AS tiene_link_pago,
        max(CASE WHEN regexp_like(product_name, 'BOTON|BTN') THEN true ELSE false END) AS tiene_boton_pago,
        max(CASE WHEN regexp_like(product_name, 'QR') THEN true ELSE false END) AS tiene_qr,
        array_join(array_sort(array_distinct(array_agg(product_name))), ', ') AS productos_observados_90d
    FROM product_activity
    GROUP BY merchant_id
)

SELECT
    vm.merchant_id,
    c.merchant_name,
    c.document_type,
    c.document_number,
    c.category_id,
    c.subcategory_id,
    c.city_code,
    c.city,
    c.address,
    c.email,
    c.cellphone_number,
    c.sales_agent_email,
    c.onboarding_end_date,
    t.first_transaction_date,
    t.last_transaction_date,
    coalesce(t.tpv_30d, 0) AS tpv_30d,
    coalesce(t.tpv_90d, 0) AS tpv_90d,
    coalesce(t.tpv_180d, 0) AS tpv_180d,
    coalesce(t.tpv_90d / 3.0, 0) AS tpv_promedio_3m,
    coalesce(t.tpv_max_daily, 0) AS tpv_max,
    CASE
        WHEN coalesce(t.tpv_max_daily, 0) >= 40000000 THEN 'Mayor a 40M'
        WHEN coalesce(t.tpv_max_daily, 0) >= 20000000 THEN 'Entre 20M y 40M'
        ELSE 'Menor a 20M'
    END AS clasificacion_calculada,
    coalesce(te.numero_terminales, 0) AS numero_terminales,
    te.terminales_asociadas,
    te.ultima_actualizacion_terminal,
    coalesce(p.tiene_pos, false) AS tiene_pos,
    coalesce(p.tiene_link_pago, false) AS tiene_link_pago,
    coalesce(p.tiene_boton_pago, false) AS tiene_boton_pago,
    coalesce(p.tiene_qr, false) AS tiene_qr,
    p.productos_observados_90d,
    current_timestamp AS fecha_validacion
FROM validation_merchants vm
LEFT JOIN client_current c
    ON vm.merchant_id = c.merchant_id
LEFT JOIN tpv_by_merchant t
    ON vm.merchant_id = t.merchant_id
LEFT JOIN terminals_by_merchant te
    ON vm.merchant_id = te.merchant_id
LEFT JOIN products_by_merchant p
    ON vm.merchant_id = p.merchant_id
ORDER BY vm.merchant_id;
