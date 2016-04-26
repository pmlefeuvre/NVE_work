
#---------------------------------------------------------------#
#               COMPARE DAILY DISCHARGE FROM NVE                #
#             WITH CORRECTED HOURLY DISCHARGE FROM              #
# 1) Sediment Chamber                                           #
# 2) Fonndal (combining both stations)                          #
# 3) COmputed Subglacial Discharge                              #
#                                                               #
# Author: Pim Lefeuvre                         Date: 11/09/2014 #
#---------------------------------------------------------------#

###########################################
# # Clean up Workspace 
# rm(list = ls(all = TRUE))
# # Save "par" default
# def.par <- par(no.readonly = TRUE)
###########################################


# Load libraries
library(zoo)
library(chron)
library(hydroGOF) #NSE


# Load User functions
source("../../UserFunction/subsample.R")
source("../../UserFunction/juliandate.R")
source("../../UserFunction/my.grid.R")


#########################################################################
#---------------------------------------------------------------#
#                       Load DISCHARGE DATA                     #
#---------------------------------------------------------------#
# Path and Filename
path            <- "../../Processing/Data/MetData/Discharge"
Q.filename      <- sprintf("%s/Q.Sc.F.Sub_corrected_1992-153-2014-001.csv",path)
Qd.filename     <- sprintf("%s/Subglacial_Q_komp.csv",path)

# Load
if (!exists("Q.corrd") || !exists("Qd")){
    print("Load Discharge Data")
    Q.corrd     <- read.zoo(Q.filename,sep=",",FUN=as.POSIXct,
                            header=T) 
    Qd.Sub      <- read.zoo(Qd.filename,sep=",",FUN=as.POSIXct,
                            header=T) 
}

# Assign and Subsample
Q.Sub   <- subsample(Q.corrd[,3],"1998-01-01","2013-12-31",F)

# Compute daily values
Q.Sub.d <- aggregate(Q.Sub,as.POSIXct(trunc(index(Q.Sub),units="days")),
                     function(x) mean(x,na.rm=TRUE))
Qd.Sub.d<- aggregate(Qd.Sub,as.POSIXct(trunc(index(Qd.Sub),units="days")),
                     function(x) mean(x,na.rm=TRUE))

# Difference
print("Compute Difference between Subglacial daily values")
Q.diff <- Q.Sub.d[!is.na(Q.Sub.d) & !is.na(Qd.Sub.d)]-Qd.Sub.d[!is.na(Q.Sub.d) & !is.na(Qd.Sub.d)]

# Summary: Over-estimate 
summary(Q.diff)

# Plot Histogram
hist(Q.diff,breaks=120)
# Plot Time Series
plot(Q.diff,xaxt="n")
my.grid.year(start(Q.diff),end(Q.diff)+3600*24)
# Plot Daily distribution
barplot_TimeFactors(index(Q.diff),"doy",coredata(Q.diff),
                    xaxt="n",pch=".",ylim=c(-0.5,1))
grid()

# Plot Period per year
year     <- seq(1998,2013)

# Make folder where will be saved the plot
path.p <- "Plots/Compare_SubDaily"
dir.create(path.p,showWarnings = FALSE)

for (j in year){
    # Time
    sub.start   <- sprintf("%s-05-01",j)
    sub.end     <- sprintf("%s-11-01",j)
    t.start     <- as.POSIXct(sub.start)
    t.end       <- as.POSIXct(sub.end)
    
    # Save
    filename    <- sprintf("Compare_SubDaily_%s-%s.pdf",
                           juliandate(t.start),
                           juliandate(t.end))
    pdf(sprintf("%s/%s",path.p,filename),heigh=4)
    
    # Subsample
    Q.Sub.d.sub <- subsample(Q.Sub.d, sub.start,sub.end,F)
    Qd.Sub.d.sub<- subsample(Qd.Sub.d,sub.start,sub.end,F)
    Q.Sub.sub   <- subsample(Q.Sub,   sub.start,sub.end,F)
    
    # Plot
    plot(Q.Sub.sub,xlim=c(t.start,t.end),ylim=c(-5,35),xaxt="n")
    points(Q.Sub.sub,pch=".")
    points(Q.Sub.d.sub,col="cyan4",pch=20, cex=1)
    points(Qd.Sub.d.sub,col="orange",cex=1,lwd=2)
    lines(Q.diff,type="h",col="red",lwd=2)
    my.grid.month(t.start,t.end)
    
    legend("topleft",legend=c("Hourly Sub","Daily Sub - linear model",
                              "Daily Sub - ratio NVE", "Difference"),
           lty=c(1,0,0,1),col=c("black","cyan4","orange","red"),
           pch=c(NA,20,1,NA),cex=0.5,bg="white")
    
    # Close pdf
    dev.off()
}




### Archive



