WITH merchant_scope (source_row, merchant_id) AS (
    VALUES
        (1, 'B0CKR5HU8C'), (2, 'R2BWFBJS7A'), (3, 'ENVQ1TNW9V'), (4, 'BGDA1VQOLZ'),
        (5, 'CINAK5N1MV'), (6, '3ODGLUFW0P'), (7, 'TOGZAEVZ0K'), (8, '0XV9992C0O'),
        (9, 'GHTNMF7727'), (10, 'XMABPI8SDB'), (11, '1KQZPLFRVW'), (12, 'JXLFJ824NO'),
        (13, 'PL0B5ER5G3'), (14, 'L7H1W2PHU6'), (15, '0GRNI5F4QF'), (16, 'R4FNXSI23Y'),
        (17, 'M28ST7P6ZS'), (18, 'BW2O3VIGL9'), (19, '0GDIBQPP50'), (20, 'Z472LRDO4K'),
        (21, '97B1X3AQSJ'), (22, '9RDRW9GH0A'), (23, 'FK9XQZ1MGR'), (24, 'Q8BB6LMM80'),
        (25, '4ET483LBS9'), (26, 'UJ6IC6QYVU'), (27, 'F4K0HCI3BX'), (28, 'T035E5K6WQ'),
        (29, 'D7F22FG5QR'), (30, 'FUGNVIJWU8'), (31, 'AJ5XQ8640E'), (32, '4I2PD2J2SH')
),
client_ranked AS (
    SELECT
        s.merchant_id,
        c.merchant_name,
        c.sales_source,
        c.merchant_acquisition_channel_sales_agent_email AS sales_agent_email,
        c.creation_date AS merchant_creation_date,
        c.onboarding_status,
        c.status AS merchant_status,
        row_number() OVER (
            PARTITION BY trim(cast(c.merchant_id AS varchar))
            ORDER BY c.last_update_event_date DESC NULLS LAST,
                     c.creation_date DESC NULLS LAST
        ) AS rn
    FROM merchant_scope s
    LEFT JOIN awsdatacatalog.bold_gold_growth.dim_client c
        ON trim(cast(c.merchant_id AS varchar)) = s.merchant_id
),
client_current AS (
    SELECT * FROM client_ranked WHERE rn = 1
),
first_transaction_ranked AS (
    SELECT
        trim(cast(t.merchant_id AS varchar)) AS merchant_id,
        t.transaction_id,
        t.creation_datetime AS primera_transaccion,
        t.terminal_serial AS terminal_primera_transaccion,
        coalesce(t.tpv, 0) AS tpv_primera_transaccion,
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
    c.merchant_name,
    c.sales_source,
    c.sales_agent_email,
    c.merchant_creation_date,
    c.onboarding_status,
    c.merchant_status,
    f.transaction_id AS primera_transaction_id,
    f.primera_transaccion,
    f.terminal_primera_transaccion,
    f.tpv_primera_transaccion,
    CASE
        WHEN c.merchant_id IS NULL THEN 'SIN_MATCH_DIM_CLIENT'
        WHEN upper(trim(coalesce(c.sales_source, ''))) = 'ENTERPRISE' THEN 'YA_ENTERPRISE'
        WHEN f.merchant_id IS NULL THEN 'SIN_PRIMERA_TRANSACCION_CON_TERMINAL'
        ELSE 'CANDIDATO_CAMBIO_CANAL_CON_TERMINAL'
    END AS estado_para_cambio_canal
FROM merchant_scope s
LEFT JOIN client_current c ON c.merchant_id = s.merchant_id
LEFT JOIN first_transaction f ON f.merchant_id = s.merchant_id
ORDER BY estado_para_cambio_canal, s.source_row;
