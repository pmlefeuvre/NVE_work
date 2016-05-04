
#---------------------------------------------------------------#
#                   PLOT LOAD CELL DATA WITH                    #
#   METEOROLOGICAL AND HYDROLOGICAL DATA FROM NEARBY STATIONS   #
#        -- PRESSURE, DISCHARGE AND AIR TEMPERATURE --          #
#                                                               #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2015-04-23 #
#                                       Last Update: 2016-04-20 #
#                                                               #
# Updates:                                                      #
# - 2016-04-14: Reformat to give code to NVE.                   #
#       Simplify the code and make function that extracts and   #
#       plots LC, Met, and Hydro data together.                 #
# - 2016-04-20: Hydro/Met. stations are called from the function#
#       Data downloaded directly from Hydra2 are used instead   #
#       of product resuting from another processing code.       #
#       eKlima data have to be merged before use (eKlima folder)#
#       f_Plot_LCs_MetHydro3.R becomes f_Plot_LCs_MetHydro.     #
#                                                               #
# Formerly called "Plot_SpringEvent_Skjaeret.R" and versions++  #
#---------------------------------------------------------------#

# # INPUT PARAMETERS FOR TESTING THE FUNCTION
# sub.start   <- "2003-07-01"
# sub.end     <- "2003-07-31"
# LCname      <- c("LC6","LC4")#"LC97_1","LC97_2",
# type        <- "15min_mean"
# Q.station   <- "Fonndal_crump"#"Fonndal_fjell"
# AT.station  <- "Glomfjord"#"Reipaa","Engabrevatn","Skjaeret"
# PP.station  <- "Glomfjord"#"Reipaa"
# f.plot      <- FALSE


