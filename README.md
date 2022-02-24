# JAMF-Install-APP-from-DMG
	This script was created to install an .app from a DMG file. This is for the DMG
	files you get that give you the option to drag the .app to Applications folder. 
	This allows the same behavior to use a JAMF Policy to do the install. The Script
	supports logging as well.

###	Jamf Variable Label Names
	Parameter 4 -eq Full path where the DMG lives. Where did JAMF Place on the Mac.
	Parameter 5 -eq Package name in the DMG. The name of app we are moving to /Applications.
	Parameter 6 -eq Path to package in application Folder (/Applications/YourPackage.app)
	Parameter 7 -eq Your log file path. (Recommended "/Library/Logs/<Company Name>")
	Parameter 8 -eq Your log file name. (Recommended "<scriptName>.log")
	Parameter 9 -eq Your Company Name for the Log
	
	You can also test the script from the command line by sending some empty variables.
	(e.x. InstallAppFromDMGJAMF.sh empty1 empty2 empty3 "</PathToYourDMGLocation.dmg>" "<appName.app>" "/Applications/<appName.app>" "/Library/Logs/<FolderName>" "<LogFileName.log>" "<CompanyName>"