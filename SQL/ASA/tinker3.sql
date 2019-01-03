;
with firstEvent as (
select h.nhi, min(h.eventStart) firstEvent
from sc.HospitalisationsPlus h
WHERE opcode is not null and opcode != 0  -- has operation --6,969,498
and  DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 >= 16 --16 and over --6154973
--and (ASA = 9 OR ASA is null) --unknown ASA or no ASA --4232542
group by h.nhi
)
select
h.*
, DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 ageAdmission
--into mohprep..firstOpEventAge16andOver
from sc.HospitalisationsPlus h
inner join firstEvent fe on fe.nhi = h.nhi and fe.firstEvent = h.eventStart
--where (ASA <> 9 AND ASA is NOT null) 
where eventStart >= '2008-01-01' --840922
and DiedDuringThisEvent = 1 --4544 (2012), 10617 (2008)
and (ASA <> 9 AND ASA is NOT null)  --1572


;
with firstEvent as (
select h.nhi, min(h.eventStart) firstEvent
from sc.HospitalisationsPlus h
WHERE opcode is not null and opcode != 0  -- has operation --6,969,498
and  DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 >= 16 --16 and over --6154973
--and (ASA = 9 OR ASA is null) --unknown ASA or no ASA --4232542
group by h.nhi
)
select
h.*
, DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 ageAdmission
--into mohprep..firstOpEventAge16andOver
from sc.HospitalisationsPlus h
inner join firstEvent fe on fe.nhi = h.nhi and fe.firstEvent = h.eventStart
--where (ASA <> 9 AND ASA is NOT null) 
where eventStart >= '2008-01-01' --840922
and DiedDuringThisEvent = 1 --4544 (2012), 10617 (2008)
and (ASA = 9 or ASA is null)  --8495


;
with firstEvent as (
select h.nhi, min(h.eventStart) firstEvent
from sc.HospitalisationsPlus h
WHERE opcode is not null and opcode != 0  -- has operation --6,969,498
and  DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 >= 16 --16 and over --6154973
--and (ASA = 9 OR ASA is null) --unknown ASA or no ASA --4232542
group by h.nhi
)
select
h.*
, DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 ageAdmission
--into mohprep..firstOpEventAge16andOver
from sc.HospitalisationsPlus h
inner join firstEvent fe on fe.nhi = h.nhi and fe.firstEvent = h.eventStart
--where (ASA <> 9 AND ASA is NOT null) 
where 
--eventStart >= '2008-01-01' --840922
DiedDuringThisEvent = 1 --4544 (2012), 10617 (2008), 16176 (mortality doesnt go back that far) --(1982)
--and (ASA = 9 or ASA is null)  --8495

select datepart(year, eventstart), count(*)
from sc.HospitalisationsPlus h
where h.DiedDuringThisEvent = 1
group by datepart(year, eventstart)

(No column name)	(No column name)
1982	1
1985	1
1988	2
1989	1
1990	1
1991	1
1992	6
1993	4
1994	3
1995	17
1996	14
1997	22
1998	41
1999	71
2000	110
2001	173
2002	305
2003	524
2004	844
2005	1850
2006	14458
2007	14215
2008	15289
2009	15013
2010	14927
2011	15704
2012	15328
2013	14194
2014	14017
2015	13908
2016	12072
2017	11005




;
with firstEvent as (
select h.nhi, min(h.eventStart) firstEvent
from sc.HospitalisationsPlus h
WHERE opcode is not null and opcode != 0  -- has operation --6,969,498
and  DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 >= 16 --16 and over --6154973
--and (ASA = 9 OR ASA is null) --unknown ASA or no ASA --4232542
group by h.nhi
)
select
h.*
, DATEDIFF(DAY, h.DOB, h.eventStart) / 365.25 ageAdmission
--into mohprep..firstOpEventAge16andOver
from sc.HospitalisationsPlus h
inner join firstEvent fe on fe.nhi = h.nhi and fe.firstEvent = h.eventStart
--where (ASA <> 9 AND ASA is NOT null) 
where eventStart >= '2006-01-01' --840922
and DiedDuringThisEvent = 1 --4544 (2012), 10617 (2008), 16176 (mortality doesnt go back that far) --(1982) --16059 from 2006 onwards
--and (ASA = 9 or ASA is null)  --8495
