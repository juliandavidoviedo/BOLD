SELECT DISTINCT
    c.table_schema,
    c.table_name
FROM information_schema.columns c
INNER JOIN information_schema.columns m
    ON m.table_schema = c.table_schema
   AND m.table_name = c.table_name
WHERE lower(m.column_name) IN (
        'merchant_id',
        'merchant_key',
        'commerce_id'
    )
  AND (
        lower(c.column_name) LIKE '%sono%'
     OR lower(c.column_name) LIKE '%qr%'
     OR lower(c.column_name) LIKE '%terminal_serial%'
     OR lower(c.column_name) LIKE '%device_serial%'
     OR lower(c.column_name) LIKE '%product_type%'
     OR lower(c.column_name) LIKE '%activation_date%'
  )
ORDER BY 1, 2




    -------

    #	table_schema	table_name
1	bold_gold_finance	mart_tpv_daily_by_transaction
2	bold_gold_finance	mart_tpv_daily_by_transaction_global
3	bold_gold_fraud	fact_dispute_and_chargeback_with_protection
4	bold_gold_growth	mart_merchant_enrich
5	bold_gold_loan	dim_web_loan_offer
6	bold_gold_loan	dim_web_loan_offer_hist
7	bold_gold_online_payments	dim_online_link
8	bold_gold_payments	fact_payment
9	bold_gold_payments	fact_payment_history
10	bold_gold_payments	fact_payment_history_v2
11	bold_gold_payments	fact_payments_conciliation
12	bold_gold_payments	fact_refund
13	bold_gold_payments	fact_refund_history
14	bold_gold_payments	fact_transaction
15	bold_gold_payments	report_payments_dash_general
16	bold_gold_sales	fact_crm_opportunities_status_change
17	bold_gold_vendemas	mart_tpv_daily_by_transaction_vendemas

----

SELECT DISTINCT
    c.table_schema,
    c.table_name
FROM information_schema.columns c
INNER JOIN information_schema.columns m
    ON m.table_schema = c.table_schema
   AND m.table_name = c.table_name
WHERE lower(m.column_name) IN (
        'merchant_id',
        'merchant_key',
        'commerce_id'
    )
  AND (
        lower(c.column_name) LIKE '%account_number%'
     OR lower(c.column_name) LIKE '%account_id%'
     OR lower(c.column_name) LIKE '%bank_account%'
     OR lower(c.column_name) LIKE '%bold_account%'
     OR lower(c.column_name) LIKE '%financial_account%'
     OR lower(c.column_name) LIKE '%provider%'
     OR lower(c.column_name) LIKE '%institution%'
  )
ORDER BY 1, 2
----

#	table_schema	table_name
1	bold_gold_accounting	fact_pricing_applied
2	bold_gold_credit_card	fact_credit_card_fee_payment
3	bold_gold_credit_card	fact_credit_card_transaction_payment
4	bold_gold_finance	fact_applied_movement
5	bold_gold_finance	fact_payout
6	bold_gold_fraud	fact_payment_authentication
7	bold_gold_growth	dim_client
8	bold_gold_growth	dim_client_georeference
9	bold_gold_growth	dim_merchant_onboarding
10	bold_gold_growth	dim_onboarding_payments
11	bold_gold_loan	dim_automatic_debit_subscription
12	bold_gold_loan	fact_disbursement
13	bold_gold_loan	fact_installment
14	bold_gold_loan	mart_fact_risk_profile_traditional_variables
15	bold_gold_loan_cf	fact_disbursement_cf
16	bold_gold_loan_cf	fact_installment_cf
17	bold_gold_logistic	dim_shipping_order
18	bold_gold_logistic	dim_shipping_order_v2
19	bold_gold_online_payments	fact_payment_surveys
20	bold_gold_payments	dim_payments_merchant
21	bold_gold_payments	dim_payments_merchant_history
22	bold_gold_sales	dim_apolo_opportunities

