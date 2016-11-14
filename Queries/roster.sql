SET HEADING OFF
SET FEEDBACK OFF
SET TRIMSPOOL ON
SET PAGESIZE 0
SET LINESIZE 300
SET VERIFY OFF
SPOOL 'psexports\roster.txt';
-- Write roster column headers.
--
SELECT
		   '01 Student ID'
|| :TAB || '02 State Student ID'
|| :TAB || '03 Student Last Name'
|| :TAB || '04 Student First Name'
|| :TAB || '05 Student Middle Name'
|| :TAB || '06 Birth Date'
|| :TAB || '07 Section ID'
|| :TAB || '08 Site ID'
|| :TAB || '09 Course ID'
|| :TAB || '10 User ID'
|| :TAB || '11 Entry Date'
|| :TAB || '12 Exit Date'
|| :TAB || '13 Student Grade Level ID'
|| :TAB || '14 Academic Year'
|| :TAB || '15 Session Type'
--BEGIN additional column headers
--END additional column headers
FROM DUAL
/
-- Write roster data.
--
SELECT
             s.Student_Number
  || :TAB || s.STATE_STUDENTNUMBER
  || :TAB || s.LAST_NAME
  || :TAB || s.FIRST_NAME
  || :TAB || s.MIDDLE_NAME
  || :TAB || TO_CHAR( s.DOB, 'MM/dd/yyyy' )
  || :TAB || ABS(cc.SECTIONID)
  || :TAB || cc.SCHOOLID
  || :TAB || cc.COURSE_NUMBER
  || :TAB || CASE WHEN LENGTH(t.teachernumber) = 6 AND SUBSTR(t.teachernumber,1,2) IN ('10','20') THEN t.teachernumber ELSE TO_CHAR(900000 + (SELECT max(id) FROM teachers WHERE teachernumber = t.teachernumber)) END -- OCW : Single Teacher workaround
  || :TAB || TO_CHAR( cc.DATEENROLLED, 'MM/dd/yyyy' )
  || :TAB || TO_CHAR( cc.DATELEFT, 'MM/dd/yyyy' )
  || :TAB || CASE s.GRADE_LEVEL WHEN -2 THEN 15 WHEN -1 THEN 15 WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 WHEN 4 THEN 5 WHEN 5 THEN 6 WHEN 6 THEN 7 WHEN 7 THEN 8 WHEN 8 THEN 9 WHEN 9 THEN 10 WHEN 10 THEN 11 WHEN 11 THEN 12 WHEN 12 THEN 13 WHEN 99 THEN 14 END
  || :TAB || TO_CHAR(trm.yearid + 1990)||'-'||TO_CHAR(trm.yearid + 1991)
  || :TAB || ''
--BEGIN additional data columns
--Acceptable fields:
--Students table(s) Custom student fields: ps_customfields.getStudentsCF(s.id, 'FIELDNAME')
--CC table(cc).
--END additional data columns
FROM
  (SELECT * FROM ps.students ORDER BY last_name, first_name) s
  JOIN ps.cc ON cc.studentid = s.id
  JOIN ps.courses c ON c.course_number = cc.course_number
  JOIN ps.teachers t ON t.id = cc.teacherid
  JOIN ps.terms trm ON trm.id = ABS(cc.termid) AND trm.schoolid = cc.schoolid
WHERE
 trm.YearID = &IE_YEAR_ID
/
SPOOL OFF