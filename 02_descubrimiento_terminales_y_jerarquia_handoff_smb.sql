-- Descubrimiento adicional: terminales y jerarquia comercial
-- Handoff Comercial SMB -> CS/KAM
-- Motor esperado: Athena / Trino desde Metabase
-- Fecha: 2026-08-27
--
-- Como usar:
-- Ejecutar un bloque a la vez en Metabase.
--
-- Motivo:
-- En el discovery recibido, las tablas de terminales NO aparecen en
-- bold_gold_growth, pero si aparece el schema bold_gold_terminals.
-- Ademas, no quedaron confirmadas columnas para team_lead/manager.

-- -------------------------------------------------------------------------
-- BLOQUE 1: tablas candidatas en bold_gold_terminals
-- -------------------------------------------------------------------------
SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'bold_gold_terminals'
  AND (
      lower(table_name) LIKE '%terminal%'
      OR lower(table_name) LIKE '%device%'
      OR lower(table_name) LIKE '%serial%'
      OR lower(table_name) LIKE '%merchant%'
      OR lower(table_name) LIKE '%assignment%'
      OR lower(table_name) LIKE '%history%'
      OR lower(table_name) LIKE '%enrich%'
  )
ORDER BY table_name;

-- -------------------------------------------------------------------------
-- BLOQUE 2: columnas candidatas en bold_gold_terminals
-- -------------------------------------------------------------------------
SELECT
    table_schema,
    table_name,
    column_name,
    data_type,
    ordinal_position,
    CASE
        WHEN lower(column_name) IN ('merchant_id', 'master_merchant_id') THEN 'llave_merchant'
        WHEN lower(column_name) LIKE '%terminal%' THEN 'terminal'
        WHEN lower(column_name) LIKE '%serial%' THEN 'serial'
        WHEN lower(column_name) LIKE '%device%' THEN 'device'
        WHEN lower(column_name) LIKE '%status%' OR lower(column_name) LIKE '%state%' THEN 'estado_terminal'
        WHEN lower(column_name) LIKE '%model%' THEN 'modelo_terminal'
        WHEN lower(column_name) LIKE '%updated%' OR lower(column_name) LIKE '%created%' OR lower(column_name) LIKE '%date%' THEN 'fecha_frescura'
        ELSE 'otro'
    END AS concepto_sugerido
FROM information_schema.columns
WHERE table_schema = 'bold_gold_terminals'
  AND (
      lower(column_name) LIKE '%merchant%'
      OR lower(column_name) LIKE '%terminal%'
      OR lower(column_name) LIKE '%serial%'
      OR lower(column_name) LIKE '%device%'
      OR lower(column_name) LIKE '%status%'
      OR lower(column_name) LIKE '%state%'
      OR lower(column_name) LIKE '%model%'
      OR lower(column_name) LIKE '%updated%'
      OR lower(column_name) LIKE '%created%'
      OR lower(column_name) LIKE '%date%'
  )
ORDER BY table_name, concepto_sugerido, ordinal_position;

-- -------------------------------------------------------------------------
-- BLOQUE 3: buscar tablas de jerarquia comercial en schemas growth
-- -------------------------------------------------------------------------
SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema IN (
    'bold_gold_growth',
    'bold_gold_growth_accounting'
)
  AND (
      lower(table_name) LIKE '%sales%'
      OR lower(table_name) LIKE '%commercial%'
      OR lower(table_name) LIKE '%agent%'
      OR lower(table_name) LIKE '%team%'
      OR lower(table_name) LIKE '%lead%'
      OR lower(table_name) LIKE '%manager%'
      OR lower(table_name) LIKE '%assignment%'
      OR lower(table_name) LIKE '%kam%'
      OR lower(table_name) LIKE '%smb%'
  )
ORDER BY table_schema, table_name;

-- -------------------------------------------------------------------------
-- BLOQUE 4: columnas candidatas de jerarquia comercial
-- -------------------------------------------------------------------------
SELECT
    table_schema,
    table_name,
    column_name,
    data_type,
    ordinal_position,
    CASE
        WHEN lower(column_name) IN ('merchant_id', 'master_merchant_id') THEN 'llave_merchant'
        WHEN lower(column_name) LIKE '%sales%agent%email%' THEN 'sales_agent_email'
        WHEN lower(column_name) LIKE '%agent%' THEN 'agent'
        WHEN lower(column_name) LIKE '%team%lead%' OR lower(column_name) LIKE '%tl%' THEN 'team_lead'
        WHEN lower(column_name) LIKE '%manager%' THEN 'manager'
        WHEN lower(column_name) LIKE '%kam%' THEN 'kam'
        WHEN lower(column_name) LIKE '%updated%' OR lower(column_name) LIKE '%created%' OR lower(column_name) LIKE '%date%' THEN 'fecha_frescura'
        ELSE 'otro'
    END AS concepto_sugerido
FROM information_schema.columns
WHERE table_schema IN (
    'bold_gold_growth',
    'bold_gold_growth_accounting'
)
  AND (
      lower(column_name) LIKE '%merchant%'
      OR lower(column_name) LIKE '%sales%'
      OR lower(column_name) LIKE '%agent%'
      OR lower(column_name) LIKE '%team%'
      OR lower(column_name) LIKE '%lead%'
      OR lower(column_name) LIKE '%tl%'
      OR lower(column_name) LIKE '%manager%'
      OR lower(column_name) LIKE '%kam%'
      OR lower(column_name) LIKE '%updated%'
      OR lower(column_name) LIKE '%created%'
      OR lower(column_name) LIKE '%date%'
  )
ORDER BY table_schema, table_name, concepto_sugerido, ordinal_position;

-- -------------------------------------------------------------------------
-- BLOQUE 5: validacion de cardinalidad cuando se elija tabla de terminales
-- -------------------------------------------------------------------------
-- Reemplazar nombre_tabla_terminales, merchant_id, terminal_id y fecha/estado
-- por los nombres reales encontrados en los bloques 1 y 2.
--
-- SELECT
--     cast(merchant_id AS varchar) AS merchant_id,
--     count(*) AS filas,
--     count(DISTINCT terminal_id) AS terminales_distintas
-- FROM awsdatacatalog.bold_gold_terminals.nombre_tabla_terminales
-- WHERE cast(merchant_id AS varchar) IN (
--     '0CZTLXEOXY',
--     '7DVLTIUMHX',
--     'RMCVFJO3D8',
--     '60WPJO2DZX',
--     '8R8UIAMUC6',
--     'PA1LA4GGYD',
--     'WFK9N0809K',
--     '3SQNBLP4ZN',
--     'LG773V6IUV',
--     'VMKYJPDVD1'
-- )
-- GROUP BY cast(merchant_id AS varchar)
-- ORDER BY merchant_id;
