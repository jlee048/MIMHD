;
with firstEvent as (
select h.nhi, min(h.eventStart) firstEvent
from sc.HospitalisationsPlus h
INNER JOIN lookups.ACHIProcedure p ON p.code = h.opCode
WHERE opcode is not null and opcode != 0  -- has operation --6,969,498
and  DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 >= 16 --16 and over --6154973
--and (ASA = 9 OR ASA is null) --unknown ASA or no ASA --4232542
and p.isOperation = 1
group by h.nhi
)
SELECT 
h.[nhi]
,DATEDIFF(DAY, DOB, eventStart) / 365.25 ageAtAdmission

      --,[DOB]
      ,[gender]
      ,[ethnicGroup]
      ,[domicileCode]
      ,[DHB]
      ,[eventType]
      ,[endType]
      ,[facility]
--      ,[opCode]
--      ,[opBlkNum]
      ,[opChapNum]
--      ,[op02Code]
--      ,[op02BlkNum]
      ,[op02ChapNum]
--      ,[op03Code]
--      ,[op03BlkNum]
      ,[op03ChapNum]
      ,[opSeverity]
      --,[diag01]
      --,[diag01Subgroup]
      --,[diag01Chapter]
      --,[diag02]
      --,[diag02Subgroup]
      --,[diag02Chapter]
      --,[diag03]
      --,[diag03Subgroup]
      --,[diag03Chapter]
      --,[ecode]
      --,[opAgeDays]
      --,[opAgeYears]
--      ,[opAgeYearsFractional]
      --,[opYear]
      --,[opMonth]
      --,[opWeek]
      --,[opDayOfWeek]
      --,[DaysTillOp]
      --,[DaysTillDischarge]

      ,[eventDuration]
      --,[EventYear]
      --,[eventMonth]
      --,[EventDayOfWeek]
      ,[eventStart]
      ,[eventEnd]

      ,[AdmissionType]
      ,h.[ASA]
      ,h.[isEmergency]
	  , p.IsEmergency
      ,[IsCancer]
      ,[IsSmoker]
      ,[WasSmoker]
      ,[HasDiabetesT1]
      ,[HasDiabetesT2]
      ,[IsNeuroTrauma]
      ,h.[id]
--      ,[dateOfDeath]
--      ,[deathCode]
--      ,[causeOfDeath]
      ,[AgeAtDeathFractional]

--      ,[DaysTillDeath]

      ,[DiedDuringThisEvent] InHospitalMortality
--, case when dateofDeath IS NULL then 0 else 1 end InHospitalMortality
, case when datediff(DAY, eventStart,  dateOfDeath) <= 1 then 1 else 0 end ShortTermMortality1d
, case when datediff(DAY, eventStart,  dateOfDeath) <= 3 then 1 else 0 end ShortTermMortality3d
, case when datediff(DAY, eventEnd,  dateOfDeath) <= 30 then 1 else 0 end LongTermMortality30d
, case when datediff(DAY, eventEnd,  dateOfDeath) <= 365 then 1 else 0 end LongTermMortality1year


      ,[Drugs1m]
      ,[Drugs6m]
      --,[Drugs9m]
      ,[Drugs12m]
      --,[Drugs18m]
      --,[Drugs24m]
      --,[Drugs36m]
      --,[Drugs60m]
      --,[DrugsTotal]
      ,[Labs1m]
      ,[Labs6m]
      --,[Labs9m]
      ,[Labs12m]
      --,[Labs18m]
      --,[Labs24m]
      --,[Labs36m]
      --,[Labs60m]
      --,[LabsTotal]
      ,[OPVisits1m]
      ,[OPVisits6m]
      --,[OPVisits9m]
      ,[OPVisits12m]
      --,[OPVisits18m]
      --,[OPVisits24m]
      --,[OPVisits36m]
      --,[OPVisits60m]
      --,[OPVisitsTotal]
      ,[IPVisits1m]
      ,[IPVisits6m]
      --,[IPVisits9m]
      ,[IPVisits12m]
      --,[IPVisits18m]
      --,[IPVisits24m]
      --,[IPVisits36m]
      --,[IPVisits60m]
      --,[IPVisitsTotal]
--into mohprep..firstadmissions18andoverfrom2006_nonmortality
FROM [MoH].[sc].[HospitalisationsPlus] h
inner join firstEvent fe on fe.nhi = h.nhi and fe.firstEvent = h.eventStart
INNER JOIN lookups.ACHIProcedure p ON p.code = h.opCode
--where (ASA <> 9 AND ASA is NOT null) 
where eventStart >= '2006-01-01' --2,213,728
AND opAgeYearsFractional >= 18
--and opSeverity is not null
AND p.IsOperation = 1
--and DiedDuringThisEvent = 1 --4544 (2012), 10617 (2008), 16176 (mortality doesnt go back that far) --(1982) --16059 from 2006 onwards
and diedduringthisEvent = 0
--and (ASA = 9 or ASA is null)  --8495
--2197669


