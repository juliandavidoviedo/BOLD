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




------
SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'bold_gold_terminals'
  AND table_name = 'mart_terminal_enrich'
ORDER BY ordinal_position

    #	table_schema	table_name	ordinal_position	column_name	data_type
1	bold_gold_terminals	mart_terminal_enrich	1	load_datetime	timestamp(6)
2	bold_gold_terminals	mart_terminal_enrich	2	terminal_key	varchar
3	bold_gold_terminals	mart_terminal_enrich	3	terminal_serial	varchar
4	bold_gold_terminals	mart_terminal_enrich	4	current_terminal_status	varchar
5	bold_gold_terminals	mart_terminal_enrich	5	terminal_model	varchar
6	bold_gold_terminals	mart_terminal_enrich	6	country_code	varchar
7	bold_gold_terminals	mart_terminal_enrich	7	model_name_category	varchar
8	bold_gold_terminals	mart_terminal_enrich	8	_1st_match_date	timestamp(6)
9	bold_gold_terminals	mart_terminal_enrich	9	_1st_merchant_matched	varchar
10	bold_gold_terminals	mart_terminal_enrich	10	_1st_merchant_match_document	varchar
11	bold_gold_terminals	mart_terminal_enrich	11	_1st_merchant_match_status	varchar
12	bold_gold_terminals	mart_terminal_enrich	12	_1st_terminal_match_client_id	varchar
13	bold_gold_terminals	mart_terminal_enrich	13	last_terminal_match_date	timestamp(6)
14	bold_gold_terminals	mart_terminal_enrich	14	last_terminal_match_merchant_id	varchar
15	bold_gold_terminals	mart_terminal_enrich	15	last_merchant_match_document	varchar
16	bold_gold_terminals	mart_terminal_enrich	16	last_merchant_match_status	varchar
17	bold_gold_terminals	mart_terminal_enrich	17	last_terminal_match_client_id	varchar
18	bold_gold_terminals	mart_terminal_enrich	18	count_distinct_merchant_terminal_matches	bigint
19	bold_gold_terminals	mart_terminal_enrich	19	count_distinct_client_terminal_matches	bigint
20	bold_gold_terminals	mart_terminal_enrich	20	total_terminal_matches	bigint
21	bold_gold_terminals	mart_terminal_enrich	21	current_merchant_matched	varchar
22	bold_gold_terminals	mart_terminal_enrich	22	_1st_match_date_current_merchant	timestamp(6)
23	bold_gold_terminals	mart_terminal_enrich	23	merchant_who_made_1st_transaction	varchar
24	bold_gold_terminals	mart_terminal_enrich	24	_1st_transaction_approved_date	timestamp(6)
25	bold_gold_terminals	mart_terminal_enrich	25	last_transaction_approved_date	timestamp(6)
26	bold_gold_terminals	mart_terminal_enrich	26	_1st_approved_transaction_id	varchar
27	bold_gold_terminals	mart_terminal_enrich	27	last_approved_transaction_id	varchar
28	bold_gold_terminals	mart_terminal_enrich	28	current_pricing_last_transaction_approved	varchar
29	bold_gold_terminals	mart_terminal_enrich	29	bold_app_version_last_tx_approved	varchar
30	bold_gold_terminals	mart_terminal_enrich	30	tpv_m0_since_terminal_activation	decimal(38,4)
31	bold_gold_terminals	mart_terminal_enrich	31	tpv_m1_since_terminal_activation	decimal(38,4)
32	bold_gold_terminals	mart_terminal_enrich	32	tpv_m2_since_terminal_activation	decimal(38,4)
33	bold_gold_terminals	mart_terminal_enrich	33	last_sim_reported	varchar
34	bold_gold_terminals	mart_terminal_enrich	34	last_comm_type_reported	varchar
35	bold_gold_terminals	mart_terminal_enrich	35	sales_origin_source	varchar
36	bold_gold_terminals	mart_terminal_enrich	36	delivered_date	timestamp(6)
37	bold_gold_terminals	mart_terminal_enrich	37	sales_executive_realocation	varchar
38	bold_gold_terminals	mart_terminal_enrich	38	sales_executive_realocation_flag	boolean
39	bold_gold_terminals	mart_terminal_enrich	39	purchase_date	timestamp(6)
40	bold_gold_terminals	mart_terminal_enrich	40	terminal_sales_source	varchar
41	bold_gold_terminals	mart_terminal_enrich	41	terminal_sales_executive	varchar
42	bold_gold_terminals	mart_terminal_enrich	42	terminal_price	decimal(18,2)
43	bold_gold_terminals	mart_terminal_enrich	43	payment_reference_purchase	varchar
44	bold_gold_terminals	mart_terminal_enrich	44	merchant_id_purchase	varchar
45	bold_gold_terminals	mart_terminal_enrich	45	extra_reference_purchase	varchar
46	bold_gold_terminals	mart_terminal_enrich	46	channel_source	varchar

