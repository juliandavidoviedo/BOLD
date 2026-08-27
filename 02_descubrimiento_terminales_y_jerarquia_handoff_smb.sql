-- -------------------------------------------------------------------------
-- BLOQUE 1: tablas candidatas en bold_gold_terminals
-- -------------------------------------------------------------------------
SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'bold_gold_terminals'
  AND (
      lower(table_name) LIKE '%terminal%'
      OR lower(table_name) LIKE '%device%'
      OR lower(table_name) LIKE '%serial%'
      OR lower(table_name) LIKE '%merchant%'
      OR lower(table_name) LIKE '%assignment%'
      OR lower(table_name) LIKE '%history%'
      OR lower(table_name) LIKE '%enrich%'
  )
ORDER BY table_name;

#	table_schema	table_name	table_type
1	bold_gold_terminals	dim_terminal	BASE TABLE
2	bold_gold_terminals	fact_inventory_terminal_sim_cards_data_usage	BASE TABLE
3	bold_gold_terminals	fact_terminal_history	BASE TABLE
4	bold_gold_terminals	mart_terminal_enrich	BASE TABLE


-- -------------------------------------------------------------------------
-- BLOQUE 2: columnas candidatas en bold_gold_terminals
-- -------------------------------------------------------------------------
SELECT
    table_schema,
    table_name,
    column_name,
    data_type,
    ordinal_position,
    CASE
        WHEN lower(column_name) IN ('merchant_id', 'master_merchant_id') THEN 'llave_merchant'
        WHEN lower(column_name) LIKE '%terminal%' THEN 'terminal'
        WHEN lower(column_name) LIKE '%serial%' THEN 'serial'
        WHEN lower(column_name) LIKE '%device%' THEN 'device'
        WHEN lower(column_name) LIKE '%status%' OR lower(column_name) LIKE '%state%' THEN 'estado_terminal'
        WHEN lower(column_name) LIKE '%model%' THEN 'modelo_terminal'
        WHEN lower(column_name) LIKE '%updated%' OR lower(column_name) LIKE '%created%' OR lower(column_name) LIKE '%date%' THEN 'fecha_frescura'
        ELSE 'otro'
    END AS concepto_sugerido
FROM information_schema.columns
WHERE table_schema = 'bold_gold_terminals'
  AND (
      lower(column_name) LIKE '%merchant%'
      OR lower(column_name) LIKE '%terminal%'
      OR lower(column_name) LIKE '%serial%'
      OR lower(column_name) LIKE '%device%'
      OR lower(column_name) LIKE '%status%'
      OR lower(column_name) LIKE '%state%'
      OR lower(column_name) LIKE '%model%'
      OR lower(column_name) LIKE '%updated%'
      OR lower(column_name) LIKE '%created%'
      OR lower(column_name) LIKE '%date%'
  )
ORDER BY table_name, concepto_sugerido, ordinal_position;

