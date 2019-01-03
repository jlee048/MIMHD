--drop database mimicplay
--go

use mimicplay
go

/*
This script is used for creating a list of admission ids. 
We only keep admissions that are the first admissions of their patients.
We collect all admission_ids from TABLE ICUSTAYS and TABLE TRANSFERS"

Remove non-first admissions

We remove all admissions which are not the first admissions of some patients in order to prevent possible information leakage, which will happen when multiple admissions of the same patient occur in training set and test set simultaneously.

*/

if exists (select * from sysobjects where name='admission_ids' and xtype='U')
    drop table admission_ids
	go

select hadm_id into admission_ids from (
	select hadm_id from mimiciii..icustays 
	union 
	select hadm_id from mimiciii..transfers
) a
--58976
select count(*) from admission_ids
--58976

--tosave = {'admission_ids':admission_ids, 'admission_ids_txt': admission_ids_txt}
--np.save('res/admission_ids.npy',tosave)

-- also get first admissions
--select hadm_id from admission_ids where hadm_id in (select distinct on (subject_id) hadm_id from (select * from admissions order by admittime) tt)')

if exists (select * from sysobjects where name='admission_first_ids' and xtype='U')
    drop table admission_first_ids
	go

SELECT part.hadm_id into admission_first_ids
FROM (  SELECT *, ROW_NUMBER() OVER(PARTITION BY subject_id ORDER BY admittime) Corr
    FROM mimiciii..admissions) part
WHERE part.Corr = 1
--46520


/*
Get Itemid List

This script is used for collecting all itemids in the database. Itemids are ids of features.

In this task we only collect itemids from the following tables:
•inputevents
•outputevents
•chartevents
•labevents
•microbiologyevents
•prescriptions

Itemids from inputevents

Data from Carevue and Metavision is separately stored in TABLE INPUTEVENTS_CV and TABLE INPUTEVENTS_MV. Inputevents from Metavision have itemids >= 200000, and those from Carevue have itemids in [30000, 49999].

We only need to collect all distinct itemids in TABLE OUTPUTEVENTS.

We only need to collect all distinct itemids in TABLE CHARTEVENTS.

We only need to collect all distinct itemids in TABLE LABEVENTS.

Itemids from microbiologyevents

We need to collect 4 kinds of itemids:
•spec_itemid
•org_itemid
•ab_itemid
•tuple of all above

We only need to collect all distinct itemids in TABLE PRESCRIPTIONS.

Histograms of itemids
RANKING occurrence
For each table we draw the histogram showing the number of admissions which have any record of each itemid.
t - Number of Admission That Use Itemid: chartevent
y - number of admissions using this feature
x- -the rank of feature, ordered by number of admissions using this feature desc
*/

--select  count(*) from mimiciii..inputevents_cv
----17527935
--select count(*) from mimiciii..inputevents_cv where itemid >= 30000 and itemid <= 49999
----17527935

--select distinct itemid from mimiciii..inputevents_cv where itemid >= 30000 and itemid <= 49999
----2938
if exists (select * from sysobjects where name='inputitemids' and xtype='U')
    drop table inputitemids
	go
;
with inputitemids as (
    select distinct itemid from mimiciii..inputevents_mv where itemid >= 200000
    union
    select distinct itemid from mimiciii..inputevents_cv where itemid >= 30000 and itemid <= 49999
)
select distinct itemid into inputitemids from inputitemids
--3126 input_itemid_txt



if exists (select * from sysobjects where name='outputeventids' and xtype='U')
    drop table outputeventids
	go

--select distinct itemid from mimiciii..outputevents where itemid >= 30000 and itemid <= 49999
--1087
select distinct itemid into outputeventids from mimiciii..outputevents
--1155 output_itemid_txt



if exists (select * from sysobjects where name='charteventids' and xtype='U')
    drop table charteventids
	go
--select distinct itemid from mimiciii..chartevents where itemid <= 49999
--4985
select distinct itemid into charteventids from mimiciii..chartevents
--6463 chart_itemid_txt


if exists (select * from sysobjects where name='labeventids' and xtype='U')
    drop table labeventids
	go

select distinct itemid into labeventids from mimiciii..labevents
--726 lab_itemid_txt




--select distinct (spec_itemid,org_itemid,ab_itemid),spec_itemid,org_itemid,ab_itemid 
--from microbiologyevents
/* --looks for commas 
 "for r in res:\n",
    "    ele = r[0][1:-1].split(',')\n",
    "    for t in range(len(ele)):\n",
    "        try:\n",
    "            ele[t] = int(ele[t])\n",
    "        except:\n",
    "            ele[t] = None\n",
    "    microbio_itemid.append(tuple(ele))\n",
*/
--int or none
--select distinct spec_itemid,org_itemid,ab_itemid 
--from microbiologyevents
----9154  microbio_itemid

--select distinct spec_itemid,org_itemid,ab_itemid
--, concat(coalesce(spec_itemid,''),coalesce(org_itemid,''),coalesce(ab_itemid,'')) microbito_itemid
--from microbiologyevents


--select distinct concat(coalesce(spec_itemid,''),coalesce(org_itemid,''),coalesce(ab_itemid,'')) microbio_itemid, spec_itemid,org_itemid,ab_itemid from microbiologyevents


