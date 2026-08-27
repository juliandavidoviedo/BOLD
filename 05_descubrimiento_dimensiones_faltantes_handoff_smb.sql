-- Descubrimiento de dimensiones faltantes para Handoff Comercial SMB -> CS/KAM
-- Motor esperado: Athena / Trino desde Metabase
-- Fecha: 2026-08-27
--
-- Objetivo:
-- Encontrar fuentes oficiales para los campos que siguen pendientes:
-- - team_lead
-- - manager
-- - city_code / ciudad
-- - address / direccion
-- - email
-- - cellphone_number / telefono
-- - subcategory_id
--
-- Como usar:
-- Ejecutar un bloque a la vez en Metabase. No ejecutar todo el archivo junto.
--
-- Criterio:
-- Si la dimension encontrada se puede unir por merchant_id, master_merchant_id,
-- client_id, sales_agent_email o sales_agent_code, los datos se pueden integrar
-- en una sola consulta SQL. Si la fuente solo vive en Google Sheets/manual, se
-- necesita una fuente adicional fuera de Athena o una tabla de control cargada.

-- -------------------------------------------------------------------------
-- BLOQUE 1: buscar schemas que puedan contener usuarios, empleados, CRM,
-- jerarquia comercial, coverage, geo, merchant o onboarding
-- -------------------------------------------------------------------------
SELECT
    catalog_name,
    schema_name
FROM information_schema.schemata
WHERE lower(schema_name) LIKE '%growth%'
   OR lower(schema_name) LIKE '%sales%'
   OR lower(schema_name) LIKE '%commercial%'
   OR lower(schema_name) LIKE '%crm%'
   OR lower(schema_name) LIKE '%agent%'
   OR lower(schema_name) LIKE '%employee%'
   OR lower(schema_name) LIKE '%people%'
   OR lower(schema_name) LIKE '%user%'
   OR lower(schema_name) LIKE '%coverage%'
   OR lower(schema_name) LIKE '%geo%'
   OR lower(schema_name) LIKE '%merchant%'
   OR lower(schema_name) LIKE '%client%'
ORDER BY catalog_name, schema_name;

-- -------------------------------------------------------------------------
-- BLOQUE 2: tablas candidatas en schemas relevantes
-- Ajustar la lista de schemas si el bloque 1 revela otros nombres relevantes.
-- -------------------------------------------------------------------------
SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema IN (
    'bold_gold_growth',
    'bold_gold_growth_accounting',
    'bold_gold_terminals'
)
  AND (
      lower(table_name) LIKE '%sales%'
      OR lower(table_name) LIKE '%commercial%'
      OR lower(table_name) LIKE '%agent%'
      OR lower(table_name) LIKE '%seller%'
      OR lower(table_name) LIKE '%executive%'
      OR lower(table_name) LIKE '%team%'
      OR lower(table_name) LIKE '%lead%'
      OR lower(table_name) LIKE '%leader%'
      OR lower(table_name) LIKE '%manager%'
      OR lower(table_name) LIKE '%kam%'
      OR lower(table_name) LIKE '%assignment%'
      OR lower(table_name) LIKE '%portfolio%'
      OR lower(table_name) LIKE '%book%'
      OR lower(table_name) LIKE '%owner%'
      OR lower(table_name) LIKE '%user%'
      OR lower(table_name) LIKE '%employee%'
      OR lower(table_name) LIKE '%person%'
      OR lower(table_name) LIKE '%coverage%'
      OR lower(table_name) LIKE '%zone%'
      OR lower(table_name) LIKE '%geo%'
      OR lower(table_name) LIKE '%address%'
      OR lower(table_name) LIKE '%location%'
      OR lower(table_name) LIKE '%client%'
      OR lower(table_name) LIKE '%merchant%'
      OR lower(table_name) LIKE '%economic%'
      OR lower(table_name) LIKE '%category%'
  )
ORDER BY table_schema, table_name;

