-- DESCUBRIMIENTO DE ARQUITECTURA REAL PARA COOPICRÉDITO
-- Athena / Trino. Ejecutar cada bloque por separado en Metabase/Athena.
-- Este archivo no inventa ni presupone una tabla de entrada para los merchants.

-- BLOQUE 1: schemas disponibles
SELECT catalog_name, schema_name
FROM information_schema.schemata
WHERE lower(schema_name) LIKE '%growth%'
   OR lower(schema_name) LIKE '%sales%'
   OR lower(schema_name) LIKE '%terminal%'
   OR lower(schema_name) LIKE '%finance%'
ORDER BY catalog_name, schema_name;

#	catalog_name	schema_name
1	awsdatacatalog	bold_gold_finance
2	awsdatacatalog	bold_gold_growth
3	awsdatacatalog	bold_gold_growth_accounting
4	awsdatacatalog	bold_gold_sales
5	awsdatacatalog	bold_gold_terminals
6	awsdatacatalog	bold_users_uploads_sales


-- BLOQUE 2: tablas candidatas reales por nombre
SELECT table_schema, table_name, table_type
FROM information_schema.tables
WHERE lower(table_schema) IN ('bold_gold_growth', 'bold_gold_sales', 'bold_gold_terminals', 'bold_gold_finance')
  AND (
       lower(table_name) LIKE '%merchant%'
    OR lower(table_name) LIKE '%client%'
    OR lower(table_name) LIKE '%onboard%'
    OR lower(table_name) LIKE '%terminal%'
    OR lower(table_name) LIKE '%trans%'
    OR lower(table_name) LIKE '%tpv%'
    OR lower(table_name) LIKE '%channel%'
    OR lower(table_name) LIKE '%sales%'
  )
ORDER BY table_schema, table_name;

#	table_schema	table_name	table_type
1	bold_gold_finance	fact_ledger_draft_accounting_transaction_recored	BASE TABLE
2	bold_gold_finance	mart_tpv_daily_by_merchant	BASE TABLE
3	bold_gold_finance	mart_tpv_daily_by_transaction	BASE TABLE
4	bold_gold_finance	mart_tpv_daily_by_transaction_global	BASE TABLE
5	bold_gold_growth	dim_client	BASE TABLE
6	bold_gold_growth	dim_client_georeference	BASE TABLE
7	bold_gold_growth	dim_merchant_onboarding	BASE TABLE
8	bold_gold_growth	dim_onboarding_banking	BASE TABLE
9	bold_gold_growth	dim_onboarding_client	BASE TABLE
10	bold_gold_growth	dim_onboarding_legacy	BASE TABLE
11	bold_gold_growth	dim_onboarding_payments	BASE TABLE
12	bold_gold_growth	dim_profiling_sales_channels	BASE TABLE
13	bold_gold_growth	fact_client_economic_activity	BASE TABLE
14	bold_gold_growth	fact_onboarding	BASE TABLE
15	bold_gold_growth	fact_payment_and_recharge_transaction	BASE TABLE
16	bold_gold_growth	mart_master_client_lineage	BASE TABLE
17	bold_gold_growth	mart_master_merchant_enrich	BASE TABLE
18	bold_gold_growth	mart_master_merchant_lineage	BASE TABLE
19	bold_gold_growth	mart_merchant_enrich	BASE TABLE
20	bold_gold_growth	mart_onboarding_data_update	BASE TABLE
21	bold_gold_sales	dim_crm_services_sales_items	BASE TABLE
22	bold_gold_sales	mart_channel_attribution_onboarding	BASE TABLE
23	bold_gold_sales	mart_sales_process_summary	BASE TABLE
24	bold_gold_sales	mart_sales_process_summary_checkout	BASE TABLE
25	bold_gold_sales	mart_sales_process_summary_ecommerce	BASE TABLE
26	bold_gold_sales	mart_sales_process_summary_opportunity	BASE TABLE
27	bold_gold_sales	mart_sales_process_summary_opportunity_with_apolo_opportunity	BASE TABLE
28	bold_gold_sales	mart_sales_process_summary_opportunity_with_checkout	BASE TABLE
29	bold_gold_terminals	dim_terminal	BASE TABLE
30	bold_gold_terminals	fact_inventory_terminal_sim_cards_data_usage	BASE TABLE
31	bold_gold_terminals	fact_terminal_history	BASE TABLE
32	bold_gold_terminals	mart_terminal_enrich	BASE TABLE