--first admissions where procedure is operation and age at operation is 18 or older
1659202
and opcode is not null -- same 1659202

1662575 lookup again
1696553 w/o lookup i.e. maybe events with same eventstart

1662575 vs 1659202. there are multiple events for some nhi
distinct h.* 


;
with firstEvent as (
select h.nhi, min(h.eventStart) firstEvent
from sc.HospitalisationsPlus h
INNER JOIN lookups.ACHIProcedure p ON p.code = h.opCode
WHERE 
opcode is not null and opcode != 0  -- has operation --6,969,498
--and  DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 >= 18 --16 and over --6154973
--AND 
and opAgeYearsFractional >= 18
AND p.IsOperation = 1
--and (ASA = 9 OR ASA is null) --unknown ASA or no ASA --4232542
group by h.nhi
)
, multipleFirstEvents as ( --36539 vs 9307 vs 3366 /*patients with multiple events*/
select h.nhi, count(*) num
FROM [MoH].[sc].[HospitalisationsPlus] h
INNER JOIN lookups.ACHIProcedure p ON p.code = h.opCode
inner join firstEvent fe on fe.nhi = h.nhi and fe.firstEvent = h.eventStart 
where opcode is not null and opcode != 0
and opAgeYearsFractional >= 18
AND p.IsOperation = 1
group by h.nhi
having count(*) > 1
)
, demulti as (
--, recoveredwithmortality as (
	select * from ( -- get the 1st one ordered by ASA (nulls last)) 3366 rows
	--alternatively, we can try to recover 183 rows from those that have multipleFirstEvents, discard the rest
		select  h.*
		,row_number() over (partition by h.nhi order by h.asa desc) ranknum
		FROM [MoH].[sc].[HospitalisationsPlus] h
		INNER JOIN lookups.ACHIProcedure p ON p.code = h.opCode
		inner join firstEvent fe on fe.nhi = h.nhi and fe.firstEvent = h.eventStart 
		where opcode is not null and opcode != 0
		and opAgeYearsFractional >= 18
		AND p.IsOperation = 1
		and h.nhi in (select nhi from multipleFirstEvents)
		--and h.DiedDuringThisEvent = 1
	) a where ranknum = 1
)
, combined as (
	select h.*, 0 ranknumber
	FROM [MoH].[sc].[HospitalisationsPlus] h
	inner join firstEvent fe on fe.nhi = h.nhi and fe.firstEvent = h.eventStart 
	INNER JOIN lookups.ACHIProcedure p ON p.code = h.opCode
	where opcode is not null and opcode != 0
	and opAgeYearsFractional >= 18
	and p.IsOperation = 1
	and h.nhi not in ( select nhi from multipleFirstEvents)
	union 
	select * from demulti
) 
select * 
, DATEDIFF(DAY, DOB, eventStart) / 365.25 ageAtAdmission
, [DiedDuringThisEvent] InHospitalMortality
, case when datediff(DAY, eventStart,  dateOfDeath) <= 1 then 1 else 0 end ShortTermMortality1d
, case when datediff(DAY, eventStart,  dateOfDeath) <= 3 then 1 else 0 end ShortTermMortality3d
, case when datediff(DAY, eventEnd,  dateOfDeath) <= 30 then 1 else 0 end LongTermMortality30d
, case when datediff(DAY, eventEnd,  dateOfDeath) <= 365 then 1 else 0 end LongTermMortality1year
into mohprep..firstadmissions18plusfrom2006NonMortality
from combined
where DiedDuringThisEvent = 0

firstadmissions18plusfrom2006aNonMortality

firstadmissions18plusfrom2006a
--first admissions where procedure is operation and age at operation is 18 or older
1659202 combined

firstadmissions18plusfrom2006aNonMortality
1649165
1649161 firstadmissions18plusfrom2006NonMortality???


select * from mohprep..firstadmissions18plusfrom2006NonMortality h where (h.ASA <> 9 AND h.ASA is NOT null) 
788326


firstadmissions18plusfrom2006aMortality
10036

select * from mohprep..firstadmissions18plusfrom2006Mortality h where (h.ASA <> 9 AND h.ASA is NOT null) 
3326


