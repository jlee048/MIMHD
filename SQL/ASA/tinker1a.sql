select count(*)
FROM [MoH].[sc].[HospitalisationsPlus] h
--12,847,939
WHERE opcode is not null and opcode != 0 
--6,969,498
and (ASA = 9 OR ASA is null)
--4,646,618
and  DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 >= 16
--4,232,542

select top 100 * 
FROM [MoH].[sc].[HospitalisationsPlus] h
--where h.OpAgeYearsFractional is null
where h.eventStart is null
--none
select top 100 * 
FROM [MoH].[sc].[HospitalisationsPlus] h
--where h.OpAgeYearsFractional is null
where h.DOB is null
--none

		, ROUND(IIF(ISDATE(h.opdate01) = 1,  DATEDIFF(DAY, h.DOB, h.opdate01), NULL) / 365.25, 2) AS OpAgeYearsFractional  /* 365.25 is used because it is more accurate than 365.2422 with older patients */


;
with firstEvent as (
select h.nhi, min(h.eventStart) firstEvent
from sc.HospitalisationsPlus h
WHERE opcode is not null and opcode != 0  -- has operation --6,969,498
and  DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 >= 16 --16 and over --6154973
--and (ASA = 9 OR ASA is null) --unknown ASA or no ASA --4232542
group by h.nhi
)
select h.*, DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 ageAdmission
into mohprep..firstOpEventAge16andOver
from sc.HospitalisationsPlus h
inner join firstEvent fe on fe.nhi = h.nhi and fe.firstEvent = h.eventStart
(2216604 row(s) affected)
--where (ASA = 9 OR ASA is null) 

--2216604 age 16 and over with operations
--1432377 missing ASA
--unknown ASA or no ASA --4232542

;
with firstEvent as (
select h.nhi, min(h.eventStart) firstEvent
from sc.HospitalisationsPlus h
WHERE opcode is not null and opcode != 0  -- has operation --6,969,498
and  DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 >= 16 --16 and over --6154973
--and (ASA = 9 OR ASA is null) --unknown ASA or no ASA --4232542
group by h.nhi
)
select h.*, DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 ageAdmission
into mohprep..firstOpEventAge16andOverWithoutASA
from sc.HospitalisationsPlus h
inner join firstEvent fe on fe.nhi = h.nhi and fe.firstEvent = h.eventStart
where (ASA = 9 OR ASA is null) 
(1432377 row(s) affected)

;
with firstEvent as (
select h.nhi, min(h.eventStart) firstEvent
from sc.HospitalisationsPlus h
WHERE opcode is not null and opcode != 0  -- has operation --6,969,498
and  DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 >= 16 --16 and over --6154973
--and (ASA = 9 OR ASA is null) --unknown ASA or no ASA --4232542
group by h.nhi
)
select h.*, DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 ageAdmission
into mohprep..firstOpEventAge16andOverWithASA
from sc.HospitalisationsPlus h
inner join firstEvent fe on fe.nhi = h.nhi and fe.firstEvent = h.eventStart
where (ASA <> 9 AND ASA is NOT null) 
(784227 row(s) affected)


select ASA, count(*) count
from  mohprep..firstOpEventAge16andOverWithoutASA
group by ASA
ASA	count
NULL	887964
9	544413

select ASA, count(*) count
from  mohprep..firstOpEventAge16andOverWithASA
group by ASA

ASA	count
1	358246
2	332880
3	81506
4	10872
5	655
6	68

will need SMOTE?

-- is 9 the same as null or do they have different meaning?

select count(*) count
from  mohprep..firstOpEventAge16andOver f
where f.DiedDuringThisEvent is null
1926261

select DiedDuringThisEvent, count(*) count
from  mohprep..firstOpEventAge16andOver f
group by DiedDuringThisEvent
DiedDuringThisEvent
DiedDuringThisEvent	count
NULL	1926261
0	274167
1	16176

select 274167+1926261
select 16176.0/(274167+1926261)
	select count(*)
	from  mohprep..firstOpEventAge16andOver f
	where dateOfDeath<= EventEnd