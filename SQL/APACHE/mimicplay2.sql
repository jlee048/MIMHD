Filter Itemid Lab

This script is used for filtering itemids from TABLE LABEVENTS.
1.We check number of units of each itemid and choose the major unit as the target of unit conversion.
2.In this step we get 3 kinds of features:•numerical features
•categorical features
•ratio features, this usually happens in blood pressure measurement, such as "135/70".


Output
1.itemid of observations for labevents.
2.unit of measurement for each itemid.

admission_ids

cur.execute('SELECT coalesce(valueuom,\'\'), count(*) FROM mimiciii.labevents WHERE itemid = '+ str(i) +' and hadm_id in (select * from admission_ids) group by valueuom')


--SELECT itemid, coalesce(valueuom, ''), count(*) 
--FROM mimiciii..labevents 
--WHERE  hadm_id in (select * from admission_ids) 
--group by itemid, valueuom

SELECT itemid, coalesce(valueuom, '') valueuom, count(*) count
FROM mimiciii..labevents c
inner join  admission_ids a on c.hadm_id = a.HADM_ID
group by itemid, valueuom

    cur.execute('SELECT count(*) FROM mimiciii.labevents WHERE itemid = '+ str(i) +' and hadm_id in (select * from admission_ids) and valuenum is null')
--# count number of observation that has non numeric value
SELECT itemid, count(*) 
FROM mimiciii..labevents 
WHERE hadm_id in (select * from admission_ids) 
and valuenum is null
group by itemid


  cur.execute('SELECT count(*) FROM mimiciii.labevents WHERE itemid = '+ str(i) +' and hadm_id in (select * from admission_ids) and valuenum is not null')
--# number of observation that have numeric
SELECT itemid, count(*) 
FROM mimiciii..labevents 
WHERE hadm_id in (select * from admission_ids)
and valuenum is not null
group by itemid


   return (i, outputunits, notnum, total)

   drop table filtered_lab_raw

select a.*, coalesce(b.nonnumitems,0) nonnumitems, coalesce(c.numericitems,0) numericitems
, (a.totalobsforitemid - coalesce(b.nonnumitems,0)) * 1.0 / a.totalobsforitemid percentagenumeric
, count(valueuom) over (partition by a.itemid) distinctunits
into filtered_lab_raw
from (
	SELECT itemid, coalesce(valueuom, '') valueuom, count(*) countforitemiduom
	, sum(count(*)) over (partition by itemid) totalobsforitemid
	,  count(*) * 1.0 / sum(count(*)) over (partition by itemid) percentage
	, row_number() over (partition by itemid order by count(*) desc) ranknumber
	FROM mimiciii..labevents c
	inner join  admission_ids a on c.hadm_id = a.HADM_ID
	group by itemid, valueuom
) a
left outer join 
(
SELECT itemid, count(*) nonnumitems
FROM mimiciii..labevents 
WHERE hadm_id in (select * from admission_ids) 
and valuenum is null
group by itemid
) b on a.ITEMID = b.ITEMID
left outer join 
(
SELECT itemid, count(*) numericitems
FROM mimiciii..labevents 
WHERE hadm_id in (select * from admission_ids) 
and valuenum is not null
group by itemid
) c on a.ITEMID = c.ITEMID
--where a.ranknumber = 1 -- choose only main unit
order by 1,6

select * from filtered_lab_raw order by 1
823


alter table filtered_lab_raw add distinctnonblankunits int
go

update filtered_lab_raw set distinctnonblankunits = distinctunits

update filtered_lab_raw set distinctnonblankunits = distinctunits -1 where itemid in
(select itemid from filtered_lab_raw where valueuom = '' group by itemid)

drop table filtered_lab_multiple_units

select * 
into filtered_lab_multiple_units 
from filtered_lab_raw 
where distinctnonblankunits>1
37

select * from filtered_lab_multiple_units
    
	#percentage =float(total[0])*100 / (notnum[0]+total[0])   #total is numericnum instead of actual total

	drop table filtered_lab_dropped_id



select a.*, coalesce(b.nonnumitems,0) nonnumitems, coalesce(c.numericitems,0) numericitems
, (a.totalobsforitemid - coalesce(b.nonnumitems,0)) * 1.0 / a.totalobsforitemid percentagenumeric
, count(valueuom) over (partition by a.itemid) distinctunits
into filtered_lab_dropped_id
from (
	SELECT itemid, coalesce(valueuom, '') valueuom, count(*) countforitemiduom
	, sum(count(*)) over (partition by itemid) totalobsforitemid
	,  count(*) * 1.0 / sum(count(*)) over (partition by itemid) percentage
	, row_number() over (partition by itemid order by count(*) desc) ranknumber
	FROM mimiciii..labevents c
	inner join  admission_ids a on c.hadm_id = a.HADM_ID
	group by itemid, valueuom
) a
left outer join 
(
SELECT itemid, count(*) nonnumitems
FROM mimiciii..labevents 
WHERE hadm_id in (select * from admission_ids) 
and valuenum is null
group by itemid
) b on a.ITEMID = b.ITEMID
left outer join 
(
SELECT itemid, count(*) numericitems
FROM mimiciii..labevents 
WHERE hadm_id in (select * from admission_ids) 
and valuenum is not null
group by itemid
) c on a.ITEMID = c.ITEMID
--where a.ranknumber = 1 -- choose only main unit
where  coalesce(c.numericitems,0)*100.0 / (coalesce(b.nonnumitems,0)+coalesce(c.numericitems,0)) < 95
order by 1,6

