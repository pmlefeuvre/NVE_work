
#---------------------------------------------------------------#
#           COMPUTE LAG IN DISCHARGE PEAK BETWEEN               #
#               SEDIMENT CHAMBER AND FONNDAL                    #
# 1) Corrected Sediment Chamber                                 #
# 2) Fonndal (combining both stations)                          #
#                                                               #
# Author: Pim Lefeuvre                         Date: 20/08/2014 #
#                                       Last Update: 11/09/2014 #
# Look at the lag between Sediment Chamber and Fonndal          #
# Formerly called: Compare_Qdaily_Qcorrected_lag.R              #
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


# Load User Functions
source("../../UserFunction/subsample.R")
source("../../UserFunction/Find_Max_CCF.R")


#########################################################################
#---------------------------------------------------------------#
#                       Load DISCHARGE DATA                     #
#---------------------------------------------------------------#
# Path and Filename
path            <- "../../Processing/Data/MetData/Discharge"
Q.filename      <- sprintf("%s/Q.Sc.F.Sub_corrected_1992-153-2014-001.csv",path)

# Load
if (!exists("Q.corrd")){
    print("Load Discharge Data")
    Q.corrd     <- read.zoo(Q.filename,sep=",",FUN=as.POSIXct,
                            header=T) 
}

# Subsample
Q.corrd.sub <- subsample(Q.corrd,"1998-01-01","2014-01-01",F)

# Rolling window for coeff
print("Compute Auto-Correlation with running window")
ndays   <- 1
win     <- 24*ndays

# Compute Auto-correlation to estimate Lag
my.FUN  <- function(x){
    if(sum(is.na(x[,1]))<(win/1.5) && sum(is.na(x[,2]))<(win/1.5)){
        x1 <- x[!is.na(x[,1]) & !is.na(x[,2]),1]
        x2 <- x[!is.na(x[,1]) & !is.na(x[,2]),2]
        if(length(x1)<win/4 | length(x2)<win/4){return(c(NA,NA))}
        
        Find_Max_CCF(x1,x2,lag.max=win/2)
    }else{return(c(NA,NA))}
}

# Rolling window
Q.lag <- rollapply(Q.corrd.sub[,1:2],width=win,FUN=my.FUN,
                   by.column=F,by=win)

## Filter Lag - remove frequency lower than original interval: 1hr
Q.lag[Q.lag[,1]<0.5] <- NA

# Make folder where will be saved the plot
path.p <- "Plots/Lag_Sc_F"
dir.create(path.p,showWarnings = FALSE)

# Plot 1
pdf(sprintf("%s/Lag_summary_ts.pdf",path.p))
plot(merge(Q.corrd.sub[,1:2],Q.lag),type="p",pch=".")
dev.off()

# Plot 2: Distribution
pdf(sprintf("%s/Lag_summary_dist.pdf",path.p),height=4)
# Lag histogram
hist(Q.lag[,2],40,col="grey")

# Plots Daily Distribution Lag
barplot_TimeFactors(index(Q.lag),"doy",coredata(Q.lag[,2]),
                    xaxt="n",pch=".")
abline(h=0,lty=3)
grid()

# Close pdf
dev.off()




### Archive



