

##########################################################################
##               Apply Correlation for Detrended Data                   ##
##      between one reference LC (usually LC6) and all the others       ##
##             Plot Seasonal Variability for a couple of LCs            ##
##########################################################################

###########################################
# # Clean up Workspace
#   rm(list = ls(all = TRUE))
###########################################

f_Detrend_all   <- function(sub.start="01/01/2000 00:00",
                            sub.end=  "01/01/2001 00:00",
                            win.mean=48,
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
    #     win.mean<- day/2*(hour/15) #15min interval = 4 points per hour
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
#     
#     # Save Plots
#     path        <-"Plots/Detrend/"
#     filename    <-sprintf("Detrend%s_all.%s-%s_wm%i_wc%i.pdf", fname,
#                           juliandate(t.start),
#                           juliandate(t.end),win.mean,win.corr)
#     pdf(file=paste(path,filename,sep="/"),height=4)
    ##################            PLOT              ##########################
    
    
    ########################################
    ####            DETREND             ####
    ########################################
    # Function to Compute mean only when there are more than 50% of Real values
    mean.na <- function(x){
        if ( sum(!is.na(x)) > win.mean*50/100 ) 
        { weighted.mean(x,w=bartlett(win.mean),na.rm=T) } }
    
    # Load Cell Loop
    for (i in 1:ln)
    {
        # Extract Column
        a       <- which(names(LC.reg.sub)==LCnames[i])
        print(sprintf("MEAN: LCnames: %s => column %i",LCnames[i],a))
        
        # Subsampling
        LC.15min.sub    <- LC.reg.sub[,a]
        
        # Rolling window for mean
        LC.15min.mean   <- rollapply( LC.15min.sub,win.mean,mean.na)
        
        # Merge
        LC.15min.m      <- merge(LC.15min.sub,LC.15min.mean)
        
#         ##################            PLOT             ##########################
#         # Plot: Plot Original and Smoothed curve
#         plot(LC.15min.m,plot.type="single",type="p",pch=pch,
#              cex=cex,col=col,xaxt="n",xlim=xlim,
#              xlab=xlab,ylab="Pressure [MPa]",
#              main=paste("Load Call:", LCnames[i]))
#         axis.POSIXct(side=1,at=ticks.min,labels=F,tcl=-0.2)
#         axis.POSIXct(side=1,at=ticks.maj,labels=format(ticks.maj,format=t.format))
#         
#         # Legend
#         text.legend<-c(paste(LCnames[i],"Original"),
#                        paste(LCnames[i],"Mean"))
#         legend("bottomleft", title=paste("Win. size =",win.mean),
#                text.legend, lty=rep(4,0), bg="white", col=col,pch=pch,cex=0.5)
#         
#         ##################                             ##########################
        
        if (i==1) {
            LC.15min.mean.all  <- LC.15min.mean
            
        }else{
            LC.15min.mean.all  <- merge(LC.15min.mean.all,LC.15min.mean)
        }
        
    }
    
#     # Close PDF  
#     dev.off()
    
    # Rename Columns
    names(LC.15min.mean.all) <- LCnames
    ln      <- length(LCnames)
    
    ########################################
    ####    PRESSURE AND CORRELATION    ####
    ########################################
    # Correlation Function
#     kor     <- function(x) {if(sum(is.na(x)) < win.corr*50/100 ) {cor(x)[3]}}
#     kor.test<- function(x) {if(sum(is.na(x)) < win.corr*50/100 ) {corr.test(x)[[4]][3]}}

    kor.test <- function(x) {
        tmp <- corr.test(x)
        cor <- signif(tmp[[1]][3],4)
        p   <- signif(tmp[[4]][3],4)
        out <- cbind(cor,p)
        names(out) <- c("cor","p")
        return(out)
    }

#     # Threshold for Summary of Cross-Correlations between LCs
#     max.corr<- 0.95
    
    # Load Cell Loop
    for (i in 1:ln)
    {
        # Extract Column
        a       <- which(names(LC.15min.mean.all)==LCnames[i])
        print(sprintf("CORR: LCnames: %s => column %i",LCnames[i],a))
        
        # Compute P-value
        cor.p   <- rollapply(LC.15min.mean.all[,c(1,a)],
                             win.corr, kor.test, by.column = F)
        
        # ReAssign
        corr.15min.mean <- cor.p[,1]
        Pvalue.corr     <- cor.p[,2]   
        
#         # Compute Correlation
#         corr.15min.mean <- rollapply(LC.15min.mean.all[,c(1,a)],
#                                      win.corr, kor, by.column = F)
#         # Compute P-value
#         Pvalue.corr     <- rollapply(LC.15min.mean.all[,c(1,a)],
#                                      win.corr, kor.test, by.column = F)
        
        # Save Correlation
        if(i==1){
            corr.15min.mean.all <- corr.15min.mean
            Pvalue.corr.all     <- Pvalue.corr 
        }else{
            corr.15min.mean.all <- merge(corr.15min.mean.all,corr.15min.mean)
            Pvalue.corr.all     <- merge(Pvalue.corr.all,Pvalue.corr)
        }
    }
    
    #     # Solve problem for 2012 and 2013 (missing data within LC1e and LC7)
    #     if          (sub.start == "01/01/2012 00:00"){
    #         LC.15min.mean.all   <- LC.15min.mean.all[,c(1,3:5)]
    #         LCnames             <- LCnames[c(1,3:5)]
    #     } else if (sub.start == "01/01/2013 00:00"){
    #         LCnames             <- LCnames[c(1,3:5)]
    #     }
    
    # Rename Columns
    names(corr.15min.mean.all)  <- LCnames
    names(Pvalue.corr.all)      <- LCnames

#     # Check if there are NA values so that the structure of Time Series is kept
#     sum(is.na(corr.15min.mean.all))
    
    ############
    #     # 1st Method: Sum Correlation when above the threshold: max.corr
    #     N       <- rollapply((corr.15min.mean.all >= max.corr),1,
    #                          function(x) sum(x,na.rm=T),by.column=F)
    #     N.max   <- rollapply(corr.15min.mean.all,1,function(x) sum(!is.na(x)),
    #                          by.column=F)
    #     N.names <- rollapply(corr.15min.mean.all,1,
    #                          function(x) {LCnames[is.na(x)] <- NA;
    #                                       LCnames[x < max.corr]  <- 0;
    #                                       LCnames[x >= max.corr]  <- 1;
    #                                       paste(LCnames,collapse=",")},by.column=F)
    #     N.names <- rollapply(corr.15min.mean.all,1,
    #                          function(x) {LCnames[is.na(x)] <- NA;
    #                              paste(LCnames,collapse=",")},by.column=F)
    #     # Compute percentage
    #     N.per   <- N/ln*100
    #     
    #     # Extract dates where the maximum number of correlation is reached
    #     max.corr.t <- max(N.per)#100
    #     N.t     <- corr.15min.mean.all[which(N.per==max.corr.t)]#index()
    
    #     ############
    #     # 2nd Method: Sum of Correlations with a rolling window
    #     corr.t.all <- rollapply(corr.15min.mean.all,1,function(x) sum(x,na.rm=T),by.column=F)
    #     corr.t.abs <- rollapply(abs(corr.15min.mean.all),1,function(x) sum(x,na.rm=T),by.column=F)
    #     
    ##################            PLOT              ##########################
    # Save Plots
    #     path        <-"Plots/Corr/"
    #     filename    <-sprintf("Corr%s_all.%s-%s_wm%i_wc%i.pdf",fname,
    #                           juliandate(t.start),
    #                           juliandate(t.end),win.mean,win.corr)
    #     pdf(file=paste(path,filename,sep="/"),height=4)
    
    #     ##########
    #     # PLOT 1: Plot Categories of Correlation
    #     plot(N,type="p",pch=pch,cex=cex,col="black",xaxt="n",xlim=xlim,xlab=xlab,
    #          ylim=c(0,100),ylab="Correlation between LCs [>0.95]",
    #          main=paste("Number of LCs=",ln))
    #     axis.POSIXct(side=1,at=ticks.min,labels=F,tcl=-0.2)
    #     axis.POSIXct(side=1,at=ticks.maj,labels=format(ticks.maj,format=t.format))
    
    
    #     ##########
    #     # PLOT 2: Plot all LC to analyse visual correlations
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
    #     obj <- xyplot(LC.15min.mean.all, width="sj", strip=T, panel = p,
    #                   scales=list(y=list(relation='free', rot=0),#limits=ylim),
    #                               x=list(limits=c(t.start-day,t.end+day),at=ticks.maj
    #                                      ,labels=format(ticks.maj,format=t.format)),
    #                               cex=c(0.8,0.8), alternating=3),
    #                   par.strip.text=list(cex=0.7),
    #                   xlab=xlabel)
    #     
    #     # Print Final
    #     print(obj)
    
    
    #     ##########
    #     # Plot 3: Plot Sum of Correlations
    #     plot(corr.t.all,type="p",pch=pch,cex=cex,col="black",xaxt="n", xlim=xlim,
    #          main=paste("Number of LCs=",ln),xlab="Time [Month Year]",
    #          ylab="Percentage of Correlation between LCs")
    #     axis.POSIXct(side=1,at=ticks.min,labels=F,tcl=-0.2)
    #     axis.POSIXct(side=1,at=ticks.maj,labels=format(ticks.maj,format=t.format))
    
    # Close PDF
    #     dev.off()   
    ##################            PLOT             ##########################
    
    
    
    ##################           OUTPUT            ##########################
    #     ###### Output for Method 1 an 2
    #     Output <- merge(N,N.max,N.names,N.per,corr.t.all,corr.t.abs)
    #     
    #     # Path and Filename
    #     path        <-"Data/Corr/"
    #     filename    <-sprintf("Corr%s_all2.%s-%s_wm%i_wc%i.csv",fname,
    #                           juliandate(t.start),
    #                           juliandate(t.end),win.mean,win.corr)
    #     path.file<-paste(path,filename,sep="")
    #     
    #     # Save Output
    #     write.zoo(Output,file=path.file,sep=",",na="")
    
    ###### Output for Raw Dat
    # Path and Filename
    path        <-"Data/Corr/"
    filename    <-sprintf("Corr%s_all2.%s-%s_wm%i_wc%i.csv","FullLCs",
                          juliandate(t.start),
                          juliandate(t.end),win.mean,win.corr)
    path.file<-paste(path,filename,sep="")
    
    # Save Output
    write.zoo(corr.15min.mean.all,file=path.file,sep=",",na="")
    
    # Path and Filename
    filename    <-sprintf("Pvalue%s_all2.%s-%s_wm%i_wc%i.csv","FullLCs",
                          juliandate(t.start),
                          juliandate(t.end),win.mean,win.corr)
    path.file<-paste(path,filename,sep="")
    
    # Save Output
    write.zoo(Pvalue.corr.all,file=path.file,sep=",",na="")    
    
    # END
    return(LC.reg.sub)
}






