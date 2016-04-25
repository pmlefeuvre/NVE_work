#! /usr/bin/env bash

# Author:PiM				         Date:15 Oct. 2013
##################################################################
#       REORDER LOAD CELL DATA TO FIT 1993-1998 SEQUENCE         #
##################################################################
# NOTES:                                                         #
# - The code is adapted to each file found in the Raw Folder     # 
#   is therefore not flexible.                                   #
##        ">>> FILE NOT FOUND >>> *.xls" or with "*.XLS"        ##
# because both types are found, but sometimes only one exist     #
#                                                                #
# Last Update: 11 Apr. 2016                                      #
#  - Cleaned file from old code and clarify change of column     #
#    for LC7 and LC2b ! I can't remember why I have swapped      #
#    the two for some periods/files                              #
##################################################################


# Define the Path and Directories to analyse
path='/Users/PiM/Desktop/NVE_work/Raw'


# Loop through Directories 
for YEAR in {1992..1998}
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

#-------------------------------1992-1993-----------------------------------#
		if [[ $YEAR == "1992" || $YEAR == "1993" ]]
		then
		    case $filename in 

# Order      Year-DoY-Hr:Mn-Battery-LoggerTemp.- 4 - 6 - 2a - 2b - 7  - 1e
# Column  1  - 2 - 3 -  4  -   5   -    6      - 7 - 8 -  9 - 10 - 11 - 12
# New Order    NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# New Column    2  -  3  -   4   - 8 - 12 - 7 -  9 -  ""  -  ""  - 11 - 10 - "" -  5
			"data001.dat"|"data002.dat"|"data003.dat"|"data004.dat"|"data005.dat"|"data006.dat"|"data007.dat"|"data008.dat"|"data009.dat"|"data010.dat"|"data011.dat"|"data012.dat"|"data013.dat"|"data015.dat"|"data016.dat"|"data017.dat"|"data018.dat"|"data019.dat"|"data020.dat"|"data021.dat"|"data022.dat"|"data023.dat"|"data024.dat"|"data025.dat"|"data026.dat"|"data027.dat"|"data028.dat"|"data032.dat"|"data040.dat")
			
		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
		    awk -F, -v OFS=, '{print $2,$3,$4,$8,$12,$7,$9,"","",$11,$10,"",$5}' $filename > ${filename%.*}_ordered.dat;;

	
# Order       Year-DoY-Hr:Mn- 4 - 6 - 2a - 2b - 7 - 1e
# Column   1  - 2 - 3 -  4  - 5 - 6 - 7  - 8 -  9 - 10
# New Order    NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# Column        2  -  3  -   4   - 6 - 10 - 5 - 7  -  ""  -  ""  - 9  - 8  - "" -  ""
			"data041.dat"|"data042.dat"|"data043.dat"|"data044.dat"|"data045.dat"|"data046.dat"|"data047.dat")
		      
		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
		    awk -F, -v OFS=, '{print $2,$3,$4,$6,$10,$5,$7,"","",$9,$8,"","" }' $filename > ${filename%.*}_ordered.dat;;
					

# Order        DoY-Hr:Mn- 4 - 6 - 2a - 2b - 7 - 1e
# Column   1  - 2 -  3  - 4 - 5 - 6  - 7  - 8 -  9 
# New Order    NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# New Column    1  -  2  -   3   - 5 - 9  - 4 - 6  -  ""  -  ""  - 8  - 7  - "" -  ""
			"data048.dat"|"data049.dat"|"data051.dat"|"data053.dat"|"data054.dat"|"data055.dat"|"data057.dat"|"data058.dat"|"data060.dat"|"data061.dat"|"data062.dat"|"data070.dat"|"data071.dat")
		      
		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
		    awk -F, -v OFS=, '{print $1,$2,$3,$5,$9,$4,$6,"","",$8,$7,"","" }' $filename > ${filename%.*}_ordered.dat;;

		    esac
		fi

							
