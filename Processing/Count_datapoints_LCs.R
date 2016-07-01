#---------------------------------------------------------------#
#           COMPUTE STATISTICS TO ASSESS QUALITY OF             #
#                       LOAD CELL DATA                          #
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
source("f_Load_ZooSub_month.R")

#---------------------------------------------------------------#
# Assign empty arrays
Years <- seq(1992,2016)
out <- matrix(NA,length(Years)*10,11)
n   <- 0 

# Loop through the years
for (year in Years){
    
    # Load data
    if (year==1992){sub.start <- sprintf("%i-11-01",year)
    }else{          sub.start <- sprintf("%i-01-01",year)}
    sub.end     <- sprintf("%i-01-01",year+1)
    LC.reg.sub  <- Load_ZooSub_month(sub.start,sub.end,type="min")
    
    # Loop through the load cells
    for (i in 1:dim(LC.reg.sub)[2]){
        
        # Extract load cell data
        LC      <- LC.reg.sub[,i]
        
        # Compute number of NAs, points, dt
        n.NA    <- sum(is.na(LC))
        n.P     <- sum(!is.na(LC))
        n.tot   <- length(LC)
        dt      <- diff(index(LC[!is.na(LC)]))
        n       <- n+1
        
        # Output 
        out[n,1] <- year
        out[n,2] <- names(LC.reg.sub)[i]
        out[n,3] <- n.NA
        out[n,4] <- round(n.NA/n.tot*100,1)
        out[n,5] <- n.P
        out[n,6] <- round(n.P/n.tot*100,1)
        out[n,7] <- n.tot
        out[n,8] <- round(min(dt)[[1]])
        out[n,9] <- round(median(dt)[[1]])
        out[n,10]<- round(max(dt)[[1]])
        out[n,11]<- length(table(as.Date(index(LC[!is.na(LC)])))) #n. of days with at least one data point per day
        
        #Print
        print(sprintf("%s: Na's: %s (%s%%), val.: %s (%s%%), tot.: %s, dt: %smin",
                      out[n,2],n.NA,out[n,4],n.P,out[n,6],n.tot,out[n,9]))
        
        
    }
    
}

# Save Output
colnames(out) <- c("year","Qstn","n.NA","NA%","n.P","P%","n.tot",
                   "dt.min","dt.med","dt.max","n.day")
write.csv(out,"../Documentation/Data_assessment/stats_LCs_year.csv",row.names = F)
write.csv(out[,c(1,2,5,11)],"../Documentation/Data_assessment/stats_LCs_year_short.csv",row.names = F)




