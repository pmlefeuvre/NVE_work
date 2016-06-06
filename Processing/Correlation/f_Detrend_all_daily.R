

##########################################################################
##               Apply Correlation for Detrended Data                   ##
##      between one reference LC (usually LC6) and all the others       ##
##             Plot Seasonal Variability for a couple of LCs            ##
##                                                                      ## 
## Author: Pim                                  Last Update: 2014.08.28 ##
## Only difference with f_Detrend_all2.R is that it computes only one   ##
## value per day instead of the overlapping running window              ##
## In the cmd rollapply, this is done with "by=win.corr"                ##
##########################################################################

###########################################
# # Clean up Workspace
#   rm(list = ls(all = TRUE))
###########################################

f_Detrend_daily  <- function(sub.start="01/01/2000 00:00",
                            sub.end=  "01/01/2001 00:00",
                            win.corr=96) 
{
    
    ### Go to the following Path in order to access data files
    setwd("/Users/PiM/Desktop/PhD/Data Processing/Load Cells/Processing")
    Sys.setenv(TZ="UTC")  
    
    # Load libraries
    library(zoo)
    library(lattice)
    library(signal)
    library(psych)
    
    # Load User Functions
    source('~/Desktop/PhD/Data Processing/Load Cells/Processing/f_Load_ZooSub_month.R')
    source('~/Desktop/PhD/Data Processing/R/juliandate.R')
    source('~/Desktop/PhD/Data Processing/R/barplot_TimeFactors.R')
    
    # Time parameters
    #     sub.start   <- "01/01/2001 00:00"
    #     sub.end     <- "01/01/2002 00:00"
    t.start     <- as.POSIXct(sub.start,format="%m/%d/%Y %H:%M")
    t.end       <- as.POSIXct(sub.end,format="%m/%d/%Y %H:%M")
    
    # Interval
    hour    <- 60 #min
    day     <- 24 #hours 
    #     win.corr<- day*(hour/15)
    
    ##################         LOAD & CHECK        ##########################
    # Load Data and create LC.reg.sub to avoid reloading the data
    LC.reg.sub  <- Load_ZooSub_month(sub.start,sub.end,type="15min_mean")
    
    # Parameters
    LCnames     <- names(LC.reg.sub)
    ln          <- length(LCnames)
    
    # Check if LC.reg.sub exists
    if ( length(LC.reg.sub) == 0 ) {
        print("Number of points < 4 (in the sampled dataset)")
        print(">>>>>>     SKIPPING      <<<<<<<")
        Output  <- NULL
        return(Output)} ## END   
    
    # Identify which columns have a number of values greater than win.corr 
    a <- NULL
    for (i in 1:ln){a <- cbind(a,(sum(!is.na(LC.reg.sub[,i])) > win.corr)*i)}
    
    # Check if there is more than "win.corr" values in the whole dataset
    if ( sum(a) == 0) {
        print(sprintf("Number of points < %i (in the sampled dataset)",win.corr))
        print(">>>>>>     SKIPPING      <<<<<<<")
        Output  <- NULL
        return(Output)}
    
    # Remove columns that have a number of values lower than "win.corr"
    LC.reg.sub  <- LC.reg.sub[,a[a>0]]
    LCnames     <- LCnames[a[a>0]]
    ln          <- length(LCnames)
    
    ##################         LOAD & CHECK        ##########################
    
    
    ##################            PLOT             ##########################
    #     # Plot Parameters
    #     col         <- c("black","orange","lightblue","red")
    #     pch         <- 19
    #     cex         <- 0.2
    #     xlim        <- c(t.start,t.end)
    #     
    #     # Ticks
    #     t.diff      <- t.end - t.start
    #     monthINdays <- 30.5
    #     
    #     if (t.diff > 4*monthINdays){
    #         ticks.min   <- seq(t.start,t.end,by="months")
    #         ticks.maj   <- seq(t.start,t.end,by="2 months")
    #         t.format    <- "%b %Y"
    #         xlab        <- "Time [Month Year]"
    #         fname       <- "Year"
    #     }else{
    #         ticks.min   <- seq(t.start,t.end,by="days")
    #         ticks.maj   <- seq(t.start,t.end,by="5 days")
    #         t.format    <- "%d %b"
    #         xlab        <- sprintf("Time [Day Month %s]",format(t.start,"%Y"))
    #         fname       <- "Month"
    #     }    
    ##################            PLOT              ##########################
    
    ########################################
    ####    PRESSURE AND CORRELATION    ####
    ########################################
    # Correlation Function
    
    kor.test <- function(x) {
        tmp <- corr.test(x)
        cor <- signif(tmp[[1]][3],4)
        p   <- signif(tmp[[4]][3],4)
        out <- cbind(cor,p)
        names(out) <- c("cor","p")
        return(out)
    }
    
    
    # Load Cell Loop
    for (i in 1:ln)
    {
        # Extract Column
        a       <- which(names(LC.reg.sub)==LCnames[i])
        print(sprintf("CORR: LCnames: %s => column %i",LCnames[i],a))
        
        # Compute Corr and P-value
        cor.p   <- rollapply(LC.reg.sub[,c(1,a)], win.corr, kor.test,
                             by = win.corr, by.column = F)
        
        # ReAssign
        corr.15min      <- cor.p[,1]
        Pvalue.corr     <- cor.p[,2]   
        
        # Save Correlation
        if(i==1){
            corr.15min.all  <- corr.15min
            Pvalue.corr.all <- Pvalue.corr 
        }else{
            corr.15min.all  <- merge(corr.15min.all,corr.15min)
            Pvalue.corr.all <- merge(Pvalue.corr.all,Pvalue.corr)
        }
    }
    
    # Rename Columns
    names(corr.15min.all)   <- LCnames
    names(Pvalue.corr.all)  <- LCnames
    
    ##################            PLOT              ##########################
    # Save Plots
    #     path        <-"Plots/Corr/"
    #     filename    <-sprintf("Corr2%s_all.%s-%s_wmNA_wc%i.pdf",fname,
    #                           juliandate(t.start),
    #                           juliandate(t.end),win.corr)
    #     pdf(file=paste(path,filename,sep="/"),height=4)
    
    #     ##########
    #     # PLOT all LC to analyse visual correlations
    #     
    #     # Plot Parameters
    #     xlabel  <- sprintf("Time [year=%s]",format(t.start,"%Y"))     
    #     xticks  <- seq(t.start,t.end,"2 months")
    #     x.ticks.lab <- format(xticks,"%d %b")
    #     ylim    <- list(c(0,3))        
    #     yticks  <- list(rep(seq(0,3,1),ln))
    #     
    #     # Panel Plot function
    #     p              <- function(x, y,...) {
    #         panel.grid(h=-1, v=-1,x=x,y=y);
    #         panel.xyplot(x, y,pch=19,lwd=0,main=NULL,cex=0.1,axt="n")
    #     }
    #     
    #     # Plot Lattice
    #     obj <- xyplot(LC.15min.all, width="sj", strip=T, panel = p,
    #                   scales=list(y=list(relation='free', rot=0),#limits=ylim),
    #                               x=list(limits=c(t.start-day,t.end+day),at=ticks.maj
    #                                      ,labels=format(ticks.maj,format=t.format)),
    #                               cex=c(0.8,0.8), alternating=3),
    #                   par.strip.text=list(cex=0.7),
    #                   xlab=xlabel)
    #     
    #     # Print Final
    #     print(obj)
    
    # Close PDF
    #     dev.off()   
    ##################            PLOT             ##########################
    
    
    
    ##################           OUTPUT            ##########################    
    ###### Output for Raw Dat
    # Path and Filename
    path        <-"Data/Corr/"
    filename    <-sprintf("Corr2%s_all2daily.%s-%s_wmNA_wc%i.csv","FullLCs",
                          juliandate(t.start),
                          juliandate(t.end),win.corr)
    path.file<-paste(path,filename,sep="")
    
    # Save Output
    write.zoo(corr.15min.all,file=path.file,sep=",",na="")
    
    # Path and Filename
    filename    <-sprintf("Pvalue2%s_all2daily.%s-%s_wmNA_wc%i.csv","FullLCs",
                          juliandate(t.start),
                          juliandate(t.end),win.corr)
    path.file<-paste(path,filename,sep="")
    
    # Save Output
    write.zoo(Pvalue.corr.all,file=path.file,sep=",",na="")    
    
    # END
    return(LC.reg.sub)
}




### ARCHIVE