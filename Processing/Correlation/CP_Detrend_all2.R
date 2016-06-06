
#---------------------------------------------------------------#
#           Apply RUNNING CORRELATION on RAW LC DATA            #
#       between load cell LC6 and ALL THE OTHER LOAD CELLS      #
#               FOR THE WHOLE LC PERIOD 1992-2015               #
#                 (No DETRENDING of LC data)                    # 
#                                                               #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2014-08-28 #
#                                       Last Update: 2016-05-31 #
#                                                               #
# Updates:                                                      #
# - 2016-05-31: Updated and simplified                          #
#                                                               #
# Formerly called "CP_Detrend_all2.R"                            #
#---------------------------------------------------------------#


##########################################
# Clean up Workspace
rm(list = ls(all = TRUE))
# Save "par" default
def.par <- par(no.readonly = TRUE)
##########################################

# Detect Operating System
if(.Platform$OS.type == "unix"){   HOME="/Users/PiM/Desktop"}
if(.Platform$OS.type == "windows"){HOME="//nve/fil/h/HB/Personlige mapper/PiM"}

# Go to the following Path in order to access data files
setwd(sprintf("%s/NVE_work/Processing/",HOME))
Sys.setenv(TZ="UTC")  

# Load libraries
library(zoo)
library(lattice)
library(signal)
library(lubridate) # cmd: year

# Load User Functions
source('Correlation/f_Detrend_all2.R')

# Interval
hour        <- 60 #min
day         <- 24 #hours 
hour.mean   <- c(1,2,4,8,day/2,day,2*day,4*day,6*day)
hour.corr   <- c(1,2,4,8,day/2,day,2*day,4*day,6*day)

# TIME Windows for Mean and Correlation #15min interval = 4 points per hour
win.corr    <- hour.corr*(hour/15)

################## WHOLE PERIOD ##################
# LOOP through Time Windows n=6 if daily window
for (n in 6){#1:length(win.mean)){
    
    print(paste("Win.corr:", win.corr[n]))
    
    ## Correlation for whole period
    sub.start   <- "1992-11-01"
    sub.end     <- "2015-01-01"
    
    print(sprintf("Analysing Corr. between %s & %s",
                  year(as.POSIXct(sub.start)),year(as.POSIXct(sub.end)) ))
    
    LC.reg.sub  <- f_Detrend_all2(sub.start= sub.start,
                                 sub.end  = sub.end,
                                 win.corr[n])
}

##### ARCHIVE