#-------------------------------1994-1995-----------------------------------#
		if [[ $YEAR == "1994" || $YEAR == "1995" ]]
		then
		    case $filename in             #(for 089 & 090  - for 91-95)
# Order        DoY-Hr:Mn- 7 - 1e - 2b - 2a - 4 - 6 ( - LoggerTemp. - Battery  )
# Column   1  - 2 -  3  - 4 - 5  - 6  - 7  - 8 - 9 ( -     10     -     11    )
# New Order    NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# New Column    1  -  2  -   3   - 9 - 5  - 8 - 7  -  ""  -  ""  - 4  - 6  - "" -  $11
			"data080.dat"|"data081.dat"|"data083.dat"|"data085.dat"|"data086.dat"|"data087.dat"|"data088.dat"|"data089.dat"|"data090.dat"|"data091.dat"|"data092.dat"|"data093.dat"|"data094.dat"|"data095.dat")
		      
		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
		    awk -F, -v OFS=, '{print $1,$2,$3,$9,$5,$8,$7,"","",$4,$6,"",$11 }' $filename > ${filename%.*}_ordered.dat;;


# Order        DoY-Hr:Mn- 2a - 2b - 1e - 7 - 6 - 4 -Battery-LoggerTemp.
# Column   1  - 2 -  3  - 4  - 5  - 6  - 7 - 8 - 9 -  10   -    11
# New Order    NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# Column        1  -  2  -   3   - 8 - 6  - 9 - 4  -  ""  -  ""  - 7  - 5  - "" -  10
			"data096.dat"|"data097.dat"|"data098.dat")
		      
		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
		    awk -F, -v OFS=, '{print $1,$2,$3,$8,$6,$9,$4,"","",$7,$5,"",$10 }' $filename > ${filename%.*}_ordered.dat;;
		    esac
		fi

#-------------------------------1996-1997-----------------------------------#
		if [[ $YEAR == "1996" || $YEAR == "1997" ]]
		then
		    case $filename in 
# Order        DoY-Hr:Mn- 6 - 1e - 4 - 2b - 2a - ?? -Battery-LoggerTemp
# Column   1  - 2 -  3  - 4 - 5  - 6 - 7  - 8  - 9  -   10  -   11
# New Order    NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# Column        1  -  2  -   3   - 4 - 5  - 6 - 8  -  ""  -  ""  - "" - 7  - "" -  ""
			"DAT97_01.DAT"|"DAT97_02.DAT"|"DAT97_03.DAT"|"DAT97_04.DAT"|"DAT97_05.DAT"|"DAT97_06.DAT"|"DAT97_07.DAT"|"DAT97_08.DAT"|"DAT97_09.DAT"|"DAT97_10.DAT"|"DAT97_11.DAT")
		      
		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
		    awk -F, -v OFS=, '{print $1,$2,$3,$4,$5,$6,$8,"","","",$7,"",$10 }' $filename > ${filename%.*}_ordered.dat;;


# Order        DoY-Hr:Mn- 6 - 1e - 4 - 2b - 2a - 97_2 - 97_1 -Battery-LoggerTemp
# Column   1  - 2 -  3  - 4 - 5  - 6 - 7  - 8  -  9   -  10  -  11   -    12
# New Order    NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# New Column    1  -  2  -   3   - 4 - 5  - 6 - 8  -  9   -  10  - "" - 7  - "" -  11
			"DAT97_12.DAT"|"DAT97_13.DAT")
		      
		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
		    awk -F, -v OFS=, '{print $1,$2,$3,$4,$5,$6,$8,$9,$10,"",$7,"",$11 }' $filename > ${filename%.*}_ordered.dat;;


# Order        DoY-Hr:Mn- 6 - 1e - 4 - 2b - 2a - 97_1 -25barPT-10barPT
# Column   1  - 2 -  3  - 4 - 5  - 6 - 7  - 8  -  9   -  10   -  12
# New Order    NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# New Column    1  -  2  -   3   - 4 - 5  - 6 - 8  -  ""  -  9   - "" - 7  - "" -  ""
			"DAT97_14.DAT")
		      
		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
		    awk -F, -v OFS=, '{print $1,$2,$3,$4,$5,$6,$8,"",$9,"",$7,"","" }' $filename > ${filename%.*}_ordered.dat;;


