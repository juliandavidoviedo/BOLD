SELECT
  "__mb_source"."merchant_id" AS "merchant_id",
  "__mb_source"."nombre_legal_representative" AS "nombre_legal_representative",
  "__mb_source"."apellido_legal_representative" AS "apellido_legal_representative",
  "__mb_source"."telefono_legal_representative" AS "telefono_legal_representative",
  "__mb_source"."email_legal_representative" AS "email_legal_representative",
  "__mb_source"."nombre_comercio" AS "nombre_comercio",
  "__mb_source"."direccion_comercio" AS "direccion_comercio",
  "__mb_source"."categoria" AS "categoria",
  "__mb_source"."subcategoria" AS "subcategoria",
  "__mb_source"."verification_status_code" AS "verification_status_code",
  "__mb_source"."status_code" AS "status_code",
  "__mb_source"."sales_agent_email" AS "sales_agent_email",
  "__mb_source"."sales_reference" AS "sales_reference",
  "__mb_source"."departamento" AS "departamento",
  "__mb_source"."sales_source" AS "sales_source",
  "__mb_source"."bundle_name" AS "bundle_name",
  "__mb_source"."plan_name" AS "plan_name",
  "__mb_source"."profile_id" AS "profile_id",
  "__mb_source"."applied_date" AS "applied_date",
  "__mb_source"."master_merchant_id" AS "master_merchant_id",
  "__mb_source"."M_kyc" AS "M_kyc",
  "__mb_source"."reason_changed" AS "reason_changed",
  "__mb_source"."flag_master_merchant" AS "flag_master_merchant",
  "__mb_source"."flag_shared_doc_legal_representative" AS "flag_shared_doc_legal_representative",
  "__mb_source"."document_number" AS "document_number",
  "__mb_source"."document_type" AS "document_type",
  "__mb_source"."terminal_master_merchant_flag" AS "terminal_master_merchant_flag",
  "__mb_source"."cellphone_master_merchant_flag" AS "cellphone_master_merchant_flag",
  "__mb_source"."document_master_merchant_flag" AS "document_master_merchant_flag",
  "__mb_source"."legal_representative_master_merchant_flag" AS "legal_representative_master_merchant_flag",
  "__mb_source"."kyc_date" AS "kyc_date",
  "__mb_source"."_1st_terminal_match" AS "_1st_terminal_match",
  "__mb_source"."_1st_terminal_match_date_only" AS "_1st_terminal_match_date_only",
  "__mb_source"."_1st_terminal_match_time_only" AS "_1st_terminal_match_time_only",
  "__mb_source"."_1st_tx_date" AS "_1st_tx_date",
  "__mb_source"."_1st_tx_date_hora" AS "_1st_tx_date_hora",
  "__mb_source"."_1st_tx_date_date_only" AS "_1st_tx_date_date_only",
  "__mb_source"."_1st_tx_time_only" AS "_1st_tx_time_only",
  "__mb_source"."ultima_trx_date" AS "ultima_trx_date",
  "__mb_source"."_1st_tx_mpos_date" AS "_1st_tx_mpos_date",
  "__mb_source"."_1st_tx_mpos_date_only" AS "_1st_tx_mpos_date_only",
  "__mb_source"."_1st_tx_mpos_time_only" AS "_1st_tx_mpos_time_only",
  "__mb_source"."_1st_tx_link_date" AS "_1st_tx_link_date",
  "__mb_source"."_1st_tx_link_date_only" AS "_1st_tx_link_date_only",
  "__mb_source"."_1st_tx_link_time_only" AS "_1st_tx_link_time_only",
  "__mb_source"."_1st_tx_boton_date" AS "_1st_tx_boton_date",
  "__mb_source"."_1st_tx_boton_date_only" AS "_1st_tx_boton_date_only",
  "__mb_source"."_1st_tx_boton_time_only" AS "_1st_tx_boton_time_only",
  "__mb_source"."_1st_tx_nequi_date" AS "_1st_tx_nequi_date",
  "__mb_source"."_1st_tx_nequi_date_only" AS "_1st_tx_nequi_date_only",
  "__mb_source"."_1st_tx_nequi_time_only" AS "_1st_tx_nequi_time_only",
  "__mb_source"."_1st_tx_qr_date" AS "_1st_tx_qr_date",
  "__mb_source"."_1st_tx_qr_date_only" AS "_1st_tx_qr_date_only",
  "__mb_source"."_1st_tx_qr_time_only" AS "_1st_tx_qr_time_only",
  "__mb_source"."match_date" AS "match_date",
  "__mb_source"."match_date_only" AS "match_date_only",
  "__mb_source"."match_time_only" AS "match_time_only",
  "__mb_source"."mes_m1" AS "mes_m1",
  "__mb_source"."onboarding_end_date" AS "onboarding_end_date",
  "__mb_source"."rank_merchant_onboarding_date_by_merchant_document" AS "rank_merchant_onboarding_date_by_merchant_document",
  "__mb_source"."flag_first_merchant_active_vinc" AS "flag_first_merchant_active_vinc",
  "__mb_source"."flag_first_merchant_active_link" AS "flag_first_merchant_active_link",
  "__mb_source"."flag_first_merchant_active" AS "flag_first_merchant_active",
  "__mb_source"."flag_new_terminal_match" AS "flag_new_terminal_match",
  "__mb_source"."total_match_merchant" AS "total_match_merchant",
  "__mb_source"."flag_new_link_match" AS "flag_new_link_match",
  "__mb_source"."flag_link_match_same_month" AS "flag_link_match_same_month",
  "__mb_source"."merchant_id_tpv" AS "merchant_id_tpv",
  "__mb_source"."total_tpv" AS "total_tpv",
  "__mb_source"."total_mdr" AS "total_mdr",
  "__mb_source"."total_processing_cost" AS "total_processing_cost",
  "__mb_source"."total_net_revenues" AS "total_net_revenues",
  "__mb_source"."ntr" AS "ntr",
  "__mb_source"."ntr_m0" AS "ntr_m0",
  "__mb_source"."ntr_m1" AS "ntr_m1",
  "__mb_source"."ntr_m2" AS "ntr_m2",
  "__mb_source"."ntr_m3" AS "ntr_m3",
  "__mb_source"."tpv_m0_kyc" AS "tpv_m0_kyc",
  "__mb_source"."tpv_m1_kyc" AS "tpv_m1_kyc",
  "__mb_source"."tpv_m2_kyc" AS "tpv_m2_kyc",
  "__mb_source"."tpv_m3_kyc" AS "tpv_m3_kyc",
  "__mb_source"."net_revenues_m0_kyc" AS "net_revenues_m0_kyc",
  "__mb_source"."net_revenues_m1_kyc" AS "net_revenues_m1_kyc",
  "__mb_source"."net_revenues_m2_kyc" AS "net_revenues_m2_kyc",
  "__mb_source"."net_revenues_m3_kyc" AS "net_revenues_m3_kyc",
  "__mb_source"."tx_m0_kyc" AS "tx_m0_kyc",
  "__mb_source"."tx_m1_kyc" AS "tx_m1_kyc",
  "__mb_source"."tx_m2_kyc" AS "tx_m2_kyc",
  "__mb_source"."tx_m3_kyc" AS "tx_m3_kyc",
  "__mb_source"."tpv_m0_1tx" AS "tpv_m0_1tx",
  "__mb_source"."tpv_m1_1tx" AS "tpv_m1_1tx",
  "__mb_source"."tpv_m2_1tx" AS "tpv_m2_1tx",
  "__mb_source"."tpv_m3_1tx" AS "tpv_m3_1tx",
  "__mb_source"."tpv_m4_1tx" AS "tpv_m4_1tx",
  "__mb_source"."tpv_m5_1tx" AS "tpv_m5_1tx",
  "__mb_source"."net_revenues_m0_1tx" AS "net_revenues_m0_1tx",
  "__mb_source"."net_revenues_m1_1tx" AS "net_revenues_m1_1tx",
  "__mb_source"."net_revenues_m2_1tx" AS "net_revenues_m2_1tx",
  "__mb_source"."net_revenues_m3_1tx" AS "net_revenues_m3_1tx",
  "__mb_source"."net_revenues_m4_1tx" AS "net_revenues_m4_1tx",
  "__mb_source"."net_revenues_m5_1tx" AS "net_revenues_m5_1tx",
  "__mb_source"."tx_m0_1tx" AS "tx_m0_1tx",
  "__mb_source"."tx_m1_1tx" AS "tx_m1_1tx",
  "__mb_source"."tx_m2_1tx" AS "tx_m2_1tx",
  "__mb_source"."tx_m3_1tx" AS "tx_m3_1tx",
  "__mb_source"."tpv_m0_vinc_serial" AS "tpv_m0_vinc_serial",
  "__mb_source"."tpv_m1_vinc_serial" AS "tpv_m1_vinc_serial",
  "__mb_source"."tpv_m2_vinc_serial" AS "tpv_m2_vinc_serial",
  "__mb_source"."tpv_m3_vinc_serial" AS "tpv_m3_vinc_serial",
  "__mb_source"."net_revenues_m0_vinc_serial" AS "net_revenues_m0_vinc_serial",
  "__mb_source"."net_revenues_m1_vinc_serial" AS "net_revenues_m1_vinc_serial",
  "__mb_source"."net_revenues_m2_vinc_serial" AS "net_revenues_m2_vinc_serial",
  "__mb_source"."net_revenues_m3_vinc_serial" AS "net_revenues_m3_vinc_serial",
  "__mb_source"."tx_m0_vinc_serial" AS "tx_m0_vinc_serial",
  "__mb_source"."tx_m1_vinc_serial" AS "tx_m1_vinc_serial",
  "__mb_source"."tx_m2_vinc_serial" AS "tx_m2_vinc_serial",
  "__mb_source"."tx_m3_vinc_serial" AS "tx_m3_vinc_serial",
  "__mb_source"."tpv_kyc_d0" AS "tpv_kyc_d0",
  "__mb_source"."tpv_kyc_d1" AS "tpv_kyc_d1",
  "__mb_source"."tpv_kyc_d2" AS "tpv_kyc_d2",
  "__mb_source"."tpv_kyc_d3" AS "tpv_kyc_d3",
  "__mb_source"."tpv_kyc_d4" AS "tpv_kyc_d4",
  "__mb_source"."tpv_kyc_d5" AS "tpv_kyc_d5",
  "__mb_source"."tpv_kyc_d6" AS "tpv_kyc_d6",
  "__mb_source"."tpv_kyc_d7" AS "tpv_kyc_d7",
  "__mb_source"."tpv_kyc_d8" AS "tpv_kyc_d8",
  "__mb_source"."tpv_kyc_d9" AS "tpv_kyc_d9",
  "__mb_source"."tpv_kyc_d10" AS "tpv_kyc_d10",
  "__mb_source"."tpv_kyc_d11" AS "tpv_kyc_d11",
  "__mb_source"."tpv_kyc_d12" AS "tpv_kyc_d12",
  "__mb_source"."tpv_kyc_d13" AS "tpv_kyc_d13",
  "__mb_source"."tpv_kyc_d14" AS "tpv_kyc_d14",
  "__mb_source"."tpv_kyc_d15" AS "tpv_kyc_d15",
  "__mb_source"."tpv_kyc_d16" AS "tpv_kyc_d16",
  "__mb_source"."tpv_kyc_d17" AS "tpv_kyc_d17",
  "__mb_source"."tpv_kyc_d18" AS "tpv_kyc_d18",
  "__mb_source"."tpv_kyc_d19" AS "tpv_kyc_d19",
  "__mb_source"."tpv_kyc_d20" AS "tpv_kyc_d20",
  "__mb_source"."tpv_kyc_d21" AS "tpv_kyc_d21",
  "__mb_source"."tpv_kyc_d22" AS "tpv_kyc_d22",
  "__mb_source"."tpv_kyc_d23" AS "tpv_kyc_d23",
  "__mb_source"."tpv_kyc_d24" AS "tpv_kyc_d24",
  "__mb_source"."tpv_kyc_d25" AS "tpv_kyc_d25",
  "__mb_source"."tpv_kyc_d26" AS "tpv_kyc_d26",
  "__mb_source"."tpv_kyc_d27" AS "tpv_kyc_d27",
  "__mb_source"."tpv_kyc_d28" AS "tpv_kyc_d28",
  "__mb_source"."tpv_kyc_d29" AS "tpv_kyc_d29",
  "__mb_source"."tpv_kyc_d30" AS "tpv_kyc_d30",
  "__mb_source"."tpv_1tx_d0" AS "tpv_1tx_d0",
  "__mb_source"."tpv_1tx_d1" AS "tpv_1tx_d1",
  "__mb_source"."tpv_1tx_d2" AS "tpv_1tx_d2",
  "__mb_source"."tpv_1tx_d3" AS "tpv_1tx_d3",
  "__mb_source"."tpv_1tx_d4" AS "tpv_1tx_d4",
  "__mb_source"."tpv_1tx_d5" AS "tpv_1tx_d5",
  "__mb_source"."tpv_1tx_d6" AS "tpv_1tx_d6",
  "__mb_source"."tpv_1tx_d7" AS "tpv_1tx_d7",
  "__mb_source"."tpv_1tx_d8" AS "tpv_1tx_d8",
  "__mb_source"."tpv_1tx_d9" AS "tpv_1tx_d9",
  "__mb_source"."tpv_1tx_d10" AS "tpv_1tx_d10",
  "__mb_source"."tpv_1tx_d11" AS "tpv_1tx_d11",
  "__mb_source"."tpv_1tx_d12" AS "tpv_1tx_d12",
  "__mb_source"."tpv_1tx_d13" AS "tpv_1tx_d13",
  "__mb_source"."tpv_1tx_d14" AS "tpv_1tx_d14",
  "__mb_source"."tpv_1tx_d15" AS "tpv_1tx_d15",
  "__mb_source"."tpv_1tx_d16" AS "tpv_1tx_d16",
  "__mb_source"."tpv_1tx_d17" AS "tpv_1tx_d17",
  "__mb_source"."tpv_1tx_d18" AS "tpv_1tx_d18",
  "__mb_source"."tpv_1tx_d19" AS "tpv_1tx_d19",
  "__mb_source"."tpv_1tx_d20" AS "tpv_1tx_d20",
  "__mb_source"."tpv_1tx_d21" AS "tpv_1tx_d21",
  "__mb_source"."tpv_1tx_d22" AS "tpv_1tx_d22",
  "__mb_source"."tpv_1tx_d23" AS "tpv_1tx_d23",
  "__mb_source"."tpv_1tx_d24" AS "tpv_1tx_d24",
  "__mb_source"."tpv_1tx_d25" AS "tpv_1tx_d25",
  "__mb_source"."tpv_1tx_d26" AS "tpv_1tx_d26",
  "__mb_source"."tpv_1tx_d27" AS "tpv_1tx_d27",
  "__mb_source"."tpv_1tx_d28" AS "tpv_1tx_d28",
  "__mb_source"."tpv_1tx_d29" AS "tpv_1tx_d29",
  "__mb_source"."tpv_1tx_d30" AS "tpv_1tx_d30",
  "__mb_source"."tpv_m0_1tx_mpos" AS "tpv_m0_1tx_mpos",
  "__mb_source"."tpv_m1_1tx_mpos" AS "tpv_m1_1tx_mpos",
  "__mb_source"."tpv_m2_1tx_mpos" AS "tpv_m2_1tx_mpos",
  "__mb_source"."tpv_m3_1tx_mpos" AS "tpv_m3_1tx_mpos",
  "__mb_source"."tpv_m4_1tx_mpos" AS "tpv_m4_1tx_mpos",
  "__mb_source"."tpv_m5_1tx_mpos" AS "tpv_m5_1tx_mpos",
  "__mb_source"."tpv_m6_1tx_mpos" AS "tpv_m6_1tx_mpos",
  "__mb_source"."tpv_m0_1tx_link" AS "tpv_m0_1tx_link",
  "__mb_source"."tpv_m1_1tx_link" AS "tpv_m1_1tx_link",
  "__mb_source"."tpv_m2_1tx_link" AS "tpv_m2_1tx_link",
  "__mb_source"."tpv_m3_1tx_link" AS "tpv_m3_1tx_link",
  "__mb_source"."tpv_m4_1tx_link" AS "tpv_m4_1tx_link",
  "__mb_source"."tpv_m5_1tx_link" AS "tpv_m5_1tx_link",
  "__mb_source"."tpv_m6_1tx_link" AS "tpv_m6_1tx_link",
  "__mb_source"."tpv_m0_1tx_boton" AS "tpv_m0_1tx_boton",
  "__mb_source"."tpv_m1_1tx_boton" AS "tpv_m1_1tx_boton",
  "__mb_source"."tpv_m2_1tx_boton" AS "tpv_m2_1tx_boton",
  "__mb_source"."tpv_m3_1tx_boton" AS "tpv_m3_1tx_boton",
  "__mb_source"."tpv_m4_1tx_boton" AS "tpv_m4_1tx_boton",
  "__mb_source"."tpv_m5_1tx_boton" AS "tpv_m5_1tx_boton",
  "__mb_source"."tpv_m6_1tx_boton" AS "tpv_m6_1tx_boton",
  "__mb_source"."tpv_m0_1tx_nequi" AS "tpv_m0_1tx_nequi",
  "__mb_source"."tpv_m1_1tx_nequi" AS "tpv_m1_1tx_nequi",
  "__mb_source"."tpv_m2_1tx_nequi" AS "tpv_m2_1tx_nequi",
  "__mb_source"."tpv_m3_1tx_nequi" AS "tpv_m3_1tx_nequi",
  "__mb_source"."tpv_m4_1tx_nequi" AS "tpv_m4_1tx_nequi",
  "__mb_source"."tpv_m5_1tx_nequi" AS "tpv_m5_1tx_nequi",
  "__mb_source"."tpv_m6_1tx_nequi" AS "tpv_m6_1tx_nequi",
  "__mb_source"."tpv_m0_1tx_qr" AS "tpv_m0_1tx_qr",
  "__mb_source"."tpv_m1_1tx_qr" AS "tpv_m1_1tx_qr",
  "__mb_source"."tpv_m2_1tx_qr" AS "tpv_m2_1tx_qr",
  "__mb_source"."tpv_m3_1tx_qr" AS "tpv_m3_1tx_qr",
  "__mb_source"."tpv_m4_1tx_qr" AS "tpv_m4_1tx_qr",
  "__mb_source"."tpv_m5_1tx_qr" AS "tpv_m5_1tx_qr",
  "__mb_source"."tpv_m6_1tx_qr" AS "tpv_m6_1tx_qr"
