

/*****************************************************************************************************************************************************************************************
Criteria:
Using opCode01 -		If Cardiac, discard
						If NOT IsOperation, discard

For the row, find the first ASA

*********** WHAT TO DO *********** 
- If the first code is an ASA
**********************************

********************
Further data to gather to help with imputation
********************
- event count
-- to date
-- last 6 months
-- last 1 yr
-- last 2 yr
-- last 5 yr


*****************************************************************************************************************************************************************************************/
SET DATEFORMAT dmy;
SET DATEFIRST 1; -- Monday

WITH Ops (encounterID, nhi, DOB, gender, ethnicGroup, domicileCode, DHB, eventType, endType, facility
					, opCode, opBlkNum, opChapNum, op02Code, op02BlkNum, op02ChapNum, op03Code, op03BlkNum, op03ChapNum
					, opSeverity, diag01, diag01Blk, diag01Chap, diag02, diag02Blk, diag02Chap, diag03, diag03Blk, diag03Chap, ecode
					, opDate, opAgeDays, opAgeYears, opAgeYearsFractional, opYear, opMonth, opWeek, opDayOfWeek
					, DaysTillOp, DaysTillDischarge 
					, EventDuration, EventYear, EventMonth, EventWeek, EventDayOfWeek, EventStart, EventEnd) AS
