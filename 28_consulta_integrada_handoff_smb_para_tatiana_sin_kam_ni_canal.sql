
WITH
-- La base mensual entregada por SMB/KAM define el universo de comercios.
-- Campos gestionados fuera de esta consulta:
--   - kam_asignado_email: viene en la base mensual y lo administra el manager de KAMs.
--   - mes_transferencia: puede calcularlo el proceso de carga/automatizacion.
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
        c.merchant_name,
        c.merchant_person_type,
        c.merchant_identification_document_type AS document_type,
        cast(c.merchant_identification_document_number AS varchar) AS document_number,
        c.economic_activity_id,
        c.economic_activity_name,
        c.economic_activity_ciiu,
        c.economic_activity_mcc,
        c.economic_activity_category_id,
        c.economic_activity_description,
        c.location_address_department_code,
        c.merchant_acquisition_channel_sales_agent_email AS sales_agent_email,
        c.sales_source,
        c.marketing_source,
        c.selected_products,
        c.status AS client_status,
        c.onboarding_status,
        c.onboarding_completion_date,
        c.creation_date,
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
    SELECT * FROM client_ranked WHERE rn = 1
),

onboarding_ranked AS (
    SELECT
        cast(o.merchant_id AS varchar) AS merchant_id,
        o.contact_info_email,
        o.contact_info_phone_number,
        o.economic_activity_category_id,
        o.economic_activity_id,
        o.economic_activity_name,
        o.economic_activity_ciiu,
        o.economic_activity_mcc,
        o.economic_activity_description,
        o.address_department_code,
        o.acquisition_channel_sales_agent_email,
        o.onboarding_completion_date,
        o.onboarding_completed_date,
        o.status AS onboarding_source_status,
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
    SELECT * FROM onboarding_ranked WHERE rn = 1
),

