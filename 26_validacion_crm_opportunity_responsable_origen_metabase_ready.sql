WITH base_mensual (merchant_id, kam_asignado_email) AS (
    VALUES
        ('0CZTLXEOXY', CAST(NULL AS varchar)),
        ('3SQNBLP4ZN', CAST(NULL AS varchar)),
        ('60WPJO2DZX', CAST(NULL AS varchar)),
        ('7DVLTIUMHX', CAST(NULL AS varchar)),
        ('8R8UIAMUC6', CAST(NULL AS varchar)),
        ('LG773V6IUV', CAST(NULL AS varchar)),
        ('PA1LA4GGYD', CAST(NULL AS varchar)),
        ('RMCVFJO3D8', CAST(NULL AS varchar)),
        ('VMKYJPDVD1', CAST(NULL AS varchar)),
        ('WFK9N0809K', CAST(NULL AS varchar))
),
opportunity_ranked AS (
    SELECT
        bm.merchant_id,
        bm.kam_asignado_email,
        cast(o.opportunity_id AS varchar) AS opportunity_id,
        cast(o.user_id AS varchar) AS responsable_origen_user_id,
        o.status AS opportunity_status,
        o.lost_status,
        o.sales_channel AS opportunity_sales_channel,
        o.opportunity_type,
        o.management_type,
        o.product_type,
        o.product_name,
        o.company_name,
        o.origin_name,
        o.creation_date,
        o.last_update_date,
        o.won_date,
        o.activation_date,
        o.load_datetime,
        row_number() OVER (
            PARTITION BY bm.merchant_id
            ORDER BY
                CASE WHEN o.won_date IS NOT NULL THEN 1 ELSE 0 END DESC,
                o.won_date DESC,
                o.activation_date DESC,
                o.last_update_date DESC,
                o.creation_date DESC,
                o.load_datetime DESC
        ) AS rn
    FROM base_mensual bm
    INNER JOIN awsdatacatalog.bold_gold_sales.dim_crm_opportunities o
        ON bm.merchant_id = cast(coalesce(o.product_merchant_id, o.metadata_merchant_id) AS varchar)
    WHERE coalesce(o.product_merchant_id, o.metadata_merchant_id) IS NOT NULL
),
opportunity_current AS (
    SELECT
        merchant_id,
        kam_asignado_email,
        opportunity_id,
        responsable_origen_user_id,
        opportunity_status,
        lost_status,
        opportunity_sales_channel,
        opportunity_type,
        management_type,
        product_type,
        product_name,
        company_name,
        origin_name,
        creation_date,
        last_update_date,
        won_date,
        activation_date,
        load_datetime
    FROM opportunity_ranked
    WHERE rn = 1
),
crm_users_ranked AS (
    SELECT
        cast(u.user_id AS varchar) AS user_id,
        u.email,
        cast(u.parent_id AS varchar) AS parent_id,
        u.role,
        u.sales_channel,
        u.status,
        u.load_datetime,
        row_number() OVER (
            PARTITION BY u.user_id
            ORDER BY
                CASE WHEN upper(u.status) = 'ACTIVE' THEN 1 ELSE 0 END DESC,
                u.load_datetime DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_sales.dim_crm_users u
    WHERE u.user_id IS NOT NULL
),
crm_users_current AS (
    SELECT user_id, email, parent_id, role, sales_channel, status
    FROM crm_users_ranked
    WHERE rn = 1
),
bamboo_ranked AS (
    SELECT
        cast(b.user_id AS varchar) AS user_id,
        b.reports_to,
        b.job_title,
        b.channel,
        b.status,
        b.load_datetime,
        row_number() OVER (
            PARTITION BY b.user_id
            ORDER BY b.load_datetime DESC, b.event_datetime DESC
        ) AS rn
    FROM awsdatacatalog.bold_gold_sales.dim_user_bamboo_information b
    WHERE b.user_id IS NOT NULL
),
bamboo_current AS (
    SELECT user_id, reports_to, job_title, channel, status
    FROM bamboo_ranked
    WHERE rn = 1
)
SELECT
    bm.merchant_id,
    bm.kam_asignado_email,
    oc.opportunity_id,
    oc.opportunity_status,
    oc.lost_status,
    oc.opportunity_sales_channel,
    oc.opportunity_type,
    oc.management_type,
    oc.product_type,
    oc.product_name,
    oc.company_name,
    oc.origin_name,
    oc.creation_date,
    oc.last_update_date,
    oc.won_date,
    oc.activation_date,
    oc.responsable_origen_user_id,
    responsable.email AS responsable_origen_email,
    responsable.role AS responsable_origen_role,
    responsable.sales_channel AS responsable_origen_sales_channel,
    responsable.status AS responsable_origen_status,
    responsable_bamboo.job_title AS responsable_origen_job_title,
    responsable_bamboo.reports_to AS responsable_origen_reports_to,
    tl.user_id AS team_lead_origen_user_id,
    tl.email AS team_lead_origen_email,
    tl.role AS team_lead_origen_role,
    tl.sales_channel AS team_lead_origen_sales_channel,
    tl.status AS team_lead_origen_status,
    tl_bamboo.job_title AS team_lead_origen_job_title,
    tl_bamboo.reports_to AS manager_origen_name,
    manager.user_id AS manager_origen_user_id,
    manager.email AS manager_origen_email,
    manager.role AS manager_origen_role,
    manager.sales_channel AS manager_origen_sales_channel,
    manager.status AS manager_origen_status,
    manager_bamboo.job_title AS manager_origen_job_title,
    oc.load_datetime AS opportunity_loaded_at,
    CASE
        WHEN oc.opportunity_id IS NULL THEN 'SIN_OPORTUNIDAD_CRM'
        WHEN oc.responsable_origen_user_id IS NULL THEN 'OPORTUNIDAD_SIN_USER_ID'
        WHEN responsable.user_id IS NULL THEN 'RESPONSABLE_NO_ENCONTRADO_EN_CRM_USERS'
        WHEN tl.user_id IS NULL THEN 'SIN_TEAM_LEAD_ORIGEN'
        ELSE 'RESPONSABLE_ORIGEN_RESUELTO'
    END AS estado_responsable_cualitativo
FROM base_mensual bm
LEFT JOIN opportunity_current oc
    ON bm.merchant_id = oc.merchant_id
LEFT JOIN crm_users_current responsable
    ON oc.responsable_origen_user_id = responsable.user_id
LEFT JOIN bamboo_current responsable_bamboo
    ON responsable.user_id = responsable_bamboo.user_id
LEFT JOIN crm_users_current tl
    ON responsable.parent_id = tl.user_id
LEFT JOIN bamboo_current tl_bamboo
    ON tl.user_id = tl_bamboo.user_id
LEFT JOIN crm_users_current manager
    ON tl.parent_id = manager.user_id
LEFT JOIN bamboo_current manager_bamboo
    ON manager.user_id = manager_bamboo.user_id
ORDER BY bm.merchant_id


##Resultado

#	merchant_id	kam_asignado_email	opportunity_id	opportunity_status	lost_status	opportunity_sales_channel	opportunity_type	management_type	product_type	product_name	company_name	origin_name	creation_date	last_update_date	won_date	activation_date	responsable_origen_user_id	responsable_origen_email	responsable_origen_role	responsable_origen_sales_channel	responsable_origen_status	responsable_origen_job_title	responsable_origen_reports_to	team_lead_origen_user_id	team_lead_origen_email	team_lead_origen_role	team_lead_origen_sales_channel	team_lead_origen_status	team_lead_origen_job_title	manager_origen_name	manager_origen_user_id	manager_origen_email	manager_origen_role	manager_origen_sales_channel	manager_origen_status	manager_origen_job_title	opportunity_loaded_at	estado_responsable_cualitativo
1	0CZTLXEOXY																																					SIN_OPORTUNIDAD_CRM
2	3SQNBLP4ZN																																					SIN_OPORTUNIDAD_CRM
3	60WPJO2DZX																																					SIN_OPORTUNIDAD_CRM
4	7DVLTIUMHX		1L36AMV0C5	WON		SMB			PAYMENT_LINK	PAYMENT_LINK		DATABASE	2026-01-15 15:56:07.033	2026-01-15 16:26:08.826	2026-01-15 16:26:08.826	2026-01-15 00:00:00.000	SD5LTUFFXU	tatiana.cuadro@bold.co	EXECUTIVE	SMB	ACTIVE	SMB Sales Executive	Carolina Daza González	B1ETH8RKIY	carolina.daza@bold.co	LEADER	SMB	ACTIVE	SMB Team Lead	Hector Causil Arguelles	LR78SVJ61Y	hector.causil@bold.co	MANAGER	SMB	ACTIVE	Sales Manager SMB	2026-08-27 19:19:37.930	RESPONSABLE_ORIGEN_RESUELTO
5	8R8UIAMUC6		04VNKMIVWZ	WON		SMB			PAYMENT_LINK	PAYMENT_LINK		DATABASE	2025-12-29 12:21:11.861	2026-01-26 14:06:56.463	2026-01-26 14:06:56.463	2026-01-26 00:00:00.000	QX9IZB8SRB	felipe.gomez@bold.co	EXECUTIVE	SMB	ACTIVE	SMB Sales Executive	Leslie Grajales  Morales	HGGPZJQG4C	tatiana.grajales@bold.co	LEADER	SMB	ACTIVE	SMB Team Lead	German Acosta Cantor	HGGPZJQG4C	tatiana.grajales@bold.co	LEADER	SMB	ACTIVE	SMB Team Lead	2026-08-27 19:19:37.930	RESPONSABLE_ORIGEN_RESUELTO
6	LG773V6IUV		HUNEBH00XQ	WON		SMB			PAYMENT_LINK	PAYMENT_LINK		LQT_MARKETING	2026-01-18 21:36:21.145	2026-02-06 10:45:32.318	2026-02-06 10:45:32.318	2026-02-06 00:00:00.000	2QNFHSUAJ8	esmeralda.malagon@bold.co	EXECUTIVE	SMB	ACTIVE	SMB Sales Executive	Maira Bautista Peraza	1KA41SKQ87	alejandra.bautista@bold.co	LEADER	SMB	ACTIVE	SMB Team Lead	Alvaro Guerrero Fabra	D3TSS47WXG	andres.guerrero@bold.co	MANAGER	SMB	ACTIVE	Sales Manager SMB	2026-08-27 19:19:37.930	RESPONSABLE_ORIGEN_RESUELTO
7	PA1LA4GGYD		POKLLWLA6V	WON		SMB			PAYMENT_LINK	PAYMENT_LINK		SPIDER	2026-01-06 19:23:35.198	2026-01-09 15:21:02.738	2026-01-09 15:21:02.738	2026-01-09 00:00:00.000	T6ZD9I7Y48	rose.ranauro@bold.co	EXECUTIVE	SMB	ACTIVE	SMB Sales Executive	Luis Alvarez Morales	NZGGG3QQGN	luis.morales@bold.co	LEADER	SMB	ACTIVE	SMB Team Lead	Hector Causil Arguelles	LR78SVJ61Y	hector.causil@bold.co	MANAGER	SMB	ACTIVE	Sales Manager SMB	2026-08-27 19:19:37.930	RESPONSABLE_ORIGEN_RESUELTO
8	RMCVFJO3D8		S4BPY8UDIW	WON		SMB			PAYMENT_LINK	PAYMENT_LINK		LQT_MARKETING	2026-01-16 13:41:03.965	2026-01-16 13:43:50.878	2026-01-16 13:43:50.878	2026-01-16 00:00:00.000	DL8IJ8O2UO	raul.castillo@bold.co	EXECUTIVE	SMB	ACTIVE	SMB Sales Executive	Maira Bautista Peraza	JB3J5VB1YZ	carolina.santos@bold.co	LEADER	SMB	ACTIVE	SMB Team Lead	Alvaro Guerrero Fabra	D3TSS47WXG	andres.guerrero@bold.co	MANAGER	SMB	ACTIVE	Sales Manager SMB	2026-08-27 19:19:37.930	RESPONSABLE_ORIGEN_RESUELTO
9	VMKYJPDVD1		5HRFEZ1ZAP	WON		SMB			PAYMENT_LINK	PAYMENT_LINK	REVIEW MODA	COLD_VISIT	2025-09-08 09:48:19.017	2026-02-03 16:19:27.838	2026-02-03 16:19:27.838	2026-02-03 00:00:00.000	OJJTOP28JC	diana.colina@bold.co	EXECUTIVE	SMB	INACTIVE			NZGGG3QQGN	luis.morales@bold.co	LEADER	SMB	ACTIVE	SMB Team Lead	Hector Causil Arguelles	LR78SVJ61Y	hector.causil@bold.co	MANAGER	SMB	ACTIVE	Sales Manager SMB	2026-08-27 19:19:37.930	RESPONSABLE_ORIGEN_RESUELTO
10	WFK9N0809K		3JM0RUET3E	WON		SMB			PAYMENT_LINK	PAYMENT_LINK		LQT_MARKETING	2026-01-26 09:05:24.927	2026-01-27 11:39:46.583	2026-01-27 11:39:46.583	2026-01-27 00:00:00.000	0FQKE3GUVK	indira.montes@bold.co	EXECUTIVE	SMB	ACTIVE	SMB Sales Executive	Wilmar Vanegas Gonzalez	FGYHUQ3E9I	wilmar.vanegas@bold.co	LEADER	SMB	INACTIVE			3UQQ20EJ2M	david.acosta@bold.co	LEADER	SMB	ACTIVE	Sales Manager SMB	2026-08-27 19:19:37.930	RESPONSABLE_ORIGEN_RESUELTO