#	table_schema	table_name	column_name	data_type	ordinal_position	concepto_sugerido
1	bold_gold_terminals	dim_terminal	business_datetime	timestamp(3)	3	fecha_frescura
2	bold_gold_terminals	dim_terminal	last_modification_date_ns	bigint	14	fecha_frescura
3	bold_gold_terminals	dim_terminal	last_modification_datetime	timestamp(3)	15	fecha_frescura
4	bold_gold_terminals	dim_terminal	creation_date_ns	bigint	16	fecha_frescura
5	bold_gold_terminals	dim_terminal	creation_datetime	timestamp(3)	17	fecha_frescura
6	bold_gold_terminals	dim_terminal	need_emv_update	boolean	20	fecha_frescura
7	bold_gold_terminals	dim_terminal	need_firmware_update	boolean	22	fecha_frescura
8	bold_gold_terminals	dim_terminal	current_merchant_id	varchar	18	otro
9	bold_gold_terminals	dim_terminal	previous_merchant_id	varchar	24	otro
10	bold_gold_terminals	dim_terminal	terminal_id	varchar	1	terminal
11	bold_gold_terminals	dim_terminal	terminal_status	varchar	2	terminal
12	bold_gold_terminals	dim_terminal	terminal_event	varchar	7	terminal
13	bold_gold_terminals	dim_terminal	terminal_model	varchar	12	terminal
14	bold_gold_terminals	dim_terminal	terminal_serial	varchar	13	terminal
15	bold_gold_terminals	fact_inventory_terminal_sim_cards_data_usage	terminal_sim_card_installed_at	timestamp(3)	2	terminal
16	bold_gold_terminals	fact_inventory_terminal_sim_cards_data_usage	terminal_sim_card_installed_at_timestamp	bigint	3	terminal
17	bold_gold_terminals	fact_inventory_terminal_sim_cards_data_usage	terminal_sim_card_installation_period	timestamp(3)	4	terminal
18	bold_gold_terminals	fact_inventory_terminal_sim_cards_data_usage	terminal_id	varchar	5	terminal
19	bold_gold_terminals	fact_inventory_terminal_sim_cards_data_usage	terminal_model	varchar	6	terminal
20	bold_gold_terminals	fact_inventory_terminal_sim_cards_data_usage	terminal_serial	varchar	7	terminal
21	bold_gold_terminals	fact_inventory_terminal_sim_cards_data_usage	terminal_icc_id	varchar	8	terminal
22	bold_gold_terminals	fact_inventory_terminal_sim_cards_data_usage	terminal_mcc	varchar	9	terminal
23	bold_gold_terminals	fact_inventory_terminal_sim_cards_data_usage	terminal_mnc	varchar	10	terminal
24	bold_gold_terminals	fact_sim_cards_consumption	business_datetime	timestamp(3)	1	fecha_frescura
25	bold_gold_terminals	fact_sim_cards_consumption	load_datetime	timestamp(3)	5	fecha_frescura
26	bold_gold_terminals	fact_terminal_history	business_datetime	timestamp(3)	1	fecha_frescura
27	bold_gold_terminals	fact_terminal_history	event_datetime	timestamp(3)	2	fecha_frescura
28	bold_gold_terminals	fact_terminal_history	last_modification_date_ns	bigint	14	fecha_frescura
29	bold_gold_terminals	fact_terminal_history	last_modification_datetime	timestamp(3)	15	fecha_frescura
30	bold_gold_terminals	fact_terminal_history	creation_date_ns	bigint	17	fecha_frescura
31	bold_gold_terminals	fact_terminal_history	creation_datetime	timestamp(3)	18	fecha_frescura
32	bold_gold_terminals	fact_terminal_history	need_emv_update	boolean	21	fecha_frescura
33	bold_gold_terminals	fact_terminal_history	need_firmware_update	boolean	23	fecha_frescura
34	bold_gold_terminals	fact_terminal_history	current_merchant_id	varchar	19	otro
35	bold_gold_terminals	fact_terminal_history	previous_merchant_id	varchar	25	otro
36	bold_gold_terminals	fact_terminal_history	terminal_event	varchar	6	terminal
37	bold_gold_terminals	fact_terminal_history	terminal_id	varchar	10	terminal
38	bold_gold_terminals	fact_terminal_history	terminal_model	varchar	12	terminal
39	bold_gold_terminals	fact_terminal_history	terminal_serial	varchar	13	terminal
40	bold_gold_terminals	fact_terminal_history	terminal_status	varchar	16	terminal
41	bold_gold_terminals	mart_terminal_enrich	_1st_merchant_match_status	varchar	11	estado_terminal
42	bold_gold_terminals	mart_terminal_enrich	last_merchant_match_status	varchar	16	estado_terminal
43	bold_gold_terminals	mart_terminal_enrich	load_datetime	timestamp(6)	1	fecha_frescura
44	bold_gold_terminals	mart_terminal_enrich	_1st_match_date	timestamp(6)	8	fecha_frescura
45	bold_gold_terminals	mart_terminal_enrich	_1st_match_date_current_merchant	timestamp(6)	22	fecha_frescura
46	bold_gold_terminals	mart_terminal_enrich	_1st_transaction_approved_date	timestamp(6)	24	fecha_frescura
47	bold_gold_terminals	mart_terminal_enrich	last_transaction_approved_date	timestamp(6)	25	fecha_frescura
48	bold_gold_terminals	mart_terminal_enrich	delivered_date	timestamp(6)	36	fecha_frescura
49	bold_gold_terminals	mart_terminal_enrich	purchase_date	timestamp(6)	39	fecha_frescura
50	bold_gold_terminals	mart_terminal_enrich	model_name_category	varchar	7	modelo_terminal
51	bold_gold_terminals	mart_terminal_enrich	_1st_merchant_matched	varchar	9	otro
52	bold_gold_terminals	mart_terminal_enrich	_1st_merchant_match_document	varchar	10	otro
53	bold_gold_terminals	mart_terminal_enrich	last_merchant_match_document	varchar	15	otro
54	bold_gold_terminals	mart_terminal_enrich	current_merchant_matched	varchar	21	otro
55	bold_gold_terminals	mart_terminal_enrich	merchant_who_made_1st_transaction	varchar	23	otro
56	bold_gold_terminals	mart_terminal_enrich	merchant_id_purchase	varchar	44	otro
57	bold_gold_terminals	mart_terminal_enrich	terminal_key	varchar	2	terminal
58	bold_gold_terminals	mart_terminal_enrich	terminal_serial	varchar	3	terminal
59	bold_gold_terminals	mart_terminal_enrich	current_terminal_status	varchar	4	terminal
60	bold_gold_terminals	mart_terminal_enrich	terminal_model	varchar	5	terminal
61	bold_gold_terminals	mart_terminal_enrich	_1st_terminal_match_client_id	varchar	12	terminal
62	bold_gold_terminals	mart_terminal_enrich	last_terminal_match_date	timestamp(6)	13	terminal
63	bold_gold_terminals	mart_terminal_enrich	last_terminal_match_merchant_id	varchar	14	terminal
64	bold_gold_terminals	mart_terminal_enrich	last_terminal_match_client_id	varchar	17	terminal
65	bold_gold_terminals	mart_terminal_enrich	count_distinct_merchant_terminal_matches	bigint	18	terminal
66	bold_gold_terminals	mart_terminal_enrich	count_distinct_client_terminal_matches	bigint	19	terminal
67	bold_gold_terminals	mart_terminal_enrich	total_terminal_matches	bigint	20	terminal
68	bold_gold_terminals	mart_terminal_enrich	tpv_m0_since_terminal_activation	decimal(38,4)	30	terminal
69	bold_gold_terminals	mart_terminal_enrich	tpv_m1_since_terminal_activation	decimal(38,4)	31	terminal
70	bold_gold_terminals	mart_terminal_enrich	tpv_m2_since_terminal_activation	decimal(38,4)	32	terminal
71	bold_gold_terminals	mart_terminal_enrich	terminal_sales_source	varchar	40	terminal
72	bold_gold_terminals	mart_terminal_enrich	terminal_sales_executive	varchar	41	terminal
73	bold_gold_terminals	mart_terminal_enrich	terminal_price	decimal(18,2)	42	terminal




