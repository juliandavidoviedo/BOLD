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
        sum(coalesce(tpvd.tpv, 0)) AS tpv_month
    FROM awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction tpvd
    INNER JOIN awsdatacatalog.bold_gold_core.dim_date d
        ON tpvd.date_key = d.date_key
    INNER JOIN validation_merchants vm
        ON cast(tpvd.merchant_id AS varchar) = vm.merchant_id
    GROUP BY
        cast(tpvd.merchant_id AS varchar),
        date_trunc('month', cast(d.date AS date))
),
first_month AS (
    SELECT
        merchant_id,
        min(month_date) AS mes_m0
    FROM tpv_monthly
    WHERE tpv_month > 0
    GROUP BY merchant_id
),
maturity AS (
    SELECT
        tm.merchant_id,
        fm.mes_m0,
        tm.month_date,
        date_diff('month', fm.mes_m0, tm.month_date) AS mes_maduracion,
        tm.tpv_month,
        tm.tx_month
    FROM tpv_monthly tm
    INNER JOIN first_month fm
        ON tm.merchant_id = fm.merchant_id
    WHERE date_diff('month', fm.mes_m0, tm.month_date) BETWEEN 0 AND 5
)
SELECT
    vm.merchant_id,
    min(m.mes_m0) AS mes_m0,
    max(CASE WHEN m.mes_maduracion = 5 THEN m.month_date END) AS mes_m5,
    sum(CASE WHEN m.mes_maduracion = 0 THEN m.tpv_month ELSE 0 END) AS tpv_m0,
    sum(CASE WHEN m.mes_maduracion = 1 THEN m.tpv_month ELSE 0 END) AS tpv_m1,
    sum(CASE WHEN m.mes_maduracion = 2 THEN m.tpv_month ELSE 0 END) AS tpv_m2,
    sum(CASE WHEN m.mes_maduracion = 3 THEN m.tpv_month ELSE 0 END) AS tpv_m3,
    sum(CASE WHEN m.mes_maduracion = 4 THEN m.tpv_month ELSE 0 END) AS tpv_m4,
    sum(CASE WHEN m.mes_maduracion = 5 THEN m.tpv_month ELSE 0 END) AS tpv_m5,
    sum(CASE WHEN m.mes_maduracion = 0 THEN m.tx_month ELSE 0 END) AS tx_m0,
    sum(CASE WHEN m.mes_maduracion = 1 THEN m.tx_month ELSE 0 END) AS tx_m1,
    sum(CASE WHEN m.mes_maduracion = 2 THEN m.tx_month ELSE 0 END) AS tx_m2,
    sum(CASE WHEN m.mes_maduracion = 3 THEN m.tx_month ELSE 0 END) AS tx_m3,
    sum(CASE WHEN m.mes_maduracion = 4 THEN m.tx_month ELSE 0 END) AS tx_m4,
    sum(CASE WHEN m.mes_maduracion = 5 THEN m.tx_month ELSE 0 END) AS tx_m5,
    count(DISTINCT m.month_date) AS meses_con_tpv_m0_m5
FROM validation_merchants vm
LEFT JOIN maturity m
    ON vm.merchant_id = m.merchant_id
GROUP BY vm.merchant_id
ORDER BY vm.merchant_id


##resultado
#	merchant_id	mes_m0	mes_m5	tpv_m0	tpv_m1	tpv_m2	tpv_m3	tpv_m4	tpv_m5	tx_m0	tx_m1	tx_m2	tx_m3	tx_m4	tx_m5	meses_con_tpv_m0_m5
1	0CZTLXEOXY	2026-01-01		29710980.0000	16182220.0000	0.0000	0.0000	0.0000	0.0000	704	392	0	0	0	0	2
2	LG773V6IUV	2026-01-01	2026-06-01	71125136.0000	358055722.0000	450311189.0000	413367068.0000	493601740.0000	511800632.0000	141	764	747	761	867	884	6
