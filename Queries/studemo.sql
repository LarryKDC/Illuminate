SET HEADING OFF
SET FEEDBACK OFF
SET TRIMSPOOL ON
SET PAGESIZE 0
SET LINESIZE 1800
SET VERIFY OFF
SPOOL 'psexports\studemo.txt';
-- Write student demographic column headers.
--
SELECT
		   '01 Student ID'
|| :TAB || '02 State Student ID'
|| :TAB || '03 Student Last Name'
|| :TAB || '04 Student First Name'
|| :TAB || '05 Student Middle Name'
|| :TAB || '06 Birth Date'
|| :TAB || '07 Gender'
|| :TAB || '08 RACE Code ID 1'
|| :TAB || '09 RACE Code ID 2'
|| :TAB || '10 RACE Code ID 3'
|| :TAB || '11 Is Hispanic'
|| :TAB || '12 Primary Language Code ID'
|| :TAB || '13 Correspondence Language Code ID'
|| :TAB || '14 Language Fluency'
|| :TAB || '15 Reclassification Date'
|| :TAB || '16 Primary Disability Code ID'
|| :TAB || '17 Migrant Ed Student ID'
|| :TAB || '18 Lep Date'
|| :TAB || '19 US Entry Date'
|| :TAB || '20 Date Entered School'
|| :TAB || '21 Date Entered District'
|| :TAB || '22 Parent Guardian Highest Education Level'
|| :TAB || '23 Residential Status'
|| :TAB || '24 Special Needs Status'
|| :TAB || '25 SST Date'
|| :TAB || '26 504 Accommodations'
|| :TAB || '27 504 Review Date'
|| :TAB || '28 Special Ed Exit Date'
|| :TAB || '29 Birth City'
|| :TAB || '30 Birth State'
|| :TAB || '31 Birth Country'
|| :TAB || '32 Lunch ID'
|| :TAB || '33 AcademicYear'
|| :TAB || '34 Student Name Suffix'
|| :TAB || '35 Student Last Name Alias'
|| :TAB || '36 Student First Name Alias'
|| :TAB || '37 Student Middle Name Alias'
|| :TAB || '38 Student Name Suffix Alias'
|| :TAB || '39 Titile 1 Service Received'
|| :TAB || '40 Student Name Suffix Alias'
|| :TAB || '41 District ID'
|| :TAB || '42 Site ID'
|| :TAB || '43 Resident LEA Code'
|| :TAB || '44 Birth Date Verification Method'
|| :TAB || '45 Homeless Dwelling Type'
|| :TAB || '46 Photo Release'
|| :TAB || '47 Military Recruitment'
|| :TAB || '48 Internet Use Release'
|| :TAB || '49 Expected Graduation Date'
|| :TAB || '50 Graduation Completion Status'
|| :TAB || '51 Graduation Service Learning Hours'
|| :TAB || '52 US Citizen Born Abroad'
|| :TAB || '53 Military Family'
|| :TAB || '54 Home Address Verification Date'
|| :TAB || '55 Special Ed Enter Date'
|| :TAB || '56 Secondary Disability Code ID'
|| :TAB || '57 State School Entry Date'
--BEGIN additional column headers
--END additional column headers
FROM DUAL
/
-- Write student demographic data.
--
SELECT
             s.Student_Number
|| :TAB || s.STATE_STUDENTNUMBER
|| :TAB || s.Last_Name
|| :TAB || s.First_Name
|| :TAB || s.Middle_Name
|| :TAB || TO_CHAR( s.DOB, 'MM/dd/yyyy' )
|| :TAB || s.GENDER
|| :TAB || sr.race1 -- OCW : Race data
|| :TAB || sr.race2 -- OCW : Race data
|| :TAB || sr.race3 -- OCW : Race data
|| :TAB || s.fedethnicity -- OCW : PS built-in new FedEthnicity
|| :TAB || '' -- OCW : removed
|| :TAB || '' -- OCW : removed
|| :TAB || '' -- OCW : removed
|| :TAB || '' -- OCW : removed
|| :TAB || (SELECT DISTINCT CASE ps_customfields.getStudentsCF(studentid,'SPED_Classification') WHEN 'Autism' THEN 320 WHEN 'DD' THEN 230 WHEN 'ED' THEN 260 WHEN 'Hearing Impaired' THEN 220 WHEN 'ID' THEN 210 WHEN 'LD' THEN 290 WHEN 'MD' THEN 310 WHEN 'OHI' THEN 280 WHEN 'SLI' THEN 240 WHEN 'TBI' THEN 330 END  FROM spenrollments WHERE studentid = s.id AND programid = (SELECT id FROM gen WHERE cat='specprog' AND name='Special Education') AND exit_date = '01-JAN-1900')
|| :TAB || ''
|| :TAB || ''
|| :TAB || '' -- OCW : removed
|| :TAB || '' -- OCW : removed
|| :TAB || '' -- OCW : removed
|| :TAB || '' -- OCW : removed
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || '' -- OCW : removed
|| :TAB || '' -- OCW : removed
|| :TAB || '' -- OCW : removed
|| :TAB || ''
|| :TAB || '&IE_ACADEMIC_YEAR'
|| :TAB || '' -- OCW : removed
|| :TAB || '' -- OCW : removed
|| :TAB || '' -- OCW : removed
|| :TAB || '' -- OCW : removed
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
|| :TAB || ''
--BEGIN additional data columns
--Acceptable fields:
--Students table.  Table alias name is 's'.  Custom fields can be pulled using: ps_customfields.getStudentsCF(s.id, 'FIELDNAME')
--END additional data columns
-- OCW : remove ORDER BY from students for speed
-- OCW : LEFT OUTER JOIN studentrace subquery gets the first three races alphabetically
-- OCW : LEFT OUTER JOIN spenrollments subquery gets Special Education start and end dates
-- OCW : replaced Special Education start and end dates here with programs.txt
FROM
  ps.students s
LEFT OUTER JOIN (
  SELECT studentid 
  , MAX(CASE WHEN sr.rnk = 1 THEN sr.racecd END) race1
  , MAX(CASE WHEN sr.rnk = 2 THEN sr.racecd END) race2
  , MAX(CASE WHEN sr.rnk = 3 THEN sr.racecd END) race3
  FROM (SELECT studentid, racecd, ROW_NUMBER() OVER (PARTITION BY studentid ORDER BY racecd) AS rnk FROM studentrace) sr
  GROUP BY studentid) sr ON sr.studentid = s.id
/*
LEFT OUTER JOIN (
  SELECT studentid, TO_CHAR(enter_date,'MM/dd/yyyy') enter_date, CASE WHEN exit_date = '01-JAN-1900' THEN NULL ELSE TO_CHAR(exit_date,'MM/dd/yyyy') END exit_date
  FROM spenrollments sp
  JOIN gen ON gen.id = sp.programid AND gen.cat = 'specprog' AND gen.value = 'Special Education'
) sp ON sp.studentid = s.id
*/
WHERE s.entrydate >= '&IE_FIRST_DAY'
/
SPOOL OFF