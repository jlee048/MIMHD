select p.*
, h.VALUENUM as HeartRate
, t.VALUENUM as Temperature
, bp.VALUENUM as MeanArterialPressure
, convert(integer,geye.VALUENUM) as GCSEyeScore
, gm.VALUENUM as GCSMotorScore
, gv.VALUENUM as GCSVerbalScore
, r.VALUENUM as RespiratoryRate
, aph.VALUENUM as phArterial
, cl.VALUENUM as Creatinine
, hl.VALUENUM as Hematocrit
, pc.VALUENUM as PotassiumSerum
, sc.VALUENUM as SodiumSerum
, wbc.VALUENUM as WhiteBloodCount
, fi.PaO2FiO2 as PaO2FiO2
     ,dp.PrimaryICD9 as PrimaryDiagICD9
	 ,dp.PrimaryDiag
      --,[D_Ext]
      --,[D_Supp]
      --,[D_Infect]
      --,[D_Neoplasm]
      --,[D_ENMDID]
      --,[D_DBBFO]
      --,[D_MentalD]
      --,[D_DNSSO]
      --,[D_DCS]
      --,[D_DRS]
      --,[D_DDS]
      --,[D_DGS]
      --,[D_CPCP]
      --,[D_SST]
      --,[D_MSCT]
      --,[D_CA]
      --,[D_CCOPP]
      --,[D_SSIDC]
      --,[D_SSIDC_NAF]
      --,[D_SSIDC_IDUCMM]
      --,[D_IP] 
	  ,ds.SecondaryICD9 as SecondaryDiagICD9
	  ,isnull(ds.SecondaryDiag,0) SecondaryDiag
	  --,coalesce(ds.SecondaryDiag,0) SecondaryDiag
   --   ,coalesce([DS_Ext],0) [DS_Ext]
   --   ,coalesce([DS_Supp],0) [DS_Supp]
   --   ,coalesce([DS_Infect],0) [DS_Infect]
   --   ,coalesce([DS_Neoplasm],0) [DS_Neoplasm]
   --   ,coalesce([DS_ENMDID],0) [DS_ENMDID]
   --   ,coalesce([DS_DBBFO],0) [DS_DBBFO]
   --   ,coalesce([DS_MentalD],0) [DS_MentalD]
   --   ,coalesce([DS_DNSSO],0) [DS_DNSSO]
   --   ,coalesce([DS_DCS],0) [DS_DCS]
   --   ,coalesce([DS_DRS],0) [DS_DRS]
   --   ,coalesce([DS_DDS],0) [DS_DDS]
   --   ,coalesce([DS_DGS],0) [DS_DGS]
   --   ,coalesce([DS_CPCP],0) [DS_CPCP]
   --   ,coalesce([DS_SST],0) [DS_SST]
   --   ,coalesce([DS_MSCT],0) [DS_MSCT]
   --   ,coalesce([DS_CA],0) [DS_CA]
   --   ,coalesce([DS_CCOPP],0) [DS_CCOPP]
   --   ,coalesce([DS_SSIDC],0) [DS_SSIDC]
   --   ,coalesce([DS_SSIDC_NAF],0) [DS_SSIDC_NAF]
   --   ,coalesce([DS_SSIDC_IDUCMM],0) [DS_SSIDC_IDUCMM]
   --   ,coalesce([DS_IP],0) [DS_IP]

,case when h.VALUENUM is null or t.valuenum is null or bp.valuenum is null or geye.valuenum is null or gm.valuenum is null or gv.valuenum is null or r.valuenum is null or aph.valuenum is null or cl.valuenum is null or hl.valuenum is null 
or pc.valuenum is null or sc.valuenum is null or wbc.valuenum is null or fi.PaO2FiO2 is null or p.[LOS_hours_icuicu_minprec] is null or p.religion is null or p.[MARITAL_STATUS] is null then 1 else 0 end hasMissing

,case when h.VALUENUM is null or t.valuenum is null or bp.valuenum is null or geye.valuenum is null or gm.valuenum is null or gv.valuenum is null or r.valuenum is null or aph.valuenum is null or cl.valuenum is null or hl.valuenum is null 
or pc.valuenum is null or sc.valuenum is null or wbc.valuenum is null or p.[LOS_hours_icuicu_minprec] is null or p.religion is null or p.[MARITAL_STATUS] is null then 1 else 0 end hasMissingExclFiO2

,case when h.VALUENUM is null or t.valuenum is null or bp.valuenum is null or geye.valuenum is null or gm.valuenum is null or gv.valuenum is null or r.valuenum is null or cl.valuenum is null or hl.valuenum is null 
or pc.valuenum is null or sc.valuenum is null or wbc.valuenum is null or p.[LOS_hours_icuicu_minprec] is null or p.religion is null or p.[MARITAL_STATUS] is null then 1 else 0 end hasMissingExclAPHFiO2

, CAST(CHECKSUM(NEWID()) & 0x7fffffff AS float) / CAST (0x7fffffff AS int) randomNumber
--into mimicprep..apachedataset16withCE
into mimicprep..apachedataset16WithCatDiag
from
mimicprep..firstadmissionsfirsticu p --45921
left outer join  MimicPrep..apachePrimaryDiagCat dp on dp.HADM_ID = p.HADM_ID
left outer join  MimicPrep..apacheSecondaryDiagCat ds on ds.HADM_ID = p.HADM_ID
left outer join  MimicPrep..apacheheart h on h.HADM_ID = p.HADM_ID and h.ICUSTAY_ID = p.ICUSTAY_ID
left outer join  MimicPrep..apachetemp t on h.HADM_ID = p.HADM_ID and t.ICUSTAY_ID = p.ICUSTAY_ID
left outer join  MimicPrep..apacheBPMean bp on bp.HADM_ID = p.HADM_ID and bp.ICUSTAY_ID = p.ICUSTAY_ID
left outer join  MimicPrep..apacheGCSEye geye on geye.HADM_ID = p.HADM_ID and geye.ICUSTAY_ID = p.ICUSTAY_ID
left outer join  MimicPrep..apacheGCSMotor gm on gm.HADM_ID = p.HADM_ID and gm.ICUSTAY_ID = p.ICUSTAY_ID
left outer join  MimicPrep..apacheGCSVerbal gv on gv.HADM_ID = p.HADM_ID and gv.ICUSTAY_ID = p.ICUSTAY_ID
left outer join  MimicPrep..apacheRespiratory r on r.HADM_ID = p.HADM_ID and r.ICUSTAY_ID = p.ICUSTAY_ID
left outer join  MimicPrep..apacheArtPHCombined aph on aph.HADM_ID = p.HADM_ID 
left outer join  MimicPrep..apacheCreatininelab cl on cl.HADM_ID = p.HADM_ID 
left outer join  MimicPrep..apacheHematocritlab hl on hl.HADM_ID = p.HADM_ID 
left outer join  MimicPrep..apachePotassiumCombined pc on pc.HADM_ID = p.HADM_ID 
left outer join  MimicPrep..apacheSodiumCombined sc on sc.HADM_ID = p.HADM_ID 
left outer join  MimicPrep..apacheWBCCombined wbc on wbc.HADM_ID = p.HADM_ID 
left outer join  MimicPrep..apachePaO2FiO2 fi on fi.HADM_ID = p.HADM_ID 
where p.[ageAtAdmission]>=16 --note fractional values
and p.HAS_CHARTEVENTS_DATA = 1

--drop table mimicprep..apachedataset16WithCatDiag
--36158 with or without
--35831 with charteventsdata
--select * from  MimicPrep..apachePaO2FiO2

--35823 >=16 + chartevents