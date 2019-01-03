

;
with firstevent as (
select icustay_id, min(charttime) as firstcharted
from chartevents
where itemid in (184,220739)
group by icustay_id
--52351
)
select ce.*
into mimicprep..apacheGCSEye
from chartevents ce
inner join firstevent fe on ce.ICUSTAY_ID = fe.ICUSTAY_ID and ce.CHARTTIME = fe.firstcharted
where itemid in (184,220739) --52352
and VALUENUM is not null --52352 -> 52243
--and valuenum <= 300	--59959 -> 59956
and ISNUMERIC(valuenum) = 1 --52243 -> 52243
order by valuenum


select distinct ICUSTAY_ID
from MimicPrep..apacheGCSEye 
--52241

--drop records if not first stored
delete from a
from MimicPrep..apacheGCSEye a
inner join (
	select icustay_id, min(storetime) firststored
	from MimicPrep..apacheGCSEye 
	group by ICUSTAY_ID
	having count(ICUSTAY_ID)>1
) d on a.icustay_id = d.icustay_id and a.storetime <> d.firststored

select count(ICUSTAY_ID)
from MimicPrep..apacheGCSEye 
--52241
--(723, 454, , 223900, 223901)

---

;
with firstevent as (
select icustay_id, min(charttime) as firstcharted
from chartevents
where itemid in (723,223900)
group by icustay_id
--52345
)
select ce.*
into mimicprep..apacheGCSVerbal
from chartevents ce
inner join firstevent fe on ce.ICUSTAY_ID = fe.ICUSTAY_ID and ce.CHARTTIME = fe.firstcharted
where itemid in (723,223900) --52346
and VALUENUM is not null --52346 -> 52179
--and valuenum <= 300	--59959 -> 59956
and ISNUMERIC(valuenum) = 1 --52179 -> 52179
order by valuenum
--drop table mimicprep..apachegcsverbal

select distinct ICUSTAY_ID
from MimicPrep..apacheGCSVerbal 
--52177

--drop records if not first stored
delete from a
from MimicPrep..apacheGCSVerbal a
inner join (
	select icustay_id, min(storetime) firststored
	from MimicPrep..apacheGCSVerbal 
	group by ICUSTAY_ID
	having count(ICUSTAY_ID)>1
) d on a.icustay_id = d.icustay_id and a.storetime <> d.firststored

select count(ICUSTAY_ID)
from MimicPrep..apacheGCSVerbal 


---

;
with firstevent as (
select icustay_id, min(charttime) as firstcharted
from chartevents
where itemid in (454,223901)
group by icustay_id
--52340
)
select ce.*
into mimicprep..apacheGCSMotor
from chartevents ce
inner join firstevent fe on ce.ICUSTAY_ID = fe.ICUSTAY_ID and ce.CHARTTIME = fe.firstcharted
where itemid in  (454,223901) --52341
and VALUENUM is not null --52341 -> 52220
--and valuenum <= 300	--59959 -> 59956
and ISNUMERIC(valuenum) = 1 --52220 -> 52220
order by valuenum
--drop table mimicprep..apacheGCSMotor

select distinct ICUSTAY_ID
from MimicPrep..apacheGCSMotor 
--52218

--drop records if not first stored
delete from a
from MimicPrep..apacheGCSMotor a
inner join (
	select icustay_id, min(storetime) firststored
	from MimicPrep..apacheGCSMotor 
	group by ICUSTAY_ID
	having count(ICUSTAY_ID)>1
) d on a.icustay_id = d.icustay_id and a.storetime <> d.firststored

select count(ICUSTAY_ID)
from MimicPrep..apacheGCSMotor 
--



select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
45921 

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apacheGCSEye ah on fafi.hadm_id = ah.HADM_ID and fafi.ICUSTAY_ID = ah.ICUSTAY_ID
37373

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apacheGCSVerbal ah on fafi.hadm_id = ah.HADM_ID and fafi.ICUSTAY_ID = ah.ICUSTAY_ID
37373

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apacheGCSMotor ah on fafi.hadm_id = ah.HADM_ID and fafi.ICUSTAY_ID = ah.ICUSTAY_ID
37373

select * from mimicprep..apacheGCSMotor order by valuenum