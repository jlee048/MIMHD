select * from DIAGNOSES_ICD 
where ICD9_CODE is null
--651047

select * from D_ICD_DIAGNOSES --14567

4	3	145834	1	0389
5	3	145834	2	78559
6	3	145834	3	5849
7	3	145834	4	4275
8	3	145834	5	41071
9	3	145834	6	4280
10	3	145834	7	6826
11	3	145834	8	4254

select HADM_ID
, SEQ_NUM
, ICD9_CODE
, case when left(icd9_code,1) = 'V' then 1 else 0 end	D_Ext
, case when left(icd9_code,1) = 'E' then 1 else 0 end	D_Supp
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 1 and 139 then 1 else 0 end	D_Infect
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 140 and 239 then 1 else 0 end D_Neoplasm
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 240 and 279 then 1 else 0 end D_ENMDID
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 280 and 289 then 1 else 0 end D_DBBFO
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 290 and 319 then 1 else 0 end D_MentalD
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 320 and 389 then 1 else 0 end D_DNSSO
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 390 and 459 then 1 else 0 end D_DCS
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 460 and 519 then 1 else 0 end D_DRS
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 520 and 579 then 1 else 0 end D_DDS
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 580 and 629 then 1 else 0 end D_DGS
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 630 and 679 then 1 else 0 end D_CPCP
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 680 and 709 then 1 else 0 end D_SST
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 710 and 739 then 1 else 0 end D_MSCT
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 740 and 759 then 1 else 0 end D_CA
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 760 and 779 then 1 else 0 end D_CCOPP
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 780 and 789 then 1 else 0 end D_SSIDC
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 790 and 796 then 1 else 0 end D_SSIDC_NAF
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 797 and 799 then 1 else 0 end D_SSIDC_IDUCMM
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 800 and 999 then 1 else 0 end D_IP
into mimicprep..apacheDiagnosesPrimary
from DIAGNOSES_ICD
where SEQ_NUM = 1
order by 3



select HADM_ID
, SEQ_NUM
, ICD9_CODE
, case when left(icd9_code,1) = 'V' then 1 else 0 end	DS_Ext
, case when left(icd9_code,1) = 'E' then 1 else 0 end	DS_Supp
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 1 and 139 then 1 else 0 end	DS_Infect
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 140 and 239 then 1 else 0 end DS_Neoplasm
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 240 and 279 then 1 else 0 end DS_ENMDID
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 280 and 289 then 1 else 0 end DS_DBBFO
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 290 and 319 then 1 else 0 end DS_MentalD
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 320 and 389 then 1 else 0 end DS_DNSSO
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 390 and 459 then 1 else 0 end DS_DCS
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 460 and 519 then 1 else 0 end DS_DRS
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 520 and 579 then 1 else 0 end DS_DDS
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 580 and 629 then 1 else 0 end DS_DGS
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 630 and 679 then 1 else 0 end DS_CPCP
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 680 and 709 then 1 else 0 end DS_SST
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 710 and 739 then 1 else 0 end DS_MSCT
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 740 and 759 then 1 else 0 end DS_CA
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 760 and 779 then 1 else 0 end DS_CCOPP
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 780 and 789 then 1 else 0 end DS_SSIDC
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 790 and 796 then 1 else 0 end DS_SSIDC_NAF
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 797 and 799 then 1 else 0 end DS_SSIDC_IDUCMM
, case when try_cast(left(icd9_code,3) as decimal(9,2)) between 800 and 999 then 1 else 0 end DS_IP
into mimicprep..apacheDiagnosesSecondary
from DIAGNOSES_ICD
where SEQ_NUM = 2
order by 3