if exists (select * from sysobjects where name='microbiologyeventids' and xtype='U')
    drop table microbiologyeventids
	go

select distinct concat(coalesce(spec_itemid,''),coalesce(org_itemid,''),coalesce(ab_itemid,'')) microbio_itemid
, spec_itemid,org_itemid,ab_itemid 
into microbiologyeventids
from mimiciii..microbiologyevents


if exists (select * from sysobjects where name='prescriptionids' and xtype='U')
    drop table prescriptionids
	go

select distinct formulary_drug_cd into prescriptionids from mimiciii..prescriptions
--3265 vs 3268

--select count(formulary_drug_cd) from prescriptions
--4154517

/*

database = {'input':input_itemid,
            'output':output_itemid,
            'chart':chart_itemid,
            'lab':lab_itemid,
            'microbio':microbio_itemid,
            'prescript':prescript_itemid}
np.save('res/itemids.npy',database);
print('saved!')
*/



--getNumberOfAdmissionThatUseStatIdBio
--select count(distinct hadm_id) from mimiciii..microbiologyevents 
--where hadm_id in (select * from admission_ids)
------...
getNumberOfAdmissionThatUseStatId(sql, itemids['lab'], admission_ids_txt,
                                  'res/labevent_numberOfAdmissionThatUseItemid.npy')

--select SPEC_ITEMID, ORG_ITEMID, AB_ITEMID, count(distinct hadm_id) from mimiciii..microbiologyevents 
--group by SPEC_ITEMID, ORG_ITEMID, AB_ITEMID

alter table microbiologyeventids add countdistincthadm_id int
go

update t1 set t1.countdistincthadm_id = t2.uc
from 
microbiologyeventids t1 
inner join (
select SPEC_ITEMID, ORG_ITEMID, AB_ITEMID, count(distinct hadm_id) uc 
from mimiciii..microbiologyevents  
group by SPEC_ITEMID, ORG_ITEMID, AB_ITEMID
) t2 --on mb.spec_itemid = mb2.spec_itemid and mb.org_itemid = mb2.org_itemid and mb.ab_itemid = mb2.ab_itemid
on coalesce(t1.spec_itemid,-1) = coalesce(t2.spec_itemid,-1)
and coalesce(t1.org_itemid,-1) = coalesce(t2.org_itemid,-1)
and coalesce(t1.ab_itemid,-1) = coalesce(t2.ab_itemid,-1)



select top 1000 * from  microbiologyeventids order by countdistincthadm_id desc

--getNumberOfAdmissionThatUseStatId

---------------------------------
alter table labeventids add countdistincthadm_id int
go

select ITEMID, count(distinct hadm_id) uc 
from mimiciii..labevents  
group by ITEMID
order by 2 desc

update t1 set t1.countdistincthadm_id = t2.uc
from 
labeventids t1 
inner join (
select ITEMID, count(distinct hadm_id) uc 
from mimiciii..labevents  
group by ITEMID
) t2 on coalesce(t1.ITEMID,-1) = coalesce(t2.ITEMID,-1)

select top 1000 * from  labeventids order by countdistincthadm_id desc

------------------------------
alter table prescriptionids add countdistincthadm_id int
go

update t1 set t1.countdistincthadm_id = t2.uc
from 
prescriptionids t1 
inner join (
select formulary_drug_cd, count(distinct hadm_id) uc 
from mimiciii..prescriptions  
group by formulary_drug_cd
) t2 on coalesce(t1.formulary_drug_cd,'-1') = coalesce(t2.formulary_drug_cd,'-1')

select top 1000 * from  prescriptionids order by countdistincthadm_id desc
---------------------------------------
alter table outputeventids add countdistincthadm_id int
go

update t1 set t1.countdistincthadm_id = t2.uc
from 
outputeventids t1 
inner join (
select ITEMID, count(distinct hadm_id) uc 
from mimiciii..OUTPUTEVENTS  
group by ITEMID
) t2 on coalesce(t1.ITEMID,-1) = coalesce(t2.ITEMID,-1)

select top 1000 * from  outputeventids order by countdistincthadm_id desc

---------------------------------------------------------------
alter table charteventids add countdistincthadm_id int
go

update t1 set t1.countdistincthadm_id = t2.uc
from 
charteventids t1 
inner join (
select ITEMID, count(distinct hadm_id) uc 
from mimiciii..CHARTEVENTS  
group by ITEMID
) t2 on coalesce(t1.ITEMID,-1) = coalesce(t2.ITEMID,-1)

select top 1000 * from  charteventids order by countdistincthadm_id desc



--------------------------------------

alter table inputitemids add countdistincthadm_id int, countdistincthadm_idmv int, countdistincthadm_idcv int
go

update t1 set t1.countdistincthadm_idcv = t2.uc
from 
inputitemids t1 
inner join (
select ITEMID, count(distinct hadm_id) uc 
from mimiciii..inputevents_cv  
group by ITEMID
) t2 on coalesce(t1.ITEMID,-1) = coalesce(t2.ITEMID,-1)

update t1 set t1.countdistincthadm_idmv = t2.uc
from 
inputitemids t1 
inner join (
select ITEMID, count(distinct hadm_id) uc 
from mimiciii..inputevents_mv  
group by ITEMID
) t2 on coalesce(t1.ITEMID,-1) = coalesce(t2.ITEMID,-1)