-- -------------------------------------------------------------------------
-- BLOQUE 3: buscar tablas de jerarquia comercial en schemas growth
-- -------------------------------------------------------------------------
SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema IN (
    'bold_gold_growth',
    'bold_gold_growth_accounting'
)
  AND (
      lower(table_name) LIKE '%sales%'
      OR lower(table_name) LIKE '%commercial%'
      OR lower(table_name) LIKE '%agent%'
      OR lower(table_name) LIKE '%team%'
      OR lower(table_name) LIKE '%lead%'
      OR lower(table_name) LIKE '%manager%'
      OR lower(table_name) LIKE '%assignment%'
      OR lower(table_name) LIKE '%kam%'
      OR lower(table_name) LIKE '%smb%'
  )
ORDER BY table_schema, table_name;

#	table_schema	table_name	table_type
1	bold_gold_growth	dim_profiling_sales_channels	BASE TABLE



-- -------------------------------------------------------------------------
-- BLOQUE 4: columnas candidatas de jerarquia comercial
-- -------------------------------------------------------------------------
SELECT
    table_schema,
    table_name,
    column_name,
    data_type,
    ordinal_position,
    CASE
        WHEN lower(column_name) IN ('merchant_id', 'master_merchant_id') THEN 'llave_merchant'
        WHEN lower(column_name) LIKE '%sales%agent%email%' THEN 'sales_agent_email'
        WHEN lower(column_name) LIKE '%agent%' THEN 'agent'
        WHEN lower(column_name) LIKE '%team%lead%' OR lower(column_name) LIKE '%tl%' THEN 'team_lead'
        WHEN lower(column_name) LIKE '%manager%' THEN 'manager'
        WHEN lower(column_name) LIKE '%kam%' THEN 'kam'
        WHEN lower(column_name) LIKE '%updated%' OR lower(column_name) LIKE '%created%' OR lower(column_name) LIKE '%date%' THEN 'fecha_frescura'
        ELSE 'otro'
    END AS concepto_sugerido
