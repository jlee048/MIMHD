select *
from labevents l
where itemid in (50816)
and VALUENUM is not null 
and ISNUMERIC(valuenum) = 1 
order by valuenum
%

select *
from chartevents 
where itemid in (223835)
and VALUENUM is not null 
and ISNUMERIC(valuenum) = 1 
order by valuenum


select *
from chartevents 
where itemid in (3420)
and VALUENUM is not null 
and ISNUMERIC(valuenum) = 1 
order by valuenum

--drop table  mimicprep..apacheFiO2
;
with firstevent as (
select icustay_id, min(charttime) as firstcharted
from chartevents
where itemid in (3420,223835,190,3422)
and VALUENUM is not null 
and ISNUMERIC(valuenum) = 1 
and valuenum >= 0	and valuenum <=100 --51327 -> 51263
and (error = 0 or error is null) 
group by icustay_id
--31954
)
select ce.*
into mimicprep..apacheFiO2
from chartevents ce
inner join firstevent fe on ce.ICUSTAY_ID = fe.ICUSTAY_ID and ce.CHARTTIME = fe.firstcharted
where itemid in (3420,223835,190,3422)
and VALUENUM is not null --31253 -> 31125
and ISNUMERIC(valuenum) = 1 --31125 -> 31125
and valuenum >= 0	and valuenum <=100 --51327 -> 51263
and (error = 0 or error is null) --31125 --> 31111
order by valuenum
--33391




select distinct ICUSTAY_ID
from MimicPrep..apacheFiO2 
--31953

--drop records if not first stored
delete from a
from MimicPrep..apacheFiO2 a
inner join (
	select icustay_id, min(storetime) firststored
	from MimicPrep..apacheFiO2 
	group by ICUSTAY_ID
	having count(ICUSTAY_ID)>1
) d on a.icustay_id = d.icustay_id and a.storetime <> d.firststored
--32

delete from a
from MimicPrep..apacheFiO2 a
inner join (
	select icustay_id, min(storetime) firststored, min(row_id) minrowid
	from MimicPrep..apacheFiO2 
	group by ICUSTAY_ID
	having count(ICUSTAY_ID)>1
) d on a.icustay_id = d.icustay_id and a.ROW_ID <> d.minrowid
--1406

select count(ICUSTAY_ID)
from MimicPrep..apacheFiO2
--31953




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
where itemid in (50816)
and VALUENUM is not null 
and ISNUMERIC(valuenum) = 1 
and valuenum >= 0	and valuenum <=100 
group by l.hadm_id
--
-- using <=  (this means labs might have earlier recorded time)
-- with 60 min buffer
)
select ce.*
into mimicprep..apacheFiO2lab
from LABEVENTS ce
inner join firstevent fe on ce.HADM_ID = fe.HAdm_ID and ce.CHARTTIME = fe.firstcharted
where itemid in (50816) --31253
and VALUENUM is not null --31253 -> 31125
and ISNUMERIC(valuenum) = 1 --31125 -> 31125
and valuenum >= 0	and valuenum <=100 
order by valuenum
--18782 rows

select distinct HADM_ID
from MimicPrep..apacheFiO2lab 
--18782

--select distinct HADM_ID, itemid, CHARTTIME, value, VALUENUM, VALUEUOM, flag
--from MimicPrep..apacheFiO2lab 

--select top 100 * from MimicPrep..apacheFiO2lab 

--select *
--from MimicPrep..apacheFiO2lab a
--inner join (
--	select HADM_ID, min(CHARTTIME) firststored
--	from MimicPrep..apacheFiO2lab
--	group by HADM_ID
--	having count(HADM_ID)>1
--) d on a.HADM_ID = d.HADM_ID
--order by 3 



----drop more dupes
--delete from a
--from MimicPrep..apacheFiO2lab a
--inner join (
--	select HADM_ID, max(itemid) maxitemid
--	from MimicPrep..apacheFiO2lab
--	group by HADM_ID
--	having count(HADM_ID)>1
--) d on a.HADM_ID = d.HADM_ID and a.itemid <> maxitemid
----178 delted

select count(*)
from MimicPrep..apacheFiO2lab 
--18782

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apacheFiO2 ah on fafi.hadm_id = ah.HADM_ID and fafi.ICUSTAY_ID = ah.ICUSTAY_ID
--23949

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apacheFiO2lab ah on fafi.hadm_id = ah.HADM_ID 
--15279

--drop table apacheFiO2Combined

; with combinedResults as (
 select  * 
--into mimicprep..apacheFiO2Combined 
 from (
	 select *,  ROW_NUMBER() OVER(PARTITION BY hadm_id ORDER BY charttime, source desc) firstrank
	 from (
		 select subject_id, hadm_id, itemid, charttime, value, valuenum, valueuom
		 , 'lab' source
		 from MimicPrep..apacheFiO2 --11197
		 union 
		 select subject_id, hadm_id, itemid, charttime, value, valuenum, valueuom 
		 , 'chart'
		 from MimicPrep..apacheFiO2lab --15279
	 ) a
 ) b
 where firstrank = 1
 ) --32263
select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join combinedResults ah on fafi.hadm_id = ah.HADM_ID 
--25948
where source = 'chart'  --11374

 