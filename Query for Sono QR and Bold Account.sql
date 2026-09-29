WITH parametros AS (
    SELECT
        CAST('2026-08-01' AS DATE) AS inicio_mes,
        DATE_ADD('month', 1, CAST('2026-08-01' AS DATE)) AS inicio_mes_siguiente,
        CAST('2026-08-28' AS DATE) AS fecha_reporte
),

input_merchants AS (
    SELECT UPPER(TRIM(CAST(merchant_id AS VARCHAR))) AS merchant_id
    FROM (
        VALUES 
            ('007ZCN72T9'), ('00HW77NRS5'), ('06INTAJXU4'), ('07B2HUVM7F'), ('07JGC7N573'), ('0ATHDV5HJG'), ('0BE18WOVV2'), ('0C0XOP1SPP'), ('0GDIBQPP50'), ('0GRNI5F4QF'),
            ('0ISTC22YF7'), ('0IWY258WI1'), ('0K38JOTZ07'), ('0KHOGAT8VD'), ('0QQ5L1BHF3'), ('0QR9JQGVSG'), ('0SNB18VV5N'), ('0TYYHKUHP8'), ('0XV9992C0O'), ('10BM9VXQVG'),
            ('13NS2IRWAL'), ('1B7HGVWPQO'), ('1HN4UQWMG4'), ('1IOK8M0I1O'), ('1KQZPLFRVW'), ('1P8Q9P60GS'), ('1TZPXSCAW9'), ('1UG6EC0153'), ('1UW879TOR7'), ('22CTCHV46Y'),
            ('22U2CK38YL'), ('25S37U3CNA'), ('25UZBO1Y3V'), ('27568RHV6J'), ('286Z87LVL9'), ('2BWXVSPCV4'), ('2EN0WTURUG'), ('2F2N70O5YQ'), ('2KYEXILWP9'), ('2KZIAUWNWC'),
            ('2PPCRU1V31'), ('2Q374JFGOU'), ('2R8RGWWOMC'), ('2RW7TX39BJ'), ('2S3YFTIOWT'), ('2T7EB5U57A'), ('2WZ9UO778I'), ('32AHS8GDKQ'), ('364IFJ0KJ0'), ('39HYZYQBCS'),
            ('3ALKBOT764'), ('3CH8FBJ9AN'), ('3FYFN0GLIG'), ('3FZ0MNAA85'), ('3K2UR9MQ3O'), ('3LFMNSDMDQ'), ('3ODGLUFW0P'), ('3OO2I3IBML'), ('3RTLO9YSA8'), ('3VKSE11YHA'),
            ('3X0E9Z7SYT'), ('3X4LMKE8LL'), ('407PTNVTRN'), ('44CVFWETUO'), ('489S5Q7WYV'), ('4CKTSEVUUS'), ('4ET483LBS9'), ('4FQG6O9PAA'), ('4GSR3W3555'), ('4I2PD2J2SH'),
            ('4IUD0W6C6Y'), ('4JF8VIZSZC'), ('4MPT1SLMS3'), ('4Q1WPIQFDI'), ('4ULC5FOEZ4'), ('4WZ93LQE5J'), ('4ZJWZDY70P'), ('53ZV791KK1'), ('54LXJZBNZ9'), ('55J5DANVAC'),
            ('55KVWQMS70'), ('55U47GXWBM'), ('56BYX939V2'), ('57TSILGZB8'), ('585CKXOEHH'), ('5H91JVCI4I'), ('5HT3134U9L'), ('5N80W95AME'), ('5PDL06YQS8'), ('5QI9HHZ4V3'),
            ('5SHPG9GQQ7'), ('5SMNGBY745'), ('5TXS2ZG7XX'), ('5UV6CB71KG'), ('5VHX9ONTCS'), ('5YYB30H3ZE'), ('66X883KUVY'), ('67K9HVZ2NA'), ('6ATTBJKOAA'), ('6AWOULU6WW'),
            ('6D9SR6I3T6'), ('6E5KOPF5O0'), ('6EOFFK04A4'), ('6FRO84K9L2'), ('6G6E7L5CY9'), ('6G7Q1H091A'), ('6GZ4O9X31H'), ('6IK5F89I1N'), ('6KVV4LOMM7'), ('6LVTRW557U'),
            ('6O50A0Q00F'), ('6PFNSOC627'), ('6PRP3SGLO4'), ('6PYY0I3KDT'), ('6TY4C3M16Y'), ('6U2KWW97J4'), ('6V1AEP6X50'), ('6WLOPUS55T'), ('6WMB7Y7OSM'), ('6X80WCGAYR'),
            ('6XEE21WOTF'), ('6XZ2R1K3F7'), ('6Y10I7C5SA'), ('6ZFQCY7564'), ('73O17J5XVT'), ('74V95GVO8P'), ('7601S5XG1U'), ('78XWWBGUGU'), ('79E9W9G236'), ('79L230O9OS'),
            ('79O947CGTY'), ('79TGZTYLSA'), ('7A977RMM9S'), ('7B1XAGOPCS'), ('7BI8S95T7L'), ('7D844HWO9U'), ('7DDA23LFF0'), ('7DRC24E0X6'), ('7EB50G4190'), ('7EN34M9T0V'),
            ('7F5OCVGVJ9'), ('7F8C4O9GOM'), ('7IPCV8YYHF'), ('7JGC7N5730'), ('7K2E76G4R3'), ('7L194ZJ3O8'), ('7LTYE51SDA'), ('7N44P9T0P9'), ('7O09P5CG4R'), ('7O6B3M9280'),
            ('7OOXCT3JON'), ('7QY765O0Z1'), ('7SK1TLLNCA'), ('7SQXWWN6A1'), ('7TA49KGWGC'), ('7TY433LFF9'), ('7UE5O73P0V'), ('7V73516L1P'), ('7WE998CG23'), ('7XOS5R6J7K'),
            ('7XS3C9S989'), ('7XZS2V2YON'), ('7YLOMX4O4L'), ('81E27A1A4C'), ('81J9R2D5N1'), ('83X76J8O84'), ('846T4K7CWW'), ('84K3SAJ175'), ('86095I243O'), ('86J2N1M9L3'),
            ('87A6M04CT4'), ('896TGOMGAW'), ('89U4A2328I'), ('8A39Y9844A'), ('8APM105B7S'), ('8B3T3J9ON0'), ('8BGTHB59TY'), ('8CG1X1W684'), ('8CM5MCT5S4'), ('8CV4SNA83F'),
            ('8D6OS9381G'), ('8EGLOM75G5'), ('8EIT9W6A35'), ('8F4F24P3C1'), ('8FSAOTD228'), ('8IEO7I8CGA'), ('8JGLSFFV7M'), ('8JWWOT20O7'), ('8K468XLLP4'), ('8KWGA2CWW6'),
            ('8L4C4S261S'), ('8M6O2CG452'), ('8M8T1TG24R'), ('8MTH8S69P4'), ('8N2Y3Y3VSA'), ('8N71578LLP'), ('8NC0479A0Y'), ('8NHJCS6CST'), ('8OF3CCTCT4'), ('8OFCA3M714'),
            ('8OJ1LWW532'), ('8OM9E1A2T5'), ('8OO112IWF9'), ('8OOE25T55J'), ('8ORPWO0E3P'), ('8P1C4P01CG'), ('8R1O15A8G5'), ('8RDA2I9T7K'), ('8S2E7O30O0'), ('8SUX1WO1M1'),
            ('8TRCA5W55W'), ('8U3O4M6C3V'), ('8UFW3J95GT'), ('8UGA9LOM80'), ('8W68YCA283'), ('8WCV7SA114'), ('8WSA2O74M1'), ('8X0CCTJ48R'), ('8X195159P4'), ('8X1OO9S3J3'),
            ('8X2Y2F2TLO'), ('8XA4A0C545'), ('8XA8NWW9T3'), ('8XGTT41CTJ'), ('8XKCS356L0'), ('8XKTHP0C1C'), ('8XL2I5O7TL'), ('8XMTHCSM8S'), ('8XMVM7J72C'), ('8XOOSFF1S3'),
            ('8XOVT15C03'), ('8XRTT6G4S9'), ('8XTL00I3M1'), ('8XV2TGJA42'), ('8XV81SAOS6'), ('8XWCS2T1OM'), ('8XWOO7N3M0'), ('8XXGA5YLLJ'), ('8XXSS53A70'), ('8XZJOMM9N4'),
            ('8Y0X83K0V0'), ('8Y2P302PGA'), ('8Y5YOMJ4P0'), ('8Y87OM6LCS'), ('8Y94CAOMCS'), ('8Y9S8SO152'), ('8YB05I5CG2'), ('8YCCCS9N2T'), ('8YCP20CA8J'), ('8YDA1M63LL'),
            ('8YE0X2P2CS'), ('8YE2OMN61L'), ('8YGA99O47S'), ('8YIAOMLL19'), ('8YKCA0T7S9'), ('8YKCSTOSJ4'), ('8YLO8O49LA'), ('8YMMI11T2S'), ('8YNCS9TJ0A'), ('8YPCC05OOM'),
            ('8YPCSM453O'), ('8YRO0M9OM1'), ('8YSCC0I123'), ('8YSMOCS03T'), ('8YSS2O0O14'), ('8YTCS5M38C'), ('8YW03A8S61'), ('8YX1SSTLS6'), ('8YYG1O08G1'), ('8YYSA54SA8'),
            ('8YZ1M591SS'), ('8YZ30SLNCT'), ('8YZCMM2N21'), ('8Z0I9N63O0'), ('8Z1O81OSG5'), ('8Z31SA15LL'), ('8Z3CA144ST'), ('8Z3TSS8G9G'), ('8Z581335T9'), ('8Z5I922M65'),
            ('8Z5OSS1GCA'), ('8Z8CM3SLT8'), ('8Z9P1186OO'), ('8ZAO34LNNM'), ('8ZC2326S13'), ('8ZD3CA6T24'), ('8ZD8GA8NLL'), ('8ZF1164J08'), ('8ZG1MA7118'), ('8ZGTT7L4T9'),
            ('8ZJ9OM4MT9'), ('8ZJSAIOMC8'), ('8ZKCC0OTOM'), ('8ZKMO1MT00'), ('8ZM45I3OSL'), ('8ZMCSL6CS4'), ('8ZNCSJOMC2'), ('8ZP0M782GA'), ('8ZPOSL6ST6'), ('8ZPCS6MC3N'),
            ('8ZR016STT5'), ('8ZRC12OM82'), ('8ZRO88OSSM'), ('8ZRP2S61P5'), ('8ZRPOML452'), ('8ZS9C13TCG'), ('8ZSCO12S85'), ('8ZSMSI2CT1'), ('8ZT3CA9OS4'), ('8ZT9990S06'),
            ('8ZTAM1S61S'), ('8ZU0O8644P'), ('8ZV28ONMLO'), ('8ZXCSS8OM8'), ('8ZYPM96G9O'), ('8ZZCS18MC4'), ('9171I9P0GC'), ('91B99I2XW8'), ('91C36I2P24'), ('91L1OS4LNA'),
            ('925S1RGAW1'), ('93TGL20L95'), ('95OC31OS0G'), ('97B1X3AQSJ'), ('97GGC3Y1O3'), ('99SAUWL1W5'), ('9A0Z9T57SL'), ('9A1CTP2JGT'), ('9A1Q1R4TG4'), ('9A2EWT1JOM'),
            ('9A4XOM6T7U'), ('9A7Q2S1O8M'), ('9ACGT51J1U'), ('9AD495JGG2'), ('9AETI256S1'), ('9AGM5SGA1G'), ('9AGO2JJAON'), ('9AH366NGA9'), ('9AHI64GA6G'), ('9AHX46LCT9'),
            ('9AI9CA4A47'), ('9AIAT5YLA2'), ('9AIGGOM6A1'), ('9AK0078O35'), ('9AK2486G8S'), ('9AL0333O29'), ('9AL4OTGA93'), ('9ALMT2PGA0'), ('9ALSTCSN1I'), ('9ALTCA92L3'),
            ('9AMSSG1SA3'), ('9ANM7GCT8O'), ('9AP17J8STC'), ('9AP22OMSA2'), ('9APCA64O1L'), ('9AQ8N65CT4'), ('9ASO8J0S80'), ('9ATGA9O9A1'), ('9ATGALL5OM'), ('9AVO7SO3N1'),
            ('9AWMO1TOS2'), ('9AWSAI8M69'), ('9AY132338A'), ('9AY5O4LO8N'), ('9AYM34G8GA'), ('9AZCS0S029'), ('9B0OS1AOS0'), ('9B1S9ML58O'), ('9B1SA5T631'), ('9B3A7J3M35'),
            ('9B5CT23A2M'), ('9B61M12IOM'), ('9B76AILNN8'), ('9B7S5SMCG8'), ('9BA094592L'), ('9BAA7JJO2T'), ('9BACST2M65'), ('9BALM448CS'), ('9BC0A6S611'), ('9BC8CS0SJA'),
            ('9BCC1OMMT2'), ('9BDM4TG4J5'), ('9BE17S6M0J'), ('9BE916M2P1'), ('9BF2A60A0I'), ('9BG16S8A52'), ('9BG79MO2SA'), ('9BGCM6L65G'), ('9BGCSML1O8'), ('9BGGT3JTG8'),
            ('9BGI202N50'), ('9BGL36SO4A'), ('9BGOM41604'), ('9BGTI6I1N1'), ('9BGTMMJG58'), ('9BH9A436O1'), ('9BI14TJ3MT'), ('9BICS741S4'), ('9BJ22J3OS6'), ('9BJ34STMC0'),
            ('9BJ4MGA5OS'), ('9BJ62I3NMM'), ('9BJ8S84MC2'), ('9BJAO7STG9'), ('9BJCS2N8A6'), ('9BJD1G8O5C'), ('9BJI931CGA'), ('9BJL51GAA2'), ('9BJM37O1SM'), ('9BJO8J1C8N'),
            ('9BJOOM63ST'), ('9BJP7N1CT2'), ('9BJS0M2CT3'), ('9BJT0OM81P'), ('9BKC6793L6'), ('9BKCA8SOON'), ('9BKG6TM1S0'), ('9BKO9I4CT5'), ('9BKOO03TGJ'), ('9BKR372MGG'),
            ('9BKS40STOM'), ('9BL3A7N3AC'), ('9BL3AOM9N1'), ('9BL82S02M6'), ('9BL865I828'), ('9BL8CSGT93'), ('9BL923O9S6'), ('9BLG42O1S6'), ('9BLGAT72CT'), ('9BLGCS12N4'),
            ('9BLGT9G4CT'), ('9BLGTT11T3'), ('9BLM7CGA02'), ('9BLMC39ST8'), ('9BLO9SMC41'), ('9BLOMMJA7G'), ('9BLS4G12L9'), ('9BLSM5J1OS'), ('9BLSS625LA'), ('9BLTT7N5MT'),
            ('9BM104O1SM'), ('9BM6OIOT26'), ('9BM6OT1J59'), ('9BM91C9A12'), ('9BMC76TG48'), ('9BMC80G1A4'), ('9BMG72314M'), ('9BMM94S1M1'), ('9BMOI5TLAO'), ('9BMP9O434A'),
            ('9BMPCS62G8'), ('9BMS599P2O'), ('9BMT2I2GLT'), ('9BMTOJSO6L'), ('9BMTT11CA8'), ('9BMVO90SGL'), ('9BN0STJG9G'), ('9BN1A7LSL9'), ('9BN7S3S66L'), ('9BN85OSOT2'),
            ('9BNC6O1SLL'), ('9BNCA1G83G'), ('9BNCST2M1M'), ('9BNI9MCTGL'), ('9BNITOSJSM'), ('9BNM98N3AC'), ('9BNO83JMTG'), ('9BNS446CA3'), ('9BNSS4J4T1'), ('9BO8N66MA3'),
            ('9BO8OM91J2'), ('9BOA9GJS6S'), ('9BOG3ON3M1'), ('9BOG9N36CT'), ('9BOM65ST2N'), ('9BOMI4A648'), ('9BOMOMLSLS'), ('9BOO5ML143'), ('9BOO601CT2'), ('9BOO7SL5CT'),
            ('9BOO88S0ON'), ('9BOS74L8LA'), ('9BOU71O2M1'), ('9BOU981CTN'), ('9BOUTN6S2A'), ('9BOVCSOS6A'), ('9BP8OOSG5P'), ('9BPCAI69A2'), ('9BPCOI491A'), ('9BPCS61ST1'),
            ('9BPG93J3SA'), ('9BPLM32SM1'), ('9BPLO3MA8G'), ('9BPMOI6GA8'), ('9BPOMN3I85'), ('9BPOO93GA2'), ('9BPR9O0OS5'), ('9BPS1C2CSM'), ('9BPT480I85'), ('9BPTM9A814'),
            ('9BPTOI0J3M'), ('9BQ21ML535'), ('9BQ6C58I8S'), ('9BQCA2M8G2'), ('9BQI635N08'), ('9BQL4OOSGA'), ('9BQM0OMTLL'), ('9BQO4N362S'), ('9BQO8ML2MC'), ('9BQS3OMOMJ'),
            ('9BQSA36MC9'), ('9BQT8S021C'), ('9BQU5L43SS'), ('9BR0O90J8L'), ('9BR0SLMC23'), ('9BR2N33LLJ'), ('9BR48M3OSG'), ('9BR4900LLP'), ('9BR8CS2MC3'), ('9BRA2M38O3'),
            ('9BRCO2J0ON'), ('9BRO2M1MMS'), ('9BROCS1CMA'), ('9BROSOS3T0'), ('9BRP8TG85A'), ('9BRPOLLST1'), ('9BRSMMSTSL'), ('9BRSTOS324'), ('9BRT3OMOSN'), ('9BRTOS1323'),
            ('9BS38L8MA0'), ('9BS928SOO5'), ('9BSA10J1L3'), ('9BSCO842SS'), ('9BSGCS4531'), ('9BSL5OOTJ3'), ('9BSM57M1G8'), ('9BSM8S4G0G'), ('9BSM8SGST6'), ('9BSMM7SM3A'),
            ('9BSO3703T1'), ('9BSOM5NMSN'), ('9BSOOM2C9A'), ('9BSRST5LL1'), ('9BSS8ML2N0'), ('9BSS9OMT2O'), ('9BSSTOMJS6'), ('9BST36O26G'), ('9BST7ST038'), ('9BSTT1CSTJ'),
            ('9BSVOI9A62'), ('9BT3CMMG4N'), ('9BT88OLL4N'), ('9BTA20SOST'), ('9BTC076MT2'), ('9BTCT7JG2S'), ('9BTG25J012'), ('9BTG9O1SLN'), ('9BTI2OSMC3'), ('9BTLOI0GMA'),
            ('9BTM1S26MT'), ('9BTMN3LNSL'), ('9BTO45SOAC'), ('9BTO4N01L0'), ('9BTOM1JJS8'), ('9BTOMT0610'), ('9BTPC66G2M'), ('9BTS3M43G1'), ('9BTT1ON3N5'), ('9BU38S3CLL'),
            ('9BU3CA0A29'), ('9BU7G4JGST'), ('9BU8I5G8L3'), ('9BUI8M00S0'), ('9BULO38L6N'), ('9BUM6210C1'), ('9BUPC6J1M9'), ('9BUS1M6C6A'), ('9BUS32JOS6'), ('9BUST538SA'),
            ('9BUT41O881'), ('9BUT840A8A'), ('9BUTOM1ST8'), ('9BV0MC8NNS'), ('9BV151CTN0'), ('9BV1OM6NMM'), ('9BV3AOMON0'), ('9BV64L6929'), ('9BV72SNOCT'), ('9BVA4I0ST6'),
            ('9BVA7J0C90'), ('9BVC8O3MT2'), ('9BVI965T02'), ('9BVJ3G1ST0'), ('9BVL4SLONN'), ('9BVLL1AOSN'), ('9BVO58GAC9'), ('9BVOMOM0C8'), ('9BVR284A5C'), ('9BVS0A2C91'),
            ('9BVS41CTOT'), ('9BVS5OIAC3'), ('9BVSOM6952'), ('9BVSTNJ0LL'), ('9BVT1I61OS'), ('9BVTCSOM10'), ('9BW154C12O'), ('9BW25LL03A'), ('9BW2C32CTN'), ('9BW2OSI85P'),
            ('9BW8196SSM'), ('9BW9AMN2GT'), ('9BWA1J0OMT'), ('9BWA5ON323'), ('9BWAON1CS1'), ('9BWB2OMGT8'), ('9BWC9A15G8'), ('9BWI21SLL0'), ('9BWL57G0C4'), ('9BWM34SA3S'),
            ('9BWM5OMSM1'), ('9BWMOM6CT9'), ('9BWO3SO3TG'), ('9BWOO14GA8'), ('9BWOONLA68'), ('9BWP9G03M8'), ('9BWRCA1A5G'), ('9BWSN16GSO'), ('9BWSOSSLCA'), ('9BWSSTJ0CA'),
            ('9BWTCA7LS3'), ('9BWTM9O385'), ('9BX16G0J98'), ('9BX3C8N5SL'), ('9BX3CMOSN2'), ('9BXA543LA9'), ('9BXAAOM9C5'), ('9BXB29OSC2'), ('9BXGCS1G3M'), ('9BXI2S44C0'),
            ('9BXM15JST9'), ('9BXM3LJA1T'), ('9BXM7C2OOS'), ('9BXMO5M3ST'), ('9BXN7S9OOS'), ('9BXNM1S01S'), ('9BXNM82I3T'), ('9BXO72S1MA'), ('9BXO9SO2MA'), ('9BXR17S10L'),
            ('9BXSCA70SM'), ('9BXTAM6SL1'), ('9BXTG69S8G'), ('9BY0MMNOOM'), ('9BY0O7O1CT'), ('9BY158STN3'), ('9BY28GLL3M'), ('9BY2MC6LA8'), ('9BY7SO1A60'), ('9BYA38JG1S'),
            ('9BYC8S36L1'), ('9BYI83I3M0'), ('9BYLOM9OSG'), ('9BYM27ACST'), ('9BYOMMOMST'), ('9BYOOJJSLL'), ('9BYOSN946A'), ('9BYS190SM2'), ('9BYS59SA2N'), ('9BYSOMN3N1'),
            ('9BYST2GA69'), ('9BYT7A2M2O'), ('9BZ10SSO10'), ('9BZ141NMC2'), ('9BZ15ON3O8'), ('9BZ191J8OO'), ('9BZ1AOM3N8'), ('9BZ22I09A8'), ('9BZ38LL5MM'), ('9BZ71M61S3'),
            ('9BZ7SOM201'), ('9BZ9119M0J'), ('9BZA6GJT6L'), ('9BZCO2GA94'), ('9BZCS6OT94'), ('9BZI0S6CSM'), ('9BZI21C26L'), ('9BZJ55SO4A'), ('9BZL3L1CS1'), ('9BZM36C3MM'),
            ('9BZMMOM6ON'), ('9BZO4C1S0M'), ('9BZS2ST1CS'), ('9BZS54032L'), ('9BZSA2N3OM'), ('9BZSA9632M'), ('9BZSOJ9J93'), ('9BZSTOMSA2'), ('9BZT13J8SN'), ('A51QMI6IBF'),
            ('AB5GBIOYD3'), ('AJ5XQ8640E'), ('B0CKR5HU8C'), ('BGDA1VQOLZ'), ('BGBKG6TM1S'), ('BW2O3VIGL9'), ('CINAK5N1MV'), ('D3G5KP2NFQ'), ('D7F22FG5QR'), ('EFXJWGG5GC'),
            ('ENVQ1TNW9V'), ('F0GDAY74ZP'), ('F4K0HCI3BX'), ('FK9XQZ1MGR'), ('FS9YLSJWLG'), ('FUGNVIJWU8'), ('GHTNMF7727'), ('IKDUZCLKDU'), ('JXLFJ824NO'), ('L7H1W2PHU6'),
            ('LBPEPJ7MSE'), ('M28ST7P6ZS'), ('NCMQIP3M3C'), ('PL0B5ER5G3'), ('PPG19HFA5W'), ('Q8BB6LMM80'), ('QLBLA9NM6A'), ('R2BWFBJS7A'), ('R4FNXSI23Y'), ('SPGCUZ5SO6'),
            ('T035E5K6WQ'), ('TOGZAEVZ0K'), ('UJ6IC6QYVU'), ('XMABPI8SDB'), ('YQV101FLPR'), ('YZX67PVJW9'), ('Z1OH7VNMNP'), ('Z3C6TXV5UQ'), ('Z3TIAXD3BP'), ('Z472LRDO4K'),
            ('Z783F3OS3R'), ('ZH3HA47CM1'), ('ZQYE71NN20'), ('ZQZQP1TCOJ'), ('ZWCQJ5QTCO')
    ) AS t(merchant_id)
),

