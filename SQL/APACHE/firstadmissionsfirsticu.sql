--select * from MimicPrep..admissions_FirstwithFirstICUStays
--select datediff(second, '2018-11-30 23:59',  '2019-01-31 01:00') / (60*60*24.0)
--select datediff(second, '2018-11-30 23:59',  '2019-01-31 01:00') / (60*60*24.0)
--select datediff(day, '2018-11-30 23:59',  '2019-01-31 01:00') 
--select datediff(year, '2018-11-30 23:59',  '2019-01-31 01:00') 
;
with firsticustayforadmission as (
	select i.ICUSTAY_ID, i.hadm_id, i.INTIME, i.OUTTIME
	from ICUSTAYS i
	inner join (
		select hadm_id, min(intime) mintime
		from ICUSTAYS
		group by hadm_id --57786
	) firsts on firsts.HADM_ID = i.HADM_ID and firsts.mintime = i.INTIME
), ctefirstadmissions as (
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
, datediff(day, pat.DOB, adm.ADMITTIME)/365.25 as ageAtAdmission
, datediff(day, pat.DOB, pat.DOD)/365.25 as ageAtDeath
, pat.GENDER
, pat.DOB
, pat.DOD
, pat.EXPIRE_FLAG
-- ICUE BASED
--, adm.DEATHTIME - icu.INTIME mortality1
, datediff(minute, icu.[INTIME],  adm.[DEATHTIME])/(24.0*60) mortalityDays_icu
, case when [DEATHTIME] IS NULL then 0 else 1 end InHospitalMortality
, case when datediff(minute, icu.INTIME,  adm.[DEATHTIME]) <= 24*60 then 1 else 0 end ShortTermMortality1d
, case when datediff(minute, icu.INTIME,  adm.[DEATHTIME]) <= 3*24*60 then 1 else 0 end ShortTermMortality3d
, case when datediff(minute, adm.DISCHTIME,  adm.[DEATHTIME]) <= 30*24*60 then 1 else 0 end LongTermMortality30d
, case when datediff(minute, adm.DISCHTIME,  adm.[DEATHTIME]) <= 365*24*60 then 1 else 0 end LongTermMortality1year
, convert(decimal(18,2),datediff(MINUTE, icu.[INTIME], icu.[OUTTIME])/(24.0*60)) as LOS_days_icuicu_minprec
, convert(decimal(18,2),datediff(MINUTE, icu.[INTIME], icu.[OUTTIME])/60.0) as LOS_hours_icuicu_minprec
/*
, datediff(day, adm.ADMITTIME,  pat.DOD) mortalityDays_adm
, datediff(month, adm.ADMITTIME,  pat.DOD) mortalityMonths_adm
, datediff(HOUR, adm.ADMITTIME,  pat.DOD) mortalityHours_adm
*/
--,[SUBJECT_ID]      ,[HADM_ID]      ,[ICUSTAY_ID]      ,[DBSOURCE]      ,[FIRST_CAREUNIT]      ,[LAST_CAREUNIT]      ,[FIRST_WARDID]      ,[LAST_WARDID]      ,[INTIME]      ,[OUTTIME]      ,[LOS]      
, icu.LOS LOS_ICU_days
      ,icu.[ICUSTAY_ID]
      ,icu.[DBSOURCE]
      ,icu.[FIRST_CAREUNIT]
      ,icu.[LAST_CAREUNIT]
      ,icu.[FIRST_WARDID]
      ,icu.[LAST_WARDID]
      ,icu.[INTIME]
      ,icu.[OUTTIME]

 from ctefirstadmissions adm
  inner join [MIMICIII].[dbo].[PATIENTS] pat on pat.SUBJECT_ID = adm.SUBJECT_ID --58976
  inner join  firsticustayforadmission ficu on ficu.HADM_ID = adm.HADM_ID 
  inner join [MIMICIII].[dbo].[ICUSTAYS] icu on icu.ICUSTAY_ID = ficu.ICUSTAY_ID
) 
, base1 as (
select 
HADM_ID
,SUBJECT_ID
,ICUSTAY_ID
, ADMISSION_TYPE
, ADMISSION_LOCATION
, INSURANCE
, [LANGUAGE]
, RELIGION
, MARITAL_STATUS
, ETHNICITY
, DIAGNOSiS
--, HOSPITAL_EXPIRE_FLAG
--, HAS_CHARTEVENTS_DATA, dob
, case when ageAtAdmission > 150 then null else ageAtAdmission end ageAtAdmission
, ageAtDeath
, gender
, InHospitalMortality
, ShortTermMortality1d
, ShortTermMortality3d
, LongTermMortality30d
, LongTermMortality1year
--, LOS_days_icuicu_minprec
, LOS_hours_icuicu_minprec
, LOS_ICU_days
, FIRST_CAREUNIT
, LAST_CAREUNIT
, dbsource
,HAS_CHARTEVENTS_DATA
from dataset 
--where ageAtAdmission>15  --41279
--and HAS_CHARTEVENTS_DATA = 1 --40427
)

select * 
into mimicprep..firstadmissionsfirsticu

from base1 b

order by b.HADM_ID

--45921

--drop table  mimicprep..firstadmissionsfirsticu