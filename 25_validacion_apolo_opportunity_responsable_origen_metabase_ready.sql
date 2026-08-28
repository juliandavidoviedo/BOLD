WITH base_mensual (merchant_id, kam_asignado_email) AS (
    VALUES
        ('0CZTLXEOXY', CAST(NULL AS varchar)),
        ('3SQNBLP4ZN', CAST(NULL AS varchar)),
        ('60WPJO2DZX', CAST(NULL AS varchar)),
        ('7DVLTIUMHX', CAST(NULL AS varchar)),
        ('8R8UIAMUC6', CAST(NULL AS varchar)),
        ('LG773V6IUV', CAST(NULL AS varchar)),
        ('PA1LA4GGYD', CAST(NULL AS varchar)),
        ('RMCVFJO3D8', CAST(NULL AS varchar)),
        ('VMKYJPDVD1', CAST(NULL AS varchar)),
        ('WFK9N0809K', CAST(NULL AS varchar))
),
opportunity_ranked AS (
    SELECT
        cast(o.merchant_id AS varchar) AS merchant_id,
        o.executive_email AS ejecutivo_origen_email,
        o.created_by_id_email AS creador_oportunidad_email,
        o.lead_origin,
        o.lead_merchant_name,
        o.lead_estimated_sale_date,
        o.load_datetime,
        row_number() OVER (
            PARTITION BY o.merchant_id
            ORDER BY o.load_datetime DESC, o.lead_estimated_sale_date DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_sales.dim_apolo_opportunities o
    INNER JOIN base_mensual bm
        ON cast(o.merchant_id AS varchar) = bm.merchant_id
    WHERE o.merchant_id IS NOT NULL
),
opportunity_current AS (
    SELECT
        merchant_id,
        ejecutivo_origen_email,
        creador_oportunidad_email,
        lead_origin,
        lead_merchant_name,
        lead_estimated_sale_date,
        load_datetime
    FROM opportunity_ranked
    WHERE rn = 1
),
crm_users_ranked AS (
    SELECT
        cast(u.user_id AS varchar) AS user_id,
        lower(trim(u.email)) AS email_key,
        u.email,
        cast(u.parent_id AS varchar) AS parent_id,
        u.role,
        u.sales_channel,
        u.status,
        u.load_datetime,
        row_number() OVER (
            PARTITION BY lower(trim(u.email))
            ORDER BY
                CASE WHEN upper(u.status) = 'ACTIVE' THEN 1 ELSE 0 END DESC,
                u.load_datetime DESC
        ) AS rn_email,
        row_number() OVER (
            PARTITION BY u.user_id
            ORDER BY
                CASE WHEN upper(u.status) = 'ACTIVE' THEN 1 ELSE 0 END DESC,
                u.load_datetime DESC
        ) AS rn_user_id
    FROM awsdatacatalog.bold_gold_sales.dim_crm_users u
    WHERE u.user_id IS NOT NULL
      AND u.email IS NOT NULL
      AND u.email <> ''
),
crm_users_by_email AS (
    SELECT user_id, email, email_key, parent_id, role, sales_channel, status
    FROM crm_users_ranked
    WHERE rn_email = 1
),
crm_users_by_id AS (
    SELECT user_id, email, email_key, parent_id, role, sales_channel, status
    FROM crm_users_ranked
    WHERE rn_user_id = 1
),
bamboo_ranked AS (
    SELECT
        cast(b.user_id AS varchar) AS user_id,
        b.reports_to,
        b.job_title,
        b.channel,
        b.status,
        b.load_datetime,
        row_number() OVER (
            PARTITION BY b.user_id
            ORDER BY b.load_datetime DESC, b.event_datetime DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_sales.dim_user_bamboo_information b
    WHERE b.user_id IS NOT NULL
),
bamboo_current AS (
    SELECT user_id, reports_to, job_title, channel, status
    FROM bamboo_ranked
    WHERE rn = 1
)
SELECT
    bm.merchant_id,
    bm.kam_asignado_email,
    oc.ejecutivo_origen_email,
    oc.creador_oportunidad_email,
    coalesce(oc.ejecutivo_origen_email, oc.creador_oportunidad_email) AS responsable_origen_email,
    agente.user_id AS responsable_origen_user_id,
    agente.role AS responsable_origen_role,
    agente.sales_channel AS responsable_origen_sales_channel,
    agente.status AS responsable_origen_status,
    agente_bamboo.job_title AS responsable_origen_job_title,
    agente_bamboo.reports_to AS responsable_origen_reports_to,
    tl.email AS team_lead_origen_email,
    tl.role AS team_lead_origen_role,
    tl.sales_channel AS team_lead_origen_sales_channel,
    tl.status AS team_lead_origen_status,
    tl_bamboo.job_title AS team_lead_origen_job_title,
    tl_bamboo.reports_to AS manager_origen_name,
    manager.email AS manager_origen_email,
    manager.role AS manager_origen_role,
    manager.sales_channel AS manager_origen_sales_channel,
    manager.status AS manager_origen_status,
    manager_bamboo.job_title AS manager_origen_job_title,
    oc.lead_origin,
    oc.lead_merchant_name,
    oc.lead_estimated_sale_date,
    oc.load_datetime AS opportunity_loaded_at,
    CASE
        WHEN oc.merchant_id IS NULL THEN 'SIN_OPORTUNIDAD_APOLO'
        WHEN coalesce(oc.ejecutivo_origen_email, oc.creador_oportunidad_email) IS NULL THEN 'OPORTUNIDAD_SIN_RESPONSABLE_EMAIL'
        WHEN agente.user_id IS NULL THEN 'RESPONSABLE_NO_ENCONTRADO_EN_CRM_USERS'
        WHEN tl.email IS NULL THEN 'SIN_TEAM_LEAD_ORIGEN'
        ELSE 'RESPONSABLE_ORIGEN_RESUELTO'
    END AS estado_responsable_cualitativo
FROM base_mensual bm
LEFT JOIN opportunity_current oc
    ON bm.merchant_id = oc.merchant_id
LEFT JOIN crm_users_by_email agente
    ON lower(trim(coalesce(oc.ejecutivo_origen_email, oc.creador_oportunidad_email))) = agente.email_key
LEFT JOIN bamboo_current agente_bamboo
    ON agente.user_id = agente_bamboo.user_id
LEFT JOIN crm_users_by_id tl
    ON agente.parent_id = tl.user_id
LEFT JOIN bamboo_current tl_bamboo
    ON tl.user_id = tl_bamboo.user_id
LEFT JOIN crm_users_by_id manager
    ON tl.parent_id = manager.user_id
LEFT JOIN bamboo_current manager_bamboo
    ON manager.user_id = manager_bamboo.user_id
ORDER BY bm.merchant_id


##resultado

#	merchant_id	kam_asignado_email	ejecutivo_origen_email	creador_oportunidad_email	responsable_origen_email	responsable_origen_user_id	responsable_origen_role	responsable_origen_sales_channel	responsable_origen_status	responsable_origen_job_title	responsable_origen_reports_to	team_lead_origen_email	team_lead_origen_role	team_lead_origen_sales_channel	team_lead_origen_status	team_lead_origen_job_title	manager_origen_name	manager_origen_email	manager_origen_role	manager_origen_sales_channel	manager_origen_status	manager_origen_job_title	lead_origin	lead_merchant_name	lead_estimated_sale_date	opportunity_loaded_at	estado_responsable_cualitativo
1	0CZTLXEOXY																										SIN_OPORTUNIDAD_APOLO
2	3SQNBLP4ZN																										SIN_OPORTUNIDAD_APOLO
3	60WPJO2DZX																										SIN_OPORTUNIDAD_APOLO
4	7DVLTIUMHX																										SIN_OPORTUNIDAD_APOLO
5	8R8UIAMUC6																										SIN_OPORTUNIDAD_APOLO
6	LG773V6IUV																										SIN_OPORTUNIDAD_APOLO
7	PA1LA4GGYD																										SIN_OPORTUNIDAD_APOLO
8	RMCVFJO3D8																										SIN_OPORTUNIDAD_APOLO
9	VMKYJPDVD1																										SIN_OPORTUNIDAD_APOLO
10	WFK9N0809K																										SIN_OPORTUNIDAD_APOLO
