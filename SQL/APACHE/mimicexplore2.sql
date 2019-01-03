
;
with ctefirstadmissions as (
	SELECT * --part.HADM_ID, part.SUBJECT_ID 
	FROM (  
		SELECT *, ROW_NUMBER() OVER(PARTITION BY subject_id ORDER BY admittime) Corr FROM admissions
		) part
	WHERE part.Corr = 1
)
, dataset as (
SELECT distinct
 convert(decimal(18,2),datediff(hour, adm.ADMITTIME, adm.DISCHTIME)/24.0) as LOS_days
, case when  adm.[EDREGTIME] is not null then 1 else 0 end hasED
, convert(decimal(18,2),datediff(hour, adm.[EDREGTIME], adm.[EDOUTTIME])/24.0) EDStayDays
, datediff(hour, adm.[EDREGTIME], adm.[EDOUTTIME]) EDStayHours
--,[SUBJECT_ID]     ,[HADM_ID]      ,[ADMITTIME]      ,[DISCHTIME]      ,[DEATHTIME]      ,[ADMISSION_TYPE]      ,[ADMISSION_LOCATION]      ,[DISCHARGE_LOCATION]      ,[INSURANCE]      ,[LANGUAGE]      ,[RELIGION]      ,[MARITAL_STATUS]      ,[ETHNICITY]      ,[EDREGTIME]      ,[EDOUTTIME]      ,[DIAGNOSIS]      ,[HOSPITAL_EXPIRE_FLAG]      ,[HAS_CHARTEVENTS_DATA]
, adm.SUBJECT_ID
, adm.HADM_ID
,[ADMITTIME]      ,[DISCHTIME]      ,[DEATHTIME]
, adm.ADMISSION_TYPE
, adm.[ADMISSION_LOCATION]
, adm.[DISCHARGE_LOCATION]
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
, datediff(year, pat.DOB, adm.ADMITTIME) as ageAtAdmission
, datediff(year, pat.DOB, pat.DOD) as ageAtDeath
, pat.GENDER
, pat.DOB
, pat.DOD
, pat.EXPIRE_FLAG

, datediff(day, adm.ADMITTIME,  pat.DOD) mortalityDays
, datediff(month, adm.ADMITTIME,  pat.DOD) mortalityMonths
, datediff(HOUR, adm.ADMITTIME,  pat.DOD) mortalityHours

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
--,[SUBJECT_ID]      ,[HADM_ID]      ,[SUBMIT_WARDID]      ,[SUBMIT_CAREUNIT]      ,[CURR_WARDID]      ,[CURR_CAREUNIT]      ,[CALLOUT_WARDID]      ,[CALLOUT_SERVICE]      ,[REQUEST_TELE]      ,[REQUEST_RESP]      ,[REQUEST_CDIFF]      ,[REQUEST_MRSA]      ,[REQUEST_VRE]      ,[CALLOUT_STATUS]      ,[CALLOUT_OUTCOME]      ,[DISCHARGE_WARDID]      ,[ACKNOWLEDGE_STATUS]      ,[CREATETIME]      ,[UPDATETIME]      ,[ACKNOWLEDGETIME]      ,[OUTCOMETIME]      ,[FIRSTRESERVATIONTIME]      ,[CURRENTRESERVATIONTIME]
--,[SUBMIT_WARDID]
--,[SUBMIT_CAREUNIT]
--,[CURR_WARDID]
--,[CURR_CAREUNIT]
--,[CALLOUT_WARDID]
--,[CALLOUT_SERVICE]
--,[REQUEST_TELE]
--,[REQUEST_RESP]
--,[REQUEST_CDIFF]
--,[REQUEST_MRSA]
--,[REQUEST_VRE]
--,[CALLOUT_STATUS]
--,[CALLOUT_OUTCOME]
--,[DISCHARGE_WARDID]
--,[ACKNOWLEDGE_STATUS]
--,[CREATETIME]
--,[UPDATETIME]
--,[ACKNOWLEDGETIME]
--,[OUTCOMETIME]
--,[FIRSTRESERVATIONTIME]
--,[CURRENTRESERVATIONTIME]
--,count(icu.row_id) over(partition by icu.hadm_id, icu.subject_id) icucount
--,count(co.row_id) over(partition by co.hadm_id, co.subject_id) calloutcount
  --FROM [MIMICIII].[dbo].[ADMISSIONS] adm --58976
  from ctefirstadmissions adm
  left outer join [MIMICIII].[dbo].[PATIENTS] pat on pat.SUBJECT_ID = adm.SUBJECT_ID --58976
  left outer join [MIMICIII].[dbo].[ICUSTAYS] icu on icu.HADM_ID = adm.HADM_ID --and icu.SUBJECT_ID  = adm.SUBJECT_ID --62722
  --left outer join [MIMICIII].[dbo].[CALLOUT] co on co.HADM_ID = adm.HADM_ID and co.SUBJECT_ID  = adm.SUBJECT_ID and co.CALLOUT_OUTCOME = 'Discharged' and co.ACKNOWLEDGETIME <= icu.OUTTIME and co.ACKNOWLEDGETIME >= icu.INTIME
) 
select * 
from dataset 
where ageAtAdmission>15 --41280
--where EXPIRE_FLAG = 1 --17206
--where dod is not null --17206
--where mortalityhours<24 --941

--where mortalityhours<24 and ageAtAdmission > 15 --910
--where mortalitymonths<1 and ageAtAdmission > 15 --3710
--where mortalitymonths<3 and ageAtAdmission > 15 --7290
--where mortalitymonths<6 and ageAtAdmission > 15 --8879
--where discharge_location = 'dead/expired'
--4933
--or
 --,[ADMITTIME]      ,[DISCHTIME]      ,[DEATHTIME]
 and discharge_location = 'dead/expired'
 and DEATHTIME <= DISCHTIME
 --4901
 admission type  vs origin
 site (firt care unit vs last care unit)
