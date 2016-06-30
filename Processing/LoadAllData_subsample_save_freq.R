

#---------------------------------------------------------------#
#         LOAD ALL RAW LOAD CELL DATA (i.e. FREQUENCY)          #
#        SAVE FREQUENCY DATA IN FILES OF 2-MONTH PERIOD         #
#                                                               #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2015-04-08 #
#                                       Last Update: 2016-04-25 #
#                                                               #
# Updates:                                                      #
# - 2016-04-25: Add colClasses to loading function              #
#                                                               #
#                                                               #
#---------------------------------------------------------------#

# Detect Operating System (!!! EDIT TO YOUR PATH !!!)
if(.Platform$OS.type == "unix"){   HOME="/Users/PiM/Desktop"}
if(.Platform$OS.type == "windows"){HOME="//nve/fil/h/HB/Personlige mapper/PiM"}

# Go to the following Path in order to access data files
setwd(sprintf("%s/NVE_work/Processing/",HOME))
Sys.setenv(TZ="UTC")    

###########################################
# Clean up Workspace
rm(list = ls(all = TRUE))
###########################################

# Load libraries (!!! NEED TO BE PRE-INSTALLED !!!)
library(zoo)
library(chron)      # cmd: trunc
library(hydroTSM)   # cmd: izoo2rzoo

# Load User Functions
source("../UserFunction/juliandate.R")
source("../UserFunction/subsample.R")
source("../UserFunction/remove_col.R")

# Start Timer to compute Elapsed time
ptm <- proc.time()

print("Loading Load Cell Data")


# Load the Data and combine them
Years       <- seq(2011,2014)#2013
datafile    <- sprintf("Data/PressureData/LC_%i.csv",Years)
colClasses  <- c(rep("character",3),rep("numeric",9)) 
LC_all      <- do.call("rbind",
                       lapply(datafile,
                              function(f) read.csv(f,colClasses=colClasses)))

###########################################################
# Attach names to columns 
attach(LC_all)

# Set up a string with Date and Time
print("Preparing Timestamp")
Dates 		<- strptime(paste(Year,Day,Hour),"%Y %j %H%M");
# Show existing duplicates of date
Dates[duplicated(Dates)]

###########################################################
###                 Date Correction                     ###
###########################################################
# Date delayed by a day from 2012 due to leap year and 
# Corrected in 2014 (file: trykk_aug001.dat)
# 113,79,1346,1.7771,.24756,1.7757,1.6899,1.4582,1.2273,-99999,
# 113,80,1346,1.7774,.24308,1.7756,1.6906,1.4581,1.2696,-99999
# Correction in R +24*3600 (+1day) 

if(any(c(2012,2013,2014) %in% Years)){
    print("Add a day to index of LCs due to delay in datalogger clock From 2012 To 2014")
    corr.t1     <- min(which(Dates>=as.POSIXct("2012-03-18 19:33")))
    corr.t2     <- max(which(Dates<=as.POSIXct("2014-03-20 13:46")))
    Dates[corr.t1:corr.t2]   <- Dates[corr.t1:corr.t2]+24*3600 
}

###########################################################
# Recreate dataframe with the formatted date (Replace Year, Dates & Hours)
lcol        <- ncol(LC_all)
LC_all      <- cbind(Dates,LC_all[,4:lcol])
detach(LC_all)

# Figure out the starting date and the ending date of the whole dataset
daterange 	<- c(as.POSIXlt(min(LC_all$Dates, na.rm = TRUE)), as.POSIXlt(max(LC_all$Dates, na.rm = TRUE)))

cat(sprintf("\n Data Span: from %s \n \t \ \ \ to \t %s \n\n",daterange[1], daterange[2]))


###########################################################
rm(datafile, Dates)
###########################################################
###########################################################

