#---------------------------------------------------------------#
#         PLOT TIME SPAN OF THE LOAD CELL TIME SERIES           #
#                                                               #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2016-05-11 #
#                                       Last Update: 2016-05-11 #
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

#### PLOT DATA SPAN
source("f_Load_ZooSub_month.R")
LC.reg.sub <- Load_ZooSub_month("1992-11-01","2015-01-01","day_med")

# Compute standard deviation
LC.sd <- rollapply(LC.reg.sub,31,function(x) sd(x,na.rm=T))
colnames(LC.sd) <- colnames(LC.reg.sub)

#Create a function to generate a continuous color palette
rbPal <- colorRampPalette(c('red','blue'))

#This adds a column of color values based on the y values
col     <- matrix(NA,nrow(LC.sd),ncol(LC.sd))
for (i in 1:ncol(LC.sd)){
    col[,i] <- rbPal(10)[as.numeric(cut(LC.sd[,i],breaks = 20))]
}

LC.reg.sub$LC01[!is.na(LC.reg.sub$LC01)] <- 0
LC.reg.sub$LC1e[!is.na(LC.reg.sub$LC1e)] <- 1
LC.reg.sub$LC2a[!is.na(LC.reg.sub$LC2a)] <- 2
LC.reg.sub$LC2b[!is.na(LC.reg.sub$LC2b)] <- 3
LC.reg.sub$LC4[ !is.na(LC.reg.sub$LC4 )] <- 4
LC.reg.sub$LC6[ !is.na(LC.reg.sub$LC6 )] <- 6
LC.reg.sub$LC7[ !is.na(LC.reg.sub$LC7 )] <- 7
LC.reg.sub$LC97_1[ !is.na(LC.reg.sub$LC97_1 )] <- 8
LC.reg.sub$LC97_2[ !is.na(LC.reg.sub$LC97_2 )] <- 9


plot(LC.reg.sub[,1],type="p",col=col[,1],pch="|",cex=.5,ylim=c(-.1,9.1))
for (i in 2:9){
    points(LC.reg.sub[,i],col=col[,i],pch="|",cex=.5)
}
