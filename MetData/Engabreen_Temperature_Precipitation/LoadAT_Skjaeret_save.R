
#####################################################################
#             Load, Process and Save Air Temperature Data           #
#                             SKJAERET                              #
#                                                                   #
# SPECIFIC TO SKJAERET: Station was changed in 2008                 #
# - Need to merge datasets before and after 2008                    #
# - Overlapping data are averaged                                   #
# In the final file, Only HOURLY data are kept                      #
#                                                                   #
# Author: PiM Lefeuvre                          Date: 2014-09-03    #
# Raw Data are resampled to provide regular time series             #
#####################################################################

###########################################
# Clean up Workspace
# rm(list = ls(all = TRUE))
###########################################

# Set Path
setwd(path.wd)
Sys.setenv(TZ="UTC")  

# Load libraries
library(chron)
library(hydroTSM)   # cmd: izoo2rzoo
library(zoo)

# Load User functions
source("f_Save_AirTemp.R")
source("../../UserFunction/axPOSIX.R")  


#############################################
#### ORIGINAL PROCESSING
# Convert Data into zoo and Save them in LC directory
filename <- "Raw/Skjaeret_komplet_AirTemp.csv"
Save_AirTdata(filename,path.wd)

filename <- "Raw/Skjaeret_komplet_AirTemp2008-2014.csv"
Save_AirTdata(filename,path.wd)


#############################################
#### MERGING THE TWO DATASETS
# Load the Skjaeret Air Temp. data
filename <- "Data/Skjaeret_komplet_AirTemp.csv"
zoo.T1     <- read.zoo(filename, sep=",",header=TRUE, FUN=as.POSIXct) 
# file.remove(filename)

filename <- "Data/Skjaeret_komplet_AirTemp2008-2014.csv"
zoo.T2    <- read.zoo(filename, sep=",",header=TRUE, FUN=as.POSIXct) 
# file.remove(filename)

# Merge time series
zoo.T <- merge(zoo.T1[,1],zoo.T2[,1])


#############################################
# Plot where there is a known overlap
plot(zoo.T[,1],type="p",pch=".",
     xlim=c(as.POSIXct("2008-01-01"),as.POSIXct("2009-01-01")))
lines(zoo.T[,2],col="red")
# Difference between sensors
tmp <- apply(zoo.T,1,function(x){dx <- x[1]-x[2]})
hist(tmp, prob=TRUE,breaks=100)
curve(dnorm(x, mean=mean(tmp,na.rm=T), sd=sd(tmp,na.rm=T)), add=TRUE)
#############################################


#############################################
## !!! MEAN data to create one dataset !!! ##
zoo.T <- zoo(apply(zoo.T,1,function(x) mean(x,na.rm=T)),order.by=index(zoo.T))

# Convert a univariate zoo vector into column based in order to add colnames  
zoo.T  <- cbind(zoo.T)
names(zoo.T) <- names(zoo.T1)[1]


#############################################
# Plot
plot(zoo.T, type="p", col="orange3",pch=".",xaxt="n",
     main="Air Temperature from Skjaeret", 
     xlab="Time [year]",ylab="Temperature [C]")
abline(h=0,lty=3)

# Time axis
axPOSIX(zoo.T,"years","%Y")


############################################
#### SAVE Final Dataset
# Save data in zoo format
path <- "../../Processing/Data/MetData/AirTemp" 
write.zoo(zoo.T,file=sprintf("%s/Skjaeret_AT_1hr_full.csv",path),sep=",",col.names=F)




#####