----
SELECT
    model_name_category,
    terminal_model,
    count(*) AS filas,
    count(DISTINCT terminal_serial) AS terminales
FROM awsdatacatalog.bold_gold_terminals.mart_terminal_enrich
GROUP BY 1, 2
ORDER BY filas DESC

#	model_name_category	terminal_model	filas	terminales
1	NEO	QPOS_CUTE	361136	361136
2	SONOQR	ET389	187957	187957
3	PLUS	QPOS_PLUS	178537	178537
4	NEO	QPOS_MINI	105543	105543
5	SMART	D20	61217	61217
6	SMARTPRO	N86	40120	40120
7	KOZEN_P10	KOZEN_P10	28659	28659
8	KOZEN_P3	KOZEN_P3	9079	9079
9	SMART	P2_LITE_SE	8264	8264
10	A910S	A910S	6004	6004

    
---

SELECT
    bank_account_name,
    bank_account_type,
    count(*) AS filas,
    count(DISTINCT merchant_id) AS merchants
FROM awsdatacatalog.bold_gold_growth.dim_merchant_onboarding
GROUP BY 1, 2
ORDER BY filas DESC


    #	bank_account_name	bank_account_type	filas	merchants
1			319700	319700
2	BANCOLOMBIA	SAVING	182054	182054
3	NEQUI	SAVING	85671	85671
4	BANCO DAVIVIENDA S.A.	SAVING	36670	36670
5	DAVIPLATA	SAVING	20799	20799
6	BANCO CAJA SOCIAL BCSC S.A.	SAVING	14614	14614
7	BANCO DE BOGOTÁ	SAVING	7790	7790
8	BOLD. C.F.	SAVING	6506	6506
9	SCOTIABANK COLPATRIA S.A	SAVING	6495	6495
10	BANCOLOMBIA	CHECKING	5339	5339
11	BBVA COLOMBIA	SAVING	4293	4293
12	BANCO DAVIVIENDA S.A.	CHECKING	2899	2899
13	BANCO FALABELLA S.A.	SAVING	2815	2815
14	BANCO DE BOGOTÁ	CHECKING	2078	2078
15	BANCO AV VILLAS	SAVING	1864	1864
16	BANCO CAJA SOCIAL BCSC S.A.	CHECKING	1788	1788
17	NUBANK	SAVING	1297	1297
18	SCOTIABANK COLPATRIA S.A	CHECKING	1071	1071
19	BBVA COLOMBIA	CHECKING	884	884
20	LULO BANK S.A.	SAVING	776	776
21	BANCO AGRARIO	SAVING	688	688
22	ITAÚ	SAVING	657	657
23	BANCO POPULAR	SAVING	601	601
24	BANCO DE OCCIDENTE	SAVING	442	442
25	BANCO DE OCCIDENTE	CHECKING	437	437
26	UALA	SAVING	383	383
27	BANCO AV VILLAS	CHECKING	333	333
28	MOVII	SAVING	256	256
29	BANCO BCP	SAVING	249	249
30	BANCOOMEVA	SAVING	209	209
31	ITAÚ antes Corpbanca	SAVING	209	209
32	NEQUI	CHECKING	207	207
33	ITAÚ	CHECKING	174	174
34	RAPPIPAY	SAVING	171	171
35	BANCO INTERBANK	SAVING	161	161
36	IRIS	SAVING	160	160
37	BANCO FINANDINA S.A.	SAVING	147	147
38	BANCAMIA S.A.	SAVING	103	103
39	DAVIPLATA	CHECKING	85	85
40	BANCO AGRARIO	CHECKING	82	82
41	BANCO GNB SUDAMERIS	SAVING	81	81
42	BANCO COOPERATIVO COOPCENTRAL	SAVING	80	80
43	ITAÚ antes Corpbanca	CHECKING	79	79
44	CONFIAR COOPERATIVA FINANCIERA	SAVING	74	74
45	BANCOOMEVA	CHECKING	69	69
46	BANCO MUNDO MUJER	SAVING	61	61
47	BANCO BBVA	SAVING	47	47
48	BANCO PICHINCHA	SAVING	40	40
49	BANCO POPULAR	CHECKING	39	39
50	BANCO SCOTIABANK	SAVING	34	34
51	BANCO SERFINANZA S.A	SAVING	34	34
52	GIROS Y FINANZAS CF	SAVING	29	29
53	BANCO PICHINCHA	CHECKING	25	25
54	BANCO INTERBANK	CHECKING	25	25
55	BANCO W S.A.	SAVING	24	24
56	MIBANCO S.A.	SAVING	24	24
57	BANCO GNB SUDAMERIS	CHECKING	23	23
58	BANCO BCP	CHECKING	17	17
59	COLTEFINANCIERA S.A.	SAVING	14	14
60	BANCO FALABELLA S.A.	CHECKING	11	11
61	BANCO BBVA	CHECKING	11	11
62	MOVII	CHECKING	10	10
63	UALA	CHECKING	10	10
64	FINANCIARA JURISCOOP S.A. COMPAÑÍA DE FINANCIAMIENTO	SAVING	7	7
65	CITIBANK	CHECKING	5	5
66	BANCO CREDIFINANCIERA SA.	SAVING	5	5
67	BANCO COOPERATIVO COOPCENTRAL	CHECKING	4	4
68	BANCO SERFINANZA S.A	CHECKING	4	4
69	BOLD. C.F.	CHECKING	3	3
70	COOTRAFA COOPERATIVA FINANCIERA	SAVING	3	3
71	BANCO BTG PACTUAL	SAVING	2	2
72	CITIBANK	SAVING	2	2
73	BANCO J.P. MORGAN COLOMBIA S.A	CHECKING	1	1
74	MIBANCO S.A.	CHECKING	1	1
75	LULO BANK S.A.	CHECKING	1	1
76	BANCO SCOTIABANK	CHECKING	1	1
77	RAPPIPAY	CHECKING	1	1
78	BANCO CORPBANCA COLOMBIA S.A.	SAVING	1	1
79	FINANCIARA JURISCOOP S.A. COMPAÑÍA DE FINANCIAMIENTO	CHECKING	1	1
80	COOFINEP COOPERATIVA FINANCIER	SAVING	1	1

