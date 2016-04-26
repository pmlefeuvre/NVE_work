
#---------------------------------------------------------------#
#           ANALYSIS OF THE CORRELATION OF DISCHARGE            #
#       MEASURED AT SEDIMENT CHAMBER AND FONNDAL STATIONS       #
#                                                               #
#                                                               #
# Author: Pim Lefeuvre                         Date: 28/01/2015 #
#                                       Last Update: 28/01/2015 #
# Formerly "Hydra2/Correlation_Q.Sc_Q.R"                        #
#---------------------------------------------------------------#


##########################################
# Clean up Workspace 
rm(list = ls(all = TRUE))
# Save "par" default
def.par <- par(no.readonly = TRUE)
##########################################
### Go to the following Path in order to access data files
setwd("/Users/PiM/Desktop/PhD/Data Processing/Load Cells/Processing")
Sys.setenv(TZ="UTC")

# Load libraries
library(zoo)
library(chron)
library(lubridate)

# Load User functions
source("../../UserFunction/subsample.R")

#########################################################################
# Time Parameters
hour    <- 60/15  #in 15min
day     <- 24*hour#in hour
month   <- 31*day # in days

#---------------------------------------------------------------#
#                       Load DISCHARGE DATA                     #
#---------------------------------------------------------------#
# Load hourly discharge
if (!exists("Q")){
#     filename <- "Data/MetData/Discharge/Q.Sc.orig-pred-combined.csv"
#     filename <- "Data/MetData/Discharge/Q.Sub.orig-pred.csv"
filename <- "dQvsP/Data/Q.Sc.F.Sub_corrected_1992-153-2014-078.csv"
Q       <- read.zoo(filename,sep=",",FUN = as.POSIXct,header=T)
Q.Sc    <- cbind(Q[,1])
Q.F     <- cbind(Q[,2])
}

# Filter
Q.Sc.f  <- subsample(Q.Sc[!is.na(Q.Sc) & !is.na(Q.F)],
                     "2003-01-01","2004-01-01")
Q.F.f   <- subsample(Q.F[ !is.na(Q.Sc) & !is.na(Q.F)],
                     "2003-01-01","2004-01-01")

# Assign
Q.min   <- seq(0,20)
cor.Q   <- array(NA,length(Q.min))
ln      <- array(NA,length(Q.min))

for (n in Q.min){
    cor.Q[n+1] <- cor(Q.Sc.f[coredata(Q.Sc.f)>n & coredata(Q.F.f)>(n/3)],
                      Q.F.f[ coredata(Q.Sc.f)>n & coredata(Q.F.f)>(n/3)])
    ln[n+1] <- length(Q.Sc.f[coredata(Q.Sc.f)>n & coredata(Q.F.f)>(n/3)])
}

# PLots
par(mar=c(5,4,4,3)+0.1)
plot(Q.min,cor.Q,ylim=c(0,1),pch=20,
     xlab="Q.Sc [m3.s-1] or Q.F/3 [m3.s-1]",main="2003")
abline(v=15,lty=2)
text(15+0.5,0.85,"15 m3.s-1",srt=-90)

par(new=T)
plot(Q.min,ln,xaxt="n",yaxt="n",xlab="",ylab="",pch=20,col="red")
abline(h=250,lty=2,col="red")
axis(4,col="red",lwd=2)
text(1,250+100,"250 pts",col="red")
mtext("Number of points",4,2,at=max(ln)/2,col="red")

