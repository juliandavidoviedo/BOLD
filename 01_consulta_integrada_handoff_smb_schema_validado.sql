-- Consulta integrada Handoff Comercial SMB -> CS/KAM
-- Version: 1.0 - basada en esquema confirmado por discovery
-- Motor esperado: Athena / Trino desde Metabase
-- Fecha: 2026-08-27
--
-- Uso:
-- 1. Ejecutar primero esta version con los 10 merchants de validacion.
-- 2. Confirmar que devuelve una fila por merchant_id.
-- 3. Confirmar con negocio la definicion de tpv_max y clasificacion.
-- 4. Cuando se valide, reemplazar validation_merchants por la tabla/lista mensual.
--
-- Fuentes confirmadas en bold_gold_growth:
-- - dim_client
-- - mart_master_merchant_enrich
--
-- Fuentes NO confirmadas aun en bold_gold_growth:
-- - mart_tpv_daily_by_merchant
-- - mart_tpv_daily_by_transaction
-- - dim_terminal
-- - fact_terminal_history
-- - mart_terminal_enrich
--
-- Por eso esta version trae:
-- - datos base disponibles del comercio;
-- - categoria economica disponible;
-- - sales_agent_email;
-- - TPV m0, m1, m2, last_month, historic y last_quarter;
-- - fechas de primera transaccion por producto;
-- - clasificacion calculada.
--
-- Esta version NO trae aun:
-- - terminales asociadas;
-- - numero de terminales;
-- - team_lead;
-- - manager;
-- - ciudad exacta/direccion, si no estan en estas fuentes.

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
    SELECT
        merchant_id,
        merchant_name,
        merchant_person_type,
        document_type,
        document_number,
        economic_activity_id,
        economic_activity_name,
        economic_activity_ciiu,
        economic_activity_mcc,
        economic_activity_category_id,
        economic_activity_description,
        location_address_department_code,
        sales_agent_email,
        sales_source,
        marketing_source,
        selected_products,
        client_status,
        onboarding_status,
        onboarding_completion_date,
        creation_date,
        last_update_event_date
    FROM client_ranked
    WHERE rn = 1
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
    SELECT
        merchant_id,
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
        tpv_total_m0,
        tpv_total_m1,
        tpv_total_m2,
        tpv_total_last_month,
        tpv_historic,
        tpv_last_quarter,
        load_datetime
    FROM merchant_enrich_ranked
    WHERE rn = 1
),

base_integrada AS (
    SELECT
        vm.merchant_id,
        c.merchant_name,
        c.merchant_person_type,
        c.document_type,
        c.document_number,
        c.economic_activity_id,
        c.economic_activity_name,
        c.economic_activity_ciiu,
        c.economic_activity_mcc,
        c.economic_activity_category_id AS category_id,
        cast(NULL AS varchar) AS subcategory_id,
        c.economic_activity_description,
        c.location_address_department_code,
        cast(NULL AS varchar) AS city_code,
        cast(NULL AS varchar) AS address,
        cast(NULL AS varchar) AS email,
        cast(NULL AS varchar) AS cellphone_number,
        c.sales_agent_email,
        cast(NULL AS varchar) AS team_lead,
        cast(NULL AS varchar) AS manager,
        c.sales_source,
        c.marketing_source,
        c.selected_products,
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
        coalesce(e.tpv_total_m0, 0) AS tpv_total_m0,
        coalesce(e.tpv_total_m1, 0) AS tpv_total_m1,
        coalesce(e.tpv_total_m2, 0) AS tpv_total_m2,
        coalesce(e.tpv_total_last_month, 0) AS tpv_total_last_month,
        coalesce(e.tpv_historic, 0) AS tpv_historic,
        coalesce(e.tpv_last_quarter, 0) AS tpv_last_quarter,
        greatest(
            coalesce(e.tpv_total_m0, 0),
            coalesce(e.tpv_total_m1, 0),
            coalesce(e.tpv_total_m2, 0),
            coalesce(e.tpv_total_last_month, 0)
        ) AS tpv_max_ventana_mensual,
        cast(NULL AS integer) AS numero_terminales,
        cast(NULL AS varchar) AS terminales_asociadas,
        CASE WHEN e.first_mpos_transaction_approved_date IS NOT NULL THEN true ELSE false END AS tiene_pos,
        CASE WHEN e.first_link_transaction_approved_date IS NOT NULL THEN true ELSE false END AS tiene_link_pago,
        CASE WHEN e.first_btn_transaction_approved_date IS NOT NULL THEN true ELSE false END AS tiene_boton_pago,
        CASE WHEN e.first_qr_transaction_approved_date IS NOT NULL THEN true ELSE false END AS tiene_qr,
        c.last_update_event_date AS dim_client_updated_at,
        e.load_datetime AS merchant_enrich_loaded_at
    FROM validation_merchants vm
    LEFT JOIN client_current c
        ON vm.merchant_id = c.merchant_id
    LEFT JOIN merchant_enrich_current e
        ON vm.merchant_id = e.merchant_id
)

SELECT
    merchant_id,
    merchant_name,
    document_type,
    document_number,
    category_id,
    subcategory_id,
    city_code,
    location_address_department_code,
    address,
    email,
    cellphone_number,
    sales_agent_email,
    team_lead,
    manager,
    tpv_max_ventana_mensual AS tpv_max,
    CASE
        WHEN tpv_max_ventana_mensual >= 40000000 THEN 'Mayor a 40M'
        WHEN tpv_max_ventana_mensual >= 20000000 THEN 'Entre 20M y 40M'
        ELSE 'Menor a 20M'
    END AS clasificacion_calculada,
    numero_terminales,
    terminales_asociadas,
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
    tpv_total_m0,
    tpv_total_m1,
    tpv_total_m2,
    tpv_total_last_month,
    tpv_historic,
    tpv_last_quarter,
    economic_activity_id,
    economic_activity_name,
    economic_activity_ciiu,
    economic_activity_mcc,
    economic_activity_description,
    dim_client_updated_at,
    merchant_enrich_loaded_at,
    current_timestamp AS record_updated_at
FROM base_integrada
ORDER BY merchant_id;
