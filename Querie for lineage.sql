SELECT
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema IN ('bold_gold_growth', 'bold_gold_payments')
  AND table_name IN ('mart_master_merchant_lineage', 'dim_merchant')
  AND (
      lower(column_name) LIKE '%merchant%'
      OR lower(column_name) LIKE '%master%'
      OR lower(column_name) LIKE '%document%'
      OR lower(column_name) LIKE '%terminal%'
      OR lower(column_name) LIKE '%flag%'
      OR lower(column_name) LIKE '%rank%'
      OR lower(column_name) LIKE '%onboarding%'
      OR lower(column_name) LIKE '%creation%'
  )
ORDER BY table_schema, table_name, ordinal_position

#	table_schema	table_name	column_name	data_type
1	bold_gold_growth	mart_master_merchant_lineage	merchant_id	varchar
2	bold_gold_growth	mart_master_merchant_lineage	parent_merchant_id	varchar
3	bold_gold_payments	dim_merchant	merchant_category_key	varchar
4	bold_gold_payments	dim_merchant	merchant_key	varchar
5	bold_gold_payments	dim_merchant	onboarding_end_date	timestamp(3)
6	bold_gold_payments	dim_merchant	document_number	varchar
7	bold_gold_payments	dim_merchant	document_type	varchar



SELECT
    l.merchant_id,
    l.parent_merchant_id
FROM awsdatacatalog.bold_gold_growth.mart_master_merchant_lineage l
WHERE l.merchant_id IN (
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
