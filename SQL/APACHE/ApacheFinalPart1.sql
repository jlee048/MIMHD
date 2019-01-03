with ctefirstadmissions as (
	SELECT *
	FROM (  
		SELECT *, ROW_NUMBER() OVER(PARTITION BY subject_id ORDER BY admittime) Corr FROM admissions
		) part
	WHERE part.Corr = 1
)
, firsticustayforadmission as (
	select i.* --i.ICUSTAY_ID, i.hadm_id, i.INTIME, i.OUTTIME
	from ICUSTAYS i
	inner join (
		select hadm_id, min(intime) mintime
		from ICUSTAYS
		group by hadm_id --57786
	) firsts on firsts.HADM_ID = i.HADM_ID and firsts.mintime = i.INTIME
) 
, dataset1 as (
	select adm.SUBJECT_ID
	, adm.HADM_ID
	,[ADMITTIME]      ,[DISCHTIME]      -- this is start of episode, not necessary ICU
	,[DEATHTIME] -- filled only if dead @ hospital
	, adm.ADMISSION_TYPE
	, adm.[ADMISSION_LOCATION]
	, adm.[INSURANCE]
	, adm.[LANGUAGE]
	, adm.[RELIGION]
	, adm.[MARITAL_STATUS]
	, adm.[ETHNICITY]
	, adm.[DIAGNOSIS]
	, adm.[HOSPITAL_EXPIRE_FLAG]
	, adm.[HAS_CHARTEVENTS_DATA]
	, datediff(day, pat.DOB, adm.ADMITTIME)/365.25 as ageAtAdmission
	, datediff(day, pat.DOB, pat.DOD)/365.25 as ageAtDeath
	, pat.GENDER
	, pat.DOB
	, pat.DOD
	, pat.EXPIRE_FLAG
	, ficu.LOS LOS_ICU_days
		  ,ficu.[ICUSTAY_ID]
		  ,ficu.[DBSOURCE]
		  ,ficu.[FIRST_CAREUNIT]
		  ,ficu.[LAST_CAREUNIT]
		  ,ficu.[FIRST_WARDID]
		  ,ficu.[LAST_WARDID]
		  ,ficu.[INTIME]
		  ,ficu.[OUTTIME]
	-- ICUE BASED
	--, adm.DEATHTIME - icu.INTIME mortality1
	, datediff(minute, ficu.[INTIME],  adm.[DEATHTIME])/(24.0*60) mortalityDays_icu
	, case when [DEATHTIME] IS NULL then 0 else 1 end InHospitalMortality
	, case when datediff(minute, ficu.INTIME,  adm.[DEATHTIME]) <= 24*60 then 1 else 0 end ShortTermMortality1d
	, case when datediff(minute, ficu.INTIME,  adm.[DEATHTIME]) <= 3*24*60 then 1 else 0 end ShortTermMortality3d
	, case when datediff(minute, adm.DISCHTIME,  adm.[DEATHTIME]) <= 30*24*60 then 1 else 0 end LongTermMortality30d
	, case when datediff(minute, adm.DISCHTIME,  adm.[DEATHTIME]) <= 365*24*60 then 1 else 0 end LongTermMortality1year
	, convert(decimal(18,2),datediff(MINUTE, ficu.[INTIME], ficu.[OUTTIME])/(24.0*60)) as LOS_days_icuicu_minprec
	, convert(decimal(18,2),datediff(MINUTE, ficu.[INTIME], ficu.[OUTTIME])/60.0) as LOS_hours_icuicu_minprec

	 from ctefirstadmissions adm
	inner join  firsticustayforadmission ficu on ficu.HADM_ID = adm.HADM_ID 
	inner join [MIMICIII].[dbo].[PATIENTS] pat on pat.SUBJECT_ID = adm.SUBJECT_ID 
) 
, baseset as (
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
--	, case when ageAtAdmission > 150 then null else ageAtAdmission end ageAtAdmission
	, ageAtAdmission
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
	from dataset1 
	where 	ageAtAdmission < 140 
	and 	ageAtAdmission>=16  
	and HAS_CHARTEVENTS_DATA = 1 
)
, apachePrimaryDiagCat as (
select HADM_ID
, SEQ_NUM
, ICD9_CODE PrimaryICD9
, case when left(icd9_code,1) = 'V' then 1 
	when left(icd9_code,1) = 'E' then 2 
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 1 and 139 then 3
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 140 and 239 then 4 
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 240 and 279 then 5
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 280 and 289 then 6
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 290 and 319 then 7
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 320 and 389 then 8
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 390 and 459 then 9
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 460 and 519 then 10
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 520 and 579 then 11
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 580 and 629 then 12
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 630 and 679 then 13
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 680 and 709 then 14
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 710 and 739 then 15
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 740 and 759 then 16
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 760 and 779 then 17
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 780 and 789 then 18
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 790 and 796 then 19
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 797 and 799 then 20
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 800 and 999 then 21 
	else 0 end PrimaryDiag
--into mimicprep..apachePrimaryDiagCat
from DIAGNOSES_ICD
where SEQ_NUM = 1
--order by 3 (58929 rows)
) 
, apacheSecondaryDiagCat as (
select HADM_ID
, SEQ_NUM
, ICD9_CODE SecondaryICD9
, case when left(icd9_code,1) = 'V' then 1 
	when left(icd9_code,1) = 'E' then 2 
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 1 and 139 then 3
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 140 and 239 then 4 
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 240 and 279 then 5
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 280 and 289 then 6
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 290 and 319 then 7
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 320 and 389 then 8
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 390 and 459 then 9
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 460 and 519 then 10
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 520 and 579 then 11
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 580 and 629 then 12
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 630 and 679 then 13
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 680 and 709 then 14
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 710 and 739 then 15
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 740 and 759 then 16
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 760 and 779 then 17
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 780 and 789 then 18
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 790 and 796 then 19
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 797 and 799 then 20
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 800 and 999 then 21 
	else 0 end SecondaryDiag
from DIAGNOSES_ICD
where SEQ_NUM = 2
--order by 3 --(58555 rows affected)
)




select * 
from baseset b
where b.LOS_hours_icuicu_minprec is null
order by b.HADM_ID


select * from ADMISSIONS where HADM_ID in (138066,148324)
select * from ICUSTAYS where HADM_ID in (138066,148324)



select count(distinct d.ICD9_CODE )
from DIAGNOSES_ICD d

select count(distinct LANGUAGE) 
from mimicprep.[dbo].[firstadmissionsfirsticu] p
--74

select count(*) 
from mimicprep.[dbo].[firstadmissionsfirsticu] p
where p.[ageAtAdmission]>=16 --note fractional values
and p.HAS_CHARTEVENTS_DATA = 1
35823

select count(*) 
from mimicprep.[dbo].[firstadmissionsfirsticu] p
where p.[ageAtAdmission]>=16 --note fractional values
and p.HAS_CHARTEVENTS_DATA = 1
and p.ageAtAdmission <140