-- -------------------------------------------------------------------------
-- BLOQUE 3: columnas candidatas para jerarquia comercial en schemas relevantes
-- -------------------------------------------------------------------------
SELECT
    table_schema,
    table_name,
    column_name,
    data_type,
    ordinal_position,
    CASE
        WHEN lower(column_name) IN ('merchant_id', 'master_merchant_id') THEN 'join_merchant'
        WHEN lower(column_name) = 'client_id' THEN 'join_client'
        WHEN lower(column_name) LIKE '%sales%agent%email%' THEN 'join_sales_agent_email'
        WHEN lower(column_name) LIKE '%acquisition%channel%sales%agent%email%' THEN 'join_sales_agent_email'
        WHEN lower(column_name) LIKE '%sales%agent%code%' THEN 'join_sales_agent_code'
        WHEN lower(column_name) LIKE '%agent%code%' THEN 'join_agent_code'
        WHEN lower(column_name) LIKE '%agent%email%' THEN 'agent_email'
        WHEN lower(column_name) LIKE '%seller%email%' THEN 'seller_email'
        WHEN lower(column_name) LIKE '%executive%' THEN 'executive'
        WHEN lower(column_name) LIKE '%team%lead%' THEN 'team_lead'
        WHEN lower(column_name) LIKE '%leader%' THEN 'leader'
        WHEN lower(column_name) LIKE '%manager%' THEN 'manager'
        WHEN lower(column_name) LIKE '%kam%' THEN 'kam'
        WHEN lower(column_name) LIKE '%owner%' THEN 'owner'
        WHEN lower(column_name) LIKE '%channel%' THEN 'channel'
        WHEN lower(column_name) LIKE '%segment%' THEN 'segment'
        WHEN lower(column_name) LIKE '%updated%' OR lower(column_name) LIKE '%load%' OR lower(column_name) LIKE '%date%' THEN 'fecha_frescura'
        ELSE 'otro'
    END AS concepto_sugerido
FROM information_schema.columns
WHERE table_schema IN (
    'bold_gold_growth',
    'bold_gold_growth_accounting',
    'bold_gold_terminals'
)
  AND (
      lower(column_name) LIKE '%merchant%'
      OR lower(column_name) LIKE '%client%'
      OR lower(column_name) LIKE '%sales%'
      OR lower(column_name) LIKE '%agent%'
      OR lower(column_name) LIKE '%seller%'
      OR lower(column_name) LIKE '%executive%'
      OR lower(column_name) LIKE '%team%'
      OR lower(column_name) LIKE '%lead%'
      OR lower(column_name) LIKE '%leader%'
      OR lower(column_name) LIKE '%manager%'
      OR lower(column_name) LIKE '%kam%'
      OR lower(column_name) LIKE '%owner%'
      OR lower(column_name) LIKE '%channel%'
      OR lower(column_name) LIKE '%segment%'
      OR lower(column_name) LIKE '%updated%'
      OR lower(column_name) LIKE '%load%'
      OR lower(column_name) LIKE '%date%'
  )
ORDER BY table_schema, table_name, concepto_sugerido, ordinal_position;

-- -------------------------------------------------------------------------
-- BLOQUE 4: columnas candidatas para ubicacion y contacto base
-- -------------------------------------------------------------------------
SELECT
    table_schema,
    table_name,
    column_name,
    data_type,
    ordinal_position,
    CASE
        WHEN lower(column_name) IN ('merchant_id', 'master_merchant_id') THEN 'join_merchant'
        WHEN lower(column_name) = 'client_id' THEN 'join_client'
        WHEN lower(column_name) LIKE '%city%' THEN 'city'
        WHEN lower(column_name) LIKE '%municip%' THEN 'municipality'
        WHEN lower(column_name) LIKE '%department%' THEN 'department'
        WHEN lower(column_name) LIKE '%address%' THEN 'address'
        WHEN lower(column_name) LIKE '%location%' THEN 'location'
        WHEN lower(column_name) LIKE '%email%' THEN 'email'
        WHEN lower(column_name) LIKE '%phone%' THEN 'phone'
        WHEN lower(column_name) LIKE '%cell%' THEN 'cellphone'
        WHEN lower(column_name) LIKE '%mobile%' THEN 'mobile'
        WHEN lower(column_name) LIKE '%contact%' THEN 'contact'
        WHEN lower(column_name) LIKE '%updated%' OR lower(column_name) LIKE '%load%' OR lower(column_name) LIKE '%date%' THEN 'fecha_frescura'
        ELSE 'otro'
    END AS concepto_sugerido
