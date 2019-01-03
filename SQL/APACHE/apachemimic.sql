CONSTITUENT COMPONENTS of apache

--select top 1000 * from  mimiciii..d_items

--select top 1000 * from  mimiciii..chartevents

	--723 GCSVerbal chartevents
	--454 GCSMotor chartevents
	--184 GCSEyes chartevents
	--223900 Verbal Response chartevents
	--223901 Motor Response chartevents
	--220739 Eye Opening charteven
select * 
from  mimiciii..d_items i
where i.itemid in (723,454,184,223900,223901,220739)

create table 

--1 No Response	1	Eye Opening	carevue	184
--1 No Response	1	Motor Response	carevue	454
--4 Flex-withdraws	4	Motor Response	carevue	454
--Abnormal extension	2	GCS - Motor Response	metavision	223901
--None	1	GCS - Eye Opening	metavision	220739
--To Pain	2	GCS - Eye Opening	metavision	220739
--NULL	NULL	Motor Response	carevue	454
--1 No Response	1	Verbal Response	carevue	723
--3 To speech	3	Eye Opening	carevue	184
--5 Localizes Pain	5	Motor Response	carevue	454
--Flex-withdraws	4	GCS - Motor Response	metavision	223901
--No response	1	GCS - Motor Response	metavision	223901
--2 To pain	2	Eye Opening	carevue	184
--Inappropriate Words	3	GCS - Verbal Response	metavision	223900
--No Response	1	GCS - Verbal Response	metavision	223900
--Oriented	5	GCS - Verbal Response	metavision	223900
--To Speech	3	GCS - Eye Opening	metavision	220739
--NULL	NULL	Verbal Response	carevue	723
--2 Incomp sounds	2	Verbal Response	carevue	723
--6 Obeys Commands	6	Motor Response	carevue	454
--Incomprehensible sounds	2	GCS - Verbal Response	metavision	223900
--Localizes Pain	5	GCS - Motor Response	metavision	223901
--2 Abnorm extensn	2	Motor Response	carevue	454
--3 Inapprop words	3	Verbal Response	carevue	723
--4 Confused	4	Verbal Response	carevue	723
--Confused	4	GCS - Verbal Response	metavision	223900
--NULL	NULL	Eye Opening	carevue	184
--Obeys Commands	6	GCS - Motor Response	metavision	223901
--Spontaneously	4	GCS - Eye Opening	metavision	220739
--1.0 ET/Trach	1	Verbal Response	carevue	723
--3 Abnorm flexion	3	Motor Response	carevue	454
--Abnormal Flexion	3	GCS - Motor Response	metavision	223901
--4 Spontaneously	4	Eye Opening	carevue	184
--5 Oriented	5	Verbal Response	carevue	723
--No Response-ETT	1	GCS - Verbal Response	metavision	223900


	--51 Arterial BP [Systolic] chartevents
	--442 Manual BP [Systolic] chartevents
	--455 NBP [Systolic] chartevents
	--6701 Arterial BP #2 [Systolic] chartevents
	--220179 Non Invasive Blood Pressure systolic chartevents
	--220050 Arterial Blood Pressure systolic chartevent
select distinct value, valuenum, label, dbsource, i.itemid 
from  mimiciii..chartevents c
inner join mimiciii..d_items i on c.ITEMID = i.ITEMID
where i.itemid in (723,454,184,223900,223901,220739)



--ROW_ID	ITEMID	LABEL	ABBREVIATION	DBSOURCE	LINKSTO	CATEGORY	UNITNAME	PARAM_TYPE	CONCEPTID
--57	51	Arterial BP [Systolic]	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
--408	442	Manual BP [Systolic]	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
--419	455	NBP [Systolic]	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
--4325	6701	Arterial BP #2 [Systolic]	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
--12716	220050	Arterial Blood Pressure systolic	ABPs	metavision	chartevents	Routine Vital Signs	mmHg	Numeric	NULL
--12734	220179	Non Invasive Blood Pressure systolic	NBPs	metavision	chartevents	Routine Vital Signs	mmHg	Numeric	NULL

https://thenursepath.blog/2016/12/08/mean-arterial-pressure-map/
The simple way to calculate the patients MAP is to use the following formula: MAP = [ (2 x diastolic) + systolic ] divided by 3. 
The reason that the diastolic value is multiplied by 2, is that the diastolic portion of the cardiac cycle is twice as long as the systolic

select * 
from  mimiciii..d_items i
where i.itemid in (51,442,455,6701,220179,220050)


select * 
from  mimiciii..d_items i
where i.itemid in (52,443,456,6702,220180,220051)

