collated itemids of interest
compared counts for each itemid
dropped those that count of icustays less than x

inconsistencies
unit of measurement
missing values
outliers
all units bpm 


;
with firstevent as (
select icustay_id, min(charttime) as firstcharted
from chartevents
where itemid in (211,220045)
group by icustay_id
--60187
)
select ce.*
into mimicprep..apacheheart
from chartevents ce
inner join firstevent fe on ce.ICUSTAY_ID = fe.ICUSTAY_ID and ce.CHARTTIME = fe.firstcharted
where itemid in (211,220045)
and VALUENUM is not null --60190 -> 59959
and valuenum <= 300	--59959 -> 59956
and ISNUMERIC(valuenum) = 1 --59956 -> 59956
order by valuenum

--select distinct VALUEnum
--from chartevents
--where itemid in (211,220045)
select distinct ICUSTAY_ID
from MimicPrep..apacheheart 
--59952

--drop records if not first stored
delete from a
from MimicPrep..apacheheart a
inner join (
	select icustay_id, min(storetime) firststored
	from MimicPrep..apacheheart 
	group by ICUSTAY_ID
	having count(ICUSTAY_ID)>1
) d on a.icustay_id = d.icustay_id and a.storetime <> d.firststored

select count(ICUSTAY_ID)
from MimicPrep..apacheheart 
59952

ROW_ID	SUBJECT_ID	HADM_ID	ICUSTAY_ID	ITEMID	CHARTTIME	STORETIME	CGID	VALUE	VALUENUM	VALUEUOM	WARNING	ERROR	RESULTSTATUS	STOPPED
125282471	17809	101503	278029	211	2102-11-24 18:30:00.0000000	2102-11-24 18:53:00.0000000	17457	67	67	BPM	NULL	NULL	NULL	NotStopd
125282472	17809	101503	278029	211	2102-11-24 18:30:00.0000000	2102-11-24 19:13:00.0000000	17457	67	67	BPM	NULL	NULL	NULL	NotStopd
137005480	20166	120963	256225	211	2127-12-11 19:00:00.0000000	2127-12-11 19:17:00.0000000	21327	103	103	BPM	NULL	NULL	NULL	NotStopd
137005481	20166	120963	256225	211	2127-12-11 19:00:00.0000000	2127-12-11 19:25:00.0000000	21327	108	108	BPM	NULL	NULL	NULL	NotStopd
155879326	24206	137291	208721	211	2166-09-08 21:00:00.0000000	2166-09-08 21:46:00.0000000	17701	79	79	BPM	NULL	NULL	NULL	NotStopd
155879327	24206	137291	208721	211	2166-09-08 21:00:00.0000000	2166-09-09 00:04:00.0000000	17701	73	73	BPM	NULL	NULL	NULL	NotStopd
113754179	15629	167015	202900	211	2197-07-01 17:00:00.0000000	2197-07-01 17:50:00.0000000	15830	81	81	BPM	NULL	NULL	NULL	NotStopd
113754180	15629	167015	202900	211	2197-07-01 17:00:00.0000000	2197-07-01 17:56:00.0000000	15830	87	87	BPM	NULL	NULL	NULL	NotStopd

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
45921 

select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apacheheart ah on fafi.hadm_id = ah.HADM_ID and fafi.ICUSTAY_ID = ah.ICUSTAY_ID
44839
