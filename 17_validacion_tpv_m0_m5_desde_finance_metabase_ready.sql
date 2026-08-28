WITH validation_merchants (merchant_id) AS (
    VALUES
        ('0CZTLXEOXY'),
        ('LG773V6IUV')
),
tpv_monthly AS (
    SELECT
        cast(tpvd.merchant_id AS varchar) AS merchant_id,
        date_trunc('month', cast(d.date AS date)) AS month_date,
        count(tpvd.transaction_id) AS tx_month,
        sum(coalesce(tpvd.tpv, 0)) AS tpv_month,
        sum(CASE WHEN tpvd.plan_name IN ('Bold D+1', 'Bold D+0') THEN coalesce(tpvd.tpv, 0) ELSE 0 END) AS tpv_cuenta_bold_month,
        sum(CASE WHEN tpvd.plan_name IN ('QR_BOLD', 'Otros Bancos D+1', 'legacy') THEN coalesce(tpvd.tpv, 0) ELSE 0 END) AS tpv_otros_bancos_month
    FROM awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction tpvd
    INNER JOIN awsdatacatalog.bold_gold_core.dim_date d
        ON tpvd.date_key = d.date_key
    INNER JOIN validation_merchants vm
        ON cast(tpvd.merchant_id AS varchar) = vm.merchant_id
    WHERE cast(d.date AS date) >= date_add('month', -5, date_trunc('month', current_date))
      AND cast(d.date AS date) < date_add('month', 1, date_trunc('month', current_date))
    GROUP BY
        cast(tpvd.merchant_id AS varchar),
        date_trunc('month', cast(d.date AS date))
),
tpv_m0_m5 AS (
    SELECT
        merchant_id,
        sum(CASE WHEN month_date = date_trunc('month', current_date) THEN tpv_month ELSE 0 END) AS tpv_m0,
        sum(CASE WHEN month_date = date_add('month', -1, date_trunc('month', current_date)) THEN tpv_month ELSE 0 END) AS tpv_m1,
        sum(CASE WHEN month_date = date_add('month', -2, date_trunc('month', current_date)) THEN tpv_month ELSE 0 END) AS tpv_m2,
        sum(CASE WHEN month_date = date_add('month', -3, date_trunc('month', current_date)) THEN tpv_month ELSE 0 END) AS tpv_m3,
        sum(CASE WHEN month_date = date_add('month', -4, date_trunc('month', current_date)) THEN tpv_month ELSE 0 END) AS tpv_m4,
        sum(CASE WHEN month_date = date_add('month', -5, date_trunc('month', current_date)) THEN tpv_month ELSE 0 END) AS tpv_m5,
        sum(CASE WHEN month_date = date_trunc('month', current_date) THEN tx_month ELSE 0 END) AS tx_m0,
        sum(CASE WHEN month_date = date_add('month', -1, date_trunc('month', current_date)) THEN tx_month ELSE 0 END) AS tx_m1,
        sum(CASE WHEN month_date = date_add('month', -2, date_trunc('month', current_date)) THEN tx_month ELSE 0 END) AS tx_m2,
        sum(CASE WHEN month_date = date_add('month', -3, date_trunc('month', current_date)) THEN tx_month ELSE 0 END) AS tx_m3,
        sum(CASE WHEN month_date = date_add('month', -4, date_trunc('month', current_date)) THEN tx_month ELSE 0 END) AS tx_m4,
        sum(CASE WHEN month_date = date_add('month', -5, date_trunc('month', current_date)) THEN tx_month ELSE 0 END) AS tx_m5,
        sum(CASE WHEN month_date = date_trunc('month', current_date) THEN tpv_cuenta_bold_month ELSE 0 END) AS tpv_cuenta_bold_m0,
        sum(CASE WHEN month_date = date_add('month', -1, date_trunc('month', current_date)) THEN tpv_cuenta_bold_month ELSE 0 END) AS tpv_cuenta_bold_m1,
        sum(CASE WHEN month_date = date_trunc('month', current_date) THEN tpv_otros_bancos_month ELSE 0 END) AS tpv_otros_bancos_m0,
        sum(CASE WHEN month_date = date_add('month', -1, date_trunc('month', current_date)) THEN tpv_otros_bancos_month ELSE 0 END) AS tpv_otros_bancos_m1,
        max(month_date) AS ultimo_mes_con_tpv,
        count(DISTINCT month_date) AS meses_con_tpv
    FROM tpv_monthly
    GROUP BY merchant_id
)
SELECT
    vm.merchant_id,
    coalesce(t.tpv_m0, 0) AS tpv_m0,
    coalesce(t.tpv_m1, 0) AS tpv_m1,
    coalesce(t.tpv_m2, 0) AS tpv_m2,
    coalesce(t.tpv_m3, 0) AS tpv_m3,
    coalesce(t.tpv_m4, 0) AS tpv_m4,
    coalesce(t.tpv_m5, 0) AS tpv_m5,
    greatest(
        coalesce(t.tpv_m0, 0),
        coalesce(t.tpv_m1, 0),
        coalesce(t.tpv_m2, 0),
        coalesce(t.tpv_m3, 0),
        coalesce(t.tpv_m4, 0),
        coalesce(t.tpv_m5, 0)
    ) AS tpv_max_m0_m5,
    coalesce(t.tx_m0, 0) AS tx_m0,
    coalesce(t.tx_m1, 0) AS tx_m1,
    coalesce(t.tx_m2, 0) AS tx_m2,
    coalesce(t.tx_m3, 0) AS tx_m3,
    coalesce(t.tx_m4, 0) AS tx_m4,
    coalesce(t.tx_m5, 0) AS tx_m5,
    coalesce(t.tpv_cuenta_bold_m0, 0) AS tpv_cuenta_bold_m0,
    coalesce(t.tpv_cuenta_bold_m1, 0) AS tpv_cuenta_bold_m1,
    coalesce(t.tpv_otros_bancos_m0, 0) AS tpv_otros_bancos_m0,
    coalesce(t.tpv_otros_bancos_m1, 0) AS tpv_otros_bancos_m1,
    CASE
        WHEN coalesce(t.tpv_m1, 0) = 0 THEN NULL
        ELSE (coalesce(t.tpv_m0, 0) - coalesce(t.tpv_m1, 0)) / coalesce(t.tpv_m1, 0)
    END AS crecimiento_m0_vs_m1,
    CASE
        WHEN (
            coalesce(t.tpv_m3, 0) + coalesce(t.tpv_m4, 0) + coalesce(t.tpv_m5, 0)
        ) = 0 THEN NULL
        ELSE (
            coalesce(t.tpv_m0, 0) + coalesce(t.tpv_m1, 0) + coalesce(t.tpv_m2, 0)
            - coalesce(t.tpv_m3, 0) - coalesce(t.tpv_m4, 0) - coalesce(t.tpv_m5, 0)
        ) / nullif(
            coalesce(t.tpv_m3, 0) + coalesce(t.tpv_m4, 0) + coalesce(t.tpv_m5, 0),
            0
        )
    END AS crecimiento_ultimos_3m_vs_previos_3m,
    t.ultimo_mes_con_tpv,
    coalesce(t.meses_con_tpv, 0) AS meses_con_tpv
FROM validation_merchants vm
LEFT JOIN tpv_m0_m5 t
    ON vm.merchant_id = t.merchant_id
ORDER BY vm.merchant_id
