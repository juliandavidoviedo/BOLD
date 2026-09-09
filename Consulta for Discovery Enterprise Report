SELECT
    CASE
        WHEN lower(c.table_name) LIKE '%opportun%' THEN 'OPORTUNIDAD'
        WHEN lower(c.table_name) LIKE '%lead%' THEN 'LEAD'
        WHEN lower(c.table_name) LIKE '%user%' OR lower(c.table_name) LIKE '%bamboo%' THEN 'JERARQUIA_EJECUTIVO'
        WHEN lower(c.table_name) LIKE '%attribution%' THEN 'ATRIBUCION'
        ELSE 'OTRO'
    END AS familia,
    c.table_schema,
    c.table_name,
    c.ordinal_position,
    c.column_name,
    c.data_type,
    CASE
        WHEN lower(c.column_name) IN ('product_merchant_id', 'metadata_merchant_id', 'merchant_id') THEN 'LLAVE_MERCHANT'
        WHEN lower(c.column_name) IN ('metadata_client_id', 'client_id') THEN 'LLAVE_CLIENTE'
        WHEN lower(c.column_name) IN ('opportunity_id', 'lead_id', 'merchant_contact_id') THEN 'LLAVE_OPORTUNIDAD'
        WHEN lower(c.column_name) IN ('sales_channel', 'origin_name', 'origin_description') THEN 'CANAL_ORIGEN_OPORTUNIDAD'
        WHEN lower(c.column_name) LIKE '%executive%' OR lower(c.column_name) LIKE '%owner%' OR lower(c.column_name) LIKE '%user_id%' THEN 'RESPONSABLE'
        WHEN lower(c.column_name) LIKE '%creation%' OR lower(c.column_name) LIKE '%activation%' OR lower(c.column_name) LIKE '%won_date%' OR lower(c.column_name) LIKE '%assignment%' THEN 'FECHA_GESTION'
        WHEN lower(c.column_name) IN ('status', 'opportunity_status', 'lost_status', 'discard_category') THEN 'ESTADO_OPORTUNIDAD'
        WHEN lower(c.column_name) IN ('opportunity_type', 'management_type', 'is_terminal_reassignment', 'previous_user') THEN 'TIPO_GESTION'
        WHEN lower(c.column_name) IN ('email', 'parent_id', 'role', 'status', 'sales_channel') THEN 'JERARQUIA'
        ELSE 'OTRO'
    END AS uso_sugerido
FROM information_schema.columns c
WHERE c.table_schema IN ('bold_gold_sales', 'bold_gold_growth', 'bold_gold_terminals')
  AND (
        lower(c.table_name) LIKE '%opportun%'
     OR lower(c.table_name) LIKE '%lead%'
     OR lower(c.table_name) LIKE '%user%'
     OR lower(c.table_name) LIKE '%bamboo%'
     OR lower(c.table_name) LIKE '%attribution%'
     OR lower(c.table_name) LIKE '%assignment%'
  )
  AND lower(c.column_name) NOT LIKE '%token%'
  AND lower(c.column_name) NOT LIKE '%secret%'
  AND lower(c.column_name) NOT LIKE '%password%'
ORDER BY familia, c.table_schema, c.table_name, c.ordinal_position
