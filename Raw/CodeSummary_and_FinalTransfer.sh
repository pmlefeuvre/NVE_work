#! /usr/bin/env bash

# Author:PiM				         Date:10 Oct. 2013
##################################################################
#       PROCESS LOAD CELL DATA TO FIT 1993-2013 SEQUENCE         #
##################################################################
#                                                                # 
#          More details can be found in each bash file           #
#                                                                # 
##################################################################


##              FIRST 1992-1998               ##
# Call first command file to process RAW data from 1992-1998
. Raw_editting_1992-1998.sh

##              SECOND 1999-2013              ##
# Reorder Raw data to fit the sequence from 1993-1998 
# (same columns for same LC)
. Raw_editting_1999-2013.sh


##           MERGE and PLOT LC data           ##
# The merging_raw and plot_YEAR need to be compiled separately and in PATH
for YEAR in {1992..2013}
do
	merging_raw $YEAR $YEAR
	plot_YEAR $YEAR $YEAR | gnuplot
done


##      LAST (must be entered manually!)      ##
#  Transfer the compiled data to the Processing directory.

# It cannot be done running the following code in the 
# terminal because to write ^M, you need to use CTRL-V CTRL-M. 
# So, you have to copy-paste and manually edit the part ^M.

# Check Directories exist
if [[ ! -d ../Processing ]] 
then 
    echo "Make Processing directory"
    mkdir ../Processing
    mkdir ../Processing/Data
    mkdir ../Processing/Data/Raw
fi

for YEAR in {1992..2013}
do 
    echo "Copy data -- $YEAR -- to Processing Directory"
    sed -e "s/^M//"  $YEAR/Processing/Compiled_$YEAR.csv >  ../Processing/Data/Raw/LC_${YEAR}.csv
done

