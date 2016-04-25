
#---------------------------------------------------------------#
#               PREDICT SEDIMENT CHAMBER DISCHARGE              #
#                   WITH FONNDAL AS PREDICTOR                   #
# 1) Sediment Chamber                                           #
# 2) Fonndal (combining both stations)                          #
#                                                               #
# Author: Pim Lefeuvre                         Date: 18/08/2014 #
# Use 1998-2001 to predict the rest of the dataset              #
#                                       Last Update: 11/09/2014 #
# Formerly called: Predict_SedimentChamber2.R                   #
#---------------------------------------------------------------#

###########################################
# # Clean up Workspace 
# rm(list = ls(all = TRUE))
# # Save "par" default
# def.par <- par(no.readonly = TRUE)
###########################################


# Load libraries
library(zoo)
library(chron)
library(hydroGOF) #NSE
library(signal) #bartlett


# Load User functions
source("../../UserFunction/subsample.R")
source("../../UserFunction/barplot_TimeFactors.R")



#########################################################################
#---------------------------------------------------------------#
#               Load DISCHARGE and GRADIENT DATA                #
#---------------------------------------------------------------#
# Path and Filename
path            <- "../../Processing/Data/MetData/Discharge"
Q.filename      <- sprintf("%s/Q.Sc.F.Sub_corrected_1992-153-2014-001.csv",path)
Q.Sc.filename   <- sprintf("%s/SedtChamber_Q_komp.csv",path)

# Load
if (!exists("Q.corrd") || !exists("Q.Sc.orig")){
    print("Load Discharge Data")
    Q.corrd     <- read.zoo(Q.filename,sep=",",FUN=as.POSIXct,
                            header=T) 
    Q.Sc.orig   <- read.zoo(Q.Sc.filename,sep=",",FUN=as.POSIXct)
}
# Assign
Q.Sc<- Q.corrd[,1]
Q.F <- Q.corrd[,2]


# Rolling window for coeff
if (!exists("coeff")){
    print("Compute Linear Model with running window")
    
    ndays   <- 3
    win     <- 24*ndays
    
    my.FUN  <- function(x){
        resp <- x[(!is.na(x[,1]) & !is.na(x[,2])),1]
        pred <- x[(!is.na(x[,1]) & !is.na(x[,2])),2]
        if(sum(!is.na(resp))>win/4){
            fit <- lm(resp~pred,na.action=na.exclude)
            c   <- coef(fit)
            r   <- summary(fit)$r.squared
            l   <- length(pred) 
            out <- cbind(rbind(c),r,l)
            return(out)
        }else{return(c(NA,NA,NA,NA))}
    }
    
    coeff <- rollapply(Q.corrd[,1:2],width=win,FUN=my.FUN,
                       by.column=F)
    
    names(coeff) <- c("Intercept", "Slope", "R2", "Count")
    
    # Subsample
    coeff       <- subsample(coeff,"1998-01-01","2014-01-01",F)
    
    # Filter Values with low R2
    coeff.R     <- coeff
    coeff.R[coeff$R2<0.8,1:2] <- NA
}

# Subsample
cal.start   <- "1998-01-01"
cal.end     <- "2002-01-01"
# cal.start   <- "2009-01-01"
# cal.end     <- "2014-01-01"
coeff.cal   <- subsample(coeff.R,cal.start,cal.end,F)

# # Plots Daily Distribution
# Make folder where will be saved the plot
path.p <- "Plots/Predict_Sc_R2"
dir.create(path.p,showWarnings = FALSE)
#SAve Plot with Parameters 
pdf(sprintf("%s/PredictionSc2From%sTo%s_Param_rollD%i.pdf",path.p,
            cal.start,cal.end,ndays),height=4)

# INTERCEPT
intercept   <- barplot_TimeFactors(index(coeff.cal),"doy",coredata(coeff.cal[,1]),
                                   pch=".",xaxt="n",ylim=c(-10,25),
                                   ylab="Intercept",xlab="Date")