FROM information_schema.columns
WHERE table_schema IN (
    'bold_gold_growth',
    'bold_gold_growth_accounting',
    'bold_gold_terminals'
)
  AND (
      lower(column_name) LIKE '%merchant%'
      OR lower(column_name) LIKE '%client%'
      OR lower(column_name) LIKE '%city%'
      OR lower(column_name) LIKE '%municip%'
      OR lower(column_name) LIKE '%department%'
      OR lower(column_name) LIKE '%address%'
      OR lower(column_name) LIKE '%location%'
      OR lower(column_name) LIKE '%email%'
      OR lower(column_name) LIKE '%phone%'
      OR lower(column_name) LIKE '%cell%'
      OR lower(column_name) LIKE '%mobile%'
      OR lower(column_name) LIKE '%contact%'
      OR lower(column_name) LIKE '%updated%'
      OR lower(column_name) LIKE '%load%'
      OR lower(column_name) LIKE '%date%'
  )
ORDER BY table_schema, table_name, concepto_sugerido, ordinal_position;

-- -------------------------------------------------------------------------
-- BLOQUE 5: columnas candidatas para categoria/subcategoria
-- -------------------------------------------------------------------------
SELECT
    table_schema,
    table_name,
    column_name,
    data_type,
    ordinal_position,
    CASE
        WHEN lower(column_name) IN ('merchant_id', 'master_merchant_id') THEN 'join_merchant'
        WHEN lower(column_name) = 'client_id' THEN 'join_client'
        WHEN lower(column_name) LIKE '%subcategor%' THEN 'subcategory'
        WHEN lower(column_name) LIKE '%category%' THEN 'category'
        WHEN lower(column_name) LIKE '%categor%' THEN 'categoria'
        WHEN lower(column_name) LIKE '%mcc%' THEN 'mcc'
        WHEN lower(column_name) LIKE '%ciiu%' THEN 'ciiu'
        WHEN lower(column_name) LIKE '%economic%activity%' THEN 'economic_activity'
        WHEN lower(column_name) LIKE '%occupation%' THEN 'occupation'
        WHEN lower(column_name) LIKE '%updated%' OR lower(column_name) LIKE '%load%' OR lower(column_name) LIKE '%date%' THEN 'fecha_frescura'
        ELSE 'otro'
    END AS concepto_sugerido
FROM information_schema.columns
WHERE table_schema IN (
    'bold_gold_growth',
    'bold_gold_growth_accounting',
    'bold_gold_terminals'
)
  AND (
      lower(column_name) LIKE '%merchant%'
      OR lower(column_name) LIKE '%client%'
      OR lower(column_name) LIKE '%subcategor%'
      OR lower(column_name) LIKE '%category%'
      OR lower(column_name) LIKE '%categor%'
      OR lower(column_name) LIKE '%mcc%'
      OR lower(column_name) LIKE '%ciiu%'
      OR lower(column_name) LIKE '%economic%activity%'
      OR lower(column_name) LIKE '%occupation%'
      OR lower(column_name) LIKE '%updated%'
      OR lower(column_name) LIKE '%load%'
      OR lower(column_name) LIKE '%date%'
  )
ORDER BY table_schema, table_name, concepto_sugerido, ordinal_position;

