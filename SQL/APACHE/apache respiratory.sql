;
with firstevent as (
select icustay_id, min(charttime) as firstcharted
from chartevents
where itemid in (618,220210)
group by icustay_id
--52427
)
select ce.*
into mimicprep..apacherespiratory
from chartevents ce
inner join firstevent fe on ce.ICUSTAY_ID = fe.ICUSTAY_ID and ce.CHARTTIME = fe.firstcharted
where itemid in (618,220210) --52429
and VALUENUM is not null --52429 -> 52196
--and valuenum <= 300	--59959 -> 59956
and ISNUMERIC(valuenum) = 1 --52196 -> 52196
order by valuenum
--bpm vs insp/min
--drop table mimicprep..apacherespiratory


select distinct ICUSTAY_ID
from MimicPrep..apacherespiratory 
--52193

--drop records if not first stored
delete from a
from MimicPrep..apacherespiratory a
inner join (
	select icustay_id, min(storetime) firststored
	from MimicPrep..apacherespiratory 
	group by ICUSTAY_ID
	having count(ICUSTAY_ID)>1
) d on a.icustay_id = d.icustay_id and a.storetime <> d.firststored

select count(ICUSTAY_ID)
from MimicPrep..apacherespiratory 

--52193


select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
45921 

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apacherespiratory ah on fafi.hadm_id = ah.HADM_ID and fafi.ICUSTAY_ID = ah.ICUSTAY_ID
37373
