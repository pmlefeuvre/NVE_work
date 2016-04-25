
#####################################################################
#            Load, Process Air Temperature Data from NVE            #
#                                                                   #
#                                                                   #
# Homogenise time interval at hourly interval and additionally      # 
# compute daily mean. Also deal with NA values                      #
#                                                                   #
# Author: PiM Lefeuvre                          Date: 2014-09-03    #
# Raw Data are resampled to provide regular time series             #
#####################################################################

# # INPUT example:
# filename        <- "Raw/Engabrevatn_komplet_AirTemp.csv"

###########################################
# Clean up Workspace
# rm(list = ls(all = TRUE))
############################################

Save_AirTdata <- function(filename,path.wd)
{
    ############################################
    # Hydra 2 - Data
    setwd(path.wd)
    Sys.setenv(TZ="UTC")  
    
    # Load libraries
    library(chron)
    library(hydroTSM)   # cmd: izoo2rzoo
    library(zoo)
    
    # Load User Functions
    source("../../UserFunction/subsample.R")
    
    
    ############################################
    # Load data
    Raw             <- read.csv(filename,sep = ';', as.is = TRUE,skip=1)
    
    # Name the columns and attach a name to a column 
    col.names       <- c("Dates", "Air_Temp")
    names(Raw)      <- col.names
    
    # Convert charachter in numeric after changing comas into points
    Raw$Air_Temp  <-as.numeric(gsub(",",".",Raw$Air_Temp))
    
    ############################################
    # Remove NA values
    Raw[Raw==-9999] <- NA
    Raw[Raw<=-60] <- NA
    
    # Format Dates in POSIXlt, then convert into POSIXct and Transform in zoo object
    Raw$Dates       <- as.POSIXct(strptime(Raw$Dates,"%Y-%m-%d %H:%M",tz="UTC"))
    zoo.Raw         <- zoo(x=Raw$Air_Temp, order.by=Raw$Dates)
    
    sub.start       <- "1990-01-01"
    sub.end         <- "2014-01-01"
    zoo.Raw.sub     <- subsample(zoo.Raw,sub.start,sub.end,F)
    # rm(Raw)
    
    
    ####################################################
    ##########  REGURLARLY SPACED ZOO  #################
    print("Conversion into a regularly spaced object")
    
    ### Select one column and converts it into a regularly spaced zoo object (inserting NAs when there is no data)
    # 1 min interval
    print("Proceed to one hour interval")
    system.time(
        zoo.reg     <- izoo2rzoo(zoo.Raw.sub,date.fmt="%Y-%m-%d %H:%M:%S", tstep="hour")
    )
    
    
    ############################################
    ############     AGGREGATED    #############
    # Parameters
    min <- 60       #sec
    hr  <- 60*min   #sec
    
    # Create daily format !!!! IMPORTANT I USE THE MEAN !!!! and replace data at midday
        daily.date      <- as.POSIXct(trunc(index(zoo.reg),units="days")) + 12*hr
        zoo.sub.day     <- aggregate(zoo.reg,daily.date,function(x) mean(x,na.rm=TRUE))
        zoo.sub.hr      <- aggregate(zoo.reg,as.POSIXct(trunc(index(zoo.reg),units="hours")),
                             function(x) mean(x,na.rm=TRUE))
    
        ############################################
        # Output
        zoo.out     <- merge(zoo.sub.hr,round(zoo.sub.day,digits=2))
        names(zoo.out) <- c("Hourly","Daily") 
    
   
        ############################################
        # Filename Processing
        path_out    <- "Data/"
        filename    <- basename(filename)
        filename    <- sub("^([^.]*).*","\\1",filename)
        filename_out<- paste(path_out,filename,".csv",sep="")
        ############################################

        # Save data in zoo format
        write.zoo(zoo.out,file=filename_out,sep=",")

}


## Archive