geo_ranked AS (
    SELECT
        cast(g.merchant_id AS varchar) AS merchant_id,
        cast(g.hub_custom_id AS varchar) AS hub_custom_id,
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
geo_current AS (
    SELECT * FROM geo_ranked WHERE rn = 1
),

merchant_enrich_ranked AS (
    SELECT
        cast(m.master_merchant_id AS varchar) AS merchant_id,
        m.kyc_verification_status_date,
        m."_1st_transaction_approved_date" AS first_transaction_approved_date,
        m."_4th_transaction_approved_date" AS fourth_transaction_approved_date,
        m."_10th_transaction_approved_date" AS tenth_transaction_approved_date,
        m.last_transaction_approved_date,
        m."_1st_btn_transaction_approved_date" AS first_btn_transaction_approved_date,
        m."_1st_mpos_transaction_approved_date" AS first_mpos_transaction_approved_date,
        m."_1st_link_transaction_approved_date" AS first_link_transaction_approved_date,
        m."_1st_nequi_transaction_approved_date" AS first_nequi_transaction_approved_date,
        m."_1st_qr_transaction_approved_date" AS first_qr_transaction_approved_date,
        m.tpv_total_m0,
        m.tpv_total_m1,
        m.tpv_total_m2,
        m.tpv_total_last_month,
        m.tpv_historic,
        m.tpv_last_quarter,
        m.load_datetime,
        row_number() OVER (
            PARTITION BY m.master_merchant_id
            ORDER BY m.load_datetime DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_growth.mart_master_merchant_enrich m
    INNER JOIN base_mensual bm
        ON cast(m.master_merchant_id AS varchar) = bm.merchant_id
    WHERE m.master_merchant_id IS NOT NULL
),
merchant_enrich_current AS (
    SELECT * FROM merchant_enrich_ranked WHERE rn = 1
),

tpv_monthly_finance AS (
    SELECT
        cast(tpvd.merchant_id AS varchar) AS merchant_id,
        date_trunc('month', cast(d.date AS date)) AS month_date,
        count(tpvd.transaction_id) AS tx_month,
        sum(coalesce(tpvd.tpv, 0)) AS tpv_month,
        sum(CASE WHEN tpvd.plan_name IN ('Bold D+1', 'Bold D+0') THEN coalesce(tpvd.tpv, 0) ELSE 0 END) AS tpv_cuenta_bold_month,
        sum(CASE WHEN tpvd.plan_name IN ('QR_BOLD', 'Otros Bancos D+1', 'legacy') THEN coalesce(tpvd.tpv, 0) ELSE 0 END) AS tpv_otros_bancos_month
    FROM awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction tpvd
    INNER JOIN awsdatacatalog.bold_gold_core.dim_date d
        ON tpvd.date_key = d.date_key
    INNER JOIN base_mensual bm
        ON cast(tpvd.merchant_id AS varchar) = bm.merchant_id
    GROUP BY
        cast(tpvd.merchant_id AS varchar),
        date_trunc('month', cast(d.date AS date))
),
tpv_first_month AS (
    SELECT
        merchant_id,
        min(month_date) AS mes_m0
    FROM tpv_monthly_finance
    WHERE tpv_month > 0
    GROUP BY merchant_id
),
tpv_monthly_maturity AS (
    SELECT
        tm.merchant_id,
        fm.mes_m0,
        tm.month_date,
        date_diff('month', fm.mes_m0, tm.month_date) AS mes_maduracion,
        tm.tx_month,
        tm.tpv_month,
        tm.tpv_cuenta_bold_month,
        tm.tpv_otros_bancos_month
    FROM tpv_monthly_finance tm
    INNER JOIN tpv_first_month fm
        ON tm.merchant_id = fm.merchant_id
    WHERE date_diff('month', fm.mes_m0, tm.month_date) BETWEEN 0 AND 5
),
tpv_m0_m5_finance AS (
    SELECT
        merchant_id,
        min(mes_m0) AS mes_m0,
        max(month_date) AS mes_m5_o_ultimo_observado,
        sum(CASE WHEN mes_maduracion = 0 THEN tpv_month ELSE 0 END) AS tpv_m0,
        sum(CASE WHEN mes_maduracion = 1 THEN tpv_month ELSE 0 END) AS tpv_m1,
        sum(CASE WHEN mes_maduracion = 2 THEN tpv_month ELSE 0 END) AS tpv_m2,
        sum(CASE WHEN mes_maduracion = 3 THEN tpv_month ELSE 0 END) AS tpv_m3,
        sum(CASE WHEN mes_maduracion = 4 THEN tpv_month ELSE 0 END) AS tpv_m4,
        sum(CASE WHEN mes_maduracion = 5 THEN tpv_month ELSE 0 END) AS tpv_m5,
        sum(CASE WHEN mes_maduracion = 0 THEN tx_month ELSE 0 END) AS tx_m0,
        sum(CASE WHEN mes_maduracion = 1 THEN tx_month ELSE 0 END) AS tx_m1,
        sum(CASE WHEN mes_maduracion = 2 THEN tx_month ELSE 0 END) AS tx_m2,
        sum(CASE WHEN mes_maduracion = 3 THEN tx_month ELSE 0 END) AS tx_m3,
        sum(CASE WHEN mes_maduracion = 4 THEN tx_month ELSE 0 END) AS tx_m4,
        sum(CASE WHEN mes_maduracion = 5 THEN tx_month ELSE 0 END) AS tx_m5,
        sum(CASE WHEN mes_maduracion = 0 THEN tpv_cuenta_bold_month ELSE 0 END) AS tpv_cuenta_bold_m0,
        sum(CASE WHEN mes_maduracion = 1 THEN tpv_cuenta_bold_month ELSE 0 END) AS tpv_cuenta_bold_m1,
        sum(CASE WHEN mes_maduracion = 0 THEN tpv_otros_bancos_month ELSE 0 END) AS tpv_otros_bancos_m0,
        sum(CASE WHEN mes_maduracion = 1 THEN tpv_otros_bancos_month ELSE 0 END) AS tpv_otros_bancos_m1,
        count(DISTINCT month_date) AS meses_con_tpv_m0_m5
    FROM tpv_monthly_maturity
    GROUP BY merchant_id
),

terminal_ranked AS (
    SELECT
        cast(t.last_terminal_match_merchant_id AS varchar) AS merchant_id,
        cast(t.terminal_key AS varchar) AS terminal_key,
        t.terminal_model,
        t.current_terminal_status,
        t.last_terminal_match_date,
        t.last_transaction_approved_date,
        t.tpv_m0_since_terminal_activation,
        t.tpv_m1_since_terminal_activation,
        t.tpv_m2_since_terminal_activation,
        t.load_datetime,
        row_number() OVER (
            PARTITION BY t.last_terminal_match_merchant_id, t.terminal_key
            ORDER BY t.load_datetime DESC, t.last_terminal_match_date DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_terminals.mart_terminal_enrich t
    INNER JOIN base_mensual bm
        ON cast(t.last_terminal_match_merchant_id AS varchar) = bm.merchant_id
    WHERE t.last_terminal_match_merchant_id IS NOT NULL
      AND t.terminal_key IS NOT NULL
),
terminals_by_merchant AS (
    SELECT
        merchant_id,
        count(DISTINCT terminal_key) AS numero_terminales,
        array_join(array_sort(array_distinct(array_agg(terminal_key))), ', ') AS terminales_asociadas,
        array_join(array_sort(array_distinct(array_agg(terminal_model))), ', ') AS modelos_terminales,
        array_join(array_sort(array_distinct(array_agg(current_terminal_status))), ', ') AS estados_terminales,
        max(last_terminal_match_date) AS ultima_fecha_asociacion_terminal,
        max(last_transaction_approved_date) AS ultima_transaccion_terminal,
        sum(coalesce(tpv_m0_since_terminal_activation, 0)) AS tpv_terminales_m0,
        sum(coalesce(tpv_m1_since_terminal_activation, 0)) AS tpv_terminales_m1,
        sum(coalesce(tpv_m2_since_terminal_activation, 0)) AS tpv_terminales_m2,
        max(load_datetime) AS terminales_loaded_at
    FROM terminal_ranked
    WHERE rn = 1
    GROUP BY merchant_id
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
        u.country_code,
        u.load_datetime,
        row_number() OVER (
            PARTITION BY u.user_id
            ORDER BY
                CASE WHEN upper(u.status) = 'ACTIVE' THEN 1 ELSE 0 END DESC,
                u.load_datetime DESC
        ) AS rn_user_id,
        row_number() OVER (
            PARTITION BY lower(trim(u.email))
            ORDER BY
                CASE WHEN upper(u.status) = 'ACTIVE' THEN 1 ELSE 0 END DESC,
                u.load_datetime DESC
        ) AS rn_email
    FROM awsdatacatalog.bold_gold_sales.dim_crm_users u
    WHERE u.user_id IS NOT NULL
      AND u.email IS NOT NULL
      AND u.email <> ''
),
crm_users_by_id AS (
    SELECT user_id, email, email_key, parent_id, role, sales_channel, status, country_code, load_datetime
    FROM crm_users_ranked
    WHERE rn_user_id = 1
),
crm_users_by_email AS (
    SELECT user_id, email, email_key, parent_id, role, sales_channel, status, country_code, load_datetime
    FROM crm_users_ranked
    WHERE rn_email = 1
),

bamboo_ranked AS (
    SELECT
        cast(b.user_id AS varchar) AS user_id,
        b.reports_to,
        cast(b.supervisor_id AS varchar) AS supervisor_id,
        b.city,
        b.region,
        cast(b.hub_custom_id AS varchar) AS hub_custom_id,
        b.hub_name,
        b.job_title,
        b.channel,
        b.status,
        b.vinculation_status,
        b.load_datetime,
        row_number() OVER (
            PARTITION BY b.user_id
            ORDER BY b.load_datetime DESC, b.event_datetime DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_sales.dim_user_bamboo_information b
    WHERE b.user_id IS NOT NULL
),
bamboo_current AS (
    SELECT *
    FROM bamboo_ranked
    WHERE rn = 1
),

location_ranked AS (
    SELECT
        cast(p.custom_id AS varchar) AS custom_id,
        p.manager_email,
        p.status,
        p.load_datetime,
        row_number() OVER (
            PARTITION BY p.custom_id
            ORDER BY p.load_datetime DESC, p.event_datetime DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_sales.dim_crm_pos_locations p
    WHERE p.custom_id IS NOT NULL
),
location_current AS (
    SELECT custom_id, manager_email, status, load_datetime
    FROM location_ranked
    WHERE rn = 1
),

opportunity_ranked AS (
    SELECT
        bm.merchant_id,
        cast(o.opportunity_id AS varchar) AS opportunity_id,
        o.status AS opportunity_status,
        o.lost_status,
        o.sales_channel AS opportunity_sales_channel,
        o.opportunity_type,
        o.management_type AS opportunity_management_type,
        o.product_type AS opportunity_product_type,
        o.product_name AS opportunity_product_name,
        o.company_name AS opportunity_company_name,
        o.origin_name AS opportunity_origin_name,
        o.creation_date AS opportunity_creation_date,
        o.last_update_date AS opportunity_last_update_date,
        o.won_date AS opportunity_won_date,
        o.activation_date AS opportunity_activation_date,
        cast(o.user_id AS varchar) AS responsable_origen_user_id,
        o.load_datetime AS opportunity_loaded_at,
        row_number() OVER (
            PARTITION BY bm.merchant_id
            ORDER BY
                CASE WHEN o.won_date IS NOT NULL THEN 1 ELSE 0 END DESC,
                o.won_date DESC,
                o.activation_date DESC,
                o.last_update_date DESC,
                o.creation_date DESC,
                o.load_datetime DESC
        ) AS rn
    FROM base_mensual bm
    INNER JOIN awsdatacatalog.bold_gold_sales.dim_crm_opportunities o
        ON bm.merchant_id = cast(coalesce(o.product_merchant_id, o.metadata_merchant_id) AS varchar)
    WHERE coalesce(o.product_merchant_id, o.metadata_merchant_id) IS NOT NULL
),
opportunity_current AS (
    SELECT
        merchant_id,
        opportunity_id,
        opportunity_status,
        lost_status,
        opportunity_sales_channel,
        opportunity_type,
        opportunity_management_type,
        opportunity_product_type,
        opportunity_product_name,
        opportunity_company_name,
        opportunity_origin_name,
        opportunity_creation_date,
        opportunity_last_update_date,
        opportunity_won_date,
        opportunity_activation_date,
        responsable_origen_user_id,
        opportunity_loaded_at
    FROM opportunity_ranked
    WHERE rn = 1
),

base_integrada AS (
    SELECT
        bm.merchant_id,
        c.client_id,
        c.merchant_name,
        c.merchant_person_type,
        c.document_type,
        c.document_number,
        oc.opportunity_id,
        oc.opportunity_status,
        oc.lost_status,
        oc.opportunity_sales_channel,
        oc.opportunity_type,
        oc.opportunity_management_type,
        oc.opportunity_product_type,
        oc.opportunity_product_name,
        oc.opportunity_company_name,
        oc.opportunity_origin_name,
        oc.opportunity_creation_date,
        oc.opportunity_last_update_date,
        oc.opportunity_won_date,
        oc.opportunity_activation_date,
        responsable_origen.user_id AS responsable_origen_user_id,
        responsable_origen.email AS responsable_origen_email,
        responsable_origen.role AS responsable_origen_role,
        responsable_origen.sales_channel AS responsable_origen_sales_channel,
        responsable_origen.status AS responsable_origen_status,
        responsable_origen_bamboo.job_title AS responsable_origen_job_title,
        responsable_origen_bamboo.reports_to AS responsable_origen_reports_to,
        tl_origen.user_id AS team_lead_origen_user_id,
        tl_origen.email AS team_lead_origen_email,
        tl_origen.role AS team_lead_origen_role,
        tl_origen.sales_channel AS team_lead_origen_sales_channel,
        tl_origen.status AS team_lead_origen_status,
        tl_origen_bamboo.job_title AS team_lead_origen_job_title,
        manager_origen.user_id AS manager_origen_user_id,
        manager_origen.email AS manager_origen_email,
        manager_origen.role AS manager_origen_role,
        manager_origen.sales_channel AS manager_origen_sales_channel,
        manager_origen.status AS manager_origen_status,
        manager_origen_bamboo.job_title AS manager_origen_job_title,
        oc.opportunity_loaded_at,
        CASE
            WHEN oc.opportunity_id IS NULL THEN 'SIN_OPORTUNIDAD_CRM'
            WHEN oc.responsable_origen_user_id IS NULL THEN 'OPORTUNIDAD_SIN_USER_ID'
            WHEN responsable_origen.user_id IS NULL THEN 'RESPONSABLE_NO_ENCONTRADO_EN_CRM_USERS'
            WHEN tl_origen.user_id IS NULL THEN 'SIN_TEAM_LEAD_ORIGEN'
            ELSE 'RESPONSABLE_ORIGEN_RESUELTO'
        END AS estado_responsable_cualitativo,
        coalesce(c.economic_activity_category_id, o.economic_activity_category_id) AS category_id,
        cast(NULL AS varchar) AS subcategory_id,
        coalesce(g.dane_code, g.municipality) AS city_code,
        coalesce(c.location_address_department_code, o.address_department_code, g.department) AS department_code,
        g.standardized_address AS address,
        o.contact_info_email AS email,
        o.contact_info_phone_number AS cellphone_number,
        coalesce(c.sales_agent_email, o.acquisition_channel_sales_agent_email) AS sales_agent_email,
        g.hub_custom_id,
        hu.email AS hub_manager_email,
        hu.role AS hub_manager_role,
        hb.job_title AS hub_manager_job_title,
        lc.status AS hub_location_status,
        agent.user_id AS sales_agent_user_id,
        agent.role AS sales_agent_role,
        agent.sales_channel AS sales_agent_sales_channel,
        agent.status AS sales_agent_status,
        agent_bamboo.job_title AS sales_agent_job_title,
        agent_bamboo.channel AS sales_agent_bamboo_channel,
        agent_bamboo.reports_to AS team_lead_name_from_bamboo,
        tl.user_id AS team_lead_user_id,
        tl.email AS team_lead_email,
        tl.role AS team_lead_role,
        tl.sales_channel AS team_lead_sales_channel,
        tl.status AS team_lead_status,
        tl_bamboo.job_title AS team_lead_job_title,
        tl_bamboo.channel AS team_lead_bamboo_channel,
        tl_bamboo.reports_to AS manager_name_from_bamboo,
        mgr.user_id AS manager_user_id,
        mgr.email AS manager_email,
        mgr.role AS manager_role,
        mgr.sales_channel AS manager_sales_channel,
        mgr.status AS manager_status,
        mgr_bamboo.job_title AS manager_job_title,
        mgr_bamboo.channel AS manager_bamboo_channel,
        coalesce(tf.tpv_m0, 0) AS tpv_m0,
        coalesce(tf.tpv_m1, 0) AS tpv_m1,
        coalesce(tf.tpv_m2, 0) AS tpv_m2,
        coalesce(tf.tpv_m3, 0) AS tpv_m3,
        coalesce(tf.tpv_m4, 0) AS tpv_m4,
        coalesce(tf.tpv_m5, 0) AS tpv_m5,
        coalesce(tf.tx_m0, 0) AS tx_m0,
        coalesce(tf.tx_m1, 0) AS tx_m1,
        coalesce(tf.tx_m2, 0) AS tx_m2,
        coalesce(tf.tx_m3, 0) AS tx_m3,
        coalesce(tf.tx_m4, 0) AS tx_m4,
        coalesce(tf.tx_m5, 0) AS tx_m5,
        coalesce(tf.tpv_cuenta_bold_m0, 0) AS tpv_cuenta_bold_m0,
        coalesce(tf.tpv_cuenta_bold_m1, 0) AS tpv_cuenta_bold_m1,
        coalesce(tf.tpv_otros_bancos_m0, 0) AS tpv_otros_bancos_m0,
        coalesce(tf.tpv_otros_bancos_m1, 0) AS tpv_otros_bancos_m1,
        CASE
            WHEN coalesce(tf.tpv_m0, 0) = 0 THEN NULL
            ELSE (coalesce(tf.tpv_m1, 0) - coalesce(tf.tpv_m0, 0)) / coalesce(tf.tpv_m0, 0)
        END AS crecimiento_m1_vs_m0,
        CASE
            WHEN coalesce(tf.tpv_m0, 0) = 0 THEN NULL
            ELSE (coalesce(tf.tpv_m5, 0) - coalesce(tf.tpv_m0, 0)) / coalesce(tf.tpv_m0, 0)
        END AS crecimiento_m5_vs_m0,
        CASE
            WHEN (
                coalesce(tf.tpv_m0, 0) + coalesce(tf.tpv_m1, 0) + coalesce(tf.tpv_m2, 0)
            ) = 0 THEN NULL
            ELSE (
                coalesce(tf.tpv_m3, 0) + coalesce(tf.tpv_m4, 0) + coalesce(tf.tpv_m5, 0)
                - coalesce(tf.tpv_m0, 0) - coalesce(tf.tpv_m1, 0) - coalesce(tf.tpv_m2, 0)
            ) / nullif(
                coalesce(tf.tpv_m0, 0) + coalesce(tf.tpv_m1, 0) + coalesce(tf.tpv_m2, 0),
                0
            )
        END AS crecimiento_m3_m5_vs_m0_m2,
        tf.mes_m0,
        tf.mes_m5_o_ultimo_observado,
        coalesce(tf.meses_con_tpv_m0_m5, 0) AS meses_con_tpv_m0_m5,
        coalesce(e.tpv_total_m0, 0) AS tpv_total_m0_growth,
        coalesce(e.tpv_total_m1, 0) AS tpv_total_m1_growth,
        coalesce(e.tpv_total_m2, 0) AS tpv_total_m2_growth,
        coalesce(e.tpv_total_last_month, 0) AS tpv_total_last_month,
        coalesce(e.tpv_historic, 0) AS tpv_historic,
        coalesce(e.tpv_last_quarter, 0) AS tpv_last_quarter,
        greatest(
            coalesce(tf.tpv_m0, 0),
            coalesce(tf.tpv_m1, 0),
            coalesce(tf.tpv_m2, 0),
            coalesce(tf.tpv_m3, 0),
            coalesce(tf.tpv_m4, 0),
            coalesce(tf.tpv_m5, 0)
        ) AS tpv_max,
        c.selected_products,
        c.sales_source,
        c.marketing_source,
        c.client_status,
        c.onboarding_status,
        c.onboarding_completion_date,
        e.kyc_verification_status_date,
        e.first_transaction_approved_date,
        e.fourth_transaction_approved_date,
        e.tenth_transaction_approved_date,
        e.last_transaction_approved_date,
        e.first_btn_transaction_approved_date,
        e.first_mpos_transaction_approved_date,
        e.first_link_transaction_approved_date,
        e.first_nequi_transaction_approved_date,
        e.first_qr_transaction_approved_date,
        coalesce(te.numero_terminales, 0) AS numero_terminales,
        te.terminales_asociadas,
        te.modelos_terminales,
        te.estados_terminales,
        te.ultima_fecha_asociacion_terminal,
        te.ultima_transaccion_terminal,
        coalesce(te.tpv_terminales_m0, 0) AS tpv_terminales_m0,
        coalesce(te.tpv_terminales_m1, 0) AS tpv_terminales_m1,
        coalesce(te.tpv_terminales_m2, 0) AS tpv_terminales_m2,
        CASE WHEN e.first_mpos_transaction_approved_date IS NOT NULL THEN true ELSE false END AS tiene_pos,
        CASE WHEN e.first_link_transaction_approved_date IS NOT NULL THEN true ELSE false END AS tiene_link_pago,
        CASE WHEN e.first_btn_transaction_approved_date IS NOT NULL THEN true ELSE false END AS tiene_boton_pago,
        CASE WHEN e.first_qr_transaction_approved_date IS NOT NULL THEN true ELSE false END AS tiene_qr,
        c.last_update_event_date AS dim_client_updated_at,
        e.load_datetime AS merchant_enrich_loaded_at,
        g.load_datetime AS georeference_loaded_at,
        te.terminales_loaded_at,
        lc.load_datetime AS hub_location_loaded_at
    FROM base_mensual bm
    LEFT JOIN client_current c ON bm.merchant_id = c.merchant_id
    LEFT JOIN onboarding_current o ON bm.merchant_id = o.merchant_id
    LEFT JOIN geo_current g ON bm.merchant_id = g.merchant_id
    LEFT JOIN merchant_enrich_current e ON bm.merchant_id = e.merchant_id
    LEFT JOIN tpv_m0_m5_finance tf ON bm.merchant_id = tf.merchant_id
    LEFT JOIN terminals_by_merchant te ON bm.merchant_id = te.merchant_id
    LEFT JOIN opportunity_current oc ON bm.merchant_id = oc.merchant_id
    LEFT JOIN crm_users_by_id responsable_origen ON oc.responsable_origen_user_id = responsable_origen.user_id
    LEFT JOIN bamboo_current responsable_origen_bamboo ON responsable_origen.user_id = responsable_origen_bamboo.user_id
    LEFT JOIN crm_users_by_id tl_origen ON responsable_origen.parent_id = tl_origen.user_id
    LEFT JOIN bamboo_current tl_origen_bamboo ON tl_origen.user_id = tl_origen_bamboo.user_id
    LEFT JOIN crm_users_by_id manager_origen ON tl_origen.parent_id = manager_origen.user_id
    LEFT JOIN bamboo_current manager_origen_bamboo ON manager_origen.user_id = manager_origen_bamboo.user_id
    LEFT JOIN location_current lc ON g.hub_custom_id = lc.custom_id
    LEFT JOIN crm_users_by_email hu ON lower(trim(lc.manager_email)) = hu.email_key
    LEFT JOIN bamboo_current hb ON hu.user_id = hb.user_id
    LEFT JOIN crm_users_by_email agent
        ON lower(trim(coalesce(c.sales_agent_email, o.acquisition_channel_sales_agent_email))) = agent.email_key
    LEFT JOIN bamboo_current agent_bamboo ON agent.user_id = agent_bamboo.user_id
    LEFT JOIN crm_users_by_id tl ON agent.parent_id = tl.user_id
    LEFT JOIN bamboo_current tl_bamboo ON tl.user_id = tl_bamboo.user_id
    LEFT JOIN crm_users_by_id mgr ON tl.parent_id = mgr.user_id
    LEFT JOIN bamboo_current mgr_bamboo ON mgr.user_id = mgr_bamboo.user_id
),

base_enriquecida AS (
    SELECT *
    FROM base_integrada
)

SELECT
    merchant_id,
    client_id,
    merchant_name,
    merchant_person_type,
    document_type,
    document_number,
    opportunity_id,
    opportunity_status,
    lost_status,
    opportunity_sales_channel,
    opportunity_type,
    opportunity_management_type,
    opportunity_product_type,
    opportunity_product_name,
    opportunity_company_name,
    opportunity_origin_name,
    opportunity_creation_date,
    opportunity_last_update_date,
    opportunity_won_date,
    opportunity_activation_date,
    responsable_origen_user_id,
    responsable_origen_email,
    responsable_origen_role,
    responsable_origen_sales_channel,
    responsable_origen_status,
    responsable_origen_job_title,
    responsable_origen_reports_to,
    team_lead_origen_user_id,
    team_lead_origen_email,
    team_lead_origen_role,
    team_lead_origen_sales_channel,
    team_lead_origen_status,
    team_lead_origen_job_title,
    manager_origen_user_id,
    manager_origen_email,
    manager_origen_role,
    manager_origen_sales_channel,
    manager_origen_status,
    manager_origen_job_title,
    opportunity_loaded_at,
    estado_responsable_cualitativo,
    category_id,
    subcategory_id,
    city_code,
    department_code,
    address,
    email,
    NULLIF(cellphone_number, '') AS cellphone_number,
    sales_agent_email,
    sales_agent_user_id,
    sales_agent_role,
    sales_agent_sales_channel,
    sales_agent_status,
    sales_agent_job_title,
    sales_agent_bamboo_channel,
    team_lead_name_from_bamboo AS team_lead_name,
    team_lead_email,
    team_lead_role,
    team_lead_sales_channel,
    team_lead_status,
    team_lead_job_title,
    team_lead_bamboo_channel,
    manager_name_from_bamboo AS manager_name,
    manager_email,
    manager_role,
    manager_sales_channel,
    manager_status,
    manager_job_title,
    manager_bamboo_channel,
    hub_custom_id,
    hub_manager_email,
    hub_manager_role,
    hub_manager_job_title,
    hub_location_status,
    tpv_max,
    CASE
        WHEN tpv_max >= 40000000 THEN 'Mayor a 40M'
        WHEN tpv_max >= 20000000 THEN 'Entre 20M y 40M'
        ELSE 'Menor a 20M'
    END AS clasificacion_calculada,
    numero_terminales,
    terminales_asociadas,
    modelos_terminales,
    estados_terminales,
    ultima_fecha_asociacion_terminal,
    ultima_transaccion_terminal,
    tiene_pos,
    tiene_link_pago,
    tiene_boton_pago,
    tiene_qr,
    selected_products,
    sales_source,
    marketing_source,
    client_status,
    onboarding_status,
    onboarding_completion_date,
    kyc_verification_status_date,
    first_transaction_approved_date,
    fourth_transaction_approved_date,
    tenth_transaction_approved_date,
    last_transaction_approved_date,
    first_btn_transaction_approved_date,
    first_mpos_transaction_approved_date,
    first_link_transaction_approved_date,
    first_nequi_transaction_approved_date,
    first_qr_transaction_approved_date,
    tpv_m0,
    tpv_m1,
    tpv_m2,
    tpv_m3,
    tpv_m4,
    tpv_m5,
    tx_m0,
    tx_m1,
    tx_m2,
    tx_m3,
    tx_m4,
    tx_m5,
    tpv_cuenta_bold_m0,
    tpv_cuenta_bold_m1,
    tpv_otros_bancos_m0,
    tpv_otros_bancos_m1,
    crecimiento_m1_vs_m0,
    crecimiento_m5_vs_m0,
    crecimiento_m3_m5_vs_m0_m2,
    mes_m0,
    mes_m5_o_ultimo_observado,
    meses_con_tpv_m0_m5,
    CASE
        WHEN meses_con_tpv_m0_m5 = 6 THEN 'CUMPLE_6_MESES_TRANSACCIONALIDAD'
        WHEN meses_con_tpv_m0_m5 BETWEEN 1 AND 5 THEN 'NO_CUMPLE_6_MESES_TRANSACCIONALIDAD'
        ELSE 'SIN_TPV_EN_FUENTE_FINANCE'
    END AS estado_maduracion_tpv,
    tpv_total_m0_growth,
    tpv_total_m1_growth,
    tpv_total_m2_growth,
    tpv_total_last_month,
    tpv_historic,
    tpv_last_quarter,
    tpv_terminales_m0,
    tpv_terminales_m1,
    tpv_terminales_m2,
    CASE
        WHEN estado_responsable_cualitativo = 'RESPONSABLE_ORIGEN_RESUELTO' THEN 'JERARQUIA_ORIGEN_CRM_RESUELTA'
        WHEN estado_responsable_cualitativo IN (
            'SIN_OPORTUNIDAD_CRM',
            'OPORTUNIDAD_SIN_USER_ID',
            'RESPONSABLE_NO_ENCONTRADO_EN_CRM_USERS',
            'SIN_TEAM_LEAD_ORIGEN'
        ) THEN estado_responsable_cualitativo
        WHEN sales_agent_email IS NULL THEN 'SIN_SALES_AGENT_EMAIL'
        WHEN team_lead_email IS NULL THEN 'SIN_MATCH_TEAM_LEAD_POR_PARENT_ID'
        WHEN manager_email IS NULL THEN 'SIN_MATCH_MANAGER_POR_PARENT_ID'
        ELSE 'JERARQUIA_COMERCIAL_RESUELTA'
    END AS estado_jerarquia_comercial,
    CASE
        WHEN hub_custom_id IS NULL THEN 'SIN_HUB_CUSTOM_ID'
        WHEN hub_manager_email IS NULL THEN 'SIN_MANAGER_EMAIL_HUB'
        ELSE 'HUB_RESUELTO'
    END AS estado_jerarquia_hub,
    dim_client_updated_at,
    merchant_enrich_loaded_at,
    georeference_loaded_at,
    terminales_loaded_at,
    hub_location_loaded_at,
    current_timestamp AS record_updated_at
FROM base_enriquecida
ORDER BY merchant_id


##resultado
#	merchant_id	client_id	merchant_name	merchant_person_type	document_type	document_number	opportunity_id	opportunity_status	lost_status	opportunity_sales_channel	opportunity_type	opportunity_management_type	opportunity_product_type	opportunity_product_name	opportunity_company_name	opportunity_origin_name	opportunity_creation_date	opportunity_last_update_date	opportunity_won_date	opportunity_activation_date	responsable_origen_user_id	responsable_origen_email	responsable_origen_role	responsable_origen_sales_channel	responsable_origen_status	responsable_origen_job_title	responsable_origen_reports_to	team_lead_origen_user_id	team_lead_origen_email	team_lead_origen_role	team_lead_origen_sales_channel	team_lead_origen_status	team_lead_origen_job_title	manager_origen_user_id	manager_origen_email	manager_origen_role	manager_origen_sales_channel	manager_origen_status	manager_origen_job_title	opportunity_loaded_at	estado_responsable_cualitativo	category_id	subcategory_id	city_code	department_code	address	email	cellphone_number	sales_agent_email	sales_agent_user_id	sales_agent_role	sales_agent_sales_channel	sales_agent_status	sales_agent_job_title	sales_agent_bamboo_channel	team_lead_name	team_lead_email	team_lead_role	team_lead_sales_channel	team_lead_status	team_lead_job_title	team_lead_bamboo_channel	manager_name	manager_email	manager_role	manager_sales_channel	manager_status	manager_job_title	manager_bamboo_channel	hub_custom_id	hub_manager_email	hub_manager_role	hub_manager_job_title	hub_location_status	tpv_max	clasificacion_calculada	numero_terminales	terminales_asociadas	modelos_terminales	estados_terminales	ultima_fecha_asociacion_terminal	ultima_transaccion_terminal	tiene_pos	tiene_link_pago	tiene_boton_pago	tiene_qr	selected_products	sales_source	marketing_source	client_status	onboarding_status	onboarding_completion_date	kyc_verification_status_date	first_transaction_approved_date	fourth_transaction_approved_date	tenth_transaction_approved_date	last_transaction_approved_date	first_btn_transaction_approved_date	first_mpos_transaction_approved_date	first_link_transaction_approved_date	first_nequi_transaction_approved_date	first_qr_transaction_approved_date	tpv_m0	tpv_m1	tpv_m2	tpv_m3	tpv_m4	tpv_m5	tx_m0	tx_m1	tx_m2	tx_m3	tx_m4	tx_m5	tpv_cuenta_bold_m0	tpv_cuenta_bold_m1	tpv_otros_bancos_m0	tpv_otros_bancos_m1	crecimiento_m1_vs_m0	crecimiento_m5_vs_m0	crecimiento_m3_m5_vs_m0_m2	mes_m0	mes_m5_o_ultimo_observado	meses_con_tpv_m0_m5	estado_maduracion_tpv	tpv_total_m0_growth	tpv_total_m1_growth	tpv_total_m2_growth	tpv_total_last_month	tpv_historic	tpv_last_quarter	tpv_terminales_m0	tpv_terminales_m1	tpv_terminales_m2	estado_jerarquia_comercial	estado_jerarquia_hub	dim_client_updated_at	merchant_enrich_loaded_at	georeference_loaded_at	terminales_loaded_at	hub_location_loaded_at	record_updated_at
1	0CZTLXEOXY	YZTGJW0CUW	Negocio de jose eliberto	NATURAL_PERSON	CEDULA	4050698																																			SIN_OPORTUNIDAD_CRM	FOOD_AND_DRINK			MAGDALENA		baratondela6@gmail.com	3239751330	jorge.amaya@bold.co	K6GWWA7PYH	EXECUTIVE	SMB	ACTIVE	SMB Sales Executive	SMB	Carolina Daza González	carolina.daza@bold.co	LEADER	SMB	ACTIVE	SMB Team Lead	SMB	Hector Causil Arguelles	hector.causil@bold.co	MANAGER	SMB	ACTIVE	Sales Manager SMB	SMB	HUBSTAMAR	carlos.gil@bold.co	HUB_LEADER		ACTIVE	29710980.0000	Entre 20M y 40M	2	6e15a3b5337436c948b07216bf8243c6, f2f7bad191389e77eda1df865c473fca	ET389, N86	BINDED	2026-01-10 09:40:03.694000	2026-02-14 18:53:46.776000	true	false	false	true	["PAYMENTS","DEPOSIT_ACCOUNT"]	SMB		ENABLED	APPROVED	2026-01-10 09:06:02.488	2026-01-10 09:17:15.205000	2026-01-10 09:35:25.571000	2026-01-10 10:07:54.638000	2026-01-10 11:00:54.230000	2026-02-14 18:53:46.776000		2026-01-10 09:40:48.473474		2026-01-10 09:43:49.518389	2026-01-10 09:35:25.571000	29710980.0000	16182220.0000	0.0000	0.0000	0.0000	0.0000	704	392	0	0	0	0	15255510.0000	8922430.0000	14455470.0000	7259790.0000	-0.4553	-1.0000	-1.0000	2026-01-01	2026-02-01	2	NO_CUMPLE_6_MESES_TRANSACCIONALIDAD	29710980.00	16182220.00	0.00	0.00	45893200.00	0.00	23111850.0000	13164600.0000	0.0000	SIN_OPORTUNIDAD_CRM	HUB_RESUELTO	2026-01-10 09:18:26.331	2026-08-27 05:33:17.120000	2026-08-27 06:03:46.913000	2026-08-27 05:53:52.363000	2025-11-26 17:40:29.758	2026-08-28 06:37:39.445 UTC
2	3SQNBLP4ZN	5J8QAM22E6	La Tierrita del berriondo	LEGAL_PERSON	NIT	902017706																																			SIN_OPORTUNIDAD_CRM	FOOD_AND_DRINK			CUNDINAMARCA		latierritadelberriondo@gmail.com	3227438193																											603172259.0000	Mayor a 40M	8	62e58be508f0c2028542189fe04a8efe, 6ffb58030c7693a472c2829f693ec756, 7e5893ebe0e4535bcc6f45c4ae011008, 84e05bbd5b297a10badcdf751688241e, 9186f3b79d8c24921e0db1723de6113e, c09179f6cc47d69985ab7f3bec92aef0, cef3693749e58140306f60e92e6c693e, e5e58a5586249107ba3d41f8170e1026	ET389, N86	BINDED	2026-05-02 16:37:46.788000	2026-08-26 21:34:22.081982	true	true	false	true	["DEPOSIT_ACCOUNT","PAYMENTS"]	INBOUND		ENABLED	APPROVED	2025-12-19 18:48:33.091	2025-12-19 19:02:38.898000	2026-01-09 14:51:16.718435	2026-01-09 15:54:33.632051	2026-01-09 16:06:28.576331	2026-08-26 21:34:22.081982		2026-01-09 14:51:16.718435	2026-01-15 16:51:30.502885	2026-01-09 15:23:08.909904	2026-03-27 18:42:48.424000	285184464.0000	362768718.0000	496558714.0000	443406145.0000	603172259.0000	533325970.0000	1471	1750	2292	2048	2655	2235	0.0000	0.0000	285184464.0000	362768718.0000	0.2720	0.8701	0.3804	2026-01-01	2026-06-01	6	CUMPLE_6_MESES_TRANSACCIONALIDAD	0.00	285184464.00	362768718.00	533062898.00	3257479168.00	1579904374.00	489627453.0000	540918323.0000	672520164.0000	SIN_OPORTUNIDAD_CRM	SIN_HUB_CUSTOM_ID	2026-03-27 18:33:26.569	2026-08-27 05:33:17.120000		2026-08-27 05:53:52.363000		2026-08-28 06:37:39.445 UTC
3	60WPJO2DZX	38M3KH6JCS	Altapone	NATURAL_PERSON	CEDULA	1026555886																																			SIN_OPORTUNIDAD_CRM	FOOD_AND_DRINK			CUNDINAMARCA		enrique1888@hotmail.com	3214258045																						HUBKENBOG	diana.prieto@bold.co	LEADER	Hubs Team Lead	ACTIVE	25684258.0000	Entre 20M y 40M	0						false	false	false	false	["DEPOSIT_ACCOUNT","PAYMENTS"]	INBOUND		ENABLED	APPROVED	2026-01-29 18:17:31.513											3376250.0000	25684258.0000	6124675.0000	0.0000	0.0000	0.0000	52	310	89	0	0	0	136350.0000	5117750.0000	3239900.0000	20566508.0000	6.6073	-1.0000	-1.0000	2026-01-01	2026-03-01	3	NO_CUMPLE_6_MESES_TRANSACCIONALIDAD	0.00	0.00	0.00	0.00	0.00	0.00	0.0000	0.0000	0.0000	SIN_OPORTUNIDAD_CRM	HUB_RESUELTO	2026-01-29 18:23:26.913		2026-08-27 06:03:46.913000		2026-05-07 16:05:09.300	2026-08-28 06:37:39.445 UTC
4	7DVLTIUMHX	N1B5IVK9T3	JM ENDOSCOPY SAS	LEGAL_PERSON	NIT	900771314	1L36AMV0C5	WON		SMB			PAYMENT_LINK	PAYMENT_LINK		DATABASE	2026-01-15 15:56:07.033	2026-01-15 16:26:08.826	2026-01-15 16:26:08.826	2026-01-15 00:00:00.000	SD5LTUFFXU	tatiana.cuadro@bold.co	EXECUTIVE	SMB	ACTIVE	SMB Sales Executive	Carolina Daza González	B1ETH8RKIY	carolina.daza@bold.co	LEADER	SMB	ACTIVE	SMB Team Lead	LR78SVJ61Y	hector.causil@bold.co	MANAGER	SMB	ACTIVE	Sales Manager SMB	2026-08-27 19:19:37.930	RESPONSABLE_ORIGEN_RESUELTO	SERVICES			ATLANTICO		jesusperezorozco@gmail.com	3008001157																						HUBPALLBQ	luis.castellar@bold.co	HUB_LEADER	Hubs Team Lead	ACTIVE	28550991.0000	Entre 20M y 40M	0						false	true	false	false	["PAYMENTS"]	INBOUND		ENABLED	APPROVED	2026-01-15 15:11:04.845	2026-01-15 16:09:27.179000	2026-01-15 16:15:42.932355	2026-01-16 08:48:36.762993	2026-02-05 15:22:41.778202	2026-02-05 15:22:41.778202			2026-01-15 16:15:42.932355			28550991.0000	3610242.0000	0.0000	0.0000	0.0000	0.0000	8	2	0	0	0	0	0.0000	0.0000	28550991.0000	3610242.0000	-0.8736	-1.0000	-1.0000	2026-01-01	2026-02-01	2	NO_CUMPLE_6_MESES_TRANSACCIONALIDAD	28550991.00	3610242.00	0.00	0.00	32161233.00	0.00	0.0000	0.0000	0.0000	JERARQUIA_ORIGEN_CRM_RESUELTA	HUB_RESUELTO	2026-01-15 16:09:17.177	2026-08-27 05:33:17.120000	2026-08-27 06:03:46.913000		2025-11-26 17:40:29.758	2026-08-28 06:37:39.445 UTC
5	8R8UIAMUC6	TO87CK5OFY	Wiki Electrónic	LEGAL_PERSON	NIT	901374005	04VNKMIVWZ	WON		SMB			PAYMENT_LINK	PAYMENT_LINK		DATABASE	2025-12-29 12:21:11.861	2026-01-26 14:06:56.463	2026-01-26 14:06:56.463	2026-01-26 00:00:00.000	QX9IZB8SRB	felipe.gomez@bold.co	EXECUTIVE	SMB	ACTIVE	SMB Sales Executive	Leslie Grajales  Morales	HGGPZJQG4C	tatiana.grajales@bold.co	LEADER	SMB	ACTIVE	SMB Team Lead	HGGPZJQG4C	tatiana.grajales@bold.co	LEADER	SMB	ACTIVE	SMB Team Lead	2026-08-27 19:19:37.930	RESPONSABLE_ORIGEN_RESUELTO	RETAIL_TRADE			ANTIOQUIA		wikielectronic18@gmail.com	3504687921																						HUBRIOMED	carolina.casas@bold.co	HUB_LEADER	Hubs Team Lead	ACTIVE	33019000.0000	Entre 20M y 40M	1	b14b6f8666fad2949609cffc19551997	N86	BINDED	2026-01-26 11:56:57.040000	2026-08-26 16:54:03.405692	true	true	false	false	["PAYMENTS"]	INBOUND		ENABLED	APPROVED	2026-01-26 11:12:31.747	2026-01-26 11:40:28.634000	2026-01-26 11:57:32.389595	2026-01-27 14:25:27.679878	2026-01-30 18:13:52.305205	2026-08-26 16:54:03.405692		2026-01-26 11:57:32.389595	2026-07-14 16:05:28.874332			7171000.0000	33019000.0000	8087500.0000	0.0000	0.0000	0.0000	13	68	16	0	0	0	0.0000	0.0000	7171000.0000	33019000.0000	3.6045	-1.0000	-1.0000	2026-01-01	2026-03-01	3	NO_CUMPLE_6_MESES_TRANSACCIONALIDAD	7171000.00	33019000.00	8087500.00	21684000.00	69961500.00	0.00	7171000.0000	33019000.0000	8087500.0000	JERARQUIA_ORIGEN_CRM_RESUELTA	HUB_RESUELTO	2026-01-26 11:40:20.638	2026-08-27 05:33:17.120000	2026-08-27 06:03:46.913000	2026-08-27 05:53:52.363000	2025-11-26 17:40:29.758	2026-08-28 06:37:39.445 UTC
6	LG773V6IUV	43T9HOMMX6	BODYBRITE	LEGAL_PERSON	NIT	901303792	HUNEBH00XQ	WON		SMB			PAYMENT_LINK	PAYMENT_LINK		LQT_MARKETING	2026-01-18 21:36:21.145	2026-02-06 10:45:32.318	2026-02-06 10:45:32.318	2026-02-06 00:00:00.000	2QNFHSUAJ8	esmeralda.malagon@bold.co	EXECUTIVE	SMB	ACTIVE	SMB Sales Executive	Maira Bautista Peraza	1KA41SKQ87	alejandra.bautista@bold.co	LEADER	SMB	ACTIVE	SMB Team Lead	D3TSS47WXG	andres.guerrero@bold.co	MANAGER	SMB	ACTIVE	Sales Manager SMB	2026-08-27 19:19:37.930	RESPONSABLE_ORIGEN_RESUELTO	BEAUTY_AND_PERSONAL_CARE			CUNDINAMARCA		directorgeneral@trafalgarco.com.co	3203553324	esmeralda.malagon@bold.co	2QNFHSUAJ8	EXECUTIVE	SMB	ACTIVE	SMB Sales Executive	SMB	Maira Bautista Peraza	alejandra.bautista@bold.co	LEADER	SMB	ACTIVE	SMB Team Lead	SMB	Alvaro Guerrero Fabra	andres.guerrero@bold.co	MANAGER	SMB	ACTIVE	Sales Manager SMB	SMB	HUBUSABOG	alejandra.pajaro@bold.co	MANAGER	Hubs Sales Manager	ACTIVE	511800632.0000	Mayor a 40M	16	2033d11865fbd2252916bede3c368524, 2e3480b599b10a67e1a4f508b9fc02ea, 3ee11f41ba150345e97a4fb65f58663c, 3f3d10f6f92e29b05b500f1f6c60ad44, 5a7829fb5df2fd213faf8bab64b62c2b, 6e51c5d749d01d23ae987cd4cc96e879, 74911a5e5bdcae30fb3cc252f768b4aa, 793813e04e7f6d33f9f20d37f320df09, 84087cd7e2a74ca0cab904352277a6d0, 9ac1a275fc48a5e823c8dcac87a31005, acc4017e936c941c74a3a1f0e2e9bca8, dc2097f5da1927e2e14445cff883e5e7, e24a2921437b55348064eff827d42a81, ecbf847144415cb4c71f4da3d4c600af, eda15464fcf5c45dc6cd737bdb8dbb72, fa3aa23cb69695f79ad4606bd5378f04	N86	BINDED	2026-02-06 14:39:28.643000	2026-08-26 18:43:04.936000	true	true	true	true	["PAYMENTS","DEPOSIT_ACCOUNT"]	SMB		ENABLED	APPROVED	2026-01-26 13:27:59.351	2026-01-26 14:06:30.481000	2026-01-28 11:56:40.539956	2026-01-29 11:06:40.143126	2026-01-29 16:23:32.853884	2026-08-26 21:11:12.520229	2026-02-12 19:01:24.149117	2026-01-29 10:03:43.742175	2026-01-29 16:29:51.831257	2026-01-28 11:56:40.539956	2026-01-30 18:12:24.178000	71125136.0000	358055722.0000	450311189.0000	413367068.0000	493601740.0000	511800632.0000	141	764	747	761	867	884	5491700.0000	0.0000	65633436.0000	358055722.0000	4.0342	6.1958	0.6132	2026-01-01	2026-06-01	6	CUMPLE_6_MESES_TRANSACCIONALIDAD	71125136.00	391716122.00	734074814.00	798485859.00	4232637569.00	2237235638.00	61651386.0000	227697755.0000	330529789.0000	JERARQUIA_ORIGEN_CRM_RESUELTA	HUB_RESUELTO	2026-01-26 14:07:26.431	2026-08-27 05:33:17.120000	2026-08-27 06:03:46.913000	2026-08-27 05:53:52.363000	2026-07-24 19:05:27.756	2026-08-28 06:37:39.445 UTC
7	PA1LA4GGYD	SDQDF8BYT2	FRIOCARNES FRIGOECOL	LEGAL_PERSON	NIT	830501536	POKLLWLA6V	WON		SMB			PAYMENT_LINK	PAYMENT_LINK		SPIDER	2026-01-06 19:23:35.198	2026-01-09 15:21:02.738	2026-01-09 15:21:02.738	2026-01-09 00:00:00.000	T6ZD9I7Y48	rose.ranauro@bold.co	EXECUTIVE	SMB	ACTIVE	SMB Sales Executive	Luis Alvarez Morales	NZGGG3QQGN	luis.morales@bold.co	LEADER	SMB	ACTIVE	SMB Team Lead	LR78SVJ61Y	hector.causil@bold.co	MANAGER	SMB	ACTIVE	Sales Manager SMB	2026-08-27 19:19:37.930	RESPONSABLE_ORIGEN_RESUELTO	FOOD_AND_DRINK			ATLANTICO		gerencia.frigoecol@gmail.com	3017171104																											1442692601.0000	Mayor a 40M	26	08f24b0c9ca55017ea3928068fb0b4c6, 0a36df8ca702926dc9f85c6c38eea5b0, 0f4ce6356aa246a1add817afd5450d7b, 1bc7c6d0574f5566d5a863d10326e534, 1d1fc09faf542ae1abba296232d4d6f4, 1f16b76892d3e6da7239357e5c76a328, 2b856fdf57605e4c947828771c083089, 2bd343e536603645a4aaaa4ebe9950df, 40e38a45e3256f80980c9b5375e42a7a, 49de847b60063310fee86f8dbb4e0041, 620f3a64f22cdada12af43e7e535d5d3, 65cad3f0beb5ef8c0bc6d26c009641b8, 7653f5e20c1232254b23a44e77db1a66, 875bff92d17000f863575918ea2ec866, 8be496d75cec2840011947b5e1af975c, 9d546f4133c0118ec2ba4143440ad108, a9a8142d5374bda8c303ed2913400cf4, bcd0328ab47b5b1727dddb7c5d8f8cc6, cb67e0409a3192f9cf8141718944b734, cedd776898a6b716a9b5f345abf85fe8, d03c06158313d866cc5c5c993e76f09d, d3a966661979dba5f38c2c359377911d, d82ee029c6cec7c34f6b3d7f0d9aa859, dbd5f09dfa091bb43d6a66ea303bbe06, de94e714bcf7972a3e45bde82fad33d2, e61f8237f3582d896fe57bce9880aae3	D20	BINDED	2026-06-19 08:21:41.731000	2026-08-26 19:05:12.612219	true	true	false	true	["DEPOSIT_ACCOUNT","PAYMENTS"]	INBOUND		ENABLED	APPROVED	2026-01-09 12:54:34.225	2026-01-09 15:16:46.884000	2026-01-09 15:43:02.122364	2026-01-15 14:04:51.183583	2026-01-15 17:40:28.920743	2026-08-26 19:05:12.612219		2026-01-09 15:43:02.122364	2026-01-09 15:59:33.280927	2026-01-15 17:40:28.920743	2026-01-09 16:07:02.616000	703104715.0000	1366836174.0000	1442692601.0000	1353578497.0000	1398974734.0000	1344455440.0000	3305	6110	6732	6641	7289	7076	383643075.0000	741671120.0000	319461640.0000	625165054.0000	0.9440	0.9122	0.1664	2026-01-01	2026-06-01	6	CUMPLE_6_MESES_TRANSACCIONALIDAD	703104715.00	1366836174.00	1442692601.00	1439318117.00	9048960278.00	4097008671.00	559407040.0000	914867686.0000	927501786.0000	JERARQUIA_ORIGEN_CRM_RESUELTA	SIN_HUB_CUSTOM_ID	2026-01-09 15:17:26.711	2026-08-27 05:33:17.120000	2026-08-27 06:03:46.913000	2026-08-27 05:53:52.363000		2026-08-28 06:37:39.445 UTC
8	RMCVFJO3D8	OE6AG43RR5	Negocio de Gustavo Alfonso	NATURAL_PERSON	CEDULA	1018408383	S4BPY8UDIW	WON		SMB			PAYMENT_LINK	PAYMENT_LINK		LQT_MARKETING	2026-01-16 13:41:03.965	2026-01-16 13:43:50.878	2026-01-16 13:43:50.878	2026-01-16 00:00:00.000	DL8IJ8O2UO	raul.castillo@bold.co	EXECUTIVE	SMB	ACTIVE	SMB Sales Executive	Maira Bautista Peraza	JB3J5VB1YZ	carolina.santos@bold.co	LEADER	SMB	ACTIVE	SMB Team Lead	D3TSS47WXG	andres.guerrero@bold.co	MANAGER	SMB	ACTIVE	Sales Manager SMB	2026-08-27 19:19:37.930	RESPONSABLE_ORIGEN_RESUELTO	RETAIL_TRADE			CUNDINAMARCA		gustav.bonilla@gmail.com	3045302294																						HUBTEQBOG	jose.rodriguez@bold.co	HUB_LEADER	Hubs Team Lead	ACTIVE	21418150.0000	Entre 20M y 40M	1	f3e1a71a246e36e9d2fab0a3a4eae9b1	QPOS_PLUS	BINDED	2026-01-16 13:56:32.312000	2026-01-16 14:02:20.700493	false	false	false	false	["PAYMENTS"]	INBOUND		ENABLED	APPROVED	2026-01-16 13:31:15.062											21418150.0000	0.0000	0.0000	0.0000	0.0000	0.0000	8	0	0	0	0	0	0.0000	0.0000	21418150.0000	0.0000	-1.0000	-1.0000	-1.0000	2026-01-01	2026-01-01	1	NO_CUMPLE_6_MESES_TRANSACCIONALIDAD	0.00	0.00	0.00	0.00	0.00	0.00	10000.0000	0.0000	0.0000	JERARQUIA_ORIGEN_CRM_RESUELTA	HUB_RESUELTO	2026-01-19 12:38:29.842		2026-08-27 06:03:46.913000	2026-08-27 05:53:52.363000	2026-08-05 13:06:10.330	2026-08-28 06:37:39.445 UTC
9	VMKYJPDVD1	VN7KEXXC8W	REVIEW 	LEGAL_PERSON	NIT	900315753	5HRFEZ1ZAP	WON		SMB			PAYMENT_LINK	PAYMENT_LINK	REVIEW MODA	COLD_VISIT	2025-09-08 09:48:19.017	2026-02-03 16:19:27.838	2026-02-03 16:19:27.838	2026-02-03 00:00:00.000	OJJTOP28JC	diana.colina@bold.co	EXECUTIVE	SMB	INACTIVE			NZGGG3QQGN	luis.morales@bold.co	LEADER	SMB	ACTIVE	SMB Team Lead	LR78SVJ61Y	hector.causil@bold.co	MANAGER	SMB	ACTIVE	Sales Manager SMB	2026-08-27 19:19:37.930	RESPONSABLE_ORIGEN_RESUELTO	RETAIL_TRADE			ATLANTICO		tesoreria@reviewmoda.com	3222792945																						HUBPALLBQ	luis.castellar@bold.co	HUB_LEADER	Hubs Team Lead	ACTIVE	335984908.0000	Mayor a 40M	0						false	false	true	false	["PAYMENTS"]	INBOUND		ENABLED	APPROVED	2026-01-29 17:45:54.984	2026-01-29 17:57:29.943000	2026-01-30 19:45:33.565122	2026-02-02 17:42:38.736669	2026-02-07 12:14:11.609097	2026-08-26 22:54:23.879166	2026-01-30 19:45:33.565122			2026-02-06 10:38:45.200314		49990.0000	28365980.0000	168276251.0000	153759526.0000	335984908.0000	173279015.0000	1	142	789	729	1143	714	0.0000	0.0000	49990.0000	28365980.0000	566.4331	3465.2736	2.3709	2026-01-01	2026-06-01	6	CUMPLE_6_MESES_TRANSACCIONALIDAD	49990.00	28365980.00	168276251.00	155126577.00	1014842247.00	663023449.00	0.0000	0.0000	0.0000	JERARQUIA_ORIGEN_CRM_RESUELTA	HUB_RESUELTO	2026-01-29 17:57:19.339	2026-08-27 05:33:17.120000	2026-08-27 06:03:46.913000		2025-11-26 17:40:29.758	2026-08-28 06:37:39.445 UTC
10	WFK9N0809K	6R4NSTOTKQ	HABITAT ADULTO MAYOR SAS	LEGAL_PERSON	NIT	900165652	3JM0RUET3E	WON		SMB			PAYMENT_LINK	PAYMENT_LINK		LQT_MARKETING	2026-01-26 09:05:24.927	2026-01-27 11:39:46.583	2026-01-27 11:39:46.583	2026-01-27 00:00:00.000	0FQKE3GUVK	indira.montes@bold.co	EXECUTIVE	SMB	ACTIVE	SMB Sales Executive	Wilmar Vanegas Gonzalez	FGYHUQ3E9I	wilmar.vanegas@bold.co	LEADER	SMB	INACTIVE		3UQQ20EJ2M	david.acosta@bold.co	LEADER	SMB	ACTIVE	Sales Manager SMB	2026-08-27 19:19:37.930	RESPONSABLE_ORIGEN_RESUELTO	SERVICES			ANTIOQUIA		reportedepagos@tuhabitat.co	3206872022																											805103696.0000	Mayor a 40M	5	07542fc49d88a696c17d748a0b8cd0cd, 441d89912b567cde83801270241ddec6, 54ebd6e5c7758cc0ee234a1619f1b360, 64b5730e568672d26c220472896384c2, 9a02a573fbe5451bfe4483f01ea06b9c	N86	BINDED, UNBINDED	2026-01-27 11:29:51.710000	2026-08-26 12:42:27.342799	true	true	false	false	["DEPOSIT_ACCOUNT","PAYMENTS"]	INBOUND		ENABLED	APPROVED	2026-01-21 16:11:10.277	2026-01-21 16:22:21.838000	2026-01-23 16:49:46.290499	2026-01-26 12:52:25.502846	2026-01-27 11:41:19.496179	2026-08-26 12:42:27.342799		2026-01-23 16:49:46.290499	2026-01-26 18:37:01.616853	2026-01-26 12:52:25.502846		98486640.0000	485489296.0000	805103696.0000	526074527.0000	573177421.0000	576000419.0000	29	85	95	74	93	86	34688322.0000	0.0000	63798318.0000	485489296.0000	3.9295	4.8485	0.2060	2026-01-01	2026-06-01	6	CUMPLE_6_MESES_TRANSACCIONALIDAD	98486640.00	485489296.00	805103696.00	583810701.00	3648142700.00	1675252367.00	84867133.0000	431030246.0000	742133122.0000	JERARQUIA_ORIGEN_CRM_RESUELTA	SIN_HUB_CUSTOM_ID	2026-01-21 16:23:26.716	2026-08-27 05:33:17.120000	2026-08-27 06:03:46.913000	2026-08-27 05:53:52.363000		2026-08-28 06:37:39.445 UTC