update inputitemids set countdistincthadm_id = isnull(countdistincthadm_idcv,0) + isnull(countdistincthadm_idmv,0)

select top 1000 * from  inputitemids order by countdistincthadm_id desc
-------------------------------------------------
--------------------------------------------------
/*

First part compiles list of distinct admissionids from icustays and transfers
We also compile list of first admissions
In addition, types(itemids) for all relevant events are collected and a count of distinct admission events against each type is computed

*/
#2

/*
Filter Itemid Input¶

This script is used for filtering itemids from TABLE INPUTEVENTS.
1.We check number of units of each itemid and choose the major unit as the target of unit conversion.
2.In this step we do not apply any filtering to the data.

Output
1.itemid of observations for inputevents.
2.unit of measurement for each itemid.


iterate thru each itemID

For each item id, we count number of observations for each unit of measurement.

For example, IN 225883 : 98.24 : 3 : [('dose', 16477L), ('mg', 251L), ('grams', 44L)] This means that for itemid 225883, there are:
1.16477 records using dose as its unit of measurement.
2.251 records using mg as its unit of measurement.
3.44 records using grams as its unit of measurement.

dose has 98.24% over all the observations for this itemid, we can say that dose is a majority unit. 
1.We will keep this itemid because 98% is high. we can relatively safe to discard the observations that has different unit of measurement. i.e. if we discard mg and grams, we lose 251+44 records which is little, compared to 16477 records we can keep.
2.We will record main unit of measurement for this itemID as dose.

IN 225845	69.42	3 : [('dose', 1024), ('mg', 450), ('grams', 1)]
IN 30046	72.65	2 : [('ml', 85), ('mg', 32)]

np.save('res/filtered_input.npy',{'id':valid_input,'unit':valid_input_unit})
print('saved!')
*/

select coalesce(amountuom, ''), count(*) 
from mimiciii..inputevents_cv 
where itemid=30044 and hadm_id in (select * from admission_ids) 
group by amountuom



--select coalesce(amountuom, ''), count(*) 
--from mimiciii..inputevents_cv 
--where itemid=30044 and hadm_id in ({0}) 
--group by amountuom'.format(admission_ids_txt))

select amountuom, sum(c) from (
		select coalesce(amountuom, '') as amountuom
		, count(*) c 
		from mimiciii..inputevents_cv 
		where itemid in (select itemid from inputitemids)
		and hadm_id in (select HADM_ID from admission_ids) 
		group by amountuom
		union all
		select coalesce(amountuom, '') as amountuom
		, count(*) c from mimiciii..inputevents_mv 
		where itemid in (select itemid from inputitemids) 
		and hadm_id in (select HADM_ID from admission_ids) 
		group by amountuom
    ) as t 
	where amountuom<>'' 
	group by amountuom
	--'.format(itemid))
	
	--

select itemid, amountuom
,c2
, sum(c2) over (partition by itemid) total
, c2*1.0/sum(c2) over (partition by itemid) perc
, row_number() over (partition by itemid order by c2 desc) ranking
, count(*)  over (partition by itemid) countuom
into filtered_input_raw
from (
select itemid, amountuom, sum(c) c2 
from (
		select itemid, coalesce(amountuom, '') as amountuom, count(*) c 
		from mimiciii..inputevents_cv 
		where itemid in (select itemid from inputitemids)
			and hadm_id in (select HADM_ID from admission_ids) 
		group by itemid, amountuom
		union all
		select itemid, coalesce(amountuom, '') as amountuom, count(*) c from mimiciii..inputevents_mv 
		where itemid in (select itemid from inputitemids) 
			and hadm_id in (select HADM_ID from admission_ids) 
		group by itemid, amountuom
    ) as t 
	where amountuom<>'' 
	group by itemid, amountuom
) a
	order by itemid, perc desc 
	--'.format(itemid))

itemid	amountuom	c2	total	perc	ranking	countuom
30001	ml	50630	50630	1.000000000000	1	1
30002	ml	72	72	1.000000000000	1	1
30003	mg	210	210	1.000000000000	1	1
30004	ml	107	107	1.000000000000	1	1
30005	ml	18997	18997	1.000000000000	1	1
30006	ml	6931	6931	1.000000000000	1	1
30007	ml	958	958	1.000000000000	1	1
30008	ml	3153	3153	1.000000000000	1	1
30009	ml	5890	5890	1.000000000000	1	1
30011	ml	735	735	1.000000000000	1	1
30012	ml	1446	1446	1.000000000000	1	1
30013	ml	2513620	2513620	1.000000000000	1	1
30014	ml	961	961	1.000000000000	1	1
30015	ml	195925	195925	1.000000000000	1	1
30016	ml	10463	10463	1.000000000000	1	1
30017	ml	495	495	1.000000000000	1	1
30018	ml	2363669	2363669	1.000000000000	1	1
30020	ml	70184	70184	1.000000000000	1	1
30021	ml	208763	208763	1.000000000000	1	1
30022	mg	647	720	0.898611111111	1	2
30022	ml	73	720	0.101388888888	2	2
30023	mg	46284	48760	0.949220672682	1	4
30023	gm	1669	48760	0.034228876127	2	4
30023	cc	404	48760	0.008285479901	3	4
30023	ml	403	48760	0.008264971287	4	4


