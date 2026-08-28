-- Athena / Trino SQL
-- Objetivo: trazabilidad serial -> terminal -> merchant -> comercio -> actividad -> ejecutivo/canal.
-- Universo: 305 seriales únicos del archivo "Seriales enviados Jeyson - Coopicredito.xlsx - Detalle.csv".
--
-- Definición de categoría/subcategoría:
--   categoria_id     = economic_activity_category_id
--   categoria        = economic_activity_name
--   subcategoria     = economic_activity_description (proxy; no existe un subcategory_id
--                      canónico confirmado en el modelo revisado)

WITH
seriales_fuente AS (
    SELECT
        source_row,
        upper(trim(serial)) AS serial
    FROM UNNEST(split('N860WN24408|N860WN29641|N860WN29646|N860WN29640|N860WN29649|N860WN29644|N860WN29656|N860WN29658|N860WN29647|N860WN29651|N860WN27185|N860WN27195|N860WN24415|N860WN24406|N860WN25412|N860WN34719|N860WN32831|N860WN34725|N860WN32836|N860WN32830|N860WN34733|N860WN34727|N860WN34734|N860WN34721|N860WN32822|N860WN32820|N860WN32829|N860WN34737|N860WN34732|N860WN32819|N860WN34722|N860WN34738|N860WN34735|N860WN34723|N860WN34731|N860WN34724|N860WN34728|N860WN34730|N860WN32825|N860WN34729|N860WN32832|N860WN34736|N860WN34720|N860WN34726|N860WN32828|N860WN34849|N860WN34854|N860WN34852|N860WN34848|N860WN34857|N860WN34843|N860WN34839|N860WN34844|N860WN34853|N860WN34850|N860WN34856|N860WN34858|N860WN34847|N860WN34851|N860WN34855|N860WN29827|N860WN29829|N860WN29825|N860WN29820|N860WN29838|N860WN29819|N860WN29823|N860WN29824|N860WN29832|N860WN29828|N860WN29834|N860WN29826|N860WN29833|N860WN29836|N860WN29822|N860WN34653|N860WN34654|N860WN34642|N860WN34641|N860WN34639|N860WN34652|N860WN34651|N860WN34655|N860WN34643|N860WN34658|N860WN34648|N860WN34644|N860WN34649|N860WN34646|N860WN34657|N860WN32087|N860WN32098|N860WN32096|N860WN32089|N860WN32079|N860WN32081|N860WN32093|N860WN32088|N860WN32080|N860WN32086|N860WN32082|N860WN32084|N860WN32085|N860WN32094|N860WN32091|N860WN35416|N860WN35399|N860WN32588|N860WN32596|N860WN32587|N860WN32586|N860WN32593|N860WN35409|N860WN32583|N860WN32579|N860WN32590|N860WN35412|N860WN35411|N860WN35408|N860WN35415|N860WN32597|N860WN32591|N860WN32598|N860WN32589|N860WN32592|N860WN32581|N860WN32585|N860WN35418|N860WN32595|N860WN35405|N860WN32584|N860WN32582|N860WN35407|N860WN32594|N860WN32580|N860WN30977|N860WN30965|N860WN30973|N860WN30959|N860WN30971|N860WN30963|38260625004132|38260625004133|N860WN30978|38260625004137|N860WN30972|N860WN30960|38260625004140|N860WN30961|N860WN30962|N860WN30976|N860WN30974|38260625004136|N860WN30968|38260625004124|N860WN30970|N860WN30967|N860WN30969|38260625004134|N860WN30964|38260625004139|38260625004123|N860WN30975|N860WN30966|38260625004131|N860WN34645|N860WN29830|N860WN34650|N860WN29837|N860WN29811|N860WN29831|N860WN35199|N860WN29835|N860WN29814|N860WN29821|N860WN34640|N860WN34647|N860WN29817|N860WN29808|N860WN34656|N860WN35452|N860WN35457|N860WN35439|N860WN35444|N860WN35443|N860WN35455|N860WN35441|N860WN35442|N860WN35458|N860WN35450|N860WN35451|N860WN35454|N860WN35453|N860WN35447|N860WN35440|N860WN35446|N860WN35449|N860WN35448|N860WN35456|N860WN35445|N860WN32810|N860WN32814|N860WN32800|N860WN32808|N860WN32799|N860WN32802|N860WN32817|N860WN32807|N860WN32816|N860WN32811|N860WN32813|N860WN32809|N860WN32803|N860WN32806|N860WN32804|N860WN33937|N860WN33938|N860WN33924|N860WN32818|N860WN33935|N860WN33925|N860WN33929|N860WN32812|N860WN33922|N860WN33919|N860WN33931|N860WN33927|N860WN33926|N860WN32815|N860WN33932|N860WN31010|N860WN31005|N860WN31007|N860WN34862|N860WN34869|N860WN34865|N860WN31008|N860WN31017|N860WN31001|N860WN31015|N860WN30999|N860WN31018|N860WN31016|N860WN34876|N860WN31006|N860WN29550|N860WN29553|N860WN29557|N860WN29546|N860WN29542|N860WN29543|N860WN29554|N860WN29545|N860WN29539|N860WN29552|N860WN29549|N860WN29558|N860WN29547|N860WN29556|N860WN29551|N860WN34580|N860WN34586|N860WN34584|N860WN34595|N860WN34593|N860WN34596|N860WN34581|N860WN34589|N860WN34588|N860WN34594|N860WN34590|N860WN34585|N860WN34598|N860WN34582|N860WN34587|N860WN33101|N860WN33114|N860WN33117|N860WN33102|N860WN33113|N860WN33103|N860WN33112|N860WN33099|N860WN33116|N860WN33108|N860WN33109|N860WN33111|N860WN33110|N860WN33106|N860WN33107|N860WN34592|N860WN34841|N860WN34842|N860WN34579|N860WN34591|N860WN34447|N860WN34846|N860WN34583|N860WN33104|N860WN34597|N860WN34452|N860WN34442|N860WN34845|N860WN34451|N860WN34840', '|'))
        WITH ORDINALITY AS u(serial, source_row)
),

