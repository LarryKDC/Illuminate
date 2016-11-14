SET HEADING OFF
SET FEEDBACK OFF
SET TRIMSPOOL ON
SET PAGESIZE 0
SET LINESIZE 3000
SET VERIFY OFF
SPOOL 'psexports\courses.txt';
-- Write course column headers.
--
SELECT  DISTINCT
			'01 Course ID'
 || :TAB || '02 Full Name'
 || :TAB || '03 Short Name'
 || :TAB || '04 Department Name'
 || :TAB || '05 Low Grade Level ID'
 || :TAB ||	'06 High Grade Level ID'
 || :TAB ||	'07 Site ID List'
 || :TAB ||	'08 Active'
 || :TAB ||	'09 A-G Requirement Category'
 || :TAB ||	'10 Course Weight'
 || :TAB ||	'11 Course Description'
 || :TAB ||	'12 Credits Possible'
 || :TAB ||	'13 Variable Credit Class'
 || :TAB ||	'14 Maximum Credits'
 || :TAB ||	'15 Special Education Course'
 || :TAB ||	'16 Max Capacity'
 || :TAB ||	'17 Intervention Course'
 || :TAB ||	'18 NCLB Instructional Level'
 || :TAB ||	'19 Course Content'
 || :TAB ||	'20 Education Service'
 || :TAB ||	'21 Instructional Strategy'
 || :TAB ||	'22 Program Funding Source'
 || :TAB ||	'23 CTE Funding Provider'
 || :TAB ||	'24 Tech Prep'
--BEGIN additional column headers
--END additional column headers
FROM DUAL
/
-- Write course data.
--
SELECT DISTINCT
			c.course_number
 || :TAB || c.course_name
 || :TAB || c.course_name
 || :TAB || c.credittype
 || :TAB || ''
 || :TAB || ''
 || :TAB || ''
 || :TAB || ''
 || :TAB || ''
 || :TAB || ''
 || :TAB || c.sched_department
 || :TAB || ''
 || :TAB || ''
 || :TAB || ''
 || :TAB || ''
 || :TAB || ''
 || :TAB || ''
 || :TAB || '' -- OCW : Removed
 || :TAB || '' -- OCW : Removed
 || :TAB || '' -- OCW : Removed
 || :TAB || '' -- OCW : Removed
 || :TAB || ''
 || :TAB || '' -- OCW : Removed
 || :TAB || '' -- OCW : Removed
--BEGIN additional data columns
--Acceptable fields:
--Courses table(c).  Custom course fields:  ps_customfields.getCoursesCF(c.id, 'FIELDNAME')
--CC table(cc).
--END additional data columns
FROM courses c
JOIN sections se ON se.course_number = c.course_number
JOIN terms y ON y.schoolid = se.schoolid AND y.yearid = SUBSTR(se.termid,0,2) AND y.isyearrec = 1 AND y.yearid = &IE_YEAR_ID
/
SPOOL OFF