### ARCHIVE

##         if (!exists("LC.15min.mean.all")) {
# if (i==1) {
#     LC.15min.mean.all  <- LC.15min.mean
# }else{
#     LC.15min.mean.all  <- merge(LC.15min.mean.all,LC.15min.mean)
# } 
#         if      (LCnames[i]=="LC6")     {LC6.15min    <- LC.15min.mean
#         }else if(LCnames[i]=="LC1e")    {LC1e.15min   <- LC.15min.mean
#         }else if(LCnames[i]=="LC4")     {LC4.15min    <- LC.15min.mean
#         }else if(LCnames[i]=="LC2a")    {LC1e.15min   <- LC.15min.mean
#         }else if(LCnames[i]=="LC97_1")  {LC97_1.15min <- LC.15min.mean
#         }else if(LCnames[i]=="LC97_2")  {LC97_2.15min <- LC.15min.mean
#         }else if(LCnames[i]=="LC2b")    {LC2b.15min   <- LC.15min.mean
#         }else if(LCnames[i]=="LC7")     {LC7.15min    <- LC.15min.mean
#         }else if(LCnames[i]=="LC01")    {LC01.15min   <- LC.15min.mean}


# Original & Median
#     LC.15min.sub.m  <- merge(LCa.15min[,2],LC.15min.m[,2])
#     LC.15min.mean.m <- merge(LCa.15min[,3],LC.15min.m[,3])

