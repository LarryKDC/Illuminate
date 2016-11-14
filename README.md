# Illuminate

##General Information

All scripts and files are stored on the PS-PROD-DB remote desktop in the folder "C:\PS_IlluminateEd_Exporter\..."
Data from PowerSchool is sent to the Illuminate SFTP nightly at 7:55pm ET by triggering the "IEexport.bat" through Windows Task Scheduler

IEexport.bat:

      1. establishes a connection to the PowerSchool server (line 6)
      2. trigger the script "ie_export_script.sql" (line 6)
      3. set the path to the SFTP and store it as a variable (line 17)
      4. set the path to the directory where the exports are stored C:\...\psexports (line 18)
      5. set current directory to SFTP client file location (line 22)
      6. open winscp (SFTP client), initializes a log file, and runs ieload.sh (line 27)

ie_export_script.sql:
    
      1. define variables to be used in queries (lines 6-8)
      2. assign the variables to queries in export (lines 16-25)
      
...\psexports\ieload.sh:

    1. login in to the SFTP server (line 3)
    2. set working directory (line 10)
    3. load exports to sftp server (lines 13-22)
    
