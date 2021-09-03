select trn_dt,
       sap_co,
       sap_br,
       ccy,
       sap_gl,
       sap_prd,
       fcy,
       lpad(trim(replace(to_char(abs(nvl((case
                                           when ccy in ('JPY', 'VND', 'KRW', 'IDR') then
                                            round(fcy_vat, 0)
                                           else
                                            fcy_vat
                                         end),
                                         0)),
                                 '9999999999999.00'),
                         '.',
                         '')),
            15,
            '0') as fcy_vat,
       lcy,
       lpad(trim(replace(to_char(abs(nvl(lcy_vat, 0)), '9999999999999.00'),
                         '.',
                         '')),
            15,
            '0') as lcy_vat
  from (select trn_dt,
               sap_co,
               sap_br,
               ccy,
               sap_gl,
               sap_prd,
               profit,
               case
                 when nvl(fcy_vat, 0) >= 0 then
                  ' '
                 else
                  '-'
               end as fcy,
               abs(fcy_vat) as fcy_vat,
               case
                 when nvl(lcy_vat, 0) >= 0 then
                  '-'
                 else
                  ' '
               end as lcy,
               abs(lcy_vat) as lcy_vat
          from (select to_char(a.trn_dt, 'yyyymmdd') as trn_dt,
                       cfuf_1.field_value as sap_co,
                       cfuf_2.field_value as sap_br,
                       a.ac_ccy as ccy,
                       lpad(trim(substr(a.external_value, 1, 8)), 10, '0') as sap_gl,
                       substr(a.external_value, -4) as sap_prd,
                       rpad(trim(cfuf_6.field_value), 10, ' ') as profit,
                       sum(fcy_vat) as fcy_vat,
                       sum(lcy_vat) as lcy_vat
                  from (select cs.data_date,
                               cs.sys_country,
                               cs.branch,
                               cs.counterparty,
                               cs.contract_ref_no,
                               ac.event,
                               ac.ac_no,
                               ct.external_value,
                               ac.ac_ccy,
                               ac.trn_code,
                               case
                                 when ac.drcr_ind = 'D' then
                                  'C'
                                 when ac.drcr_ind = 'C' then
                                  'D'
                               end as drcr_ind,
                               round(ac.fcy_amount, 2) as fcy_amount,
                               ac.exch_rate,
                               round(ac.lcy_amount, 2) as lcy_amount,
                               case
                                 when (udf1_5.field_value = 'N' or
                                      (udf2_80.field_value = 'Y' and
                                      udf1_6.field_value = 'N')) then
                                  0
                                 else
                                  case
                                    when ((ac.ac_no like '2%' and
                                         ac.drcr_ind = 'C') or (ac.ac_no like '4%' and
                                         ac.drcr_ind = 'D')) then
                                     -round((ac.lcy_amount / 1.06 * 0.06), 2)
                                    else
                                     round((ac.lcy_amount / 1.06 * 0.06), 2)
                                  end
                               end as lcy_vat,
                               case
                                 when (udf1_5.field_value = 'N' or
                                      (udf2_80.field_value = 'Y' and
                                      udf1_6.field_value = 'N')) then
                                  0
                                 else
                                  case
                                    when ((ac.ac_no like '2%' and
                                         ac.drcr_ind = 'C') or (ac.ac_no like '4%' and
                                         ac.drcr_ind = 'D')) then
                                     - (case
                                          when ac.ac_ccy in ('JPY', 'VND', 'KRW', 'IDR') then
                                           round((ac.lcy_amount / 1.06 * 0.06) /
                                                 ac.exch_rate,
                                                 0)
                                          else
                                           round((ac.lcy_amount / 1.06 * 0.06) /
                                                 ac.exch_rate,
                                                 2)
                                        end)
                                    else
                                     (case
                                       when ac.ac_ccy in ('JPY', 'VND', 'KRW', 'IDR') then
                                        round((ac.lcy_amount / 1.06 * 0.06) /
                                              ac.exch_rate,
                                              0)
                                       else
                                        round((ac.lcy_amount / 1.06 * 0.06) /
                                              ac.exch_rate,
                                              2)
                                     end)
                                  end
                               end as fcy_vat,
                               case
                                 when (udf1_5.field_value = 'N' or
                                      (udf2_80.field_value = 'Y' and
                                      udf1_6.field_value = 'N')) then
                                  ac.lcy_amount
                                 else
                                  (ac.lcy_amount -
                                  round((ac.lcy_amount / 1.06 * 0.06), 2))
                               end as lcy_income,
                               ac.trn_dt,
                               ac.value_dt,
                               ac.amount_tag,
                               ac.module,
                               ac.user_id,
                               ac.auth_id
                          from src_fcc_com_cstb_contract cs
                          join src_fcc_com_daily_txn ac
                            on ac.trn_ref_no = cs.contract_ref_no
                           and ac.sys_country = cs.sys_country
                           and ac.event = 'ACCR'
                          left join src_fcc_com_sap_gl_mapping ct
                            on ct.internal_branch = ac.ac_branch
                           and ct.internal_value = ac.ac_no
                           and ct.sys_country = ac.sys_country
                          left join (select *
                                      from udf1
                                     where field_name = 'VAT商品名称') udf1_2
                            on udf1_2.field_key = ac.ac_no || '~'
                           and udf1_2.sys_country = ac.sys_country
                          left join (select data_date,
                                           sys_country,
                                           field_key,
                                           nvl(field_value, 'N') as field_value
                                      from udf1
                                     where field_name = 'VAT貸款相關項目') udf1_3
                            on udf1_3.field_key = ac.ac_no || '~'
                           and udf1_3.sys_country = ac.sys_country
                          left join (select *
                                      from udf1
                                     where field_name = 'VAT價稅分離項目') udf1_5
                            on udf1_5.field_key = ac.ac_no || '~'
                           and udf1_5.sys_country = ac.sys_country
                          left join (select *
                                      from udf1
                                     where field_name = 'VAT非存款金融机构') udf1_6
                            on udf1_6.field_key = ac.ac_no || '~'
                           and udf1_6.sys_country = ac.sys_country
                          left join (select *
                                      from udf2
                                     where field_name =
                                           'CSBR_SUPERVISION_FLAG') udf2_80
                            on udf2_80.field_key = cs.counterparty || '~'
                           and udf2_80.sys_country = ac.sys_country
                          left join (select *
                                      from udf2
                                     where field_name = 'TAXPAYER_TYPE') udf2_84
                            on udf2_84.field_key = cs.counterparty || '~'
                           and udf2_84.sys_country = ac.sys_country
                         where to_char(ac.trn_dt, 'mm/yyyy') =
                               to_char(ac.data_date, 'mm/yyyy')) a
                  left join (select *
                              from cfuf
                             where field_name = 'SAP_COMPANY') cfuf_1
                    on a.branch || '~' = cfuf_1.field_key
                   and a.sys_country = cfuf_1.sys_country
                  left join (select *
                              from cfuf
                             where field_name = 'SAP_BRANCH') cfuf_2
                    on '0' || a.branch = cfuf_2.field_value
                   and a.sys_country = cfuf_2.sys_country
                  left join (select *
                              from cfuf
                             where field_name = 'SAP_PROFIT') cfuf_6
                    on a.branch || '~' = cfuf_6.field_key
                   and a.sys_country = cfuf_6.sys_country
                 where a.ac_ccy <> 'CNY'
                 group by a.trn_dt,
                          cfuf_1.field_value,
                          cfuf_2.field_value,
                          a.ac_ccy,
                          a.external_value,
                          cfuf_6.field_value))
) where sap_gl like '004%' order by sap_br, ccy, sap_gl, sap_prd