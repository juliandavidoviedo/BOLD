-- Objetivo:
-- Descubrir en que tablas/marts existen campos candidatos de direccion, ciudad,
-- municipio, departamento y codigos geograficos para enriquecer los merchant_id
-- del Handoff SMB.
--
-- Importante para Metabase:
-- Ejecutar SOLO un bloque a la vez. Metabase/Athena puede mostrar error si se
-- pegan varias sentencias juntas.
--
-- BLOQUE 1 - Catalogo de columnas candidatas
-- Copiar y ejecutar desde WITH candidate_columns AS (...) hasta ORDER BY ...

WITH candidate_columns AS (
    SELECT
        table_schema,
        table_name,
        ordinal_position,
        column_name,
        data_type,
        CASE
            WHEN lower(column_name) IN ('merchant_id', 'master_merchant_id') THEN 'JOIN_MERCHANT'
            WHEN lower(column_name) IN ('client_id', 'master_client_id') THEN 'JOIN_CLIENT'
            WHEN lower(column_name) LIKE '%address%' THEN 'ADDRESS'
            WHEN lower(column_name) LIKE '%direccion%' THEN 'ADDRESS'
            WHEN lower(column_name) LIKE '%city%' THEN 'CITY'
            WHEN lower(column_name) LIKE '%municip%' THEN 'MUNICIPALITY'
            WHEN lower(column_name) LIKE '%department%' THEN 'DEPARTMENT'
            WHEN lower(column_name) LIKE '%departamento%' THEN 'DEPARTMENT'
            WHEN lower(column_name) LIKE '%dane%' THEN 'DANE_CODE'
            WHEN lower(column_name) LIKE '%postal%' THEN 'POSTAL_CODE'
            WHEN lower(column_name) LIKE '%location%' THEN 'LOCATION'
            WHEN lower(column_name) LIKE '%geo%' THEN 'GEO'
            WHEN lower(column_name) LIKE '%latitude%' OR lower(column_name) LIKE '%latitud%' THEN 'LATITUDE'
            WHEN lower(column_name) LIKE '%longitude%' OR lower(column_name) LIKE '%longitud%' THEN 'LONGITUDE'
            ELSE 'OTHER'
        END AS candidate_type,
        CASE
            WHEN table_schema = 'bold_gold_growth'
                 AND table_name IN (
                    'dim_client',
                    'dim_merchant_onboarding',
                    'dim_client_georeference',
                    'mart_master_merchant_enrich',
                    'mart_merchant_enrich'
                 ) THEN 1
            WHEN table_schema = 'bold_gold_payments'
                 AND table_name IN ('dim_merchant') THEN 2
            WHEN table_schema = 'bold_gold_sales'
                 AND lower(table_name) LIKE '%location%' THEN 3
            WHEN table_schema LIKE 'bold_gold_%' THEN 4
            ELSE 9
        END AS prioridad
    FROM awsdatacatalog.information_schema.columns
    WHERE table_schema LIKE 'bold_gold_%'
      AND (
          lower(column_name) IN (
              'merchant_id',
              'master_merchant_id',
              'client_id',
              'master_client_id'
          )
          OR lower(column_name) LIKE '%address%'
          OR lower(column_name) LIKE '%direccion%'
          OR lower(column_name) LIKE '%city%'
          OR lower(column_name) LIKE '%municip%'
          OR lower(column_name) LIKE '%department%'
          OR lower(column_name) LIKE '%departamento%'
          OR lower(column_name) LIKE '%dane%'
          OR lower(column_name) LIKE '%postal%'
          OR lower(column_name) LIKE '%location%'
          OR lower(column_name) LIKE '%geo%'
          OR lower(column_name) LIKE '%latitude%'
          OR lower(column_name) LIKE '%longitude%'
          OR lower(column_name) LIKE '%latitud%'
          OR lower(column_name) LIKE '%longitud%'
      )
)
SELECT
    prioridad,
    table_schema,
    table_name,
    candidate_type,
    column_name,
    data_type,
    ordinal_position
FROM candidate_columns
ORDER BY
    prioridad,
    table_schema,
    table_name,
    CASE candidate_type
        WHEN 'JOIN_MERCHANT' THEN 1
        WHEN 'JOIN_CLIENT' THEN 2
        WHEN 'ADDRESS' THEN 3
        WHEN 'CITY' THEN 4
        WHEN 'MUNICIPALITY' THEN 5
        WHEN 'DEPARTMENT' THEN 6
        WHEN 'DANE_CODE' THEN 7
        ELSE 9
    END,
    ordinal_position
