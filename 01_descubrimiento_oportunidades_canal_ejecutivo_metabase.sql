SELECT
    CASE
        WHEN lower(c.table_name) LIKE '%opportun%' THEN 'OPORTUNIDAD'
        WHEN lower(c.table_name) LIKE '%lead%' THEN 'LEAD'
        WHEN lower(c.table_name) LIKE '%user%' OR lower(c.table_name) LIKE '%bamboo%' THEN 'JERARQUIA_EJECUTIVO'
        WHEN lower(c.table_name) LIKE '%attribution%' THEN 'ATRIBUCION'
        ELSE 'OTRO'
    END AS familia,
    c.table_schema,
    c.table_name,
    c.ordinal_position,
    c.column_name,
    c.data_type,
    CASE
        WHEN lower(c.column_name) IN ('product_merchant_id', 'metadata_merchant_id', 'merchant_id') THEN 'LLAVE_MERCHANT'
        WHEN lower(c.column_name) IN ('metadata_client_id', 'client_id') THEN 'LLAVE_CLIENTE'
        WHEN lower(c.column_name) IN ('opportunity_id', 'lead_id', 'merchant_contact_id') THEN 'LLAVE_OPORTUNIDAD'
        WHEN lower(c.column_name) IN ('sales_channel', 'origin_name', 'origin_description') THEN 'CANAL_ORIGEN_OPORTUNIDAD'
        WHEN lower(c.column_name) LIKE '%executive%' OR lower(c.column_name) LIKE '%owner%' OR lower(c.column_name) LIKE '%user_id%' THEN 'RESPONSABLE'
        WHEN lower(c.column_name) LIKE '%creation%' OR lower(c.column_name) LIKE '%activation%' OR lower(c.column_name) LIKE '%won_date%' OR lower(c.column_name) LIKE '%assignment%' THEN 'FECHA_GESTION'
        WHEN lower(c.column_name) IN ('status', 'opportunity_status', 'lost_status', 'discard_category') THEN 'ESTADO_OPORTUNIDAD'
        WHEN lower(c.column_name) IN ('opportunity_type', 'management_type', 'is_terminal_reassignment', 'previous_user') THEN 'TIPO_GESTION'
        WHEN lower(c.column_name) IN ('email', 'parent_id', 'role', 'status', 'sales_channel') THEN 'JERARQUIA'
        ELSE 'OTRO'
    END AS uso_sugerido
FROM information_schema.columns c
WHERE c.table_schema IN ('bold_gold_sales', 'bold_gold_growth', 'bold_gold_terminals')
  AND (
        lower(c.table_name) LIKE '%opportun%'
     OR lower(c.table_name) LIKE '%lead%'
     OR lower(c.table_name) LIKE '%user%'
     OR lower(c.table_name) LIKE '%bamboo%'
     OR lower(c.table_name) LIKE '%attribution%'
     OR lower(c.table_name) LIKE '%assignment%'
  )
  AND lower(c.column_name) NOT LIKE '%token%'
  AND lower(c.column_name) NOT LIKE '%secret%'
  AND lower(c.column_name) NOT LIKE '%password%'
ORDER BY familia, c.table_schema, c.table_name, c.ordinal_position




