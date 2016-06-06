
#---------------------------------------------------------------#
#               IDENTIFY ANTI-CORRELATION PERIOD                #
#                                                               #
# Based on Data:                                                #
#   - Correlation between LC6 and the rest of the load cells    #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2014-09-02 #
#                                       Last Update: 2016-05-31 #
#                                                               #
# Updates:                                                      #
# - 2016-05-31: Updated and simplified                          #
#                                                               #
# Formerly called "CP_Detrend_all2.R"                            #
#---------------------------------------------------------------#


##########################################
# Clean up Workspace
# rm(list = ls(all = TRUE))
# Save "par" default
def.par <- par(no.readonly = TRUE)
##########################################

# Detect Operating System
if(.Platform$OS.type == "unix"){   HOME="/Users/PiM/Desktop"}
if(.Platform$OS.type == "windows"){HOME="//nve/fil/h/HB/Personlige mapper/PiM"}

# Go to the following Path in order to access data files
setwd(sprintf("%s/NVE_work/Processing/",HOME))
Sys.setenv(TZ="UTC")  

# Load libraries
library(zoo)
library(chron)
library(lattice)
library(MASS) #kde2d
library(signal) #bartlett
library(RColorBrewer)

# Load User Functions
source('f_Load_ZooSub_month.R')
source('../UserFunction/juliandate.R')
source('../UserFunction/subsample.R')
source('../UserFunction/my.grid.R')
source('../UserFunction/barplot_TimeFactors.R')
source('../UserFunction/toyear.R')


#########################################################################
# Time Parameters
hour    <- 60/15  #in 15min
day     <- 24*hour#in hour 
month   <- 31*day # in days

#---------------------------------------------------------------#
#                    Load CORRELATION DATA                      #
#---------------------------------------------------------------#
# Parameters
win.corr    <- 96
sub.start   <- "1992-11-01"
sub.end     <- "2015-01-01"
t.start     <- as.POSIXct(sub.start) 
t.end       <- as.POSIXct(sub.end)
LC.name     <- c("LC4","LC1e","LC97_1","LC97_2") 

# Load Correlation
if( !exists("LCs.corr") & !exists("LCs") ){
    path    <- "Data/Corr"
    fname   <- sprintf("Corr2LC6-FullLCs_all2.%s-%s_wmNA_wc%i",
                       juliandate(sub.start),juliandate(sub.end),win.corr)
    filename<- sprintf("%s/%s.csv",path,fname)
    LCs.corr<- read.zoo(filename, header=T, sep=",",FUN=as.POSIXct)
}  

