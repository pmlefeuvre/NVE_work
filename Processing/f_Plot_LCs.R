

#---------------------------------------------------------------#
#         FUNCTION THAT PLOTS LOAD CELL TIME SERIES             #
#                                                               #
# Function: Plot_LCs_Pressure(sub.start,sub.end,                #
#                             LCname,type,f.plot)              #
# Input: sub.start="2003-07-01"                         (start) #
#        sub.end="2003-07-15"                             (end) #
#        LCname=c("LC97_1","LC97_2")  (order of the LC matters) #
#        type="15min_mean"        ("min","15min_med","day_med") #
#        f.plot=FALSE                  (f.plot=TRUE, save plot) #
#                                                               #
# Notes: The load cells (LC) are plotted in pairs on subpanels. #
#        The number of panels depends on the number of LCs and  #
#        allows a maximum of three pairs (or three panels).     #
#        The order in "LCname" defines in which order the pairs #
#        of LCs are plotted. The by-default data have 15min     #
#        interval, but 1-min and 1-day data can also be used.   #
#        The plot can be saved in a pdf, but then is not viewed;#
#        this is done by changing f.plot=FALSE to f.plot=TRUE.  #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2015-08-13 #
#                                       Last Update: 2016-04-13 #
#                                                               #
# It is the result of merging old codes from "Plot_LCs_month.R",#
# "Plot_LCs_year.R","Plot_LCs_year2.R","Plot_LCs_year2_month.R",#
# "Plot_LCs_year2_week.R" and "Plot_LCs_year3_week.R".          #
#---------------------------------------------------------------#


##########################################
# # Clean up Workspace
# rm(list = ls(all = TRUE))
##########################################

# # INPUT PARAMETERS FOR TESTING THE FUNCTION
# type        <- "15min_mean"
# sub.start   <- "2003-07-01"
# sub.end     <- "2003-07-15"
# LCname      <- c("LC97_1","LC97_2","LC6","LC4","LC1e","LC7")#)
# f.plot      <- FALSE