--np.save('res/filtered_input.npy',{'id':valid_input,'unit':valid_input_unit})
--print('saved!')
-- take the majority unit
select * 
into filtered_input
from (
select itemid, amountuom
,c2
, sum(c2) over (partition by itemid) total
, c2*1.0/sum(c2) over (partition by itemid) perc
, row_number() over (partition by itemid order by c2 desc) ranking
, count(*)  over (partition by itemid) countuom

from (
select itemid, amountuom, sum(c) c2 
from (
		select itemid, coalesce(amountuom, '') as amountuom, count(*) c 
		from mimiciii..inputevents_cv 
		where itemid in (select itemid from inputitemids)
			and hadm_id in (select HADM_ID from admission_ids) 
		group by itemid, amountuom
		union all
		select itemid, coalesce(amountuom, '') as amountuom, count(*) c from mimiciii..inputevents_mv 
		where itemid in (select itemid from inputitemids) 
			and hadm_id in (select HADM_ID from admission_ids) 
		group by itemid, amountuom
    ) as t 
	where amountuom<>'' 
	group by itemid, amountuom
) a
) b
where b.ranking = 1
	order by itemid, perc desc 
--3210

# ## iterate thru each itemID
# For each item id, we count number of observations for each unit of measurement.
# 
# For example,
# IN 225883 : 98.24 : 3 : [('dose', 16477L), ('mg', 251L), ('grams', 44L)]
# This means that for itemid 225883, there are:
# 1. 16477 records using dose as its unit of measurement.
# 2. 251 records using mg as its unit of measurement.
# 3. 44 records using grams as its unit of measurement.
# 
# dose has 98.24% over all the observations for this itemid, we can say that dose is a majority unit. 
# 1. We will keep this itemid because 98% is high. we can relatively safe to discard the observations that has different unit of measurement. i.e. if we discard mg and grams, we lose 251+44 records which is little, compared to 16477 records we can keep.
# 2. We will record main unit of measurement for this itemID as dose.


sql = 'select hadm_id, amountuom, count(amountuom) from mimiciii.inputevents_cv where itemid={0} group by hadm_id, amountuom union all select hadm_id, amountuom, count(amountuom) from mimiciii.inputevents_mv where itemid={0} group by hadm_id, amountuom order by hadm_id'


-- number of event for each hadm for each uom

select itemid, hadm_id
, amountuom
, count(amountuom) 
from mimiciii..inputevents_cv 
group by itemid, hadm_id, amountuom
union all 
select itemid, hadm_id, amountuom, count(amountuom) 
from mimiciii..inputevents_mv 
group by itemid, hadm_id, amountuom 
order by itemid, hadm_id


--------------------------3
/*
Filter Itemid Output

This script is used for filtering itemids from TABLE OUTPUTEVENTS.
1.We check number of units of each itemid and choose the major unit as the target of unit conversion. In fact, for outputevents the units are the same - 'mL'.
2.In this step we do not apply any filtering to the data.

Output
1.itemid of observations for outputevents.
2.unit of measurement for each itemid. Here we use None since no conversion is needed
np.save('res/filtered_output.npy',{'id':valid_output,'unit':None})


*/

select distinct valueuom 
from mimiciii..outputevents
--[(None,), ('ml',), ('mL',)]
--All records have the same unit. Therefore just keep all itemids.
--np.save('res/filtered_output.npy',{'id':valid_output,'unit':None})

valueuom
NULL
ml

select * 
into filtered_output
from outputeventids
---------------------\
--4

--# for each itemID select number of rows group by unit of measurement.
/*
Filter Itemid Chart

This script is used for filtering itemids from TABLE CHARTEVENTS.
1.We check number of units of each itemid and choose the major unit as the target of unit conversion.
2.In this step we get 3 kinds of features:
•numerical features
•categorical features
•ratio features, this usually happens in blood pressure measurement, such as "135/70".


Output
1.itemid of observations for chartevents.
2.unit of measurement for each itemid.

First filtering of categorical features

All features with numerical values < 80% of all records are possible categorical features. In this step we drop them for later analyzing.

Unit inconsistency

Here are itemids having two or more different units.

For [211, 505], they have the same unit in fact. Keep them.

For [3451, 578, 113], the major unit covers > 90% of all records. Keep them.

For [3723], it is just a typo and we keep all.

*/

--# for each itemID select number of rows group by unit of measurement.
USE [MIMICIII]
GO
CREATE NONCLUSTERED INDEX [IX_CHARTEVENTS_HADM_ID_inc_ItemId_ValueUOM]
ON [dbo].[CHARTEVENTS] ([HADM_ID])
INCLUDE ([ITEMID],[VALUEUOM])
GO
Use MimicPlay
Go
CREATE NONCLUSTERED INDEX [IX_admission_ids_HADM_ID]
ON [dbo].admission_ids ([HADM_ID])
go


SELECT itemid, coalesce(valueuom, ''), count(*) 
FROM mimiciii..chartevents 
WHERE  hadm_id in (select * from admission_ids) 
group by itemid, valueuom