-- BLOQUE 3: columnas reales para resolver el cruce y las reglas de negocio
SELECT table_schema, table_name, ordinal_position, column_name, data_type
FROM information_schema.columns
WHERE lower(table_schema) IN ('bold_gold_growth', 'bold_gold_sales', 'bold_gold_terminals', 'bold_gold_finance')
  AND (
       lower(column_name) LIKE '%merchant%'
    OR lower(column_name) LIKE '%client%'
    OR lower(column_name) LIKE '%onboard%'
    OR lower(column_name) LIKE '%terminal%'
    OR lower(column_name) LIKE '%serial%'
    OR lower(column_name) LIKE '%trans%'
    OR lower(column_name) LIKE '%tpv%'
    OR lower(column_name) LIKE '%channel%'
    OR lower(column_name) LIKE '%source%'
    OR lower(column_name) LIKE '%agent%'
    OR lower(column_name) LIKE '%executive%'
    OR lower(column_name) LIKE '%email%'
    OR lower(column_name) LIKE '%date%'
  )
ORDER BY table_schema, table_name, ordinal_position;

#	table_schema	table_name	ordinal_position	column_name	data_type
1	bold_gold_finance	fact_applied_movement	1	load_datetime	timestamp(6)
2	bold_gold_finance	fact_applied_movement	2	creation_date_key	integer
3	bold_gold_finance	fact_applied_movement	4	merchant_key	varchar
4	bold_gold_finance	fact_applied_movement	5	creation_datetime	timestamp(6)
5	bold_gold_finance	fact_applied_movement	7	transaction_id	varchar
6	bold_gold_finance	fact_applied_movement	18	merchant_id	varchar
7	bold_gold_finance	fact_applied_movement	33	source_id	varchar
8	bold_gold_finance	fact_applied_movement	39	pricing__deduction_at_source	varchar
9	bold_gold_finance	fact_applied_movement	51	pricing__processing_channel	varchar
10	bold_gold_finance	fact_applied_movement	52	source__id	varchar
11	bold_gold_finance	fact_applied_movement	53	source__installment_source_id	varchar
12	bold_gold_finance	fact_applied_movement	54	source__loan_id	varchar
13	bold_gold_finance	fact_applied_movement	57	event_datetime	timestamp(6)
14	bold_gold_finance	fact_ledger_balance_by_account	2	client_id	varchar
15	bold_gold_finance	fact_ledger_consolidated_movements	2	transaction_key	varchar
16	bold_gold_finance	fact_ledger_consolidated_movements	9	consolidated_id	varchar
17	bold_gold_finance	fact_ledger_draft_accounting_transaction_recored	2	date_key	integer
18	bold_gold_finance	fact_ledger_draft_accounting_transaction_recored	3	load_datetime	timestamp(6)
19	bold_gold_finance	fact_ledger_draft_accounting_transaction_recored	4	client_id	varchar
20	bold_gold_finance	fact_ledger_draft_accounting_transaction_recored	6	transaction_type	varchar
21	bold_gold_finance	fact_ledger_draft_accounting_transaction_recored	7	transaction_id	varchar
22	bold_gold_finance	fact_ledger_draft_accounting_transaction_recored	13	transaction_date	timestamp(6)
23	bold_gold_finance	fact_ledger_draft_accounting_transaction_recored	14	applied_date	timestamp(6)
24	bold_gold_finance	fact_ledger_historical_movements	2	date_key	integer
25	bold_gold_finance	fact_ledger_historical_movements	3	load_datetime	timestamp(6)
26	bold_gold_finance	fact_ledger_historical_movements	4	event_datetime	timestamp(6)
27	bold_gold_finance	fact_ledger_historical_movements	5	client_id	varchar
28	bold_gold_finance	fact_ledger_historical_movements	7	transaction_type	varchar
29	bold_gold_finance	fact_ledger_historical_movements	8	transaction_id	varchar
30	bold_gold_finance	fact_ledger_historical_movements	14	transaction_date	timestamp(6)
31	bold_gold_finance	fact_ledger_historical_movements	15	applied_date	timestamp(6)
32	bold_gold_finance	fact_payout	1	merchant_key	varchar
33	bold_gold_finance	fact_payout	2	creation_date	date
34	bold_gold_finance	fact_payout	3	creation_date_key	integer
35	bold_gold_finance	fact_payout	6	merchant_id	varchar
36	bold_gold_finance	fact_payout	10	bank_result_data__application_date	timestamp(6)
37	bold_gold_finance	fact_payout	20	update_date	timestamp(6)
38	bold_gold_finance	fact_payout	21	updated_by_user_id	varchar
39	bold_gold_finance	fact_payout	22	updated_by_user_email	varchar
40	bold_gold_finance	fact_payout	26	bank_result_data__transmission_date	timestamp(6)
41	bold_gold_finance	fact_payout	28	transaction_id	varchar
42	bold_gold_finance	fact_payout	35	audit_load_datetime	timestamp(6)
43	bold_gold_finance	fact_payout	36	effective_date	timestamp(6)
44	bold_gold_finance	int_base_cohortes	5	lifecycle_flag_master_merchant_general_transaccional	varchar
45	bold_gold_finance	int_base_cohortes	6	sales_source_channel_escalonado	varchar
46	bold_gold_finance	int_base_cohortes	7	dispositivo_transaccional	varchar
47	bold_gold_finance	int_base_cohortes	8	tpv	decimal(38,2)
48	bold_gold_finance	mart_tpv_daily_by_merchant	1	load_datetime	timestamp(3)
49	bold_gold_finance	mart_tpv_daily_by_merchant	2	merchant_key	varchar
50	bold_gold_finance	mart_tpv_daily_by_merchant	3	date_key	integer
51	bold_gold_finance	mart_tpv_daily_by_merchant	6	tpv	decimal(31,2)
52	bold_gold_finance	mart_tpv_daily_by_merchant	7	tpv_pagado	decimal(31,2)
53	bold_gold_finance	mart_tpv_daily_by_merchant	8	tpv_neto	decimal(31,2)
54	bold_gold_finance	mart_tpv_daily_by_merchant	13	count_transaction	bigint
55	bold_gold_finance	mart_tpv_daily_by_transaction	1	load_datetime	timestamp(6)
56	bold_gold_finance	mart_tpv_daily_by_transaction	2	date_key	integer
57	bold_gold_finance	mart_tpv_daily_by_transaction	3	creation_datetime	timestamp(6)
58	bold_gold_finance	mart_tpv_daily_by_transaction	4	transaction_id	varchar
59	bold_gold_finance	mart_tpv_daily_by_transaction	5	merchant_id	varchar
60	bold_gold_finance	mart_tpv_daily_by_transaction	6	master_merchant_id	varchar
61	bold_gold_finance	mart_tpv_daily_by_transaction	7	client_id	varchar
62	bold_gold_finance	mart_tpv_daily_by_transaction	8	tpv	decimal(38,4)
63	bold_gold_finance	mart_tpv_daily_by_transaction	9	paid_tpv	decimal(38,4)
64	bold_gold_finance	mart_tpv_daily_by_transaction	10	net_tpv	decimal(38,4)
65	bold_gold_finance	mart_tpv_daily_by_transaction	15	channel	varchar
66	bold_gold_finance	mart_tpv_daily_by_transaction	28	terminal_serial	varchar
67	bold_gold_finance	mart_tpv_daily_by_transaction	41	m_since_kyc_merchant	bigint
68	bold_gold_finance	mart_tpv_daily_by_transaction	42	m_since_1st_merchant	bigint
69	bold_gold_finance	mart_tpv_daily_by_transaction	43	m_since_1st_merchant_payment_type	bigint
70	bold_gold_finance	mart_tpv_daily_by_transaction	44	m_since_1st_merchant_model	bigint
71	bold_gold_finance	mart_tpv_daily_by_transaction	45	m_since_1st_merchant_payment_method_type	bigint
72	bold_gold_finance	mart_tpv_daily_by_transaction	46	m_since_1st_merchant_integration	bigint
73	bold_gold_finance	mart_tpv_daily_by_transaction	47	m_since_kyc_master_merchant	bigint
74	bold_gold_finance	mart_tpv_daily_by_transaction	48	m_since_1st_master_merchant	bigint
75	bold_gold_finance	mart_tpv_daily_by_transaction	49	m_since_1st_master_merchant_payment_type	bigint
76	bold_gold_finance	mart_tpv_daily_by_transaction	50	m_since_1st_master_merchant_model	bigint
77	bold_gold_finance	mart_tpv_daily_by_transaction	51	m_since_1st_master_merchant_payment_method_type	bigint
78	bold_gold_finance	mart_tpv_daily_by_transaction	52	m_since_1st_master_merchant_merchant_integration	bigint
79	bold_gold_finance	mart_tpv_daily_by_transaction	53	m_since_kyc_general_client	bigint
80	bold_gold_finance	mart_tpv_daily_by_transaction	54	m_since_kyc_payments_client	bigint
81	bold_gold_finance	mart_tpv_daily_by_transaction	55	m_since_1st_transaction_payments_client	bigint
82	bold_gold_finance	mart_tpv_daily_by_transaction	56	m_since_1st_client_payment_type	bigint
83	bold_gold_finance	mart_tpv_daily_by_transaction	57	m_since_1st_client_model	bigint
84	bold_gold_finance	mart_tpv_daily_by_transaction	58	m_since_1st_client_payment_method_type	bigint
85	bold_gold_finance	mart_tpv_daily_by_transaction	59	m_since_1st_client_integration	bigint
86	bold_gold_finance	mart_tpv_daily_by_transaction	66	merchant_country_code	varchar
87	bold_gold_finance	mart_tpv_daily_by_transaction	73	tpv_usd	decimal(19,3)
88	bold_gold_finance	mart_tpv_daily_by_transaction_global	1	load_datetime	timestamp(6)
89	bold_gold_finance	mart_tpv_daily_by_transaction_global	2	client_id	varchar
90	bold_gold_finance	mart_tpv_daily_by_transaction_global	3	merchant_id	varchar
91	bold_gold_finance	mart_tpv_daily_by_transaction_global	4	transaction_id	varchar
92	bold_gold_finance	mart_tpv_daily_by_transaction_global	5	creation_datetime_local	timestamp(6)
93	bold_gold_finance	mart_tpv_daily_by_transaction_global	6	tpv_local	decimal(18,2)
94	bold_gold_finance	mart_tpv_daily_by_transaction_global	9	terminal_serial	varchar
95	bold_gold_finance	mart_tpv_daily_by_transaction_global	11	channel	varchar
96	bold_gold_finance	mart_tpv_daily_by_transaction_global	13	transaction_source	varchar
97	bold_gold_finance	mart_tpv_daily_by_transaction_global	16	merchant_country_code	varchar
98	bold_gold_finance	report_neogrid_payment_proofs	11	tipo_documento cliente	varchar
99	bold_gold_finance	report_neogrid_payment_proofs_invalid_data	3	event_datetime	timestamp(3)
100	bold_gold_finance	report_neogrid_payment_proofs_invalid_data	4	load_datetime	timestamp(3)


