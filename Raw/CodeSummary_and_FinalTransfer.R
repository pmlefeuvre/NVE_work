

#---------------------------------------------------------------#
#       PROCESS LOAD CELL DATA TO FIT FILE STRUCTURE FOR        #
#           THE PERIOD 1992-2013 AND TRANSFER COMPILED          #
#               FILES TO THE PROCESSING FOLDER                  #
#                                                               #
# NOTES:                                                        #
# - The code loads all raw date and compiles them in:           #
#   > Raw_editting_1992-2013.R                                  #
#   > Raw_merging_1992-2013.R                                   #
# - This code is a conversion of the bash code:                 #
#   > CodeSummary_and_Transfer.sh lasted edited in 2013-10-10   #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2016-04-22 #
#                                       Last Update: 2016-04-22 #
#                                                               #
# Updates:                                                      #
#                                                               #
#---------------------------------------------------------------#

##################################################################
#       PROCESS LOAD CELL DATA TO FIT 1993-2013 SEQUENCE         #
##################################################################
#                                                                # 
#          More details can be found in each bash file           #
#                                                                # 
##################################################################

##########################################
# Clean up Workspace
rm(list = ls(all = TRUE))
##########################################

# Go to the following Path in order to access data files
setwd("/Users/PiM/Desktop/NVE_work/Raw/")
Sys.setenv(TZ="UTC")    

# Load libraries

# Load User Functions

#########################################################################

##           EDITTING 1992-2013             ##
# Call first command file to reorder columns of RAW data from 1992-2013
source("Raw_editting_1992-2013.R")


##      MERGING OF ALL LOAD CELL DATA       ##
# The merging_raw and plot_YEAR need to be compiled separately and in PATH
source("Raw_merging_1992-2013.R")

##  TRANSFER COMPILED DATA TO THE PROCESSING DIRECTORY  ##
dir.create("../Processing/Data",showWarnings = FALSE)
dir.create("../Processing/Data/RawR",showWarnings = FALSE)

for (year in seq(1992,2013)){
file.copy(sprintf("%i/ProcessingR/Compiled_%i.csv",year,year),
          sprintf("../Processing/Data/RawR/LC_%i.csv",year))
}
