#!/bin/bash
# Steve Ward: 2016-12-25

# USAGE:	/Users/steve/Dropbox/BASH\ Scripts/housekeep.sh /path/to/folder
# SOURCE: 	/Users/steve/Dropbox/BASH Scripts/housekeep.sh
# LAUNCHD:	/Users/steve/Library/LaunchAgents/com.steve.housekeeping.desktop-filing.plist
#			/Users/steve/Library/LaunchAgents/com.steve.housekeeping.downloads.plist			

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

DIRECTORY=$1

function check-duplicate {
    #n=$PATHONLY/$NAME
    n=$1/$NAME

	if [ $TYPE == "FILE" ]; then
	    if [[ -e "$n".$EXT ]] ; then
			i=1
	        while [[ -e "${n}"_${i}.$EXT ]] ; do
				let i++
			done
	        n="${n}"_${i}
    	fi
    	
    	mv $PATHONLY/$NAME.$EXT "$n".$EXT
    	echo -e "[`date +"%d-%m-%Y %H:%M:%S"`] MOVED $PATHONLY/$NAME.$EXT TO $n.$EXT" >> ~/Library/Logs/housekeep.log
    	
    elif [ $TYPE == "DIRECTORY" ]; then
    	if [[ -e "$n" ]] ; then
	       i=1
	        while [[ -e "${n}"_${i} ]] ; do
	            let i++
			done
	        n="${n}"_${i}
    	fi
    	
    	mv $PATHONLY/$NAME "$n"
    	echo -e "[`date +"%d-%m-%Y %H:%M:%S"`] MOVED $PATHONLY/$NAME TO $n" >> ~/Library/Logs/housekeep.log
    fi

    #if [ "$2" == false ]; then
#    if [ $TYPE == "FILE" ]; then 
#    	#echo -e "[`date +"%d-%m-%Y %H:%M:%S"`] Moved $PATHONLY/$NAME.$EXT\n\t\t\t to $n.$EXT\n"
#    	mv $PATHONLY/$NAME.$EXT "$n".$EXT
#    	echo -e "[`date +"%d-%m-%Y %H:%M:%S"`] MOVED $PATHONLY/$NAME.$EXT TO $n.$EXT" >> ~/Library/Logs/housekeep.log
#    elif [ $TYPE == "DIRECTORY" ]; then
#    	#echo -e "[`date +"%d-%m-%Y %H:%M:%S"`] Moved $PATHONLY/$NAME\n\t\t\t to $n\n"
#    	mv $PATHONLY/$NAME "$n"
#    	echo -e "[`date +"%d-%m-%Y %H:%M:%S"`] MOVED $PATHONLY/$NAME TO $n" >> ~/Library/Logs/housekeep.log
#    fi
    
}

