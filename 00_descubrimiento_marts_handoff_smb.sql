-- Descubrimiento de marts para Handoff Comercial SMB -> CS/KAM
-- Motor esperado: Athena / Trino desde Metabase
-- Fecha: 2026-08-27
--
-- Como usar este archivo:
-- Ejecutar un bloque a la vez en Metabase. No ejecutar todo el archivo junto,
-- porque Metabase/Athena puede rechazar multiples SELECT en una sola tarjeta.
--
-- Objetivo:
-- Documentar primero la arquitectura real de tablas, columnas y llaves antes
-- de construir la consulta integrada final.

-- -------------------------------------------------------------------------
-- BLOQUE 1: schemas disponibles relacionados con Bold Growth
-- -------------------------------------------------------------------------
SELECT
    catalog_name,
    schema_name
FROM information_schema.schemata
WHERE lower(schema_name) LIKE '%growth%'
   OR lower(schema_name) LIKE '%merchant%'
   OR lower(schema_name) LIKE '%client%'
   OR lower(schema_name) LIKE '%terminal%'
ORDER BY catalog_name, schema_name;

-- -------------------------------------------------------------------------
-- BLOQUE 2: tablas candidatas dentro de bold_gold_growth
-- -------------------------------------------------------------------------
SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'bold_gold_growth'
  AND (
      lower(table_name) LIKE '%client%'
      OR lower(table_name) LIKE '%merchant%'
      OR lower(table_name) LIKE '%tpv%'
      OR lower(table_name) LIKE '%terminal%'
      OR lower(table_name) LIKE '%transaction%'
      OR lower(table_name) LIKE '%commercial%'
      OR lower(table_name) LIKE '%sales%'
      OR lower(table_name) LIKE '%assignment%'
      OR lower(table_name) LIKE '%lineage%'
      OR lower(table_name) LIKE '%enrich%'
  )
ORDER BY table_name;

-- -------------------------------------------------------------------------
-- BLOQUE 3: columnas candidatas por concepto
-- -------------------------------------------------------------------------
SELECT
    table_schema,
    table_name,
    column_name,
    data_type,
    ordinal_position,
    CASE
        WHEN lower(column_name) IN ('merchant_id', 'merchantid') THEN 'llave_merchant'
        WHEN lower(column_name) LIKE '%merchant%name%' THEN 'nombre_comercio'
        WHEN lower(column_name) LIKE '%document%' OR lower(column_name) LIKE '%identification%' THEN 'documento'
        WHEN lower(column_name) LIKE '%categor%' OR lower(column_name) LIKE '%subcategory%' OR lower(column_name) LIKE '%mcc%' THEN 'categoria'
        WHEN lower(column_name) LIKE '%city%' OR lower(column_name) LIKE '%address%' THEN 'ubicacion'
        WHEN lower(column_name) LIKE '%email%' OR lower(column_name) LIKE '%phone%' OR lower(column_name) LIKE '%cell%' THEN 'contacto_base'
        WHEN lower(column_name) LIKE '%tpv%' OR lower(column_name) LIKE '%gmv%' OR lower(column_name) LIKE '%amount%' THEN 'tpv'
        WHEN lower(column_name) LIKE '%terminal%' OR lower(column_name) LIKE '%serial%' OR lower(column_name) LIKE '%device%' THEN 'terminales'
        WHEN lower(column_name) LIKE '%product%' OR lower(column_name) LIKE '%payment%' OR lower(column_name) LIKE '%qr%' OR lower(column_name) LIKE '%link%' THEN 'productos'
        WHEN lower(column_name) LIKE '%team%' OR lower(column_name) LIKE '%lead%' OR lower(column_name) LIKE '%manager%' OR lower(column_name) LIKE '%kam%' OR lower(column_name) LIKE '%agent%' THEN 'jerarquia_comercial'
        WHEN lower(column_name) LIKE '%updated%' OR lower(column_name) LIKE '%created%' OR lower(column_name) LIKE '%date%' THEN 'fecha_frescura'
        ELSE 'otro'
    END AS concepto_sugerido
