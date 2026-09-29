WITH merchant_scope (source_row, merchant_id, nombre_archivo, fecha_activacion_archivo) AS (
    VALUES
        (1, 'B0CKR5HU8C', 'COOPICRÉDITO - DROGUERIAS SANSALUD SAN PEDRO DE URABA', DATE '2026-09-17'),
        (2, 'R2BWFBJS7A', 'COOPICRÉDITO - DROGUERIAS SANSALUD ARBOLETES', DATE '2026-09-21'),
        (3, 'ENVQ1TNW9V', 'COOPICRÉDITO - FARMAHOGAR CENTRAL', DATE '2026-09-15'),
        (4, 'BGDA1VQOLZ', 'COOPICRÉDITO - DROGUERÍA CALIMÍO', DATE '2026-09-18'),
        (5, 'CINAK5N1MV', 'COOPICRÉDITO - DROGUERIA SAN GIL 1', DATE '2026-09-23'),
        (6, '3ODGLUFW0P', 'COOPICRÉDITO - DROGUERÍA ANDINA CE', DATE '2026-09-17'),
        (7, 'TOGZAEVZ0K', 'COOPICRÉDITO - DROGUERÍA CLUBMED', DATE '2026-09-01'),
        (8, '0XV9992C0O', 'COOPICRÉDITO - DROGUERÍA Y FARMACIA CENTRAL', DATE '2026-09-02'),
        (9, 'GHTNMF7727', 'COOPICRÉDITO - DROGUERIA MELCOMIA', DATE '2026-09-14'),
        (10, 'XMABPI8SDB', 'COOPICRÉDITO - DROGUERÍA FARMACENTER YINIMAR', DATE '2026-09-14'),
        (11, '1KQZPLFRVW', 'COOPICRÉDITO - FARMALKOSTO ALMENDROS', DATE '2026-09-12'),
        (12, 'JXLFJ824NO', 'COOPICRÉDITO - DROGUERÍAS EXPRESO', DATE '2026-09-07'),
        (13, 'PL0B5ER5G3', 'COOPICRÉDITO - DROGUERIA VILLADELA', DATE '2026-09-15'),
        (14, 'L7H1W2PHU6', 'COOPICRÉDITO - NEGOCIO DE MÓNICA YOHANA', DATE '2026-09-15'),
        (15, '0GRNI5F4QF', 'COOPICRÉDITO - DROGUERÍA SAN ANTERO', DATE '2026-09-18'),
        (16, 'R4FNXSI23Y', 'COOPICRÉDITO - DROGARCIA NO4', DATE '2026-09-15'),
        (17, 'M28ST7P6ZS', 'COOPICRÉDITO - MIL DROGAS DOS', DATE '2026-09-21'),
        (18, 'BW2O3VIGL9', 'COOPICRÉDITO - DROGUERÍA COLSANAR DEL NORTE', DATE '2026-09-23'),
        (19, '0GDIBQPP50', 'COOPICRÉDITO - DROGUERÍA LA CUARTA B', DATE '2026-09-23'),
        (20, 'Z472LRDO4K', 'COOPICRÉDITO - DROGUERÍA DIOSALUD RD', DATE '2026-09-19'),
        (21, '97B1X3AQSJ', 'COOPICRÉDITO - DROGUERÍA DIOSALUD LOS ANGELES', DATE '2026-09-19'),
        (22, '9RDRW9GH0A', 'COOPICRÉDITO - DROGUERÍAS DIOSALUD', DATE '2026-09-19'),
        (23, 'FK9XQZ1MGR', 'COOPICRÉDITO - DROGUERÍA DIOSALUD RS', DATE '2026-09-19'),
        (24, 'Q8BB6LMM80', 'COOPICRÉDITO - DROGUERÍA Y PERFUMERÍA SANTANDER', DATE '2026-09-23'),
        (25, '4ET483LBS9', 'COOPICRÉDITO - DROGUERIA MICHEL', DATE '2026-09-24'),
        (26, 'UJ6IC6QYVU', 'COOPICRÉDITO - DROGUERIA DE LA 146', DATE '2026-09-24'),
        (27, 'F4K0HCI3BX', 'COOPICRÉDITO - DROGUERIA VICTORIA NORTE', DATE '2026-09-24'),
        (28, 'T035E5K6WQ', 'COOPICRÉDITO - DROGUERIA VICTORIA NORTE 2', DATE '2026-09-24'),
        (29, 'D7F22FG5QR', 'COOPICRÉDITO - DROGUERIA CRUZ AZUL 104', DATE '2026-09-24'),
        (30, 'FUGNVIJWU8', 'COOPICRÉDITO - DROGUERIA ANDES FARMA', DATE '2026-09-24'),
        (31, 'AJ5XQ8640E', 'COOPICRÉDITO - DROGUERIA CRUZ AZUL 133', DATE '2026-09-24'),
        (32, '4I2PD2J2SH', 'COOPICRÉDITO - DROGUERÍA XIOFARMA JD', DATE '2026-09-23')
),
client_ranked AS (
    SELECT
        s.source_row,
        s.merchant_id,
        s.nombre_archivo,
        s.fecha_activacion_archivo,
        c.merchant_name,
        c.creation_date AS merchant_creation_date,
        c.onboarding_completion_date,
        c.status AS merchant_status,
        c.onboarding_status,
        c.sales_source,
        c.merchant_acquisition_channel_source AS acquisition_channel_source,
        c.merchant_acquisition_channel_value AS acquisition_channel_value,
        c.merchant_acquisition_channel_sales_agent_email AS sales_agent_email,
        c.last_update_event_date,
        row_number() OVER (
            PARTITION BY trim(cast(c.merchant_id AS varchar))
            ORDER BY c.last_update_event_date DESC NULLS LAST,
                     c.creation_date DESC NULLS LAST
        ) AS rn
    FROM merchant_scope s
    LEFT JOIN awsdatacatalog.bold_gold_growth.dim_client c
        ON trim(cast(c.merchant_id AS varchar)) = s.merchant_id
),
client_current AS (
    SELECT * FROM client_ranked WHERE rn = 1
),
opportunity_ranked AS (
    SELECT
        s.merchant_id,
        cast(o.opportunity_id AS varchar) AS opportunity_id,
        o.status AS opportunity_status,
        o.sales_channel AS opportunity_sales_channel,
        o.opportunity_type,
        o.management_type,
        o.user_id AS opportunity_user_id,
        o.creation_date AS opportunity_creation_date,
        o.won_date,
        o.activation_date,
        row_number() OVER (
            PARTITION BY s.merchant_id
            ORDER BY coalesce(o.activation_date, o.won_date, o.creation_date, o.last_update_date) DESC NULLS LAST,
                     o.load_datetime DESC NULLS LAST
        ) AS rn
    FROM merchant_scope s
    LEFT JOIN awsdatacatalog.bold_gold_sales.dim_crm_opportunities o
        ON trim(cast(coalesce(o.product_merchant_id, o.metadata_merchant_id) AS varchar)) = s.merchant_id
),
opportunity_current AS (
    SELECT * FROM opportunity_ranked WHERE rn = 1
)
SELECT
    s.source_row,
    s.merchant_id,
    s.nombre_archivo,
    c.merchant_name,
    c.merchant_creation_date,
    c.onboarding_completion_date,
    c.merchant_status,
    c.onboarding_status,
    c.sales_source,
    c.acquisition_channel_source,
    c.acquisition_channel_value,
    c.sales_agent_email,
    o.opportunity_id,
    o.opportunity_status,
    o.opportunity_sales_channel,
    o.opportunity_type,
    o.management_type,
    o.opportunity_creation_date,
    o.won_date,
    o.activation_date,
    CASE
        WHEN c.merchant_id IS NULL THEN 'SIN_MATCH_DIM_CLIENT'
        WHEN upper(trim(coalesce(c.sales_source, ''))) = 'ENTERPRISE'
             OR upper(trim(coalesce(o.opportunity_sales_channel, ''))) = 'ENTERPRISE'
            THEN 'YA_ENTERPRISE_O_VALIDAR_CONSISTENCIA'
        WHEN o.opportunity_id IS NULL
            THEN 'SIN_OPORTUNIDAD_CRM'
        ELSE 'CANDIDATO_CAMBIO_CANAL'
    END AS recomendacion_canal,
    CASE
        WHEN o.opportunity_id IS NULL THEN 'SIN_OPORTUNIDAD'
        WHEN upper(trim(coalesce(o.opportunity_status, ''))) IN ('WON', 'CLOSED_WON', 'GANADA')
            THEN 'OPORTUNIDAD_GANADA'
        ELSE 'OPORTUNIDAD_ABIERTA_O_NO_GANADA'
    END AS estado_oportunidad
FROM merchant_scope s
LEFT JOIN client_current c ON c.merchant_id = s.merchant_id
LEFT JOIN opportunity_current o ON o.merchant_id = s.merchant_id
ORDER BY recomendacion_canal, s.source_row;
