SET HEADING OFF
SET FEEDBACK OFF
SET TRIMSPOOL ON
SET PAGESIZE 0
SET LINESIZE 3000
SET VERIFY OFF
SPOOL 'psexports\users.txt';
-- Write teacher column headers.
--
SELECT DISTINCT
			 '01 User ID'
  || :TAB || '02 User Last Name'
  || :TAB || '03 User First Name'
  || :TAB || '04 User Middle Name'
  || :TAB || '05 Birth Date'
  || :TAB || '06 Gender'
  || :TAB || '07 Email Address'
  || :TAB || '08 Username'
  || :TAB || '09 Password'
  || :TAB || '10 State User or Employee ID'
  || :TAB || '11 Name suffix'
  || :TAB || '12 Former First Name'
  || :TAB || '13 Former Middle Name'
  || :TAB || '14 Former Last Name'
  || :TAB || '15 Primary Race'
  || :TAB || '16 User is Hispanic'
  || :TAB || '17 Address'
  || :TAB || '18 City'
  || :TAB || '19 State'
  || :TAB || '20 Zip'
  || :TAB || '21 Job Title'
  || :TAB || '22 Education Level'
  || :TAB || '23 Hire Date'
  || :TAB || '24 Exit Date'
  || :TAB || '25 Active'
--BEGIN additional column headers
--END additional column headers
FROM DUAL
/
-- Write teacher data.
--
SELECT DISTINCT
			 CASE WHEN LENGTH(u.teachernumber) = 6 AND SUBSTR(u.teachernumber,1,2) IN ('10','20') THEN u.teachernumber ELSE TO_CHAR(900000 + (SELECT max(id) FROM teachers WHERE teachernumber = u.teachernumber)) END -- OCW : unified TeacherNumber (100xxx or 200xxx) for current users, 900xxx for old users
  || :TAB || u.Last_Name
  || :TAB || u.First_Name
  || :TAB || ''
  || :TAB || (SELECT MAX(ps_customfields.getTeachersCF (id,'dob')) FROM teachers WHERE teachernumber = u.teachernumber) -- OCW : Max DOB from teachers in case of multiple/null DOBs
  || :TAB || (SELECT UPPER(MAX(ps_customfields.getTeachersCF (id,'gender'))) FROM teachers WHERE teachernumber = u.teachernumber) -- OCW : Max gender from teachers in case of multiple/null genders
  || :TAB || LOWER(u.email_addr) -- OCW : does not always match LoginID, usually this is for teachers who marry and change last names but keep old last name for user account
  || :TAB || LOWER(CASE WHEN u.loginid LIKE '%.%' THEN u.loginid ELSE LOWER(REGEXP_REPLACE(u.first_name,chr(91)||'^A-Za-z-'||chr(93),'')) || '.' || LOWER(REGEXP_REPLACE(u.last_name,'('||chr(91)||'JS'||chr(93)||'r\.|II|III|IV)|'||chr(91)||'^A-Za-z-'||chr(93),'')) END) -- OCW : Use LoginID when first.last ELSE force a RegEx-cleaned first.last - this will align with our AD for LDAP authentication
  || :TAB || '' -- OCW : removed
  || :TAB || ''
  || :TAB || ''
  || :TAB || ''
  || :TAB || ''
  || :TAB || ''
  || :TAB || ''
  || :TAB || CASE WHEN u.fedethnicity < 0 THEN 0 ELSE u.fedethnicity END  -- OCW : No data in fedethnicity returns -1 in Powerschool
  || :TAB || '' -- OCW : removed
  || :TAB || '' -- OCW : removed
  || :TAB || '' -- OCW : removed
  || :TAB || '' -- OCW : removed
  || :TAB || ''
  || :TAB || ''
  || :TAB || ''
  || :TAB || ''
  || :TAB || CASE (SELECT MIN(status) FROM teachers WHERE teachernumber = u.teachernumber) WHEN 1 THEN 1 ELSE 0 END -- OCW : In PowerSchool, status = 1 for active, 2 for inactive
--BEGIN additional data columns
--Acceptable fields:
--Teachers table(t). Custom teacher fields:  ps_customfields.getTeachersCF(t.id, 'FIELDNAME')
-- OCW : Pulling custom teacher fields requires inline aggregate sub-queries that return one value (like those above for DOB and gender) to account for multiple teacher accounts per user with differing custom field data
-- OCW : Removed ORDER BY in teachers for speed
-- OCW : JOIN SchoolStaff sub-query to return only users with section assignments, including Co-Teachers. Sections table to SectionTeacher table relationship is one-to-many.  SectionTeacher to SchoolStaff is one-to-one.  Users to SchoolStaff is one-to-many
-- OCW : Update 2013-12-06 - Removed SchoolStaff sub-query join so results include all relevant staff in PowerSchool, i.e. SPED staff that is not assigned to a section
-- OCW : Update 2013-12-06 - Added "Illuminate_Exclude" field in PowerSchool to exclude any staff we don't want included in results, i.e. Lunch Staff
-- OCW : Users table only exists in PowerSchool 7.8+
--END additional data columns
FROM ps.users u
WHERE (SELECT MAX(ps_customfields.getTeachersCF (id,'Illuminate_Exclude')) FROM teachers WHERE teachernumber = u.teachernumber) IS NULL
/
SPOOL OFF