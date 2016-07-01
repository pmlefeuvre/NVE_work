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
if (!exists("Q.Sc")){
    # Q.all.station <- c("sedimentkammer","Fonndal_crump","Fonndal_fjell")
    # Path
    Q.path  <- "Data/MetData/Discharge/KomplettNVEdata_20160512"
    
    # Sediment Chamber
    filename<- list.files(Q.path,"SedimentChamber",full.names=T)
    Q.Sc    <- read.csv(filename,F,";", colClasses=c("POSIXct","numeric"),skip=1,
                        as.is=T,na.strings = "-9999.0000",blank.lines.skip=T)
    Q.Sc    <- zoo(Q.Sc[,2],Q.Sc[,1])
    Q.Sc[Q.Sc>30] <- NA
    
    # Fonndal_crump
    filename<- list.files(Q.path,"FonndalCrump",full.names=T)
    Q.Fc    <- read.csv(filename,F,";", colClasses=c("POSIXct","numeric"),skip=1,
                        as.is=T,na.strings = "-9999.0000",blank.lines.skip=T)
    Q.Fc    <- zoo(Q.Fc[,2],Q.Fc[,1])
    
    # Fonndal_fjellsterkel
    filename<- list.files(Q.path,"FonndalFjell",full.names=T)
    Q.Ff    <- read.csv(filename,F,";", colClasses=c("POSIXct","numeric"),skip=1,
                        as.is=T,na.strings = "-9999.0000",blank.lines.skip=T)
    Q.Ff    <- zoo(Q.Ff[,2],Q.Ff[,1])
    
    # Compute subglacial discharge with FonndalCrump and FonndalFjell
    Q.SubFc      <- merge(Q.Sc,Q.Fc)
    Q.SubFc$Q.Fc <- na.approx(Q.SubFc$Q.Fc,maxgap=6,na.rm=F) 
    Q.SubFc      <- Q.SubFc$Q.Sc-Q.SubFc$Q.Fc
    Q.SubFf      <- merge(Q.Sc,Q.Ff)
    Q.SubFf$Q.Ff <- na.approx(Q.SubFf$Q.Ff,maxgap=6,na.rm=F) 
    Q.SubFf      <- Q.SubFf$Q.Sc-Q.SubFf$Q.Ff
    
    
    # Engabrevatne
    filename<- list.files(Q.path,"Engabrevatn",full.names=T)
    Q.Evat    <- read.csv(filename,F,";", colClasses=c("POSIXct","numeric"),skip=1,
                        as.is=T,na.strings = "-9999.0000",blank.lines.skip=T)
    Q.Evat    <- zoo(Q.Evat[,2],Q.Evat[,1])
    
    # Engabreelv
    filename<- list.files(Q.path,"Engabreelv",full.names=T)
    Q.Eelv    <- read.csv(filename,F,";", colClasses=c("POSIXct","numeric"),skip=1,
                          as.is=T,na.strings = "-9999.0000",blank.lines.skip=T)
    Q.Eelv    <- zoo(Q.Eelv[,2],Q.Eelv[,1])
    
    # MERGE ALL DISCHARGE data
    Q.all   <- merge(Q.Fc,Q.Ff,Q.Sc,Q.SubFc,Q.SubFf,Q.Eelv,Q.Evat)
    colnames(Q.all) <- c("QFc","QFf","QSc","QSubFc","QSubFf","Q.Eelv","Q.Evat")
}


# Assign empty arrays
Years <- seq(1992,2016)
out <- matrix(NA,length(Years)*ncol(Q.all),11)
n   <- 0 

# Loop through the years
for (year in Years){
    
    # Load data
    sub.start   <- sprintf("%i-01-01",year)
    sub.end     <- sprintf("%i-01-01",year+1)
    Q.all.sub   <- subsample(Q.all,sub.start,sub.end,F)
    
    # Loop through the discharge station
    for (i in 1:ncol(Q.all)){
        
        # Extract load cell data
        Q       <- Q.all.sub[,i]
        
        # Compute number of NAs, points, dt
        n.NA    <- sum(is.na(Q))
        n.P     <- sum(!is.na(Q))
        n.tot   <- length(Q)
        dt      <- diff(index(Q[!is.na(Q)]))
        n       <- n+1
        
        # Output 
        out[n,1] <- year
        out[n,2] <- names(Q.all.sub)[i]
        out[n,3] <- n.NA
        out[n,4] <- round(n.NA/n.tot*100,1)
        out[n,5] <- n.P
        out[n,6] <- round(n.P/n.tot*100,1)
        out[n,7] <- n.tot
        out[n,8] <- round(min(dt)[[1]])
        out[n,9] <- round(median(dt)[[1]])
        out[n,10]<- round(max(dt)[[1]])
        out[n,11]<- length(table(as.Date(index(Q[!is.na(Q)])))) #n. of days with at least one data point per day
        
        #Print
        print(sprintf("%s: Na's: %s (%s%%), val.: %s (%s%%), tot.: %s, dt: %smin",
                      out[n,2],n.NA,out[n,4],n.P,out[n,6],n.tot,out[n,9]))
        
        
    }
    
}

# Save Output
colnames(out) <- c("year","Qstn","n.NA","NA%","n.P","P%","n.tot",
                   "dt.min","dt.med","dt.max","n.day")
write.csv(out,"../Documentation/Data_assessment/stats_Q_year.csv",row.names = F)
write.csv(out[,c(1,2,5,11)],"../Documentation/Data_assessment/stats_Q_year_short.csv",row.names = F)


