
###################################################
####        Plot HOURLY Discharge Data         #### 
###################################################

# # Input
# year      <- 2001
# filename  <- "Data/MetData/Discharge/Engabrevatn_Q_full.csv"
# path.wd   <- "~/Desktop/DischargeSSL_corrections" 
# path.wd means path to the working directory

###########################################
# Clean up Workspace
# rm(list = ls(all = TRUE))
############################################

Plot_Discharge_hourly <- function(filename="Data/Discharge/Q.Sub.orig-pred.csv",
                                  year=2003,path.wd)
{
    ############################################
    # Processing Directory
    setwd(path.wd)
    Sys.setenv(TZ="UTC")  
    
    # Load libraries
    library(chron)
    library(zoo)
    library(RColorBrewer)
    library(signal)
    
    # Load User functions
    source("../../UserFunction/subsample.R")
    source("../../UserFunction/toyear.R")  
    
    ############################################
    # LOAD DATA
    
    # Text Output
    print("...")
    print(sprintf("FILE:%s YEAR:%i",filename,year))
    print("...")
    
    # Extract Station Name
    name.st <- "Subglacial"#strsplit(basename(filename),"_")[[1]][1]
    n.month <- 1
    
    # Check if Data already exist (Save Time)
    if ( !exists("Q") || !exists("Q.mean") )
    { 
        Q       <- read.zoo(filename,sep=",",FUN = as.POSIXct,header=T) 
        Q.pred  <- cbind(Q[,2])
        Q.comb  <- cbind(Q[,3])
        
        # Time Parameters
        hour    <- 1      # Hour is the unit as sampling freq. is in hour
        day     <- 24*hour  # in hour
        
        # Running Mean
        win     <- n.month*30*day # 2*30*day = 2 months running mean
        mean.na <- function(x){weighted.mean(x,w=bartlett(win),na.rm=T)}
        Q.mean  <- rollapply(Q.comb,win,mean.na)
        
    }else{
        cat("Skip Loading Q Data \n")
    }
    
    ##### Average for the whole period
    # Gather data of the whole period within a defined year
    Q.ref    <- toyear(Q.comb,2000)
    Q.sub    <- toyear(Q.mean,2000)
    
    # Compute Daily Average for the whole period
    Q.day     <- aggregate(Q.ref,
                           as.POSIXct(trunc(index(Q.ref),units="days")),
                           function(x) mean(x,na.rm=TRUE))
    
    ############################################
    ##### Individual Year comparisons
    sub.start   <- sprintf("%i-01-01",year)
    sub.end     <- sprintf("%i-01-01",year+1) 
    t.start     <- as.POSIXct(sub.start) 
    t.end       <- as.POSIXct(sub.end)
    
    # Create OUTPUT and rename list with original names
    Output          <- list(Q,Q.pred,Q.comb,Q.mean)
    names(Output)   <- c("Q","Q.pred","Q.comb","Q.mean")
    #####
    
    ############################################
    # Check if there are dates for this time period
    if ( max(index(Q),na.rm=T)  < t.start || min(index(Q),na.rm=T) > t.end){
        print("NO DATA for the current year")
        return(Output)
    }
    
    # Subsample
    Q.comb.sub  <- subsample(Q.comb,sub.start,sub.end,F)
    Q.pred.sub  <- subsample(Q.pred,sub.start,sub.end,F)
    Q.m.sub     <- subsample(Q.mean,sub.start,sub.end,F)
    
    
    # Check if there are values within the subsampled time series
    if (length(Q.comb.sub[!is.na(Q.comb.sub)]) == 0 ){
        print("NO DATA for the current year")
        return(Output)
    }
    
    # Daily Mean
    daily.date  <- as.POSIXct(trunc(index(Q.m.sub),units="days"))
    Q.m.day     <- aggregate(Q.m.sub,daily.date,function(x) mean(x,na.rm=TRUE))
    
    # Reformat Dates and Add smoothed line
    Q.day.sub   <- toyear(Q.day,year)
    Q.day.sub   <- aggregate(Q.day.sub,as.POSIXct(index(Q.day.sub)),
                             function(x) x[1])
    
    Q.day.smooth<- zoo(unlist(lowess(Q.day.sub,f=.05)[2]),
                       as.POSIXct(index(Q.day.sub)))
    Q.day.smooth<- aggregate(Q.day.smooth,index(Q.day.smooth)+3600*12,function(x) x[1])
    
    
    ############################################
    # Plot Parameters
    ticks.min   <- seq(t.start,t.end,by="2 days")
    ticks.maj   <- seq(t.start,t.end,by="months")
    t.format    <- "%b"
    xlab        <- sprintf("Time [Month %i]",year)
    lwd         <- 2
    col         <- c("black","grey75","grey") 
    lty         <- 2 
    
    ymin        <- 0#min(Q.ref,na.rm=T)
    ymax        <- 40#max(Q.ref,na.rm=T)
    
    #################
    # Save Plot
    fname    <- sprintf("Plots/Discharge_Hr/%s_Discharge_Hr_%i.pdf",
                        name.st,year)
    pdf(file=fname,height=2.5)
    
    par(oma=c(1,1,1,1),cex=0.7)
    # Remove NA values
    Q.pred.sub   <- Q.pred.sub[!is.na(Q.pred.sub)]
    Q.comb.sub   <- na.approx(Q.comb.sub,maxgap=24*1)
    #     Q.comb.sub   <- Q.comb.sub[!is.na(Q.comb.sub)]
    
    ## Plot 1: Hourly Data with running mean and total mean (whole period)
    plot(Q.day.smooth,type="l",#type="p",pch=".",
         main="Hourly Subglacial Discharge",
         xlab=xlab,ylab=expression("Discharge [" ~ m^3 ~ s^-1~"]"),
         xaxt="n",yaxt="n", xaxs="i",
         xlim=c(t.start,t.end),ylim=c(ymin,ymax),col=col[3],lwd=2,lty=lty)  
    lines(Q.comb.sub,col=col[1],lwd=2)
    points(Q.pred.sub,col=col[2],pch=20,cex=0.25)
    
    # Axis
    axis.POSIXct(side=1,at=ticks.min,labels=F,tcl=-0.2)
    axis.POSIXct(side=1,at=ticks.maj,labels=format(ticks.maj,format=t.format))
    axis(side=2,at=seq(0,ymax,1),labels=F,tcl=-0.2)
    axis(side=2,at=seq(0,ymax,10),labels=T)
    
    # Legend
    text.leg  <- c("Observed Hourly Discharge","Modeled Hourly Discharge",
                   "Long Term Average")
    legend("topleft", legend=text.leg, bg="white", col=col,lwd=c(2,NA,2),cex=0.6,
           lty=c(1,NA,3),pch=c(NA,20,NA))
    #################
    # Close PDF
    dev.off()
    
    #####
    # Export output
    cat(">> Outputs are:",names(Output),"\n")
    return(Output)
    
    
}