SELECT itemid, coalesce(valueuom, ''), count(*) 
FROM mimiciii..chartevents c
inner join  admission_ids a on c.hadm_id = a.HADM_ID
group by itemid, valueuom

--# count number of observation that has non numeric value
SELECT itemid, count(*) 
FROM mimiciii..chartevents 
WHERE hadm_id in (select * from admission_ids) 
and valuenum is null
group by itemid

--# total number of observation
SELECT itemid, count(*) 
FROM mimiciii..chartevents 
WHERE hadm_id in (select * from admission_ids)
group by itemid

--return (itemid, chartunits, notnum, total)

--All features with numerical values < 80% of all records are possible categorical features. In this step we drop them for later analyzing.
  --# calculate percentage of the top frequent unit compared to all observation

select a.*, coalesce(b.nonnumitems,0) nonnumitems,  (a.totalobsforitemid - coalesce(b.nonnumitems,0)) * 1.0 / a.totalobsforitemid percentagenumeric
from (
SELECT itemid, coalesce(valueuom, '') valueuom, count(*) countforitemiduom
, sum(count(*)) over (partition by itemid) totalobsforitemid
,  count(*) * 1.0 / sum(count(*)) over (partition by itemid) percentage
, row_number() over (partition by itemid order by count(*) desc) ranknumber
FROM mimiciii..chartevents c
inner join  admission_ids a on c.hadm_id = a.HADM_ID
group by itemid, valueuom
) a
left outer join 
(
SELECT itemid, count(*) nonnumitems
FROM mimiciii..chartevents 
WHERE hadm_id in (select * from admission_ids) 
and valuenum is null
group by itemid
) b on a.ITEMID = b.ITEMID
where a.ranknumber = 1 -- choose only main unit
order by 1

/*
CHART 226537	74.35	[('mg/dL', 52828), ('', 18229)]
Numeric observation :100.0000% ( NOTNUM= 0 / ALL= 71057 ) 


  # if the percentage of numeric number is less, then dropped it, and make it categorical feature.
  Unit inconsistency

## Unit inconsistency

Here are itemids having two or more different units.
For [211, 505], they have the same unit in fact. Keep them.
For [3451, 578, 113], the major unit covers > 90% of all records. Keep them.
For [3723], it is just a typo and we keep all.

for i, chartunits, percentage in sorted(multiple_units, key=lambda x: x[2]):
    total2 = sum([t[1] for t in chartunits])
    percentage = float(chartunits[0][1]) / total2 * 100.
    print("CHART "+str(i) + "\t" + "{:.4f}".format(percentage) +'\t'+ str(chartunits))


CHART 3723	59.3440	[('cm', 258375), ('kg', 177010)]
CHART 211	67.2600	[('BPM', 3484614), ('bpm', 1696195)]
CHART 578	94.0624	[('.', 277532), ('cmH20', 12941), ('', 4578)]
CHART 3451	94.3170	[('kg', 179206), ('cm', 10793), ('', 5)]
CHART 113	97.4122	[('mmHg', 1167662), ('%', 23460), ('', 7559)]
CHART 227441	99.3007	[('mg/dL', 142), ('units', 1)]
CHART 505	99.4428	[('cmH20', 350365), ('', 1958), ('cmH2O', 5)]

*/

--filtered_chart_raw
select a.*, coalesce(b.nonnumitems,0) nonnumitems
, (a.totalobsforitemid - coalesce(b.nonnumitems,0)) * 1.0 / a.totalobsforitemid percentagenumeric
, count(valueuom) over (partition by a.itemid) distinctunits
into filtered_chart_raw
from (
	SELECT itemid, coalesce(valueuom, '') valueuom, count(*) countforitemiduom
	, sum(count(*)) over (partition by itemid) totalobsforitemid
	,  count(*) * 1.0 / sum(count(*)) over (partition by itemid) percentage
	, row_number() over (partition by itemid order by count(*) desc) ranknumber
	FROM mimiciii..chartevents c
	inner join  admission_ids a on c.hadm_id = a.HADM_ID
	group by itemid, valueuom
) a
left outer join 
(
SELECT itemid, count(*) nonnumitems
FROM mimiciii..chartevents 
WHERE hadm_id in (select * from admission_ids) 
and valuenum is null
group by itemid
) b on a.ITEMID = b.ITEMID
--where a.ranknumber = 1 -- choose only main unit
order by 1,6

6463

--All features with numerical values < 80% of all records are possible categorical features. In this step we drop them for later analyzing
drop table filterchartdropped

select a.*, coalesce(b.nonnumitems,0) nonnumitems
, (a.totalobsforitemid - coalesce(b.nonnumitems,0)) * 1.0 / a.totalobsforitemid percentagenumeric
, count(valueuom) over (partition by a.itemid) distinctunits
into filtered_chart_dropped
from (
SELECT itemid, coalesce(valueuom, '') valueuom, count(*) countforitemiduom
, sum(count(*)) over (partition by itemid) totalobsforitemid
,  count(*) * 1.0 / sum(count(*)) over (partition by itemid) percentage
, row_number() over (partition by itemid order by count(*) desc) ranknumber
FROM mimiciii..chartevents c
inner join  admission_ids a on c.hadm_id = a.HADM_ID
group by itemid, valueuom
) a
left outer join 
(
SELECT itemid, count(*) nonnumitems
FROM mimiciii..chartevents 
WHERE hadm_id in (select * from admission_ids) 
and valuenum is null
group by itemid
) b on a.ITEMID = b.ITEMID
--where a.ranknumber = 1 -- choose only main unit
where a.ranknumber = 1 and  ((a.totalobsforitemid - coalesce(b.nonnumitems,0)) * 1.0 / a.totalobsforitemid) < 0.8 --percentage numeric
order by 1,6


