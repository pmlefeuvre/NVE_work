
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

# Load library
library(zoo)
library(hydroTSM)

# Load Userfunction
source("f_Load_ZooSub_month.R")
source("f_timespan.R")
source("../UserFunction/my.grid.R")

#### PLOT DATA SPAN
sub.start   <- "1992-11-01"
sub.end     <- "2016-01-01"
t.start     <- as.POSIXct(sub.start) 
t.end       <- as.POSIXct(sub.end) 

#---------------------------------------------------------------#
#                       Load load cell DATA                     #
#---------------------------------------------------------------#
LC.reg.sub <- Load_ZooSub_month(sub.start,sub.end,"day_med")
timespan(LC.reg.sub,10)


#---------------------------------------------------------------#
#                       Load DISCHARGE DATA                     #
#---------------------------------------------------------------#
if (!exists("Q.Sc")){
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
    colnames(Q.all) <- c("Q_FonndalCrump","Q_FonndalFjell","Q_SedimentChamber",
                         "Q_SubglacialFc","Q_SubglacialFf",
                         "Q_Engabreelv","Q_Engabrevatn")
    Q.agg   <- aggregate(Q.all,as.Date,function(x) mean(x,na.rm=T)) 
    Q.reg   <- izoo2rzoo(Q.agg,t.start,t.end,tstep="days")
}
timespan(Q.reg,10)

