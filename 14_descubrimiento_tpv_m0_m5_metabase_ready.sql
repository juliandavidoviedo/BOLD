WITH candidate_tables(table_schema, table_name, prioridad) AS (
    VALUES
        ('bold_gold_growth', 'mart_master_merchant_enrich', 1),
        ('bold_gold_growth', 'mart_tpv_daily_by_merchant', 2),
        ('bold_gold_growth', 'mart_tpv_daily_by_transaction', 3),
        ('bold_gold_growth', 'mart_merchant_enrich', 4)
)
SELECT
    c.prioridad,
    cols.table_schema,
    cols.table_name,
    cols.ordinal_position,
    cols.column_name,
    cols.data_type,
    CASE
        WHEN lower(cols.column_name) LIKE '%tpv%total%m0%' THEN 'TPV_M0_DIRECTO'
        WHEN lower(cols.column_name) LIKE '%tpv%total%m1%' THEN 'TPV_M1_DIRECTO'
        WHEN lower(cols.column_name) LIKE '%tpv%total%m2%' THEN 'TPV_M2_DIRECTO'
        WHEN lower(cols.column_name) LIKE '%tpv%total%m3%' THEN 'TPV_M3_DIRECTO'
        WHEN lower(cols.column_name) LIKE '%tpv%total%m4%' THEN 'TPV_M4_DIRECTO'
        WHEN lower(cols.column_name) LIKE '%tpv%total%m5%' THEN 'TPV_M5_DIRECTO'
        WHEN lower(cols.column_name) LIKE '%tpv%' THEN 'TPV_OTRO'
        WHEN lower(cols.column_name) LIKE '%transaction%date%' THEN 'FECHA_TRANSACCION'
        WHEN lower(cols.column_name) LIKE '%date%' THEN 'FECHA_OTRA'
        WHEN lower(cols.column_name) IN ('merchant_id', 'master_merchant_id') THEN 'LLAVE_MERCHANT'
        ELSE 'OTRO'
    END AS uso_sugerido
FROM information_schema.columns cols
INNER JOIN candidate_tables c
    ON cols.table_schema = c.table_schema
   AND cols.table_name = c.table_name
WHERE lower(cols.column_name) LIKE '%tpv%'
   OR lower(cols.column_name) LIKE '%transaction%date%'
   OR lower(cols.column_name) LIKE '%date%'
   OR lower(cols.column_name) IN ('merchant_id', 'master_merchant_id')
ORDER BY
    c.prioridad,
    cols.table_name,
    cols.ordinal_position



--resultado:

#	prioridad	table_schema	table_name	ordinal_position	column_name	data_type	uso_sugerido
1	1	bold_gold_growth	mart_master_merchant_enrich	1	load_datetime	timestamp(6)	FECHA_OTRA
2	1	bold_gold_growth	mart_master_merchant_enrich	2	master_merchant_id	varchar	LLAVE_MERCHANT
3	1	bold_gold_growth	mart_master_merchant_enrich	3	kyc_verification_status_date	timestamp(6)	FECHA_OTRA
4	1	bold_gold_growth	mart_master_merchant_enrich	4	_1st_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
5	1	bold_gold_growth	mart_master_merchant_enrich	5	_4th_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
6	1	bold_gold_growth	mart_master_merchant_enrich	6	_10th_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
7	1	bold_gold_growth	mart_master_merchant_enrich	7	last_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
8	1	bold_gold_growth	mart_master_merchant_enrich	10	_1st_btn_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
9	1	bold_gold_growth	mart_master_merchant_enrich	12	_1st_mpos_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
10	1	bold_gold_growth	mart_master_merchant_enrich	14	_1st_link_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
11	1	bold_gold_growth	mart_master_merchant_enrich	16	_1st_nequi_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
12	1	bold_gold_growth	mart_master_merchant_enrich	18	_1st_qr_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
13	1	bold_gold_growth	mart_master_merchant_enrich	19	tpv_total_m0	decimal(38,2)	TPV_M0_DIRECTO
14	1	bold_gold_growth	mart_master_merchant_enrich	20	tpv_total_m1	decimal(38,2)	TPV_M1_DIRECTO
15	1	bold_gold_growth	mart_master_merchant_enrich	21	tpv_total_m2	decimal(38,2)	TPV_M2_DIRECTO
16	1	bold_gold_growth	mart_master_merchant_enrich	22	tpv_total_last_month	decimal(38,2)	TPV_OTRO
17	1	bold_gold_growth	mart_master_merchant_enrich	23	tpv_historic	decimal(38,2)	TPV_OTRO
18	1	bold_gold_growth	mart_master_merchant_enrich	24	tpv_last_quarter	decimal(38,2)	TPV_OTRO
19	1	bold_gold_growth	mart_master_merchant_enrich	27	bucket_tpv_m0	varchar	TPV_OTRO
20	1	bold_gold_growth	mart_master_merchant_enrich	28	bucket_tpv_m1	varchar	TPV_OTRO
21	1	bold_gold_growth	mart_master_merchant_enrich	29	bucket_tpv_m2	varchar	TPV_OTRO
22	1	bold_gold_growth	mart_master_merchant_enrich	30	bucket_tpv_last_month	varchar	TPV_OTRO
23	4	bold_gold_growth	mart_merchant_enrich	1	load_datetime	timestamp(6)	FECHA_OTRA
24	4	bold_gold_growth	mart_merchant_enrich	2	merchant_id	varchar	LLAVE_MERCHANT
25	4	bold_gold_growth	mart_merchant_enrich	8	onboarding_end_date	timestamp(6)	FECHA_OTRA
26	4	bold_gold_growth	mart_merchant_enrich	15	kyc_verification_status_date	timestamp(6)	FECHA_OTRA
27	4	bold_gold_growth	mart_merchant_enrich	18	kyc_pending_status_date	timestamp(6)	FECHA_OTRA
28	4	bold_gold_growth	mart_merchant_enrich	20	blocked_status_date	timestamp(6)	FECHA_OTRA
29	4	bold_gold_growth	mart_merchant_enrich	21	_1st_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
30	4	bold_gold_growth	mart_merchant_enrich	22	_4th_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
31	4	bold_gold_growth	mart_merchant_enrich	23	_10th_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
32	4	bold_gold_growth	mart_merchant_enrich	24	last_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
33	4	bold_gold_growth	mart_merchant_enrich	27	_1st_btn_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
34	4	bold_gold_growth	mart_merchant_enrich	31	_1st_nequi_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
35	4	bold_gold_growth	mart_merchant_enrich	32	_1st_link_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
36	4	bold_gold_growth	mart_merchant_enrich	33	_1st_mpos_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
37	4	bold_gold_growth	mart_merchant_enrich	35	_1st_qr_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
38	4	bold_gold_growth	mart_merchant_enrich	37	_1st_online_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
39	4	bold_gold_growth	mart_merchant_enrich	39	_1st_online_api_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
40	4	bold_gold_growth	mart_merchant_enrich	41	_1st_link_api_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
41	4	bold_gold_growth	mart_merchant_enrich	43	_1st_mpos_neo_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
42	4	bold_gold_growth	mart_merchant_enrich	45	_1st_mpos_plus_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
43	4	bold_gold_growth	mart_merchant_enrich	47	_1st_mpos_smart_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
44	4	bold_gold_growth	mart_merchant_enrich	49	_1st_mpos_smart_pro_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
45	4	bold_gold_growth	mart_merchant_enrich	51	_1st_mpos_sono_qr_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
46	4	bold_gold_growth	mart_merchant_enrich	53	last_btn_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
47	4	bold_gold_growth	mart_merchant_enrich	55	last_mpos_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
48	4	bold_gold_growth	mart_merchant_enrich	57	last_link_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
49	4	bold_gold_growth	mart_merchant_enrich	59	last_nequi_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
50	4	bold_gold_growth	mart_merchant_enrich	61	last_qr_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
51	4	bold_gold_growth	mart_merchant_enrich	63	last_online_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
52	4	bold_gold_growth	mart_merchant_enrich	65	last_online_api_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
53	4	bold_gold_growth	mart_merchant_enrich	67	last_link_api_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
54	4	bold_gold_growth	mart_merchant_enrich	69	last_mpos_neo_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
55	4	bold_gold_growth	mart_merchant_enrich	71	last_mpos_plus_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
56	4	bold_gold_growth	mart_merchant_enrich	73	last_mpos_smart_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
57	4	bold_gold_growth	mart_merchant_enrich	75	last_mpos_smart_pro_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
58	4	bold_gold_growth	mart_merchant_enrich	77	last_mpos_sono_qr_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
59	4	bold_gold_growth	mart_merchant_enrich	78	_1st_match_date	timestamp(6)	FECHA_OTRA
60	4	bold_gold_growth	mart_merchant_enrich	79	tpv_total_m0	decimal(38,4)	TPV_M0_DIRECTO
61	4	bold_gold_growth	mart_merchant_enrich	80	tpv_total_m1	decimal(38,4)	TPV_M1_DIRECTO
62	4	bold_gold_growth	mart_merchant_enrich	81	tpv_total_m2	decimal(38,4)	TPV_M2_DIRECTO
63	4	bold_gold_growth	mart_merchant_enrich	82	tpv_total_last_month	decimal(38,4)	TPV_OTRO
64	4	bold_gold_growth	mart_merchant_enrich	83	tpv_historic	decimal(38,4)	TPV_OTRO
65	4	bold_gold_growth	mart_merchant_enrich	84	tpv_last_quarter	decimal(38,4)	TPV_OTRO
66	4	bold_gold_growth	mart_merchant_enrich	86	bucket_tpv_m0	varchar	TPV_OTRO
67	4	bold_gold_growth	mart_merchant_enrich	87	bucket_tpv_m1	varchar	TPV_OTRO
68	4	bold_gold_growth	mart_merchant_enrich	88	bucket_tpv_m2	varchar	TPV_OTRO
69	4	bold_gold_growth	mart_merchant_enrich	89	bucket_tpv_last_month	varchar	TPV_OTRO
70	4	bold_gold_growth	mart_merchant_enrich	93	master_merchant_id	varchar	LLAVE_MERCHANT
71	4	bold_gold_growth	mart_merchant_enrich	104	_1st_significant_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
72	4	bold_gold_growth	mart_merchant_enrich	105	_4th_significant_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
73	4	bold_gold_growth	mart_merchant_enrich	106	_10th_significant_transaction_approved_date	timestamp(6)	FECHA_TRANSACCION
74	4	bold_gold_growth	mart_merchant_enrich	107	rank_merchant_onboarding_date_by_rep_legal_document	bigint	FECHA_OTRA
75	4	bold_gold_growth	mart_merchant_enrich	108	rank_merchant_onboarding_date_by_merchant_document	bigint	FECHA_OTRA
