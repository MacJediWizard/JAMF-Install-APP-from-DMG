#!/bin/sh

##########################################################################################
# General Information
##########################################################################################
#
#   Script created by William Grzybowski on November 11, 2021.
#
#	This script was created to install an .app from a DMG file. This is for the DMG
#	files you get that give you the option to drag the .app to Applications folder. 
#	This allows the same behavior to use a JAMF Policy to do the install. 
#
#	The Script supports logging as well.
#
#
#	Jamf Variable Label Names
#
#	Parameter 4 -eq Full path where the DMG lives. Where did JAMF Place on the Mac.
#	Parameter 5 -eq Package name in the DMG. The name of app we are moving to /Applications.
#	Parameter 6 -eq Path to package in application Folder (/Applications/YourPackage.app)
#	Parameter 7 -eq Your log file path. (Recommended "/Library/Logs/<Company Name>")
#	Parameter 8 -eq Your log file name. (Recommended "<scriptName>.log")
#	Parameter 9 -eq Your Company Name for the Log
#
##########################################################################################


##########################################################################################
# Version Info
##########################################################################################
#
#   Current Version Number 
version="1.0.0" 
#
#   Version History 
#   1.0.0 - Initial Creation of Script 
#
##########################################################################################


##########################################################################################
# License information
##########################################################################################
#
#	Copyright (c) 2022 William Grzybowski
#
#	Permission is hereby granted, free of charge, to any person obtaining a copy
#	of this software and associated documentation files (the "Software"), to deal
#	in the Software without restriction, including without limitation the rights
#	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#	copies of the Software, and to permit persons to whom the Software is
#	furnished to do so, subject to the following conditions:
#
#	The above copyright notice and this permission notice shall be included in all
#	copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#	SOFTWARE.
#
##########################################################################################


##########################################################################################
# Variables
##########################################################################################
dmgPath="$4" # full path where the DMG lives
packageName="$5" # Package name in the DMG
ApplicationName="$6" # Path to package in application Folder (/Applications/YourPackage.app)


#########################################################################################
# Logging Information
#########################################################################################
#Build Logging for script
logFilePath="${7}"
logFile="${logFilePath}/${8}"
companyName="${9}"
logFileDate=`date +"%Y-%b-%d %T"`

# Check if log path exists
if [ ! -d "${logFilePath}" ]; then
	mkdir ${logFilePath}
fi


# Logging Script
function readCommandOutputToLog(){
	if [ -n "${1}" ];	then
		IN="${1}"
	else
		while read IN 
		do
			echo "$(date +"%Y-%b-%d %T") : ${IN}" | tee -a "${logFile}"
		done
	fi
}

( # To Capture output into Date and Time log file
	
	# Get Local Info
	logBannerDate=`date +"%Y-%b-%d %T"`
	
	echo " "
	echo "##########################################################################################"
	echo "#                                                                                        #"
	echo "#                    Install ${packageName} - $logFileDate                       #"
	echo "#                                                                                        #"
	echo "##########################################################################################"
	echo "Installation of ${packageName} by ${companyName} DMG Install Script ${version} on the Mac has Started..."


	##########################################################################################
	# Core Script
	##########################################################################################
	
	# Check for the presence of the Vendor .dmg file
	if [[ -e "${dmgPath}" ]]; then
		
		# Mount the vendor .dmg file
		echo "Mounting ${dmgPath}..."
		device=$(/usr/bin/hdiutil attach -nobrowse "${dmgPath}" | /usr/bin/grep "/Volumes" | /usr/bin/awk '{ print $1 }')
		sleep 3
		
	else
		
		echo "Vendor .dmg file not found, look for ${dmgPath}..."
		echo "Need to exit script, please verify name and location of .dmg..."
		exit 1	#Stop HERE#
		
	fi
	
	
	# If Variable is not empty, check if file is present, Remove the earlier copy of the Vendor App from /Applications
	if [[ -e "${ApplicationName}" ]]; then
			
			echo "${ApplicationName} found! Removing original App..."
			rm -Rf "${ApplicationName}"
			sleep 3
			
		else
			
			echo "${ApplicationName} not found, beginning copy of ${packageName}..."
			
	fi
	
	
	# Using the device, determine the mount point
	mountPoint=$(/usr/bin/hdiutil info | /usr/bin/grep "^${device}" | /usr/bin/cut -f 3)
	
	
	# Find the package inside
	foundPackage=$(/usr/bin/find "${mountPoint}" -type d -iname "*${packageName}" -maxdepth 1 | /usr/bin/grep -v "^$mountPoint$")
	
	
	# Install the package
	cp -Rf "${foundPackage}" /Applications/
	sleep 3
	
	
	# Check if the copy completed and .app is present, modify via chown and chmod
	if [[ -e "${ApplicationName}" ]]; then
		
		echo "${packageName} successfully copied to Applications Folder..."
		sudo chown root:wheel "${ApplicationName}"
		sudo chmod 775 "${ApplicationName}"
		
	else
		
		echo "${packageName} not found!, check the ${dmgPath} file..."
		
	fi
	
	
	# UnMount the vendor .dmg file, remove the vendor.dmg as cleanup
	echo "UnMounting ${mountPoint}..."
	hdiutil detach "${mountPoint}"
	sleep 3
	
	echo "Cleaning up and removing ${dmgPath}..."
	
	rm -Rf "${dmgPath}"
	
	echo "Cleanup of ${dmgPath} is now complete..."
	
	echo "Install of ${packageName} is finished! Check status messages above..."
	
	exit 0		## Success
	exit 1		## Failure
	
) 2>&1 | readCommandOutputToLog # To Capture output into Date and Time log file