-- BLOQUE 4: comprobar tablas ya usadas en consultas documentadas
SELECT expected.table_schema, expected.table_name,
       CASE WHEN actual.table_name IS NULL THEN 'NO_ENCONTRADA' ELSE 'ENCONTRADA' END AS estado
FROM (
    VALUES
      ('bold_gold_growth', 'dim_client'),
      ('bold_gold_growth', 'dim_merchant_onboarding'),
      ('bold_gold_growth', 'mart_merchant_enrich'),
      ('bold_gold_growth', 'mart_master_merchant_enrich'),
      ('bold_gold_growth', 'mart_tpv_daily_by_merchant'),
      ('bold_gold_growth', 'mart_tpv_daily_by_transaction'),
      ('bold_gold_terminals', 'dim_terminal'),
      ('bold_gold_terminals', 'fact_terminal_history'),
      ('bold_gold_terminals', 'mart_terminal_enrich'),
      ('bold_gold_sales', 'dim_crm_opportunities'),
      ('bold_gold_sales', 'dim_crm_users'),
      ('bold_gold_sales', 'dim_user_bamboo_information')
) AS expected(table_schema, table_name)
LEFT JOIN information_schema.tables actual
  ON actual.table_schema = expected.table_schema
 AND actual.table_name = expected.table_name
