-- ============================================================
-- PULLMAN | REPORTE TRANSACCIONAL APROBADOS
-- Plantilla fiel al reporte de Mis Carnes Parrilla
-- Motor: Athena / Trino
-- Periodo: 2026-06-01 a 2026-08-12 inclusive
--
-- Universo Pullman:
--   J7KC6JLFIJ
--   M0ZCT4GSAT
--   IX8YV49KVP
--   45GXPINC22
--   375N178LGP
--
-- Fuentes:
--   bold_gold_payments.fact_payment
--   bold_gold_accounting.dim_movement_details_payment
--   bold_gold_growth.dim_person
--   bold_gold_payments.fact_partial_payments
--
-- Grano:
--   1 fila por merchant_id + payment_id
--
-- Regla de negocio:
--   Solo transacciones APPROVED.
-- ============================================================

WITH merchant_pullman (merchant_id) AS (
    VALUES
        ('J7KC6JLFIJ'),
        ('M0ZCT4GSAT'),
        ('IX8YV49KVP'),
        ('45GXPINC22'),
        ('375N178LGP')
),

payment_base AS (
    SELECT
        p.*,
        ROW_NUMBER() OVER (
            PARTITION BY p."merchant_id", p."payment_id"
            ORDER BY p."transaction_datetime" DESC
        ) AS rn
    FROM "bold_gold_payments"."fact_payment" p
    INNER JOIN merchant_pullman mp
        ON p."merchant_id" = mp.merchant_id
    WHERE p."transaction_datetime" >= TIMESTAMP '2026-06-01 00:00:00'
      AND p."transaction_datetime" <  TIMESTAMP '2026-08-13 00:00:00'
      AND p."status" = 'APPROVED'
),

payment AS (
    SELECT *
    FROM payment_base
    WHERE rn = 1
),

movement_base AS (
    SELECT
        m.*,
        ROW_NUMBER() OVER (
            PARTITION BY m."merchant_id", m."transaction_id"
            ORDER BY m."load_datetime" DESC, m."internal_event_id" DESC
        ) AS rn
    FROM "bold_gold_accounting"."dim_movement_details_payment" m
    INNER JOIN payment p
        ON p."merchant_id" = m."merchant_id"
       AND p."payment_id" = m."transaction_id"
),

movement AS (
    SELECT *
    FROM movement_base
    WHERE rn = 1
),

person_base AS (
    SELECT
        dp.*,
        ROW_NUMBER() OVER (
            PARTITION BY dp."id"
            ORDER BY dp."load_datetime" DESC
        ) AS rn
    FROM "bold_gold_growth"."dim_person" dp
    INNER JOIN payment p
        ON p."user_id" = dp."id"
),

person AS (
    SELECT *
    FROM person_base
    WHERE rn = 1
),

partial_payments AS (
    SELECT
        pp."payment_id",
        MAX(pp."split_check_id") AS split_check_id
    FROM "bold_gold_payments"."fact_partial_payments" pp
    INNER JOIN payment p
        ON p."payment_id" = pp."payment_id"
    GROUP BY 1
)