-- those with > 1 uoms
select * from (
select a.*, coalesce(b.nonnumitems,0) nonnumitems
, (a.totalobsforitemid - coalesce(b.nonnumitems,0)) * 1.0 / a.totalobsforitemid percentagenumeric
, count(valueuom) over (partition by a.itemid) distinctunits
from (
SELECT itemid, coalesce(valueuom, '') valueuom, count(*) countforitemiduom
, sum(count(*)) over (partition by itemid) totalobsforitemid
,  count(*) * 1.0 / sum(count(*)) over (partition by itemid) percentage
, row_number() over (partition by itemid order by count(*) desc) ranknumber

FROM mimiciii..chartevents c
inner join  admission_ids a on c.hadm_id = a.HADM_ID
group by itemid, valueuom
) a
left outer join 
(
SELECT itemid, count(*) nonnumitems
FROM mimiciii..chartevents 
WHERE hadm_id in (select * from admission_ids) 
and valuenum is null
group by itemid
) b on a.ITEMID = b.ITEMID
--where a.ranknumber = 1 -- choose only main unit
--order by 1,6
) c where distinctunits  > 1
order by 1

--676 rows or so

-- test for units inconsistencies
--ignoring blanks now 
select * from (
select a.*, coalesce(b.nonnumitems,0) nonnumitems
, (a.totalobsforitemid - coalesce(b.nonnumitems,0)) * 1.0 / a.totalobsforitemid percentagenumeric
, count(valueuom) over (partition by a.itemid) distinctunits
from (
SELECT itemid, coalesce(valueuom, '') valueuom, count(*) countforitemiduom
, sum(count(*)) over (partition by itemid) totalobsforitemid
,  count(*) * 1.0 / sum(count(*)) over (partition by itemid) percentage
, row_number() over (partition by itemid order by count(*) desc) ranknumber
FROM mimiciii..chartevents c
inner join  admission_ids a on c.hadm_id = a.HADM_ID
where c.VALUEUOM != ''
group by itemid, valueuom
) a
left outer join 
(
SELECT itemid, count(*) nonnumitems
FROM mimiciii..chartevents 
WHERE hadm_id in (select * from admission_ids) 
and valuenum is null
group by itemid
) b on a.ITEMID = b.ITEMID
--where a.ranknumber = 1 -- choose only main unit
--order by 1,6
) c where distinctunits  > 1
order by 1

/*
only 12
--upon inspection keep all
*/
itemid	valueuom	countforitemiduom	totalobsforitemid	percentage	ranknumber	nonnumitems	percentagenumeric	distinctunits
113	mmHg	1167662	1191122	0.980304284531	1	16245	0.986361598560	2
113	%	23460	1191122	0.019695715468	2	16245	0.986361598560	2
505	cmH20	350365	350370	0.999985729371	1	2136	0.993903587635	2
505	cmH2O	5	350370	0.000014270628	2	2136	0.993903587635	2
578	.	277532	290473	0.955448527057	1	5254	0.981912260347	2
578	cmH20	12941	290473	0.044551472942	2	5254	0.981912260347	2
3451	kg	179206	189999	0.943194437865	1	171	0.999099995263	2
3451	cm	10793	189999	0.056805562134	2	171	0.999099995263	2
3723	cm	258375	435385	0.593440288480	1	104	0.999761130953	2
3723	kg	177010	435385	0.406559711519	2	104	0.999761130953	2
227441	mg/dL	142	143	0.993006993006	1	0	1.000000000000	2
227441	units	1	143	0.006993006993	2	0	1.000000000000	2
---------------------------------------------

select * FROM mimiciii..chartevents c
where itemid in (113,505,578,3451,3723,227441)
order by itemid

select * from filtered_chart_dropped

--3819 --matches doco
--there should be 3819 dropped records


select * from filtered_chart_raw
/*
SELECT value, valueuom, count(*) as x FROM mimiciii.chartevents as lb \
                WHERE itemid = '+ str(d) +' and hadm_id in (select * from admission_ids) GROUP BY value, valueuom ORDER BY x DESC')
*/
----------------------
select top 1000 * from filtered_chart_dropped order by itemid, 2


select count(*)
FROM mimiciii..chartevents c
inner join  admission_ids a on c.hadm_id = a.HADM_ID
--330712483

select count(*)
FROM mimiciii..chartevents c
inner join admission_ids a on c.hadm_id = a.HADM_ID
inner join filtered_chart_dropped f on f.ITEMID = c.ITEMID
184 062 568

--select itemid, value, valueuom
--into charteventsfilteredadmissionids
--FROM mimiciii..chartevents c
--inner join  admission_ids a on c.hadm_id = a.HADM_ID