terminal_ranked AS (
    SELECT
        sf.source_row,
        sf.serial AS serial_solicitado,
        cast(t.terminal_key AS varchar) AS terminal_key,
        cast(t.terminal_serial AS varchar) AS terminal_serial,
        t.terminal_model,
        t.model_name_category,
        t.current_terminal_status,
        cast(t.last_terminal_match_merchant_id AS varchar) AS merchant_id,
        t.last_terminal_match_date,
        t.last_merchant_match_status,
        t.last_transaction_approved_date AS terminal_last_transaction_date,
        t.terminal_sales_source,
        t.terminal_sales_executive,
        t.load_datetime AS terminal_loaded_at,
        row_number() OVER (
            PARTITION BY sf.serial
            ORDER BY
                CASE WHEN upper(trim(cast(t.terminal_serial AS varchar))) = sf.serial THEN 1 ELSE 0 END DESC,
                CASE WHEN t.last_terminal_match_merchant_id IS NOT NULL THEN 1 ELSE 0 END DESC,
                t.last_terminal_match_date DESC,
                t.load_datetime DESC
        ) AS rn
    FROM seriales_fuente sf
    LEFT JOIN awsdatacatalog.bold_gold_terminals.mart_terminal_enrich t
        ON sf.serial = upper(trim(cast(t.terminal_serial AS varchar)))
        OR sf.serial = upper(trim(cast(t.terminal_key AS varchar)))
),
terminal_actual AS (
    SELECT * FROM terminal_ranked WHERE rn = 1
),