ORDER BY expected.table_schema, expected.table_name;


#	table_schema	table_name	estado
1	bold_gold_growth	dim_client	ENCONTRADA
2	bold_gold_growth	dim_merchant_onboarding	ENCONTRADA
3	bold_gold_growth	mart_master_merchant_enrich	ENCONTRADA
4	bold_gold_growth	mart_merchant_enrich	ENCONTRADA
5	bold_gold_growth	mart_tpv_daily_by_merchant	NO_ENCONTRADA
6	bold_gold_growth	mart_tpv_daily_by_transaction	NO_ENCONTRADA
7	bold_gold_sales	dim_crm_opportunities	ENCONTRADA
8	bold_gold_sales	dim_crm_users	ENCONTRADA
9	bold_gold_sales	dim_user_bamboo_information	ENCONTRADA
10	bold_gold_terminals	dim_terminal	ENCONTRADA
11	bold_gold_terminals	fact_terminal_history	ENCONTRADA
12	bold_gold_terminals	mart_terminal_enrich	ENCONTRADA




-- BLOQUE 5: localizar si existe una tabla de carga/lista mensual ya creada.
-- Se busca por nombre; no se asume que exista.
SELECT table_schema, table_name, table_type
FROM information_schema.tables
WHERE lower(table_name) LIKE '%coopic%'
   OR lower(table_name) LIKE '%drog%'
   OR lower(table_name) LIKE '%vinculad%'
   OR lower(table_name) LIKE '%solicitud%'
   OR lower(table_name) LIKE '%cambio%canal%'
   OR lower(table_name) LIKE '%input%merchant%'
ORDER BY table_schema, table_name;


#	table_schema	table_name	table_type
1	bold_gold_regulatory_reports	report_sireg_ilbase_tbl_solicitud_credito	BASE TABLE
2	bold_gold_regulatory_reports	report_sireg_ilbase_tbl_solicitud_credito_v2	BASE TABLE


-- BLOQUE 6: validación posterior (rellenar SOLO con una tabla encontrada en BLOQUE 5)
-- SELECT * FROM <tabla_real_encontrada> LIMIT 20;
