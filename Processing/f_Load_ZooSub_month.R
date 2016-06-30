#---------------------------------------------------------------#
#       Load Processed PRESSURE or FREQUENCY LC Data from       #
#                   a zoo regular space object                  #
#                                                               #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2013-01-01 #
#                                       Last Update: 2016-04-25 #
#                                                               #
# Updates:                                                      #
#                                                               #
#---------------------------------------------------------------#

################################################
####                  ####
################################################


Load_ZooSub_month <- function(sub.start="05/15/2010 09:00",
                        sub.end="05/15/2010 11:00",
                        type="15min_mean",freq=F)
{
    # Detect Operating System (!!! EDIT TO YOUR PATH !!!)
    if(.Platform$OS.type == "unix"){   HOME="/Users/PiM/Desktop"}
    if(.Platform$OS.type == "windows"){HOME="//nve/fil/h/HB/Personlige mapper/PiM"}
    
    # Go to the following Path in order to access data files
    setwd(sprintf("%s/NVE_work/Processing/",HOME))
    Sys.setenv(TZ="UTC")     
    
    # Load libraries
    require(zoo)
    require(chron)
    require(Hmisc)
    require(lubridate)
    
    # Load functions
    source("../UserFunction/juliandate.R")
    source("../UserFunction/subsample.R")
    source("../UserFunction/remove_col.R")
    
    # To reLoad if the sampling dates have changed
    if ( !exists("old.start") || !exists("old.end") ){
        print("old.Dates does not Exist")
        old.start   <-NULL
        old.end     <-NULL
    }
    
    # Format Filename, Load and Subsample Data
        if ( !exists("LC.reg.sub") || (sub.start != old.start) || (sub.end != old.end) )
            { 
        print("Load and Reformat LC Data")
        
        # Time parameters
        min     <-60       #sec
        hr      <-60*min   #sec
        day     <-24*hr    #sec
        
        # Identify Date Formatting
        if        (nchar(sub.start) == 8) {
            t.format="%Y-%j"
        } else if (nchar(sub.start) == 10) {
            if ( length(grep("-",sub.end))>0 ){
                t.format="%Y-%m-%d"
            }else{t.format="%m/%d/%Y"
            }
        } else if (nchar(sub.start) == 16) {
            if ( length(grep("-",sub.end))>0 ){
                t.format="%Y-%m-%d %H:%M"
            }else{t.format="%m/%d/%Y %H:%M"
            }
        }
        
        # Reformat in POSIX according to t.format
        t.sub.start <-as.POSIXct(sub.start,format=t.format)
        t.sub.end   <-as.POSIXct(sub.end  ,format=t.format)
        
        # Extract the month in a numeric format
        m.sub.start <- as.numeric(strftime(t.sub.start,format="%m"))
        m.sub.end   <- as.numeric(strftime(t.sub.end,  format="%m"))
        
        # Check if month is even or odd. Find floor month for start date and
        # ceiling month for end in order to fit the filename format
        if(m.sub.start %% 2) {c.sub.start <-t.sub.start
                    } else   {c.sub.start <-t.sub.start-as.numeric(strftime(t.sub.start,"%d"))*day
                    }
        if(m.sub.end   %% 2) {c.sub.end   <-t.sub.end 
                    } else   {c.sub.end   <-seq(t.sub.end,by="months",len=2)[2]}
    
        # Round (Down for start and Up for end)
        j.sub.start <-trunc(c.sub.start,units="months")
        j.sub.end   <-ceil( c.sub.end,  units="months")
        # Check if start and end have minimum two months in between - use(lubridate)
        if( (as.yearmon(j.sub.end)-as.yearmon(j.sub.start))*12 <= 3){
            month(j.sub.end) <- month(j.sub.end) + 1
        }
        
        # If more than 2 months load several files and combine them
        j.sub       <-seq(j.sub.start,j.sub.end,by="2 months")
        lj          <-length(j.sub)
        
        daterange <- c(0)
        # Create an string array with the files to load
        for (i in 1:(lj-1)) {
        # Define daterange for filename in julian day (ex:"2010-113-2010-161")
        daterange[i]   <-paste(juliandate(j.sub[i]),
                            juliandate(j.sub[i+1]), sep="_")
        }
        
        # Directory for the type of data to load
        if       (type == "min"){
            dir.type <- "Sub1min"
        }else if (type == "15min_med"){
            dir.type <- "Sub15med"
        }else if (type == "15min_mean"){
            dir.type <- "Sub15mean"
        }else if (type == "day_med"){
            dir.type <- "Sub_daily"
        }else{stop("Data type must be: min, 15min_med, 15min_mean or day_med")}
        
        # Assign Filename and whether to load Frequency data 
        if (freq){
            print("Load Frequency Data")
            datafile    <-paste("Data/Zoo/",dir.type,"/Zoo_LCallfreq_",
                                type,"_", daterange, ".csv", sep="")
        }else{
            print("Load Pressure Data")
            datafile    <-paste("Data/Zoo/",dir.type,"/Zoo_LCall_",
                                type,"_", daterange, ".csv", sep="")
        }
        
        # Load LC data from file(s)
        LC.reg.min <- do.call("rbind",
                              lapply(datafile,
                                     function(f) read.zoo(f, header = T,
                                                          sep = ",",FUN = as.POSIXct)))
        
        # Subsample
        LC.reg.sub  <-subsample(LC.reg.min,sub.start,sub.end,f.print=F)
        
        # Remove Empty Columns
        Output          <- remove_col(LC.reg.sub)
        # Individualise the output lists with their original name
        list2env(Output,env=environment())
        
        rm(Output)
        
    # If LC.zoo.sub already exists SKIP that part >> Save Time <<
    } else {
        print("Skip Loading of LC data because they already exists")
    }
    
    # Assign used dates to check if a new subampling period was entered
    assign("old.start",sub.start,envir= .GlobalEnv)
    assign("old.end"  ,sub.end  ,envir= .GlobalEnv)
    
    # Check if LC.reg.sub exists
    if ( length(LC.reg.sub) == 0 ) {
        print("No Data Point")
        print(">>>>>>     SKIPPING      <<<<<<<")
        Output  <- NULL
        return(Output)} ## END   
    
    
    return(LC.reg.sub) 
}


## ARCHIVE

