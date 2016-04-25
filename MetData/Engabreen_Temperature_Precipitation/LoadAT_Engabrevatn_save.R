
#####################################################################
#             Load, Process and Save Air Temperature Data           #
#                           ENGABREVATN                             #
#                                                                   #
# Homogenise time interval and Extract daily values when            #
# observation interval is higher. Also deal with NA values          #
# In the final file, Only HOURLY data are kept                      #
#                                                                   #
# Author: PiM Lefeuvre                          Date: 2014-09-03    #
# Raw Data are resampled to provide regular time series             #
#####################################################################

###########################################
# Clean up Workspace
# rm(list = ls(all = TRUE))
###########################################

# Set Path
setwd(path.wd)
Sys.setenv(TZ="UTC")  

# Load libraries
library(chron)
library(hydroTSM)   # cmd: izoo2rzoo
library(zoo)

# Load User Functions
source("f_Save_AirTemp.R")


#############################################
#### ORIGINAL PROCESSING
# Convert Data into zoo
filename <- "Raw/Engabrevatn_komplet_AirTemp.csv"
Save_AirTdata(filename,path.wd)

#############################################
#### EXTRACT HOURLY VALUES and remove Header
# ReLoad Air Temp. data
filename <- "Data/Engabrevatn_komplet_AirTemp.csv"
zoo.T    <- read.zoo(filename, sep=",",header=TRUE, FUN=as.POSIXct) 
# file.remove(filename)

# Extract Hourly Data
zoo.T    <- cbind(zoo.T[,1])

# Save full dataset in zoo format
filename_out <- "../../Processing/Data/MetData/AirTemp/Engabrevatn_AT_1hr_full.csv"
write.zoo(zoo.T,file=filename_out,sep=",",col.names=F)
