
##########################################################################
##              Extract Trends and Short Term Variablilty               ##
##                      FOR INDIVIDUAL YEARS                            ##
##########################################################################

###########################################
# # Clean up Workspace
rm(list = ls(all = TRUE))
###########################################

### Go to the following Path in order to access data files
setwd("/Users/PiM/Desktop/PhD/Data Processing/Load Cells/Processing")
Sys.setenv(TZ="UTC")  

# Load libraries
library(zoo)
library(lattice)
library(signal)

# Load User Functions
source('~/Desktop/PhD/Data Processing/Load Cells/Processing/f_Detrend_all.R')


# Interval
hour        <- 60 #min
day         <- 24 #hours 
# hour.mean   <- c(1,2,4,8,day/2,day,2*day,4*day,6*day)
# hour.coor   <- c(1,2,4,8,day/2,day,2*day,4*day,6*day)

# TIME Windows for Mean and Correlation
win.mean    <- c(4    ,day/2,1*day,4*day)*(hour/15) #15min interval = 4 points per hour
win.corr    <- c(day/2,1*day,2*day,6*day)*(hour/15)

################## INDIVIDUAL YEARS ##################
years <- seq(1993,2013,1)

# # LOOP through Time Windows
# for (n in 1){#:length(win.mean)){
#     
#     print(paste("Win.mean:", win.mean[n]))
#     print(paste("Win.corr:", win.corr[n]))
#     
#     ## Correlation for each year
#     for (k in 1:(length(years)-1)){
#         
#         sub.start=sprintf("01/01/%i 00:00",years[k])
#         # Particular condition for 2013, which ends in May
#         if(years[k]<2013){
#                 sub.end=sprintf("01/01/%i 00:00",years[k+1])
#         }else{  sub.end=sprintf("05/01/%i 00:00",years[k])}
#         
#         print(sprintf("Analysing Corr. between %s & %s",years[k],years[k+1]))
#         
#         LC.reg.sub <- f_Detrend_all(sub.start= sub.start,
#                                     sub.end  = sub.end,
#                                     win.mean[n],win.corr[n])
#     }
# }

################## WHOLE PERIOD ##################
# LOOP through Time Windows
for (n in c(1,3)){#1:length(win.mean)){
    
    print(paste("Win.mean:", win.mean[n]))
    print(paste("Win.corr:", win.corr[n]))
    
    ## Correlation for whole period
    sub.start   <- "11/01/1992 00:00"
    sub.end     <- "05/01/2013 00:00"
    
    print(sprintf("Analysing Corr. between %s & %s","1992","2013"))
    
    LC.reg.sub  <- f_Detrend_all(sub.start= sub.start,
                                 sub.end  = sub.end,
                                 win.mean[n],win.corr[n])
}



# ################## MONTHS ##################
# # Save Output in Log
# sink("Plots/Detrend/Log/Log_Months.txt",append=T,type="output")
# 
# # Time Array
# time.array  <- seq(as.Date("1996-01-01"),as.Date("2013-05-01"),by="2 months")
# lt          <- length(time.array)
# 
# for (i in 53:(lt-1))
# {
#     sub.start   <- format(time.array[i],"%m/%d/%Y %H:%M")
#     sub.end     <- format(time.array[i+1],"%m/%d/%Y %H:%M")
#     
#     # Start Timer to compute Elapsed time
#     ptm <- proc.time()
#     
#     print("-              < + >               -")
#     print("------------------------------------")
#     print(paste("Time Window:",time.array[i],"-",time.array[i+1]))
#     
#     LC.reg.sub <- f_Detrend_all(sub.start= sub.start,
#                                 sub.end  = sub.end,
#                                 win.mean,win.corr)
#     rm(LC.reg.sub)
# }
# 
# # Close Log file
# sink(file = NULL)

##### ARCHIVE

# ######################################################
# win.mean    <- day/2*hour/15 #15min interval = 4 points per hour
# win.corr    <- day  *hour/15
# 
# print(paste("Win.mean:", win.mean))
# print(paste("Win.corr:", win.corr))
# 
# 
# ################## YEARS ##################
# years <- seq(1993,2012,1)
# 
# ## Correlation for each year
# for (k in 1:length(years)){
#     
#     sub.start=sprintf("01/01/%i 00:00",years[k])
#     # Particular condition for 2013, which ends in May
#     if(years[k]<2013){
#         sub.end=sprintf("01/01/%i 00:00",years[k+1])
#     }else{  sub.end=sprintf("05/01/%i 00:00",years[k])}
#     
#     print(sprintf("Analysing Corr. between %s & %s",years[k],years[k+1]))
#     
#     LC.reg.sub <- f_Detrend_all(sub.start= sub.start,
#                                 sub.end  = sub.end,
#                                 win.mean,win.corr)
# }
# 
# ######################################################
# win.mean    <- 1*day*hour/15 #15min interval = 4 points per hour
# win.corr    <- 2*day*hour/15
# 
# print(paste("Win.mean:", win.mean))
# print(paste("Win.corr:", win.corr))
# 
# 
# ################## YEARS ##################
# years <- seq(1993,2012,1)
# 
# ## Correlation for each year
# for (k in 1:length(years)){
#     
#     sub.start=sprintf("01/01/%i 00:00",years[k])
#     # Particular condition for 2013, which ends in May
#     if(years[k]<2013){
#         sub.end=sprintf("01/01/%i 00:00",years[k+1])
#     }else{  sub.end=sprintf("05/01/%i 00:00",years[k])}
#     
#     print(sprintf("Analysing Corr. between %s & %s",years[k],years[k+1]))
#     
#     LC.reg.sub <- f_Detrend_all(sub.start= sub.start,
#                                 sub.end  = sub.end,
#                                 win.mean,win.corr)
# }
# 
# ######################################################
# win.mean    <- 4*day*hour/15 #15min interval = 4 points per hour
# win.corr    <- 6*day*hour/15
# 
# print(paste("Win.mean:", win.mean))
# print(paste("Win.corr:", win.corr))
# 
# 
# ################## YEARS ##################
# years <- seq(1993,2012,1)
# 
# ## Correlation for each year
# for (k in 1:length(years)){
#     
#     sub.start=sprintf("01/01/%i 00:00",years[k])
#     # Particular condition for 2013, which ends in May
#     if(years[k]<2013){
#         sub.end=sprintf("01/01/%i 00:00",years[k+1])
#     }else{  sub.end=sprintf("05/01/%i 00:00",years[k])}
#     
#     print(sprintf("Analysing Corr. between %s & %s",years[k],years[k+1]))
#     
#     LC.reg.sub <- f_Detrend_all(sub.start= sub.start,
#                                 sub.end  = sub.end,
#                                 win.mean,win.corr)
# }
