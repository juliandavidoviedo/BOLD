WITH tablas_objetivo(table_schema, table_name, prioridad) AS (
    VALUES
        ('bold_gold_sales', 'dim_apolo_opportunities', 1),
        ('bold_gold_sales', 'dim_crm_opportunities', 2),
        ('bold_gold_sales', 'dim_crm_leads', 3),
        ('bold_gold_sales', 'fact_crm_checkout_status_change', 4),
        ('bold_gold_sales', 'fact_crm_leads_status_change', 5),
        ('bold_gold_sales', 'report_crm_leads_status_change_with_tasks', 6)
)
SELECT
    t.prioridad,
    c.table_schema,
    c.table_name,
    c.ordinal_position,
    c.column_name,
    c.data_type,
    CASE
        WHEN lower(c.column_name) IN ('merchant_id', 'product_merchant_id', 'metadata_merchant_id') THEN 'JOIN_MERCHANT'
        WHEN lower(c.column_name) IN ('client_id', 'metadata_client_id', 'metadata_client__id') THEN 'JOIN_CLIENT'
        WHEN lower(c.column_name) IN ('lead_id', 'merchant_contact_id') THEN 'JOIN_LEAD_CONTACT'
        WHEN lower(c.column_name) LIKE '%executive%email%' THEN 'RESPONSABLE_COMERCIAL_EMAIL'
        WHEN lower(c.column_name) LIKE '%created%by%email%' THEN 'CREADOR_OPORTUNIDAD_EMAIL'
        WHEN lower(c.column_name) LIKE '%user%email%' THEN 'USUARIO_EVENTO_EMAIL'
        WHEN lower(c.column_name) LIKE '%lead%email%' THEN 'LEAD_EMAIL'
        WHEN lower(c.column_name) LIKE '%manager%email%' THEN 'MANAGER_EMAIL'
        WHEN lower(c.column_name) LIKE '%owner%' THEN 'OWNER'
        WHEN lower(c.column_name) LIKE '%status%' THEN 'ESTADO_OPORTUNIDAD'
        WHEN lower(c.column_name) LIKE '%stage%' THEN 'ETAPA_OPORTUNIDAD'
        WHEN lower(c.column_name) LIKE '%date%' OR lower(c.column_name) LIKE '%datetime%' THEN 'FECHA'
        WHEN lower(c.column_name) LIKE '%comment%' OR lower(c.column_name) LIKE '%note%' THEN 'CONTEXTO_CRM_NO_HANDOFF'
        ELSE 'OTRO'
    END AS uso_sugerido
FROM information_schema.columns c
INNER JOIN tablas_objetivo t
    ON c.table_schema = t.table_schema
   AND c.table_name = t.table_name
WHERE lower(c.column_name) NOT LIKE '%token%'
  AND lower(c.column_name) NOT LIKE '%secret%'
  AND lower(c.column_name) NOT LIKE '%password%'
ORDER BY
    t.prioridad,
    c.table_schema,
    c.table_name,
    c.ordinal_position


