
#########################################################################
#         Load and Save Air Temperature/Precipitation Data from         #
#                      - Glomfjord      (eKlima)                        #
#                      - Reipaa         (eKlima)                        #
#                      - Skjaeret       (NVE)                           #
#                      - Engabrevatn    (NVE)                           #
#                                                                       #
# install.packages("chron","zoo","hydroTSM")                            #
#                                                                       #
# Author: Pim Lefeuvre                              Date: 2014-09-03    #
#########################################################################

###########################################
# # Clean up Workspace
rm(list = ls(all = TRUE))
###########################################

# !! HAS TO BE ENTERED MANUALLY!!
# !! HAS TO BE ENTERED MANUALLY!!
# Set Path -- "path.wd" is the path to the Working Directory 
# !! HAS TO BE ENTERED MANUALLY!!
# !! HAS TO BE ENTERED MANUALLY!!
# Detect Operating System
if(.Platform$OS.type == "unix"){   HOME="/Users/PiM/Desktop"}
if(.Platform$OS.type == "windows"){HOME="//nve/fil/h/HB/Personlige mapper/PiM"}

# Go to the following Path in order to access data files
path.wd <- sprintf("%s/NVE_work/MetData/Engabreen_Temperature_Precipitation",HOME) 
setwd(path.wd)
Sys.setenv(TZ="UTC")  

# Load libraries
library(zoo)
library(chron)
library(lubridate) # cmd: year

# Load User functions
source("f_Save_AirTemp.R")

# Make folder where will be saved the data
dir.create("Plots/",showWarnings = FALSE)
dir.create("Data/", showWarnings = FALSE)
dir.create("../../Processing/Data/MetData/",       showWarnings = FALSE)
dir.create("../../Processing/Data/MetData/AirTemp",showWarnings = FALSE)
dir.create("../../Processing/Data/MetData/Precip", showWarnings = FALSE)


# Load Air Temeprature
print("                 --                    ")
print("PROCESSING: Air Temperature - Glomfjord")
print("                 --                    ")
source("LoadAT_Glomfjord_save.R")

print("                 --                 ")
print("PROCESSING: Air Temperature - Reipaa")
print("                 --                 ")
source("LoadAT_Reipaa_save.R")

print("                 --                   ")
print("PROCESSING: Air Temperature - Skjaeret")
print("                 --                   ")
source("LoadAT_Skjaeret_save.R")

print("                 --                      ")
print("PROCESSING: Air Temperature - Engabrevatn")
print("                 --                      ")
source("LoadAT_Engabrevatn_save.R")

# Load Precipiation and output only daily
print("                 --                 ")
print("PROCESSING: Precipitation - Glomjord")
print("                 --                 ")
source("LoadPP_Glomfjord_Daily_save.R")

print("                 --               ")
print("PROCESSING: Precipitation - Reipaa")
print("                 --               ")
source("LoadPP_Reipaa_Daily_save.R")




