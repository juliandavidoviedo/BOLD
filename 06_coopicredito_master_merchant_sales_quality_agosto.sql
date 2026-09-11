WITH merchant_scope_raw (
    source_row,
    merchant_id,
    estado_onboarding_archivo,
    clasificacion_tpv_archivo,
    ejecutivo_onboarding_archivo
) AS (
    VALUES
        (426, 'GSYCJJ0ZMX', 'MIGRACION', 'NO NUEVO', 'claudia.romero@bold.co'),
        (427, '0XV9992C0O', 'CREADO', 'NUEVO', 'harold.montenegro@bold.co'),
        (429, 'GHTNMF7727', 'CREADO', 'NUEVO', 'jenny.baron@bold.co'),
        (430, 'TR2KLJUVZ6', 'CREADO', 'NUEVO', 'alex.gil@bold.co'),
        (431, '75H2G3UNCN', 'MIGRACION', 'NO NUEVO', 'claudia.romero@bold.co'),
        (432, 'LZ4FUN0WQD', 'CREADO', 'NUEVO', 'claudia.romero@bold.co'),
        (433, 'VUSTI8DA46', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (434, '54LXJZBNZ9', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (435, 'XOP5AO97MP', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (436, 'BVDN5HUB7R', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (437, '0BE18WOVV2', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (438, 'NIV028B3MZ', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (439, 'J7IML9IM9I', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (440, '3K2UR9MQ3O', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (441, 'VS2MRZDVZL', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (442, '9OYGZJX2JZ', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (443, 'IFZJ8WSLSE', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (444, 'AVGU6FEYZ7', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (445, 'NFBG4DGNTU', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (446, 'NZ911L9FFZ', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (447, 'HW9F3DLU6Y', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (448, 'X12JGJK6HD', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (449, '6T666ZC1PC', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (450, 'ND9E9BVEFH', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (451, 'D3CSCWAZSN', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (452, 'OL7HSSUC3Q', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (453, '3CH8FBJ9AN', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (454, '9O6561CJE9', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (455, 'Z1OH7VNMNP', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (456, 'GH9NAMTKQE', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (457, '8A1O5ELS22', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (458, 'R1MFU4VEUU', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (459, 'LNZJWX2CJM', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (460, 'RINNZMPT6N', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (461, 'JWB364BYJT', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (462, 'U215EU8J7D', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (463, 'J9QFIT63EE', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (464, '91VH6IUNEA', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (465, 'MLMHGPOYCP', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (466, 'AKKHBLNCCA', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (467, 'GHYHY5RPOS', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (468, 'NFUSJ7NQ96', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (469, 'XMABPI8SDB', 'CREADO', 'NUEVO', 'jorge.amaya@bold.co'),
        (470, 'O1ZWI9P1IS', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (471, '1KQZPLFRVW', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (472, 'VXJZXFZCK5', 'CREADO', 'NUEVO', 'jeyson.salazar@bold.co'),
        (475, 'JXLFJ824NO', 'CREADO', 'NUEVO', 'harold.montenegro@bold.co'),
        (476, 'PL0B5ER5G3', 'CREADO', 'NUEVO', 'carolina.reyes@bold.co'),
        (999999, 'FR3AWY0OWD', 'MASTER_REFERENCIA', 'MASTER_REFERENCIA', '')
),
merchant_scope AS (
    SELECT
        source_row,
        trim(cast(merchant_id AS varchar)) AS merchant_id,
        estado_onboarding_archivo,
        clasificacion_tpv_archivo,
        lower(trim(ejecutivo_onboarding_archivo)) AS ejecutivo_onboarding_archivo
    FROM merchant_scope_raw
),
scope_ids AS (
    SELECT merchant_id FROM merchant_scope
    UNION
    SELECT 'FR3AWY0OWD' AS merchant_id
),
master_merchant_lineage AS (
    SELECT
        trim(cast(l.merchant_id AS varchar)) AS merchant_id,
        array_join(array_agg(DISTINCT trim(cast(l.parent_merchant_id AS varchar))), ', ') AS parent_merchant_ids_lineage,
        array_join(
            array_agg(
                DISTINCT concat(
                    trim(cast(l.merchant_id AS varchar)),
                    ' | ',
                    trim(cast(l.parent_merchant_id AS varchar)),
                    '=[',
                    coalesce(cast(l.reason_changed AS varchar), ''),
                    ']'
                )
            ),
            ' -> '
        ) AS reason_changed,
        sum(CASE WHEN l.reason_changed LIKE '%TERMINAL%' THEN 1 ELSE 0 END) AS terminal_master_merchant_flag,
        sum(CASE WHEN l.reason_changed LIKE '%CELLPHONE%' THEN 1 ELSE 0 END) AS cellphone_master_merchant_flag,
        sum(CASE WHEN l.reason_changed LIKE '%B_SHARED_DOCUMENT_MERCHANT%' THEN 1 ELSE 0 END) AS document_master_merchant_flag,
        sum(CASE WHEN l.reason_changed LIKE '%REPRESENTATIVE%' THEN 1 ELSE 0 END) AS legal_representative_master_merchant_flag,
        sum(CASE WHEN l.reason_changed LIKE '%C_SHARED_DOCUMENT_LEGAL_REPRESENTATIVE%' THEN 1 ELSE 0 END) AS shared_doc_legal_representative_flag
    FROM awsdatacatalog.bold_gold_growth.mart_master_merchant_lineage l
    INNER JOIN scope_ids s
        ON trim(cast(l.merchant_id AS varchar)) = s.merchant_id
    GROUP BY 1
),
merchant_enrich AS (
    SELECT
        trim(cast(e.merchant_id AS varchar)) AS merchant_id,
        trim(cast(e.master_merchant_id AS varchar)) AS master_merchant_id,
        e.kyc_verification_status_date AS kyc_date,
        e._1st_match_date AS first_match_date,
        e._1st_transaction_approved_date AS first_transaction_date,
        e.last_transaction_approved_date AS last_transaction_date
    FROM awsdatacatalog.bold_gold_growth.mart_merchant_enrich e
    INNER JOIN scope_ids s
        ON trim(cast(e.merchant_id AS varchar)) = s.merchant_id
),
merchant_contact AS (
    SELECT
        trim(cast(m.id AS varchar)) AS merchant_id,
        m.name AS merchant_name,
        m.document_type,
        cast(m.document_number AS varchar) AS document_number,
        m.status__status_code AS status_code,
        m.manual_verification_status__reason_code AS verification_status_code,
        m.sales_source AS sales_source_raw,
        CASE
            WHEN coalesce(m.sales_source, 'INBOUND') = 'INBOUND' THEN 'INBOUND'
            WHEN m.sales_source = 'REFERRED' THEN 'REFERRED'
            WHEN m.sales_source = 'RETAIL' THEN 'RETAIL'
            WHEN m.sales_source IN ('HUBS', 'OUTBOUND', 'STANDS', 'BOLD_STORE', 'EVENTS') THEN 'HUBS'
            WHEN m.sales_source IN ('DISTRIBUTOR', 'ALLIANCE') THEN 'DISTRIBUTOR'
            WHEN m.sales_source = 'SMB' THEN 'SMB'
            WHEN m.sales_source = 'ENTERPRISE' THEN 'ENTERPRISE'
            WHEN m.sales_source = 'ONLINE_PAYM' THEN 'ONLINE_PAYMENTS'
            ELSE m.sales_source
        END AS sales_source_normalized,
        lower(trim(coalesce(m.sales_agent_email, ''))) AS sales_agent_email,
        m.sales_reference,
        m.onboarding_end_date,
        m.location_department__code AS department_code,
        p.name AS legal_representative_name,
        p.last_name AS legal_representative_last_name,
        p.cellphone_number AS legal_representative_phone,
        p.email AS legal_representative_email
    FROM awsdatacatalog.bold_gold_payments.dim_merchant m
    LEFT JOIN awsdatacatalog.bold_gold_growth.dim_person p
        ON m.id = p.merchant_id
       AND m.legal_representative_id = p.id
    WHERE trim(cast(m.id AS varchar)) IN (
        SELECT merchant_id FROM scope_ids
        UNION
        SELECT master_merchant_id FROM merchant_enrich WHERE master_merchant_id IS NOT NULL
    )
),
detalle AS (
    SELECT
        s.source_row,
        CASE
            WHEN s.merchant_id = 'FR3AWY0OWD' THEN 'MASTER_REFERENCIA'
            ELSE 'COOPICREDITO_AGOSTO'
        END AS tipo_registro,
        s.merchant_id,
        s.estado_onboarding_archivo,
        s.clasificacion_tpv_archivo,
        s.ejecutivo_onboarding_archivo,
        mc.merchant_name,
        mc.document_type,
        mc.document_number,
        mc.status_code,
        mc.verification_status_code,
        mc.sales_source_raw,
        mc.sales_source_normalized,
        mc.sales_agent_email,
        mc.sales_reference,
        mc.onboarding_end_date,
        mc.department_code,
        mc.legal_representative_name,
        mc.legal_representative_last_name,
        mc.legal_representative_phone,
        mc.legal_representative_email,
        me.master_merchant_id,
        mm.merchant_name AS master_merchant_name,
        mm.document_type AS master_document_type,
        mm.document_number AS master_document_number,
        mm.sales_source_raw AS master_sales_source_raw,
        mm.sales_source_normalized AS master_sales_source_normalized,
        mm.sales_agent_email AS master_sales_agent_email,
        mm.status_code AS master_status_code,
        mm.verification_status_code AS master_verification_status_code,
        ml.parent_merchant_ids_lineage,
        ml.reason_changed,
        CASE
            WHEN ml.reason_changed LIKE '%NO_CHANGE%' OR ml.reason_changed IS NULL OR ml.reason_changed = '' THEN 1
            ELSE 0
        END AS flag_master_merchant_reporte_metabase,
        coalesce(ml.terminal_master_merchant_flag, 0) AS terminal_master_merchant_flag,
        coalesce(ml.cellphone_master_merchant_flag, 0) AS cellphone_master_merchant_flag,
        coalesce(ml.document_master_merchant_flag, 0) AS document_master_merchant_flag,
        coalesce(ml.legal_representative_master_merchant_flag, 0) AS legal_representative_master_merchant_flag,
        coalesce(ml.shared_doc_legal_representative_flag, 0) AS shared_doc_legal_representative_flag,
        me.kyc_date,
        me.first_match_date,
        me.first_transaction_date,
        me.last_transaction_date,
        CASE
            WHEN s.merchant_id = 'FR3AWY0OWD' THEN 'REGISTRO_MASTER_FR3'
            WHEN me.master_merchant_id = 'FR3AWY0OWD' THEN 'MASTER_FR3_POR_MART_MERCHANT_ENRICH'
            WHEN ml.parent_merchant_ids_lineage LIKE '%FR3AWY0OWD%' THEN 'MASTER_FR3_POR_LINEAGE'
            WHEN me.master_merchant_id IS NULL AND ml.parent_merchant_ids_lineage IS NULL THEN 'SIN_RELACION_MASTER_VISIBLE'
            WHEN me.master_merchant_id = s.merchant_id THEN 'MERCHANT_ES_SU_PROPIO_MASTER'
            ELSE 'OTRO_MASTER'
        END AS relacion_con_fr3awy0owd,
        CASE
            WHEN mc.document_number IS NOT NULL
             AND mm.document_number IS NOT NULL
             AND mc.document_type = mm.document_type
             AND mc.document_number = mm.document_number
                THEN 'MISMO_DOCUMENTO_MERCHANT_Y_MASTER'
            WHEN mc.document_number IS NOT NULL
             AND mm.document_number IS NOT NULL
                THEN 'DOCUMENTO_MERCHANT_DISTINTO_AL_MASTER'
            ELSE 'DOCUMENTO_INCOMPLETO'
        END AS comparacion_documento_merchant_vs_master,
        CASE
            WHEN coalesce(ml.shared_doc_legal_representative_flag, 0) > 0 THEN 'AGRUPACION_POR_DOCUMENTO_REPRESENTANTE_LEGAL'
            WHEN coalesce(ml.legal_representative_master_merchant_flag, 0) > 0 THEN 'AGRUPACION_POR_REPRESENTANTE_LEGAL'
            WHEN coalesce(ml.document_master_merchant_flag, 0) > 0 THEN 'AGRUPACION_POR_DOCUMENTO_MERCHANT'
            WHEN coalesce(ml.cellphone_master_merchant_flag, 0) > 0 THEN 'AGRUPACION_POR_CELULAR'
            WHEN coalesce(ml.terminal_master_merchant_flag, 0) > 0 THEN 'AGRUPACION_POR_TERMINAL'
            WHEN ml.reason_changed IS NULL THEN 'SIN_REASON_CHANGED'
            ELSE 'OTRA_RAZON_LINEAGE'
        END AS causa_lineage_priorizada
    FROM merchant_scope s
    LEFT JOIN merchant_contact mc
        ON mc.merchant_id = s.merchant_id
    LEFT JOIN merchant_enrich me
        ON me.merchant_id = s.merchant_id
    LEFT JOIN master_merchant_lineage ml
        ON ml.merchant_id = s.merchant_id
    LEFT JOIN merchant_contact mm
        ON mm.merchant_id = me.master_merchant_id
)
SELECT
    d.*,
    count(*) OVER () AS registros_salida,
    sum(CASE WHEN d.tipo_registro = 'COOPICREDITO_AGOSTO' THEN 1 ELSE 0 END) OVER () AS merchants_coopicredito_agosto,
    sum(CASE WHEN d.tipo_registro = 'COOPICREDITO_AGOSTO' AND d.relacion_con_fr3awy0owd IN ('MASTER_FR3_POR_MART_MERCHANT_ENRICH', 'MASTER_FR3_POR_LINEAGE') THEN 1 ELSE 0 END) OVER () AS merchants_coopicredito_relacionados_fr3,
    sum(CASE WHEN d.shared_doc_legal_representative_flag > 0 THEN 1 ELSE 0 END) OVER () AS merchants_con_doc_representante_compartido,
    sum(CASE WHEN d.document_master_merchant_flag > 0 THEN 1 ELSE 0 END) OVER () AS merchants_con_documento_merchant_compartido,
    sum(CASE WHEN d.sales_source_normalized = 'ENTERPRISE' THEN 1 ELSE 0 END) OVER () AS merchants_canal_enterprise,
    sum(CASE WHEN d.master_sales_source_normalized = 'INBOUND' THEN 1 ELSE 0 END) OVER () AS merchants_con_master_inbound
FROM detalle d
ORDER BY
    CASE d.relacion_con_fr3awy0owd
        WHEN 'MASTER_FR3_POR_MART_MERCHANT_ENRICH' THEN 1
        WHEN 'MASTER_FR3_POR_LINEAGE' THEN 2
        WHEN 'OTRO_MASTER' THEN 3
        WHEN 'MERCHANT_ES_SU_PROPIO_MASTER' THEN 4
        WHEN 'SIN_RELACION_MASTER_VISIBLE' THEN 5
        ELSE 6
    END,
    d.causa_lineage_priorizada,
    d.source_row
