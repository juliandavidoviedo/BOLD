-- Cierre TPV M0 Enterprise - Agosto 2026
-- Objetivo:
-- 1) Medir TPV nuevo puro Enterprise para agosto.
-- 2) Separar reactivado, asignado/misión, expansión y cartera existente.
-- 3) Usar Coopicrédito como universo base del cierre cuando sea prospección propia Enterprise.
--
-- Instrucción:
-- Reemplazar master_enterprise_input por la lista oficial de merchants disponibles.
-- Si ya existe una tabla/Sheet cargada con esos merchants, reemplazar el CTE por un SELECT.

WITH master_enterprise_input AS (
    -- Ejemplo de estructura mínima.
    -- origin_type debe venir del criterio comercial validado:
    -- NUEVO_PURO, REACTIVADO, ASIGNADO_MISION, EXPANSION, CARTERA_EXISTENTE
    SELECT *
    FROM (
        VALUES
            -- ('MERCHANT_ID', DATE '2026-08-01', 'NUEVO_PURO', 'Coopicredito', 'Ejecutivo')
            ('REEMPLAZAR', CAST(NULL AS DATE), 'NUEVO_PURO', 'Coopicredito', CAST(NULL AS VARCHAR))
    ) AS t(
        merchant_id,
        fecha_vinculacion_gestion,
        origin_type,
        convenio,
        ejecutivo_enterprise
    )
    WHERE merchant_id <> 'REEMPLAZAR'
),

tpv_agosto AS (
    SELECT
        t.merchant_id,
        SUM(t.tpv) AS tpv_agosto,
        COUNT(DISTINCT t.transaction_id) AS tx_agosto,
        MIN(d.date) AS primera_tx_agosto,
        MAX(d.date) AS ultima_tx_agosto
    FROM bold_gold_finance.mart_tpv_daily_by_transaction t
    INNER JOIN bold_gold_core.dim_date d
        ON t.date_key = d.date_key
    WHERE d.date >= DATE '2026-08-01'
      AND d.date < DATE '2026-09-01'
    GROUP BY 1
),

historico_previo AS (
    SELECT
        t.merchant_id,
        MIN(d.date) AS primera_tx_historica,
        MAX(CASE WHEN d.date < DATE '2026-08-01' THEN d.date END) AS ultima_tx_antes_agosto,
        SUM(CASE WHEN d.date < DATE '2026-08-01' THEN t.tpv ELSE 0 END) AS tpv_antes_agosto,
        COUNT(DISTINCT CASE WHEN d.date < DATE '2026-08-01' THEN t.transaction_id END) AS tx_antes_agosto
    FROM bold_gold_finance.mart_tpv_daily_by_transaction t
    INNER JOIN bold_gold_core.dim_date d
        ON t.date_key = d.date_key
    WHERE d.date < DATE '2026-09-01'
    GROUP BY 1
),

clasificacion AS (
    SELECT
        m.merchant_id,
        m.convenio,
        m.ejecutivo_enterprise,
        m.fecha_vinculacion_gestion,
        m.origin_type AS origen_comercial_reportado,
        COALESCE(a.tpv_agosto, 0) AS tpv_agosto,
        COALESCE(a.tx_agosto, 0) AS tx_agosto,
        a.primera_tx_agosto,
        a.ultima_tx_agosto,
        h.primera_tx_historica,
        h.ultima_tx_antes_agosto,
        COALESCE(h.tpv_antes_agosto, 0) AS tpv_antes_agosto,
        COALESCE(h.tx_antes_agosto, 0) AS tx_antes_agosto,
        CASE
            WHEN m.origin_type = 'NUEVO_PURO'
             AND m.fecha_vinculacion_gestion >= DATE '2026-08-01'
             AND m.fecha_vinculacion_gestion < DATE '2026-09-01'
             AND COALESCE(h.tx_antes_agosto, 0) = 0
             AND COALESCE(a.tx_agosto, 0) > 0
                THEN 'NUEVO_PURO_ENTERPRISE_M0'

            WHEN m.origin_type = 'REACTIVADO'
             AND h.ultima_tx_antes_agosto < DATE_ADD('month', -6, DATE '2026-08-01')
             AND COALESCE(a.tx_agosto, 0) > 0
                THEN 'REACTIVADO_MAYOR_6_MESES'

            WHEN m.origin_type = 'ASIGNADO_MISION'
                THEN 'ASIGNADO_MISION'

            WHEN m.origin_type = 'EXPANSION'
                THEN 'EXPANSION_NUEVA_SEDE_MERCHANT'

            WHEN m.origin_type = 'CARTERA_EXISTENTE'
                THEN 'CARTERA_EXISTENTE'

            WHEN COALESCE(a.tx_agosto, 0) = 0
                THEN 'SIN_TPV_AGOSTO'

            ELSE 'REVISAR_CLASIFICACION'
        END AS categoria_cierre
    FROM master_enterprise_input m
    LEFT JOIN tpv_agosto a
        ON m.merchant_id = a.merchant_id
    LEFT JOIN historico_previo h
        ON m.merchant_id = h.merchant_id
)

SELECT
    categoria_cierre,
    COUNT(DISTINCT merchant_id) AS merchants,
    SUM(tpv_agosto) AS tpv_agosto,
    SUM(tx_agosto) AS tx_agosto,
    CASE
        WHEN COUNT(DISTINCT CASE WHEN tpv_agosto > 0 THEN merchant_id END) > 0
        THEN SUM(tpv_agosto) / COUNT(DISTINCT CASE WHEN tpv_agosto > 0 THEN merchant_id END)
    END AS tpv_promedio_por_merchant_activo
FROM clasificacion
GROUP BY 1
ORDER BY
    CASE categoria_cierre
        WHEN 'NUEVO_PURO_ENTERPRISE_M0' THEN 1
        WHEN 'REACTIVADO_MAYOR_6_MESES' THEN 2
        WHEN 'ASIGNADO_MISION' THEN 3
        WHEN 'EXPANSION_NUEVA_SEDE_MERCHANT' THEN 4
        WHEN 'CARTERA_EXISTENTE' THEN 5
        WHEN 'SIN_TPV_AGOSTO' THEN 6
        ELSE 7
    END;
cierre_tpv_m0_enterprise_agosto