# Save only the third element of a 2x2 symmetric matrix with diagonal values equal to 1, produced by the correlation function
# win.corr        <- 12*(hour/15) 
# kor             <- function(x) {if(sum(is.na(x)) < win.corr*50/100 ) {cor(x[,1], x[,2])}} #[3]
#     corr.15min.sub  <- rollapply(LC.15min.sub.m,   win.corr, kor, by.column = F)
#     corr.15min.mean <- rollapply(LC.15min.mean.m,  win.corr, kor, by.column = F)

########################################
## MONTH BARPLOT PLOT
#     col         <- c("lightblue2","lightblue2","lightblue2",
#                      "lightblue2","orange","red","red","red",
#                      "red","orange","lightblue2","lightblue2")
#     # 
#     # barplot_TimeFactors(index(corr.15min.sub),type="month",coredata(corr.15min.sub)
#     #                     ,pch=".", yaxt="n", col=col,
#     #                     xlab="Month", ylab=paste("Correlation between",
#     #                                              LCnames[1],"&",LCnames[2])) 
#     
#     info <- barplot_TimeFactors(index(corr.15min.mean),type="month",
#                                 coredata(corr.15min.mean), pch=".", yaxt="n",
#                                 col=col,xlab="Month", 
#                                 ylab=paste("Correlation between",
#                                            LCnames[1],"&",LCnames[2])) 
#     
#     dev.off()
#     
#     
#     # Save Info
#     path        <-"Data/Detrend"
#     filename    <-sprintf("Detrend_%s-%s.%s-%s.t_start-t_end_wm%i_wc%i.csv", 
#                           LCnames[1], LCnames[2], juliandate(t.start),
#                           juliandate(t.end),win.mean,win.corr)
#     write.zoo(info,paste(path,filename,sep="/")) #read.zoo(filename,header=T)
#     
#     

