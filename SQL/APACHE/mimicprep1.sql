use mimiciii
go

--if not exists (select * from sysobjects where name='admission_ids' and xtype='U')
--    create table cars (
--        Name varchar(64) not null
--    )
--go

/*
This script is used for creating a list of admission ids. 
We only keep admissions that are the first admissions of their patients.
We collect all admission_ids from TABLE ICUSTAYS and TABLE TRANSFERS"
*/
if exists (select * from sysobjects where name='admission_ids' and xtype='U')
    drop table admission_ids
	go

select hadm_id into admission_ids from (
select distinct hadm_id from icustays union select distinct hadm_id from transfers
) a
--58976
select count(*) from admission_ids
--58976

/*
"We remove all admissions which are not the first admissions of some patients in order to prevent possible information leakage, which will happen when multiple admissions of the same patient occur in training set and test set simultaneously."
*/

--select hadm_id from admission_ids where hadm_id in 
--	(select distinct on (subject_id) hadm_id  from (
--			select * from admissions 
--			order by admittime
--		) tt)

if exists (select * from sysobjects where name='admission_first_ids' and xtype='U')
    drop table admission_first_ids
	go

SELECT part.hadm_id into admission_first_ids
FROM (  SELECT *, ROW_NUMBER() OVER(PARTITION BY subject_id ORDER BY admittime) Corr
    FROM admissions) part
WHERE part.Corr = 1
--46520

/*
This script is used for collecting all itemids in the database. Itemids are ids of features.\n",
    "\n",
    "In this task we only collect itemids from the following tables:\n",
    "- inputevents\n",
    "- outputevents\n",
    "- chartevents\n",
    "- labevents\n",
    "- microbiologyevents\n",
    "- prescriptions"
	"Data from Carevue and Metavision is separately stored in TABLE INPUTEVENTS_CV and TABLE INPUTEVENTS_MV. 
	Inputevents from Metavision have itemids >= 200000, and those from Carevue have itemids in [30000, 49999]."

We only need to collect all distinct itemids in TABLE OUTPUTEVENTS.
"We only need to collect all distinct itemids in TABLE CHARTEVENTS."
"We only need to collect all distinct itemids in TABLE LABEVENTS."
## Itemids from microbiologyevents\n",
    "\n",
    "We need to collect 4 kinds of itemids:\n",
    "- spec_itemid\n",
    "- org_itemid\n",
    "- ab_itemid\n",
    "- tuple of all above"

	    "We only need to collect all distinct itemids in TABLE PRESCRIPTIONS."
*/

--3216?

select  count(*) from inputevents_cv
--17527935
select count(*) from inputevents_cv where itemid >= 30000 and itemid <= 49999
--17527935

select distinct itemid from inputevents_cv where itemid >= 30000 and itemid <= 49999
--2938

with inputitemids as (
    select distinct itemid from inputevents_mv where itemid >= 200000
    union
    select distinct itemid from inputevents_cv where itemid >= 30000 and itemid <= 49999
)
select distinct itemid from inputitemids
--3126 input_itemid_txt


select distinct itemid from outputevents where itemid >= 30000 and itemid <= 49999
--1087
select distinct itemid from outputevents
--1155 output_itemid_txt


select distinct itemid from chartevents where itemid <= 49999
--4985
select distinct itemid from chartevents
--6463 chart_itemid_txt


select distinct itemid from labevents
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
select distinct spec_itemid,org_itemid,ab_itemid 
from microbiologyevents
--9154  microbio_itemid

select distinct spec_itemid,org_itemid,ab_itemid
, concat(coalesce(spec_itemid,''),coalesce(org_itemid,''),coalesce(ab_itemid,'')) microbito_itemid
from microbiologyevents


select distinct concat(coalesce(spec_itemid,''),coalesce(org_itemid,''),coalesce(ab_itemid,'')) microbio_itemid, spec_itemid,org_itemid,ab_itemid from microbiologyevents
select distinct concat(coalesce(spec_itemid,''),coalesce(org_itemid,''),coalesce(ab_itemid,'')) microbio_itemid, spec_itemid,org_itemid,ab_itemid from microbiologyevents

select distinct formulary_drug_cd from prescriptions
--3265 vs 3268

select count(formulary_drug_cd) from prescriptions
--4154517

/*

database = {'input':input_itemid,\n",
    "            'output':output_itemid,\n",
    "            'chart':chart_itemid,\n",
    "            'lab':lab_itemid,\n",
    "            'microbio':microbio_itemid,\n",
    "            'prescript':prescript_itemid}\n",
*/





getNumberOfAdmissionThatUseStatId
--numberOfAdmissionThatUseItemid

getNumberOfAdmissionThatUseStatIdBio
select count(distinct hadm_id) from microbiologyevents where hadm_id in (select * from admission_ids)
--48740

getNumberOfAdmissionThatUseStatIdPrescript


   "histo = np.load('res/inputevent_numberOfAdmissionThatUseItemid.npy').tolist()\n",
    "plt.figure(figsize=(10,5))\n",
    "plt.bar([i for i in range(len(histo))],[int(r[1]) for r in histo])\n",
    "plt.title('Number of Admission That Use Itemid: inputevent')\n",
    "plt.xlabel('the rank of feature, ordered by number of admissions using this feature desc')\n",
    "plt.ylabel('number of admissions using this feature')"

   "source": [
    "histo = np.load('res/outputevent_numberOfAdmissionThatUseItemid.npy').tolist()\n",
    "plt.figure(figsize=(10,5))\n",
    "plt.bar([i for i in range(len(histo))],[int(r[1]) for r in histo])\n",
    "plt.title('Number of Admission That Use Itemid: outputevent')\n",
    "plt.xlabel('the rank of feature, ordered by number of admissions using this feature desc')\n",
    "plt.ylabel('number of admissions using this feature')"
   ]
  },

  "histo = np.load('res/chartevent_numberOfAdmissionThatUseItemid.npy').tolist()\n",
    "plt.figure(figsize=(10,5))\n",
    "plt.bar([i for i in range(len(histo))],[int(r[1]) for r in histo])\n",
    "plt.title('Number of Admission That Use Itemid: chartevent')\n",
    "plt.xlabel('the rank of feature, ordered by number of admissions using this feature desc')\n",
    "plt.ylabel('number of admissions using this feature')"
   ]


   select count(distinct hadm_id) from labevents where itemid {0} AND hadm_id in (select * from admission_ids)