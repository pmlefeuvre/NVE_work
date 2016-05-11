#---------------------------------------------------------------#
#           COMPUTE STATISTICS TO ASSESS QUALITY OF             #
#                   METEOROLOGICAL DATA                         #
#                                                               #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2016-05-10 #
#                                       Last Update: 2016-05-10 #
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

# Load Userfunction
source("../UserFunction/subsample.R")


#---------------------------------------------------------------#
#                       Load TEMPERATURE DATA                   #
#---------------------------------------------------------------#
# AT.all.station <- c("Glomfjord","Reipaa","Engabrevatn","Skjaeret")
if (!exists("AT.Gl")){
    # Load Air Temperature data and reformat in zoo time series 
    
    AT.path <- "Data/MetData/AirTemp/eKlima"
    # Glomfjord
    AT.Gl   <- read.zoo(sprintf("%s/%s_AT_full.csv",AT.path,"Glomfjord"),
                        sep=",",FUN=as.POSIXct)
    # Reipaa
    AT.Ra   <- read.zoo(sprintf("%s/%s_AT_full.csv",AT.path,"Reipaa"),
                        sep=",",FUN=as.POSIXct)
    
    AT.path <- "Data/MetData/AirTemp/KomplettNVEdata_20140606"
    # Engabrevatn
    filename<- list.files(AT.path,"Engabrevatn",full.names=T)
    AT.Evat   <- read.csv(filename,F,";", colClasses=c("POSIXct","numeric"),skip=1,
                          as.is=T,na.strings = "-9999.0000",blank.lines.skip=T)
    AT.Evat   <- zoo(AT.Evat[,2],AT.Evat[,1])
    
    # Skjaeret1 before 2009
    filename<- list.files(AT.path,"Skjaeret",full.names=T)
    AT.Skj1   <- read.csv(filename[1],F,";", colClasses=c("POSIXct","numeric"),skip=1,
                          as.is=T,na.strings = "-9999.0000",blank.lines.skip=T)
    AT.Skj1   <- zoo(AT.Skj1[,2],AT.Skj1[,1])
    # Skjaeret2 after 2009
    filename<- list.files(AT.path,"Skjaeret",full.names=T)
    AT.Skj2   <- read.csv(filename[2],F,";", colClasses=c("POSIXct","numeric"),skip=1,
                          as.is=T,na.strings = "-9999.0000",blank.lines.skip=T)
    AT.Skj2   <- zoo(AT.Skj2[,2],AT.Skj2[,1])
    
}

#---------------------------------------------------------------#
#                   Load PRECIPITATION DATA                     #
#---------------------------------------------------------------#
if (!exists("PP.Gl")){
    # Path defines whether Komplett or Historisk data are used
    PP.path <- "Data/MetData/Precip/eKlima"
    
    # Glomfjord
    PP.Gl      <- read.zoo(sprintf("%s/%s_P24_full.csv",PP.path,"Glomfjord"),
                        sep=",",FUN=as.POSIXct)
    
    # Reipaa
    PP.Ra      <- read.zoo(sprintf("%s/%s_P24_full.csv",PP.path,"Reipaa"),
                           sep=",",FUN=as.POSIXct)
}

# MERGE ALL DISCHARGE data
all     <- merge(AT.Gl,AT.Ra,AT.Skj1,AT.Skj2,AT.Evat,PP.Gl,PP.Ra)

# Assign empty arrays
out <- matrix(NA,(2016-1992)*ncol(all),11)
n   <- 0 

# Loop through the years
for (year in seq(1992,2014)){
    
    # Load data
    sub.start   <- sprintf("%i-01-01",year)
    sub.end     <- sprintf("%i-01-01",year+1)
    all.sub     <- subsample(all,sub.start,sub.end,F)
    
    # Loop through the stations
    for (i in 1:ncol(all)){
        
        # Extract load cell data
        ATPP    <- all.sub[,i]
        
        # Compute number of NAs, points, dt
        n.NA    <- sum(is.na(ATPP))
        n.P     <- sum(!is.na(ATPP))
        n.tot   <- length(ATPP)
        dt      <- diff(index(ATPP[!is.na(ATPP)]))
        n       <- n+1
        
        # Output 
        out[n,1] <- year
        out[n,2] <- names(all.sub)[i]
        out[n,3] <- n.NA
        out[n,4] <- round(n.NA/n.tot*100,1)
        out[n,5] <- n.P
        out[n,6] <- round(n.P/n.tot*100,1)
        out[n,7] <- n.tot
        out[n,8] <- round(min(dt)[[1]])
        out[n,9] <- round(median(dt)[[1]])
        out[n,10]<- round(max(dt)[[1]])
        out[n,11]<- length(table(as.Date(index(ATPP[!is.na(ATPP)])))) #n. of days with at least one data point per day
        
        #Print
        print(sprintf("%s: Na's: %s (%s%%), val.: %s (%s%%), tot.: %s, dt: %smin",
                      out[n,2],n.NA,out[n,4],n.P,out[n,6],n.tot,out[n,9]))
        
        
    }
    
}

# Save Output
colnames(out) <- c("year","stn","n.NA","NA%","n.P","P%","n.tot",
                   "dt.min","dt.med","dt.max","n.day")
write.csv(out,"../Documentation/Data_assessment/stats_ATPP_year.csv",row.names = F)
write.csv(out[,c(1,2,5,11)],"../Documentation/Data_assessment/stats_ATPP_year_short.csv",row.names = F)