# Conversion of the frequency from kHz into Hz
LC_all$LC6      <- LC_all$LC6[]*1000;
LC_all$LC1e     <- LC_all$LC1e[]*1000;
LC_all$LC4	    <- LC_all$LC4[]*1000;
LC_all$LC2a     <- LC_all$LC2a[]*1000;
LC_all$LC97_2   <- LC_all$LC97_2[]*1000;
LC_all$LC97_1	<- LC_all$LC97_1[]*1000;
LC_all$LC7	    <- LC_all$LC7[]*1000;
LC_all$LC2b     <- LC_all$LC2b[]*1000;
LC_all$LC01     <- LC_all$LC01[]*1000;

# Conversion of -9999 to Not A Number
print("Replacing Data Gaps with NA values")
is.na(LC_all)   <- (LC_all <= -9999)

###########################################################
###########################################################
# Removing non Realistic FREQUENCY converting them in Not A Number
maxF 		<- 4000;
cat(sprintf("Removing non-realistic FREQUENCY values (> %1.0f kHz) \n",maxF))

LC_all$LC6      [ LC_all$LC6  > maxF]	<- NA;
LC_all$LC1e	    [ LC_all$LC1e > maxF] 	<- NA;
LC_all$LC4	    [ LC_all$LC4  > maxF]	<- NA;
LC_all$LC2a     [ LC_all$LC2a > maxF]	<- NA;
LC_all$LC97_2   [ LC_all$LC97_2>maxF]	<- NA;
LC_all$LC97_1	[ LC_all$LC97_1>maxF]	<- NA;
LC_all$LC7      [ LC_all$LC7  > maxF] 	<- NA;
LC_all$LC2b  	[ LC_all$LC2b > maxF] 	<- NA;
LC_all$LC01     [ LC_all$LC01 > maxF] 	<- NA;

# ###
# # Save zero frequencies for each load cell (coming from calibration sheet)
# # Define empty data.frame
# lcol        <- ncol(LC_all)
# f_0         <- data.frame(matrix(NA,2,lcol-1))
# names(f_0)  <- names(LC_all[,2:lcol])
# # Assign manufacturer's zero frequency values
# f_0$LC6     <- 1061.5
# f_0$LC1e    <- 1157.3
# f_0$LC4     <- 1105.0
# f_0$LC2a    <- 1106.0
# f_0$LC97_2  <- c(1191.8,1150.6)
# f_0$LC97_1  <- c(1230.0,1176.0)
# f_0$LC7	  <- c(1115.0,1196.3)
# f_0$LC2b    <- 1178.0
# f_0$LC01    <- 1239.0


# Elapsed time
cat("Elapsed time is",round((proc.time() - ptm)[3]), "sec.","\n")


##############################################################
########    TRANSFORM TIME SERIES INTO ZOO OBJECT     ########
##############################################################

# Convert into zoo object.
lcol         <- ncol(LC_all)
zoo_LC       <- zoo(x=LC_all[2:lcol], order.by=LC_all$Dates)
print("Converting Time Series into Zoo object")

# Aggregate values with same timestamp
# zoo_LC_agg   <- aggregate(zoo_LC,index(zoo_LC),function(x) mean(x,na.rm=TRUE))
zoo_LC_agg   <- aggregate(zoo_LC,index(zoo_LC),mean)

# Print how many values were combined
cat(">>>",ncol(zoo_LC)*(nrow(zoo_LC)-nrow(zoo_LC_agg)),"values were combined with aggregate","\n")

# Elapsed time
print("First Part Completed")
cat("Elapsed time is",round((proc.time() - ptm)[3]), "sec.","\n \n")

# Remove Original data
rm(LC_all, zoo_LC)


########################################################################
#######################   SUB-SAMPLING   ###############################
# Make folder where will be saved the data
dir.create("Data/Zoo",           showWarnings = FALSE)
dir.create("Data/Zoo/Sub1min",   showWarnings = FALSE)
dir.create("Data/Zoo/Sub15med",  showWarnings = FALSE)
dir.create("Data/Zoo/Sub15mean", showWarnings = FALSE)
dir.create("Data/Zoo/Sub_daily", showWarnings = FALSE)