SELECT
    p."merchant_id" AS "MERCHANT ID",
    p."payment_id" AS "ID TRANSACCIÓN",
    p."transaction_datetime" AS "FECHA",

    'APROBADO' AS "OPERACIÓN",

    COALESCE(
        CAST(m."sale_amount" AS DECIMAL(38,2)),
        CAST(m."taxable_base" AS DECIMAL(38,2)),
        CAST(p."amount_total" AS DECIMAL(38,2))
            - COALESCE(CAST(m."vat" AS DECIMAL(38,2)), CAST(0 AS DECIMAL(38,2)))
            - COALESCE(CAST(p."amount_tip" AS DECIMAL(38,2)), CAST(0 AS DECIMAL(38,2)))
            - COALESCE(CAST(p."amount_consumption_tax" AS DECIMAL(38,2)), CAST(0 AS DECIMAL(38,2)))
    ) AS "VALOR DE LA COMPRA",

    COALESCE(
        CAST(p."amount_tip" AS DECIMAL(38,2)),
        CAST(m."tip" AS DECIMAL(38,2)),
        CAST(0 AS DECIMAL(38,2))
    ) AS "PROPINA",

    COALESCE(CAST(m."vat" AS DECIMAL(38,2)), CAST(0 AS DECIMAL(38,2))) AS "IVA",

    COALESCE(
        CAST(p."amount_consumption_tax" AS DECIMAL(38,2)),
        CAST(m."iac" AS DECIMAL(38,2)),
        CAST(0 AS DECIMAL(38,2))
    ) AS "IMPOCONSUMO",

    CAST(p."amount_total" AS DECIMAL(38,2)) AS "VALOR TOTAL",

    COALESCE(CAST(m."withholding_at_source" AS DECIMAL(38,2)), CAST(0 AS DECIMAL(38,2))) AS "VALOR RETE FUENTE",
    COALESCE(CAST(m."vat_withholding" AS DECIMAL(38,2)), CAST(0 AS DECIMAL(38,2))) AS "VALOR RETE IVA",
    COALESCE(CAST(m."ica_withholding" AS DECIMAL(38,2)), CAST(0 AS DECIMAL(38,2))) AS "VALOR RETE ICA",

    COALESCE(
        CAST(m."bold_percentage_processing_commission" AS DECIMAL(38,4)),
        CAST(0 AS DECIMAL(38,4))
    ) AS "% COMISIÓN BOLD",

    COALESCE(
        CAST(m."bold_flat_commission" AS DECIMAL(38,2)),
        CAST(0 AS DECIMAL(38,2))
    ) AS "COMISIÓN BOLD FIJA",

    (
        COALESCE(CAST(m."withholding_at_source" AS DECIMAL(38,2)), CAST(0 AS DECIMAL(38,2)))
        + COALESCE(CAST(m."vat_withholding" AS DECIMAL(38,2)), CAST(0 AS DECIMAL(38,2)))
        + COALESCE(CAST(m."ica_withholding" AS DECIMAL(38,2)), CAST(0 AS DECIMAL(38,2)))
        + COALESCE(CAST(m."bold_processing_commission" AS DECIMAL(38,2)), CAST(0 AS DECIMAL(38,2)))
    ) AS "TOTAL DEDUCCIÓN",

    COALESCE(
        CAST(m."balance_paid" AS DECIMAL(38,2)),
        CAST(0 AS DECIMAL(38,2))
    ) AS "DEPOSITO EN SALDO DE VENTAS",

    p."description" AS "DESCRIPCIÓN",
    p."terminal_serial" AS "SERIAL DEL DATÁFONO",
    p."terminal_name" AS "NOMBRE DEL DATÁFONO",
    p."authorization_code" AS "CODIGO AUTORIZACION",

    CASE
        WHEN p."card_account_type" = 'CHECKING' THEN 'CUENTA CORRIENTE'
        WHEN p."card_account_type" = 'CREDIT' THEN 'CRÉDITO'
        WHEN p."card_account_type" = 'SAVING' THEN 'CUENTA DE AHORROS'
        ELSE p."card_account_type"
    END AS "TIPO TARJETA",

    p."card_franchise" AS "FRANQUICIA",
    p."card_masked_pan" AS "TARJETA",

    CASE
        WHEN m."issuing_country" = 'CO' THEN 'NACIONAL'
        WHEN m."issuing_country" = 'ES' THEN 'ESPAÑA'
        WHEN m."issuing_country" = 'International' THEN 'INTERNACIONAL'
        WHEN m."issuing_country" IS NULL THEN 'NO DISPONIBLE'
        ELSE m."issuing_country"
    END AS "PAIS",

    p."card_bank_name" AS "BANCO",
    p."traceability_code" AS "CUS",

    CASE
        WHEN person."name" IS NULL AND person."last_name" IS NULL THEN 'NO DISPONIBLE'
        WHEN person."name" IS NULL THEN person."last_name"
        WHEN person."last_name" IS NULL THEN person."name"
        ELSE CONCAT(person."name", ' ', person."last_name")
    END AS "REALIZADA POR",

    CASE
        WHEN p."payment_method_type" = 'CREDIT_CARD' THEN 'TARJETA DE CRÉDITO'
        WHEN p."payment_method_type" = 'DAVIPLATA' THEN 'DAVIPLATA'
        WHEN p."payment_method_type" = 'DEBIT_CARD' THEN 'TARJETA DÉBITO'
        WHEN p."payment_method_type" = 'NEQUI' THEN 'NEQUI'
        WHEN p."payment_method_type" = 'PSE' THEN 'PSE'
        WHEN p."payment_method_type" = 'BANCOLOMBIA_BUTTON' THEN 'BOTON_BANCOLOMBIA'
        WHEN p."payment_method_type" = 'QR_BOLD' THEN 'QR BOLD'
        WHEN p."payment_method_type" IS NULL THEN 'NO DISPONIBLE'
        ELSE p."payment_method_type"
    END AS "METODO DE PAGO",

    CASE
        WHEN p."integration" = 'API_INTEGRATION' THEN 'INTEGRACIÓN API'
        WHEN p."integration" = 'BUTTON' THEN 'BOTÓN DE PAGOS'
        WHEN p."integration" = 'LINK' THEN 'LINK DE PAGOS'
        WHEN p."integration" = 'ONLINE_API_INTEGRATION' THEN 'INTEGRACIÓN API EN LÍNEA'
        WHEN p."integration" = 'POS' THEN 'DATAFONO'
        WHEN p."integration" = 'SOFT_POS' THEN 'DATAFONO VIRTUAL'
        WHEN p."integration" IS NULL THEN 'NO DISPONIBLE'
        ELSE p."integration"
    END AS "CANAL DE VENTAS",

    p."metadata_payer_payment_reference" AS "REFERENCIA",
    CAST(p."foreign_amount_exchange_rate_value" AS DECIMAL(38,8)) AS "TASA DE CAMBIO",
    p."foreign_amount_currency" AS "MONEDA EXTRANJERA",
    CAST(p."foreign_amount_total" AS DECIMAL(38,2)) AS "VALOR MONEDA EXTRANJERA",
    p."card_cardholder_name" AS "NOMBRE DEL PAGADOR",
    p."payer_email" AS "CORREO DEL PAGADOR",
    pp.split_check_id AS "CUENTA DIVIDIDA"

FROM payment p
LEFT JOIN movement m
    ON p."merchant_id" = m."merchant_id"
   AND p."payment_id" = m."transaction_id"
LEFT JOIN person
    ON p."user_id" = person."id"
LEFT JOIN partial_payments pp
    ON p."payment_id" = pp."payment_id"

ORDER BY
    "FECHA",
    "MERCHANT ID",
    "ID TRANSACCIÓN"

LIMIT 1048575;
