SELECT DISTINCT
    c.table_schema,
    c.table_name
FROM information_schema.columns c
INNER JOIN information_schema.columns m
    ON m.table_schema = c.table_schema
   AND m.table_name = c.table_name
WHERE lower(m.column_name) IN (
        'merchant_id',
        'merchant_key',
        'commerce_id'
    )
  AND (
        lower(c.column_name) LIKE '%sono%'
     OR lower(c.column_name) LIKE '%qr%'
     OR lower(c.column_name) LIKE '%terminal_serial%'
     OR lower(c.column_name) LIKE '%device_serial%'
     OR lower(c.column_name) LIKE '%product_type%'
     OR lower(c.column_name) LIKE '%activation_date%'
  )
ORDER BY 1, 2

----

SELECT DISTINCT
    c.table_schema,
    c.table_name
FROM information_schema.columns c
INNER JOIN information_schema.columns m
    ON m.table_schema = c.table_schema
   AND m.table_name = c.table_name
WHERE lower(m.column_name) IN (
        'merchant_id',
        'merchant_key',
        'commerce_id'
    )
  AND (
        lower(c.column_name) LIKE '%account_number%'
     OR lower(c.column_name) LIKE '%account_id%'
     OR lower(c.column_name) LIKE '%bank_account%'
     OR lower(c.column_name) LIKE '%bold_account%'
     OR lower(c.column_name) LIKE '%financial_account%'
     OR lower(c.column_name) LIKE '%provider%'
     OR lower(c.column_name) LIKE '%institution%'
  )
ORDER BY 1, 2