FROM
  (
    -- ------------------------------------------------------------------------------------------------------------------------------
    -- ------------------------------------------------------------------------------------------------------------------------------
    -- reporte outbound V3
    -- ------------------------------------------------------------------------------------------------------------------------------
    -- ------------------------------------------------------------------------------------------------------------------------------
    -- tabla de vinculaciones de terminales
    with base_match as (
      select
        ter_match.terminal_serial,
        ter_match.merchant_id,
        ter_match.datetime_temrinal_merchant,
        ter_match.cuenta_match_serial,
        ter_match.cuenta_match_merchant,
        max(ter_match.cuenta_match_serial) over (partition by ter_match.terminal_serial) as total_match_serial,
        max(ter_match.cuenta_match_merchant) over (partition by ter_match.merchant_id) as total_match_merchant
      from
        (
          select
            --*
            terminal_serial,
            current_merchant_id as merchant_id,
            last_modification_datetime as datetime_temrinal_merchant,
            row_number() over (
              partition by terminal_serial
              order by
                last_modification_datetime asc
            ) as cuenta_match_serial,
            row_number() over (
              partition by current_merchant_id
              order by
                last_modification_datetime
            ) as cuenta_match_merchant
          from
            bold_gold_terminals.fact_terminal_history
          where
            terminal_status = 'BINDED'
        ) ter_match
    ),
    primera_vinculacion_comercio as (
      select
        terminal_serial,
        merchant_id,
        datetime_temrinal_merchant,
        cuenta_match_serial,
        cuenta_match_merchant,
        total_match_serial,
        total_match_merchant
      from
        base_match
      where
        cuenta_match_merchant = 1
    ),
    master_merchant_linaje_enrich as (
      SELECT
        merchant_id,
        ARRAY_JOIN(
          ARRAY_AGG(
            CONCAT(
              merchant_id,
              ' | ',
              parent_merchant_id,
              '=[',
              reason_changed,
              ']'
            )
          ),
          ' -> '
        ) AS merged_reason,
        sum(
          case
            when reason_changed like '%TERMINAL%' then 1
            else 0
          end
        ) as terminal_master_merchant_flag,
        sum(
          case
            when reason_changed like '%CELLPHONE%' then 1
            else 0
          end
        ) as cellphone_master_merchant_flag,
        sum(
          case
            when reason_changed like '%B_SHARED_DOCUMENT_MERCHANT%' then 1
            else 0
          end
        ) as document_master_merchant_flag,
        sum(
          case
            when reason_changed like '%REPRESENTATIVE%' then 1
            else 0
          end
        ) as legal_representative_master_merchant_flag,
        sum(
          case
            when reason_changed like '%C_SHARED_DOCUMENT_LEGAL_REPRESENTATIVE%' then 1
            else 0
          end
        ) as flag_shared_doc_legal_representative
      FROM
        bold_gold_growth.mart_master_merchant_lineage --WHERE merchant_id in('B2APSKB3LT')--, '2UREJO0MMK')
      GROUP BY
        merchant_id
    ),
    info_pricing as (
      -- pendeinte de que la info este OK
      select
        merchant_id,
        bundle_name,
        plan_name,
        profile_id,
        applied_date
      from
        (
          select
            --*
            merchant_id,
            bundle_name,
            plan_name,
            profile_id,
            applied_date,
            row_number() over (
              partition by merchant_id
              order by
                applied_date desc
            ) as order_
          from
            bold_gold_accounting.fact_historical_pricing
        )
      where
        order_ = 1
    ),
    merchant_contacto as (
      select
        m.id as merchant_id,
        p.name as nombre_legal_representative,
        p.last_name as apellido_legal_representative,
        p.cellphone_number as telefono_legal_representative,
        p.email as email_legal_representative,
        m.name as nombre_comercio,
        m.address as direccion_comercio,
        m.category__slug as categoria,
        m.category__subcategory__slug as subcategoria,
        m.manual_verification_status__reason_code as verification_status_code,
        m.status__status_code as status_code,
        m.sales_agent_email,
        m.sales_reference,
        m.location_department__code as departamento,
        case
          when m.sales_source IN ('INBOUND', NULL) then 'INBOUND'
          when m.sales_source = 'REFERRED' then 'REFERRED'
          when m.sales_source = 'RETAIL' then 'RETAIL'
          when m.sales_source IN ('HUBS', 'OUTBOUND', 'STANDS', 'BOLD_STORE', 'EVENTS') then 'HUBS'
          when m.sales_source IN ('DISTRIBUTOR', 'ALLIANCE') then 'DISTRIBUTOR'
          when m.sales_source = 'SMB' then 'SMB'
          when m.sales_source in ('ENTERPRISE') then 'ENTERPRISE'
          when m.sales_source in ('ONLINE_PAYM') then 'ONLINE_PAYMENTS'
          else m.sales_source
        end as sales_source
      from
        bold_gold_payments.dim_merchant m
        LEFT join bold_gold_growth.dim_person p on m.id = p.merchant_id
        and m.legal_representative_id = p.id
    ),
    atributos_calculados as (
      select
        en.merchant_id,
        en.master_merchant_id,
        date_diff(
          'month',
          date_trunc('month', en.kyc_verification_status_date),
          date_trunc('month', current_date)
        ) as M_kyc,
        m_lin.merged_reason as reason_changed,
        case
          when m_lin.merged_reason LIKE '%NO_CHANGE%' then 1
          when m_lin.merged_reason is null then 1
          when m_lin.merged_reason = '' then 1
          ELSE 0
        END flag_master_merchant,
        m.document_number,
        m.document_type,
        m_lin.terminal_master_merchant_flag,
        m_lin.cellphone_master_merchant_flag,
        m_lin.document_master_merchant_flag,
        m_lin.legal_representative_master_merchant_flag,
        m_lin.flag_shared_doc_legal_representative,
        en.kyc_verification_status_date as kyc_date,
        t_vinc.datetime_temrinal_merchant as _1st_terminal_match,
        en._1st_transaction_approved_date as _1st_tx_date,
        en._1st_transaction_approved_date as _1st_tx_date_hora,
        en.last_transaction_approved_date as ultima_trx_date,
        en._1st_mpos_transaction_approved_date as _1st_tx_mpos_date,
        en._1st_link_transaction_approved_date as _1st_tx_link_date,
        en._1st_btn_transaction_approved_date as _1st_tx_boton_date,
        en._1st_nequi_transaction_approved_date as _1st_tx_nequi_date,
        en._1st_qr_transaction_approved_date as _1st_tx_qr_date,
        en._1st_match_date as match_date,
        date_add(
          'month',
          1,
          DATE_TRUNC(
            'month',
            cast(en.kyc_verification_status_date as date)
          )
        ) AS mes_m1,
        m.onboarding_end_date,
        row_number() over (
          partition by m.document_number,
          m.document_type
          order by
            en.kyc_verification_status_date
        ) as order_,
        row_number() over (
          partition by m.document_number,
          m.document_type
          order by
            t_vinc.datetime_temrinal_merchant
        ) as flag_first_merchant_active_vinc,
        row_number() over (
          partition by m.document_number,
          m.document_type
          order by
            en._1st_link_transaction_approved_date
        ) as flag_first_merchant_active_link,
        case
          when en.merchant_id = en.master_merchant_id then 1
          else 0
        end as flag_first_merchant_active,
        case
          when t_vinc.cuenta_match_serial = t_vinc.cuenta_match_merchant then 1
          else 0
        end as flag_new_terminal_match,
        case
          when en._1st_link_transaction_approved_date is not null
          and (
            t_vinc.datetime_temrinal_merchant is null
            or en._1st_link_transaction_approved_date < t_vinc.datetime_temrinal_merchant
          ) then 1
          when en._1st_nequi_transaction_approved_date is not null
          and (
            t_vinc.datetime_temrinal_merchant is null
            or en._1st_nequi_transaction_approved_date < t_vinc.datetime_temrinal_merchant
          ) then 1 --		   when en._1st_qr_transaction_approved_date is not null and
          --				(t_vinc.datetime_temrinal_merchant is null or
          --				en._1st_qr_transaction_approved_date < t_vinc.datetime_temrinal_merchant)
          --				then 1
          --		   when en._1st_btn_transaction_approved_date is not null and
          --				(t_vinc.datetime_temrinal_merchant is null or
          --				en._1st_btn_transaction_approved_date < t_vinc.datetime_temrinal_merchant)
          --				then 1
          else 0
        end as flag_new_link_match --flag_new_online_match
,
        case
          when en._1st_link_transaction_approved_date is not null
          and (
            t_vinc.datetime_temrinal_merchant is null
            or (
              en._1st_link_transaction_approved_date < t_vinc.datetime_temrinal_merchant
              and date_trunc('month', en._1st_link_transaction_approved_date) = date_trunc('month', t_vinc.datetime_temrinal_merchant)
            )
          ) then 1
          when en._1st_nequi_transaction_approved_date is not null
          and (
            t_vinc.datetime_temrinal_merchant is null
            or (
              en._1st_nequi_transaction_approved_date < t_vinc.datetime_temrinal_merchant
              and date_trunc('month', en._1st_nequi_transaction_approved_date) = date_trunc('month', t_vinc.datetime_temrinal_merchant)
            )
          ) then 1 --			when en._1st_qr_transaction_approved_date is not null and
          --	            (t_vinc.datetime_temrinal_merchant is null or
          --				(en._1st_qr_transaction_approved_date < t_vinc.datetime_temrinal_merchant and
          --				date_trunc('month', en._1st_qr_transaction_approved_date) = date_trunc('month', t_vinc.datetime_temrinal_merchant)))
          --				then 1
          --			when en._1st_btn_transaction_approved_date is not null and
          --	            (t_vinc.datetime_temrinal_merchant is null or
          --				(en._1st_btn_transaction_approved_date < t_vinc.datetime_temrinal_merchant and
          --				date_trunc('month', en._1st_btn_transaction_approved_date) = date_trunc('month', t_vinc.datetime_temrinal_merchant)))
          --				then 1
          else 0
        end as flag_link_match_same_month --flag_online_match_same_month
,
        t_vinc.total_match_merchant
      from
        bold_gold_growth.mart_merchant_enrich en
        left join primera_vinculacion_comercio t_vinc on en.merchant_id = t_vinc.merchant_id
        left join bold_gold_payments.dim_merchant m on en.merchant_id = m.id --left join bold_gold_growth.mart_master_merchant_linaje m_lin
        --on en.merchant_id = m_lin.merchant_id
        left join master_merchant_linaje_enrich m_lin on en.merchant_id = m_lin.merchant_id
    ),
    all_general_tx as (
      ----- Aqui Melissa Correa hizo un ajuste para reemplazar una tabla que ya no existe si necesita la consulta inicial por favor escribir x slack
      select
        t.merchant_id,
        at_.kyc_date,
        at_._1st_terminal_match,
        at_._1st_tx_date,
        at_._1st_tx_mpos_date,
        at_._1st_tx_link_date,
        at_._1st_tx_boton_date,
        at_._1st_tx_nequi_date,
        at_._1st_tx_qr_date -- Se reemplaza d.date por t.creation_datetime
,
        date_diff(
          'month',
          date_trunc('month', at_.kyc_date),
          date_trunc('month', t.creation_datetime)
        ) as m_kyc,
        date_diff(
          'month',
          date_trunc('month', at_._1st_tx_date),
          date_trunc('month', t.creation_datetime)
        ) as m_1TX,
        date_diff(
          'month',
          date_trunc('month', at_._1st_terminal_match),
          date_trunc('month', t.creation_datetime)
        ) as m_vinc_serial,
        date_diff(
          'month',
          date_trunc('month', at_._1st_tx_mpos_date),
          date_trunc('month', t.creation_datetime)
        ) as m_1TX_mpos,
        date_diff(
          'month',
          date_trunc('month', at_._1st_tx_link_date),
          date_trunc('month', t.creation_datetime)
        ) as m_1TX_link,
        date_diff(
          'month',
          date_trunc('month', at_._1st_tx_boton_date),
          date_trunc('month', t.creation_datetime)
        ) as m_1TX_boton,
        date_diff(
          'month',
          date_trunc('month', at_._1st_tx_nequi_date),
          date_trunc('month', t.creation_datetime)
        ) as m_1TX_nequi,
        date_diff(
          'month',
          date_trunc('month', at_._1st_tx_qr_date),
          date_trunc('month', t.creation_datetime)
        ) as m_1TX_qr,
        date_diff(
          'day',
          date_trunc('day', at_.kyc_date),
          date_trunc('day', t.creation_datetime)
        ) as day_kyc,
        date_diff(
          'day',
          date_trunc('day', at_._1st_tx_date),
          date_trunc('day', t.creation_datetime)
        ) as day_1TX,
        t.transaction_id,
        t.creation_datetime as date -- Mantenemos el alias 'date' por si se usa en capas posteriores
,
        CASE
          when t.payment_type = 'PAY_BY_LINK' then 'LINK'
          when t.payment_type = 'PAY_BY_BTN' then 'BOTON'
          when t.payment_method__type in ('NEQUI', 'DAVIPLATA') then 'WALLETS'
          when t.payment_method__type in ('QR_BOLD') then 'QR'
          when t.payment_type in ('SOFT_POS') then 'DATAFONO'
          when t.payment_type in ('POS')
          and t.model in ('QPOS', 'QPOS_CUTE', 'QPOS_MINI') then 'DATAFONO'
          when t.payment_type in ('POS')
          and t.model in ('QPOS_PLUS') then 'DATAFONO'
          when t.payment_type in ('POS')
          and t.model in ('D20') then 'DATAFONO'
          when t.payment_type in ('POS')
          and t.model in ('N86') then 'DATAFONO'
          else t.payment_type
        end as dispositivo_transaccional,
        t.tpv,
        t.mdr,
        t.processing_cost,
        (t.mdr - t.processing_cost) as net_revenues
      from
        bold_gold_finance.mart_tpv_daily_by_transaction t
        left join atributos_calculados at_ on t.merchant_id = at_.merchant_id -- Se eliminó por completo el INNER JOIN a bold_gold_core.dim_date
    ),
    info_tpv_agregada as (
      select
        merchant_id as merchant_id_tpv,
        sum(tpv) as total_tpv,
        sum(mdr) as total_mdr,
        sum(processing_cost) as total_processing_cost,
        sum(net_revenues) as total_net_revenues,
        cast(
          (
            cast(sum(net_revenues) as real) / cast(sum(tpv) as real)
          ) as real
        ) * 100 as ntr,
        cast(
          (
            cast(
              sum(
                case
                  when m_1tx = 0 then net_revenues
                end
              ) as real
            ) / cast(
              sum(
                case
                  when m_1tx = 0 then tpv
                end
              ) as real
            )
          ) as real
        ) * 100 as ntr_m0,
        cast(
          (
            cast(
              sum(
                case
                  when m_1tx = 1 then net_revenues
                end
              ) as real
            ) / cast(
              sum(
                case
                  when m_1tx = 1 then tpv
                end
              ) as real
            )
          ) as real
        ) * 100 as ntr_m1,
        cast(
          (
            cast(
              sum(
                case
                  when m_1tx = 2 then net_revenues
                end
              ) as real
            ) / cast(
              sum(
                case
                  when m_1tx = 2 then tpv
                end
              ) as real
            )
          ) as real
        ) * 100 as ntr_m2,
        cast(
          (
            cast(
              sum(
                case
                  when m_1tx = 3 then net_revenues
                end
              ) as real
            ) / cast(
              sum(
                case
                  when m_1tx = 3 then tpv
                end
              ) as real
            )
          ) as real
        ) * 100 as ntr_m3,
        sum(
          case
            when m_kyc = 0 then tpv
          end
        ) as tpv_m0_kyc,
        sum(
          case
            when m_kyc = 1 then tpv
          end
        ) as tpv_m1_kyc,
        sum(
          case
            when m_kyc = 2 then tpv
          end
        ) as tpv_m2_kyc,
        sum(
          case
            when m_kyc = 3 then tpv
          end
        ) as tpv_m3_kyc,
        sum(
          case
            when m_kyc = 0 then net_revenues
          end
        ) as net_revenues_m0_kyc,
        sum(
          case
            when m_kyc = 1 then net_revenues
          end
        ) as net_revenues_m1_kyc,
        sum(
          case
            when m_kyc = 2 then net_revenues
          end
        ) as net_revenues_m2_kyc,
        sum(
          case
            when m_kyc = 3 then net_revenues
          end
        ) as net_revenues_m3_kyc,
        count(
          distinct(
            case
              when m_kyc = 0 then transaction_id
            end
          )
        ) as tx_m0_kyc,
        count(
          distinct(
            case
              when m_kyc = 1 then transaction_id
            end
          )
        ) as tx_m1_kyc,
        count(
          distinct(
            case
              when m_kyc = 2 then transaction_id
            end
          )
        ) as tx_m2_kyc,
        count(
          distinct(
            case
              when m_kyc = 3 then transaction_id
            end
          )
        ) as tx_m3_kyc,
        sum(
          case
            when m_1tx = 0 then tpv
          end
        ) as tpv_m0_1tx,
        sum(
          case
            when m_1tx = 1 then tpv
          end
        ) as tpv_m1_1tx,
        sum(
          case
            when m_1tx = 2 then tpv
          end
        ) as tpv_m2_1tx,
        sum(
          case
            when m_1tx = 3 then tpv
          end
        ) as tpv_m3_1tx,
        sum(
          case
            when m_1tx = 4 then tpv
          end
        ) as tpv_m4_1tx,
        sum(
          case
            when m_1tx = 5 then tpv
          end
        ) as tpv_m5_1tx,
        sum(
          case
            when m_1tx = 0 then net_revenues
          end
        ) as net_revenues_m0_1tx,
        sum(
          case
            when m_1tx = 1 then net_revenues
          end
        ) as net_revenues_m1_1tx,
        sum(
          case
            when m_1tx = 2 then net_revenues
          end
        ) as net_revenues_m2_1tx,
        sum(
          case
            when m_1tx = 3 then net_revenues
          end
        ) as net_revenues_m3_1tx,
        sum(
          case
            when m_1tx = 4 then net_revenues
          end
        ) as net_revenues_m4_1tx,
        sum(
          case
            when m_1tx = 5 then net_revenues
          end
        ) as net_revenues_m5_1tx,
        count(
          distinct(
            case
              when m_1tX = 0 then transaction_id
            end
          )
        ) as tx_m0_1tx,
        count(
          distinct(
            case
              when m_1tx = 1 then transaction_id
            end
          )
        ) as tx_m1_1tx,
        count(
          distinct(
            case
              when m_1tx = 2 then transaction_id
            end
          )
        ) as tx_m2_1tx,
        count(
          distinct(
            case
              when m_1tx = 3 then transaction_id
            end
          )
        ) as tx_m3_1tx,
        sum(
          case
            when m_vinc_serial = 0 then tpv
          end
        ) as tpv_m0_vinc_serial,
        sum(
          case
            when m_vinc_serial = 1 then tpv
          end
        ) as tpv_m1_vinc_serial,
        sum(
          case
            when m_vinc_serial = 2 then tpv
          end
        ) as tpv_m2_vinc_serial,
        sum(
          case
            when m_vinc_serial = 3 then tpv
          end
        ) as tpv_m3_vinc_serial,
        sum(
          case
            when m_vinc_serial = 0 then net_revenues
          end
        ) as net_revenues_m0_vinc_serial,
        sum(
          case
            when m_vinc_serial = 1 then net_revenues
          end
        ) as net_revenues_m1_vinc_serial,
        sum(
          case
            when m_vinc_serial = 2 then net_revenues
          end
        ) as net_revenues_m2_vinc_serial,
        sum(
          case
            when m_vinc_serial = 3 then net_revenues
          end
        ) as net_revenues_m3_vinc_serial,
        count(
          distinct(
            case
              when m_vinc_serial = 1 then transaction_id
            end
          )
        ) as tx_m0_vinc_serial,
        count(
          distinct(
            case
              when m_vinc_serial = 1 then transaction_id
            end
          )
        ) as tx_m1_vinc_serial,
        count(
          distinct(
            case
              when m_vinc_serial = 2 then transaction_id
            end
          )
        ) as tx_m2_vinc_serial,
        count(
          distinct(
            case
              when m_vinc_serial = 3 then transaction_id
            end
          )
        ) as tx_m3_vinc_serial,
        sum(
          case
            when day_kyc = 0 then tpv
          end
        ) as tpv_kyc_d0,
        sum(
          case
            when day_kyc = 1 then tpv
          end
        ) as tpv_kyc_d1,
        sum(
          case
            when day_kyc = 2 then tpv
          end
        ) as tpv_kyc_d2,
        sum(
          case
            when day_kyc = 3 then tpv
          end
        ) as tpv_kyc_d3,
        sum(
          case
            when day_kyc = 4 then tpv
          end
        ) as tpv_kyc_d4,
        sum(
          case
            when day_kyc = 5 then tpv
          end
        ) as tpv_kyc_d5,
        sum(
          case
            when day_kyc = 6 then tpv
          end
        ) as tpv_kyc_d6,
        sum(
          case
            when day_kyc = 7 then tpv
          end
        ) as tpv_kyc_d7,
        sum(
          case
            when day_kyc = 8 then tpv
          end
        ) as tpv_kyc_d8,
        sum(
          case
            when day_kyc = 9 then tpv
          end
        ) as tpv_kyc_d9,
        sum(
          case
            when day_kyc = 10 then tpv
          end
        ) as tpv_kyc_d10,
        sum(
          case
            when day_kyc = 11 then tpv
          end
        ) as tpv_kyc_d11,
        sum(
          case
            when day_kyc = 12 then tpv
          end
        ) as tpv_kyc_d12,
        sum(
          case
            when day_kyc = 13 then tpv
          end
        ) as tpv_kyc_d13,
        sum(
          case
            when day_kyc = 14 then tpv
          end
        ) as tpv_kyc_d14,
        sum(
          case
            when day_kyc = 15 then tpv
          end
        ) as tpv_kyc_d15,
        sum(
          case
            when day_kyc = 16 then tpv
          end
        ) as tpv_kyc_d16,
        sum(
          case
            when day_kyc = 17 then tpv
          end
        ) as tpv_kyc_d17,
        sum(
          case
            when day_kyc = 18 then tpv
          end
        ) as tpv_kyc_d18,
        sum(
          case
            when day_kyc = 19 then tpv
          end
        ) as tpv_kyc_d19,
        sum(
          case
            when day_kyc = 20 then tpv
          end
        ) as tpv_kyc_d20,
        sum(
          case
            when day_kyc = 21 then tpv
          end
        ) as tpv_kyc_d21,
        sum(
          case
            when day_kyc = 22 then tpv
          end
        ) as tpv_kyc_d22,
        sum(
          case
            when day_kyc = 23 then tpv
          end
        ) as tpv_kyc_d23,
        sum(
          case
            when day_kyc = 24 then tpv
          end
        ) as tpv_kyc_d24,
        sum(
          case
            when day_kyc = 25 then tpv
          end
        ) as tpv_kyc_d25,
        sum(
          case
            when day_kyc = 26 then tpv
          end
        ) as tpv_kyc_d26,
        sum(
          case
            when day_kyc = 27 then tpv
          end
        ) as tpv_kyc_d27,
        sum(
          case
            when day_kyc = 28 then tpv
          end
        ) as tpv_kyc_d28,
        sum(
          case
            when day_kyc = 29 then tpv
          end
        ) as tpv_kyc_d29,
        sum(
          case
            when day_kyc = 30 then tpv
          end
        ) as tpv_kyc_d30,
        sum(
          case
            when day_1tx = 0 then tpv
          end
        ) as tpv_1tx_d0,
        sum(
          case
            when day_1tx = 1 then tpv
          end
        ) as tpv_1tx_d1,
        sum(
          case
            when day_1tx = 2 then tpv
          end
        ) as tpv_1tx_d2,
        sum(
          case
            when day_1tx = 3 then tpv
          end
        ) as tpv_1tx_d3,
        sum(
          case
            when day_1tx = 4 then tpv
          end
        ) as tpv_1tx_d4,
        sum(
          case
            when day_1tx = 5 then tpv
          end
        ) as tpv_1tx_d5,
        sum(
          case
            when day_1tx = 6 then tpv
          end
        ) as tpv_1tx_d6,
        sum(
          case
            when day_1tx = 7 then tpv
          end
        ) as tpv_1tx_d7,
        sum(
          case
            when day_1tx = 8 then tpv
          end
        ) as tpv_1tx_d8,
        sum(
          case
            when day_1tx = 9 then tpv
          end
        ) as tpv_1tx_d9,
        sum(
          case
            when day_1tx = 10 then tpv
          end
        ) as tpv_1tx_d10,
        sum(
          case
            when day_1tx = 11 then tpv
          end
        ) as tpv_1tx_d11,
        sum(
          case
            when day_1tx = 12 then tpv
          end
        ) as tpv_1tx_d12,
        sum(
          case
            when day_1tx = 13 then tpv
          end
        ) as tpv_1tx_d13,
        sum(
          case
            when day_1tx = 14 then tpv
          end
        ) as tpv_1tx_d14,
        sum(
          case
            when day_1tx = 15 then tpv
          end
        ) as tpv_1tx_d15,
        sum(
          case
            when day_1tx = 16 then tpv
          end
        ) as tpv_1tx_d16,
        sum(
          case
            when day_1tx = 17 then tpv
          end
        ) as tpv_1tx_d17,
        sum(
          case
            when day_1tx = 18 then tpv
          end
        ) as tpv_1tx_d18,
        sum(
          case
            when day_1tx = 19 then tpv
          end
        ) as tpv_1tx_d19,
        sum(
          case
            when day_1tx = 20 then tpv
          end
        ) as tpv_1tx_d20,
        sum(
          case
            when day_1tx = 21 then tpv
          end
        ) as tpv_1tx_d21,
        sum(
          case
            when day_1tx = 22 then tpv
          end
        ) as tpv_1tx_d22,
        sum(
          case
            when day_1tx = 23 then tpv
          end
        ) as tpv_1tx_d23,
        sum(
          case
            when day_1tx = 24 then tpv
          end
        ) as tpv_1tx_d24,
        sum(
          case
            when day_1tx = 25 then tpv
          end
        ) as tpv_1tx_d25,
        sum(
          case
            when day_1tx = 26 then tpv
          end
        ) as tpv_1tx_d26,
        sum(
          case
            when day_1tx = 27 then tpv
          end
        ) as tpv_1tx_d27,
        sum(
          case
            when day_1tx = 28 then tpv
          end
        ) as tpv_1tx_d28,
        sum(
          case
            when day_1tx = 29 then tpv
          end
        ) as tpv_1tx_d29,
        sum(
          case
            when day_1tx = 30 then tpv
          end
        ) as tpv_1tx_d30,
        sum(
          case
            when m_1tx_mpos = 0
            and dispositivo_transaccional = 'DATAFONO' then tpv
          end
        ) as tpv_m0_1tx_mpos,
        sum(
          case
            when m_1tx_mpos = 1
            and dispositivo_transaccional = 'DATAFONO' then tpv
          end
        ) as tpv_m1_1tx_mpos,
        sum(
          case
            when m_1tx_mpos = 2
            and dispositivo_transaccional = 'DATAFONO' then tpv
          end
        ) as tpv_m2_1tx_mpos,
        sum(
          case
            when m_1tx_mpos = 3
            and dispositivo_transaccional = 'DATAFONO' then tpv
          end
        ) as tpv_m3_1tx_mpos,
        sum(
          case
            when m_1tx_mpos = 4
            and dispositivo_transaccional = 'DATAFONO' then tpv
          end
        ) as tpv_m4_1tx_mpos,
        sum(
          case
            when m_1tx_mpos = 5
            and dispositivo_transaccional = 'DATAFONO' then tpv
          end
        ) as tpv_m5_1tx_mpos,
        sum(
          case
            when m_1tx_mpos = 6
            and dispositivo_transaccional = 'DATAFONO' then tpv
          end
        ) as tpv_m6_1tx_mpos,
        sum(
          case
            when m_1tx_link = 0
            and dispositivo_transaccional = 'LINK' then tpv
          end
        ) as tpv_m0_1tx_link,
        sum(
          case
            when m_1tx_link = 1
            and dispositivo_transaccional = 'LINK' then tpv
          end
        ) as tpv_m1_1tx_link,
        sum(
          case
            when m_1tx_link = 2
            and dispositivo_transaccional = 'LINK' then tpv
          end
        ) as tpv_m2_1tx_link,
        sum(
          case
            when m_1tx_link = 3
            and dispositivo_transaccional = 'LINK' then tpv
          end
        ) as tpv_m3_1tx_link,
        sum(
          case
            when m_1tx_link = 4
            and dispositivo_transaccional = 'LINK' then tpv
          end
        ) as tpv_m4_1tx_link,
        sum(
          case
            when m_1tx_link = 5
            and dispositivo_transaccional = 'LINK' then tpv
          end
        ) as tpv_m5_1tx_link,
        sum(
          case
            when m_1tx_link = 6
            and dispositivo_transaccional = 'LINK' then tpv
          end
        ) as tpv_m6_1tx_link,
        sum(
          case
            when m_1tx_boton = 0
            and dispositivo_transaccional = 'BOTON' then tpv
          end
        ) as tpv_m0_1tx_boton,
        sum(
          case
            when m_1tx_boton = 1
            and dispositivo_transaccional = 'BOTON' then tpv
          end
        ) as tpv_m1_1tx_boton,
        sum(
          case
            when m_1tx_boton = 2
            and dispositivo_transaccional = 'BOTON' then tpv
          end
        ) as tpv_m2_1tx_boton,
        sum(
          case
            when m_1tx_boton = 3
            and dispositivo_transaccional = 'BOTON' then tpv
          end
        ) as tpv_m3_1tx_boton,
        sum(
          case
            when m_1tx_boton = 4
            and dispositivo_transaccional = 'BOTON' then tpv
          end
        ) as tpv_m4_1tx_boton,
        sum(
          case
            when m_1tx_boton = 5
            and dispositivo_transaccional = 'BOTON' then tpv
          end
        ) as tpv_m5_1tx_boton,
        sum(
          case
            when m_1tx_boton = 6
            and dispositivo_transaccional = 'BOTON' then tpv
          end
        ) as tpv_m6_1tx_boton,
        sum(
          case
            when m_1tx_nequi = 0
            and dispositivo_transaccional = 'WALLETS' then tpv
          end
        ) as tpv_m0_1tx_nequi,
        sum(
          case
            when m_1tx_nequi = 1
            and dispositivo_transaccional = 'WALLETS' then tpv
          end
        ) as tpv_m1_1tx_nequi,
        sum(
          case
            when m_1tx_nequi = 2
            and dispositivo_transaccional = 'WALLETS' then tpv
          end
        ) as tpv_m2_1tx_nequi,
        sum(
          case
            when m_1tx_nequi = 3
            and dispositivo_transaccional = 'WALLETS' then tpv
          end
        ) as tpv_m3_1tx_nequi,
        sum(
          case
            when m_1tx_nequi = 4
            and dispositivo_transaccional = 'WALLETS' then tpv
          end
        ) as tpv_m4_1tx_nequi,
        sum(
          case
            when m_1tx_nequi = 5
            and dispositivo_transaccional = 'WALLETS' then tpv
          end
        ) as tpv_m5_1tx_nequi,
        sum(
          case
            when m_1tx_nequi = 6
            and dispositivo_transaccional = 'WALLETS' then tpv
          end
        ) as tpv_m6_1tx_nequi,
        sum(
          case
            when m_1tx_qr = 0
            and dispositivo_transaccional = 'QR' then tpv
          end
        ) as tpv_m0_1tx_qr,
        sum(
          case
            when m_1tx_qr = 1
            and dispositivo_transaccional = 'QR' then tpv
          end
        ) as tpv_m1_1tx_qr,
        sum(
          case
            when m_1tx_qr = 2
            and dispositivo_transaccional = 'QR' then tpv
          end
        ) as tpv_m2_1tx_qr,
        sum(
          case
            when m_1tx_qr = 3
            and dispositivo_transaccional = 'QR' then tpv
          end
        ) as tpv_m3_1tx_qr,
        sum(
          case
            when m_1tx_qr = 4
            and dispositivo_transaccional = 'QR' then tpv
          end
        ) as tpv_m4_1tx_qr,
        sum(
          case
            when m_1tx_qr = 5
            and dispositivo_transaccional = 'QR' then tpv
          end
        ) as tpv_m5_1tx_qr,
        sum(
          case
            when m_1tx_qr = 6
            and dispositivo_transaccional = 'QR' then tpv
          end
        ) as tpv_m6_1tx_qr
      from
        all_general_tx
      group by
        1
    )
    select
      t1.* -- info de contacto
      -- Campos de T3 -- atributos de pricing