# Save Correlation and Sum Correlation when above the threshold: max.corr
# if(i==1){
#     corr.15min.mean.all  <- corr.15min.mean
#     N <-     (corr.15min.mean.all[!is.na(corr.15min.mean.all)] >= max.corr)
# }else{
#     corr.15min.mean.all  <- merge(corr.15min.mean.all,corr.15min.mean)
#     N <- N + (corr.15min.mean.all[!is.na(corr.15min.mean.all)] >= max.corr)
# }
# 
# if (t.diff > 4*days.in.month){
#     ticks.min   <- seq(as.POSIXct(sub.start,format="%m/%d/%Y %H:%M"),
#                        as.POSIXct(sub.end,format="%m/%d/%Y %H:%M"),by="months")
#     ticks.maj   <- seq(as.POSIXct(sub.start,format="%m/%d/%Y %H:%M"),
#                        as.POSIXct(sub.end,format="%m/%d/%Y %H:%M"),by="2 months")
#     t.format    <- "%b %Y"
#     xlab        <-"Time [Month Year]"
# }else{
#     ticks.min   <- seq(as.POSIXct(sub.start,format="%m/%d/%Y %H:%M"),
#                        as.POSIXct(sub.end,format="%m/%d/%Y %H:%M"),by="days")
#     ticks.maj   <- seq(as.POSIXct(sub.start,format="%m/%d/%Y %H:%M"),
#                        as.POSIXct(sub.end,format="%m/%d/%Y %H:%M"),by="5 days")
#     t.format    <- "%d %b"
#     xlab        <-sprintf("Time [Day Month %i]",format(t.start,"%Y") 
# }    

#     if ( sum(!is.na(LC.reg.sub)) < win.corr) {

# Panel function
#         if(i == ln){
#             axis.POSIXct(side=1,at=ticks.min,labels=F,tcl=-0.2)
#             axis.POSIXct(side=1,at=,labels=)
#         }

#     LCnames=c("LC6","LC1e","LC4","LC97_1","LC97_2","LC7","LC01","LC2a""LC2b")

# MESS! MESS! MESS! Didn't work!
# N.names <- rollapply(corr.15min.mean.all,1,
#                      function(x) {LCnames[is.na(x)] <- NA;
#                                   LCnames[which(x <= max.corr)]
#                                   col2=which(x <= max.corr)}
#                      corr.names=LCnames[,which(x >= max.corr)];
#                      paste(corr.names,collapse=",")},by.column=F)
# 
