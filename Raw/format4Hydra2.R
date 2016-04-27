
#---------------------------------------------------------------#
#       REFORMAT LOAD CELL DATA FOR TRANSFER TO HYDRA 2         #
#                                                               #
# NOTES:                                                        #
# - INPUT: Compiled Frequency data for each year                #
# - LOOP through each year and EXTRACT time and data for each   #
#   load cell and each year.                                    #
# - Reformat time from "%Y,%j,%H%M" to "%Y%m%d/%H%M"            #
# - Remove empty lines for each load cell                       #
# - Change NaN values from -99999 to -9999                      #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2016-04-11 #
#                                       Last Update: 2016-04-27 #
#                                                               #
# Updates:                                                      #
# - 2016-04-02: Replace individual load cell codes by a loop    #
#               Change output directory from Sample to Hydra2   #
# - 2016-04-27: Convert bash code into a R routine              #
#                                                               #
#---------------------------------------------------------------#

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
