#!/bin/bash
###############################################################################
# @author Radu Cotescu                                                        #
# @version 1.0 Wed Jan 27 14:57:34 EET 2010                                   #
#                                                                             #
# This script will help you remove all Thumbs.db files from a folder path if  #
# you are using a Linux machine with access to folders shared with Windows    #
# clients.                                                                    #
#                                                                             #
# Thumbs.db is a system file generated automatically by Windows OS when you   #
# view the contents of a folder in “Thumbnail” or “Filmstrip” view. Thumbs.db #
# contains a copy of each of the tiny preview images generated for image      #
# files in that folder so that they load up quickly the next time you browse  #
# that folder. Thumbs.db also stores your settings with regard to thumbnail   #
# and filmstrip view.                                                         #
#                                                                             #
# To disable the mechanism that creates these files check off the checkbox    #
# in front of "Do not cache thumbnails" from Windows' Folder Options.         #
###############################################################################

MAXDEPTH="5"
ARGS="$@"
PATHS=""
LOG="0"
SCRIPT_NAME="$0"

usage_text() {
	echo "This script will help you remove all Thumbs.db files from a folder"
	echo "path if you are using a Linux machine with access to folders shared"
	echo "with Windows clients."
	echo -e "Usage:\n ./cleanThumbs.sh [maxdepth] [-log] [PATH(S)]\n"
	echo "where:"
	echo -e "\tmaxdepth \t an integer which specifies the maximum depth for"
	echo -e "\t\t\t searching files inside the PATH(S); set to 5 by default"
	echo -e "\t-log \t\t if specified will write a log containing the files"
	echo -e "\t\t\t removed in `basename $SCRIPT_NAME .sh`.log"
	echo -e "\tPATH(S) \t the PATH or the list of PATHS to be searched for"
	echo -e "\t\t\t Thumbs.db files; by default it's the current folder"
	echo "Parameters can be supplied in any order."
}

usage() {
	code=0
	if [[ "$1" ]]; then
		echo "Error: $1"
		code=1
	fi
	usage_text
	exit $code
}

analize_args() {
    check=0
    for param in $ARGS
    do
        case $param in
        *[0-9])
            if [[ $check -eq "0" ]]; then
                MAXDEPTH=$param
                check=1
            else
                usage "You supplied multiple integers although only one is needed for setting the depth!"
            fi
        ;;
        "-log")
            LOG=1
        ;;
		"-h" | "--help")
			usage
		;;
        *)
           if [[ -e $param ]]; then
                PATHS="$PATHS $param"
           fi
        ;;
        esac 
    done 
}

seek_and_destroy() {
	if [[ $PATHS ]]; then
		echo "Looking in: $PATHS"
	else
		echo "Looking in: current folder"
	fi
	echo "MAXDEPTH: $MAXDEPTH"
    find $PATHS -maxdepth $MAXDEPTH -name 'Thumbs.db' -ls | awk '{ for (i=11; i<NF; i++) {printf("%s ", $i);} printf("%s", $NF); printf("\n"); }' >> files.txt
	n=1
    while read LINE ; do
		if [[ $LOG -eq "1" ]]; then
                echo "$n. Removed: $LINE" >> cleanThumbs.log
            else
                echo "$n. Removed: $LINE"
        fi
        rm "$LINE"
		n=$((n+1))
    done < files.txt
	rm files.txt
}

rm -f cleanThumbs.log
analize_args
seek_and_destroy
exit 0
