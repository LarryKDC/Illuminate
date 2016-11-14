SET HEADING OFF
SET FEEDBACK OFF
SET TRIMSPOOL ON
SET PAGESIZE 0
SET LINESIZE 300
SPOOL 'psexports\mastschd.txt';
-- Write course column headers.
--
SELECT  DISTINCT
			'01 Section ID'
 || :TAB || '02 Site ID'
 || :TAB || '03 Term Name'
 || :TAB || '04 Course ID'
 || :TAB || '05 User ID'
 || :TAB || '06 Period'
 || :TAB || '07 AcademicYear'
 || :TAB || '08 Room Number'
 || :TAB || '09 Session Type'
 || :TAB || '10 Unique Term ID'
 || :TAB || '11 Quarter Number'
 || :TAB || '12 User Start Date'
 || :TAB || '13 User End Date'
 || :TAB || '14 Primary User'
 || :TAB || '15 Highly Qualified Teacher Competency Code'
--BEGIN additional column headers
--END additional column headers
FROM DUAL
/
-- Write course data.
--
SELECT DISTINCT
			s.ID
 || :TAB || s.SCHOOLID
 || :TAB || 'Y'
 || :TAB || s.COURSE_NUMBER
 || :TAB || CASE WHEN LENGTH(u.teachernumber) = 6 AND SUBSTR(u.teachernumber,1,2) IN ('10','20') THEN u.teachernumber ELSE TO_CHAR(900000 + (SELECT max(id) FROM teachers WHERE teachernumber = u.teachernumber)) END -- OCW : This line matches the User ID line from users.sql
 || :TAB || CASE WHEN s.course_number = '3' THEN 'Homeroom' ELSE COALESCE(COALESCE(ps_customfields.getSectionsCF(s.id,'Homeroom'),s.section_number),'NONE') END -- OCW : This returns 'Homeroom' for the Homeroom section and the cohort Homeroom name (i.e. 'UVA') for all other sections
 || :TAB || TO_CHAR(t.yearid + 1990)||'-'||TO_CHAR(t.yearid + 1991)
 || :TAB || COALESCE(COALESCE(ps_customfields.getSectionsCF(s.id,'Homeroom'),s.section_number),s.room)
 || :TAB || ''
 || :TAB || ''
 || :TAB || ''
 || :TAB || ''
 || :TAB || ''
 || :TAB || CASE WHEN r.name = 'Lead Teacher' THEN 1 ELSE 0 END -- OCW : Default role in PowerSchool is 'Lead Teacher'
 || :TAB || ''
--BEGIN additional data columns
--Acceptable fields:
--Terms table(t).  Custom section fields:  ps_customfields.getTermsCF(c.id, 'FIELDNAME')
--Section table(s).  Custom section fields:  ps_customfields.getSectionsCF(c.id, 'FIELDNAME')
-- OCW : SectionTeacher table includes TeacherIDs for non-Lead Teachers
-- OCW : SchoolStaff/Users tables link to UserID as defined in users.sql.  This numbering convention is specific to KIPP DC
-- OCW : RoleDef table defines the type of teacher role, i.e. Lead Teacher or Co-Teacher/Class Observer/etc.
-- OCW : The Homeroom (course number = '3') and cohort Homeroom structure is specific to KIPP DC
--END additional data columns
FROM sections s
JOIN terms t ON t.id = s.termid AND t.schoolid = s.schoolid
JOIN sectionteacher st ON st.sectionid = s.id
JOIN schoolstaff ss ON ss.id = st.teacherid
JOIN users u ON u.dcid = ss.users_dcid
JOIN roledef r ON r.id = st.roleid
WHERE t.yearid = &IE_YEAR_ID
/
SPOOL OFF