#---------------------------------------------------------------#
#                       Load TEMPERATURE DATA                   #
#---------------------------------------------------------------#
if (!exists("AT.Gl")){
    # Load Air Temperature data and reformat in zoo time series 
    
    AT.path <- "Data/MetData/AirTemp/eKlima"
    # Glomfjord
    AT.Gl   <- read.zoo(sprintf("%s/%s_AT_full.csv",AT.path,"Glomfjord"),
                        sep=",",FUN=as.POSIXct)
    # Reipaa
    AT.Ra   <- read.zoo(sprintf("%s/%s_AT_full.csv",AT.path,"Reipaa"),
                        sep=",",FUN=as.POSIXct)
    
    AT.path <- "Data/MetData/AirTemp/KomplettNVEdata_20160512"
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
AT.all     <- merge(AT.Gl,AT.Ra,AT.Skj1,AT.Skj2,AT.Evat,PP.Gl,PP.Ra)
colnames(AT.all) <- c("AT_Glomfjord","AT_Reipaa",
                      "AT_Skjaeret1","AT_Skjaeret2","AT_Engabrevatn",
                      "PP_Glomfjord","PP_Reipaa")

AT.agg   <- aggregate(AT.all,as.Date,function(x) mean(x,na.rm=T)) 
AT.reg   <- izoo2rzoo(AT.agg,t.start,t.end,tstep="days")

timespan(AT.reg,10)

#---------------------------------------------------------------#
#               Load SEDIMENT CONCENTRATION DATA                #
#---------------------------------------------------------------#
if (!exists("S.Sc")){
    # Path
    S.path  <- "Data/SedimentData/"
    
    # Sediment Chamber
    filename<- list.files(S.path,"SedimentChamber",full.names=T)
    S.Sc    <- read.csv(filename,F,";",skip=2,as.is=T,
                        colClasses=c("POSIXct","numeric","numeric"),
                        col.names=c("Date","Conc.mineral","Conc.organic"),
                        na.strings = "-9999.0000",blank.lines.skip=T)
    S.Sc    <- zoo(S.Sc[,2:3],S.Sc[,1])
    
    # Engabrevatn
    filename<- list.files(S.path,"Engabrevatn",full.names=T)
    S.Evat  <- read.csv(filename,F,";",skip=2,as.is=T,
                        colClasses=c("POSIXct","numeric","numeric"),
                        col.names=c("Date","Conc.mineral","Conc.organic"),
                        na.strings = "-9999.0000",blank.lines.skip=T)
    S.Evat  <- zoo(S.Evat[,2:3],S.Evat[,1])
    
    # Engabreelv
    filename<- list.files(S.path,"Engabreelv",full.names=T)
    S.Eelv  <- read.csv(filename,F,";",skip=2,as.is=T,
                        colClasses=c("POSIXct","numeric","numeric"),
                        col.names=c("Date","Conc.mineral","Conc.organic"),
                        na.strings = "-9999.0000",blank.lines.skip=T)
    S.Eelv  <- zoo(S.Eelv[,2:3],S.Eelv[,1])
    
    # MERGE ALL DISCHARGE data
    S.all   <- merge(S.Sc,S.Eelv,S.Evat)
    colnames(S.all) <- c("Sdtminl_SedimentChamber","Sdtorg_SedimentChamber",
                         "Sdtminl_Engabreelv","Sdtorg_Engabreelv",
                         "Sdtminl_Engabrevatn","Sdtorg_Engabrevatn")
    S.agg   <- aggregate(S.all,as.Date,function(x) mean(x,na.rm=T))
    S.reg   <- izoo2rzoo(S.agg,t.start,t.end,tstep="days")
}
timespan(S.reg,10)


#---------------------------------------------------------------#
#                       Plot Data Timespan                      #
#---------------------------------------------------------------#

####
# Filenames
stn         <- c(names(LC.reg.sub),names(Q.all),names(AT.all),names(S.all))
datafile    <- sprintf("Data/Timespan/Timespan_%s.csv",stn)
# Dimensions
l           <- length(datafile)
lLC         <- ncol(LC.reg.sub) 
lQ          <- ncol(Q.all) 
lAT         <- ncol(AT.all) 
lS          <- ncol(S.all) 
yr          <- -3600*24*5

# plot
c1 <- "black"
c2 <- "grey50"
col         <- c(rep(c1,6),rep(c2,6),rep(c1,3),c2,c1,c2,rep(c1,5),rep(c2,6)) 

plot(c(as.POSIXct(t.start),as.POSIXct(t.end)),c(1,l),type="n",
     xlab="",ylab="",yaxt="n",xaxt="n",xaxs="i",ylim=c(1.5,l-.5))
rect(t.start-yr,1-.5,           t.end+yr  ,lLC+.5,         col="grey80",border=NA)
# rect(t.start-yr,lLC+.5,         t.end+yr  ,lLC+lQ+.5,      col="white",border=NA)
rect(t.start-yr,lLC+lQ+.5,      t.end+yr  ,lLC+lQ+lAT-2+.5,col="grey80",border=NA)
# rect(t.start-yr,lLC+lQ+lAT-2+.5,t.end+yr  ,lLC+lQ+lAT+.5,  col="white",border=NA)
rect(t.start-yr,lLC+lQ+lAT+.5,t.end+yr  ,lLC+lQ+lAT+lS+.5,col="grey80",border=NA)
my.grid.year(as.POSIXct(t.start),as.POSIXct(t.end))
axis(2,seq(1:l),stn,las=1,cex.axis=.5)

for (i in 1:l){
    
    tmp <- read.csv(datafile[i],as.is=T,colClasses="POSIXct")
    lt <- nrow(tmp)
    
    for (j in 1:lt){
        lines(c(tmp[j,1],tmp[j,2]),rep(i,2),lwd=4,col=col[i])
    }
}


#---------------------------------------------------------------#
#           Plot Data Timespan with inversed y-axis             #
#---------------------------------------------------------------#
par(mar=c(2.1,5.1,1.1,1.1))
# Variable and Station names
lstn    <- c(1:21,24,26,28)
l2      <- length(lstn)
stn2    <- gsub("Sdtorg_","",gsub("Sdtminl_","",
                                  gsub("AT_","",gsub("Q_","",rev(stn[lstn])))))
stn2[stn2=="SedimentChamber"] <- "Sediment\nChamber"

lwd     <- 10 

#Plot
plot(c(as.POSIXct(t.start),as.POSIXct(t.end)),c(1,l2),type="n",
     xlab="",ylab="",yaxt="n",xaxt="n",xaxs="i",ylim=c(1.5,l2-.5))
# Background rectangles
rect(t.start-yr,l2-(lLC-.5)        ,t.end+yr,l2+1          ,col="grey80",border=NA)
rect(t.start-yr,l2-(lLC+lQ+lS-1)+.5,t.end+yr,l2-(lLC+lQ)+.5,col="grey80",border=NA)
# Grid and Axis
my.grid.year(as.POSIXct(t.start),as.POSIXct(t.end))
axis(2,seq(1:l2),stn2,las=1,cex.axis=.7,line=-.8,col=NA)
yr.seq <- seq(as.POSIXct("1993-01-01"),as.POSIXct("2016-01-01"),"year")
axis.POSIXct(3,yr.seq,yr.seq,tck=-0.01)
axis.POSIXct(3,yr.seq,yr.seq,"%Y",line=-.8,cex.axis=.6,col=NA)

n <- 0
for (i in lstn){
    n <- n+1
    # Glomfjord (Air temp. and Precip.)
    if(grepl("Glomfjord",datafile[i])){
        tmp <- read.csv(datafile[i],as.is=T,colClasses="POSIXct")
        lt  <- nrow(tmp)
        for (j in 1:lt){lines(c(tmp[j,1],tmp[j,2]),rep(l2-n+.8,2),
                              lwd=lwd,col=col[i],lend='butt')}
        
        tmp <- read.csv(datafile[22],as.is=T,colClasses="POSIXct")
        lt <- nrow(tmp)
        for (j in 1:lt){
            lines(c(tmp[j,1],tmp[j,2]),rep(l2-n+1.2,2),lwd=lwd,
                  col=col[i],lend='butt')}
        text(tmp[1,1]+12*30*24*3600,rep(l2-n+1.2,2),"Precip.",cex=.5,col="white")
    
    # Reipaa (Air temp. and Precip.)  
    }else if(grepl("Reipaa",datafile[i])){
        tmp <- read.csv(datafile[i],as.is=T,colClasses="POSIXct")
        lt  <- nrow(tmp)
        for (j in 1:lt){lines(c(tmp[j,1],tmp[j,2]),rep(l2-n+.8,2),
                              lwd=lwd,col=col[i],lend='butt')}
        
        tmp <- read.csv(datafile[23],as.is=T,colClasses="POSIXct")
        lt <- nrow(tmp)
        for (j in 1:lt){
            lines(c(tmp[j,1],tmp[j,2]),rep(l2-n+1.2,2),lwd=lwd,
                  col=col[i],lend='butt')}
        text(tmp[1,1]+12*30*24*3600,rep(l2-n+1.2,2),"Precip.",cex=.5,col="white")
    
    # Sediment concentration
    }else if(grepl("Sdt",datafile[i])){
            tmp <- read.csv(datafile[i],as.is=T,colClasses="POSIXct")
            lt  <- nrow(tmp)
            for (j in 1:lt){lines(c(tmp[j,1],tmp[j,2]),rep(l2-n+.8,2),
                                  lwd=lwd,col=col[i],lend='butt')}
            text(t.start+12*30*24*3600,rep(l2-n+.8,2),"Mineral",cex=.5)
            
            tmp <- read.csv(datafile[i+1],as.is=T,colClasses="POSIXct")
            lt <- nrow(tmp)
            for (j in 1:lt){
                lines(c(tmp[j,1],tmp[j,2]),rep(l2-n+1.2,2),
                      lwd=lwd,col=col[i],lend='butt')}
            text(t.start+12*30*24*3600,rep(l2-n+1.2,2),"Organic",cex=.5)
    # All the rest
    }else{
        
        tmp <- read.csv(datafile[i],as.is=T,colClasses="POSIXct")
        lt <- nrow(tmp)
        
        for (j in 1:lt){
            lines(c(tmp[j,1],tmp[j,2]),rep(l2-n+1,2),lwd=lwd,
                  col=col[i],lend='butt')
        }
    }
}

par(def.par)
xt <- 1.07
text(xt,1.05,"Load Cell",xpd=T,srt=-90)
text(xt,.45 ,"Discharge",xpd=T,srt=-90)
text(xt,0.0 ,"Air Temp.",xpd=T,srt=-90)
text(xt,-.33,"Sdt Conc.",xpd=T,srt=-90)
