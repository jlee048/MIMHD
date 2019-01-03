
with firsticustayforadmission as (
	select i.hadm_id, i.INTIME, i.OUTTIME
	from ICUSTAYS i
	inner join (
		select hadm_id, min(intime) mintime
		from ICUSTAYS
		group by hadm_id --57786
	) firsts on firsts.HADM_ID = i.HADM_ID and firsts.mintime = i.INTIME
)
, firstevent as (
select l.hadm_id, min(charttime) as firstcharted
from labevents l
inner join firsticustayforadmission f on l.HADM_ID = f.hadm_id and l.CHARTTIME<=dateadd(minute,60,f.outtime)
where itemid in (51221)
and VALUENUM is not null 
and ISNUMERIC(valuenum) = 1 
group by l.hadm_id
-- with 60 min buffer
)
select ce.*
into mimicprep..apacheHematocritlab
from LABEVENTS ce
inner join firstevent fe on ce.HADM_ID = fe.HAdm_ID and ce.CHARTTIME = fe.firstcharted
where itemid in (51221) --31253
and VALUENUM is not null --31253 -> 31125
and ISNUMERIC(valuenum) = 1 --31125 -> 31125
order by valuenum
--56135 rows

select count(*) from mimicprep..apacheHematocritlab
--56135

select distinct HADM_ID
from MimicPrep..apacheHematocritlab 
--56135


--select distinct HADM_ID, itemid, CHARTTIME, value, VALUENUM, VALUEUOM, flag
--from MimicPrep..apacheHematocritlab 

--select *
--from MimicPrep..apacheHematocritlab a
--inner join (
--	select HADM_ID, min(CHARTTIME) firststored
--	from MimicPrep..apacheHematocritlab
--	group by HADM_ID
--	having count(HADM_ID)>1
--) d on a.HADM_ID = d.HADM_ID
--order by 3 

----drop more dupes
--delete from a
--from MimicPrep..apacheHematocritlab a
--inner join (
--	select HADM_ID, max(ROW_ID) maxrowid
--	from MimicPrep..apacheHematocritlab
--	group by HADM_ID
--	having count(HADM_ID)>1
--) d on a.HADM_ID = d.HADM_ID and a.ROW_ID <> maxrowid
----1

--select count(*)
--from MimicPrep..apacheHematocritlab 
--51838

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apacheHematocritlab ah on fafi.hadm_id = ah.HADM_ID 
--44359


--; with combinedResults as (
-- select  * 
-- --into apachePotassiumCombined
-- from (
--	 select *,  ROW_NUMBER() OVER(PARTITION BY hadm_id ORDER BY charttime, source desc) firstrank
--	 from (
--		 select subject_id, hadm_id, itemid, charttime, value, valuenum, valueuom
--		 , 'lab' source
--		 from MimicPrep..apachePotassium 
--		 union 
--		 select subject_id, hadm_id, itemid, charttime, value, valuenum, valueuom 
--		 , 'chart'
--		 from MimicPrep..apachePotassiumlab 
--	 ) a
-- ) b
-- where firstrank = 1
-- ) --51893
--select * 
----into apachePotassiumCombined
--from mimicprep..admissions_FirstwithFirstICUStays fafi
--inner join combinedResults ah on fafi.hadm_id = ah.HADM_ID 
----40158
----where source = 'chart'  --37996
