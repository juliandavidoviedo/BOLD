-- Descubrimiento específico de jerarquía comercial.
-- El resultado 05 confirmó que existe bold_gold_sales, pero no lo inspeccionó.
-- Ejecutar cada bloque por separado en Metabase/Athena.

-- 1) Tablas candidatas
SELECT table_schema, table_name, table_type
FROM information_schema.tables
WHERE table_schema IN ('bold_gold_sales', 'bold_users_uploads', 'bold_users_uploads_sales')
  AND (
      lower(table_name) LIKE '%agent%' OR lower(table_name) LIKE '%seller%'
      OR lower(table_name) LIKE '%team%' OR lower(table_name) LIKE '%lead%'
      OR lower(table_name) LIKE '%manager%' OR lower(table_name) LIKE '%hierarch%'
      OR lower(table_name) LIKE '%user%' OR lower(table_name) LIKE '%employee%'
      OR lower(table_name) LIKE '%coverage%' OR lower(table_name) LIKE '%merchant%'
      OR lower(table_name) LIKE '%assignment%' OR lower(table_name) LIKE '%owner%'
  )
ORDER BY table_schema, table_name;

-- 2) Columnas de jerarquía y llaves de unión
SELECT table_schema, table_name, ordinal_position, column_name, data_type
FROM information_schema.columns
WHERE table_schema IN ('bold_gold_sales', 'bold_users_uploads', 'bold_users_uploads_sales')
  AND (
      lower(column_name) LIKE '%merchant%' OR lower(column_name) LIKE '%client%'
      OR lower(column_name) LIKE '%agent%' OR lower(column_name) LIKE '%seller%'
      OR lower(column_name) LIKE '%lead%' OR lower(column_name) LIKE '%manager%'
      OR lower(column_name) LIKE '%leader%' OR lower(column_name) LIKE '%executive%'
      OR lower(column_name) LIKE '%email%' OR lower(column_name) LIKE '%employee%'
      OR lower(column_name) LIKE '%owner%' OR lower(column_name) LIKE '%team%'
      OR lower(column_name) LIKE '%updated%' OR lower(column_name) LIKE '%load%'
  )
ORDER BY table_schema, table_name, ordinal_position;

-- 3) Tras identificar una tabla, reemplazar NOMBRE_TABLA y revisar muestra.
-- SELECT * FROM awsdatacatalog.bold_gold_sales.NOMBRE_TABLA LIMIT 50;
