WITH tablas_objetivo(table_schema, table_name, prioridad) AS (
    VALUES
        ('bold_gold_sales', 'dim_apolo_opportunities', 1),
        ('bold_gold_sales', 'dim_crm_opportunities', 2),
        ('bold_gold_sales', 'dim_crm_leads', 3),
        ('bold_gold_sales', 'fact_crm_checkout_status_change', 4),
        ('bold_gold_sales', 'fact_crm_leads_status_change', 5),
        ('bold_gold_sales', 'report_crm_leads_status_change_with_tasks', 6)
)
SELECT
    t.prioridad,
    c.table_schema,
    c.table_name,
    c.ordinal_position,
    c.column_name,
    c.data_type,
    CASE
        WHEN lower(c.column_name) IN ('merchant_id', 'product_merchant_id', 'metadata_merchant_id') THEN 'JOIN_MERCHANT'
        WHEN lower(c.column_name) IN ('client_id', 'metadata_client_id', 'metadata_client__id') THEN 'JOIN_CLIENT'
        WHEN lower(c.column_name) IN ('lead_id', 'merchant_contact_id') THEN 'JOIN_LEAD_CONTACT'
        WHEN lower(c.column_name) LIKE '%executive%email%' THEN 'RESPONSABLE_COMERCIAL_EMAIL'
        WHEN lower(c.column_name) LIKE '%created%by%email%' THEN 'CREADOR_OPORTUNIDAD_EMAIL'
        WHEN lower(c.column_name) LIKE '%user%email%' THEN 'USUARIO_EVENTO_EMAIL'
        WHEN lower(c.column_name) LIKE '%lead%email%' THEN 'LEAD_EMAIL'
        WHEN lower(c.column_name) LIKE '%manager%email%' THEN 'MANAGER_EMAIL'
        WHEN lower(c.column_name) LIKE '%owner%' THEN 'OWNER'
        WHEN lower(c.column_name) LIKE '%status%' THEN 'ESTADO_OPORTUNIDAD'
        WHEN lower(c.column_name) LIKE '%stage%' THEN 'ETAPA_OPORTUNIDAD'
        WHEN lower(c.column_name) LIKE '%date%' OR lower(c.column_name) LIKE '%datetime%' THEN 'FECHA'
        WHEN lower(c.column_name) LIKE '%comment%' OR lower(c.column_name) LIKE '%note%' THEN 'CONTEXTO_CRM_NO_HANDOFF'
        ELSE 'OTRO'
    END AS uso_sugerido
FROM information_schema.columns c
INNER JOIN tablas_objetivo t
    ON c.table_schema = t.table_schema
   AND c.table_name = t.table_name
WHERE lower(c.column_name) NOT LIKE '%token%'
  AND lower(c.column_name) NOT LIKE '%secret%'
  AND lower(c.column_name) NOT LIKE '%password%'
ORDER BY
    t.prioridad,
    c.table_schema,
    c.table_name,
    c.ordinal_position
