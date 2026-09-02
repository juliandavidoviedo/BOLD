-- Objetivo:
-- Validar cobertura real de ciudad/direccion/departamento por merchant_id en
-- fuentes conocidas del Handoff SMB.
--
-- Esta consulta NO filtra por canal. Solo usa los merchant_id de entrada.
-- Si una fuente no trae ciudad/direccion, el merchant debe seguir visible.

WITH
base_mensual (merchant_id) AS (
    VALUES
        ('0CZTLXEOXY'), ('7DVLTIUMHX'), ('RMCVFJO3D8'), ('60WPJO2DZX'),
        ('8R8UIAMUC6'), ('PA1LA4GGYD'), ('WFK9N0809K'), ('3SQNBLP4ZN'),
        ('LG773V6IUV'), ('VMKYJPDVD1')
),

client_ranked AS (
    SELECT
        cast(c.merchant_id AS varchar) AS merchant_id,
        cast(c.client_id AS varchar) AS client_id,
        c.location_address_department_code,
        c.last_update_event_date,
        row_number() OVER (
            PARTITION BY c.merchant_id
            ORDER BY c.last_update_event_date DESC, c.creation_date DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_growth.dim_client c
    INNER JOIN base_mensual bm
        ON cast(c.merchant_id AS varchar) = bm.merchant_id
    WHERE c.merchant_id IS NOT NULL
),
client_current AS (
    SELECT
        merchant_id,
        client_id,
        location_address_department_code,
        last_update_event_date
    FROM client_ranked
    WHERE rn = 1
),

onboarding_ranked AS (
    SELECT
        cast(o.merchant_id AS varchar) AS merchant_id,
        o.address_department_code,
        o.onboarding_completed_date,
        o.onboarding_completion_date,
        row_number() OVER (
            PARTITION BY o.merchant_id
            ORDER BY o.onboarding_completed_date DESC, o.onboarding_completion_date DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_growth.dim_merchant_onboarding o
    INNER JOIN base_mensual bm
        ON cast(o.merchant_id AS varchar) = bm.merchant_id
    WHERE o.merchant_id IS NOT NULL
),
onboarding_current AS (
    SELECT
        merchant_id,
        address_department_code,
        onboarding_completed_date,
        onboarding_completion_date
    FROM onboarding_ranked
    WHERE rn = 1
),

georef_ranked AS (
    SELECT
        cast(g.merchant_id AS varchar) AS merchant_id,
        g.standardized_address,
        g.municipality,
        g.department,
        g.dane_code,
        g.latitude,
        g.longitude,
        g.load_datetime,
        row_number() OVER (
            PARTITION BY g.merchant_id
            ORDER BY g.load_datetime DESC, g.date_key DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_growth.dim_client_georeference g
    INNER JOIN base_mensual bm
        ON cast(g.merchant_id AS varchar) = bm.merchant_id
    WHERE g.merchant_id IS NOT NULL
),
georef_current AS (
    SELECT
        merchant_id,
        standardized_address,
        municipality,
        department,
        dane_code,
        latitude,
        longitude,
        load_datetime
    FROM georef_ranked
    WHERE rn = 1
),

resultado AS (
    SELECT
        bm.merchant_id,
        c.client_id,
        g.standardized_address AS georef_address,
        g.municipality AS georef_city_name,
        g.department AS georef_department_name,
        g.dane_code AS georef_city_code,
        g.latitude AS georef_latitude,
        g.longitude AS georef_longitude,
        c.location_address_department_code AS dim_client_department_code,
        o.address_department_code AS onboarding_department_code,
        CASE
            WHEN g.municipality IS NOT NULL AND trim(cast(g.municipality AS varchar)) <> ''
                THEN 'CIUDAD_RESUELTA_GEOREFERENCE'
            ELSE 'SIN_CIUDAD_GEOREFERENCE'
        END AS estado_ciudad_georeference,
        CASE
            WHEN g.standardized_address IS NOT NULL AND trim(cast(g.standardized_address AS varchar)) <> ''
                THEN 'DIRECCION_RESUELTA_GEOREFERENCE'
            ELSE 'SIN_DIRECCION_GEOREFERENCE'
        END AS estado_direccion_georeference,
        CASE
            WHEN g.department IS NOT NULL AND trim(cast(g.department AS varchar)) <> ''
                THEN 'DEPARTAMENTO_RESUELTO_GEOREFERENCE'
            WHEN c.location_address_department_code IS NOT NULL
                 AND trim(cast(c.location_address_department_code AS varchar)) <> ''
                THEN 'DEPARTAMENTO_RESUELTO_DIM_CLIENT'
            WHEN o.address_department_code IS NOT NULL
                 AND trim(cast(o.address_department_code AS varchar)) <> ''
                THEN 'DEPARTAMENTO_RESUELTO_ONBOARDING'
            ELSE 'SIN_DEPARTAMENTO'
        END AS estado_departamento,
        g.load_datetime AS georef_loaded_at,
        c.last_update_event_date AS dim_client_updated_at,
        coalesce(o.onboarding_completed_date, o.onboarding_completion_date) AS onboarding_updated_at
    FROM base_mensual bm
    LEFT JOIN client_current c ON bm.merchant_id = c.merchant_id
    LEFT JOIN onboarding_current o ON bm.merchant_id = o.merchant_id
    LEFT JOIN georef_current g ON bm.merchant_id = g.merchant_id
)

SELECT
    *
FROM resultado
ORDER BY merchant_id
