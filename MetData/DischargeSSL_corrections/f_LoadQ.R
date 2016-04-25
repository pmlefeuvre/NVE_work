#---------------------------------------------------------------#
#                  FORMAT HYDRA 2 DISCHARGE DATA                #
#                         INTO ZOO OBJECT                       #
#                                                               #
#                                                               #
# Author: Pim Lefeuvre                         Date: 19/06/2014 #
#                                       Last Update: 11/09/2014 #
#---------------------------------------------------------------#

###########################################
# # Clean up Workspace 
# rm(list = ls(all = TRUE))
###########################################


f_LoadQ <- function(filename,filename_out,path.wd){
    ############################################
    # Set Path
    setwd(path.wd)
    Sys.setenv(TZ="UTC")  
    
    # Load libraries
    library(chron)
    library(hydroTSM)   # cmd: izoo2rzoo
    library(zoo)
    
    # Load User functions
    source("../../UserFunction/axPOSIX.R")
    source("../../UserFunction/subsample.R")
    source("../../UserFunction/remove_col.R")  
    
    ############################################
    # Load data
    Raw             <- read.csv(filename,sep = ';',as.is=T,
                                skip=1,header=F)
    
    # Name the columns and attach a name to a column 
    col.names       <- c("Dates", "Discharge");
    names(Raw)      <- col.names;
    
    # Convert charachter in numeric after changing Norwegian commas into points
    Raw$Discharge   <-as.numeric(gsub(",",".",Raw$Discharge))
    
    ############################################
    # Remove NA values
    Raw[Raw==-9999] <- NA
    
    # Convert Dates into POSIXct and Transform in zoo object
    Raw$Dates       <- as.POSIXct(strptime(Raw$Dates,"%Y-%m-%d %H:%M",tz="UTC"))
    zoo.Raw         <- zoo(x=Raw$Discharge, order.by=Raw$Dates)
    
    # Resample (in case, there are data before 1992)
    sub.start       <- "1992-01-01"
    sub.end         <- "2014-01-01"
    zoo.Raw.sub     <- subsample(zoo.Raw,sub.start,sub.end,f.print=F)
    
    ####################################################
    ##########  REGURLARLY SPACED ZOO  #################
    print("Conversion into a regularly spaced object")
    
    ### Select one column and converts it into a regularly spaced zoo object 
    # (inserting NAs when there is no data)
    print("Proceed to one hour interval")
    zoo.reg          <- izoo2rzoo(zoo.Raw.sub[,drop=T],date.fmt="%Y-%m-%d %H:%M:%S",
                                  tstep="hour")
    
    
    ############################################
    ############################################
    # Aggregate values to get 1 hour interval
    zoo.sub.hr      <- aggregate(zoo.reg,as.POSIXct(trunc(index(zoo.reg),
                                                          units="hours")),
                                 function(x) mean(x,na.rm=TRUE))
    
    # A Warning Message might pop up, due to "trunc" that converts dates in 
    # POSIXlt and somehow loses information from isdst. 
    # From ?DateTimeClasses > isdst: Daylight Saving Time flag. Positive if in
    #                                force, zero if not, negative if unknown.
    # For us, isdst should equal 0 as data from NVE remain in Winter Time Zone
    
    # ###########################################
    # # Plot
    # plot(zoo.Raw.sub, type="p", col="orange3",
    #      xaxt="n",
    #      main="Discharge",
    #      xlab="Time 2012 [%m]",
    #      ylab="Discharge [m3/sec]")
    # 
    # # Time axis
    # axPOSIX(zoo.Raw.sub,"years","%Y")
    # points(zoo.sub.hr,  col="chartreuse4",pch=19,cex=0.2)
    
    ############################################
    # Save data in zoo format
    path <- "../../Processing/Data/MetData/Discharge" 
    write.zoo(zoo.sub.hr,file=sprintf("%s/%s",path,filename_out),sep=",")
}