--SELECT itemid, value, valueuom
--, count(*) as x 
--FROM mimiciii..chartevents c
--inner join  admission_ids a on c.hadm_id = a.HADM_ID
--where c.ITEMID in (select itemid from filtered_chart_dropped)
--GROUP BY itemid, value, valueuom 
--ORDER BY x DESC

select c.itemid, value, c.valueuom,count(*) as x 
into chart_dropped_value_raw
FROM mimiciii..chartevents c
inner join admission_ids a on c.hadm_id = a.HADM_ID
inner join filtered_chart_dropped f on f.ITEMID = c.ITEMID
GROUP BY c.itemid, value, c.valueuom 
ORDER BY x DESC

10:57 @ 50870 rows

select * from chart_dropped_value_raw
select distinct itemid from chart_dropped_value_raw
--3819 match  match dropped_id

select * from filtered_chart
--2644 match valid+chart

alter table chart_dropped_value_raw add hasNumeric int
alter table chart_dropped_value_raw add isasc int

--update chart_dropped_value_raw set hasNumeric = case when value like '%[0-9]%' then 1 else 0 end


update chart_dropped_value_raw set hasNumeric = case when value like '%[0-9]/[0-9]%' then 1    when value like '%[0-9]/%' then 1    when value like '%/[0-9]%' then 1   else  isnumeric(value) end
--update chart_dropped_value_raw set isasc = case  when value like '%[0-9]%' then 0  when value like '%[0-9]/[0-9]%' then 0    when value like '%[0-9]/%' then 0    when value like '%/[0-9]%' then 0  when isnumeric(value)=1 then 0 else 1 end
update chart_dropped_value_raw set isasc = case  
--when value like '%[0-9]%' then 0  
when value like '[0-9]%' then 0 
when value like '%[0-9]/[0-9]%' then 0    
when value like '%[0-9]/%' then 0    
when value like '%/[0-9]%' then 0  
when isnumeric(value)=1 then 0 else 1 end
  
  alter table chart_dropped_value_raw add isratio int

  --update [chart_dropped_value] set isratio = case when value like '%[0-9]/[0-9]%' then 1 when value like '%[0-9]/%' then 1  when value like '%/[0-9]%' then 1  else 0 end
 -- update [chart_dropped_value] set isratio = case when value like '%[0-9]/[0-9]%' then 1   else 0 end
 update chart_dropped_value_raw set isratio = case when value like '%[0-9]/[0-9]%' then 1     when value like '%[0-9]/%' then 1    when value like '%/[0-9]%' then 1 else 0 end


 select top 1000 * from chart_dropped_value_raw

drop table chart_dropped_value

select itemid, coalesce(valueuom,'None') valueuom
, value, x instances
, hasNumeric
, sum(x) over (partition by itemid) total
, sum(hasNumeric) over (partition by itemid) * 1.0/count(*) over (partition by itemid) numericRatio
, isasc
,isratio
into chart_dropped_value
from chart_dropped_value_raw
order by itemid

select * from chart_dropped_value
50870


select * from [chart_dropped_value]

select distinct itemid
--  into valid_chart_cate 
  from (
  SELECT [itemid]
      ,[valueuom]
      ,[value]
      ,[instances]
      ,[hasNumeric]
      ,[total]
      ,[numericRatio]
	  , isasc
	  , isratio
	  , sum(instances * hasNumeric) over (partition by itemid)  * 1.0 /total rationumericinstances
	  	  , sum(hasNumeric) over (partition by itemid)  * 1.0 /count(*) over (partition by itemid) rationumericcatstototalcats
	  , sum(isasc) over (partition by itemid)  * 1.0 /count(*) over (partition by itemid) ratioASCtototalcats
  FROM [mimicplay].[dbo].[chart_dropped_value]
 -- where value != 'none'
-- where value is not null
  ) a
--  where rationumericinstances< 0.5
where ratioASCtototalcats >= 0.5

3435 vs 3405 valid cates

select * from chart_dropped_value_raw
--------------------------------------
select * 
from mimiciii..CHARTEVENTS ce
where ITEMID in (
select itemid 
from filtered_chart_raw 
where percentagenumeric<0.8 and ranknumber =1 
)
---------------------------------------


314 3405 100

select * 
into filtered_chart
from filtered_chart_raw  fcr
where itemid not in (select itemid from chart_dropped_value)
and fcr.ranknumber = 1

--2644 *matches
/*
def numerical_ratio(units):
    res = list(map(lambda unit: re.match(r'(\d+\.\d*)|(\d*\.\d+)|(\d+)', unit), units))
    numerical_ratio = 1.0 * len([1 for r in res if r is not None]) / len(res)
    return numerical_ratio

LAB : 224890
Count  33004
['Not applicable ', 'Foam Cleanser', 'Normal Saline', 'Wound Cleanser', "1/4 Strength Dakin's"]
Numeric ratio 0.2
None Not applicable  	 11371
None Foam Cleanser 	 8195
None Normal Saline 	 8035
None Wound Cleanser 	 5400
None 1/4 Strength Dakin's 	 3

	*/

	Store selected features in first filtering

These features are all numerical features.



	store 3 kinds of features

## Divide dropped features in first filtering