FROM information_schema.columns
WHERE table_schema = 'bold_gold_growth'
  AND (
      lower(table_name) LIKE '%client%'
      OR lower(table_name) LIKE '%merchant%'
      OR lower(table_name) LIKE '%tpv%'
      OR lower(table_name) LIKE '%terminal%'
      OR lower(table_name) LIKE '%transaction%'
      OR lower(table_name) LIKE '%commercial%'
      OR lower(table_name) LIKE '%sales%'
      OR lower(table_name) LIKE '%assignment%'
      OR lower(table_name) LIKE '%lineage%'
      OR lower(table_name) LIKE '%enrich%'
  )
  AND (
      lower(column_name) LIKE '%merchant%'
      OR lower(column_name) LIKE '%document%'
      OR lower(column_name) LIKE '%identification%'
      OR lower(column_name) LIKE '%categor%'
      OR lower(column_name) LIKE '%subcategory%'
      OR lower(column_name) LIKE '%mcc%'
      OR lower(column_name) LIKE '%city%'
      OR lower(column_name) LIKE '%address%'
      OR lower(column_name) LIKE '%email%'
      OR lower(column_name) LIKE '%phone%'
      OR lower(column_name) LIKE '%cell%'
      OR lower(column_name) LIKE '%tpv%'
      OR lower(column_name) LIKE '%gmv%'
      OR lower(column_name) LIKE '%amount%'
      OR lower(column_name) LIKE '%terminal%'
      OR lower(column_name) LIKE '%serial%'
      OR lower(column_name) LIKE '%device%'
      OR lower(column_name) LIKE '%product%'
      OR lower(column_name) LIKE '%payment%'
      OR lower(column_name) LIKE '%qr%'
      OR lower(column_name) LIKE '%link%'
      OR lower(column_name) LIKE '%team%'
      OR lower(column_name) LIKE '%lead%'
      OR lower(column_name) LIKE '%manager%'
      OR lower(column_name) LIKE '%kam%'
      OR lower(column_name) LIKE '%agent%'
      OR lower(column_name) LIKE '%updated%'
      OR lower(column_name) LIKE '%created%'
      OR lower(column_name) LIKE '%date%'
  )
ORDER BY table_name, concepto_sugerido, ordinal_position;

-- -------------------------------------------------------------------------
-- BLOQUE 4: validar si las tablas sugeridas existen
-- -------------------------------------------------------------------------
WITH expected_tables(table_name, uso_esperado) AS (
    VALUES
        ('dim_client', 'datos_base_comercio'),
        ('mart_master_merchant_enrich', 'maestro_enriquecido_comercio'),
        ('mart_master_merchant_lineage', 'linaje_homologacion_merchant'),
        ('mart_tpv_daily_by_merchant', 'tpv_por_comercio'),
        ('mart_tpv_daily_by_transaction', 'tpv_productos_transacciones'),
        ('dim_terminal', 'dimension_terminal'),
        ('fact_terminal_history', 'historia_terminal'),
        ('mart_terminal_enrich', 'terminales_enriquecidas')
)
SELECT
    e.table_name,
    e.uso_esperado,
    CASE WHEN t.table_name IS NULL THEN 'NO_ENCONTRADA' ELSE 'ENCONTRADA' END AS estado
FROM expected_tables e
LEFT JOIN information_schema.tables t
    ON t.table_schema = 'bold_gold_growth'
   AND t.table_name = e.table_name
ORDER BY e.table_name;

-- -------------------------------------------------------------------------
-- BLOQUE 5: columnas de las tablas sugeridas encontradas
-- -------------------------------------------------------------------------
SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'bold_gold_growth'
  AND table_name IN (
      'dim_client',
      'mart_master_merchant_enrich',
      'mart_master_merchant_lineage',
      'mart_tpv_daily_by_merchant',
      'mart_tpv_daily_by_transaction',
      'dim_terminal',
      'fact_terminal_history',
      'mart_terminal_enrich'
  )
ORDER BY table_name, ordinal_position;

-- -------------------------------------------------------------------------
-- BLOQUE 6: plantilla de matriz fuente -> campo objetivo
-- -------------------------------------------------------------------------
-- Este bloque no consulta datos; sirve como contrato de documentacion.
-- Completar con los nombres reales despues de ejecutar los bloques anteriores.
SELECT *
FROM (
    VALUES
        ('merchant_id', 'pendiente', 'pendiente', 'llave primaria de cruce'),
        ('merchant_name', 'pendiente', 'pendiente', 'nombre del comercio'),
        ('document_type', 'pendiente', 'pendiente', 'tipo de documento'),
        ('document_number', 'pendiente', 'pendiente', 'numero de documento'),
        ('category_id', 'pendiente', 'pendiente', 'categoria o MCC'),
        ('subcategory_id', 'pendiente', 'pendiente', 'subcategoria'),
        ('city_code', 'pendiente', 'pendiente', 'ciudad normalizada'),
        ('address', 'pendiente', 'pendiente', 'direccion'),
        ('email', 'pendiente', 'pendiente', 'email base'),
        ('cellphone_number', 'pendiente', 'pendiente', 'telefono base'),
        ('sales_agent_email', 'pendiente', 'pendiente', 'ejecutivo comercial'),
        ('team_lead', 'pendiente', 'pendiente', 'lider comercial / TL'),
        ('manager', 'pendiente', 'pendiente', 'manager comercial'),
        ('tpv_max', 'pendiente', 'pendiente', 'TPV usado para clasificacion'),
        ('clasificacion_calculada', 'derivado', 'tpv_max', 'Mayor a 40M / Entre 20M y 40M / Menor a 20M'),
        ('numero_terminales', 'pendiente', 'pendiente', 'conteo de terminales vigentes'),
        ('terminales_asociadas', 'pendiente', 'pendiente', 'lista de terminales vigentes'),
        ('productos_observados_90d', 'pendiente', 'pendiente', 'productos con actividad transaccional reciente'),
        ('mes_transferencia', 'manual_control', 'parametro_carga', 'mes del lote: YYYY-MM')
) AS mapping(campo_objetivo, tabla_fuente, columna_fuente, definicion);