ROW_ID	ITEMID	LABEL	ABBREVIATION	DBSOURCE	LINKSTO	CATEGORY	UNITNAME	PARAM_TYPE	CONCEPTID
58	52	Arterial BP Mean	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
409	443	Manual BP Mean(calc)	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
420	456	NBP Mean	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
4326	6702	Arterial BP Mean #2	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
12717	220051	Arterial Blood Pressure diastolic	ABPd	metavision	chartevents	Routine Vital Signs	mmHg	Numeric	NULL
12735	220180	Non Invasive Blood Pressure diastolic	NBPd	metavision	chartevents	Routine Vital Signs	mmHg	Numeric	NULL

select * 
from  mimiciii..d_items i
where i.itemid in (52,443,456,6702,220181,220052)
ROW_ID	ITEMID	LABEL	ABBREVIATION	DBSOURCE	LINKSTO	CATEGORY	UNITNAME	PARAM_TYPE	CONCEPTID
58	52	Arterial BP Mean	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
409	443	Manual BP Mean(calc)	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
420	456	NBP Mean	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
4326	6702	Arterial BP Mean #2	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
12718	220052	Arterial Blood Pressure mean	ABPm	metavision	chartevents	Routine Vital Signs	mmHg	Numeric	NULL
12736	220181	Non Invasive Blood Pressure mean	NBPm	metavision	chartevents	Routine Vital Signs	mmHg	Numeric	NULL


select * 
from  mimiciii..d_items i
where i.itemid in (211,220045)

ROW_ID	ITEMID	LABEL	ABBREVIATION	DBSOURCE	LINKSTO	CATEGORY	UNITNAME	PARAM_TYPE	CONCEPTID
212	211	Heart Rate	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
12712	220045	Heart Rate	HR	metavision	chartevents	Routine Vital Signs	bpm	Numeric	NULL

select * 
from  mimiciii..d_items i
where i.itemid in (678,223671,676,223762)
ROW_ID	ITEMID	LABEL	ABBREVIATION	DBSOURCE	LINKSTO	CATEGORY	UNITNAME	PARAM_TYPE	CONCEPTID
627	676	Temperature C	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
629	678	Temperature F	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
12758	223762	Temperature Celsius	Temperature C	metavision	chartevents	Routine Vital Signs	?C	Numeric	NULL
---------------------------------
4298	6643	Temp Rectal	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
2818	3654	Temp Rectal [F]	NULL	carevue	chartevents	NULL	NULL	NULL	NULL

627	676	Temperature C	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
628	677	Temperature C (calc)	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
629	678	Temperature F	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
630	679	Temperature F (calc)	NULL	carevue	chartevents	NULL	NULL	NULL	NULL


12757	223761	Temperature Fahrenheit	Temperature F	metavision	chartevents	Routine Vital Signs	?F	Numeric	NULL
12758	223762	Temperature Celsius	Temperature C	metavision	chartevents	Routine Vital Signs	?C	Numeric	NULL

14731	227054	TemperatureF_ApacheIV	TemperatureF_ApacheIV	metavision	chartevents	Scores - APACHE IV (2)	?F	Numeric	NULL

(678,223671,676,223762, 6643, 3654, 677, 679, 227054)


select * 
from  mimiciii..d_items i
where label like '%Temp%' and label like '%rectal%'


-----
AaDO2 or PaO2 (depending on FiO2)
A-aPO2(FiO2>50%) or PaO2(FiO2<50%)
A-aPO2(FiO2>50%) or PaO2(FiO2<50%)

select * 
from  mimiciii..d_items i
where i.itemid in (50821,50816, 223835, 3420, 3422, 190)

ROW_ID	ITEMID	LABEL	ABBREVIATION	DBSOURCE	LINKSTO	CATEGORY	UNITNAME	PARAM_TYPE	CONCEPTID
191	190	FiO2 Set	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
1019	3420	FIO2	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
1021	3422	FIO2 [Meas]	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
12804	223835	Inspired O2 Fraction	FiO2	metavision	chartevents	Respiratory	None	Numeric	NULL

select * 
from  mimiciii..d_labitems i
where i.itemid in (50821,50816, 223835, 3420, 3422, 190)
ROW_ID	ITEMID	LABEL	FLUID	CATEGORY	LOINC_CODE
17	50816	Oxygen	Blood	Blood Gas	19994-3
22	50821	pO2	Blood	Blood Gas	11556-8