# Loop through Load cells
for (i in 1:length(LC.name)){
    
    # Extract column
    print(LC.name[i])
    n.LC        <- which(LC.name[i]==names(LCs.corr)) 
    ## Subsample
    corr.sub        <- LCs.corr[,n.LC,drop=F]
    
    # barplot_TimeFactors(index(corr.sub),type="year",n.data=coredata(corr.sub))
    
    #---------------------------------------------------------------#
    #                     Load LOAD CELL DATA                       #
    #---------------------------------------------------------------#
    LC.reg.sub      <- Load_ZooSub_month(sub.start,sub.end)
    
    ## Subsample
    LC.col          <- c(1,which(LC.name[i]==names(LC.reg.sub)))
    LC.sub          <- LC.reg.sub[,LC.col]
    
    #---------------------------------------------------------------#
    #                   Extract ANTI-CORRELATION                    #
    #---------------------------------------------------------------#
    # Level of anti-correlation being extracted
    max.AC      <- (-0.8)
    maxgap.NA   <- day 
    
    # Interpolate anti-correlation periods separated by less than a day
    corr.R2             <- (corr.sub[,1]<=max.AC)
    corr.R2[corr.R2==0] <- NA
    corr.R2             <- na.approx(corr.R2,maxgap=maxgap.NA,na.rm=F)
    corr.R2[is.na(corr.R2)] <- 0
    
    # Extract period range with anti-correlation
    range   <- corr.R2+lag(corr.R2,1,na.pad=F)
    range   <- range[range==1]
    start   <- index(range[which(seq(1,length(range)) %% 2 == 1)])
    end     <- index(range[which(seq(1,length(range)) %% 2 != 1)])
    l.time  <- as.numeric((end-start)/(60*24)) #Conversion from minutes into days
    print(summary(l.time))
    
    #---------------------------------------------------------------#
    #                Plot ANTI-CORRELATION distribution             #
    #---------------------------------------------------------------#
    # Extract periods longer than t.min
        l.min   <- 2 # c(0.5,1,2,3)
    
    # for(l.min in c(0.5,1,2,3)){ 
        out     <- cbind.data.frame(start[l.time>l.min],end[l.time>l.min])
        
        # For identification of periods with low variance
        var.min <- 0.01
        var.low <- rep(NA,nrow(out))
        
        # Save PDF
        path.out<- "Plots/AntiCorr" 
        dir.create(path.out,showWarnings=F)
        filename<- sprintf("AntiCorr_%s_daymin%g_ACmax%1.2f_var%1.3f.pdf",
                           LC.name[i],l.min,max.AC,var.min)
        pdf(sprintf("%s/%s",path.out,filename))
        
        # Plot distribution of length of anti-correlation periods
        hist(l.time[l.time>l.min],breaks=seq(0,14,0.1),xlim=c(0,14),ylim=c(0,100),
             main=LC.name[i],xlab="Consecutive days with anti-correlation",
             ylab="Number")
        
        #---------------------------------------------------------------#
        #                Plot ANTI-CORRELATION periods                  #
        #---------------------------------------------------------------#
        for (j in seq(1,nrow(out))){
            
            t1 <- out[j,1]-2*24*3600
            t2 <- out[j,2]+2*24*3600
            print(format(out[j,1]))
            # Subsample
            LC.sub2     <- subsample(LC.sub,  format(t1),format(t2),F)
            corr.sub2   <- subsample(corr.sub,format(t1),format(t2),F)
            
            # NA problem caused by correlation code (max: 75% of data are NAs)
            if(sum(is.na(LC.sub2))>(0.75*nrow(LC.sub2))){
                print("Problem with NAs, next")
                                             var.low[j] <- 0
                                             next()}
            # Check if Load Cell Variance is lower than 0.01, otherwise go to next
            var.LC      <- var(LC.sub2,na.rm=T)
            if(prod(var.LC[c(1,4)]<var.min)){print("Too High Variance, next")
                                             var.low[j] <- 0
                                             next()}
            
            # Layout
            layout(matrix(1:2,2,1),widths=5,height=2)
            
            # Plot 1a
            plot(LC.sub2[,1],xaxt="n",xlab="")
            points(LC.sub2[,1],pch=20,cex=0.1)
            # Plot 1b
            par(new=T)
            plot(LC.sub2[,2],xaxt="n",yaxt="n",xlab="",ylab="",col="grey")
            points(LC.sub2[,2],pch=20,cex=0.1,col="grey")
            axis(4)
            mtext("Pressure",4,3)
            my.grid.week.year(t1,t2)
            legend("topleft",col=c("black","grey"),lty=1,
                   legend=names(LC.sub2),cex=0.7,bg="white")
            
            # PLot 2
            plot(corr.sub2,type="p",pch=20,cex=0.5,xaxt="n",ylim=c(-1,1))
            points(corr.sub2[corr.sub2[,1]<=max.AC],col="red")
            my.grid.week.year(t1,t2)
            
            par(def.par)
        }
        
        # Close pdf
        dev.off()
        
        #---------------------------------------------------------------#
        #                Save ANTI-CORRELATION periods                  #
        #---------------------------------------------------------------#
        # Remove Periods with low variance in pressure
        out.var <- out[var.low==1,1:2]
        colnames(out.var) <- c("start_AC","end_AC")
        sprintf("Percentage of periods with variance>%1.2e: %1.1f",var.min,
                nrow(out.var)/nrow(out)*100)
        
        # SAVE
        path.out<- "Data/Corr/AntiCorr" 
        dir.create(path.out,showWarnings=F)
        filename<- sprintf("AntiCorr_%s_daymin%g_ACmax%1.2f_var%1.3f.csv",
                           LC.name[i],l.min,max.AC,var.min)
        write.csv(out.var,sprintf("%s/%s",path.out,filename),row.names=F)
    # }   
}




##### ARCHIVE



