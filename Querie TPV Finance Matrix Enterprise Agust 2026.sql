
SELECT
    c.merchant_id,
    c.merchant_name,
    c.sales_source,
    c.merchant_acquisition_channel_sales_agent_email,
    c.creation_date,
    c.status,
    c.onboarding_status,
    c.last_update_event_date
FROM awsdatacatalog.bold_gold_growth.dim_client c
WHERE c.merchant_id IN (
    'TR2KLJUVZ6',
    'GSYCJJ0ZMX',
    '75H2G3UNCN',
    '0XV9992C0O',
    'GHTNMF7727',
    'XMABPI8SDB',
    'PL0B5ER5G3',
    'JXLFJ824NO'
)
LIMIT 50
--------
#	merchant_id	merchant_name	sales_source	merchant_acquisition_channel_sales_agent_email	creation_date	status	onboarding_status	last_update_event_date
1	XMABPI8SDB	Droguería Farmacenter Yinimar	INBOUND		2026-08-14 12:39:03.724	ENABLED	APPROVED	2026-08-14 12:51:20.179
2	JXLFJ824NO	Droguerías Expreso	INBOUND		2026-08-14 11:22:26.022	ENABLED	APPROVED	2026-08-15 11:05:28.060
3	PL0B5ER5G3	Drogueria  villadela	INBOUND		2026-08-20 09:33:27.598	ENABLED	APPROVED	2026-08-20 18:02:00.963
4	GSYCJJ0ZMX	Raga Company	INBOUND		2024-08-22 00:06:30.581	ENABLED	APPROVED	2026-03-18 16:05:54.441
5	GHTNMF7727	Drogueria Melcomia 	INBOUND		2026-08-06 17:08:35.384	ENABLED	APPROVED	2026-08-06 17:20:55.771
6	75H2G3UNCN	Farmacenter mi farma	INBOUND		2024-09-15 09:06:16.539	ENABLED	APPROVED	2026-03-18 18:18:26.779
7	TR2KLJUVZ6	Droguería Farma América	INBOUND		2026-08-06 17:50:46.893	ENABLED	APPROVED	2026-08-06 17:59:51.371
8	0XV9992C0O	Droguería y Farmacia Central	INBOUND		2026-08-06 09:12:05.587	ENABLED	APPROVED	2026-08-06 09:26:22.697
