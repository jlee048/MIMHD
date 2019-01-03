--create table apacheitems (itemid int)
--gcs
insert into apacheitems values(723)
insert into apacheitems values(454)
insert into apacheitems values(184)
insert into apacheitems values(223900)
insert into apacheitems values(223901)
insert into apacheitems values(220739)

select * from d_items where itemid = 456
--bp
--(51,442,455,6701,220179,220050)
--(52,443,456,6702,220181,220052)
insert into apacheitems values(51)
insert into apacheitems values(442)
insert into apacheitems values(443)
insert into apacheitems values(455)
insert into apacheitems values(456)
insert into apacheitems values(6701)
insert into apacheitems values(6702)
insert into apacheitems values(220179)
insert into apacheitems values(220181)
insert into apacheitems values(220050)
insert into apacheitems values(220052)
insert into apacheitems values(220051)
insert into apacheitems values(220180)

--hr
--(211,220045)
insert into apacheitems values(211)
insert into apacheitems values(220045)

--temp
--(678,223671,676,223762, 6643, 3654, 677, 679, 227054)
insert into apacheitems values(676)
insert into apacheitems values(677)
insert into apacheitems values(678)
insert into apacheitems values(679)
insert into apacheitems values(223671)
insert into apacheitems values(223762)
insert into apacheitems values(227054)
insert into apacheitems values(6643)
insert into apacheitems values(3654)


--AaDO2 or PaO2 (depending on FiO2)
--A-aPO2(FiO2>50%) or PaO2(FiO2<50%)
--A-aPO2(FiO2>50%) or PaO2(FiO2<50%)
--(50821,50816, 223835, 3420, 3422, 190)

--fio2
insert into apacheitems values(50821) --lab
insert into apacheitems values(50816) --lab
insert into apacheitems values(223835)
insert into apacheitems values(3420)
insert into apacheitems values(3422)
insert into apacheitems values(190)

insert into apacheitems values(2981)
insert into apacheitems values(189)
insert into apacheitems values(3422)
insert into apacheitems values(226754)

--pao2
insert into apacheitems values(490)
insert into apacheitems values(779)
--po2
insert into apacheitems values(3785)
insert into apacheitems values(3837)
insert into apacheitems values(220224)
insert into apacheitems values(226770)
insert into apacheitems values(227039)

--PAO2 is partial pressure of oxygen in alveoli. PaO2 is partial pressure of oxygen dissolved in (arterial) blood.
/*
PO2 is just partial pressure of oxgen in a given environment, such as room air. 21% O2 in standard barometric pressure of 760mmHg means usual PO2 in room air is 760 x 0.21 = 160mmHg.
PAO2 is partial pressure of oxygen in alveoli.
PaO2 is partial pressure of oxygen dissolved in (arterial) blood. Partial pressure of a gas dissolved in a liquid depends on the qualities of the liquid and the concentration of the gas. This is where the dissociation curve comes in - its the relationship between the pp and total content of O2 in the blood. 
The FiO2 is used in the APACHE II (Acute Physiology and Chronic Health Evaluation II) severity of disease classification system for intensive care unit patients.[3] For FiO2 values equal to or greater than 0.5, the alveolar–arterial gradient value should be used in the APACHE II score calculation. Otherwise, the PaO2 will suffice.[3]

*/

--arterial ph
insert into apacheitems values(780)
insert into apacheitems values(223830)
insert into apacheitems values(50820) --lab
--21	50820	pH	Blood	Blood Gas	11558-4

--respiratory
insert into apacheitems values(618)
insert into apacheitems values(220210)
insert into apacheitems values(224689)
insert into apacheitems values(224690)

--select * 
--from  mimiciii..d_items i
--where label like '%sodium%' or label like '%serum%'

--sodium serum
insert into apacheitems values(220645)
insert into apacheitems values(228389)
insert into apacheitems values(4195)
insert into apacheitems values(3726)
insert into apacheitems values(1536)
insert into apacheitems values(837)
insert into apacheitems values(3803)
insert into apacheitems values(226775)

insert into apacheitems values(50983) --lab
insert into apacheitems values(50824) --lab

--potassium
insert into apacheitems values(50822)--lab
insert into apacheitems values(50971)--lab

insert into apacheitems values(4194) --
insert into apacheitems values(3725) --
insert into apacheitems values(226771) --
insert into apacheitems values(227442) 

--creatinine

insert into apacheitems values(50912) --lab
insert into apacheitems values(51081) --lab

--Hematocrit
insert into apacheitems values(50810) --lab
insert into apacheitems values(51115) --lab
insert into apacheitems values(51221) --lab

--White Blood Count
insert into apacheitems values(51300) --lab
insert into apacheitems values(51301) --lab

insert into apacheitems values(226779) 
insert into apacheitems values(220546) 
insert into apacheitems values(1542) 
insert into apacheitems values(1127) 
insert into apacheitems values(226780) 
insert into apacheitems values(861) 
insert into apacheitems values(4200) 

--select *
--from  mimiciii..d_labitems i
--where label like '%WBC%' or label like '%white blood%'