abline(h=0,lty=3)
grid()

# Smooothing
n <- 1
win <- 30
bart <- bartlett(win)
interc.mw   <- rollapply(intercept[,n],win,FUN=function(x){weighted.mean(x,bart)})
interc.m    <- rollmean(intercept[,n],win)
interc.l    <- lowess(seq(1,dim(intercept)[1]),coredata(intercept[,n]),f=0.05) 

lines(seq(1,length(interc.mw)),coredata(interc.mw),col="green")
lines(seq(1,length(interc.m)),coredata(interc.m),col="red")
lines(interc.l,col="blue")

# SLOPE
slope       <- barplot_TimeFactors(index(coeff.cal),"doy",coredata(coeff.cal[,2]),
                                   pch=".",xaxt="n",ylim=c(-2.5,7.5),
                                   ylab="Slope",xlab="Date")
abline(h=0,lty=3)
grid()

# Smooothing
interc.mw   <- rollapply(slope[,n],win,FUN=function(x){weighted.mean(x,bart)})
interc.m    <- rollmean(slope[,n],win)
slope.l     <- lowess(seq(1,dim(slope)[1]),slope[,n],f=0.05)

lines(seq(1,length(interc.mw)),coredata(interc.mw),col="green")
lines(seq(1,length(interc.m)),coredata(interc.m),col="red")
lines(slope.l,col="blue")

# Close PDF
dev.off()


# Reformat coefficient from daily to hourly using linear interpolation
doy         <- seq(start(coeff),end(Q.F),"days")
doy.h       <- seq(start(coeff),end(Q.F),"hours")
slope.doy   <- zoo(slope.l$y,doy)
interc.doy  <- zoo(interc.l$y,doy)

# Create NA array with hour interval
slope.doy.h <- zoo(rep(NA,length.out=length(doy.h)),doy.h)
interc.doy.h<- zoo(rep(NA,length.out=length(doy.h)),doy.h)

# Approximate daily values to hourly
slope.doy.f <- na.approx(merge(slope.doy,slope.doy.h)[,1])
interc.doy.f<- na.approx(merge(interc.doy,interc.doy.h)[,1])

# PREDICTION
Q.Sc.pred  <- interc.doy.f+slope.doy.f*Q.F


##### FILTERS
# FILTER 1 Remove NAs
Q.Sc.f  <- Q.Sc[!is.na(Q.Sc) & !is.na(Q.F)]
Q.F.f   <- Q.F[ !is.na(Q.Sc) & !is.na(Q.F)]
##### 



############################################
# Overview per year 
t.array <- seq(as.POSIXct("1998-01-01"),as.POSIXct("2014-01-01"),by="years") 
lt      <- length(t.array)-1
coef    <- matrix(nrow=lt,ncol=6)
R2      <- matrix(nrow=lt,ncol=3)

# PLot parameters
ylim <- c(0,120/2)
xlim <- c(0,15)
col  <- c("red","orange","yellow") 
col2 <- c("black","grey","red","orange","blue") 
pch  <- 20
cex  <- 0.5


