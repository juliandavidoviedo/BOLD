-- DESCUBRIMIENTO DE ARQUITECTURA REAL PARA COOPICRÉDITO
-- Athena / Trino. Ejecutar cada bloque por separado en Metabase/Athena.
-- Este archivo no inventa ni presupone una tabla de entrada para los merchants.

-- BLOQUE 1: schemas disponibles
SELECT catalog_name, schema_name
FROM information_schema.schemata
WHERE lower(schema_name) LIKE '%growth%'
   OR lower(schema_name) LIKE '%sales%'
   OR lower(schema_name) LIKE '%terminal%'
   OR lower(schema_name) LIKE '%finance%'
ORDER BY catalog_name, schema_name;

-- BLOQUE 2: tablas candidatas reales por nombre
SELECT table_schema, table_name, table_type
FROM information_schema.tables
WHERE lower(table_schema) IN ('bold_gold_growth', 'bold_gold_sales', 'bold_gold_terminals', 'bold_gold_finance')
  AND (
       lower(table_name) LIKE '%merchant%'
    OR lower(table_name) LIKE '%client%'
    OR lower(table_name) LIKE '%onboard%'
    OR lower(table_name) LIKE '%terminal%'
    OR lower(table_name) LIKE '%trans%'
    OR lower(table_name) LIKE '%tpv%'
    OR lower(table_name) LIKE '%channel%'
    OR lower(table_name) LIKE '%sales%'
  )
ORDER BY table_schema, table_name;

-- BLOQUE 3: columnas reales para resolver el cruce y las reglas de negocio
SELECT table_schema, table_name, ordinal_position, column_name, data_type
FROM information_schema.columns
WHERE lower(table_schema) IN ('bold_gold_growth', 'bold_gold_sales', 'bold_gold_terminals', 'bold_gold_finance')
  AND (
       lower(column_name) LIKE '%merchant%'
    OR lower(column_name) LIKE '%client%'
    OR lower(column_name) LIKE '%onboard%'
    OR lower(column_name) LIKE '%terminal%'
    OR lower(column_name) LIKE '%serial%'
    OR lower(column_name) LIKE '%trans%'
    OR lower(column_name) LIKE '%tpv%'
    OR lower(column_name) LIKE '%channel%'
    OR lower(column_name) LIKE '%source%'
    OR lower(column_name) LIKE '%agent%'
    OR lower(column_name) LIKE '%executive%'
    OR lower(column_name) LIKE '%email%'
    OR lower(column_name) LIKE '%date%'
  )
ORDER BY table_schema, table_name, ordinal_position;

-- BLOQUE 4: comprobar tablas ya usadas en consultas documentadas
SELECT expected.table_schema, expected.table_name,
       CASE WHEN actual.table_name IS NULL THEN 'NO_ENCONTRADA' ELSE 'ENCONTRADA' END AS estado
FROM (
    VALUES
      ('bold_gold_growth', 'dim_client'),
      ('bold_gold_growth', 'dim_merchant_onboarding'),
      ('bold_gold_growth', 'mart_merchant_enrich'),
      ('bold_gold_growth', 'mart_master_merchant_enrich'),
      ('bold_gold_growth', 'mart_tpv_daily_by_merchant'),
      ('bold_gold_growth', 'mart_tpv_daily_by_transaction'),
      ('bold_gold_terminals', 'dim_terminal'),
      ('bold_gold_terminals', 'fact_terminal_history'),
      ('bold_gold_terminals', 'mart_terminal_enrich'),
      ('bold_gold_sales', 'dim_crm_opportunities'),
      ('bold_gold_sales', 'dim_crm_users'),
      ('bold_gold_sales', 'dim_user_bamboo_information')
) AS expected(table_schema, table_name)
LEFT JOIN information_schema.tables actual
  ON actual.table_schema = expected.table_schema
 AND actual.table_name = expected.table_name
ORDER BY expected.table_schema, expected.table_name;

-- BLOQUE 5: localizar si existe una tabla de carga/lista mensual ya creada.
-- Se busca por nombre; no se asume que exista.
SELECT table_schema, table_name, table_type
FROM information_schema.tables
WHERE lower(table_name) LIKE '%coopic%'
   OR lower(table_name) LIKE '%drog%'
   OR lower(table_name) LIKE '%vinculad%'
   OR lower(table_name) LIKE '%solicitud%'
   OR lower(table_name) LIKE '%cambio%canal%'
   OR lower(table_name) LIKE '%input%merchant%'
ORDER BY table_schema, table_name;

-- BLOQUE 6: validación posterior (rellenar SOLO con una tabla encontrada en BLOQUE 5)
-- SELECT * FROM <tabla_real_encontrada> LIMIT 20;