for i in "$DIRECTORY"/*; do

                                    #                   F I L E                                     D I R E C T O R Y							DIRECTORY (with periods in name)
                                    # /Users/steve/Downloads/About\ Downloads.pdf       /Users/steve/Downloads/_Applications		/Users/steve/Downloads/bootstrap-4.0.0-alpha.6-dist
	
	PATHONLY=$(dirname "$i")        # /Users/steve/Downloads                            /Users/steve/Downloads						/Users/steve/Downloads
	FILENAME=$(basename "$i")       # About Downloads.pdf                               _Applications								bootstrap-4.0.0-alpha.6-dist
	NAME="${FILENAME%.*}"           # About Downloads                                   _Applications								bootstrap-4.0.0-alpha	(Wrong. S/B bootstrap-4.0.0-alpha.6-dist. See work-a-round.)
	EXT="${FILENAME##*.}"           # pdf                                               _Applications								6-dist					(Wrong. S/B bootstrap-4.0.0-alpha.6-dist. See work-a-round. )
	
	LCEXT=$( echo $EXT | awk '{print tolower($0)}')		# Convert to lowercase for consistency in matching

	if [ -f "$i" ]; then
		# Entry is a file
		TYPE="FILE"
	elif [ -d "$i" ]; then
		case $LCEXT in 
			app|kext|mpkg|pkg|prefpane|rtfd)
				# Although entry is a directory, because it has one of the above file extensions it is considered a file 
				TYPE="FILE"
				;;
			*)
				# Entry is a directory
				TYPE="DIRECTORY"
				NAME="$FILENAME"
				EXT="$FILENAME"
				;;
		esac
	fi
	 
	if [ $TYPE == "FILE" ]; then
			
		case $LCEXT in
			# Move to _APPLICATIONS
			# Some files with 'app', 'kext' or 'prefPane' extensions maybe treated as files or directories
			app|exe|kext|prefpane)
				#echo 'f '$i' | '$EXT' | MOVE TO _APPLICATIONS'
				check-duplicate "$PATHONLY/_Applications"
				;;
			
			# Move to _ARCHIVES
			# Some files with 'mpkg' or 'pkg' extensions maybe treated as files or directories
			bz2|dmg|gz|hqx|iso|mpkg|pkg|rar|tar|tgz)
				#echo 'f '$i' | '$EXT' | MOVE TO _ARCHIVES'
				check-duplicate "$PATHONLY/_Archives"
				;;

			# Move to _DATABASES
			sql)
				#echo 'f '$i' | '$EXT' | MOVE TO _DATABASES'
				check-duplicate "$PATHONLY/_Databases"
				;;
	
			# Move to _DOCUMENTS
			csv|doc|docx|numbers|pages|pdf|rtf|rtfd|txt|xls|xlsx)				
				if [ "$FILENAME" != "About Downloads.pdf" ]; then
					#echo 'f '$i' | '$EXT' | MOVE TO _DOCUMENTS'
					check-duplicate "$PATHONLY/_Documents"
				else
					echo 'F '$i' [IGNORED AS PER RULES]' > /dev/null
				fi
				;;
				
			# Move to _IMAGES
			gif|jpg|jpeg|mov|m4v|png|psd|tif|tiff)
				#echo 'f '$i' | '$EXT' | MOVE TO _IMAGES'
				check-duplicate "$PATHONLY/_Images"
				;;
			
			# Move to _SOUND
			mp3|m4a)
				#echo 'f '$i' | '$EXT' | MOVE TO _SOUND'
				check-duplicate "$PATHONLY/_Sound"
				;;

			# Move to _SOURCE
			css|js|htm|html|php|scpt|sh|xml)
				#echo 'f '$i' | '$EXT' | MOVE TO _SOURCE'
				check-duplicate "$PATHONLY/_Source"
				;;
			
			# Move to _ZIPS
			zip)
				#echo 'f '$i' | '$EXT' | MOVE TO _ZIPS'
				check-duplicate "$PATHONLY/_ZIPs"
				;;
					
			# Move to _MISCELLANEOUS
			*)
				#echo 'f '$i' | '$EXT' | MOVE TO _MISCELLANEOUS'
				check-duplicate "$PATHONLY/_Miscellaneous"
				;;
		esac
			
#	fi
		
	elif [ $TYPE == "DIRECTORY" ]; then
	
		# $FILENAME and $EXT will be the same only for true directories
		
#		if [ "$FILENAME" != "$EXT" ]; then
#			case $LCEXT in
#				# Move to _APPLICATIONS
#				# Some files with 'app', 'kext' or 'prefPane' extensions maybe treated as files or directories
#				app|kext|prefpane)
#					#echo 'f '$i' | '$EXT' | MOVE TO _APPLICATIONS'
#					check-duplicate "$PATHONLY/_Applications"
#					;;
#			
#				# Move to _ARCHIVES
#				# Some files with 'mpkg' or 'pkg' extensions maybe treated as files or directories
#				mpkg|pkg)
#					check-duplicate "$PATHONLY/_Archives"
#					;;
#				
#				# Move to _DOCUMENTS			
#				rtfd)
#					#echo 'f '$i' | '$EXT' | MOVE TO _ARCHIVES'
#					check-duplicate "$PATHONLY/_Documents"
#					;;
#			esac
#		
#		else
		
			if [[ "$FILENAME" == _* ]]; then
				echo 'D '$i' [IGNORED AS PER RULES]' > /dev/null
			else
				#echo 'D '$i' | '$EXT' | MOVE TO FOLDERS'
				check-duplicate "$PATHONLY/_Folders"
			fi
#		fi
	fi

done

IFS=$SAVEIFS