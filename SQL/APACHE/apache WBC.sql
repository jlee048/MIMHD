;
with firstevent as (
select icustay_id, min(charttime) as firstcharted
from chartevents
where itemid in (4200,861,1127,1542,220546)
and VALUENUM is not null 
and ISNUMERIC(valuenum) = 1 
--and valuenum >= 10	and valuenum <=350 --51327 -> 51263
--and valuenum < 10	and valuenum > 3 --31111 -> 31110
and (error = 0 or error is null) 
group by icustay_id
--56913
)
select ce.*
into mimicprep..apacheWBC
from chartevents ce
inner join firstevent fe on ce.ICUSTAY_ID = fe.ICUSTAY_ID and ce.CHARTTIME = fe.firstcharted
where itemid in (4200,861,1127,1542,220546)
and VALUENUM is not null --31253 -> 31125
and ISNUMERIC(valuenum) = 1 --31125 -> 31125
--and valuenum < 10	and valuenum > 3 --31111 -> 31110
and (error = 0 or error is null) --31125 --> 31111
order by valuenum
--107649

select HADM_ID, itemid, count(*) c1, sum(count(*)) over (partition by hadm_id) c2, AVG(VALUENUM) mean 
from chartevents ce
where ce.itemid in (1542, 4200, 861, 1127)
group by HADM_ID, ITEMID
order by 4 desc, 1, 2
HADM_ID	itemid	c1	c2	mean
177998	861	129	329	9.44627906976744
177998	1127	129	329	9.44627906976744
177998	1542	71	329	12.0394366197183




select distinct ICUSTAY_ID
from MimicPrep..apacheWBC 
--56912

--drop records if not first stored
delete from a
from MimicPrep..apacheWBC a
inner join (
	select icustay_id, min(storetime) firststored
	from MimicPrep..apacheWBC 
	group by ICUSTAY_ID
	having count(ICUSTAY_ID)>1
) d on a.icustay_id = d.icustay_id and a.storetime <> d.firststored
--1367

delete from a
from MimicPrep..apacheWBC a
inner join (
	select icustay_id, min(storetime) firststored, min(row_id) minrowid
	from MimicPrep..apacheWBC 
	group by ICUSTAY_ID
	having count(ICUSTAY_ID)>1
) d on a.icustay_id = d.icustay_id and a.ROW_ID <> d.minrowid
--49370

select count(ICUSTAY_ID)
from MimicPrep..apacheWBC
--30702

----



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
where itemid in (51301, 51300)
and VALUENUM is not null 
and ISNUMERIC(valuenum) = 1 
group by l.hadm_id
--
-- using <=  (this means labs might have earlier recorded time)
-- with 60 min buffer
)
select ce.*
into mimicprep..apacheWBClab
from LABEVENTS ce
inner join firstevent fe on ce.HADM_ID = fe.HAdm_ID and ce.CHARTTIME = fe.firstcharted
where itemid in (51301, 51300) --31253
and VALUENUM is not null --31253 -> 31125
and ISNUMERIC(valuenum) = 1 --31125 -> 31125
order by valuenum
--56079 rows

select distinct HADM_ID
from MimicPrep..apacheWBClab 
--56001

select distinct HADM_ID, itemid, CHARTTIME, value, VALUENUM, VALUEUOM, flag
from MimicPrep..apacheWBClab 

select top 100 * from MimicPrep..apacheWBClab 

select *
from MimicPrep..apacheWBCLab a
inner join (
	select HADM_ID, min(CHARTTIME) firststored
	from MimicPrep..apacheWBCLab
	group by HADM_ID
	having count(HADM_ID)>1
) d on a.HADM_ID = d.HADM_ID
order by 3 



--drop more dupes
delete from a
from MimicPrep..apacheWBCLab a
inner join (
	select HADM_ID, max(itemid) maxitemid
	from MimicPrep..apacheWBCLab
	group by HADM_ID
	having count(HADM_ID)>1
) d on a.HADM_ID = d.HADM_ID and a.itemid <> maxitemid
--178 delted

select count(*)
from MimicPrep..apacheWBClab 
--56001

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apacheWBC ah on fafi.hadm_id = ah.HADM_ID and fafi.ICUSTAY_ID = ah.ICUSTAY_ID
--42187

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apacheWBClab ah on fafi.hadm_id = ah.HADM_ID 
--44274


; with combinedResults as (
 select  * 
 into mimicprep..apacheWBCCombined 
 from (
	 select *,  ROW_NUMBER() OVER(PARTITION BY hadm_id ORDER BY charttime, source desc) firstrank
	 from (
		 select subject_id, hadm_id, itemid, charttime, value, valuenum, valueuom
		 , 'lab' source
		 from MimicPrep..apacheWBC --56912
		 union 
		 select subject_id, hadm_id, itemid, charttime, value, valuenum, valueuom 
		 , 'chart'
		 from MimicPrep..apacheWBClab --56001
	 ) a
 ) b
 where firstrank = 1
 ) --56083
select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join combinedResults ah on fafi.hadm_id = ah.HADM_ID 
--44352
where source = 'chart'  --31616
 --29755
 ----with 479 chart
 