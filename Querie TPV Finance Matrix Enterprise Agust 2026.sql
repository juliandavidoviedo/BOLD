SELECT
    c.merchant_id,
    c.merchant_name,
    c.sales_source,
    c.merchant_acquisition_channel_sales_agent_email,
    c.creation_date,
    c.status,
    c.onboarding_status,
    c.last_update_event_date
FROM awsdatacatalog.bold_gold_growth.dim_client c
WHERE c.merchant_id IN (
    'TR2KLJUVZ6',
    'GSYCJJ0ZMX',
    '75H2G3UNCN',
    '0XV9992C0O',
    'GHTNMF7727',
    'XMABPI8SDB',
    'PL0B5ER5G3',
    'JXLFJ824NO'
)
LIMIT 50
