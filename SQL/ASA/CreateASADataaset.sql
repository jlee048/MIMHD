

with firstEvent as ( --non cardiacs == 1613959
select h.nhi, min(h.eventStart) firstEvent
from sc.HospitalisationsPlus h
INNER JOIN lookups.ACHIProcedure p ON p.code = h.opCode
where opcode is not null and opcode != 0  -- has operation --6,969,498
and eventStart >= '2006-01-01' --1613409
--and  DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 >= 18 --16 and over --6154973
--AND 
and opAgeYearsFractional >= 18
AND p.IsOperation = 1
And p.IsCardiac = 0
--and (ASA = 9 OR ASA is null) --unknown ASA or no ASA --4232542
group by h.nhi
)
, multipleFirstEvents as ( --36539 vs 9307 vs 3366 /*patients with multiple events*/ non cardiacts 3236 records
select h.nhi, count(*) num
FROM [MoH].[sc].[HospitalisationsPlus] h
INNER JOIN lookups.ACHIProcedure p ON p.code = h.opCode
inner join firstEvent fe on fe.nhi = h.nhi and fe.firstEvent = h.eventStart 
where opcode is not null and opcode != 0
and eventStart >= '2006-01-01' --1613409
and opAgeYearsFractional >= 18
AND p.IsOperation = 1
And p.IsCardiac = 0
group by h.nhi
having count(*) > 1
)
, demulti as ( --3236
--, recoveredwithmortality as (
	select * from ( -- get the 1st one ordered by ASA (nulls last)) 3366 rows
	--alternatively, we can try to recover 183 rows from those that have multipleFirstEvents, discard the rest
		select  h.*
		,row_number() over (partition by h.nhi order by h.asa desc) ranknum
		FROM [MoH].[sc].[HospitalisationsPlus] h
		INNER JOIN lookups.ACHIProcedure p ON p.code = h.opCode
		inner join firstEvent fe on fe.nhi = h.nhi and fe.firstEvent = h.eventStart 
		where opcode is not null and opcode != 0
		and eventStart >= '2006-01-01' --1613409
		and opAgeYearsFractional >= 18
		AND p.IsOperation = 1
		And p.IsCardiac = 0
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
	and eventStart >= '2006-01-01' --1613409
	and opAgeYearsFractional >= 18
	and p.IsOperation = 1
	And p.IsCardiac = 0
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
, case when datediff(DAY, eventEnd,  dateOfDeath) <= 730 then 1 else 0 end LongTermMortality2year
, CAST(CHECKSUM(NEWID()) & 0x7fffffff AS float) / CAST (0x7fffffff AS int) randomnumber
--into mohprep..firstadmissions18plusfrom2006NonMortalityV2 --1604086
--into mohprep..firstadmissions18plusfrom2006MortalityV2 --9868 --9874
into mohprep..firstadmissions18plusfrom2006CombinedV3 --1613959
from combined
--where DiedDuringThisEvent not in (0,1)
--where DiedDuringThisEvent = 1

--drop table mohprep..firstadmissions18plusfrom2006NonMortalityV2 
--drop table mohprep..firstadmissions18plusfrom2006MortalityV2 

select  *
into mohprep..firstadmissions18plusfrom2006MortalityV2
FROM [MoHPrep].[dbo].[firstadmissions18plusfrom2006CombinedV2]
where diedduringthisevent = 1
--9874

select  *
into mohprep..firstadmissions18plusfrom2006NonMortalityV2
FROM [MoHPrep].[dbo].[firstadmissions18plusfrom2006CombinedV2]
where diedduringthisevent = 0
--1604085


--select 1604086+9868 = 1613954
/*
  select count(distinct nhi) 
  FROM [MoHPrep].[dbo].[firstadmissions18plusfrom2006NonMortalityV2]

	  select count(distinct nhi)
  FROM [MoHPrep].[dbo].[firstadmissions18plusfrom2006MortalityV2]

    	  select count(distinct nhi)
  FROM [MoHPrep].[dbo].[firstadmissions18plusfrom2006CombinedV2]


select * 
FROM [MoHPrep].[dbo].[firstadmissions18plusfrom2006CombinedV2]
where nhi in ( 
	select nhi
	FROM [MoHPrep].[dbo].[firstadmissions18plusfrom2006CombinedV2]
	except 
	select nhi
	FROM [MoHPrep].[dbo].[firstadmissions18plusfrom2006NonMortalityV2] --9873
	except 
	select nhi
	FROM [MoHPrep].[dbo].[firstadmissions18plusfrom2006MortalityV2] --11
)
*/

--Want a smaller subset
select * 
into mohprep..firstadmission18plusfrom2006SubsetV2
from (
select * from mohprep..firstadmissions18plusfrom2006NonMortalityV2 h
where randomnumber <  30000.0/1613959.0 --25000/1649161.0
union 
select * from mohprep..firstadmissions18plusfrom2006MortalityV2  h --9874
) a 

--39407
--==============================================

SELECT 

--[nhi]
--      ,[DOB]
  [gender] as gender
      ,[ethnicGroup]
--      ,[domicileCode]
      ,f.[DHB]
      ,[eventType]
      ,[endType]
   --   ,[facility]
      --,[opCode]
      --,[opBlkNum]
      ,[opChapNum]
  --    ,[op02Code]
      --,[op02BlkNum]
      ,[op02ChapNum]
      --,[op03Code]
      --,[op03BlkNum]
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
      ,[opAgeYears]
      ,[opAgeYearsFractional]
      --,[opYear]
      --,[opMonth]
      --,[opWeek]
      --,[opDayOfWeek]
      --,[DaysTillOp]
      --,[DaysTillDischarge] LOS
      --,[eventDuration] 
	  , [DaysTillDischarge] LOS
      --,[EventYear]
      --,[eventMonth]
      --,[EventDayOfWeek]
      --,[eventStart]
      --,[eventEnd]
      ,[AdmissionType]
      ,[ASA]
      ,[isEmergency]
      ,[IsCancer]
      ,[IsSmoker]
      ,[WasSmoker]
      ,[HasDiabetesT1]
      ,[HasDiabetesT2]
      ,[IsNeuroTrauma]
--      ,[id]
      --,[dateOfDeath]
      --,[deathCode]
      --,[causeOfDeath]
      --,[AgeAtDeathFractional]
--      ,[DiedDuringThisEvent]
     -- ,[DaysTillDeath]
      ,[Drugs1m]
      ,[Drugs6m]
--      ,[Drugs9m]
      ,[Drugs12m]
      --,[Drugs18m]
      --,[Drugs24m]
      --,[Drugs36m]
      --,[Drugs60m]
      --,[DrugsTotal]
      ,[Labs1m]
      ,[Labs6m]
--      ,[Labs9m]
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
--      ,[IPVisits9m]
      ,[IPVisits12m]
      --,[IPVisits18m]
      --,[IPVisits24m]
      --,[IPVisits36m]
      --,[IPVisits60m]
      --,[IPVisitsTotal]
      --,[ranknumber]
      ,[ageAtAdmission]
      ,[InHospitalMortality]
      ,[ShortTermMortality1d]
      ,[ShortTermMortality3d]
      ,[LongTermMortality30d]
      ,[LongTermMortality1year]
	  , LongTermMortality2year
  --    ,[randomnumber]
  --into firstadmission18plusfrom2006SubsetDistilled
  , Dep_score
  into mohprep..firstadmission18plusfrom2006SubsetDistilledV2
  FROM [MoHPrep].[dbo].firstadmission18plusfrom2006SubsetV2 f
  left outer join Moh.lookups.NZDep dep on f.[domicileCode] = dep.Dom


  --drop table mohprep..firstadmission18plusfrom2006SubsetDistilledV2