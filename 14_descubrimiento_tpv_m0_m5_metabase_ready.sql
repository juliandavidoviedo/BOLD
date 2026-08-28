WITH candidate_tables(table_schema, table_name, prioridad) AS (
    VALUES
        ('bold_gold_growth', 'mart_master_merchant_enrich', 1),
        ('bold_gold_growth', 'mart_tpv_daily_by_merchant', 2),
        ('bold_gold_growth', 'mart_tpv_daily_by_transaction', 3),
        ('bold_gold_growth', 'mart_merchant_enrich', 4)
)
SELECT
    c.prioridad,
    cols.table_schema,
    cols.table_name,
    cols.ordinal_position,
    cols.column_name,
    cols.data_type,
    CASE
        WHEN lower(cols.column_name) LIKE '%tpv%total%m0%' THEN 'TPV_M0_DIRECTO'
        WHEN lower(cols.column_name) LIKE '%tpv%total%m1%' THEN 'TPV_M1_DIRECTO'
        WHEN lower(cols.column_name) LIKE '%tpv%total%m2%' THEN 'TPV_M2_DIRECTO'
        WHEN lower(cols.column_name) LIKE '%tpv%total%m3%' THEN 'TPV_M3_DIRECTO'
        WHEN lower(cols.column_name) LIKE '%tpv%total%m4%' THEN 'TPV_M4_DIRECTO'
        WHEN lower(cols.column_name) LIKE '%tpv%total%m5%' THEN 'TPV_M5_DIRECTO'
        WHEN lower(cols.column_name) LIKE '%tpv%' THEN 'TPV_OTRO'
        WHEN lower(cols.column_name) LIKE '%transaction%date%' THEN 'FECHA_TRANSACCION'
        WHEN lower(cols.column_name) LIKE '%date%' THEN 'FECHA_OTRA'
        WHEN lower(cols.column_name) IN ('merchant_id', 'master_merchant_id') THEN 'LLAVE_MERCHANT'
        ELSE 'OTRO'
    END AS uso_sugerido
FROM information_schema.columns cols
INNER JOIN candidate_tables c
    ON cols.table_schema = c.table_schema
   AND cols.table_name = c.table_name
WHERE lower(cols.column_name) LIKE '%tpv%'
   OR lower(cols.column_name) LIKE '%transaction%date%'
   OR lower(cols.column_name) LIKE '%date%'
   OR lower(cols.column_name) IN ('merchant_id', 'master_merchant_id')
ORDER BY
    c.prioridad,
    cols.table_name,
    cols.ordinal_position
