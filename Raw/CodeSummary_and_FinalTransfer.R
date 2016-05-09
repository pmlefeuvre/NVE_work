

#---------------------------------------------------------------#
#       PROCESS LOAD CELL DATA TO FIT FILE STRUCTURE FOR        #
#           THE PERIOD 1992-2016 AND TRANSFER COMPILED          #
#               FILES TO THE PROCESSING FOLDER                  #
#                                                               #
# NOTES:                                                        #
# - The code loads all raw date, reorders and compiles them in: #
#   > Raw_editing_1992-2016.R                                  #
#   > Raw_merging_1992-2016.R                                   #
# - This code is a conversion of the bash code:                 #
#   > CodeSummary_and_Transfer.sh lasted edited in 2013-10-10   #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2016-04-22 #
#                                       Last Update: 2016-05-06 #
#                                                               #
# Updates:                                                      #
# - 2016-05-06: Edit text                                       #
#                                                               #
#---------------------------------------------------------------#


##########################################
# Clean up Workspace
rm(list = ls(all = TRUE))
##########################################

# Detect Operating System
if(.Platform$OS.type == "unix"){   HOME="/Users/PiM/Desktop"}
if(.Platform$OS.type == "windows"){HOME="//nve/fil/h/HB/Personlige mapper/PiM"}

# Go to the following Path in order to access data files
setwd(sprintf("%s/NVE_work/Raw/",HOME))
Sys.setenv(TZ="UTC")        

# Load libraries

# Load User Functions

#########################################################################

# VARIABLE: Which year to process (can be an array of years)
year=2014 #seq(1992,2015)

##     REORDER LOAD CELL DATA (Columns) TO FIT DEFINED SEQUENCE     ##
source("Raw_editing.R")
Raw_editing(year)


##      MERGE ALL FILES WITH LOAD CELL DATA PER YEAR      ##
source("Raw_merging.R")
Raw_merging(year)


##      FORMAT THE COMPILED RAW DATA TO THE HYDRA II FORMAT     ##
source("format4Hydra2.R")
format4Hydra2(year)


##  TRANSFER COMPILED DATA TO THE PROCESSING DIRECTORY  ##
dir.create("../Processing/Data",showWarnings = FALSE)
dir.create("../Processing/Data/RawR",showWarnings = FALSE)

for (year.cp in year){
file.copy(sprintf("%i/ProcessingR/Compiled_%i.csv",year.cp,year.cp),
          sprintf("../Processing/Data/RawR/LC_%i.csv",year.cp),
          overwrite = TRUE)
}







###### ARCHIVE 



