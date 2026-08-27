-- Validación de la relación entre jerarquía comercial y merchant/client.
-- El resultado 07 encontró campos candidatos, pero aún no demostró la llave ni la vigencia.
-- Ejecutar cada bloque por separado.

-- 1) Estructura completa de tablas candidatas
SELECT table_schema, table_name, ordinal_position, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'bold_gold_sales'
  AND table_name IN (
      'dim_crm_pos_locations',
      'dim_crm_services',
      'dim_crm_users',
      'dim_user_bamboo_information',
      'dim_user_bamboo_information_history',
      'fact_crm_checkout_status_change'
  )
ORDER BY table_name, ordinal_position;

-- 2) Muestras de las tablas candidatas
SELECT * FROM awsdatacatalog.bold_gold_sales.dim_crm_pos_locations LIMIT 50;
SELECT * FROM awsdatacatalog.bold_gold_sales.dim_crm_services LIMIT 50;
SELECT * FROM awsdatacatalog.bold_gold_sales.dim_crm_users LIMIT 50;

-- 3) Cobertura por merchant de los 10 casos de prueba.
-- Ejecutar este bloque SOLO después de confirmar en el bloque 1 si existen
-- p.merchant_id y/o s.service_detail_client_id. Sustituir las llaves si tienen
-- otro nombre (por ejemplo client_id, location_id o user_id).
--
-- WITH validation_merchants (merchant_id) AS (...10 IDs...)
-- SELECT vm.merchant_id, p.manager_email, s.service_detail_client_kam_email
-- FROM validation_merchants vm
-- LEFT JOIN awsdatacatalog.bold_gold_sales.dim_crm_pos_locations p
--   ON cast(p.merchant_id AS varchar) = vm.merchant_id
-- LEFT JOIN awsdatacatalog.bold_gold_sales.dim_crm_services s
--   ON cast(s.service_detail_client_id AS varchar) = vm.merchant_id;

-- 4) Si la tabla no tiene merchant_id, revisar las llaves disponibles antes de unir.
-- No agregar joins por nombre, email o posición sin confirmar la relación.