# Order        DoY-Hr:Mn- 6 - 1e - 4 - 2b - 2a - 97_2 - 97_1 -25barPT-10barPT-Battery-LoggerTemp
# Column   1  - 2 -  3  - 4 - 5  - 6 - 7  - 8  -  9   -  10  -  11   -  12   -  13   -    14 
# New Order    NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# New Column    1  -  2  -   3   - 4 - 5  - 6 - 8  -  9   -  10  - "" - 7  - "" -  13
			"DAT97_15.DAT"|"DAT97_16.DAT"|"DAT97_17.DAT"|"DAT97_18.DAT"|"DAT98001.dat")
		      
		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
		    awk -F, -v OFS=, '{print $1,$2,$3,$4,$5,$6,$8,$9,$10,"",$7,"",$13 }' $filename > ${filename%.*}_ordered.dat;;

		    esac
		fi

#----------------------------------1998--------------------------------------#
		if [[ $YEAR == "1998" ]]
		then
		    case $filename in
# Order        DoY-Hr:Mn- 6 - 1e - 4 - 2b - 2a - 97_2 - 97_1 -25barPT-10barPT-Battery
# Column   1  - 2 -  3  - 4 - 5  - 6 - 7  - 8  -  9   -  10  -  11   -  12   -  13    
# New Order    NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# New Column    1  -  2  -   3   - 4 - 5  - 6 - 8  -  9   -  10  - "" - 7  - "" -  13
			"DAT98001.dat"|"DAT98002.dat"|"DAT98003.dat"|"DAT98004.dat"|"DAT98005.dat"|"DAT98006.dat"|"DAT98007.dat"|"DAT98008.dat"|"DAT98009.dat"|"DAT98010.dat"|"DAT98011.dat"|"DAT98012.dat"|"DAT98013.dat"|"DAT98014.dat"|"DAT98015.dat"|"DAT98016.dat")

		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat
		    awk -F, -v OFS=, '{print $1,$2,$3,$4,$5,$6,$8,$9,$10,"",$7,"",$13 }' $filename > ${filename%.*}_ordered.dat;;


# Order        DoY-Hr:Mn- 6 - 1e - 4 - 2b - 2a - 97_2 - 97_1 -Battery
# Column   1  - 2 -  3  - 4 - 5  - 6 - 7  - 8  -  9   -  10  -  11    
# New Order    NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# New Column    1  -  2  -   3   - 4 - 5  - 6 - 8  -  9   -  10  - "" - 7  - "" -  11
			"DAT98017.dat"|"DAT98018.dat"|"DAT98019.dat"|"DAT98020.dat")

		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat 
		    awk -F, -v OFS=, '{print $1,$2,$3,$4,$5,$6,$8,$9,$10,"",$7,"",$13 }' $filename > ${filename%.*}_ordered.dat;;

# Already Done NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# New Column    1  -  2  -   3   - 4 - 5  - 6 - 7  -  8   -  9   - "" - ""  - "" -  11
			"CompiledXLS_1998.dat")

		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat 
		    cat $filename | sed 's/://g' > ${filename%.*}_ordered.dat;;


# Order in file      DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - ?? -Battery
# Column        1  -  2  -   3   - 4 - 5  - 6 - 7  -  8   -  9   - 10 -  11    
# New Order    NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
# New Column    1  -  2  -   3   - 4 - 5  - 6 - 7  -  8   -  9   - "" - ""  - "" -  11
			"Data99_01.dat")

		    echo "Converting:" $filename " -> " ${filename%.*}_ordered.dat 
		    awk -F, -v OFS=, '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,"","","",$13 }' $filename > ${filename%.*}_ordered.dat;;

		    esac
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



### ARCHIVE