-- -------------------------------------------------------------------------
-- BLOQUE 6: columnas completas de tablas candidatas ya detectadas
-- -------------------------------------------------------------------------
SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'bold_gold_growth'
  AND table_name IN (
      'dim_client',
      'dim_client_georeference',
      'dim_merchant_onboarding',
      'dim_onboarding_client',
      'dim_onboarding_payments',
      'dim_profiling_sales_channels',
      'dim_coverage_zones',
      'dim_person',
      'dim_person_v2',
      'dim_product',
      'mart_merchant_enrich',
      'mart_master_merchant_enrich',
      'mart_master_merchant_lineage'
  )
ORDER BY table_schema, table_name, ordinal_position;

-- -------------------------------------------------------------------------
-- BLOQUE 7: validar si dim_profiling_sales_channels sirve para mapear
-- sales_agent_email -> team_lead / manager
-- -------------------------------------------------------------------------
SELECT
    *
FROM awsdatacatalog.bold_gold_growth.dim_profiling_sales_channels
LIMIT 50;

-- -------------------------------------------------------------------------
-- BLOQUE 8: validar si dim_client_georeference completa direccion/ciudad
-- para los 10 merchants de prueba
-- -------------------------------------------------------------------------
WITH validation_merchants (merchant_id) AS (
    VALUES
        ('0CZTLXEOXY'),
        ('7DVLTIUMHX'),
        ('RMCVFJO3D8'),
        ('60WPJO2DZX'),
        ('8R8UIAMUC6'),
        ('PA1LA4GGYD'),
        ('WFK9N0809K'),
        ('3SQNBLP4ZN'),
        ('LG773V6IUV'),
        ('VMKYJPDVD1')
)
SELECT
    g.*
FROM awsdatacatalog.bold_gold_growth.dim_client_georeference g
INNER JOIN validation_merchants vm
    ON cast(g.merchant_id AS varchar) = vm.merchant_id
LIMIT 50;

-- -------------------------------------------------------------------------
-- BLOQUE 9: validar si onboarding contiene email/telefono/direccion completos
-- para los 10 merchants de prueba
-- -------------------------------------------------------------------------
WITH validation_merchants (merchant_id) AS (
    VALUES
        ('0CZTLXEOXY'),
        ('7DVLTIUMHX'),
        ('RMCVFJO3D8'),
        ('60WPJO2DZX'),
        ('8R8UIAMUC6'),
        ('PA1LA4GGYD'),
        ('WFK9N0809K'),
        ('3SQNBLP4ZN'),
        ('LG773V6IUV'),
        ('VMKYJPDVD1')
)
SELECT
    o.*
FROM awsdatacatalog.bold_gold_growth.dim_merchant_onboarding o
INNER JOIN validation_merchants vm
    ON cast(o.merchant_id AS varchar) = vm.merchant_id
LIMIT 50;

-- -------------------------------------------------------------------------
-- BLOQUE 10: diagnostico de posibilidad de una sola consulta
-- Completar manualmente con base en los resultados anteriores.
-- -------------------------------------------------------------------------
SELECT *
FROM (
    VALUES
        ('team_lead', 'pendiente', 'pendiente', 'merchant_id o sales_agent_email', 'si hay llave en Athena, se integra; si no, fuente externa'),
        ('manager', 'pendiente', 'pendiente', 'merchant_id o sales_agent_email', 'si hay llave en Athena, se integra; si no, fuente externa'),
        ('city_code', 'pendiente', 'pendiente', 'merchant_id o client_id', 'posible si aparece en georeference/onboarding'),
        ('address', 'pendiente', 'pendiente', 'merchant_id o client_id', 'posible si aparece en georeference/onboarding'),
        ('email', 'pendiente', 'pendiente', 'merchant_id o client_id', 'posible si aparece en onboarding/client/person'),
        ('cellphone_number', 'pendiente', 'pendiente', 'merchant_id o client_id', 'posible si aparece en onboarding/client/person'),
        ('subcategory_id', 'pendiente', 'pendiente', 'merchant_id o activity_id', 'posible si existe dimension de categorias')
) AS decision(campo_faltante, tabla_candidata, columna_candidata, llave_necesaria, criterio);
