
#---------------------------------------------------------------#
#                   APPLY CORRECTION FOR DISCHARGE              #
#               STATIONS AND COMPUTE DISCHARGE GRADIENT         #
#                         FINALLY SAVE DATA                     #
#                                                               #
#                                                               #
# Author: Pim Lefeuvre                         Date: 21/05/2014 #
#                                       Last Update: 19/06/2014 #
# Formerly "dQvsP/DischargeCorrection.R"                        #
#---------------------------------------------------------------#

###########################################
# # Clean up Workspace 
# rm(list = ls(all = TRUE))
# # Save "par" default
# def.par <- par(no.readonly = TRUE)
###########################################

Discharge_Correction <- function(path.wd,f.plot=F){
    
    ### Go to the following Path in order to access data files
    setwd(path.wd)
    Sys.setenv(TZ="UTC")  
    
    # Load libraries
    library(zoo)
    library(chron)
    library(lattice)
    
    # Load User functions
    source("../../UserFunction/subsample.R")
    source("../../UserFunction/juliandate.R")
    
    
    #########################################################################
    
    #---------------------------------------------------------------#
    #                       DISCHARGE DATA                          #
    #---------------------------------------------------------------#
    print("Load Discharge Data")
    
    # Load Discharge Data (hist=Daily, full/komp=Hourly)
    path        <- "../../Processing/Data/MetData/Discharge" 
    Q.Fc        <- read.zoo(sprintf("%s/FonndalC_Q_komp.csv",path), sep=",",
                            FUN=as.POSIXct)
    Q.Ff        <- read.zoo(sprintf("%s/FonndalF_Q_komp.csv",path), sep=",",
                            FUN=as.POSIXct) 
    Q.Sc        <- read.zoo(sprintf("%s/SedtChamber_Q_komp.csv",path), sep=",",
                            FUN=as.POSIXct) 
    
    Q.merged    <- merge(Q.Fc,Q.Ff,Q.Sc) 
    
    # Only plot if f.plot==T
    if(f.plot){
        # Data Overview per year
        for (i in seq(1998,2013)){
            Q.m.sub <- subsample(Q.merged,sprintf("%i-01-01",i),sprintf("%i-01-01",i+1),F)    
            plot(Q.m.sub,plot.type="single",type="p",pch=19,cex=0.2,
                 col=c("red","blue","black"), xlab=sprintf("Time [%i]",i))
            legend("topleft",c("FonndalC","FonndalF","SedtChamber"),pch=19,pt.cex=0.3,
                   col=c("red","blue","black"),cex=0.7)
        }
    }
    
    #---------------------------------------------------------------#
    #                       FONNDAL CORRECTION                      #
    #---------------------------------------------------------------#
    print("Apply Fonndal Correction")
    
    # Merge Fonndal Discharge and 
    Q.FcFf      <- merge(Q.Fc,Q.Ff) 
    
    # Standard Deviation and Difference with a linear approximation 
    # of gaps containing at the maximum "maxgap" points
    maxgap      <- 24
    sdFcFf      <- rollapply(Q.FcFf,2,sd,by.column=F) 
    dFcFf       <- na.approx(Q.Fc,maxgap=maxgap)-na.approx(Q.Ff,maxgap=maxgap)
    
    # Approximate gaps and add NA values when QFf and QFc are NAs
    Q.FcFf1     <- na.approx(Q.FcFf,maxgap=maxgap) 
    Q.FcFf1[is.na(Q.FcFf[,1]) & is.na(Q.FcFf[,2]),c(1,2)] <- NA
    
    # Mean of Fonndal Stations 
    Q.F         <- rollapply(Q.FcFf1,1,by.column=F,FUN=function(x){
        if(!is.na(x[1]) & !is.na(x[2])){mean(x)} 
        else{mean(x,na.rm=T)} }) 
    # Does not make sense to do mean when use a window of 1 value
    
    # Only plot if f.plot==T
    if(f.plot){
        # Plot Different time series
        plot(merge(Q.F,Q.FcFf,dFcFf),plot.type="single",type="p",pch=list(19,20,20,20),
             col=list("red","cyan","blue","black"),cex=1,
             xlim=c(as.POSIXct("2006-05-01"),as.POSIXct("2006-08-01")))
        
        # List of Dates where Fonndal Discharge behaved strangely (drops)
        # Not Caused by the merging of the Fonndal data sets
        #         c(as.POSIXct("1999-06-25"),as.POSIXct("1999-07-05"))
        #         c(as.POSIXct("2005-06-20"),as.POSIXct("2005-07-01"))
        #         c(as.POSIXct("2005-09-01"),as.POSIXct("2005-09-10"))
        
        # Plot Distribution ## Fc is relatively higher than Ff ##
        hist(dFcFf,col="grey",nclass=200,freq=F,ylim=c(0,12),
             main=sprintf("Hist. of Difference between QFonndals with maxgap=%i",maxgap))
        curve(dnorm(x,mean=mean(dFcFf,na.rm=T),sd=sd(dFcFf,na.rm=T)),
              col=2,lty=2,lwd=2,add=T)
        
        # Final Product
        plot(merge(Q.F,Q.FcFf),type="p",pch=".")
    }
    
    #---------------------------------------------------------------#
    #                   SEDT CHAMBER CORRECTION                     #
    #---------------------------------------------------------------#
    print("Apply Sediment Chamber Correction")
    
    # Remove values greater than 30m^2.sec from Q.Sc, which represents 
    # 5% of the whole dataset (obtained with:)
    sum(Q.Sc>30,na.rm=T)/sum(Q.Sc<=30,na.rm=T)*100
    Q.Sc[Q.Sc>30]   <- NA
    
    
    # Only plot if f.plot==T
    if(f.plot){
        plot(Q.Sc,type="p",pch=".")
        points(Q.Sc[Q.Sc>30],pch=".",col="red")
    }
    
    
    #################################################
    # Detailled Corrections between May and September
    #################################################
    ## 1998
    Q.Sc[index(Q.Sc)==as.POSIXct("1998-09-23 14:00")] <- NA
    Q.Sc[index(Q.Sc)>=as.POSIXct("1998-09-24 09:00") & index(Q.Sc)<=as.POSIXct("1998-09-24 13:00")] <- NA
    ## 1999
    Q.Sc[index(Q.Sc)>=as.POSIXct("1999-09-07 13:00") & index(Q.Sc)<=as.POSIXct("1999-09-07 15:00")] <- NA
    ## 2000
    Q.Sc[index(Q.Sc)>=as.POSIXct("2000-09-27 08:00") & index(Q.Sc)<=as.POSIXct("2000-09-29 09:00")] <- NA
    ## 2001
    # Nothing to correct
    ## 2002
    # No data
    ## 2003
    Q.Sc[index(Q.Sc)==as.POSIXct("2003-05-13 06:00")] <- NA
    Q.Sc[index(Q.Sc)>=as.POSIXct("2003-05-19 09:00") & index(Q.Sc)<=as.POSIXct("2003-05-23 12:00")] <- NA
    ## 2004
    Q.Sc[index(Q.Sc)>=as.POSIXct("2004-09-10 12:00") & index(Q.Sc)<=as.POSIXct("2004-09-10 14:00")] <- NA
    ## 2005
    Q.Sc[index(Q.Sc)>=as.POSIXct("2005-09-08 13:00") & index(Q.Sc)<=as.POSIXct("2005-09-08 16:00")] <- NA
    ## 2006
    Q.Sc[index(Q.Sc)>=as.POSIXct("2006-09-18 13:00") & index(Q.Sc)<=as.POSIXct("2006-09-19 13:00")] <- NA
    ## 2007
    # Nothing to correct
    ## 2008
    # Nothing to correct
    ## 2009
    # Nothing to correct
    ## 2010
    Q.Sc[index(Q.Sc)>=as.POSIXct("2010-04-28 21:00") & index(Q.Sc)<=as.POSIXct("2010-05-05 16:00")] <- NA
    ## 2011
    # Nothing to correct
    ## 2012
    Q.Sc[index(Q.Sc)>=as.POSIXct("2012-07-03 05:00") & index(Q.Sc)<=as.POSIXct("2012-07-03 06:00")] <- NA
    ## 2013
    Q.Sc[index(Q.Sc)>=as.POSIXct("2013-09-23 11:00") & index(Q.Sc)<=as.POSIXct("2013-09-24 09:00")] <- NA
    #################################################
    
    # Only plot if f.plot==T
    if(f.plot){
        # Plot After correction
        points(Q.Sc,type="p",pch=19,cex=0.1,col="red")
    }
    
    #---------------------------------------------------------------#
    #                      SUBGLACIAL DISCHARGE                     #
    #---------------------------------------------------------------#
    print("Compute Subglacial Discharge")
    
    # Compute Subglacial Discharge
    Q.Sub           <- Q.Sc-Q.F
    
    # Only plot if f.plot==T
    if(f.plot){
        hist(Q.Sub[Q.Sub<=0])
        plot(Q.Sub[!is.na(Q.Sub)])
    }
    
    # Remove Negative values occuring between 2005 and 2006
    Q.Sub[Q.Sub<=0] <- 0
    
    # Plot after correction. Only if f.plot==T
    if(f.plot){points(Q.Sub,col="red",pch=".")}
    
    # Overview per year
    Q.corrd     <- merge(Q.Sc,Q.F,Q.Sub) 
    
    # Save
    t.start     <- juliandate(start(Q.corrd))
    t.end       <- juliandate(end(Q.corrd))
    filename    <- sprintf("Q.Sc.F.Sub_corrected_%s-%s.csv",t.start,t.end)
    write.zoo(Q.corrd,file=sprintf("%s/%s",path,filename),sep=",")
    
    
    # Only plot if f.plot==T
    if(f.plot){
        for (i in seq(1998,2013)){
            Q.m.sub <- subsample(Q.corrd,sprintf("%i-01-01",i),
                                 sprintf("%i-01-01",i+1),F)    
            plot(Q.m.sub,plot.type="single",type="p",pch=19,cex=0.2,
                 col=c("red","black","blue"), xlab=sprintf("Time [%i]",i))
            legend("topleft",c("SedtChamber","Fonndal(F-C)","Subglacial"),pch=19,
                   pt.cex=0.3,col=c("red","black","blue"),cex=0.7)
        }
    }
    
    
    #---------------------------------------------------------------#
    #                       DISCHARGE GRADIENT                      #
    #---------------------------------------------------------------#
    print("Compute Discharge Gradient")
    
    # Gradient assuming dt=1hour (lag=2 means 2hrs diff.)
    dt          <- 2 
    dQ          <- diff(Q.corrd,lag=dt)/dt
    
    # Save
    filename    <- sprintf("dQ%ihr.Sc.F.Sub_corrected_%s-%s.csv",dt,t.start,t.end)
    write.zoo(dQ,file=sprintf("%s/%s",path,filename),sep=",")
    
    # Only plot if f.plot==T
    if(f.plot){
        plot(dQ,plot.type="single",type="p",pch=19,cex=0.2,
             col=c("red","black","blue"),ylim=c(-8,8))
        
        # Overview per year
        for (i in seq(1998,2013)){
            Q.m.sub <- subsample(dQ,sprintf("%i-01-01",i),sprintf("%i-01-01",i+1))    
            plot(Q.m.sub,type="p", ylim=c(-5,5),pch=19,cex=0.2,
                 col=c("red","black","blue"), xlab=sprintf("Time [%i]",i))
            legend("topleft",c("SedtChamber","Fonndal(F-C)","Subglacial"),pch=19,
                   pt.cex=0.3,col=c("red","black","blue"),cex=0.7)
        }
    }
}