select * 
from  mimiciii..d_items i
where label like '%FiO2%' or abbreviation like '%FiO2%' 
1019	3420	FIO2	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
3911	2981	FiO2	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
190	189	FiO2 (Analyzed)	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
1021	3422	FIO2 [Meas]	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
14687	227010	FiO2_ApacheIV	FiO2_ApacheIV	metavision	chartevents	Scores - APACHE IV (2)	%	Numeric	NULL
14686	227009	FiO2_ApacheIV_old	FiO2_ApacheIV_old	metavision	chartevents	Scores - APACHE IV (2)	None	Numeric	NULL
14515	226754	FiO2ApacheIIValue	FiO2ApacheIIValue	metavision	chartevents	Scores - APACHE II	%	Numeric	NULL
ROW_ID	ITEMID	LABEL	ABBREVIATION	DBSOURCE	LINKSTO	CATEGORY	UNITNAME	PARAM_TYPE	CONCEPTID
12804	223835	Inspired O2 Fraction	FiO2	metavision	chartevents	Respiratory	None	Numeric	NULL

ROW_ID	ITEMID	LABEL	ABBREVIATION	DBSOURCE	LINKSTO	CATEGORY	UNITNAME	PARAM_TYPE	CONCEPTID
450	490	PAO2	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
699	779	Arterial PaO2	NULL	carevue	chartevents	ABG	NULL	NULL	NULL

---

select * 
from  mimiciii..d_items i
where label like '%PaO2%' or ABBREVIATION like '%pao2%'
ROW_ID	ITEMID	LABEL	ABBREVIATION	DBSOURCE	LINKSTO	CATEGORY	UNITNAME	PARAM_TYPE	CONCEPTID
450	490	PAO2	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
699	779	Arterial PaO2	NULL	carevue	chartevents	ABG	NULL	NULL	NULL

select * 
from  mimiciii..d_items i
where label like '%po2%' or ABBREVIATION like '%po2%'

ROW_ID	ITEMID	LABEL	ABBREVIATION	DBSOURCE	LINKSTO	CATEGORY	UNITNAME	PARAM_TYPE	CONCEPTID
2892	3785	PO2	NULL	carevue	chartevents	ABG's	NULL	NULL	NULL
2924	3837	pO2	NULL	carevue	chartevents	ABG'S	NULL	NULL	NULL
12740	220224	Arterial O2 pressure	PO2 (Arterial)	metavision	chartevents	Labs	mmHg	Numeric	NULL
14531	226770	PO2ApacheIIValue	PO2ApacheIIValue	metavision	chartevents	Scores - APACHE II	None	Numeric	NULL
14716	227039	PO2_ApacheIV	PO2_ApacheIV	metavision	chartevents	Scores - APACHE IV (2)	mmHg	Numeric	NULL

PAO2 is partial pressure of oxygen in alveoli. PaO2 is partial pressure of oxygen dissolved in (arterial) blood.

https://medical-dictionary.thefreedictionary.com/(A-a)+Po2
(A-a) Po2
alveolar-arterial oxygen tension difference.

select * 
from  mimiciii..d_items i
where label like '%tension%' or ABBREVIATION like '%po2%'

PO2 is just partial pressure of oxgen in a given environment, such as room air. 21% O2 in standard barometric pressure of 760mmHg means usual PO2 in room air is 760 x 0.21 = 160mmHg.

PAO2 is partial pressure of oxygen in alveoli.

PaO2 is partial pressure of oxygen dissolved in (arterial) blood. Partial pressure of a gas dissolved in a liquid depends on the qualities of the liquid and the concentration of the gas. This is where the dissociation curve comes in - its the relationship between the pp and total content of O2 in the blood. 

The FiO2 is used in the APACHE II (Acute Physiology and Chronic Health Evaluation II) severity of disease classification system for intensive care unit patients.[3] For FiO2 values equal to or greater than 0.5, the alveolar–arterial gradient value should be used in the APACHE II score calculation. Otherwise, the PaO2 will suffice.[3]


alveolar–arterial gradient value


select * 
from  mimiciii..d_labitems i
where label like '%pH%' and label like '%arterial%'

select * 
from  mimiciii..d_items i
where label like '%pH%' and label like '%arterial%'
ROW_ID	ITEMID	LABEL	ABBREVIATION	DBSOURCE	LINKSTO	CATEGORY	UNITNAME	PARAM_TYPE	CONCEPTID
700	780	Arterial pH	NULL	carevue	chartevents	ABG	NULL	NULL	NULL
12802	223830	PH (Arterial)	PH (Arterial)	metavision	chartevents	Labs	None	Numeric	NULL


