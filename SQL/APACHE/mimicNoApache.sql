 SELECT LABEL,  COUNT(*) cnt
 FROM  mimiciii..CHARTEVENTS,
 mimiciii..d_items
  WHERE LOWER(d_items.LABEL) LIKE '%apache%'
  and CHARTEVENTS.itemid = d_items.itemid
   GROUP BY d_items.LABEL
 ORDER BY cnt DESC ;


https://opendata.stackexchange.com/questions/6399/are-the-apache-scores-available-somewhere
accepted

"Acute Physiology and Chronic Health Evaluation" (APACHE) scores are rarely recorded by caregivers, so they are not well documented in the core MIMIC dataset.

Several APACHE-related itemids appear in the d_items table, as shown in the question, but there are few associated values in the chartevents table.

APACHE scores also appear as free text in the NOTEEVENTS table (for example, "On admission, APACHE II score of 10..."), but again infrequently.

The MIMIC research community is developing code to calculate scores retrospectively which will be shared in the MIMIC Code Repository.



LABEL	cnt
APACHE II Predecited Death Rate	20
AgeApacheIIScore	20
RrApacheIIScore	19
PhApacheIIScore	19
TempApacheIIScore	19
APACHE II	19
APACHE II PDR - Adjusted	19
CreatinineApacheIIScore	19
SodiumApacheIIScore	19
HematocritApacheIIScore	19
HrApacheIIScore	19
OxygenApacheIIScore	19
APACHEII-Renal failure	19
GcsApacheIIScore	19
WbcApacheIIScore	19
MapApacheIIScore	19
PotassiumApacheIIScore	19
RRApacheIIValue	18
HrApacheIIValue	18
AgeApacheIIValue	18
GCSEyeApacheIIValue	18
GCSMotorApacheIIValue	18
MapApacheIIValue	18
TempApacheIIValue	18
GCSVerbalApacheIIValue	18
WBCApacheIIValue	17
PotassiumApacheIIValue	17
SodiumApacheIIValue	17
HematocritApacheIIValue	17
HCO3ApacheIIValue	16
CreatinineApacheIIValue	16
ChpApacheIIScore	15
DswfApacheScore	15
PHApacheIIValue	14
ApacheIV_LOS	13
FiO2ApacheIIValue	13
APACHEIII	13
APACHEII-Chronic health points	9
AaDO2ApacheIIValue	9
GlucoseScore_ApacheIV	8
RRScore_ApacheIV	8
TempScore_ApacheIV	8
Hematocrit_ApacheIV	8
HrScore_ApacheIV	8
HtScore_ApacheIV	8
MapScore_ApacheIV	8
BunScore_ApacheIV	8
ChronicScore_ApacheIV	8
Apache IV Age	8
OxygenScore_ApacheIV	8
Urine output_ApacheIV	8
WBCScore_ApacheIV	8
Intubated_ApacheIV	8
AgeScore_ApacheIV	8
AlbuminScore_ApacheIV	8
ApacheIV_Natural antilog	8
Creatinine_ApacheIV	8
GcsScore_ApacheIV	8
BiliScore_ApacheIV	8
BUN_ApacheIV	8
Glucose_ApacheIV	8
PHPaCO2Score_ApacheIV	8
SodiumScore_ApacheIV	8
CreatScore_ApacheIV	8
Sodium_ApacheIV	8
UrineScore_ApacheIV	8
ApacheIV_Mortality prediction	8
WBC_ApacheIV	8
HR_ApacheIV	7
RR_ApacheIV	7
Bilirubin_ApacheIV	7
Apache IV PaFiRatio	7
MAP_ApacheIV	7
TemperatureF_ApacheIV	7
FiO2_ApacheIV	6
APACHE II Diagnosistic weight factors - Medical	5
ApacheII chronic health	5
APACHE IV diagnosis	5
APACHE IV diagnosis choice 1	5
PCO2_ApacheIV	5
PH_ApacheIV	5
Albumin_ApacheIV	4
APACHE IV diagnosis choice 2	3
APACHE II Diagnosistic weight factors - Surgical	2
APACHE IV main groups non-operative	2
Apache IV A-aDO2	2
PO2_ApacheIV	1
APACHE II Diagnosistic weight factors - Surgical emergency	1