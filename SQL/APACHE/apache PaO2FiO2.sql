--select * from mimicprep..bloodgasart

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
select l.hadm_id, min(l.charttime) mincharttime
from mimicprep..bloodgasart l
--inner join firsticustayforadmission f on l.HADM_ID = f.hadm_id and l.CHARTTIME<=dateadd(minute,60,f.outtime)
where paO2FiO2 is not null
group by l.hadm_id
  --22744
  --21688
  )
  select bga.* 
  --into mimicprep..apachePaO2FiO2
  --into mimicprep..apachePaO2FiO2v2
  from mimicprep..bloodgasart bga
  inner join  firstevent fe on fe.hadm_id = bga.hadm_id and fe.mincharttime = bga.charttime



select * 
from mimicprep..admissions_FirstwithFirstICUStays fafi
inner join mimicprep..apachePaO2FiO2v2 ah on fafi.hadm_id = ah.HADM_ID 
--17590
--18371