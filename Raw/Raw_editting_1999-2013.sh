#! /usr/bin/env bash

# Author:PiM				         Date:08 Oct. 2013
##################################################################
#       REORDER LOAD CELL DATA TO FIT 1999-2013 SEQUENCE         #
##################################################################
# NOTES:                                                         #
# - The code is adapted to each file found in the Raw Folder     # 
#   is therefore not flexible.                                   #
##        ">>> FILE NOT FOUND >>> *.xls" or with "*.XLS"        ##
# because both types are found, but sometimes only one exist     #
#                                                                #
# Last Update: 11 Apr. 2016                                      #
#  - Cleaned file from old code                                  #
##################################################################


# Define the Path and Directories to analyse
path='/Users/PiM/Desktop/NVE_work/Raw'


# Loop through Directories 
for YEAR in {1999..2013}
do 

    # Define Directory name from $YEAR
    DIR=$YEAR
    # Define Local Path (known file structure) and Processing Folder
    DIR_path="${path}/${DIR}/Raw/"

    # Check Directories exist
    if [[ -d "$DIR_path" ]]
    then 
	cd "$DIR_path"
	echo " "
	echo "----"
	echo "Change Directory to" $DIR
	

	# Loop through Excel Files
	for i in "$DIR_path"/*.dat "$DIR_path"/*.DAT
	do
	    filename=${i##*/}
	    
	    # Check that File Exists
	    if [[ -e "$i" ]]
	    then 

#----------------------------1999-2000-----------------------------------#
# New Order   NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# New Column   1  -  2  -   3   - 4 - 5  - 6 - 7  -  8   -  9   - 10 - "" - "" - 11
		if [[ $YEAR < "2001" ]]
		then
		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
		    awk -F, -v OFS=, '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,"","",$11 }' $filename > ${filename%.*}_ordered.dat
		fi

#---------------------------------2002-------------------------------------#
# New Order   NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# New Column   1  -  2  -   3   - 4 - 5  - 6 - 7  -  8   -  9   - "" - "" - 10 - 11
		if [[ $YEAR == "2002" ]]
		then
		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
		    awk -F, -v OFS=, '{ print $1,$2,$3,$4,$5,$6,$7,$8,$9,"","",$10,$11 }' $filename > ${filename%.*}_ordered.dat
		fi

#------------------------------2001 & 2003----------------------------------#
		case $filename in 
		    ## Transition ##
		    "Mar20001.dat" )	
			echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
			awk -F, -v OFS=, '{ 
                if($2<79) print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,"","",$11;
                if($2==79 && $3<1815) print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,"","",$11;
                if($2==79 && $3>=1815) print $1,$2,$3,$4,$5,$6,$7,$8,$9,"","",$10,$11;
                if($2>79) print $1,$2,$3,$4,$5,$6,$7,$8,$9,"","",$10,$11;
                }' $filename > ${filename%.*}_ordered.dat;;

                   ## 2001 & 2003 ##
# New Order   NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# New Column   1  -  2  -   3   - 4 - 5  - 6 - 7  -  8   -  9   - "" - "" - 10 - 11
		    "Mar30001.dat" | "May28001.dat" | "AUG21001.dat" | "SEP24001.dat" | "DEC3101.dat" | "FEB18001.dat" | "APR02001.dat" )
		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
		    awk -F, -v OFS=, '{ print $1,$2,$3,$4,$5,$6,$7,$8,$9,"","",$10,$11 }' $filename > ${filename%.*}_ordered.dat;;

		   ## Transition ##
		    "MAY03.dat" )
			echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
			awk -F, -v OFS=, '{ 
                if($2<134) print $1,$2,$3,$4,$5,$6,$7,$8,$9,"","",$10,$11;
                if($2==134 && $3<748) print $1,$2,$3,$4,$5,$6,$7,$8,$9,"","",$10,$11;
                if($2==134 && $3>=748) print $1,$2,$3,$4,$5,$6,$7,$8,$9,"","","",$10;
                if($2>134) print $1,$2,$3,$4,$5,$6,$7,$8,$9,"","","",$10;
                }' $filename > ${filename%.*}_ordered.dat;;

                   ##   2003   ##
# New Order   NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# New Column   1  -  2  -   3   - 4 - 5  - 6 - 7  -  8   -  9   - "" - "" - "" - 10
		    "JUL03001.dat" | "SEP28001.dat" | "Nov07.dat" )

			echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
			awk -F, -v OFS=, '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,"","","",$10 }' $filename > ${filename%.*}_ordered.dat;;

                   ##   2003   ##
# New Order   NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# New Column   1  -  2  -   3   - 4 - 5  - 6 - 7  -  8   -  9   - 10 - "" - "" - 11
		    "Nov13.dat" | "MAR24001.dat" )

			echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
			awk -F, -v OFS=, '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,"","",$11 }' $filename > ${filename%.*}_ordered.dat;;
		esac

#-------------------------------2004-2013----------------------------------#
# New Order   NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 12_1 - 12_2 - 7  - 2b - 01 - Battery
# New Column   1  -  2  -   3   - 4 - 5  - 6 - 7  -  8   -  9   - 10 - "" - "" - 11
		if [[ $YEAR > "2003" ]]
		then
		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
		    awk -F, -v OFS=, '{ print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,"","",$11 }' $filename > ${filename%.*}_ordered.dat
		fi




	    [[ ! -d "$DIR_path/Ordered/" ]] && mkdir "$DIR_path/Ordered/"
	    mv ${filename%.*}_ordered.dat "$DIR_path/Ordered/"

	    else 
		echo " >>> FILE NOT FOUND >>>" $filename
	    fi
	done

    else
	echo " "
	echo "----"
	echo ">>> DIRECTORY NOT FOUND:" $DIR_path
	echo "----"

    fi

done

cd ../..


### ARCHIVE ###