#percentage =float(total[0])*100 / (notnum[0]+total[0])   #total is numericnum instead of actual total


select * from filtered_lab_dropped_id
364
select * from filtered_lab_dropped_id where ranknumber = 1
select distinct itemid from filtered_lab_dropped_id
338 match


select * 
into filtered_lab
from filtered_lab_raw where itemid not in (select ITEMID from filtered_chart_dropped) and ranknumber = 1


select * from filtered_lab order by 1
710
select * from filtered_lab where ranknumber =1 order by 1
710
/*
All the units are convertible, so keep all of them.
*/


select * from [dbo].[filtered_lab_multiple_units]



d in dropped_id
 cur.execute('SELECT value, valueuom, count(*) as x FROM mimiciii.labevents as lb \
                WHERE itemid = '+ str(d) +' and hadm_id in (select * from admission_ids) GROUP BY value, valueuom ORDER BY x DESC')
   


   select c.itemid, value, c.valueuom,count(*) as x 
into lab_dropped_value_raw
FROM mimiciii..labevents c
inner join admission_ids a on c.hadm_id = a.HADM_ID
inner join filtered_lab_dropped_id f on f.ITEMID = c.ITEMID
GROUP BY c.itemid, value, c.valueuom 
ORDER BY x DESC


select * from lab_dropped_value_raw
17588

alter table lab_dropped_value_raw add hasNumeric int

alter table lab_dropped_value_raw add isasc int

update lab_dropped_value_raw set hasNumeric = case when value like '%[0-9]%' then 1 else 0 end

update lab_dropped_value_raw set hasNumeric = case when value like '%[0-9]/[0-9]%' then 1    when value like '%[0-9]/%' then 1    when value like '%/[0-9]%' then 1   else  isnumeric(value) end



--update lab_dropped_value_raw set isasc = case when value like '%[0-9]/[0-9]%' then 0    when value like '%[0-9]/%' then 0    when value like '%/[0-9]%' then 0  when isnumeric(value)=1 then 0 else 1 end
update lab_dropped_value_raw set isasc = case  when value like '%[0-9]%' then 0  when value like '%[0-9]/[0-9]%' then 0    when value like '%[0-9]/%' then 0    when value like '%/[0-9]%' then 0  when isnumeric(value)=1 then 0 else 1 end

  --select ISNUMERIC([value])
  --SELECT name, isnumeric(name) AS IsNameANumber, database_id, isnumeric(database_id) AS IsIdANumber   
--FROM sys.databases;

alter table lab_dropped_value_raw add isratio int

  
update lab_dropped_value_raw set isratio = case when value like '%[0-9]/[0-9]%' then 1     when value like '%[0-9]/%' then 1    when value like '%/[0-9]%' then 1 else 0 end

select * from lab_dropped_value_raw
--17588




drop table lab_dropped_value

select itemid, coalesce(valueuom,'None') valueuom
, value, x instances
, hasNumeric
, sum(x) over (partition by itemid) total
, sum(hasNumeric) over (partition by itemid) * 1.0/count(*) over (partition by itemid) numericRatio
, isratio
, isasc
into lab_dropped_value
from lab_dropped_value_raw
order by itemid


select * from lab_dropped_value
--17588

drop table valid_lab_cate

  select *
  into valid_lab_cate 
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
  FROM [mimicplay].[dbo].lab_dropped_value
  ) a
 -- where rationumericinstances< 0.5
  where ratioASCtototalcats>= 0.5


1102

select * from valid_lab_cate
  select distinct itemid from valid_lab_cate

  254 vs 224
  224 match

  drop table valid_lab_ratio

  select *
  into valid_lab_ratio 
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
  FROM [mimicplay].[dbo].lab_dropped_value
  ) a
  where ratioASCtototalcats<0.5
  and rationum >=0.5

 1354 rows
  select distinct itemid from valid_lab_ratio
  1
  

  drop table valid_lab_num

    select *
  into valid_lab_num 
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
  FROM [mimicplay].[dbo].[lab_dropped_value]
  ) a
  --where rationumericinstances>= 0.5
  where ratioASCtototalcats<0.5
  and rationum<0.5

  
  15132

    select distinct itemid from valid_lab_num
113
	print(len(valid_lab_num), len(valid_lab_cate), len(valid_lab_ratio))
	113 224 1


match!