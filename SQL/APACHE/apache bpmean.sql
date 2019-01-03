;
with firstevent as (
select icustay_id, min(charttime) as firstcharted
from chartevents
where itemid in (456,220181,220052)
group by icustay_id
--51600
)
select ce.*
into mimicprep..apacheBPMean
from chartevents ce
inner join firstevent fe on ce.ICUSTAY_ID = fe.ICUSTAY_ID and ce.CHARTTIME = fe.firstcharted
where itemid in (456,220181,220052) --51672
and VALUENUM is not null --51672 -> 51327
and ISNUMERIC(valuenum) = 1 --51327 -> 51327
and valuenum >= 10	and valuenum <=350 --51327 -> 51263
and (error = 0 or error is null) --51263 --> 51200
order by valuenum

--drop table mimicprep..apacheBPMean


select distinct ICUSTAY_ID
from MimicPrep..apacheBPMean 
--51132

--drop records if not first stored
delete from a
from MimicPrep..apacheBPMean a
inner join (
	select icustay_id, min(storetime) firststored
	from MimicPrep..apacheBPMean 
	group by ICUSTAY_ID
	having count(ICUSTAY_ID)>1
) d on a.icustay_id = d.icustay_id and a.storetime <> d.firststored
--19

delete from a
from MimicPrep..apacheBPMean a
inner join (
	select icustay_id, min(storetime) firststored, min(row_id) minrowid
	from MimicPrep..apacheBPMean 
	group by ICUSTAY_ID
	having count(ICUSTAY_ID)>1
) d on a.icustay_id = d.icustay_id and a.ROW_ID <> d.minrowid
--49

select count(ICUSTAY_ID)
from MimicPrep..apacheBPMean 

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
45921 

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apacheBPMean ah on fafi.hadm_id = ah.HADM_ID and fafi.ICUSTAY_ID = ah.ICUSTAY_ID
36570