-- 1. Dimensión Client deduplicada (Productos seleccionados y habilitación de depósitos)
dim_client_dedup AS (
    SELECT
        UPPER(TRIM(CAST(merchant_id AS VARCHAR))) AS merchant_id,
        merchant_name,
        status AS merchant_status,
        selected_products,
        is_deposit_retrofit_enabled,
        ROW_NUMBER() OVER (
            PARTITION BY UPPER(TRIM(CAST(merchant_id AS VARCHAR)))
            ORDER BY last_update_event_date DESC NULLS LAST, creation_date DESC NULLS LAST
        ) AS rn
    FROM awsdatacatalog.bold_gold_growth.dim_client
    WHERE UPPER(TRIM(CAST(merchant_id AS VARCHAR))) IN (SELECT merchant_id FROM input_merchants)
),

-- 2. Dimensión Onboarding deduplicada (Cuentas bancarias / Cuenta Bold de depósito)
dim_onboarding_dedup AS (
    SELECT
        UPPER(TRIM(CAST(merchant_id AS VARCHAR))) AS merchant_id,
        bank_account_id,
        bank_account_name,
        bank_account_type,
        bank_account_ally_id,
        ROW_NUMBER() OVER (
            PARTITION BY UPPER(TRIM(CAST(merchant_id AS VARCHAR)))
            ORDER BY onboarding_completion_date DESC NULLS LAST
        ) AS rn
    FROM awsdatacatalog.bold_gold_growth.dim_merchant_onboarding
    WHERE UPPER(TRIM(CAST(merchant_id AS VARCHAR))) IN (SELECT merchant_id FROM input_merchants)
),