##########################################
##########################################
Plot_LCs_MetHydro <- function(sub.start="2003-07-13",sub.end="2003-07-31",
                              LCname=c("LC97_1","LC97_2"),type="15min_mean",
                              Q.station="Fonndal_crump",AT.station="Glomfjord",
                              PP.station="Glomfjord",f.plot=FALSE){
    
    # ##########################################
    # # Clean up Workspace
    # rm(list = ls(all = TRUE))
    # # Save "par" default
    def.par <- par(no.readonly = TRUE)
    # ##########################################
    
    # Detect Operating System
    if(.Platform$OS.type == "unix"){   HOME="/Users/PiM/Desktop"}
    if(.Platform$OS.type == "windows"){HOME="//nve/fil/h/HB/Personlige mapper/PiM"}
    
    # Go to the following Path in order to access data files
    setwd(sprintf("%s/NVE_work/Processing/",HOME))
    Sys.setenv(TZ="UTC")      
    
    # Load libraries (!!! NEED TO BE PRE-INSTALLED !!!)
    library(zoo)
    library(chron)      
    library(lattice) 
    library(lubridate) #cmd: year   
    
    # Load User Functions
    source("f_Load_ZooSub_month.R")
    source("../UserFunction/juliandate.R")
    source("../UserFunction/subsample.R")
    source("../UserFunction/my.grid.R")
    
    
    #########################################################################
    # Time parameters
    t.start     <- as.POSIXct(sub.start)
    t.end       <- as.POSIXct(sub.end)
    
    # Reload the data if station names have changed
    if ( !exists("old.station") ){
        print("old.station does not Exist")
        old.station   <-NULL
    }
    
    #---------------------------------------------------------------#
    #                       Load DISCHARGE DATA                     #
    #---------------------------------------------------------------#
    Q.all.station <- c("Fonndal_crump","Fonndal_fjell")
    # Load hourly discharge (Original Data)
    if (!exists("Q.Sub") || Q.station!=old.station[1]){
        # Path defines whether Komplett or Historisk data are used
        Q.path  <- "Data/MetData/Discharge/KomplettNVEdata_20140606/"
        
        # Load Discharge data and reformat in zoo time series    
        # Sediment Chamber
        filename<- list.files(Q.path,"sedimentkammer",full.names=T)
        Q.Sc    <- read.csv(filename,F,";", colClasses=c("POSIXct","numeric"),skip=1,
                            as.is=T,na.strings = "-9999.0000",blank.lines.skip=T)
        Q.Sc    <- zoo(Q.Sc[,2],Q.Sc[,1])
        Q.Sc[Q.Sc>30] <- NA
        
        # Fonndal_fjell or Fonndal_crump
        filename<- list.files(Q.path,Q.station,full.names=T)
        Q.F     <- read.csv(filename,F,";", colClasses=c("POSIXct","numeric"),skip=1,
                            as.is=T,na.strings = "-9999.0000",blank.lines.skip=T)
        Q.F     <- zoo(Q.F[,2],Q.F[,1])
        
        # Compute subglacial discharge
        Q.Sub       <- merge(Q.Sc,Q.F)
        Q.Sub$Q.F   <- na.approx(Q.Sub$Q.F,maxgap=6,na.rm=F) 
        Q.Sub       <- Q.Sub$Q.Sc-Q.Sub$Q.F
        
        # Assign variable to avoid reloading
        assign("Q.Sc" ,Q.Sc ,envir= .GlobalEnv)
        assign("Q.F"  ,Q.F  ,envir= .GlobalEnv)
        assign("Q.Sub",Q.Sub,envir= .GlobalEnv)
        
    }
    
    #---------------------------------------------------------------#
    #                       Load TEMPERATURE DATA                   #
    #---------------------------------------------------------------#
    AT.all.station <- c("Glomfjord","Reipaa","Engabrevatn","Skjaeret")
    if (!exists("AirT") || AT.station!=old.station[2]){
        # Load Air Temperature data and reformat in zoo time series 
        
        # Glomfjord or Reipaa
        if (AT.station %in% c("Glomfjord","Reipaa")){
            AT.path <- "Data/MetData/AirTemp/eKlima"
            AirT   <- read.zoo(sprintf("%s/%s_AT_full.csv",AT.path,AT.station),
                               sep=",",FUN=as.POSIXct)
        }
        
        # Engabrevatn or Skjaeret (2 datasets)
        if (AT.station %in% c("Engabrevatn","Skjaeret")){
            AT.path <- "Data/MetData/AirTemp/KomplettNVEdata_20140606"
            filename<- list.files(AT.path,AT.station,full.names=T)
            
            # Define which data to load for Skjaeret station 
            if (AT.station=="Skjaeret" && year(t.start)<2009){
                filename <- filename[1]
                print(sprintf("LOAD: %s -- for period BEFORE 2009",basename(filename)))
            }else{
                filename <- filename[2]
                print(sprintf("LOAD: %s -- for period AFTER 2009",basename(filename)))}
            
            # Load and Zoo
            AirT   <- read.csv(filename,F,";", colClasses=c("POSIXct","numeric"),skip=1,
                               as.is=T,na.strings = "-9999.0000",blank.lines.skip=T)
            AirT   <- zoo(AirT[,2],AirT[,1])
        }
        
        
        # Assign variable to avoid reloading
        assign("AirT",AirT,envir= .GlobalEnv)
    }
    
    #---------------------------------------------------------------#
    #                   Load PRECIPITATION DATA                     #
    #---------------------------------------------------------------#
    PP.all.station <- c("Glomfjord","Reipaa")
    if (!exists("PP") || PP.station!=old.station[3]){
        # Path defines whether Komplett or Historisk data are used
        PP.path <- "Data/MetData/Precip/eKlima"
        # Load Precipitation data
        PP      <- read.zoo(sprintf("%s/%s_P24_full.csv",PP.path,PP.station),
                            sep=",",FUN=as.POSIXct)
        
        # Correct for conventional measurement of PP, 
        # that records rainfall for the last 24 hours.
        index(PP)<- index(PP) - 3600*24
        
        # Assign variable to avoid reloading
        assign("PP",PP,envir= .GlobalEnv)
        
        # Check if there is data
        # if (length(PP))
    }
    
    
    # Assign variable to reload only if called stations are different from before
    old.station <- c(Q.station,AT.station,PP.station)
    assign("old.station",old.station,envir= .GlobalEnv)
    
    #---------------------------------------------------------------#
    #                           SUBSAMPLE                           #
    #---------------------------------------------------------------#
    # Subsample each time series
    Q.Sub.sub   <- window(Q.Sub, start=sub.start,end=sub.end)
    Q.F.sub     <- window(Q.F,   start=sub.start,end=sub.end)
    AirT.sub    <- window(AirT,  start=sub.start,end=sub.end)
    PP.sub      <- window(PP,    start=sub.start,end=sub.end)
    
    
    #---------------------------------------------------------------#
    # Check if there is data for Air Temperature
    if(all(is.na(AirT.sub))){
        err <- paste(AT.all.station[!AT.all.station %in% AT.station],collapse=" or ")
        stop(sprintf("\nNO Air Temp. DATA at %s\nTRY with another station: %s",
                     AT.station,err))}
    # Check if there is data for Discharge
    if(all(is.na(Q.F.sub))){
        err <- paste(Q.all.station[!Q.all.station %in% Q.station],collapse=" or ")
        stop(sprintf("\nNO Discharge DATA at %s\nTRY with another station: %s",
                     Q.station,err))}
    # Check if there is data for Precipitation
    if(all(is.na(PP.sub))){
        err <- paste(PP.all.station[!PP.all.station %in% PP.station],collapse=" or ")
        stop(sprintf("\nNO Precip. DATA at %s\nTRY with another station: %s",
                     PP.station,err))}
    #---------------------------------------------------------------#
    
    
    #---------------------------------------------------------------#
    #                   Load PRESSURE/LOAD CELL DATA                #
    #---------------------------------------------------------------#
    # DATE CORRECTION
    if(t.start > as.POSIXct("2012-01-01")){
        # Load Pressure Data
        LC.reg.sub  <- Load_ZooSub_month(t.start-24*3600,sub.end,type=type)
        LC.n        <- which(names(LC.reg.sub) %in% LCname) 
        LC          <- LC.reg.sub[,LC.n,drop=F]
        
        print("Add a day to index of LCs due to delay in datalogger clock after 2012")
        index(LC)        <- index(LC)+24*3600
    } else {
        # Load Pressure Data
        LC.reg.sub  <- Load_ZooSub_month(sub.start,sub.end,type=type)
        LC.n        <- which(names(LC.reg.sub) %in% LCname) 
        LC          <- LC.reg.sub[,LC.n,drop=F]
    }
    
    
    
    #---------------------------------------------------------------#
    #         PLOT DISCHARGE, GRADIENT AND  PRESSURE DATA           #
    #---------------------------------------------------------------#
    
    # Save Plot
    if (f.plot){
        # Make folder where will be saved the data
        path        <- sprintf("Plots/Pressure_MetData")
        dir.create(path,showWarnings = FALSE)
        # Include all figures in a pdf file!
        filename    <- sprintf("Pressure_MetData_%s%s_%s-%s.pdf",
                               LCname[1],LCname[2],
                               juliandate(t.start),juliandate(t.end))
        pdf(sprintf("%s/%s",path,filename),height=5)
    }
    
    
    # Plot Parameters
    col         <- c("red","black","blue")
    col2        <- c("grey60","black")#,"red","orange","cyan","blue","grey")
    lty         <- c(1,1,3,3,3,3)
    text.leg    <- c("Subglacial","Fonndal") 
    
    Q.max       <- max(Q.Sub.sub,na.rm=T) 
    AT.min      <- min(AirT.sub,na.rm=T)
    AT.max      <- max(AirT.sub,na.rm=T)
    PP.max      <- max(PP.sub,na.rm=T)
    LC.ymin     <- max(-0.1,min(LC,na.rm=T))
    LC.ymax     <- max(LC,na.rm=T)
    
    # Layout Parameters
    par(mfrow=c(3,1))
    left        <- 5 
    right       <- 4 
    
    ##### 1ST PLOT #####
    # Plot Precipitation and Air Temperature
    par(mar=c(0,left,2.1,right))
    plot(c(start(PP.sub),end(PP.sub)),c(0,PP.max),xaxt="n",col="white",
         yaxt="n",ylab="",xlim=c(t.start,t.end),xaxs="i")
    my.grid.month.simple(t.start,t.end)
    # Process Precipiation values for plot
    t.PP <- c(start( PP.sub)-3600*24,rep(index(PP.sub),each=2),
              end(PP.sub)+3600*24,end(PP.sub)+3600*24,end(PP.sub)+2*3600*24)
    y.PP <- c(0,0,rep(PP.sub,each=2),0,0)
    # NAs are given a negative value
    y.PP[is.na(y.PP)] <- (-.02)*PP.max
    # Plot Precipitation 
    polygon(t.PP,y.PP,xaxt="n",yaxt="n",
            ylim=c(0,PP.max),xlim=c(t.start,t.end),
            ylab="",xlab="Date",col="grey75")
    axis(4,cex=0.1)
    mtext("Precip. [mm]",4,2.3,cex=0.7)
    
    # Plot Air temperature
    par(new=T)
    plot(AirT.sub,xaxt="n",xlim=c(t.start,t.end),
         lwd=2,ylab="Air Temp [°C]",xaxs="i")
    abline(h=0,lty=2)
    points(AirT.sub,pch=19,cex=0.2)
    
    
    ##### 2ND PLOT #####
    # Plot Discharge
    par(mar=c(1,left,1,right))
    plot(na.approx(Q.F.sub),col=col2[1],xaxt="n",xlim=c(t.start,t.end),lwd=1,lty=3,
         ylim=c(0,Q.max),ylab=expression(paste(Q," [",m^3,s^{-1},"]")),xaxs="i")
    # Background Grid
    my.grid.month.simple(t.start,t.end)
    # Points/Lines
    points(Q.F.sub,col=col2[1],pch=19,cex=0.3)
    lines(na.approx(Q.Sub.sub),lty=3,col=col2[2])
    points(Q.Sub.sub,col=col2[2],pch=19,cex=0.3)
    
    # Legend
    legend("topright",text.leg,pch=19,pt.cex=0.5,col=col2[c(2,1)],cex=0.7,lty=3,bg="white")
    
    ##### 3RD PLOT #####
    # Plot Basal Pressure
    par(mar=c(2.1,left,0,right))
    plot(c(t.start,t.end),c(LC.ymin,LC.ymax),col="white",xaxt="n",
         xlim=c(t.start,t.end),ylim=c(LC.ymin,LC.ymax),xaxs="i",
         xlab="Date",ylab="P [MPa]")
    
    
    # Background Grid
    my.grid.month.year(t.start,t.end)
    
    # PLot LC data
    LC.ln <- length(LCname)
    if(LC.ln>1){lines(LC[,2],lwd=2,col=col2[1])}
    lines(LC[,1],lwd=2,col=col2[2])
    
    
    # Legend
    legend("topright",names(LC[,seq(LC.ln,1),drop=F]),lwd=2,col=col2,lty=lty,cex=0.7,bg="white")
    
    par(def.par)
    ########################################
    # End PDF file
    if (f.plot){dev.off()}
    
} 


#### ARCHIVE