with firstEvent as (
select h.nhi, min(h.eventStart) firstEvent
from sc.HospitalisationsPlus h
INNER JOIN lookups.ACHIProcedure p ON p.code = h.opCode
WHERE 
opcode is not null and opcode != 0  -- has operation --6,969,498
--and  DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 >= 18 --16 and over --6154973
--AND 
and opAgeYearsFractional >= 18
AND p.IsOperation = 1
--and (ASA = 9 OR ASA is null) --unknown ASA or no ASA --4232542
group by h.nhi
)
, multipleFirstEvents as ( --36539 vs 9307 vs 3366 /*patients with multiple events*/
select h.nhi, count(*) num
FROM [MoH].[sc].[HospitalisationsPlus] h
INNER JOIN lookups.ACHIProcedure p ON p.code = h.opCode
inner join firstEvent fe on fe.nhi = h.nhi and fe.firstEvent = h.eventStart 
where opcode is not null and opcode != 0
and opAgeYearsFractional >= 18
AND p.IsOperation = 1
group by h.nhi
having count(*) > 1
)
, demulti as (
--, recoveredwithmortality as (
	select * from ( -- get the 1st one ordered by ASA (nulls last)) 3366 rows
	--alternatively, we can try to recover 183 rows from those that have multipleFirstEvents, discard the rest
		select  h.*
		,row_number() over (partition by h.nhi order by h.asa desc) ranknum
		FROM [MoH].[sc].[HospitalisationsPlus] h
		INNER JOIN lookups.ACHIProcedure p ON p.code = h.opCode
		inner join firstEvent fe on fe.nhi = h.nhi and fe.firstEvent = h.eventStart 
		where opcode is not null and opcode != 0
		and opAgeYearsFractional >= 18
		AND p.IsOperation = 1
		and h.nhi in (select nhi from multipleFirstEvents)
		--and h.DiedDuringThisEvent = 1
	) a where ranknum = 1
)
, combined as (
	select h.*, 0 ranknumber
	FROM [MoH].[sc].[HospitalisationsPlus] h
	inner join firstEvent fe on fe.nhi = h.nhi and fe.firstEvent = h.eventStart 
	INNER JOIN lookups.ACHIProcedure p ON p.code = h.opCode
	where opcode is not null and opcode != 0
	and opAgeYearsFractional >= 18
	and p.IsOperation = 1
	and h.nhi not in ( select nhi from multipleFirstEvents)
	union 
	select * from demulti
) 
select * 
, DATEDIFF(DAY, DOB, eventStart) / 365.25 ageAtAdmission
, [DiedDuringThisEvent] InHospitalMortality
, case when datediff(DAY, eventStart,  dateOfDeath) <= 1 then 1 else 0 end ShortTermMortality1d
, case when datediff(DAY, eventStart,  dateOfDeath) <= 3 then 1 else 0 end ShortTermMortality3d
, case when datediff(DAY, eventEnd,  dateOfDeath) <= 30 then 1 else 0 end LongTermMortality30d
, case when datediff(DAY, eventEnd,  dateOfDeath) <= 365 then 1 else 0 end LongTermMortality1year
, CAST(CHECKSUM(NEWID()) & 0x7fffffff AS float) / CAST (0x7fffffff AS int) randomnumber
into mohprep..firstadmissions18plusfrom2006NonMortality
from combined
where DiedDuringThisEvent = 0



--AND  (h.ASA <> 9 AND h.ASA is NOT null) 
--and diedduringthisEvent = 1
--and (h.ASA = 9 or h.ASA is null)  --8495
--1 357 938 rows where opseverity is not null

--1356695

-->2006 because mortality records before that are of poor quality
-->=18
--1306762 no mortality
--6892 mortality
-- total is op and 18 from 2006
-- 1313654 total records


686,883 with missing ASA
628,196 with ASA

of those non mortality (1306762)
625,929 have ASA


of those mortality (6892)
3370 have ASA
===============================================================================
select count(*) from sc.HospitalisationsPlus h
where DiedDuringThisEvent = 0
and  (h.ASA <> 9 AND h.ASA is NOT null)
2312834

select count(*) from sc.HospitalisationsPlus h
where DiedDuringThisEvent = 0
and (h.ASA = 9 or h.ASA is null) 
10360984


select count(*) from sc.HospitalisationsPlus h
where DiedDuringThisEvent = 0
and (h.ASA = 9 or h.ASA is null) 

select count(*) from mohprep..firstadmissions18plusfrom2006Mortality
--10036

select count(*) from mohprep..firstadmissions18plusfrom2006NonMortality  h
where randomnumber <  25000/1649161.0
--24772

select count(*) from mohprep..firstadmissions18plusfrom2006NonMortality  h
where randomnumber <  25000/1649161.0
and  (h.ASA <> 9 AND h.ASA is NOT null) 
11848

select count(*) from mohprep..firstadmissions18plusfrom2006NonMortality h
where randomnumber <  25000/1649161.0
and  (h.ASA = 9 or h.ASA is null) 
12924


select count(*) from mohprep..firstadmissions18plusfrom2006Mortality h
where (h.ASA <> 9 AND h.ASA is NOT null) 
3326


select count(*) from mohprep..firstadmissions18plusfrom2006Mortality h
where (h.ASA = 9 or h.ASA is null) 
6710





select count(*) from mohprep..firstadmissions18plusfrom2006NonMortality
1649161

select 25000/1649161.0 = 0.012127378

firstadmissions18plusfrom2006aNonMortality
1649165
1649161 firstadmissions18plusfrom2006NonMortality???

select * 
into firstadmission18plusfrom2006Subset
from (
select * from mohprep..firstadmissions18plusfrom2006NonMortality  h
where randomnumber <  25000/1649161.0
union 
select *, 0 randomnumber from mohprep..firstadmissions18plusfrom2006Mortality  h
) a

(34808 rows affected)