# Sub-sampling (2 MONTHS)
if(Years[1]==1992){
    start<-seq(as.Date("1992-11-01"),
               as.Date(sprintf("%i-12-01",last(Years))),  by="2 months")
    end  <-seq(as.Date("1993-01-01"),
               as.Date(sprintf("%i-01-01",last(Years)+1)),by="2 months")
}else {
    start<-seq(as.Date(sprintf("%i-01-01",Years[1])),
               as.Date(sprintf("%i-12-01",last(Years))),  by="2 months")
    end  <-seq(as.Date(sprintf("%i-03-01",Years[1])),
               as.Date(sprintf("%i-01-01",last(Years)+1)),by="2 months")
}

for (i in 1:length(start)) {
    
    # Intitialise Time Period
    sub.start   <- juliandate(start[i])
    sub.end     <- juliandate(end[i])
    
    cat("\n","Subsampling of the LC Frequency time series from",sub.start,"to",sub.end,"\n")
    
    sub_zoo_LC      <- subsample(zoo_LC_agg,sub.start,sub.end,F)
    ########################################################################
    ########################################################################
    
    
    ########################################################################
    ####################  REGURLARLY SPACED ZOO  ###########################
    print("Conversion into a regularly spaced object")
    
    # Start Timer to compute Elapsed time
    ptm                 <- proc.time()
    
    # Filenames
    filename_1min  <-paste("Data/Zoo/Sub1min/Zoo_LCallfreq_min_",
                           sub.start,"_",sub.end,".csv",sep='')
    filename_15med <-paste("Data/Zoo/Sub15med/Zoo_LCallfreq_15min_med_",
                           sub.start,"_",sub.end,".csv",sep='')
    filename_15mean<-paste("Data/Zoo/Sub15mean/Zoo_LCallfreq_15min_mean_",
                           sub.start,"_",sub.end,".csv",sep='')
    filename_daily <-paste("Data/Zoo/Sub_daily/Zoo_LCallfreq_day_med_",
                           sub.start,"_",sub.end,".csv",sep='')
    
    ### Select one column and converts it into a regularly spaced zoo object (inserting NAs when there is no data)
    # 1 min interval
    #---------------
    print("Proceed to one minute interval")
    LC_reg_min          <- izoo2rzoo(sub_zoo_LC,from=as.POSIXct(start[i]),
                                     to=as.POSIXct(end[i])-60,
                                     date.fmt="%Y-%m-%d %H:%M:%S", tstep="min")
    
    # Save data in zoo format
    write.zoo(LC_reg_min,file=filename_1min,sep=",")
    rm(sub_zoo_LC)
    
    # 15 min interval
    #----------------
    #To create a continuous time series at 15min interval, I have to truncate the original index of the zoo to every 15 min. For that I convert the zoo dates in chron to be able to use the trunc function, which can deal with sub-hourly interval. Then, I reconvert in POSIXct and apply aggregate.
    
#     #-- MEDIAN
#     print("Proceed to 15 minutes interval (Median)")
#     LC_reg_15min_med    <- aggregate(LC_reg_min,as.POSIXct(trunc(as.chron(index(LC_reg_min)),units="00:15:00")),function(x) median(x,na.rm=TRUE))
#     
#     # Save data in zoo format
#     write.zoo(LC_reg_15min_med,file=filename_15med,sep=",")
#     rm(LC_reg_15min_med)
    
    #-- MEAN
    print("Proceed to 15 minutes interval (Mean)")
    LC_reg_15min_mean   <- aggregate(LC_reg_min,as.POSIXct(trunc(as.chron(index(LC_reg_min)),units="00:15:00")),function(x) mean(x,na.rm=TRUE))
    
    # Save data in zoo format
    write.zoo(LC_reg_15min_mean,file=filename_15mean,sep=",")
    rm(LC_reg_15min_mean)
    
    
    # 1 day interval
    #---------------
    print("Proceed to one day interval")
    LC_reg_day          <- aggregate(LC_reg_min,as.POSIXct(trunc(index(LC_reg_min),units="days")),function(x) median(x,na.rm=TRUE))
    
    # Save data in zoo format
    write.zoo(LC_reg_day,file=filename_daily,sep=",")
    rm(LC_reg_day)
    
    # Elapsed time
    cat("Elapsed time is",round((proc.time() - ptm)[3]), "sec.","\n")
}




