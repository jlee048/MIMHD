--select datediff(second, '2018-11-30 23:59',  '2019-01-31 01:00') / (60*60*24.0)

;
with ctefirstadmissions as (
	SELECT * --part.HADM_ID, part.SUBJECT_ID 
	FROM (  
		SELECT *, ROW_NUMBER() OVER(PARTITION BY subject_id ORDER BY admittime) Corr FROM admissions
		) part
	WHERE part.Corr = 1
)
, dataset as (

	SELECT 
-- convert(decimal(18,2),datediff(hour, adm.ADMITTIME, adm.DISCHTIME)/24.0) as LOS_days_adm_disc
--, case when  adm.[EDREGTIME] is not null then 1 else 0 end hasED
--, convert(decimal(18,2),datediff(hour, adm.[EDREGTIME], adm.[EDOUTTIME])/24.0) EDStayDays
--, datediff(hour, adm.[EDREGTIME], adm.[EDOUTTIME]) EDStayHours
--,[SUBJECT_ID]     ,[HADM_ID]      ,[ADMITTIME]      ,[DISCHTIME]      ,[DEATHTIME]      ,[ADMISSION_TYPE]      ,[ADMISSION_LOCATION]      ,[DISCHARGE_LOCATION]      ,[INSURANCE]      ,[LANGUAGE]      ,[RELIGION]      ,[MARITAL_STATUS]      ,[ETHNICITY]      ,[EDREGTIME]      ,[EDOUTTIME]      ,[DIAGNOSIS]      ,[HOSPITAL_EXPIRE_FLAG]      ,[HAS_CHARTEVENTS_DATA]
--, 
adm.SUBJECT_ID
, adm.HADM_ID
,[ADMITTIME]      ,[DISCHTIME]      -- this is start of episode, not necessary ICU
,[DEATHTIME] -- filled only if dead @ hospital
, adm.ADMISSION_TYPE
, adm.[ADMISSION_LOCATION]
--, adm.[DISCHARGE_LOCATION]
, adm.[INSURANCE]
, adm.[LANGUAGE]
, adm.[RELIGION]
, adm.[MARITAL_STATUS]
, adm.[ETHNICITY]
--, adm.[EDREGTIME]      , adm.[EDOUTTIME]
, adm.[DIAGNOSIS]
, adm.[HOSPITAL_EXPIRE_FLAG]
, adm.[HAS_CHARTEVENTS_DATA]

--,[SUBJECT_ID]      ,[GENDER]      ,[DOB]      ,[DOD]      ,[DOD_HOSP]      ,[DOD_SSN]      ,[EXPIRE_FLAG]
, datediff(day, pat.DOB, adm.ADMITTIME)/365 as ageAtAdmission
, datediff(day, pat.DOB, pat.DOD)/365 as ageAtDeath
, pat.GENDER
, pat.DOB
, pat.DOD
, pat.EXPIRE_FLAG
-- ICUE BASED
--, adm.DEATHTIME - icu.INTIME mortality1
, datediff(minute, icu.[INTIME],  adm.[DEATHTIME])/(24.0*60) mortalityDays_icu
, case when [DEATHTIME] IS NULL then 0 else 1 end InHospitalMortality
, case when datediff(minute, icu.INTIME,  adm.[DEATHTIME]) <= 3*24*60 then 1 else 0 end ShortTermMortality3d
, case when datediff(minute, adm.DISCHTIME,  adm.[DEATHTIME]) <= 30*24*60 then 1 else 0 end LongTermMortality30d
, case when datediff(minute, adm.DISCHTIME,  adm.[DEATHTIME]) <= 365*24*60 then 1 else 0 end LongTermMortality1year
, convert(decimal(18,2),datediff(MINUTE, icu.[INTIME], icu.[OUTTIME])/(24.0*60)) as LOS_days_icuicu_minprec
/*
, datediff(day, adm.ADMITTIME,  pat.DOD) mortalityDays_adm
, datediff(month, adm.ADMITTIME,  pat.DOD) mortalityMonths_adm
, datediff(HOUR, adm.ADMITTIME,  pat.DOD) mortalityHours_adm
*/
--,[SUBJECT_ID]      ,[HADM_ID]      ,[ICUSTAY_ID]      ,[DBSOURCE]      ,[FIRST_CAREUNIT]      ,[LAST_CAREUNIT]      ,[FIRST_WARDID]      ,[LAST_WARDID]      ,[INTIME]      ,[OUTTIME]      ,[LOS]      
, icu.LOS LOS_ICU_days
      ,[ICUSTAY_ID]
      ,[DBSOURCE]
      ,[FIRST_CAREUNIT]
      ,[LAST_CAREUNIT]
      ,[FIRST_WARDID]
      ,[LAST_WARDID]
      ,[INTIME]
      ,[OUTTIME]

--, convert(decimal(18,2),datediff(hour, icu.[INTIME], adm.DISCHTIME)/24.0) as LOS_days_icudisc
--, convert(decimal(18,2),datediff(hour, icu.[INTIME], icu.[OUTTIME])/24.0) as LOS_days_icuicu

 from ctefirstadmissions adm
  left outer join [MIMICIII].[dbo].[PATIENTS] pat on pat.SUBJECT_ID = adm.SUBJECT_ID --58976
  left outer join [MIMICIII].[dbo].[ICUSTAYS] icu on icu.HADM_ID = adm.HADM_ID --and icu.SUBJECT_ID  = adm.SUBJECT_ID --62722
  --left outer join [MIMICIII].[dbo].[CALLOUT] co on co.HADM_ID = adm.HADM_ID and co.SUBJECT_ID  = adm.SUBJECT_ID and co.CALLOUT_OUTCOME = 'Discharged' and co.ACKNOWLEDGETIME <= icu.OUTTIME and co.ACKNOWLEDGETIME >= icu.INTIME
) 
, base1 as (
select top 10
SUBJECT_ID, HADM_ID, [ICUSTAY_ID], ADMISSION_TYPE
, DIAGNOSiS, HOSPITAL_EXPIRE_FLAG, HAS_CHARTEVENTS_DATA, ageAtAdmission, ageAtDeath, gender, dob
, InHospitalMortality, ShortTermMortality3d, LongTermMortality30d, LongTermMortality1year
, LOS_days_icuicu_minprec, LOS_ICU_days
, FIRST_CAREUNIT
, LAST_CAREUNIT
, dbsource
from dataset 
where ageAtAdmission>15  --41279
and HAS_CHARTEVENTS_DATA = 1 --40427
)

select b.HADM_ID, b.ICUSTAY_ID

, di.DBSOURCE, di.LINKSTO, di.label
, ce.*
from base1 b
inner join chartevents ce on ce.HADM_ID = b.HADM_ID and ce.ICUSTAY_ID = b.ICUSTAY_ID
left outer join d_items di on di.ITEMID = ce.ITEMID
where di.ITEMID in (select itemid from  apacheitems) --ai on ai.itemid = di.itemid
order by b.HADM_ID, ce.CHARTTIME