FROM information_schema.columns
WHERE table_schema IN (
    'bold_gold_growth',
    'bold_gold_growth_accounting'
)
  AND (
      lower(column_name) LIKE '%merchant%'
      OR lower(column_name) LIKE '%sales%'
      OR lower(column_name) LIKE '%agent%'
      OR lower(column_name) LIKE '%team%'
      OR lower(column_name) LIKE '%lead%'
      OR lower(column_name) LIKE '%tl%'
      OR lower(column_name) LIKE '%manager%'
      OR lower(column_name) LIKE '%kam%'
      OR lower(column_name) LIKE '%updated%'
      OR lower(column_name) LIKE '%created%'
      OR lower(column_name) LIKE '%date%'
  )
ORDER BY table_schema, table_name, concepto_sugerido, ordinal_position;

#	table_schema	table_name	column_name	data_type	ordinal_position	concepto_sugerido
1	bold_gold_growth	dim_client	last_update_event_date	timestamp(3)	8	fecha_frescura
2	bold_gold_growth	dim_client	creation_date	timestamp(3)	13	fecha_frescura
3	bold_gold_growth	dim_client	onboarding_completion_date	timestamp(3)	16	fecha_frescura
4	bold_gold_growth	dim_client	risk_assessment_last_recalculated_date	timestamp(3)	26	fecha_frescura
5	bold_gold_growth	dim_client	birth_information_date	timestamp(3)	27	fecha_frescura
6	bold_gold_growth	dim_client	tac_signing_date	timestamp(3)	38	fecha_frescura
7	bold_gold_growth	dim_client	tac_acceptance_date	timestamp(3)	40	fecha_frescura
8	bold_gold_growth	dim_client	migration_end_date	timestamp(3)	43	fecha_frescura
9	bold_gold_growth	dim_client	commercial_activity_start_date	timestamp(3)	59	fecha_frescura
10	bold_gold_growth	dim_client	kyc_registry_date	varchar	66	fecha_frescura
11	bold_gold_growth	dim_client	last_update_event	varchar	69	fecha_frescura
12	bold_gold_growth	dim_client	merchant_id	varchar	46	llave_merchant
13	bold_gold_growth	dim_client	sales_source	varchar	5	otro
14	bold_gold_growth	dim_client	migration_merchants	varchar	42	otro
15	bold_gold_growth	dim_client	merchant_name	varchar	44	otro
16	bold_gold_growth	dim_client	merchant_person_type	varchar	45	otro
17	bold_gold_growth	dim_client	merchant_acquisition_channel_extra_reference	varchar	47	otro
18	bold_gold_growth	dim_client	merchant_acquisition_channel_referred_by	varchar	48	otro
19	bold_gold_growth	dim_client	merchant_acquisition_channel_source	varchar	50	otro
20	bold_gold_growth	dim_client	merchant_acquisition_channel_value	varchar	51	otro
21	bold_gold_growth	dim_client	merchant_identification_document_type	varchar	52	otro
22	bold_gold_growth	dim_client	merchant_identification_document_number	varchar	53	otro
23	bold_gold_growth	dim_client	merchant_identification_document_verification_digit	varchar	54	otro
24	bold_gold_growth	dim_client	merchant_acquisition_channel_sales_agent_email	varchar	49	sales_agent_email
25	bold_gold_growth	dim_client_georeference	date_key	integer	1	fecha_frescura
26	bold_gold_growth	dim_client_georeference	load_datetime	timestamp(6)	39	fecha_frescura
27	bold_gold_growth	dim_client_georeference	merchant_id	varchar	4	llave_merchant
28	bold_gold_growth	dim_coverage_zones	date_key	integer	1	fecha_frescura
29	bold_gold_growth	dim_coverage_zones	load_datetime	timestamp(3)	15	fecha_frescura
30	bold_gold_growth	dim_merchant_onboarding	acquisition_channel_sales_agent_code	varchar	35	agent
31	bold_gold_growth	dim_merchant_onboarding	onboarding_completion_date	timestamp(3)	4	fecha_frescura
32	bold_gold_growth	dim_merchant_onboarding	onboarding_completed_date	timestamp(3)	54	fecha_frescura
33	bold_gold_growth	dim_merchant_onboarding	merchant_id	varchar	5	llave_merchant
34	bold_gold_growth	dim_merchant_onboarding	merchant_key	varchar	2	otro
35	bold_gold_growth	dim_merchant_onboarding	acquisition_channel_sales_agent_email	varchar	33	sales_agent_email
36	bold_gold_growth	dim_onboarding_banking	event_datetime	timestamp(3)	6	fecha_frescura
37	bold_gold_growth	dim_onboarding_banking	load_datetime	timestamp(3)	8	fecha_frescura
38	bold_gold_growth	dim_onboarding_banking	creation_date	timestamp(3)	14	fecha_frescura
39	bold_gold_growth	dim_onboarding_banking	completion_date	timestamp(3)	15	fecha_frescura
40	bold_gold_growth	dim_onboarding_banking	last_update_date	timestamp(3)	16	fecha_frescura
41	bold_gold_growth	dim_onboarding_banking	merchants_pricing_plans	varchar	25	otro
42	bold_gold_growth	dim_onboarding_client	acquisition_channel_sales_agent_code	varchar	30	agent
43	bold_gold_growth	dim_onboarding_client	event_datetime	timestamp(3)	7	fecha_frescura
44	bold_gold_growth	dim_onboarding_client	load_datetime	timestamp(3)	9	fecha_frescura
45	bold_gold_growth	dim_onboarding_client	creation_date	timestamp(3)	15	fecha_frescura
46	bold_gold_growth	dim_onboarding_client	completion_date	timestamp(3)	16	fecha_frescura
47	bold_gold_growth	dim_onboarding_client	last_update_date	timestamp(3)	17	fecha_frescura
48	bold_gold_growth	dim_onboarding_client	acquisition_channel_sales_agent_email	varchar	28	sales_agent_email
49	bold_gold_growth	dim_onboarding_legacy	load_datetime	timestamp(3)	2	fecha_frescura
50	bold_gold_growth	dim_onboarding_legacy	onboarding_end_date	timestamp(3)	11	fecha_frescura
51	bold_gold_growth	dim_onboarding_legacy	creation_date	timestamp(3)	12	fecha_frescura
52	bold_gold_growth	dim_onboarding_legacy	is_created_from_mlp	boolean	18	fecha_frescura
53	bold_gold_growth	dim_onboarding_legacy	update_reason	varchar	25	fecha_frescura
54	bold_gold_growth	dim_onboarding_legacy	updated_by_user_email	varchar	26	fecha_frescura
55	bold_gold_growth	dim_onboarding_legacy	updated_by_user_id	varchar	27	fecha_frescura
56	bold_gold_growth	dim_onboarding_legacy	updated_date	varchar	28	fecha_frescura
57	bold_gold_growth	dim_onboarding_legacy	merchant_id	varchar	7	llave_merchant
58	bold_gold_growth	dim_onboarding_legacy	merchant_key	varchar	3	otro
59	bold_gold_growth	dim_onboarding_payments	acquisition_channel_sales_agent_code	varchar	32	agent
60	bold_gold_growth	dim_onboarding_payments	event_datetime	timestamp(3)	8	fecha_frescura
61	bold_gold_growth	dim_onboarding_payments	load_datetime	timestamp(3)	10	fecha_frescura
62	bold_gold_growth	dim_onboarding_payments	creation_date	timestamp(3)	16	fecha_frescura
63	bold_gold_growth	dim_onboarding_payments	completion_date	timestamp(3)	17	fecha_frescura
64	bold_gold_growth	dim_onboarding_payments	last_update_date	timestamp(3)	18	fecha_frescura
65	bold_gold_growth	dim_onboarding_payments	onboarding_approved_date	timestamp(3)	27	fecha_frescura
66	bold_gold_growth	dim_onboarding_payments	merchant_id	varchar	25	llave_merchant
67	bold_gold_growth	dim_onboarding_payments	merchant_key	varchar	4	otro
68	bold_gold_growth	dim_onboarding_payments	merchants_pricing_plans	varchar	26	otro
69	bold_gold_growth	dim_onboarding_payments	merchants_pricing_plan_bundle_id	varchar	46	otro
70	bold_gold_growth	dim_onboarding_payments	merchants_pricing_plan_id	varchar	47	otro
71	bold_gold_growth	dim_onboarding_payments	merchants_pricing_plan_profile_id	varchar	48	otro
72	bold_gold_growth	dim_onboarding_payments	merchants_pricing_plan_product_id	varchar	49	otro
73	bold_gold_growth	dim_onboarding_payments	merchants_pricing_plan_tag_name	varchar	50	otro
74	bold_gold_growth	dim_onboarding_payments	team_members	array(varchar)	51	otro
75	bold_gold_growth	dim_onboarding_payments	acquisition_channel_sales_agent_email	varchar	30	sales_agent_email
76	bold_gold_growth	dim_person	business_datetime	timestamp(3)	4	fecha_frescura
77	bold_gold_growth	dim_person	event_datetime	timestamp(3)	5	fecha_frescura
78	bold_gold_growth	dim_person	terms_and_conditions__acceptance_date	timestamp(3)	7	fecha_frescura
79	bold_gold_growth	dim_person	load_datetime	timestamp(3)	9	fecha_frescura
80	bold_gold_growth	dim_person	update_reason	varchar	22	fecha_frescura
81	bold_gold_growth	dim_person	updated_by_user_email	varchar	23	fecha_frescura
82	bold_gold_growth	dim_person	updated_by_user_id	varchar	24	fecha_frescura
83	bold_gold_growth	dim_person	merchant_id	varchar	10	llave_merchant
84	bold_gold_growth	dim_person_v2	business_datetime	timestamp(6)	3	fecha_frescura
85	bold_gold_growth	dim_person_v2	event_datetime	timestamp(6)	4	fecha_frescura
86	bold_gold_growth	dim_person_v2	terms_and_conditions__acceptance_date	timestamp(6)	6	fecha_frescura
87	bold_gold_growth	dim_person_v2	load_datetime	timestamp(6)	8	fecha_frescura
88	bold_gold_growth	dim_person_v2	update_reason	varchar	21	fecha_frescura
89	bold_gold_growth	dim_person_v2	updated_by_user_email	varchar	22	fecha_frescura
90	bold_gold_growth	dim_person_v2	updated_by_user_id	varchar	23	fecha_frescura
91	bold_gold_growth	dim_person_v2	merchant_id	varchar	9	llave_merchant
92	bold_gold_growth	dim_product	event_datetime	timestamp(3)	6	fecha_frescura
93	bold_gold_growth	dim_product	pricing__updated_event_count	bigint	7	fecha_frescura
94	bold_gold_growth	dim_product	merchant_id	varchar	10	llave_merchant
95	bold_gold_growth	dim_product	merchant_key	varchar	2	otro
96	bold_gold_growth	dim_profiling_sales_channels	sales_channel	varchar	1	otro
97	bold_gold_growth	dim_referral_reward	creation_date	timestamp(3)	5	fecha_frescura
98	bold_gold_growth	dim_referral_reward	completion_date	timestamp(3)	12	fecha_frescura
99	bold_gold_growth	fact_client_economic_activity	kyc_registry_date	varchar	11	fecha_frescura
100	bold_gold_growth	fact_lifecycle_profiling_record	creation_date	timestamp(3)	5	fecha_frescura
