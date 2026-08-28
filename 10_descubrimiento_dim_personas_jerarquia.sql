-- Descubrimiento de dimensión de personas para completar:
--   manager_name, manager_email, team_lead_name, team_lead_email
--
-- Hallazgo actual:
--   dim_crm_pos_locations.manager_email identifica al responsable del hub.
--   Falta resolver nombre, rol y superior desde las dimensiones de usuarios/personas.
-- Ejecutar cada bloque por separado en Athena/Metabase.

-- 1) Revisar todas las columnas disponibles para personas y jerarquía
SELECT table_schema, table_name, ordinal_position, column_name, data_type
FROM information_schema.columns
WHERE (
    (table_schema = 'bold_gold_sales' AND table_name IN (
        'dim_crm_users', 'dim_user_bamboo_information',
        'dim_user_bamboo_information_history'
    ))
    OR (table_schema = 'bold_gold_growth' AND table_name IN (
        'dim_person', 'dim_person_v2'
    ))
)
ORDER BY table_schema, table_name, ordinal_position;

-- 2) Muestra segura de usuarios CRM.
-- No usar SELECT *: metadata puede contener secretos o información sensible.
SELECT
    user_id,
    email,
    role,
    parent_id,
    sales_channel,
    status,
    country_code,
    load_datetime
FROM awsdatacatalog.bold_gold_sales.dim_crm_users
LIMIT 100;

-- 3) Muestra de información Bamboo/personas
SELECT *
FROM awsdatacatalog.bold_gold_sales.dim_user_bamboo_information
LIMIT 100;

-- 4) Cadena propuesta: hub -> manager_email -> usuario -> supervisor.
-- Esta consulta usa únicamente columnas confirmadas en el resultado 08.
WITH hub_manager AS (
    SELECT
        custom_id,
        manager_email,
        row_number() OVER (
            PARTITION BY custom_id
            ORDER BY load_datetime DESC, event_datetime DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_sales.dim_crm_pos_locations
    WHERE custom_id IS NOT NULL
),
manager_current AS (
    SELECT custom_id, manager_email
    FROM hub_manager
    WHERE rn = 1
)
SELECT
    hm.custom_id,
    hm.manager_email,
    u.user_id AS manager_user_id,
    u.email AS manager_user_email,
    u.role AS manager_role,
    u.parent_id AS manager_parent_id,
    b.reports_to AS bamboo_reports_to,
    b.supervisor_id AS bamboo_supervisor_id,
    b.job_title AS manager_job_title,
    b.channel AS manager_channel
FROM manager_current hm
LEFT JOIN awsdatacatalog.bold_gold_sales.dim_crm_users u
    ON lower(trim(u.email)) = lower(trim(hm.manager_email))
LEFT JOIN awsdatacatalog.bold_gold_sales.dim_user_bamboo_information b
    ON b.user_id = u.user_id
ORDER BY hm.custom_id;

-- 5) Validar la cadena para los merchants del Handoff.
-- Requiere haber confirmado en la consulta 04/06 el hub_custom_id de cada merchant.
-- Si la relación es correcta, agregar el resultado del bloque 4 al resultado
-- integrado mediante merchant_id -> hub_custom_id -> manager_email.