## resultado
#	prioridad	table_schema	table_name	ordinal_position	column_name	data_type	uso_sugerido
1	1	bold_gold_sales	dim_apolo_opportunities	1	event_timestamp	bigint	OTRO
2	1	bold_gold_sales	dim_apolo_opportunities	2	load_datetime	timestamp(3)	FECHA
3	1	bold_gold_sales	dim_apolo_opportunities	3	opportunity_id	varchar	OTRO
4	1	bold_gold_sales	dim_apolo_opportunities	4	creation_date	timestamp(3)	FECHA
5	1	bold_gold_sales	dim_apolo_opportunities	5	last_update_date	timestamp(3)	FECHA
6	1	bold_gold_sales	dim_apolo_opportunities	6	sales_process_ended_date	timestamp(3)	FECHA
7	1	bold_gold_sales	dim_apolo_opportunities	7	completed_date	timestamp(3)	FECHA
8	1	bold_gold_sales	dim_apolo_opportunities	8	executive_email	varchar	RESPONSABLE_COMERCIAL_EMAIL
9	1	bold_gold_sales	dim_apolo_opportunities	9	fingerprint_device_type	varchar	OTRO
10	1	bold_gold_sales	dim_apolo_opportunities	10	fingerprint_platform	varchar	OTRO
11	1	bold_gold_sales	dim_apolo_opportunities	11	fingerprint_os	varchar	OTRO
12	1	bold_gold_sales	dim_apolo_opportunities	12	fingerprint_model	varchar	OTRO
13	1	bold_gold_sales	dim_apolo_opportunities	13	fingerprint_browser	varchar	OTRO
14	1	bold_gold_sales	dim_apolo_opportunities	14	fingerprint_app_version	varchar	OTRO
15	1	bold_gold_sales	dim_apolo_opportunities	15	fingerprint_latitude	varchar	OTRO
16	1	bold_gold_sales	dim_apolo_opportunities	16	fingerprint_longitude	varchar	OTRO
17	1	bold_gold_sales	dim_apolo_opportunities	17	fingerprint_city	varchar	OTRO
18	1	bold_gold_sales	dim_apolo_opportunities	18	fingerprint_country	varchar	OTRO
19	1	bold_gold_sales	dim_apolo_opportunities	19	fingerprint_ip	varchar	OTRO
20	1	bold_gold_sales	dim_apolo_opportunities	20	lead_merchant_name	varchar	OTRO
21	1	bold_gold_sales	dim_apolo_opportunities	21	lead_economic_activity_name	varchar	OTRO
22	1	bold_gold_sales	dim_apolo_opportunities	22	lead_economic_activity_ciiu	varchar	OTRO
23	1	bold_gold_sales	dim_apolo_opportunities	23	lead_economic_activity_mcc	varchar	OTRO
24	1	bold_gold_sales	dim_apolo_opportunities	24	lead_origin	varchar	OTRO
25	1	bold_gold_sales	dim_apolo_opportunities	25	lead_quote	varchar	OTRO
26	1	bold_gold_sales	dim_apolo_opportunities	26	lead_comment	varchar	CONTEXTO_CRM_NO_HANDOFF
27	1	bold_gold_sales	dim_apolo_opportunities	27	lead_estimated_sale_date	timestamp(3)	FECHA
28	1	bold_gold_sales	dim_apolo_opportunities	28	lead_average_monthly_sales	varchar	OTRO
29	1	bold_gold_sales	dim_apolo_opportunities	29	sales_channel	varchar	OTRO
30	1	bold_gold_sales	dim_apolo_opportunities	30	sales_delivery_required	boolean	OTRO
31	1	bold_gold_sales	dim_apolo_opportunities	31	kyc_required	boolean	OTRO
32	1	bold_gold_sales	dim_apolo_opportunities	32	allowed_payment_methods	varchar	OTRO
33	1	bold_gold_sales	dim_apolo_opportunities	33	activities	varchar	OTRO
34	1	bold_gold_sales	dim_apolo_opportunities	34	fees	varchar	OTRO
35	1	bold_gold_sales	dim_apolo_opportunities	35	billing_id	varchar	OTRO
36	1	bold_gold_sales	dim_apolo_opportunities	36	merchant_id	varchar	JOIN_MERCHANT
37	1	bold_gold_sales	dim_apolo_opportunities	37	merchant_name	varchar	OTRO
38	1	bold_gold_sales	dim_apolo_opportunities	38	external_invoice_id	varchar	OTRO
39	1	bold_gold_sales	dim_apolo_opportunities	39	shipment	varchar	OTRO
40	1	bold_gold_sales	dim_apolo_opportunities	40	opportunity_status	varchar	ESTADO_OPORTUNIDAD
41	1	bold_gold_sales	dim_apolo_opportunities	41	external_id	varchar	OTRO
42	1	bold_gold_sales	dim_apolo_opportunities	42	void_lost_date	timestamp(3)	FECHA
43	1	bold_gold_sales	dim_apolo_opportunities	43	created_by_id_email	varchar	CREADOR_OPORTUNIDAD_EMAIL
44	1	bold_gold_sales	dim_apolo_opportunities	44	point_of_sale_id	varchar	OTRO
45	1	bold_gold_sales	dim_apolo_opportunities	45	point_of_sale_name	varchar	OTRO
46	1	bold_gold_sales	dim_apolo_opportunities	46	point_of_sale_city	varchar	OTRO
47	1	bold_gold_sales	dim_apolo_opportunities	47	opportunity_status_history	varchar	ESTADO_OPORTUNIDAD
48	1	bold_gold_sales	dim_apolo_opportunities	48	management_type	varchar	OTRO
49	1	bold_gold_sales	dim_apolo_opportunities	49	terminal_providers	varchar	OTRO
50	1	bold_gold_sales	dim_apolo_opportunities	50	cancellation_information	varchar	OTRO
51	1	bold_gold_sales	dim_apolo_opportunities	51	payment_order_id	varchar	OTRO
52	1	bold_gold_sales	dim_apolo_opportunities	52	payment_order_detail_id	varchar	OTRO
53	1	bold_gold_sales	dim_apolo_opportunities	53	payment_method	varchar	OTRO
54	1	bold_gold_sales	dim_apolo_opportunities	54	payment_status	varchar	ESTADO_OPORTUNIDAD
55	1	bold_gold_sales	dim_apolo_opportunities	55	transaction_id	varchar	OTRO
56	1	bold_gold_sales	dim_apolo_opportunities	56	payment_event_date	bigint	FECHA
57	1	bold_gold_sales	dim_apolo_opportunities	57	total_sale_items	double	OTRO
58	1	bold_gold_sales	dim_apolo_opportunities	58	event_partition	integer	OTRO
59	2	bold_gold_sales	dim_crm_opportunities	1	idempotency_hash	varchar	OTRO
60	2	bold_gold_sales	dim_crm_opportunities	2	event_timestamp	bigint	OTRO
61	2	bold_gold_sales	dim_crm_opportunities	3	event_datetime	timestamp(3)	FECHA
62	2	bold_gold_sales	dim_crm_opportunities	4	load_datetime	timestamp(3)	FECHA
63	2	bold_gold_sales	dim_crm_opportunities	5	product_type	varchar	OTRO
64	2	bold_gold_sales	dim_crm_opportunities	6	product_name	varchar	OTRO
65	2	bold_gold_sales	dim_crm_opportunities	7	opportunity_id	varchar	OTRO
66	2	bold_gold_sales	dim_crm_opportunities	8	user_id	varchar	OTRO
67	2	bold_gold_sales	dim_crm_opportunities	9	status	varchar	ESTADO_OPORTUNIDAD
68	2	bold_gold_sales	dim_crm_opportunities	10	parent_type	varchar	OTRO
69	2	bold_gold_sales	dim_crm_opportunities	11	parent_id	varchar	OTRO
70	2	bold_gold_sales	dim_crm_opportunities	12	products	varchar	OTRO
71	2	bold_gold_sales	dim_crm_opportunities	13	is_terminal_reassignment	varchar	OTRO
72	2	bold_gold_sales	dim_crm_opportunities	14	management_type	varchar	OTRO
73	2	bold_gold_sales	dim_crm_opportunities	15	activation_date	timestamp(3)	FECHA
74	2	bold_gold_sales	dim_crm_opportunities	16	contract_type	varchar	OTRO
75	2	bold_gold_sales	dim_crm_opportunities	17	customized_contract	varchar	OTRO
76	2	bold_gold_sales	dim_crm_opportunities	18	merchant_contact_id	varchar	JOIN_LEAD_CONTACT
77	2	bold_gold_sales	dim_crm_opportunities	19	observation	varchar	OTRO
78	2	bold_gold_sales	dim_crm_opportunities	20	supporting_file	varchar	OTRO
79	2	bold_gold_sales	dim_crm_opportunities	21	tpv_size	varchar	OTRO
80	2	bold_gold_sales	dim_crm_opportunities	22	sales_channel	varchar	OTRO
81	2	bold_gold_sales	dim_crm_opportunities	23	lost_status	varchar	ESTADO_OPORTUNIDAD
82	2	bold_gold_sales	dim_crm_opportunities	24	discard_category	varchar	OTRO
83	2	bold_gold_sales	dim_crm_opportunities	25	discard_reason	varchar	OTRO
84	2	bold_gold_sales	dim_crm_opportunities	26	other_discard_reason	varchar	OTRO
85	2	bold_gold_sales	dim_crm_opportunities	27	creation_date	timestamp(3)	FECHA
86	2	bold_gold_sales	dim_crm_opportunities	28	last_update_date	timestamp(3)	FECHA
87	2	bold_gold_sales	dim_crm_opportunities	29	won_date	timestamp(3)	FECHA
88	2	bold_gold_sales	dim_crm_opportunities	30	product_merchant_id	varchar	JOIN_MERCHANT
89	2	bold_gold_sales	dim_crm_opportunities	31	metadata_merchant_id	varchar	JOIN_MERCHANT
90	2	bold_gold_sales	dim_crm_opportunities	32	metadata_client_id	varchar	JOIN_CLIENT
91	2	bold_gold_sales	dim_crm_opportunities	33	metadata_client_type	varchar	OTRO
92	2	bold_gold_sales	dim_crm_opportunities	34	company_name	varchar	OTRO
93	2	bold_gold_sales	dim_crm_opportunities	35	previous_user	varchar	OTRO
94	2	bold_gold_sales	dim_crm_opportunities	36	reassign_reason	varchar	OTRO
95	2	bold_gold_sales	dim_crm_opportunities	37	vertical	varchar	OTRO
96	2	bold_gold_sales	dim_crm_opportunities	38	opportunity_type	varchar	OTRO
97	2	bold_gold_sales	dim_crm_opportunities	39	origin_name	varchar	OTRO
98	2	bold_gold_sales	dim_crm_opportunities	40	origin_description	varchar	OTRO
99	2	bold_gold_sales	dim_crm_opportunities	41	origin_utm_source	varchar	OTRO
100	2	bold_gold_sales	dim_crm_opportunities	42	origin_utm_medium	varchar	OTRO