---resultado 
#	familia	table_schema	table_name	ordinal_position	column_name	data_type	uso_sugerido
1	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	1	idempotency_hash	varchar	OTRO
2	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	2	load_datetime	timestamp(6)	OTRO
3	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	3	document_type	varchar	OTRO
4	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	4	document_number	varchar	OTRO
5	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	5	client_id	varchar	LLAVE_CLIENTE
6	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	6	event	varchar	OTRO
7	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	7	event_datetime	timestamp(6)	OTRO
8	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	8	commercial_origin	varchar	OTRO
9	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	9	commercial_origin_description	varchar	OTRO
10	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	10	utm_source_digital	varchar	OTRO
11	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	11	utm_medium_digital	varchar	OTRO
12	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	12	utm_type_digital	varchar	OTRO
13	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	13	utm_content_digital	varchar	OTRO
14	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	14	utm_campaign_digital	varchar	OTRO
15	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	15	sales_source_init	varchar	OTRO
16	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	16	advisor_code	varchar	OTRO
17	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	17	sales_executive	varchar	RESPONSABLE
18	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	18	sales_source_last	varchar	OTRO
19	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	19	is_open_reassignment	varchar	FECHA_GESTION
20	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	20	product_vertical	varchar	OTRO
21	ATRIBUCION	bold_gold_sales	mart_channel_attribution_onboarding	21	product	varchar	OTRO
22	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_crm_users	1	event_timestamp	bigint	OTRO
23	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_crm_users	2	load_datetime	timestamp(3)	OTRO
24	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_crm_users	3	user_id	varchar	RESPONSABLE
25	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_crm_users	4	company	varchar	OTRO
26	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_crm_users	5	email	varchar	JERARQUIA
27	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_crm_users	6	parent_id	varchar	JERARQUIA
28	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_crm_users	7	role	varchar	JERARQUIA
29	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_crm_users	8	sales_channel	varchar	CANAL_ORIGEN_OPORTUNIDAD
30	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_crm_users	9	status	varchar	ESTADO_OPORTUNIDAD
31	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_crm_users	10	country_code	varchar	OTRO
32	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_crm_users	11	metadata	varchar	OTRO
33	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_crm_users	12	parent_previous_id	varchar	OTRO
34	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_crm_users	13	event_partition	integer	OTRO
35	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	1	user_id	varchar	RESPONSABLE
36	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	2	reports_to	varchar	OTRO
37	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	3	supervisor_id	varchar	OTRO
38	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	4	city	varchar	OTRO
39	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	5	region	varchar	OTRO
40	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	6	hub_custom_id	varchar	OTRO
41	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	7	hub_name	varchar	OTRO
42	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	8	job_title	varchar	OTRO
43	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	9	channel	varchar	OTRO
44	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	10	status	varchar	ESTADO_OPORTUNIDAD
45	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	11	vinculation_status	varchar	OTRO
46	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	12	division	varchar	OTRO
47	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	13	career_level	varchar	OTRO
48	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	14	is_temporary_position	varchar	OTRO
49	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	15	new_position	varchar	OTRO
50	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	16	is_double_position	varchar	OTRO
51	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	17	length_of_service	varchar	OTRO
52	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	18	hire_date	date	OTRO
53	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	19	start_date	date	OTRO
54	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	20	end_date	date	OTRO
55	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	21	retirement_date	date	OTRO
56	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	22	custom_date	date	OTRO
57	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	23	squad	varchar	OTRO
58	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	24	cost_center	varchar	OTRO
59	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	25	retirement_type	varchar	OTRO
60	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	26	termination_date	date	OTRO
61	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	27	termination_reason	varchar	OTRO
62	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	28	event_timestamp	bigint	OTRO
63	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	29	event_datetime	timestamp(6)	OTRO
64	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information	30	load_datetime	timestamp(6)	OTRO
65	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	1	user_id	varchar	RESPONSABLE
66	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	2	reports_to	varchar	OTRO
67	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	3	supervisor_id	varchar	OTRO
68	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	4	city	varchar	OTRO
69	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	5	region	varchar	OTRO
70	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	6	hub_custom_id	varchar	OTRO
71	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	7	hub_name	varchar	OTRO
72	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	8	job_title	varchar	OTRO
73	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	9	channel	varchar	OTRO
74	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	10	status	varchar	ESTADO_OPORTUNIDAD
75	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	11	vinculation_status	varchar	OTRO
76	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	12	division	varchar	OTRO
77	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	13	career_level	varchar	OTRO
78	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	14	is_temporary_position	varchar	OTRO
79	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	15	new_position	varchar	OTRO
80	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	16	is_double_position	varchar	OTRO
81	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	17	length_of_service	varchar	OTRO
82	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	18	hire_date	date	OTRO
83	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	19	start_date	date	OTRO
84	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	20	end_date	date	OTRO
85	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	21	retirement_date	date	OTRO
86	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	22	custom_date	date	OTRO
87	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	23	squad	varchar	OTRO
88	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	24	cost_center	varchar	OTRO
89	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	25	retirement_type	varchar	OTRO
90	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	26	termination_date	date	OTRO
91	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	27	termination_reason	varchar	OTRO
92	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	28	bamboo_information_hash	varchar	OTRO
93	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	29	event_timestamp	bigint	OTRO
94	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	30	event_datetime	timestamp(6)	OTRO
95	JERARQUIA_EJECUTIVO	bold_gold_sales	dim_user_bamboo_information_history	31	load_datetime	timestamp(6)	OTRO
96	LEAD	bold_gold_sales	dim_crm_leads	1	lead_id	varchar	LLAVE_OPORTUNIDAD
97	LEAD	bold_gold_sales	dim_crm_leads	2	user_id	varchar	RESPONSABLE
98	LEAD	bold_gold_sales	dim_crm_leads	3	company_name	varchar	OTRO
99	LEAD	bold_gold_sales	dim_crm_leads	4	legal_name	varchar	OTRO
100	LEAD	bold_gold_sales	dim_crm_leads	5	person_type	varchar	OTRO











