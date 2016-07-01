#---------------------------------------------------------------#
#           COMPUTE STATISTICS TO ASSESS QUALITY OF             #
#                       HYDROLOGICAL DATA                       #
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
if(.Platform$OS.type == "windows"){HOME="//nve/fil/h/HB/Bredata/breprosjekt/Engabreen/Engabreen Brelabben/"}

# Go to the following Path in order to access data files
setwd(sprintf("%s/NVE_work/Processing/",HOME))
Sys.setenv(TZ="UTC")      

# Load library
library(zoo)

# Load Userfunction
source("../UserFunction/subsample.R")

#---------------------------------------------------------------#
#                       Load DISCHARGE DATA                     #
#---------------------------------------------------------------#
if (!exists("S.Sc")){
    # Path
    path    <- "Data/SedimentData"
    
    # Sediment Chamber
    filename<- list.files(path,"SedimentChamber",full.names=T)
    S.Sc    <- read.csv(filename,F,";",skip=2,as.is=T,
                        colClasses=c("POSIXct","numeric","numeric"),
                        col.names=c("Date","Conc.mineral","Conc.organic"),
                        na.strings = "-9999.0000",blank.lines.skip=T)
    S.Sc    <- zoo(S.Sc[,2:3],S.Sc[,1])
    
    # Engabrevatne
    filename<- list.files(path,"Engabrevatn",full.names=T)
    S.Evat  <- read.csv(filename,F,";",skip=2,as.is=T,
                        colClasses=c("POSIXct","numeric","numeric"),
                        col.names=c("Date","Conc.mineral","Conc.organic"),
                        na.strings = "-9999.0000",blank.lines.skip=T)
    S.Evat  <- zoo(S.Evat[,2:3],S.Evat[,1])
    
    # Engabreelv
    filename<- list.files(path,"Engabreelv",full.names=T)
    S.Eelv  <- read.csv(filename,F,";",skip=2,as.is=T,
                        colClasses=c("POSIXct","numeric","numeric"),
                        col.names=c("Date","Conc.mineral","Conc.organic"),
                        na.strings = "-9999.0000",blank.lines.skip=T)
    S.Eelv  <- zoo(S.Eelv[,2:3],S.Eelv[,1])
    
    # MERGE ALL DISCHARGE data
    all   <- merge(S.Sc,S.Eelv,S.Evat)
}


# Assign empty arrays
Years <- seq(1992,2004)
out <- matrix(NA,length(Years)*ncol(all),11)
n   <- 0 

# Loop through the years
for (year in Years){
    
    # Load data
    sub.start   <- sprintf("%i-01-01",year)
    sub.end     <- sprintf("%i-01-01",year+1)
    all.sub   <- subsample(all,sub.start,sub.end,F)
    
    # Loop through the discharge station
    for (i in 1:ncol(all)){
        
        # Extract load cell data
        Sdt     <- all.sub[,i]
        
        # Compute number of NAs, points, dt
        n.NA    <- sum(is.na(Sdt))
        n.P     <- sum(!is.na(Sdt))
        n.tot   <- length(Sdt)
        dt      <- diff(index(Sdt[!is.na(Sdt)]))
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
        out[n,11]<- length(table(as.Date(index(Sdt[!is.na(Sdt)])))) #n. of days with at least one data point per day
        
        #Print
        print(sprintf("%s: Na's: %s (%s%%), val.: %s (%s%%), tot.: %s, dt: %smin",
                      out[n,2],n.NA,out[n,4],n.P,out[n,6],n.tot,out[n,9]))
        
        
    }
    
}

# Save Output
colnames(out) <- c("year","Sdtstn","n.NA","NA%","n.P","P%","n.tot",
                   "dt.min","dt.med","dt.max","n.day")
write.csv(out,"../Documentation/Data_assessment/stats_Sdt_year.csv",
          row.names = F)
write.csv(out[,c(1,2,5,11)],
          "../Documentation/Data_assessment/stats_Sdt_year_short.csv",
          row.names = F)


