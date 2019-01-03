--select distinct ICUSTAY_ID
--from ICUSTAYS

----61532

--select distinct hadm_id 
--from ADMISSIONS
----58976
;
with ctefirstadmissions as (
	SELECT * --part.HADM_ID, part.SUBJECT_ID 
	--into mimicprep..admissions_first
	FROM (  
		SELECT *, ROW_NUMBER() OVER(PARTITION BY subject_id ORDER BY admittime) Corr FROM admissions
		) part
	WHERE part.Corr = 1
	--46520
)
, ctefirsticustayforadmission as (
	SELECT * --part.HADM_ID, part.SUBJECT_ID 
--	into mimicprep..icustays_firstperadmission
	FROM (  
		SELECT *, ROW_NUMBER() OVER(PARTITION BY hadm_ID ORDER BY intime) Corr FROM ICUSTAYS
		) part
	WHERE part.Corr = 1
	--57786
)	
select ctea.*, ctei.ICUSTAY_ID, ctei.INTIME, ctei.OUTTIME, ctei.DBSOURCE, ctei.FIRST_CAREUNIT, ctei.LAST_CAREUNIT, ctei.FIRST_WARDID, ctei.LAST_WARDID, ctei.LOS
into mimicprep..admissions_FirstwithFirstICUStays
from ctefirstadmissions ctea 
inner join ctefirsticustayforadmission ctei
on ctea.HADM_ID = ctei.HADM_ID
--45921 firstadmissions and firsticu


--drop table mimicprep..admissions_FirstwithFirstICUStays