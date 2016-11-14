SET HEADING OFF
SET FEEDBACK OFF
SET TRIMSPOOL ON
SET PAGESIZE 0
SET LINESIZE 1800
SET VERIFY OFF
SPOOL 'psexports\programs.txt';
-- Write student enrollment column headers.
--
SELECT
		   '01 Student ID'
|| :TAB || '02 State Student ID'
|| :TAB || '03 Student Last Name'
|| :TAB || '04 Student First Name'
|| :TAB || '05 Student Middle Name'
|| :TAB || '06 Birth Date'
|| :TAB || '07 Program ID'
|| :TAB || '08 Eligibility Start Date'
|| :TAB || '09 Eligibility End Date'
|| :TAB || '10 Program Start Date'
|| :TAB || '11 Program End Date'
|| :TAB || '12 Academic Year'
--BEGIN additional column headers
--END additional column headers
FROM DUAL
/
-- Write student enrollment data.
--
SELECT
             s.Student_Number
  || :TAB || ''
  || :TAB || s.Last_Name
  || :TAB || s.First_Name
  || :TAB || s.Middle_Name
  || :TAB || TO_CHAR( s.DOB, 'MM/dd/yyyy' )
  || :TAB || CASE gen.name 
				WHEN '504' THEN 101 
				WHEN 'ELL' THEN 120 
				WHEN 'Math Intervention Round 1' THEN 5101
				WHEN 'Math Intervention Round 2' THEN 5102
				WHEN 'Lit Intervention Round 1' THEN 5201
				WHEN 'Lit Intervention Round 2' THEN 5202
				WHEN 'Social Emotional Intervention Round 1' THEN 5301
				WHEN 'Social Emotional Intervention Round 2' THEN 5302         
				ELSE sp.programid 
			 END
  --|| :TAB || CASE gen.name WHEN '504' THEN 101 WHEN 'ELL' THEN 120 ELSE sp.programid END
  || :TAB || TO_CHAR( sp.enter_date, 'MM/dd/yyyy' )
  || :TAB || CASE WHEN sp.exit_date = '01-JAN-1900' THEN NULL ELSE TO_CHAR( sp.exit_date, 'MM/dd/yyyy' ) END
  || :TAB || CASE WHEN sp.enter_date < '&IE_FIRST_DAY' THEN TO_CHAR(TO_DATE('&IE_FIRST_DAY'),'MM/dd/yyyy') ELSE TO_CHAR( sp.enter_date, 'MM/dd/yyyy' )  END
  || :TAB || CASE WHEN sp.exit_date = '01-JAN-1900' THEN NULL ELSE TO_CHAR( sp.exit_date, 'MM/dd/yyyy' ) END
  || :TAB || '&IE_ACADEMIC_YEAR'
--BEGIN additional data columns
--Acceptable fields:
--Students table.  Table alias name is 's'.  Custom fields can be pulled using: ps_customfields.getStudentsCF(s.id, 'FIELDNAME')
--END additional data columns
FROM spenrollments sp
JOIN gen ON gen.id = sp.programid AND gen.cat = 'specprog'
JOIN students s ON s.id = sp.studentid
WHERE ( sp.exit_date >= '&IE_FIRST_DAY' OR sp.exit_date = '01-JAN-1900')
/
SPOOL OFF