- Features with the ratio of non-numerical values(values that cannot pass the parser) > 0.5: categorical features
- Features with the ratio of ratio values > 0.5: ratio features
- otherwise: (possible) numerical features, we will parse them later


  select distinct itemid from [chart_dropped_value]
  3819

--SELECT [itemid]
--      ,[valueuom]
--      ,[value]
--      ,[instances]
--      ,[hasNumeric]
--      ,[total]
--      ,[numericRatio]
--	  --, sum([hasNumeric]) over (partition by itemid)  * 1.0 /count(*) over (partition by itemid) numeric
--into chart_dropped_nonnumeric
--  FROM [mimicplay].[dbo].[chart_dropped_value]
--  where [numericRatio]< 0.5
----28477

--  select distinct itemid from chart_dropped_nonnumeric
--  3343

  drop table chart_dropped_nonnumeric

  select *
  into chart_dropped_nonnumeric 
  from (
  SELECT [itemid]
      ,[valueuom]
      ,[value]
      ,[instances]
      ,[hasNumeric]
      ,[total]
      ,[numericRatio]
	  , sum(instances * hasNumeric) over (partition by itemid)  * 1.0 /total rationumericinstances
  FROM [mimicplay].[dbo].[chart_dropped_value]
  ) a
  where rationumericinstances< 0.5
  37813

    select distinct itemid from chart_dropped_nonnumeric
	3407 vs 3405 itemids

	314 3405 100

	
	drop table valid_chart_cate

  select *
  into valid_chart_cate 
  from (
  SELECT [itemid]
      ,[valueuom]
      ,[value]
      ,[instances]
      ,[hasNumeric]
      ,[total]
      ,[numericRatio]
	  , sum(instances * hasNumeric) over (partition by itemid)  * 1.0 /total rationumericinstances
	  	  , sum(hasNumeric) over (partition by itemid)  * 1.0 /count(*) over (partition by itemid) rationumericcatstototalcats
	  , sum(isasc) over (partition by itemid)  * 1.0 /count(*) over (partition by itemid) ratioASCtototalcats
  FROM [mimicplay].[dbo].[chart_dropped_value]
  ) a
--  where rationumericinstances< 0.5
where ratioASCtototalcats >= 0.5


select distinct itemid from valid_chart_cate
3386
3435 vs 3405

print(len(valid_chart_num), len(valid_chart_cate), len(valid_chart_ratio))
314 3405 100

select *
  from valid_chart_cate 
  where itemid in (6851, 6835, 737)
  where hasNumeric = 1

  select * from [chart_dropped_value]
------------------------------------------------------------------------------
drop table valid_chart_ratio

  select *
  into valid_chart_ratio 
  from (
  SELECT [itemid]
      ,[valueuom]
      ,[value]
      ,[instances]
      ,[hasNumeric]
      ,[total]
      ,[numericRatio]
	  , sum(instances * hasNumeric) over (partition by itemid)  * 1.0 /total rationumericinstances
	  , sum(instances * isratio) over (partition by itemid)  * 1.0 /total rationum
	  , sum(hasNumeric) over (partition by itemid)  * 1.0 /count(*) over (partition by itemid) rationumericcatstototalcats
	  , sum(isasc) over (partition by itemid)  * 1.0 /count(*) over (partition by itemid) ratioASCtototalcats
	  , sum(isratio) over (partition by itemid) * 1.0 / count(*) over (partition by itemid) ratioratiotototalcats
  FROM [mimicplay].[dbo].[chart_dropped_value]
  ) a
  --where rationumericinstances>= 0.5
  where ratioASCtototalcats < 0.5
 -- and rationum >=0.5
 and ratioratiotototalcats >=0.5

  --2207
  --2218
  select * from valid_chart_ratio

     select distinct itemid from valid_chart_ratio

	 --101 itemids
	 --105
	 --107

  and value like '%/%'
  and value like '%[0-9][0-9][0-9]/[0-9][0-9][0-9]'

  print(len(valid_chart_num), len(valid_chart_cate), len(valid_chart_ratio))
  314 3405 100


    select *
  into valid_chart_num 
  from (
  SELECT [itemid]
      ,[valueuom]
      ,[value]
      ,[instances]
      ,[hasNumeric]
      ,[total]
      ,[numericRatio]
	  , sum(instances * hasNumeric) over (partition by itemid)  * 1.0 /total rationumericinstances
	  , sum(instances * isratio) over (partition by itemid)  * 1.0 /total rationum
  FROM [mimicplay].[dbo].[chart_dropped_value]
  ) a
  where rationumericinstances>= 0.5
  and rationum <0.5

  10850 rows

  172.20.36.131\mimic

select distinct itemid from valid_chart_num

311 vs 314

---------------------------------------------------------------------------



print(len(valid_chart_num), len(valid_chart_num_unit), len(valid_chart_cate))
print(valid_chart_num, valid_chart_num_unit, valid_chart_cate)
np.save('res/filtered_chart_num',{'id':valid_chart_num,'unit':valid_chart_num_unit})
np.save('res/filtered_chart_cate',{'id':valid_chart_cate,'unit':None})
np.save('res/filtered_chart_ratio', {'id': valid_chart_ratio, 'unit': None})




314 314 3405