,
      t3.bundle_name,
      t3.plan_name,
      t3.profile_id,
      t3.applied_date -- Campos de T2 -- atributos de fechas
,
      t2.master_merchant_id,
      t2.M_kyc,
      t2.reason_changed,
      t2.flag_master_merchant,
      t2.flag_shared_doc_legal_representative,
      t2.document_number,
      t2.document_type,
      t2.terminal_master_merchant_flag,
      t2.cellphone_master_merchant_flag,
      t2.document_master_merchant_flag,
      t2.legal_representative_master_merchant_flag,
      t2.kyc_date,
      t2._1st_terminal_match,
      CAST(t2._1st_terminal_match AS DATE) AS _1st_terminal_match_date_only,
      CAST(t2._1st_terminal_match AS TIME) AS _1st_terminal_match_time_only,
      t2._1st_tx_date,
      t2._1st_tx_date_hora,
      CAST(t2._1st_tx_date AS DATE) AS _1st_tx_date_date_only,
      CAST(t2._1st_tx_date AS TIME) AS _1st_tx_time_only,
      t2.ultima_trx_date,
      t2._1st_tx_mpos_date,
      CAST(t2._1st_tx_mpos_date AS DATE) AS _1st_tx_mpos_date_only,
      CAST(t2._1st_tx_mpos_date AS TIME) AS _1st_tx_mpos_time_only,
      t2._1st_tx_link_date,
      CAST(t2._1st_tx_link_date AS DATE) AS _1st_tx_link_date_only,
      CAST(t2._1st_tx_link_date AS TIME) AS _1st_tx_link_time_only,
      t2._1st_tx_boton_date,
      CAST(t2._1st_tx_boton_date AS DATE) AS _1st_tx_boton_date_only,
      CAST(t2._1st_tx_boton_date AS TIME) AS _1st_tx_boton_time_only,
      t2._1st_tx_nequi_date,
      CAST(t2._1st_tx_nequi_date AS DATE) AS _1st_tx_nequi_date_only,
      CAST(t2._1st_tx_nequi_date AS TIME) AS _1st_tx_nequi_time_only,
      t2._1st_tx_qr_date,
      CAST(t2._1st_tx_qr_date AS DATE) AS _1st_tx_qr_date_only,
      CAST(t2._1st_tx_qr_date AS TIME) AS _1st_tx_qr_time_only,
      t2.match_date,
      CAST(t2.match_date AS DATE) AS match_date_only,
      CAST(t2.match_date AS TIME) AS match_time_only,
      t2.mes_m1,
      t2.onboarding_end_date,
      coalesce(t2.order_, 0) as rank_merchant_onboarding_date_by_merchant_document,
      t2.flag_first_merchant_active_vinc,
      t2.flag_first_merchant_active_link,
      t2.flag_first_merchant_active,
      t2.flag_new_terminal_match,
      t2.total_match_merchant,
      t2.flag_new_link_match,
      t2.flag_link_match_same_month -- campos de T4 Info de TPV
,
      t4.*
    from
      merchant_contacto t1
      left join atributos_calculados t2 on t1.merchant_id = t2.merchant_id
      left join info_pricing t3 on t1.merchant_id = t3.merchant_id
      left join info_tpv_agregada t4 on t1.merchant_id = t4.merchant_id_tpv --where t1.merchant_id = 'B2APSKB3LT'
  ) AS "__mb_source"
WHERE
  "__mb_source"."flag_master_merchant" = 0
