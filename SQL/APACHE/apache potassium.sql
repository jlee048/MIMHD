;
with firstevent as (
select icustay_id, min(charttime) as firstcharted
from chartevents
where itemid in (227442)--(1536,837,3803,220645)
and VALUENUM is not null 
and ISNUMERIC(valuenum) = 1 
--and valuenum >= 10	and valuenum <=350 --51327 -> 51263
--and valuenum < 10	and valuenum > 3 --31111 -> 31110
and (error = 0 or error is null) 
group by icustay_id
--25684
)
select ce.*
into mimicprep..apachePotassium
from chartevents ce
inner join firstevent fe on ce.ICUSTAY_ID = fe.ICUSTAY_ID and ce.CHARTTIME = fe.firstcharted
where itemid in (227442)
and VALUENUM is not null --31253 -> 31125
and ISNUMERIC(valuenum) = 1 --31125 -> 31125
--and valuenum < 10	and valuenum > 3 --31111 -> 31110
and (error = 0 or error is null) --31125 --> 31111
order by valuenum
--25783



select distinct ICUSTAY_ID
from MimicPrep..apachePotassium 
--25683

--drop records if not first stored
delete from a
from MimicPrep..apachePotassium a
inner join (
	select icustay_id, min(storetime) firststored
	from MimicPrep..apachePotassium 
	group by ICUSTAY_ID
	having count(ICUSTAY_ID)>1
) d on a.icustay_id = d.icustay_id and a.storetime <> d.firststored
--2

delete from a
from MimicPrep..apachePotassium a
inner join (
	select icustay_id, min(storetime) firststored, min(row_id) minrowid
	from MimicPrep..apachePotassium 
	group by ICUSTAY_ID
	having count(ICUSTAY_ID)>1
) d on a.icustay_id = d.icustay_id and a.ROW_ID <> d.minrowid
--98

select count(ICUSTAY_ID)
from MimicPrep..apachePotassium
--2583

--drop table  MimicPrep..apacheSodiumlab 
;
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
where itemid in (50983)
and VALUENUM is not null 
and ISNUMERIC(valuenum) = 1 
group by l.hadm_id
-- with 60 min buffer
)
select ce.*
into mimicprep..apachePotassiumlab
from LABEVENTS ce
inner join firstevent fe on ce.HADM_ID = fe.HAdm_ID and ce.CHARTTIME = fe.firstcharted
--where itemid in (50983) --31253
where itemid in (50971) --31253
and VALUENUM is not null --31253 -> 31125
and ISNUMERIC(valuenum) = 1 --31125 -> 31125
order by valuenum
--51839 rows
--51301 rows

select count(*) from mimicprep..apachePotassiumlab
--51839

select distinct HADM_ID
from MimicPrep..apachePotassiumlab 
--51838
--51298
select distinct valuenum from MimicPrep..apachePotassiumlab 
select distinct valuenum from MimicPrep..apachePotassium 
select distinct valuenum from MimicPrep..apachePotassiumCombined



select distinct HADM_ID, itemid, CHARTTIME, value, VALUENUM, VALUEUOM, flag
from MimicPrep..apachePotassiumlab 

select *
from MimicPrep..apachePotassiumlab a
inner join (
	select HADM_ID, min(CHARTTIME) firststored
	from MimicPrep..apachePotassiumlab
	group by HADM_ID
	having count(HADM_ID)>1
) d on a.HADM_ID = d.HADM_ID
order by 3 

--drop more dupes
delete from a
from MimicPrep..apachePotassiumlab a
inner join (
	select HADM_ID, max(ROW_ID) maxrowid
	from MimicPrep..apachePotassiumlab
	group by HADM_ID
	having count(HADM_ID)>1
) d on a.HADM_ID = d.HADM_ID and a.ROW_ID <> maxrowid
--1

select count(*)
from MimicPrep..apachePotassiumlab 
--51838



select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apachePotassium ah on fafi.hadm_id = ah.HADM_ID and fafi.ICUSTAY_ID = ah.ICUSTAY_ID
--17459

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apachePotassiumlab ah on fafi.hadm_id = ah.HADM_ID 
--40105


--; with combinedResults as (
 select  * 
 into mimicprep..apachePotassiumCombined
 from (
	 select *,  ROW_NUMBER() OVER(PARTITION BY hadm_id ORDER BY charttime, source desc) firstrank
	 from (
		 select subject_id, hadm_id, itemid, charttime, value, valuenum, valueuom
		 , 'lab' source
		 from MimicPrep..apachePotassium 
		 union 
		 select subject_id, hadm_id, itemid, charttime, value, valuenum, valueuom 
		 , 'chart'
		 from MimicPrep..apachePotassiumlab 
	 ) a
 ) b
 where firstrank = 1
 --) --51893xx 51427
select * 
--into apachePotassiumCombined
--from mimicprep..admissions_FirstwithFirstICUStays fafi
--inner join combinedResults ah on fafi.hadm_id = ah.HADM_ID 
--40158
--where source = 'chart'  --37996
