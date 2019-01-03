;
with firstevent as (
select icustay_id, min(charttime) as firstcharted
from chartevents
where itemid in (780,223830)
and VALUENUM is not null --31253 -> 31125
and ISNUMERIC(valuenum) = 1 --31125 -> 31125
--and valuenum >= 10	and valuenum <=350 --51327 -> 51263
and valuenum < 10	and valuenum > 3 --31111 -> 31110
and (error = 0 or error is null) --31125 --> 31111
group by icustay_id
--30833
--30729
)
select ce.*
into mimicprep..apacheArtPHchart
from chartevents ce
inner join firstevent fe on ce.ICUSTAY_ID = fe.ICUSTAY_ID and ce.CHARTTIME = fe.firstcharted
where itemid in (780,223830) --31253
and VALUENUM is not null --31253 -> 31125
and ISNUMERIC(valuenum) = 1 --31125 -> 31125
and valuenum < 10	and valuenum > 3 --31111 -> 31110
and (error = 0 or error is null) --31125 --> 31111
order by valuenum
--31123



select distinct ICUSTAY_ID
from MimicPrep..apacheArtPHchart 
--30702
--30890

--drop records if not first stored
delete from a
from MimicPrep..apacheArtPHchart a
inner join (
	select icustay_id, min(storetime) firststored
	from MimicPrep..apacheArtPHchart 
	group by ICUSTAY_ID
	having count(ICUSTAY_ID)>1
) d on a.icustay_id = d.icustay_id and a.storetime <> d.firststored

delete from a
from MimicPrep..apacheArtPHchart a
inner join (
	select icustay_id, min(storetime) firststored, min(row_id) minrowid
	from MimicPrep..apacheArtPHchart 
	group by ICUSTAY_ID
	having count(ICUSTAY_ID)>1
) d on a.icustay_id = d.icustay_id and a.ROW_ID <> d.minrowid

select count(ICUSTAY_ID)
from MimicPrep..apacheArtPHchart
--30890
--30702
select *
from MimicPrep..apacheArtPHchart

select * from labevents

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
where itemid in (50820)
and VALUENUM is not null 
and ISNUMERIC(valuenum) = 1 
and valuenum < 10	and valuenum > 3 
group by l.hadm_id
--38918
--32408  using between
--37116 using <=  (this means labs might have earlier recorded time)
--37123 with 60 min buffer
)
select ce.*
into mimicprep..apacheArtPHlab
from LABEVENTS ce
inner join firstevent fe on ce.HADM_ID = fe.HAdm_ID and ce.CHARTTIME = fe.firstcharted
where itemid in (50820) --31253
and VALUENUM is not null --31253 -> 31125
and ISNUMERIC(valuenum) = 1 --31125 -> 31125
and valuenum < 10	and valuenum > 3 --31111 -> 31110
order by valuenum
--38917 rows
--37123
--drop table  mimicprep..apacheArtPHlab

select distinct HADM_ID
from MimicPrep..apacheArtPHlab 
--38917
select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apacheArtPHchart ah on fafi.hadm_id = ah.HADM_ID and fafi.ICUSTAY_ID = ah.ICUSTAY_ID
--22681

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apacheArtPHlab ah on fafi.hadm_id = ah.HADM_ID 
--30195
--29321

; with combinedResults as (
 select  * 
 into mimicprep..apacheArtPHCombined
 from (
	 select *,  ROW_NUMBER() OVER(PARTITION BY hadm_id ORDER BY charttime, source desc) firstrank
	 from (
		 select subject_id, hadm_id, itemid, charttime, value, valuenum, valueuom
		 , 'lab' source
		 from MimicPrep..apacheArtPHlab --38917
		 union 
		 select subject_id, hadm_id, itemid, charttime, value, valuenum, valueuom 
		 , 'chart'
		 from MimicPrep..apacheArtPHchart --30702
	 ) a
 ) b
 where firstrank = 1
 ) --38962
select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join combinedResults ah on fafi.hadm_id = ah.HADM_ID 
where source = 'chart'
 --29755
 ----with 479 chart
 ;
 with firstevent as (
	select HADM_ID, min(charttime) as firstcharted
	, 'chart' source
	from chartevents
	where itemid in (780,223830)
	and VALUENUM is not null --31253 -> 31125
	and ISNUMERIC(valuenum) = 1 --31125 -> 31125
	and valuenum < 10	and valuenum > 3 --31111 -> 31110
	and (error = 0 or error is null) --31125 --> 31111
	group by HADM_ID
	union
	select hadm_id, min(charttime) as firstcharted
	, 'lab' source
	from labevents
	where itemid in (50820)
	and VALUENUM is not null 
	and ISNUMERIC(valuenum) = 1 
	and valuenum < 10	and valuenum > 3 
	group by hadm_id
) --59501 cs 68247