-- 3. Mart Merchant Enrich deduplicado (Fecha consolidada de 1ra tx aprobada SONOQR)
mart_merchant_enrich_dedup AS (
    SELECT
        UPPER(TRIM(CAST(merchant_id AS VARCHAR))) AS merchant_id,
        _1st_mpos_sono_qr_transaction_approved_date AS fecha_1ra_tx_sonoqr_mart,
        ROW_NUMBER() OVER (
            PARTITION BY UPPER(TRIM(CAST(merchant_id AS VARCHAR)))
            ORDER BY load_datetime DESC NULLS LAST, last_transaction_approved_date DESC NULLS LAST
        ) AS rn
    FROM awsdatacatalog.bold_gold_growth.mart_merchant_enrich
    WHERE UPPER(TRIM(CAST(merchant_id AS VARCHAR))) IN (SELECT merchant_id FROM input_merchants)
),

-- 4. Conteo de terminales SONOQR vinculados/asignados en el parque activo
terminales_sonoqr AS (
    SELECT
        UPPER(TRIM(CAST(last_terminal_match_merchant_id AS VARCHAR))) AS merchant_id,
        COUNT(DISTINCT UPPER(TRIM(terminal_serial))) AS cantidad_sonoqr
    FROM awsdatacatalog.bold_gold_terminals.mart_terminal_enrich
    WHERE last_terminal_match_merchant_id IS NOT NULL
      AND UPPER(TRIM(CAST(last_terminal_match_merchant_id AS VARCHAR))) IN (SELECT merchant_id FROM input_merchants)
      AND (
          UPPER(model_name_category) LIKE '%SONO%QR%' 
          OR UPPER(terminal_model) LIKE '%SONO%QR%'
      )
    GROUP BY UPPER(TRIM(CAST(last_terminal_match_merchant_id AS VARCHAR)))
),

