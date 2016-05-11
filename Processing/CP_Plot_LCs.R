#---------------------------------------------------------------#
#         CONTROL PANEL TO PLOT LOAD CELL TIME SERIES           #
#                                                               #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2016-05-09 #
#                                       Last Update: 2016-05-09 #
#                                                               #
#---------------------------------------------------------------#

# ##########################################
# # Clean up Workspace
rm(list = ls(all = TRUE))
# # Save "par" default
def.par <- par(no.readonly = TRUE)
# ##########################################

# Detect Operating System
if(.Platform$OS.type == "unix"){   HOME="/Users/PiM/Desktop"}
if(.Platform$OS.type == "windows"){HOME="//nve/fil/h/HB/Personlige mapper/PiM"}

# Go to the following Path in order to access data files
setwd(sprintf("%s/NVE_work/Processing/",HOME))
Sys.setenv(TZ="UTC")      

# Load library
source("f_Plot_LCs.R")

# Variables
LCname      <- "LC7"#c("LC01","LC1e","LC2a","LC2b","LC4","LC6","LC97_1","LC97_2")

for (year in seq(1992,2015)){
    
    for (i in seq(1:length(LCname))){
        
        try(Plot_LCs_Pressure(sprintf("%i-01-01",year),
                              sprintf("%i-01-01",year+1),
                              LCname[i],type="15min_mean",f.plot=T))
        
    } 
    
}