##########################################
##########################################
Plot_LCs_Pressure <- function(sub.start="2003-07-01",sub.end="2003-07-15",
                              LCname=c("LC97_1","LC97_2"),type="15min_mean",
                              f.plot=FALSE,f.freq=FALSE){
    
    ############################################################################
    # Detect Operating System (!!! EDIT TO YOUR PATH !!!)
    if(.Platform$OS.type == "unix"){   HOME="/Users/PiM/Desktop"}
    if(.Platform$OS.type == "windows"){HOME="//nve/fil/h/HB/Bredata/breprosjekt/Engabreen/Engabreen Brelabben/"}
    
    # Go to the following Path in order to access data files
    setwd(sprintf("%s/NVE_work/Processing/",HOME))
    Sys.setenv(TZ="UTC")        
    
    # Load libraries (!!! NEED TO BE PRE-INSTALLED !!!)
    library(zoo)        #cmd: zoo
    library(lattice)    #plot: xy.plot
    
    # Load User functions
    source('f_Load_ZooSub_month.R')
    source("../UserFunction/juliandate.R")
    
    ############################################################################
    # Time variable
    t.start     <- as.POSIXct(sub.start)
    t.end       <- as.POSIXct(sub.end)
    daterange   <- paste(juliandate(sub.start),juliandate(sub.end),sep="-")
    
    ################################################
    ####          Load Load Cell Data           ####
    ################################################
    # LOAD Data in "LC.reg.sub" to avoid reloading the data
    LC.reg.sub  <- Load_ZooSub_month(sub.start,sub.end,type,f.freq)
    
    # Extract Column according to the order in LCname -AND-
    n.LC        <- match(LCname,names(LC.reg.sub))
    
    # CHECK: if missing load cell data (i.e. column)
    check.LC    <- which(!LCname %in% names(LC.reg.sub))
    if (length(check.LC)>0){stop(sprintf(">> Skip %s : NO Data <<",LCname[check.LC]))} 
    # REMOVE called load cell that does not have any data 
    n.LC        <- n.LC[!is.na(n.LC)] 
    ln          <- length(n.LC)
    
    ################################################
    ####      Replace NAs by Interpolation      ####
    ################################################
    # Extract Time Parameters For APPROXIMATING NA values
    dt.data <- difftime(index(LC.reg.sub[2]),index(LC.reg.sub[1]),units="mins")
    hour    <- 60/as.numeric(dt.data)   # min 
    day     <- 24*hour                  # hour 
    
    # Approximate NAs if the GAP is SHORTER THAN a DAY
    LC.reg.sub2 <- na.approx(LC.reg.sub[,n.LC],maxgap=1*day)
    # Extract Column again because order is changed
    n.LC2       <- which(names(LC.reg.sub2) %in% LCname)
    
    
    ################################################
    ####      Save plotted Figure in a pdf      ####
    ################################################
    if (f.plot){
        # Make folder where will be saved the data
        path    <- sprintf("Plots/Pressure/%s",format(t.start,"%Y"))
        dir.create("Plots/Pressure",showWarnings = FALSE)
        dir.create(path,showWarnings = FALSE)
        # Include all figures in a pdf file!
        filename<- sprintf("%s/PDF_%s_%s.pdf",path,LCname,daterange)
        pdf(file=filename,height=5)
    }
    par(oma=c(1,1,1,1),cex=0.7)
    
    ################################################
    ####       Reformat data for plotting       ####
    ################################################
    # Merge columns according to number of load cells
    if        (ln<=2){LC.plot <- merge(LC.reg.sub2[,1])
    } else if (ln<=4){LC.plot <- merge(LC.reg.sub2[,c(1,3)])
    } else if (ln<=6){LC.plot <- merge(LC.reg.sub2[,c(1,3,5)])}
    
    
    ################################################
    ####         Prepare Customised Axis        ####
    ################################################
    ## TIME AXIS and parameters that defines density of x-axis labels
    # THE AXIS IS MADE TO ADAPT TO THE TIME SPAN FOR MAKING PRETTY PLOT
    dt          <- t.end-t.start
    
    # Define label density and format of the time axis
    if         (dt < 30){
        dt.tck <- "2 days"
        dt.lab <- "%d %b"
    } else if (dt < 150) {
        dt.tck <- "10 days"
        dt.lab <- "%d %b"
    } else if (dt < 365) {
        dt.tck <- "months"
        dt.lab <- "%b"
    } else if (dt < 2*365) {
        dt.tck <- "2 months"
        dt.lab <- "%b"
    } else if (dt >= 2*365) {
        dt.tck <- "6 months"
        dt.lab <- "%b %Y"
    }
    
    # Format of the Time axis 
    xlabel      <- "Date"
    xticks      <- seq(t.start,t.end,dt.tck)
    x.ticks.lab <- format(xticks,dt.lab)
    lx          <- length(x.ticks.lab) 
    x.ticks.lab[lx] <- sprintf("%s \n%s",x.ticks.lab[lx],strftime(t.end,"%Y"))
    
    
    ## PRESSURE AXIS and parameters that defines density of y-axis labels
    # THE AXIS IS MADE TO ADAPT TO THE NUMBER OF LOAD CELLS AND SO PANELS
    # Plot Parameters
    ncol        <- max(1,ncol(LC.plot))
    ylabel      <- rep("P [MPa]",ncol)  # Inversed
    n.tick      <- 5                    # Number of ticks on y-axis of one panel
    col1        <- rep("black",ncol)    # Colour to differentiate two LCs
    col2        <- rep("gray50",ncol)
    lwd         <- 2 
    
    # 1) Defines Limits and labels of FIRST AXIS (when there is ONE load cell OR MORE)
    if        (ln>=1){ 
        LC      <- LC.reg.sub2[,n.LC2[1:min(2,length(n.LC2))]]
        r       <- 1 + round(abs(log10(diff(range(LC,na.rm=T))))) 
        ymin1   <- max(0,round(min(LC,na.rm=T),r))
        ymax1   <- round(max(LC,na.rm=T),r)
        ylim    <- c(list(c(ymin1,ymax1)))
        yticks  <- c(list(round(seq(ymin1, ymax1,length.out=n.tick),r+1)))
        rm("LC","r")}
    
    # 2) Defines Limits and labels of SECOND AXIS (when there is THREE load cells OR MORE)
    if (ln>=3){
        LC      <- LC.reg.sub2[,n.LC2[3:min(4,length(n.LC2))]]
        r       <- 1 + round(abs(log10(diff(range(LC,na.rm=T)))))
        ymin2   <- round(max(c(min(LC,na.rm=T),0)),r)
        ymax2   <- round(max(LC,na.rm=T),r)
        ylim    <- c(list(c(ymin1,ymax1)),list(c(ymin2,ymax2)))
        yticks  <- c(list(round(seq(ymin1, ymax1,length.out=n.tick),r+1)),
                     list(round(seq(ymin2, ymax2,length.out=n.tick),r+1)))
        rm("LC","r")} 
    
    # 3) Defines Limits and labels of THIRD AXIS (when there is FIVE load cells OR MORE)
    if (ln>=5){
        LC      <- LC.reg.sub2[,n.LC2[5:min(6,length(n.LC2))]]
        r       <- 1 + round(abs(log10(diff(range(LC,na.rm=T)))))
        ymin3   <- round(max(c(min(LC,na.rm=T),0)),r)
        ymax3   <- round(max(LC,na.rm=T),r)
        ylim    <- c(list(c(ymin1,ymax1)),list(c(ymin2,ymax2)),list(c(ymin3,ymax3)))
        yticks  <- c(list(round(seq(ymin1, ymax1,length.out=n.tick),r+1)),
                     list(round(seq(ymin2, ymax2,length.out=n.tick),r+1)),
                     list(round(seq(ymin3, ymax3,length.out=n.tick),r+1)))
        rm("LC","r")
    }
    
    
    
    ################################################
    ####         PLOT THE LOAD CELL DATA        ####
    ################################################
    # Plot function
    p              <- function(x, y,...) {
        i <- panel.number();
        panel.grid(h=-1,v=-1,x=x,y=y);
        #if (i==1){panel.abline(h = seq(1.5,2.5,0.25), lwd=0.5,col="gray")}
        panel.xyplot(x, y, type="b",col=col1[i],
                     lwd=lwd,main=NULL,cex=0.1,
                     ylab=ylabel[i]);
        panel.abline(h = 0, lty=3)
        panel.text((t.start+3600*24*as.numeric(dt)/40),ylim[[i]][1],LCname[((i-1)*2)+1],
                   adj=0,col=col1[i],font=2)
        if(!is.na(LCname[(i-1)*2+2])){
            panel.text((t.start+3600*24*as.numeric(dt)*3*2/40),ylim[[i]][1],LCname[(i-1)*2+2],
                       adj=0,col=col2[i],font=2)
        }
    }
    
    
    # Plot Lattice
    obj <- xyplot(LC.plot, width="sj", strip=F, panel=p,
                  main=NULL,
                  scales=list(y=list(relation='free', rot=0, limits=ylim,
                                     at=yticks,cex=0.75), 
                              x=list(limits=c(t.start-day,t.end+day),at=xticks,
                                     labels=x.ticks.lab, cex=0.75),
                              alternating=3),
                  xlab=list(label=xlabel,cex=0.75),
                  ylab=list(label=ylabel,cex=0.75))
    
    # Display plot
    print(obj)
    
    
    # Plot additional Load cell data onto existing plots
    if (ln>1){ 
        n <- round(ln-.5)
        for (i in 1:(n/2)){
            trellis.focus("panel", 1, i,highlight = F)
            do.call("panel.xyplot", list(index(LC.reg.sub2),LC.reg.sub2[,2*i],
                                         type="l",col=col2[i],lwd=lwd,main=NULL,cex=0.1)) 
            trellis.unfocus()
        }
    }
    
    
    ########################################
    # End PDF file
    if (f.plot){dev.off()}
    
}

## Archive