-- 5. Primera transacción histórica con terminal SONOQR en tabla operativa de finanzas
tx_sonoqr_primera AS (
    SELECT
        UPPER(TRIM(CAST(t.merchant_id AS VARCHAR))) AS merchant_id,
        MIN(t.creation_datetime) AS fecha_activacion_sonoqr_tx
    FROM awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction t
    INNER JOIN awsdatacatalog.bold_gold_terminals.mart_terminal_enrich term
        ON UPPER(TRIM(t.terminal_serial)) = UPPER(TRIM(term.terminal_serial))
    WHERE UPPER(TRIM(CAST(t.merchant_id AS VARCHAR))) IN (SELECT merchant_id FROM input_merchants)
      AND t.terminal_serial IS NOT NULL
      AND COALESCE(t.tpv, 0) > 0
      AND (
          UPPER(term.model_name_category) LIKE '%SONO%QR%' 
          OR UPPER(term.terminal_model) LIKE '%SONO%QR%'
      )
    GROUP BY UPPER(TRIM(CAST(t.merchant_id AS VARCHAR)))
)

-- Consolidado Final de SONOQR y Cuenta Bold
SELECT
    p.fecha_reporte,
    inp.merchant_id,
    COALESCE(dc.merchant_name, 'SIN_INFORMACION_MAESTRA') AS nombre_comercio,
    dc.merchant_status,
    
    -- Atributos SONOQR
    CASE 
        WHEN COALESCE(term.cantidad_sonoqr, 0) > 0 
          OR me.fecha_1ra_tx_sonoqr_mart IS NOT NULL 
          OR txs.fecha_activacion_sonoqr_tx IS NOT NULL 
          OR UPPER(COALESCE(dc.selected_products, '')) LIKE '%SONO%QR%'
        THEN 'SI'
        ELSE 'NO'
    END AS tiene_sonoqr,
    
    COALESCE(term.cantidad_sonoqr, 0) AS cantidad_sonoqr,
    
    COALESCE(
        txs.fecha_activacion_sonoqr_tx,
        me.fecha_1ra_tx_sonoqr_mart
    ) AS fecha_activacion_sonoqr,
    
    -- Atributos Cuenta Bold
    CASE 
        WHEN NULLIF(TRIM(o.bank_account_id), '') IS NOT NULL 
          OR dc.is_deposit_retrofit_enabled = TRUE
          OR UPPER(COALESCE(o.bank_account_name, '')) LIKE '%BOLD%'
        THEN 'SI'
        ELSE 'NO'
    END AS tiene_cuenta_bold,
    
    COALESCE(
        NULLIF(TRIM(o.bank_account_id), ''),
        'SIN_CUENTA_REGISTRADA'
    ) AS numero_cuenta_bold,
    
    o.bank_account_name AS nombre_banco_registrado,
    o.bank_account_type AS tipo_cuenta_registrada

FROM input_merchants inp
CROSS JOIN parametros p
LEFT JOIN (SELECT * FROM dim_client_dedup WHERE rn = 1) dc ON inp.merchant_id = dc.merchant_id
LEFT JOIN (SELECT * FROM dim_onboarding_dedup WHERE rn = 1) o ON inp.merchant_id = o.merchant_id
LEFT JOIN (SELECT * FROM mart_merchant_enrich_dedup WHERE rn = 1) me ON inp.merchant_id = me.merchant_id
LEFT JOIN terminales_sonoqr term ON inp.merchant_id = term.merchant_id
LEFT JOIN tx_sonoqr_primera txs ON inp.merchant_id = txs.merchant_id
ORDER BY tiene_sonoqr DESC, cantidad_sonoqr DESC, tiene_cuenta_bold DESC;
