#!bin/bash
# Steve Ward
# 2018-03-20

# USAGE: bash ~/Dropbox/BASH Scripts/housekeep-reverse.sh YYYYMMDD
# Where  `YYYYMMDD` is the date the files/folders were moved and forms part of the symbolic link name i.e. testA.sh {20180318-010506}.

oldifs="$IFS"
IFS=$'\n'

# ~/Desktop/temp.tmp contains housekeep*.log for relevant day i.e.
# [18-03-2018 01:05:06] MOVED FILE /Users/steve/Desktop/Desktop Filing/testA.sh TO /Users/steve/Desktop/Desktop Filing/_Source/testA.sh
files=($(sed -n -e 's/^.*TO //p' < ~/Desktop/temp.tmp))

i=0
for f in "${files[@]}"; do

	filename=$(basename "${f}" )

	if [ -f "${f}" ]; then
		#echo $filename

		echo "${f}"
		echo "${filename}"

		mv "${f}" ~/Downloads/_HOUSEKEEP/Files/

		link=$(ls ~/Sundry/Housekeep\ Links/*"${filename}"* 2>/dev/null)
		if [ $? -eq 0 ]; then
			echo "${link}"
			mv "${link}" ~/Downloads/_HOUSEKEEP/Links/
		else
			touch ~/Downloads/_HOUSEKEEP/Links/LINK-"${filename}".NOT-FOUND
		fi

	else
		touch ~/Downloads/_HOUSEKEEP/Files/FILE-"${filename}".NOT-FOUND
	fi




	# Move file/folder back to ~/Desktop/Desktop Filing
	#mv "$f" ~/Desktop/Desktop\ Filing/
	#mv "$f" ~/Downloads/
	((i++))
done
echo $i


#i=0
#for f in /Users/steve/Sundry/Housekeep\ Links/*; do
#	if [[ "$f" =  *"{$1-"* ]]; then
#		echo "$f"
#		# Delete the symbolic link to the file/folder based on creation date i.e.
#		# ~/Desktop/Housekeep Links/testA.sh {20180318-010506}
#		#rm -f "$f"
#		mv "$f" ~/Downloads/_housekeep-reverse
#		((i++))
#	fi
#done
#echo $i

IFS="$oldifs"
