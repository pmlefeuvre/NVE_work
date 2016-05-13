

#---------------------------------------------------------------#
#         LOAD ALL RAW LOAD CELL DATA (i.e. FREQUENCY)          #
#     CONVERT FREQUENCY INTO PRESSURE BASED ON CALIBRATION      #
#         SAVE PRESSURE DATA IN FILES OF 2-MONTH PERIOD         #
#                                                               #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2015-04-08 #
#                                       Last Update: 2016-05-06 #
#                                                               #
# Updates:                                                      #
# - 2016-04-12: Reformat to give code to NVE                    #
#       Add title and remove useless code. Simplify Time(Hour)  #
#       conversion by removing floor and round code to use      #
#       instead sprintf that adds a 0 to have 4 numbers aligned #
#       - The result is much much faster.                       #
#                                                               #
# - 2016-04-25: Add colClasses to loading function              #
# - 2016-05-06: Edit handling of years so that individual years #
#               can be processed instead of processing the whole#
#               period again when another year is added.        #  
#                                                               #
# Formerly called "LoadAllData_subsample_save2.R", inherited    #
# from "LoadAllData.R" and "LoadAllData_save.R" (no subsampling)#
#---------------------------------------------------------------#

# Detect Operating System
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
datafile    <- sprintf("Data/RawR/LC_%i.csv",Years)
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

print("Computing Subglacial Pressure in bar")
# Conversion from frequencies (Hz) to Pressure (bars)
LC_all$LC6      <- -0.0000092248*(1061.5^2 - LC_all$LC6^2)  + (-0.32476);
LC_all$LC1e     <-  0.0334466*(LC_all$LC1e   - 1157.3)+ 0.0000178058* (LC_all$LC1e   - 1157.3)^2 ;
LC_all$LC4      <- -0.0000090465*(1105.0^2 - LC_all$LC4^2)  + (-0.31762);
LC_all$LC2a	    <- -0.0000090971*(1106.0^2 - LC_all$LC2a^2) + (-0.32367);
LC_all$LC2b     <-  0.0304178*(LC_all$LC2b   - 1178.0)  + 0.0000156223* (LC_all$LC2b - 1178.0)^2;
LC_all$LC01     <-  0.0359029*(LC_all$LC01   - 1239.0)  + 0.0000170723* (LC_all$LC01 - 1239.0)^2;

###########################################################
###             Load Cell Replacement                   ###
###########################################################
######### LC97_1 and LC97_2 #########
lt              <- length(LC_all$Dates)
if(2012 %in% Years){
    t97.t12         <- which(LC_all$Dates==as.POSIXct("2012-84 17:59",format="%Y-%j %H:%M"))
    ## Downstream Load Cell: LC97_2 replaced by LC12_1
    LC_all$LC97_2[1:t97.t12] <- 0.0352708*(LC_all$LC97_2[1:t97.t12]  - 1191.8) + 0.0000168821*(LC_all$LC97_2[1:t97.t12] - 1191.8)^2;
    LC_all$LC97_2[t97.t12:lt]<- 0.0365852*(LC_all$LC97_2[t97.t12:lt] - 1150.6) + 0.0000153525*(LC_all$LC97_2[t97.t12:lt]- 1150.6)^2;
    ## Upstream Load Cell:   LC97_1 replaced by LC12_2
    LC_all$LC97_1[1:t97.t12] <- 0.0373280*(LC_all$LC97_1[1:t97.t12]  - 1230.0) + 0.0000181262*(LC_all$LC97_1[1:t97.t12] - 1230.0)^2;
    LC_all$LC97_1[t97.t12:lt]<- 0.0361260*(LC_all$LC97_1[t97.t12:lt] - 1176.0) + 0.0000164113*(LC_all$LC97_1[t97.t12:lt]- 1176.0)^2;
    
}else if(last(Years)<2012){
    ## Downstream Load Cell: LC97_2
    LC_all$LC97_2 <- 0.0352708*(LC_all$LC97_2 - 1191.8) + 0.0000168821*(LC_all$LC97_2 - 1191.8)^2;
    ## Upstream Load Cell:   LC97_1
    LC_all$LC97_1 <- 0.0373280*(LC_all$LC97_1 - 1230.0) + 0.0000181262*(LC_all$LC97_1 - 1230.0)^2;
    
}else if(Years[1]>2012){
    ## Downstream Load Cell: LC97_2 replaced by LC12_1
    LC_all$LC97_2 <- 0.0365852*(LC_all$LC97_2 - 1150.6) + 0.0000153525*(LC_all$LC97_2 - 1150.6)^2;
    ## Upstream Load Cell:   LC97_1 replaced by LC12_2
    LC_all$LC97_1 <- 0.0361260*(LC_all$LC97_1 - 1176.0) + 0.0000164113*(LC_all$LC97_1 - 1176.0)^2;
}

