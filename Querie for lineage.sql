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
