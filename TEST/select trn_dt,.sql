SELECT  trn_dt
       ,sap_co
       ,sap_br
       ,ccy
       ,sap_gl
       ,sap_prd
       ,fcy
       ,lpad(trim(replace(to_char(abs(nvl((case WHEN ccy IN ('JPY','VND','KRW','IDR') THEN round(fcy_vat,0) else fcy_vat end),0)),'9999999999999.00'),'.','')),15,'0') AS fcy_vat
       ,lcy
       ,lpad(trim(replace(to_char(abs(nvl(lcy_vat,0)),'9999999999999.00'),'.','')),15,'0') AS lcy_vat
FROM
(
	SELECT  trn_dt
	       ,sap_co
	       ,sap_br
	       ,ccy
	       ,sap_gl
	       ,sap_prd
	       ,profit
	       ,CASE WHEN nvl(fcy_vat,0) >= 0 THEN ' '  ELSE '-' END AS fcy
	       ,abs(fcy_vat)                                         AS fcy_vat
	       ,CASE WHEN nvl(lcy_vat,0) >= 0 THEN '-'  ELSE ' ' END AS lcy
	       ,abs(lcy_vat)                                         AS lcy_vat
	FROM
	(
		SELECT  to_char(a.trn_dt,'yyyymmdd')                    AS trn_dt
		       ,cfuf_1.field_value                              AS sap_co
		       ,cfuf_2.field_value                              AS sap_br
		       ,a.ac_ccy                                        AS ccy
		       ,lpad(trim(substr(a.external_value,1,8)),10,'0') AS sap_gl
		       ,substr(a.external_value,-4)                     AS sap_prd
		       ,rpad(trim(cfuf_6.field_value),10,' ')           AS profit
		       ,SUM(fcy_vat)                                    AS fcy_vat
		       ,SUM(lcy_vat)                                    AS lcy_vat
		FROM
		(
			SELECT  cs.data_date
			       ,cs.sys_country
			       ,cs.branch
			       ,cs.counterparty
			       ,cs.contract_ref_no
			       ,ac.event
			       ,ac.ac_no
			       ,ct.external_value
			       ,ac.ac_ccy
			       ,ac.trn_code
			       ,CASE WHEN ac.drcr_ind = 'D' THEN 'C'
			             WHEN ac.drcr_ind = 'C' THEN 'D' END AS drcr_ind
			       ,round(ac.fcy_amount,2)                   AS fcy_amount
			       ,ac.exch_rate
			       ,round(ac.lcy_amount,2)                   AS lcy_amount
			       ,CASE WHEN (udf1_5.field_value = 'N' or (udf2_80.field_value = 'Y' AND udf1_6.field_value = 'N')) THEN 0  ELSE CASE
			             WHEN ((ac.ac_no like '2%' AND ac.drcr_ind = 'C') or (ac.ac_no like '4%' AND ac.drcr_ind = 'D')) THEN -round((ac.lcy_amount / 1.06 * 0.06),2)  ELSE round((ac.lcy_amount / 1.06 * 0.06),2) END END AS lcy_vat
			       ,CASE WHEN (udf1_5.field_value = 'N' or (udf2_80.field_value = 'Y' AND udf1_6.field_value = 'N')) THEN 0  ELSE CASE
			             WHEN ((ac.ac_no like '2%' AND ac.drcr_ind = 'C') or (ac.ac_no like '4%' AND ac.drcr_ind = 'D')) THEN - (case
			             WHEN ac.ac_ccy IN ('JPY','VND','KRW','IDR') THEN round((ac.lcy_amount / 1.06 * 0.06) / ac.exch_rate,0)  ELSE round((ac.lcy_amount / 1.06 * 0.06) / ac.exch_rate,2) END)  ELSE (case
			             WHEN ac.ac_ccy IN ('JPY','VND','KRW','IDR') THEN round((ac.lcy_amount / 1.06 * 0.06) / ac.exch_rate,0)  ELSE round((ac.lcy_amount / 1.06 * 0.06) / ac.exch_rate,2) END) END END AS fcy_vat
			       ,CASE WHEN (udf1_5.field_value = 'N' or (udf2_80.field_value = 'Y' AND udf1_6.field_value = 'N')) THEN ac.lcy_amount  ELSE (ac.lcy_amount - round((ac.lcy_amount / 1.06 * 0.06),2)) END AS lcy_income
			       ,ac.trn_dt
			       ,ac.value_dt
			       ,ac.amount_tag
			       ,ac.module
			       ,ac.user_id
			       ,ac.auth_id
			FROM src_fcc_com_cstb_contract cs
			JOIN src_fcc_com_daily_txn ac
			ON ac.trn_ref_no = cs.contract_ref_no AND ac.sys_country = cs.sys_country AND ac.event = 'ACCR'
			LEFT JOIN src_fcc_com_sap_gl_mapping ct
			ON ct.internal_branch = ac.ac_branch AND ct.internal_value = ac.ac_no AND ct.sys_country = ac.sys_country
			LEFT JOIN
			(
				SELECT  *
				FROM udf1
				WHERE field_name = 'VAT商品名称'
			) udf1_2
			ON udf1_2.field_key = ac.ac_no || '~' AND udf1_2.sys_country = ac.sys_country
			LEFT JOIN
			(
				SELECT  data_date
				       ,sys_country
				       ,field_key
				       ,nvl(field_value,'N') AS field_value
				FROM udf1
				WHERE field_name = 'VAT貸款相關項目'
			) udf1_3
			ON udf1_3.field_key = ac.ac_no || '~' AND udf1_3.sys_country = ac.sys_country
			LEFT JOIN
			(
				SELECT  *
				FROM udf1
				WHERE field_name = 'VAT價稅分離項目'
			) udf1_5
			ON udf1_5.field_key = ac.ac_no || '~' AND udf1_5.sys_country = ac.sys_country
			LEFT JOIN
			(
				SELECT  *
				FROM udf1
				WHERE field_name = 'VAT非存款金融机构'
			) udf1_6
			ON udf1_6.field_key = ac.ac_no || '~' AND udf1_6.sys_country = ac.sys_country
			LEFT JOIN
			(
				SELECT  *
				FROM udf2
				WHERE field_name = 'CSBR_SUPERVISION_FLAG'
			) udf2_80
			ON udf2_80.field_key = cs.counterparty || '~' AND udf2_80.sys_country = ac.sys_country
			LEFT JOIN
			(
				SELECT  *
				FROM udf2
				WHERE field_name = 'TAXPAYER_TYPE'
			) udf2_84
			ON udf2_84.field_key = cs.counterparty || '~' AND udf2_84.sys_country = ac.sys_country
			WHERE to_char(ac.trn_dt, 'mm/yyyy') = to_char(ac.data_date, 'mm/yyyy')
		) a
		LEFT JOIN
		(
			SELECT  *
			FROM cfuf
			WHERE field_name = 'SAP_COMPANY'
		) cfuf_1
		ON a.branch || '~' = cfuf_1.field_key AND a.sys_country = cfuf_1.sys_country
		LEFT JOIN
		(
			SELECT  *
			FROM cfuf
			WHERE field_name = 'SAP_BRANCH'
		) cfuf_2
		ON '0' || a.branch = cfuf_2.field_value AND a.sys_country = cfuf_2.sys_country
		LEFT JOIN
		(
			SELECT  *
			FROM cfuf
			WHERE field_name = 'SAP_PROFIT'
		) cfuf_6
		ON a.branch || '~' = cfuf_6.field_key AND a.sys_country = cfuf_6.sys_country
		WHERE a.ac_ccy <> 'CNY'
		GROUP BY  a.trn_dt
		         ,cfuf_1.field_value
		         ,cfuf_2.field_value
		         ,a.ac_ccy
		         ,a.external_value
		         ,cfuf_6.field_value
	)
)
WHERE sap_gl like '004%'
ORDER BY sap_br, ccy, sap_gl, sap_prd