client_ranked AS (
    SELECT
        cast(c.merchant_id AS varchar) AS merchant_id,
        cast(c.client_id AS varchar) AS client_id,
        c.merchant_name,
        c.merchant_person_type,
        cast(c.merchant_identification_document_number AS varchar) AS document_number,
        cast(c.economic_activity_category_id AS varchar) AS categoria_id,
        c.economic_activity_name AS categoria,
        c.economic_activity_description AS subcategoria,
        c.economic_activity_ciiu AS ciiu,
        c.economic_activity_mcc AS mcc,
        c.merchant_acquisition_channel_source AS acquisition_channel_source,
        c.merchant_acquisition_channel_value AS acquisition_channel_value,
        c.merchant_acquisition_channel_sales_agent_email AS sales_agent_email,
        c.sales_source,
        c.marketing_source,
        c.status AS merchant_status,
        c.onboarding_status,
        c.creation_date AS merchant_created_at,
        c.last_update_event_date AS merchant_updated_at,
        row_number() OVER (
            PARTITION BY c.merchant_id
            ORDER BY c.last_update_event_date DESC, c.creation_date DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_growth.dim_client c
    INNER JOIN (
        SELECT DISTINCT merchant_id
        FROM terminal_actual
        WHERE merchant_id IS NOT NULL
    ) m ON cast(c.merchant_id AS varchar) = m.merchant_id
),
client_actual AS (
    SELECT * FROM client_ranked WHERE rn = 1
),

onboarding_ranked AS (
    SELECT
        cast(o.merchant_id AS varchar) AS merchant_id,
        cast(o.economic_activity_category_id AS varchar) AS categoria_id,
        o.economic_activity_name AS categoria,
        o.economic_activity_description AS subcategoria,
        o.economic_activity_ciiu AS ciiu,
        o.economic_activity_mcc AS mcc,
        o.acquisition_channel_sales_agent_email AS sales_agent_email,
        o.status AS onboarding_source_status,
        o.onboarding_completion_date,
        o.onboarding_completed_date,
        row_number() OVER (
            PARTITION BY o.merchant_id
            ORDER BY o.onboarding_completed_date DESC, o.onboarding_completion_date DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_growth.dim_merchant_onboarding o
    INNER JOIN (
        SELECT DISTINCT merchant_id
        FROM terminal_actual
        WHERE merchant_id IS NOT NULL
    ) m ON cast(o.merchant_id AS varchar) = m.merchant_id
),
onboarding_actual AS (
    SELECT * FROM onboarding_ranked WHERE rn = 1
),

opportunity_ranked AS (
    SELECT
        cast(coalesce(o.product_merchant_id, o.metadata_merchant_id) AS varchar) AS merchant_id,
        cast(o.opportunity_id AS varchar) AS opportunity_id,
        cast(o.user_id AS varchar) AS opportunity_user_id,
        o.sales_channel AS opportunity_sales_channel,
        o.origin_name AS opportunity_origin,
        o.status AS opportunity_status,
        o.won_date,
        o.activation_date,
        o.last_update_date,
        o.load_datetime,
        row_number() OVER (
            PARTITION BY coalesce(o.product_merchant_id, o.metadata_merchant_id)
            ORDER BY
                CASE WHEN o.won_date IS NOT NULL THEN 1 ELSE 0 END DESC,
                o.won_date DESC,
                o.activation_date DESC,
                o.last_update_date DESC,
                o.load_datetime DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_sales.dim_crm_opportunities o
    INNER JOIN (
        SELECT DISTINCT merchant_id
        FROM terminal_actual
        WHERE merchant_id IS NOT NULL
    ) m ON cast(coalesce(o.product_merchant_id, o.metadata_merchant_id) AS varchar) = m.merchant_id
),
opportunity_actual AS (
    SELECT * FROM opportunity_ranked WHERE rn = 1
),

crm_users_ranked AS (
    SELECT
        cast(u.user_id AS varchar) AS user_id,
        lower(trim(u.email)) AS email_key,
        u.email,
        u.role,
        u.sales_channel,
        u.status,
        cast(u.parent_id AS varchar) AS parent_id,
        u.load_datetime,
        row_number() OVER (
            PARTITION BY u.user_id
            ORDER BY CASE WHEN upper(u.status) = 'ACTIVE' THEN 1 ELSE 0 END DESC,
                     u.load_datetime DESC
        ) AS rn_id,
        row_number() OVER (
            PARTITION BY lower(trim(u.email))
            ORDER BY CASE WHEN upper(u.status) = 'ACTIVE' THEN 1 ELSE 0 END DESC,
                     u.load_datetime DESC
        ) AS rn_email
    FROM awsdatacatalog.bold_gold_sales.dim_crm_users u
    WHERE u.user_id IS NOT NULL
),
crm_user_by_id AS (
    SELECT * FROM crm_users_ranked WHERE rn_id = 1
),
crm_user_by_email AS (
    SELECT * FROM crm_users_ranked WHERE rn_email = 1
),

bamboo_ranked AS (
    SELECT
        cast(b.user_id AS varchar) AS user_id,
        b.job_title,
        b.channel,
        b.reports_to,
        b.status,
        b.load_datetime,
        row_number() OVER (
            PARTITION BY b.user_id
            ORDER BY b.load_datetime DESC, b.event_datetime DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_sales.dim_user_bamboo_information b
    WHERE b.user_id IS NOT NULL
),
bamboo_actual AS (
    SELECT * FROM bamboo_ranked WHERE rn = 1
)

SELECT
    t.source_row,
    t.serial_solicitado,
    t.terminal_key,
    t.terminal_serial,
    t.terminal_model,
    t.model_name_category AS terminal_categoria_modelo,
    t.current_terminal_status AS terminal_estado,
    t.last_merchant_match_status AS terminal_match_estado,
    t.merchant_id,
    c.client_id,
    c.merchant_name AS nombre_comercio,
    c.merchant_person_type AS tipo_persona,
    c.document_number AS documento_comercio,
    coalesce(c.categoria_id, o.categoria_id) AS categoria_id,
    coalesce(c.categoria, o.categoria) AS categoria,
    coalesce(c.subcategoria, o.subcategoria) AS subcategoria,
    coalesce(c.ciiu, o.ciiu) AS ciiu,
    coalesce(c.mcc, o.mcc) AS mcc,
    coalesce(c.sales_agent_email, o.sales_agent_email) AS ejecutivo_adquisicion_email,
    acquisition_user.role AS ejecutivo_adquisicion_rol,
    acquisition_bamboo.job_title AS ejecutivo_adquisicion_cargo,
    opportunity_user.email AS ejecutivo_oportunidad_email,
    opportunity_user.role AS ejecutivo_oportunidad_rol,
    opportunity_bamboo.job_title AS ejecutivo_oportunidad_cargo,
    t.terminal_sales_executive AS ejecutivo_venta_terminal,
    coalesce(
        nullif(t.terminal_sales_source, ''),
        nullif(c.acquisition_channel_source, ''),
        nullif(c.acquisition_channel_value, ''),
        nullif(opp.opportunity_sales_channel, ''),
        nullif(acquisition_user.sales_channel, ''),
        nullif(acquisition_bamboo.channel, ''),
        nullif(opportunity_user.sales_channel, ''),
        nullif(opportunity_bamboo.channel, '')
    ) AS canal_consolidado,
    t.terminal_sales_source,
    c.acquisition_channel_source,
    c.acquisition_channel_value,
    c.sales_source,
    c.marketing_source,
    opp.opportunity_id,
    opp.opportunity_status,
    opp.opportunity_sales_channel,
    opp.opportunity_origin,
    c.merchant_status,
    c.onboarding_status,
    o.onboarding_source_status,
    t.last_terminal_match_date,
    t.terminal_last_transaction_date,
    c.merchant_created_at,
    c.merchant_updated_at,
    t.terminal_loaded_at,
    CASE
        WHEN t.terminal_key IS NULL AND t.terminal_serial IS NULL THEN 'SERIAL_NO_ENCONTRADO'
        WHEN t.merchant_id IS NULL THEN 'TERMINAL_SIN_MERCHANT'
        WHEN c.merchant_id IS NULL AND o.merchant_id IS NULL THEN 'MERCHANT_SIN_DIMENSION_COMERCIAL'
        WHEN coalesce(c.sales_agent_email, o.sales_agent_email, opportunity_user.email, t.terminal_sales_executive) IS NULL
            THEN 'SIN_EJECUTIVO'
        WHEN coalesce(
            nullif(t.terminal_sales_source, ''),
            nullif(c.acquisition_channel_source, ''),
            nullif(c.acquisition_channel_value, ''),
            nullif(opp.opportunity_sales_channel, ''),
            nullif(acquisition_user.sales_channel, ''),
            nullif(acquisition_bamboo.channel, ''),
            nullif(opportunity_user.sales_channel, ''),
            nullif(opportunity_bamboo.channel, '')
        ) IS NULL THEN 'SIN_CANAL'
        ELSE 'TRAZABILIDAD_COMPLETA'
    END AS estado_trazabilidad
FROM terminal_actual t
LEFT JOIN client_actual c
    ON t.merchant_id = c.merchant_id
LEFT JOIN onboarding_actual o
    ON t.merchant_id = o.merchant_id
LEFT JOIN opportunity_actual opp
    ON t.merchant_id = opp.merchant_id
LEFT JOIN crm_user_by_email acquisition_user
    ON lower(trim(coalesce(c.sales_agent_email, o.sales_agent_email))) = acquisition_user.email_key
LEFT JOIN bamboo_actual acquisition_bamboo
    ON acquisition_user.user_id = acquisition_bamboo.user_id
LEFT JOIN crm_user_by_id opportunity_user
    ON opp.opportunity_user_id = opportunity_user.user_id
LEFT JOIN bamboo_actual opportunity_bamboo
    ON opportunity_user.user_id = opportunity_bamboo.user_id
ORDER BY t.source_row;