for (i in 1:lt){
    t.start     <- t.array[i] 
    t.end       <- t.array[i+1]
    sub.start   <- format(t.array[i],"%F")
    sub.end     <- format(t.array[i+1],"%F")
    year        <- format(t.start,"%Y")
    
    if(t.start==as.POSIXct("2002-01-01")){next()}
    
    #SAve
    pdf(sprintf("%s/PredictionSc2From%sTo%s_rollD%i_%s.pdf",path.p,
                cal.start,cal.end,ndays,year),height=4)
    
    
    # Subsample
    Q.Sc.o.sub  <- subsample(Q.Sc.orig,sub.start,sub.end,F)
    Q.F.o.sub   <- subsample(Q.F,sub.start,sub.end,F)
    
    
    # Keep only values greater than 30
    Q.Sc.o.sub  <- Q.Sc.o.sub[coredata(Q.Sc.o.sub)>30]
    Q.F.o.sub   <- Q.F.o.sub[coredata(Q.Sc.o.sub) >30]
    Q.Sc.p.sub  <- Q.Sc.pred[coredata(Q.Sc.pred)  >30]
    
    for (j in 5:10){
        
        #### JUNE-SEPTEMBER
        t.stt.ex    <- sprintf("%s-%02i-01",year,j)
        t.end.ex    <- sprintf("%s-%02i-01",year,j+1)
        Q.Sc.sub.ex <- subsample(Q.Sc.f,t.stt.ex,t.end.ex,F)
        Q.Sc.sub.pr <- subsample(Q.Sc.pred,t.stt.ex,t.end.ex,F)
        xlim <- c(as.POSIXct(t.stt.ex),as.POSIXct(t.end.ex))
        
        plot(Q.Sc.sub.ex,type="p",pch=pch,cex=cex,ylim=c(0,60),
             main=year,xlab="Date",xlim=xlim,
             ylab="Discharge [m3.s-1]")
        points(Q.Sc.o.sub,pch=pch,cex=cex,col=col2[2])
        points(Q.Sc.pred,pch=pch,cex=cex,col=col2[3])
        points(Q.Sc.p.sub,pch=pch,cex=cex,col=col2[4])
        points(Q.F,pch=pch,cex=cex,col=col2[5])
        grid()
        
        text.leg <- c("Sedt Chbr: Q<30","Sedt Chbr: Q>30","Predicted Q Sc: : Q<30","Predicted Q Sc: : Q>30","Predictor: Fonndal")
        legend("topright",legend=text.leg,col=col2,pch=pch,cex=cex)
        
        # NSE test (Reformat to have same number of rows)
        prex.sub <- merge(Q.Sc.sub.pr,Q.Sc.sub.ex)
        prex.sub <- prex.sub[!is.na(prex.sub[,1]) & !is.na(prex.sub[,2])]    
        NSE <- mNSE(prex.sub[,1],prex.sub[,2])
        text(as.POSIXct(t.stt.ex)+3600*24*3,50,sprintf("NSE=%1.2f",NSE)) 
    }   
    
    # Close PDF
    dev.off()
}



#####################################################################
# Assessing prediction/simulated versus observations with Nash-Sutcliffe Efficiency
prex <- merge(Q.Sc.pred,Q.Sc)
prex <- prex[!is.na(prex[,1]) & !is.na(prex[,2])]
NSE <- mNSE(prex[,1],prex[,2])


#SAve
pdf(sprintf("%s/PredictionSc2From%sTo%s_NSE_rollD%i.pdf",path.p,
            cal.start,cal.end,ndays),height=4)

t.array     <- seq(as.POSIXct("1998-01-01"),as.POSIXct("2013-10-01"),by="months") 
lt <- length(t.array)
plot(as.POSIXct("1998-01-01"),1,col="white",pch=20,xlim=c(as.POSIXct("1998-01-01"),as.POSIXct("2014-01-01")),ylim=c(-2,1))

NSE.all <- array(dim=c(1,lt))

for (i in 1:(lt-1)){
    t.start     <- t.array[i] 
    t.end       <- t.array[i+1]
    sub.start   <- format(t.array[i])
    sub.end     <- format(t.array[i+1])
    
    Q.Sc.sub.pr <- subsample(prex[,1],sub.start,sub.end,F)
    Q.Sc.sub.ex <- subsample(prex[,2],sub.start,sub.end,F)
    
    
    NSE <- mNSE(Q.Sc.sub.pr,Q.Sc.sub.ex)
    points(t.start,NSE,pch=20,col="black")
    
    NSE.all[i] <- NSE
} 

dev.off()








### Archive


