;
with firstevent as (
select icustay_id, min(charttime) as firstcharted
from chartevents
where itemid in (678,223761)
group by icustay_id
--51591
)
select ce.*
into mimicprep..apacheTemp
from chartevents ce
inner join firstevent fe on ce.ICUSTAY_ID = fe.ICUSTAY_ID and ce.CHARTTIME = fe.firstcharted
where itemid in (678,223761) --51592
and VALUENUM is not null --51592 -> 51216

and ISNUMERIC(valuenum) = 1 --51216 -> 51216
and valuenum >= 40	--51216 -> 51008
order by valuenum


select distinct ICUSTAY_ID
from MimicPrep..apacheTemp 
--51006

--drop records if not first stored
delete from a
from MimicPrep..apacheTemp a
inner join (
	select icustay_id, min(storetime) firststored
	from MimicPrep..apacheTemp 
	group by ICUSTAY_ID
	having count(ICUSTAY_ID)>1
) d on a.icustay_id = d.icustay_id and a.storetime <> d.firststored

select count(ICUSTAY_ID)
from MimicPrep..apacheTemp 

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
45921 

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apacheTemp ah on fafi.hadm_id = ah.HADM_ID and fafi.ICUSTAY_ID = ah.ICUSTAY_ID
36381