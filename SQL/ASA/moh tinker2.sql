select count(*)
from Hospitalisations
12,847,939


select top 10 * 
from Hospitalisations


select h.new_enc_nhi, count(*)
from Hospitalisations h
group by h.new_enc_nhi
3,575,540

select 1
      ,min([EVSTDATE])
	  , max(EVSTDATE)
	        ,min([EVENDATE])
	  , max([EVENDATE])
from Hospitalisations h
(No column name)	(No column name)	(No column name)	(No column name)	(No column name)
1	1922-08-22	2017-12-31	2006-01-01	2017-12-31

select count(distinct h.DRG_CURRENT)
from Hospitalisations h
950