---

SELECT
    bank_account_id,
    bank_account_name,
    bank_account_type,
    count(DISTINCT merchant_id) AS merchants
FROM awsdatacatalog.bold_gold_growth.dim_merchant_onboarding
WHERE bank_account_id IS NOT NULL
GROUP BY 1, 2, 3
ORDER BY merchants DESC
LIMIT 100

#	bank_account_id	bank_account_name	bank_account_type	merchants
1	19	BANCOLOMBIA	SAVING	182054
2	29	NEQUI	SAVING	85671
3	8	BANCO DAVIVIENDA S.A.	SAVING	36670
4	30	DAVIPLATA	SAVING	20799
5	3	BANCO CAJA SOCIAL BCSC S.A.	SAVING	14614
6	9	BANCO DE BOGOTÁ	SAVING	7790
7	47	BOLD. C.F.	SAVING	6506
8	4	SCOTIABANK COLPATRIA S.A	SAVING	6495
9	19	BANCOLOMBIA	CHECKING	5339
10	21	BBVA COLOMBIA	SAVING	4293
11	8	BANCO DAVIVIENDA S.A.	CHECKING	2899
12	11	BANCO FALABELLA S.A.	SAVING	2815
13	9	BANCO DE BOGOTÁ	CHECKING	2078
14	2	BANCO AV VILLAS	SAVING	1864
15	3	BANCO CAJA SOCIAL BCSC S.A.	CHECKING	1788
16	48	NUBANK	SAVING	1297
17	4	SCOTIABANK COLPATRIA S.A	CHECKING	1071
18	21	BBVA COLOMBIA	CHECKING	884
19	43	LULO BANK S.A.	SAVING	776
20	1	BANCO AGRARIO	SAVING	688
21	40	ITAÚ	SAVING	657
22	16	BANCO POPULAR	SAVING	601
23	10	BANCO DE OCCIDENTE	SAVING	442
24	10	BANCO DE OCCIDENTE	CHECKING	437
25	46	UALA	SAVING	383
26	2	BANCO AV VILLAS	CHECKING	333
27	44	MOVII	SAVING	256
28	2	BANCO BCP	SAVING	249
29	28	ITAÚ antes Corpbanca	SAVING	209
30	20	BANCOOMEVA	SAVING	209
31	29	NEQUI	CHECKING	207
32	40	ITAÚ	CHECKING	174
33	41	RAPPIPAY	SAVING	171
34	4	BANCO INTERBANK	SAVING	161
35	45	IRIS	SAVING	160
36	12	BANCO FINANDINA S.A.	SAVING	147
37	34	BANCAMIA S.A.	SAVING	103
38	30	DAVIPLATA	CHECKING	85
39	1	BANCO AGRARIO	CHECKING	82
40	13	BANCO GNB SUDAMERIS	SAVING	81
41	6	BANCO COOPERATIVO COOPCENTRAL	SAVING	80
42	28	ITAÚ antes Corpbanca	CHECKING	79
43	24	CONFIAR COOPERATIVA FINANCIERA	SAVING	74
44	20	BANCOOMEVA	CHECKING	69
45	31	BANCO MUNDO MUJER	SAVING	61
46	3	BANCO BBVA	SAVING	47
47	15	BANCO PICHINCHA	SAVING	40
48	16	BANCO POPULAR	CHECKING	39
49	37	BANCO SERFINANZA S.A	SAVING	34
50	1	BANCO SCOTIABANK	SAVING	34
51	39	GIROS Y FINANZAS CF	SAVING	29
52	15	BANCO PICHINCHA	CHECKING	25
53	4	BANCO INTERBANK	CHECKING	25
54	33	BANCO W S.A.	SAVING	24
55	5	MIBANCO S.A.	SAVING	24
56	13	BANCO GNB SUDAMERIS	CHECKING	23
57	2	BANCO BCP	CHECKING	17
58	23	COLTEFINANCIERA S.A.	SAVING	14
59	11	BANCO FALABELLA S.A.	CHECKING	11
60	3	BANCO BBVA	CHECKING	11
61	46	UALA	CHECKING	10
62	44	MOVII	CHECKING	10
63	27	FINANCIARA JURISCOOP S.A. COMPAÑÍA DE FINANCIAMIENTO	SAVING	7
64	22	CITIBANK	CHECKING	5
65	35	BANCO CREDIFINANCIERA SA.	SAVING	5
66	37	BANCO SERFINANZA S.A	CHECKING	4
67	6	BANCO COOPERATIVO COOPCENTRAL	CHECKING	4
68	47	BOLD. C.F.	CHECKING	3
69	26	COOTRAFA COOPERATIVA FINANCIERA	SAVING	3
70	22	CITIBANK	SAVING	2
71	42	BANCO BTG PACTUAL	SAVING	2
72	36	BANCO J.P. MORGAN COLOMBIA S.A	CHECKING	1
73	27	FINANCIARA JURISCOOP S.A. COMPAÑÍA DE FINANCIAMIENTO	CHECKING	1
74	41	RAPPIPAY	CHECKING	1
75	5	MIBANCO S.A.	CHECKING	1
76	1	BANCO SCOTIABANK	CHECKING	1
77	38	COOFINEP COOPERATIVA FINANCIER	SAVING	1
78	7	BANCO CORPBANCA COLOMBIA S.A.	SAVING	1
79	43	LULO BANK S.A.	CHECKING	1


