
WITH
validation_merchants (merchant_id) AS (
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
    INNER JOIN validation_merchants vm
        ON cast(c.merchant_id AS varchar) = vm.merchant_id
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
    INNER JOIN validation_merchants vm
        ON cast(o.merchant_id AS varchar) = vm.merchant_id
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
    INNER JOIN validation_merchants vm
        ON cast(g.merchant_id AS varchar) = vm.merchant_id
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
    INNER JOIN validation_merchants vm
        ON cast(m.master_merchant_id AS varchar) = vm.merchant_id
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
    INNER JOIN validation_merchants vm
        ON cast(tpvd.merchant_id AS varchar) = vm.merchant_id
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
    INNER JOIN validation_merchants vm
        ON cast(t.last_terminal_match_merchant_id AS varchar) = vm.merchant_id
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

service_ranked AS (
    SELECT
        cast(s.service_detail_client_id AS varchar) AS client_id,
        s.service_detail_client_kam_email AS kam_email,
        s.status AS service_status,
        s.load_datetime,
        row_number() OVER (
            PARTITION BY s.service_detail_client_id
            ORDER BY s.load_datetime DESC, s.event_datetime DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_sales.dim_crm_services s
    WHERE s.service_detail_client_id IS NOT NULL
),
service_current AS (
    SELECT client_id, kam_email, service_status, load_datetime
    FROM service_ranked
    WHERE rn = 1
),

base_integrada AS (
    SELECT
        vm.merchant_id,
        c.client_id,
        c.merchant_name,
        c.merchant_person_type,
        c.document_type,
        c.document_number,
        coalesce(c.economic_activity_category_id, o.economic_activity_category_id) AS category_id,
        cast(NULL AS varchar) AS subcategory_id,
        coalesce(g.dane_code, g.municipality) AS city_code,
        coalesce(c.location_address_department_code, o.address_department_code, g.department) AS department_code,
        g.standardized_address AS address,
        o.contact_info_email AS email,
        o.contact_info_phone_number AS cellphone_number,
        coalesce(c.sales_agent_email, o.acquisition_channel_sales_agent_email) AS sales_agent_email,
        g.hub_custom_id,
        sc.kam_email AS kam_email_crm,
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
        sc.load_datetime AS kam_service_loaded_at,
        lc.load_datetime AS hub_location_loaded_at
    FROM validation_merchants vm
    LEFT JOIN client_current c ON vm.merchant_id = c.merchant_id
    LEFT JOIN onboarding_current o ON vm.merchant_id = o.merchant_id
    LEFT JOIN geo_current g ON vm.merchant_id = g.merchant_id
    LEFT JOIN merchant_enrich_current e ON vm.merchant_id = e.merchant_id
    LEFT JOIN tpv_m0_m5_finance tf ON vm.merchant_id = tf.merchant_id
    LEFT JOIN terminals_by_merchant te ON vm.merchant_id = te.merchant_id
    LEFT JOIN service_current sc ON c.client_id = sc.client_id
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

base_smb AS (
    SELECT
        *,
        CASE
            WHEN upper(coalesce(sales_agent_sales_channel, sales_agent_bamboo_channel)) = 'SMB'
                THEN 'SMB'
            WHEN upper(coalesce(team_lead_sales_channel, team_lead_bamboo_channel)) = 'SMB'
                THEN 'SMB'
            WHEN upper(coalesce(manager_sales_channel, manager_bamboo_channel)) = 'SMB'
                THEN 'SMB'
            ELSE coalesce(
                sales_agent_sales_channel,
                sales_agent_bamboo_channel,
                team_lead_sales_channel,
                team_lead_bamboo_channel,
                manager_sales_channel,
                manager_bamboo_channel,
                'NO_CONFIRMADO'
            )
        END AS canal_aplicacion_handoff
    FROM base_integrada
)

SELECT
    merchant_id,
    client_id,
    merchant_name,
    merchant_person_type,
    document_type,
    document_number,
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
    canal_aplicacion_handoff,
    hub_custom_id,
    hub_manager_email,
    hub_manager_role,
    hub_manager_job_title,
    hub_location_status,
    kam_email_crm,
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
    kam_service_loaded_at,
    hub_location_loaded_at,
    current_timestamp AS record_updated_at
FROM base_smb
WHERE canal_aplicacion_handoff = 'SMB'
ORDER BY merchant_id