######### LC7 #########
## Replacement Load Cell 7a by LoadCell 7b (Observed in the data and Gaute's files -- Reasons unknown)
## Date chosen because LC7 started recording again on 2003-11-11, but it is unsure what happened then.
if(2003 %in% Years){
    t7a.t7b         <- which(LC_all$Dates==as.POSIXct("2003-315 00:00",format="%Y-%j %H:%M"))
    LC_all$LC7[1:t7a.t7b]   <-  0.0344475*(LC_all$LC7[1:t7a.t7b]    - 1115.0)  + 0.0000170808* (LC_all$LC7[1:t7a.t7b]  - 1115.0)^2;
    LC_all$LC7[t7a.t7b:lt]  <-  0.0358384*(LC_all$LC7[t7a.t7b:lt]   - 1196.3)  + 0.0000162982* (LC_all$LC7[t7a.t7b:lt] - 1196.3)^2;
    
}else if(last(Years)<2003){
    LC_all$LC7 <-  0.0344475*(LC_all$LC7 - 1115.0) + 0.0000170808* (LC_all$LC7 - 1115.0)^2;
    
}else if(Years[1]>2003){
    LC_all$LC7 <-  0.0358384*(LC_all$LC7 - 1196.3) + 0.0000162982* (LC_all$LC7 - 1196.3)^2;
}
###########################################################

# Removing non Realistic pressures converting them in Not A Number
maxP 		<- 100;
cat(sprintf("Removing non-realistic Pressure values (> %1.0f bars) \n",maxP))

LC_all$LC6      [ LC_all$LC6  > maxP]	<- NA;
LC_all$LC1e	    [ LC_all$LC1e > maxP] 	<- NA;
LC_all$LC4	    [ LC_all$LC4  > maxP]	<- NA;
LC_all$LC2a     [ LC_all$LC2a > maxP]	<- NA;
LC_all$LC97_2   [ LC_all$LC97_2>maxP]	<- NA;
LC_all$LC97_1	[ LC_all$LC97_1>maxP]	<- NA;
LC_all$LC7      [ LC_all$LC7  > maxP] 	<- NA;
LC_all$LC2b  	[ LC_all$LC2b > maxP] 	<- NA;
LC_all$LC01     [ LC_all$LC01 > maxP] 	<- NA;

# Convert from bars to MPa
lcol       <- ncol(LC_all)
LC_all[,2:lcol]<-LC_all[,2:lcol]/10

# Clean variables
rm(maxP,daterange,lt)

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
zoo_LC_agg   <- aggregate(zoo_LC,index(zoo_LC),function(x) mean(x,na.rm=TRUE))


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
    
    cat("\n","Subsampling of the LC time series from",sub.start,"to",sub.end,"\n")
    
    sub_zoo_LC      <- subsample(zoo_LC_agg,sub.start,sub.end,F)
    ########################################################################
    ########################################################################
    
    
    ########################################################################
    ####################  REGURLARLY SPACED ZOO  ###########################
    print("Conversion into a regularly spaced object")
    
    # Start Timer to compute Elapsed time
    ptm                 <- proc.time()
    
    # Filenames
    filename_1min  <-paste("Data/Zoo/Sub1min/Zoo_LCall_min_",
                           sub.start,"_",sub.end,".csv",sep='')
    filename_15med <-paste("Data/Zoo/Sub15med/Zoo_LCall_15min_med_",
                           sub.start,"_",sub.end,".csv",sep='')
    filename_15mean<-paste("Data/Zoo/Sub15mean/Zoo_LCall_15min_mean_",
                           sub.start,"_",sub.end,".csv",sep='')
    filename_daily <-paste("Data/Zoo/Sub_daily/Zoo_LCall_day_med_",
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