(
		SELECT		h.id AS encounterID, new_enc_nhi
					, h.DOB /* This is included because it is needed for calculations of DateAt ... */
					, gender, ethnicgp, DOM_CD, DHBDOM
					, EVENT_TYPE, END_TYPE, facility
					, ISNULL(op01, 0) AS op01, ISNULL(blk.Num, 0) AS op01Blk, ISNULL(chap.Num, 0) AS op01Chap
					, ISNULL(op02, 0), ISNULL(blk02.Num, 0) AS op02Blk, ISNULL(chap02.Num, 0) AS op02Chap
					, ISNULL(op03, 0), ISNULL(blk03.Num, 0) AS op03Blk, ISNULL(chap03.Num, 0) AS op03Chap
					, blk.SeverityFinal
					, ISNULL(diag01, 'NONE') AS diag01, ISNULL(LEFT(diag01, 2), 'NONE') AS diag01Blk, ISNULL(LEFT(diag01, 1), 'NONE') AS diag01Chap
					, ISNULL(diag02, 'NONE') AS diag02, ISNULL(LEFT(diag02, 2), 'NONE') AS diag02Blk, ISNULL(LEFT(diag02, 1), 'NONE') AS diag02Chap
					, ISNULL(diag03, 'NONE') AS diag03, ISNULL(LEFT(diag03, 2), 'NONE') AS diag03Blk, ISNULL(LEFT(diag03, 1), 'NONE') AS diag03Chap
					, ecode01
					, IIF(ISDATE(h.opdate01) = 1,  opdate01, NULL) AS OpDate
					, IIF(ISDATE(h.opdate01) = 1,  DATEDIFF(DAY, h.DOB, h.opdate01), NULL) AS OpAgeDays, IIF(ISDATE(h.opdate01) = 1,  DATEDIFF(YEAR, h.DOB, h.opdate01), NULL) AS OpAgeYears
					, ROUND(IIF(ISDATE(h.opdate01) = 1,  DATEDIFF(DAY, h.DOB, h.opdate01), NULL) / 365.25, 2) AS OpAgeYearsFractional  /* 365.25 is used because it is more accurate than 365.2422 with older patients */
					, IIF(ISDATE(h.opdate01) = 1,  DATEPART(YEAR, h.opdate01), NULL) AS OpYear, IIF(ISDATE(h.opdate01) = 1,  DATEPART(MONTH, h.opdate01), NULL) AS OpMonth
					, IIF(ISDATE(h.opdate01) = 1,  DATEPART(WEEK, h.opdate01), NULL) AS OpWeek, IIF(ISDATE(h.opdate01) = 1,  DATEPART(WEEKDAY, h.opdate01), NULL) AS OpDayOfWeek
					, IIF(ISDATE(h.opdate01) = 1,  DATEDIFF(DAY, h.EVSTDATE, h.opdate01), NULL) AS DaysTillOp, IIF(ISDATE(h.opdate01) = 1,  DATEDIFF(DAY, h.opdate01, h.EVENDATE), NULL) AS DaysTillDischarge 
					, DATEDIFF(DAY, h.EVSTDATE, h.EVENDATE) + 1 AS eventDuration, DATEPART(YEAR, EVSTDATE) AS EventYear, DATEPART(MONTH, EVSTDATE) AS EventMonth, DATEPART(WEEK, EVSTDATE) AS EventWeek, DATEPART(WEEKDAY, EVSTDATE) AS EventDayOfWeek
					, h.EVSTDATE, h.EVENDATE
		FROM		Hospitalisations h
					LEFT JOIN [lookups].[ACHIProcedure] pro ON pro.code = h.op01 /* We want to get the information for all events and then filter out later AND (pro.IsCardiac = 0 AND pro.IsOperation = 1) */
					LEFT JOIN [lookups].[ACHIBlock] blk ON blk.id = pro.blockId
					LEFT JOIN [lookups].ACHIChapter chap on chap.id = blk.chapterId
					LEFT JOIN [lookups].[ACHIProcedure] pro02 ON pro02.code = h.op02
					LEFT JOIN [lookups].[ACHIBlock] blk02 ON blk02.id = pro02.blockId
					LEFT JOIN [lookups].ACHIChapter chap02 on chap02.id = blk02.chapterId
					LEFT JOIN [lookups].[ACHIProcedure] pro03 ON pro03.code = h.op03
					LEFT JOIN [lookups].[ACHIBlock] blk03 ON blk03.id = pro03.blockId
					LEFT JOIN [lookups].ACHIChapter chap03 on chap03.id = blk03.chapterId
		--WHERE		op01 IS NOT NULL /* Decision made to include all hospitalisations - Non Op events can be filtered later.)
)
, ASAs
AS
(
			SELECT c.id, Op, c.code, p.ASA, p.IsEmergency
			FROM   (
						SELECT id, op01, op02, op03, op04, op05, op06, op07, op08, op09, op10, op11, op12, op13, op14, op15, op16, op17, op18, op19, op20, op21, op22, op23, op24, op25, op26, op27, op28, op29, op30 FROM Hospitalisations) p  
						UNPIVOT  
							(Code FOR Op IN (op01, op02, op03, op04, op05, op06, op07, op08, op09, op10, op11, op12, op13, op14, op15, op16, op17, op18, op19, op20, op21, op22, op23, op24, op25, op26, op27, op28, op29, op30)
					) AS c
					INNER JOIN lookups.ACHIProcedure p ON p.code = c.code AND NOT p.ASA IS NULL
)
, FirstASA
AS
(
			SELECT	*
			FROM	(
						SELECT   id, op, ROW_NUMBER() OVER(PARTITION BY id ORDER BY id, Op) AS RowNumber
						FROM     ASAs
						GROUP BY id, Op
					) t
			WHERE	RowNumber = 1

)
/*, Diagnoses
AS
(
			SELECT c.id, diag, c.code
			FROM   (
						SELECT id, diag01, diag02, diag03, diag04, diag05, diag06, diag07, diag08, diag09, diag10, diag11, diag12, diag13, diag14, diag15, diag16, diag17, diag18, diag19, diag20, diag21, diag22, diag23, diag24, diag25, diag26, diag27, diag28, diag29, diag30 FROM Hospitalisations) p  
						UNPIVOT  
							(Code FOR diag IN (diag01, diag02, diag03, diag04, diag05, diag06, diag07, diag08, diag09, diag10, diag11, diag12, diag13, diag14, diag15, diag16, diag17, diag18, diag19, diag20, diag21, diag22, diag23, diag24, diag25, diag26, diag27, diag28, diag29, diag30)
					) AS c
)
/* Thomas decided that this had too little value 2018-08-16.
, DiagnosisCount
AS
(
			SELECT		id, COUNT(*) AS DiagnosisCount
			FROM		Diagnoses
			GROUP BY	id
)
*/
, ECodes
AS
(
			SELECT c.id, ecode, c.code
			FROM   (
						SELECT id, ecode01, ecode02, ecode03, ecode04, ecode05, ecode06, ecode07, ecode08, ecode09, ecode10, ecode11, ecode12, ecode13, ecode14, ecode15, ecode16, ecode17, ecode18, ecode19, ecode20 FROM Hospitalisations) p  
						UNPIVOT  
							(Code FOR ecode IN (ecode01, ecode02, ecode03, ecode04, ecode05, ecode06, ecode07, ecode08, ecode09, ecode10, ecode11, ecode12, ecode13, ecode14, ecode15, ecode16, ecode17, ecode18, ecode19, ecode20)
					) AS c
)
/* Thomas decided that this had too little value 2018-08-16.
, ecodeCount
AS
(
			SELECT		id, COUNT(*) AS ecodeCount
			FROM		Ecodes
			GROUP BY	id
)
*/
, Operations
AS
(
			SELECT c.id, op, c.code
			FROM   (
						SELECT id, op01, op02, op03, op04, op05, op06, op07, op08, op09, op10, op11, op12, op13, op14, op15, op16, op17, op18, op19, op20, op21, op22, op23, op24, op25, op26, op27, op28, op29, op30 FROM Hospitalisations) p  
						UNPIVOT  
							(Code FOR op IN (op01, op02, op03, op04, op05, op06, op07, op08, op09, op10, op11, op12, op13, op14, op15, op16, op17, op18, op19, op20, op21, op22, op23, op24, op25, op26, op27, op28, op29, op30)
					) AS c
)
/* Thomas decided that this had too little value 2018-08-16.
--, opCount
--AS
--(
--			SELECT		id, COUNT(*) AS opCount
--			FROM		Operations
--			GROUP BY	id
--)
*/*/
, OpInfo
AS
(
			SELECT		o.encounterId, nhi, DOB, gender, ethnicGroup, domicileCode, DHB, eventType, endType, facility
						, opCode, opBlkNum, opChapNum, op02Code, op02BlkNum, op02ChapNum, op03Code, op03BlkNum, op03ChapNum
						, opSeverity, diag01, diag01Blk, diag01Chap, diag02, diag02Blk, diag02Chap, diag03, diag03Blk, diag03Chap, ISNULL(ecode, 'NONE') AS ecode
						, opDate, opAgeDays, opAgeYears, opAgeYearsFractional, opYear, opMonth, opWeek, opDayOfWeek
						, DaysTillOp, DaysTillDischarge
						, eventDuration, EventYear, EventMonth, EventDayOfWeek, a2.ASA, a2.IsEmergency, EventStart, EventEnd
			FROM		Ops o
						LEFT JOIN FirstASA a ON a.id = o.encounterId
						LEFT JOIN ASAs a2 ON a2.id = a.id AND a2.Op = a.Op
)

SELECT		nhi, DOB, gender, ethnicGroup, domicileCode, DHB, eventType, endType, facility
			, opCode, opBlkNum, opChapNum, op02Code, op02BlkNum, op02ChapNum, op03Code, op03BlkNum, op03ChapNum
			, opSeverity, diag01, diag01Blk, diag01Chap, diag02, diag02Blk, diag02Chap, diag03, diag03Blk, diag03Chap, ecode
			, opAgeDays, opAgeYears, opAgeYearsFractional, opYear, opMonth, opWeek, opDayOfWeek
			, DaysTillOp, DaysTillDischarge
			, eventDuration, EventYear, eventMonth, EventDayOfWeek, eventStart, eventEnd, ASA, isEmergency
INTO		sc.HospitalisationsPlus
FROM		OpInfo
--WHERE		ASA IS NOT NULL AND ASA != 9  /* We want to get the information for all events and then filter out later */

GO

ALTER TABLE sc.HospitalisationsPlus ADD id INT IDENTITY(1,1) NOT NULL
CREATE CLUSTERED INDEX CX_HospitalisationsPlus_id ON sc.HospitalisationsPlus (id)
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Add Supporting Indexes
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE		INDEX	IX_Labs_nhi_VISIT_DATE ON Labs (new_enc_nhi, VISIT_DATE) 
GO

CREATE		INDEX	IX_OutPatient_nhi_Service_Date ON OutPatient (new_enc_nhi, SERVICE_DATE) 
GO

CREATE		INDEX	IX_Hospitalisations_nhi_EVSTDATE ON Hospitalisations (new_enc_nhi, EVSTDATE) 
GO

CREATE		INDEX	IX_Pharmacy_nhi_Date_Dispensed ON Pharmacy (new_enc_nhi, DATE_DISPENSED) 
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Add Death information
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE	sc.HospitalisationsPlus ADD dateOfDeath DATE, deathCode VARCHAR(1), causeOfDeath VARCHAR(10), AgeAtDeathFractional FLOAT, DiedDuringThisEvent TINYINT, DaysTillDeath INT
/* DiedDuringThisEvent: 0 = left hospital alive, 1 = died during this event */
GO

UPDATE		sc.HospitalisationsPlus
SET			dateOfDeath = m.DOD
			, deathCode = m.DEATH_TYPE
			, causeOfDeath = m.icdd
			, AgeAtDeathFractional = ISNULL(ROUND(DATEDIFF(DAY, hp.DOB, m.DOD) / 365.25, 2), NULL)
			, DiedDuringThisEvent = ISNULL(IIF(DATEDIFF(DAY, hp.eventStart, m.DOD) <= DATEDIFF(DAY, hp.eventStart, hp.eventEnd), 1, 0), 0) 
			, DaysTillDeath = ISNULL(DATEDIFF(DAY, hp.eventEnd, m.DOD), NULL) /* Days from discharge to death if the patient is now dead) */

FROM		sc.HospitalisationsPlus hp
			INNER JOIN Mortality m on m.new_enc_nhi = hp.nhi

GO
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Add Drug Counts
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE	sc.HospitalisationsPlus ADD Drugs1m INT, Drugs6m INT, Drugs9m INT, Drugs12m INT, Drugs18m INT, Drugs24m INT, Drugs36m INT, Drugs60m INT, DrugsTotal INT
GO

UPDATE		sc.HospitalisationsPlus
SET			Drugs1m = (SELECT COUNT(*) FROM Pharmacy h WHERE h.new_enc_nhi = hp.nhi AND h.DATE_DISPENSED BETWEEN DATEADD(M, -1, hp.EventStart) AND hp.EventStart)
			, Drugs6m = (SELECT COUNT(*) FROM Pharmacy h WHERE h.new_enc_nhi = hp.nhi AND h.DATE_DISPENSED BETWEEN DATEADD(M, -6, hp.EventStart) AND hp.EventStart)
			, Drugs9m = (SELECT COUNT(*) FROM Pharmacy h WHERE h.new_enc_nhi = hp.nhi AND h.DATE_DISPENSED BETWEEN DATEADD(M, -9, hp.EventStart) AND hp.EventStart)
			, Drugs12m = (SELECT COUNT(*) FROM Pharmacy h WHERE h.new_enc_nhi = hp.nhi AND h.DATE_DISPENSED BETWEEN DATEADD(M, -12, hp.EventStart) AND hp.EventStart)
			, Drugs18m = (SELECT COUNT(*) FROM Pharmacy h WHERE h.new_enc_nhi = hp.nhi AND h.DATE_DISPENSED BETWEEN DATEADD(M, -18, hp.EventStart) AND hp.EventStart)
			, Drugs24m = (SELECT COUNT(*) FROM Pharmacy h WHERE h.new_enc_nhi = hp.nhi AND h.DATE_DISPENSED BETWEEN DATEADD(M, -24, hp.EventStart) AND hp.EventStart)
			, Drugs36m = (SELECT COUNT(*) FROM Pharmacy h WHERE h.new_enc_nhi = hp.nhi AND h.DATE_DISPENSED BETWEEN DATEADD(M, -36, hp.EventStart) AND hp.EventStart)
			, Drugs60m = (SELECT COUNT(*) FROM Pharmacy h WHERE h.new_enc_nhi = hp.nhi AND h.DATE_DISPENSED BETWEEN DATEADD(M, -60, hp.EventStart) AND hp.EventStart)
			, DrugsTotal = (SELECT COUNT(*) FROM Pharmacy h WHERE h.new_enc_nhi = hp.nhi)

FROM		sc.HospitalisationsPlus hp

GO
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Add Lab Counts
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE	sc.HospitalisationsPlus ADD Labs1m INT, Labs6m INT, Labs9m INT, Labs12m INT, Labs18m INT, Labs24m INT, Labs36m INT, Labs60m INT, LabsTotal INT
GO

UPDATE		sc.HospitalisationsPlus
SET			Labs1m = (SELECT COUNT(*) FROM Labs h WHERE h.new_enc_nhi = hp.nhi AND h.VISIT_DATE BETWEEN DATEADD(M, -1, hp.EventStart) AND hp.EventStart)
			, Labs6m = (SELECT COUNT(*) FROM Labs h WHERE h.new_enc_nhi = hp.nhi AND h.VISIT_DATE BETWEEN DATEADD(M, -6, hp.EventStart) AND hp.EventStart)
			, Labs9m = (SELECT COUNT(*) FROM Labs h WHERE h.new_enc_nhi = hp.nhi AND h.VISIT_DATE BETWEEN DATEADD(M, -9, hp.EventStart) AND hp.EventStart)
			, Labs12m = (SELECT COUNT(*) FROM Labs h WHERE h.new_enc_nhi = hp.nhi AND h.VISIT_DATE BETWEEN DATEADD(M, -12, hp.EventStart) AND hp.EventStart)
			, Labs18m = (SELECT COUNT(*) FROM Labs h WHERE h.new_enc_nhi = hp.nhi AND h.VISIT_DATE BETWEEN DATEADD(M, -18, hp.EventStart) AND hp.EventStart)
			, Labs24m = (SELECT COUNT(*) FROM Labs h WHERE h.new_enc_nhi = hp.nhi AND h.VISIT_DATE BETWEEN DATEADD(M, -24, hp.EventStart) AND hp.EventStart)
			, Labs36m = (SELECT COUNT(*) FROM Labs h WHERE h.new_enc_nhi = hp.nhi AND h.VISIT_DATE BETWEEN DATEADD(M, -36, hp.EventStart) AND hp.EventStart)
			, Labs60m = (SELECT COUNT(*) FROM Labs h WHERE h.new_enc_nhi = hp.nhi AND h.VISIT_DATE BETWEEN DATEADD(M, -60, hp.EventStart) AND hp.EventStart)
			, LabsTotal = (SELECT COUNT(*) FROM Labs h WHERE h.new_enc_nhi = hp.nhi)

FROM		sc.HospitalisationsPlus hp

GO
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Add OutPatient Visits
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE	sc.HospitalisationsPlus ADD OPVisits1m INT, OPVisits6m INT, OPVisits9m INT, OPVisits12m INT, OPVisits18m INT, OPVisits24m INT, OPVisits36m INT, OPVisits60m INT, OPVisitsTotal INT
GO

UPDATE		sc.HospitalisationsPlus
SET			OPVisits1m = (SELECT COUNT(*) FROM OutPatient h WHERE h.new_enc_nhi = hp.nhi AND h.SERVICE_DATE BETWEEN DATEADD(M, -1, hp.EventStart) AND hp.EventStart)
			, OPVisits6m = (SELECT COUNT(*) FROM OutPatient h WHERE h.new_enc_nhi = hp.nhi AND h.SERVICE_DATE BETWEEN DATEADD(M, -6, hp.EventStart) AND hp.EventStart)
			, OPVisits9m = (SELECT COUNT(*) FROM OutPatient h WHERE h.new_enc_nhi = hp.nhi AND h.SERVICE_DATE BETWEEN DATEADD(M, -9, hp.EventStart) AND hp.EventStart)
			, OPVisits12m = (SELECT COUNT(*) FROM OutPatient h WHERE h.new_enc_nhi = hp.nhi AND h.SERVICE_DATE BETWEEN DATEADD(M, -12, hp.EventStart) AND hp.EventStart)
			, OPVisits18m = (SELECT COUNT(*) FROM OutPatient h WHERE h.new_enc_nhi = hp.nhi AND h.SERVICE_DATE BETWEEN DATEADD(M, -18, hp.EventStart) AND hp.EventStart)
			, OPVisits24m = (SELECT COUNT(*) FROM OutPatient h WHERE h.new_enc_nhi = hp.nhi AND h.SERVICE_DATE BETWEEN DATEADD(M, -24, hp.EventStart) AND hp.EventStart)
			, OPVisits36m = (SELECT COUNT(*) FROM OutPatient h WHERE h.new_enc_nhi = hp.nhi AND h.SERVICE_DATE BETWEEN DATEADD(M, -36, hp.EventStart) AND hp.EventStart)
			, OPVisits60m = (SELECT COUNT(*) FROM OutPatient h WHERE h.new_enc_nhi = hp.nhi AND h.SERVICE_DATE BETWEEN DATEADD(M, -60, hp.EventStart) AND hp.EventStart)
			, OPVisitsTotal = (SELECT COUNT(*) FROM OutPatient h WHERE h.new_enc_nhi = hp.nhi)

FROM		sc.HospitalisationsPlus hp

GO
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Add InPatient Visits
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE	sc.HospitalisationsPlus ADD IPVisits1m INT, IPVisits6m INT, IPVisits9m INT, IPVisits12m INT, IPVisits18m INT, IPVisits24m INT, IPVisits36m INT, IPVisits60m INT, IPVisitsTotal INT
GO

UPDATE		sc.HospitalisationsPlus
SET			IPVisits1m = (SELECT COUNT(*) FROM Hospitalisations h WHERE h.new_enc_nhi = hp.nhi AND h.EVSTDATE BETWEEN DATEADD(M, -1, hp.EventStart) AND hp.EventStart)
			, IPVisits6m = (SELECT COUNT(*) FROM Hospitalisations h WHERE h.new_enc_nhi = hp.nhi AND h.EVSTDATE BETWEEN DATEADD(M, -6, hp.EventStart) AND hp.EventStart)
			, IPVisits9m = (SELECT COUNT(*) FROM Hospitalisations h WHERE h.new_enc_nhi = hp.nhi AND h.EVSTDATE BETWEEN DATEADD(M, -9, hp.EventStart) AND hp.EventStart)
			, IPVisits12m = (SELECT COUNT(*) FROM Hospitalisations h WHERE h.new_enc_nhi = hp.nhi AND h.EVSTDATE BETWEEN DATEADD(M, -12, hp.EventStart) AND hp.EventStart)
			, IPVisits18m = (SELECT COUNT(*) FROM Hospitalisations h WHERE h.new_enc_nhi = hp.nhi AND h.EVSTDATE BETWEEN DATEADD(M, -18, hp.EventStart) AND hp.EventStart)
			, IPVisits24m = (SELECT COUNT(*) FROM Hospitalisations h WHERE h.new_enc_nhi = hp.nhi AND h.EVSTDATE BETWEEN DATEADD(M, -24, hp.EventStart) AND hp.EventStart)
			, IPVisits36m = (SELECT COUNT(*) FROM Hospitalisations h WHERE h.new_enc_nhi = hp.nhi AND h.EVSTDATE BETWEEN DATEADD(M, -36, hp.EventStart) AND hp.EventStart)
			, IPVisits60m = (SELECT COUNT(*) FROM Hospitalisations h WHERE h.new_enc_nhi = hp.nhi AND h.EVSTDATE BETWEEN DATEADD(M, -60, hp.EventStart) AND hp.EventStart)
			, IPVisitsTotal = (SELECT COUNT(*) FROM Hospitalisations h WHERE h.new_enc_nhi = hp.nhi)

FROM		sc.HospitalisationsPlus hp

GO

/*
CREATE VIEW	sc.vw_HospitalisationsPlus
AS
	(
			SELECT		[gender]
						, [ethnicGroup]
						, [domicileCode]
						, [DHB]
						, [eventType]
						, [endType]
						, [facility]
						, [opCode]
						, [opBlkNum]
						, [opChapNum]
						, [op02Code]
						, [op02BlkNum]
						, [op02ChapNum]
						, [op03Code]
						, [op03BlkNum]
						, [op03ChapNum]
						, [diag01]
						, [diag01Blk]
						, [diag01Chap]
						, [diag02]
						, [diag02Blk]
						, [diag02Chap]
						, [diag03]
						, [diag03Blk]
						, [diag03Chap]
						, [ecode]
						, [opAgeYearsFractional]
						, [opYear]
						, [opMonth]
						, [opWeek]
						, [opDayOfWeek]
						, [DaysTillOp]
						, [DaysTillDischarge]
						, [eventDuration]
						, [EventYear]
						, [eventMonth]
						, [EventDayOfWeek]
						, [Drugs1m]
						, [Drugs6m]
						, [Drugs9m]
						, [Drugs12m]
						, [Drugs18m]
						, [Drugs24m]
						, [Drugs36m]
						, [Drugs60m]
						, [DrugsTotal]
						, [Labs1m]
						, [Labs6m]
						, [Labs9m]
						, [Labs12m]
						, [Labs18m]
						, [Labs24m]
						, [Labs36m]
						, [Labs60m]
						, [LabsTotal]
						, [OPVisits1m]
						, [OPVisits6m]
						, [OPVisits9m]
						, [OPVisits12m]
						, [OPVisits18m]
						, [OPVisits24m]
						, [OPVisits36m]
						, [OPVisits60m]
						, [OPVisitsTotal]
						, [IPVisits1m]
						, [IPVisits6m]
						, [IPVisits9m]
						, [IPVisits12m]
						, [IPVisits18m]
						, [IPVisits24m]
						, [IPVisits36m]
						, [IPVisits60m]
						, [IPVisitsTotal]
			FROM [MoH].[sc].[HospitalisationsPlus]
	)

*/

--SELECT		TOP 1000 *
--FROM		OpInfo
--WHERE		NOT ASA IS NULL

--SELECT		ASA, COUNT(*)
--FROM		OpInfo
--GROUP BY	ASA



/*
******************** STUFF *********************************
DECLARE @counter SMALLINT = 1;
DECLARE @MaxRandomNumbers INT; 

WHILE @counter < @MaxRandomNumbers
   BEGIN  
      SELECT RAND() Random_Number  
      SET @counter = @counter + 1  
   END;  
GO  

*/