select * 
from  mimiciii..d_items i
where label like '%respiratory%' and label like '%rate%'
ROW_ID	ITEMID	LABEL	ABBREVIATION	DBSOURCE	LINKSTO	CATEGORY	UNITNAME	PARAM_TYPE	CONCEPTID
575	618	Respiratory Rate	NULL	carevue	chartevents	NULL	NULL	NULL	NULL
12738	220210	Respiratory Rate	RR	metavision	chartevents	Respiratory	insp/min	Numeric	NULL
13245	224689	Respiratory Rate (spontaneous)	Respiratory Rate (spontaneous)	metavision	chartevents	Respiratory	insp/min	Numeric	NULL
13246	224690	Respiratory Rate (Total)	Respiratory Rate (Total)	metavision	chartevents	Respiratory	insp/min	Numeric	NULL




select * 
from  mimiciii..d_items i
where label like '%sodium%' or label like '%serum%'
ROW_ID	ITEMID	LABEL	ABBREVIATION	DBSOURCE	LINKSTO	CATEGORY	UNITNAME	PARAM_TYPE	CONCEPTID
12705	220645	Sodium (serum)	Sodium (serum)	metavision	chartevents	Labs	None	Numeric	NULL
15517	228389	Sodium (serum) (soft)	Sodium (serum) (soft)	metavision	chartevents	Labs	None	Numeric with tag	NULL

2225	4195	ABG Sodium	NULL	carevue	chartevents	ABG'S	NULL	NULL	NULL
1129	837	Sodium (135-148)	NULL	carevue	chartevents	Chemistry	NULL	NULL	NULL
2855	3726	ABG SODIUM	NULL	carevue	chartevents	ABG'S	NULL	NULL	NULL
2904	3803	Sodium  (135-148)	NULL	carevue	chartevents	Chemistry	NULL	NULL	NULL
2988	1536	Sodium	NULL	carevue	chartevents	Chemistry	NULL	NULL	NULL



Sodium level 950824 Sodium Whole Blood labevents
50983 Sodium labevents

select * 
from  mimiciii..d_items i
where i.ITEMID in (950824,50983)

select * 
from  mimiciii..d_labitems i
where i.ITEMID in (950824,50983)
ROW_ID	ITEMID	LABEL	FLUID	CATEGORY	LOINC_CODE
184	50983	Sodium	Blood	Chemistry	2951-2

select * 
from  mimiciii..d_labitems i
where label like '%sodium%'
In blood, the serum is the component that is neither a blood cell (serum does not contain white or red blood cells) nor a clotting factor; it is the blood plasma not including the fibrinogens. Serum includes all proteins not used in blood clotting (coagulation) and all the electrolytes, antibodies, antigens, hormones, and any exogenous substances (e.g., drugs and microorganisms). 
184	50983	Sodium	Blood	Chemistry	2951-2
25	50824	Sodium, Whole Blood	Blood	Blood Gas	2947-0


select * 
from  mimiciii..d_items i
where label like '%sodium%'
2855	3726	ABG SODIUM	NULL	carevue	chartevents	ABG'S	NULL	NULL	NULL
12705	220645	Sodium (serum)	Sodium (serum)	metavision	chartevents	Labs	None	Numeric	NULL
14536	226775	SodiumApacheIIScore	SodiumApacheIIScore	metavision	chartevents	Scores - APACHE II	None	Numeric	NULL


select * 
from  mimiciii..d_labitems i
where label like '%Potassium%'

23	50822	Potassium, Whole Blood	Blood	Blood Gas	6298-4
172	50971	Potassium	Blood	Chemistry	2823-3




select * 
from  mimiciii..d_items i
where label like '%Potassium%'
2224	4194	ABG Potassium	NULL	carevue	chartevents	ABG'S	NULL	NULL	NULL
2854	3725	ABG POTASSIUM	NULL	carevue	chartevents	ABG'S	NULL	NULL	NULL

14532	226771	PotassiumApacheIIScore	PotassiumApacheIIScore	metavision	chartevents	Scores - APACHE II	None	Numeric	NULL
14756	227442	Potassium (serum)	Potassium (serum)	metavision	chartevents	Labs	None	Numeric with tag	NULL


select * 
from  mimiciii..d_labitems i
where label like '%Potassium%'


select * 
from  mimiciii..d_labitems i
where label like '%Creatinine%'

113	50912	Creatinine	Blood	Chemistry	2160-0
281	51081	Creatinine, Serum	Urine	Chemistry	NULL


select * 
from  mimiciii..d_items i
where label like '%Creatinine%'


select * 
from  mimiciii..d_labitems i
where label like '%Hematocrit%'
11	50810	Hematocrit, Calculated	Blood	Blood Gas	20570-8
315	51115	Hematocrit, Ascites	Ascites	Hematology	NULL
421	51221	Hematocrit	Blood	Hematology	4544-3


Hematocrit


White blood cell count

select *
from  mimiciii..d_labitems i
where label like '%WBC%' or label like '%white blood%'