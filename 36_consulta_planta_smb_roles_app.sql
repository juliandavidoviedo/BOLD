-- Consulta 36 - Planta SMB para asignación de roles en la APP
-- Fuente: Athena/Metabase (Bold Gold Sales)
--
-- Objetivo:
--   Obtener una fila por colaborador vigente del canal SMB, con correo,
--   rol y datos de jerarquía para cargar/validar permisos en la APP.
--
-- Nota sobre nombres:
--   Las columnas confirmadas en dim_crm_users y
--   dim_user_bamboo_information no incluyen nombre completo del usuario.
--   Por eso nombre_usuario queda NULL de forma explícita. reports_to sí
--   se conserva como nombre del superior cuando está disponible.
--   Cuando BI confirme la columna oficial (por ejemplo full_name),
--   reemplazar NULL AS nombre_usuario por esa columna en bamboo_current.

WITH crm_ranked AS (
    SELECT
        CAST(u.user_id AS VARCHAR) AS user_id,
        TRIM(u.email) AS email,
        u.role,
        u.parent_id,
        u.sales_channel,
        u.status,
        u.country_code,
        u.load_datetime,
        ROW_NUMBER() OVER (
            PARTITION BY CAST(u.user_id AS VARCHAR)
            ORDER BY
                CASE WHEN UPPER(u.status) = 'ACTIVE' THEN 1 ELSE 0 END DESC,
                u.load_datetime DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_sales.dim_crm_users u
    WHERE u.user_id IS NOT NULL
      AND u.email IS NOT NULL
      AND TRIM(u.email) <> ''
),
crm_current AS (
    SELECT user_id, email, role, parent_id, sales_channel, status,
           country_code, load_datetime
    FROM crm_ranked
    WHERE rn = 1
),
bamboo_ranked AS (
    SELECT
        CAST(b.user_id AS VARCHAR) AS user_id,
        b.reports_to,
        CAST(b.supervisor_id AS VARCHAR) AS supervisor_id,
        b.city,
        b.region,
        CAST(b.hub_custom_id AS VARCHAR) AS hub_custom_id,
        b.hub_name,
        b.job_title,
        b.channel,
        b.status AS bamboo_status,
        b.vinculation_status,
        b.load_datetime,
        ROW_NUMBER() OVER (
            PARTITION BY CAST(b.user_id AS VARCHAR)
            ORDER BY b.load_datetime DESC, b.event_datetime DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_sales.dim_user_bamboo_information b
    WHERE b.user_id IS NOT NULL
),
bamboo_current AS (
    SELECT * FROM bamboo_ranked WHERE rn = 1
),
planta_smb AS (
    SELECT
        c.user_id,
        CAST(NULL AS VARCHAR) AS nombre_usuario,
        c.email,
        c.role AS rol_crm,
        COALESCE(b.job_title, c.role) AS rol_app_sugerido,
        COALESCE(c.sales_channel, b.channel) AS canal,
        c.status AS estado_crm,
        b.bamboo_status,
        b.vinculation_status,
        b.reports_to AS superior_nombre_bamboo,
        b.supervisor_id AS superior_user_id,
        b.city,
        b.region,
        b.hub_custom_id,
        b.hub_name,
        c.load_datetime AS crm_updated_at,
        b.load_datetime AS bamboo_updated_at
    FROM crm_current c
    LEFT JOIN bamboo_current b ON b.user_id = c.user_id
    WHERE UPPER(COALESCE(c.sales_channel, b.channel)) = 'SMB'
      AND UPPER(COALESCE(c.status, '')) = 'ACTIVE'
)
SELECT
    user_id,
    nombre_usuario,
    email,
    rol_app_sugerido,
    rol_crm,
    canal,
    estado_crm,
    bamboo_status,
    vinculation_status,
    superior_nombre_bamboo,
    superior_user_id,
    city,
    region,
    hub_custom_id,
    hub_name,
    crm_updated_at,
    bamboo_updated_at,
    CASE
        WHEN nombre_usuario IS NULL THEN 'NOMBRE_PENDIENTE_DIMENSION_PERSONAS'
        ELSE 'OK'
    END AS estado_nombre
FROM planta_smb
ORDER BY rol_app_sugerido, nombre_usuario, email;

