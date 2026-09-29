WITH merchant_scope (source_row, merchant_id) AS (
    VALUES
        (1,'B0CKR5HU8C'),(2,'R2BWFBJS7A'),(3,'ENVQ1TNW9V'),(4,'BGDA1VQOLZ'),
        (5,'CINAK5N1MV'),(6,'3ODGLUFW0P'),(7,'TOGZAEVZ0K'),(8,'0XV9992C0O'),
        (9,'GHTNMF7727'),(10,'XMABPI8SDB'),(11,'1KQZPLFRVW'),(12,'JXLFJ824NO'),
        (13,'PL0B5ER5G3'),(14,'L7H1W2PHU6'),(15,'0GRNI5F4QF'),(16,'R4FNXSI23Y'),
        (17,'M28ST7P6ZS'),(18,'BW2O3VIGL9'),(19,'0GDIBQPP50'),(20,'Z472LRDO4K'),
        (21,'97B1X3AQSJ'),(22,'9RDRW9GH0A'),(23,'FK9XQZ1MGR'),(24,'Q8BB6LMM80'),
        (25,'4ET483LBS9'),(26,'UJ6IC6QYVU'),(27,'F4K0HCI3BX'),(28,'T035E5K6WQ'),
        (29,'D7F22FG5QR'),(30,'FUGNVIJWU8'),(31,'AJ5XQ8640E'),(32,'4I2PD2J2SH')
),
merchant_enrich AS (
    SELECT
        trim(cast(e.merchant_id AS varchar)) AS merchant_id,
        trim(cast(e.master_merchant_id AS varchar)) AS master_merchant_id,
        row_number() OVER (
            PARTITION BY trim(cast(e.merchant_id AS varchar))
            ORDER BY e.last_transaction_approved_date DESC NULLS LAST,
                     e.first_match_date DESC NULLS LAST
        ) AS rn
    FROM awsdatacatalog.bold_gold_growth.mart_merchant_enrich e
    INNER JOIN merchant_scope s
        ON trim(cast(e.merchant_id AS varchar)) = s.merchant_id
),
enrich_current AS (
    SELECT merchant_id, master_merchant_id
    FROM merchant_enrich
    WHERE rn = 1
),
scope_ids AS (
    SELECT merchant_id FROM merchant_scope
    UNION
    SELECT master_merchant_id FROM enrich_current WHERE master_merchant_id IS NOT NULL
),
merchant_dim AS (
    SELECT
        trim(cast(m.id AS varchar)) AS merchant_id,
        m.name AS merchant_name,
        m.document_type,
        cast(m.document_number AS varchar) AS document_number,
        m.sales_source,
        lower(trim(coalesce(m.sales_agent_email, ''))) AS sales_agent_email,
        m.status__status_code AS merchant_status,
        m.onboarding_status,
        m.onboarding_end_date,
        row_number() OVER (
            PARTITION BY trim(cast(m.id AS varchar))
            ORDER BY m.onboarding_end_date DESC NULLS LAST
        ) AS rn
    FROM awsdatacatalog.bold_gold_payments.dim_merchant m
    INNER JOIN scope_ids s
        ON trim(cast(m.id AS varchar)) = s.merchant_id
),
merchant_current AS (
    SELECT * FROM merchant_dim WHERE rn = 1
),
lineage AS (
    SELECT
        trim(cast(l.merchant_id AS varchar)) AS merchant_id,
        array_join(array_agg(DISTINCT trim(cast(l.parent_merchant_id AS varchar))), ', ') AS parent_merchant_ids_lineage,
        array_join(array_agg(DISTINCT cast(l.reason_changed AS varchar)), ' | ') AS reason_changed,
        max(CASE WHEN l.reason_changed LIKE '%TERMINAL%' THEN 1 ELSE 0 END) AS terminal_flag,
        max(CASE WHEN l.reason_changed LIKE '%CELLPHONE%' THEN 1 ELSE 0 END) AS cellphone_flag,
        max(CASE WHEN l.reason_changed LIKE '%B_SHARED_DOCUMENT_MERCHANT%' THEN 1 ELSE 0 END) AS document_flag,
        max(CASE WHEN l.reason_changed LIKE '%C_SHARED_DOCUMENT_LEGAL_REPRESENTATIVE%' THEN 1 ELSE 0 END) AS legal_representative_flag
    FROM awsdatacatalog.bold_gold_growth.mart_master_merchant_lineage l
    INNER JOIN scope_ids s
        ON trim(cast(l.merchant_id AS varchar)) = s.merchant_id
    GROUP BY 1
),
first_transaction_ranked AS (
    SELECT
        trim(cast(t.merchant_id AS varchar)) AS merchant_id,
        t.transaction_id,
        t.creation_datetime AS first_transaction_datetime,
        t.terminal_serial AS first_transaction_terminal,
        coalesce(t.tpv, 0) AS first_transaction_tpv,
        row_number() OVER (
            PARTITION BY trim(cast(t.merchant_id AS varchar))
            ORDER BY t.creation_datetime ASC, t.transaction_id
        ) AS rn
    FROM awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction t
    INNER JOIN merchant_scope s
        ON trim(cast(t.merchant_id AS varchar)) = s.merchant_id
    WHERE t.terminal_serial IS NOT NULL
      AND coalesce(t.tpv, 0) > 0
),
first_transaction AS (
    SELECT * FROM first_transaction_ranked WHERE rn = 1
)
SELECT
    s.source_row,
    s.merchant_id,
    md.merchant_name,
    md.document_type,
    md.document_number,
    coalesce(md.sales_source, 'SIN_CANAL_EN_DIM_MERCHANT') AS sales_source,
    md.sales_agent_email,
    md.merchant_status,
    md.onboarding_status,
    md.onboarding_end_date,
    ec.master_merchant_id,
    mm.merchant_name AS master_merchant_name,
    mm.document_type AS master_document_type,
    mm.document_number AS master_document_number,
    mm.sales_source AS master_sales_source,
    l.parent_merchant_ids_lineage,
    l.reason_changed,
    coalesce(l.terminal_flag, 0) AS terminal_master_flag,
    coalesce(l.cellphone_flag, 0) AS cellphone_master_flag,
    coalesce(l.document_flag, 0) AS document_master_flag,
    coalesce(l.legal_representative_flag, 0) AS legal_representative_master_flag,
    ft.transaction_id AS first_transaction_id,
    ft.first_transaction_datetime,
    ft.first_transaction_terminal,
    ft.first_transaction_tpv,
    CASE
        WHEN md.merchant_id IS NULL THEN 'REVISAR_SIN_MATCH_DIM_MERCHANT'
        WHEN upper(trim(coalesce(md.sales_source, ''))) = 'ENTERPRISE' THEN 'YA_ENTERPRISE'
        WHEN ft.merchant_id IS NULL THEN 'NO_ESCALAR_SIN_PRIMERA_TX_CON_TERMINAL'
        ELSE 'CANDIDATO_CAMBIO_CANAL'
    END AS decision_cambio_canal
FROM merchant_scope s
LEFT JOIN merchant_current md ON md.merchant_id = s.merchant_id
LEFT JOIN enrich_current ec ON ec.merchant_id = s.merchant_id
LEFT JOIN merchant_current mm ON mm.merchant_id = ec.master_merchant_id
LEFT JOIN lineage l ON l.merchant_id = s.merchant_id
LEFT JOIN first_transaction ft ON ft.merchant_id = s.merchant_id
ORDER BY decision_cambio_canal, s.source_row;
