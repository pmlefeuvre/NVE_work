# EXTRACT CORRECTED POINTS


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
library(zoo)

# Load Userfunction
source("../UserFunction/subsample.R")


# Variables
LCname  <- c("LC01","LC1e","LC2a","LC2b","LC4","LC6","LC7","LC97_1","LC97_2")
lLC     <- length(LCname)

# Path
path    <- "Data/Hykval"

for (i in 1:lLC){
  # Sediment Chamber
  filename<- list.files(path,LCname[i],full.names=T)
  LC      <- read.csv(filename,F,";",skip=2,as.is=T,
                      colClasses=c("POSIXct","numeric","numeric"),
                      col.names=c("Date","Hykval","Hytran"),
                      na.strings = "-9999.0000",blank.lines.skip=T)
  
  noNA    <- which(is.na(LC$Hykval) & !is.na(LC$Hytran))
  DeletedPts <- LC[noNA,1]
  
  # Save
  dir.create("Data/DeletedPoints",showWarnings=F)
  write.csv(DeletedPts,sprintf("Data/DeletedPoints/DeletedPts_%s.csv",LCname[i]),
            row.names=F)
  
}

# # Plot zoo
# LC.zoo<- zoo(LC[,2:3],LC[,1])
# plot(LC.zoo[,2])
# points(LC.zoo[nona,2],col="red",pch=".")



# ARCHIVE
# ind   <-duplicated(LC[,1:2],MARGIN=0)
