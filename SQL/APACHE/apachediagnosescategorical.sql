
select HADM_ID
, SEQ_NUM
, ICD9_CODE PrimaryICD9
, case when left(icd9_code,1) = 'V' then 1 
	when left(icd9_code,1) = 'E' then 2 
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 1 and 139 then 3
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 140 and 239 then 4 
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 240 and 279 then 5
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 280 and 289 then 6
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 290 and 319 then 7
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 320 and 389 then 8
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 390 and 459 then 9
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 460 and 519 then 10
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 520 and 579 then 11
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 580 and 629 then 12
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 630 and 679 then 13
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 680 and 709 then 14
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 710 and 739 then 15
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 740 and 759 then 16
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 760 and 779 then 17
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 780 and 789 then 18
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 790 and 796 then 19
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 797 and 799 then 20
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 800 and 999 then 21 
	else 0 end PrimaryDiag
--into mimicprep..apachePrimaryDiagCat
from DIAGNOSES_ICD
where SEQ_NUM = 1
order by 3
(58929 rows)

--drop table mimicprep..apacheSecondaryDiagCat
select HADM_ID
, SEQ_NUM
, ICD9_CODE SecondaryICD9
, case when left(icd9_code,1) = 'V' then 1 
	when left(icd9_code,1) = 'E' then 2 
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 1 and 139 then 3
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 140 and 239 then 4 
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 240 and 279 then 5
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 280 and 289 then 6
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 290 and 319 then 7
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 320 and 389 then 8
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 390 and 459 then 9
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 460 and 519 then 10
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 520 and 579 then 11
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 580 and 629 then 12
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 630 and 679 then 13
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 680 and 709 then 14
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 710 and 739 then 15
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 740 and 759 then 16
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 760 and 779 then 17
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 780 and 789 then 18
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 790 and 796 then 19
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 797 and 799 then 20
	when try_cast(left(icd9_code,3) as decimal(9,2)) between 800 and 999 then 21 
	else 0 end SecondaryDiag
into mimicprep..apacheSecondaryDiagCat
from DIAGNOSES_ICD
where SEQ_NUM = 2
order by 3
(58555 rows affected)
