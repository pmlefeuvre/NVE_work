
#---------------------------------------------------------------#
#           FILL GAPS USING COEFFICIENTS OF A LINEAR            #
#          MODEL AND INTERPOLATE THEIR VALUES WHEN GAP          #
#                                                               #
# Data:                                                         #
# 1) Sediment Chamber                                           #
# 2) Fonndal (combining both stations)                          #
#                                                               #
# Author: Pim Lefeuvre                         Date: 18/08/2014 #
# Analysis for each year and compare winter and summer Q        #
# Formerly called: Compare_Qdaily_Qcorrected_roll_Final.R       #
#---------------------------------------------------------------#

###########################################
# # # Clean up Workspace 
# rm(list = ls(all = TRUE))
# # Save "par" default
# def.par <- par(no.readonly = TRUE)
###########################################

# Load libraries
library(zoo)
library(chron)
library(hydroGOF) #NSE
library(RColorBrewer)


# Load User functions
source("../../UserFunction/subsample.R")
source("../../UserFunction/barplot_TimeFactors.R")


#########################################################################
#---------------------------------------------------------------#
#         Load DISCHARGE DATA and Compute a LINEAR MODEL        #
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

# FILTER 1 Remove NAs
Q.Sc.f  <- Q.Sc[!is.na(Q.Sc) & !is.na(Q.F)]
Q.F.f   <- Q.F[ !is.na(Q.Sc) & !is.na(Q.F)]
##### 

# # PLots
# plot(Q.F,Q.Sc.orig,pch=".")
# points(Q.F,Q.Sc,pch=".",col="red")
# # General Fit (Whole period)
# abline(lm(Q.Sc.f~Q.F.f))


# Rolling window for coeff
ndays   <- 10
win     <- 24*ndays

if (!exists("coeff")){
    print("Compute Linear Model with running window")

    my.FUN  <- function(x){
        resp <- x[(!is.na(x[,1]) & !is.na(x[,2])),1]
        pred <- x[(!is.na(x[,1]) & !is.na(x[,2])),2]
        if(sum(!is.na(resp))>win/4){
            fit <- lm(resp~pred,na.action=na.exclude)
            c   <- coef(fit)
            r   <- summary(fit)$r.squared
            l   <- length(resp)
            out <- cbind(rbind(c),r,l)
            return(out)
        }else{return(c(NA,NA,NA,NA))}
    }
    
    coeff <- rollapply(Q.corrd[,1:2],width=win,FUN=my.FUN,
                       by.column=F)
    
    names(coeff) <- c("Intercept", "Slope", "R2", "Count")
    
    # Subsample
    coeff       <- subsample(coeff,"1998-01-01","2014-01-01",F)
    
    # Filter Values with low R2 and low count
    coeff.R     <- coeff
    coeff.R[coeff$R2<0.8,1:2] <- NA
}


#---------------------------------------------------------------#
#               Plot TIME SERIES of the COEFFICIENTS            #
#---------------------------------------------------------------#
# PLot: Time Series
coeff.year  <- seq(start(coeff.R),end(coeff.R),"years")
coeff1.roll <- rollapply(coeff.R[,1],24*30,function(x){mean(x,na.rm=T)})
coeff2.roll <- rollapply(coeff.R[,2],24*30,function(x){mean(x,na.rm=T)})

plot(coeff.R[,1],type="p",pch=".",ylim=c(-10,20),xaxt="n",ylab="Intercept",xlab="Date")
lines(coeff1.roll,col="red")
axis(1,coeff.year,format(coeff.year,"%Y"))
grid()

plot(coeff.R[,2],type="p",pch=".",ylim=c(-2,8),xaxt="n",ylab="Slope",xlab="Date")
lines(coeff2.roll,col="red")
axis(1,coeff.year,format(coeff.year,"%Y"))
grid()


#---------------------------------------------------------------#
#           Plot DAILY DISTRIBUTION of the COEFFICIENTS         #
#---------------------------------------------------------------#

## INTERCEPT
# Filetered with R Squared
tmp <- barplot_TimeFactors(index(coeff.R),"doy",coredata(coeff.R[,1]),pch=".",
                    ylim=c(-10,25),ylab="Intercept",xlab="Date")
abline(h=0,lty=3)
grid()

# Not Filtered
tmp <- barplot_TimeFactors(index(coeff),"doy",coredata(coeff[,1]),pch=".",
                           ylim=c(-10,25),ylab="Intercept",xlab="Date")
abline(h=0,lty=3)
grid()

## SLOPE
# Filetered with R Squared
tmp <- barplot_TimeFactors(index(coeff),"doy",coredata(coeff.R[,2]),pch=".",
                    ylim=c(-2.5,7.5),ylab="Slope",xlab="Date")
abline(h=0,lty=3)
grid()
# Not Filtered
tmp <- barplot_TimeFactors(index(coeff),"doy",coredata(coeff[,2]),pch=".",
                           ylim=c(-2.5,7.5),ylab="Slope",xlab="Date")
abline(h=0,lty=3)
grid()


#---------------------------------------------------------------#
#           Verify how good is the Linear Approximation         #
#---------------------------------------------------------------#
# Subsample for analysis
coeff.sub <- subsample(merge(coeff,Q.corrd[,1:2]),"2009-06-01","2009-09-10",F)
coeff.sub[is.na(coeff.sub[,3]),1] <- NA 
coeff.sub[is.na(coeff.sub[,3]),2] <- NA 

# Linear Approximation
coeff.approx<- na.approx(coeff.R,maxgap=24*15)

# Plots: Check Approximations
plot(coeff.sub,type="p",pch=".")
plot(coeff.sub[,2],ylim=c(1,6))
points(coeff.approx[,2],col="blue",pch=".")


#---------------------------------------------------------------#
#        PREDICTION/RECONSTRUCTION - Save FINAL PRODUCT         #
#---------------------------------------------------------------#
# PREDICTION
Q.Sc.pred   <- coeff.approx[,1]+coeff.approx[,2]*Q.F

## COMPARE PREDICTION AND ORIGINAL
hist(Q.Sc-Q.Sc.pred,breaks=120)
summary(Q.Sc-Q.Sc.pred)

# Subsample to have same length between Observations and Model
# 17 is because Q.F starts at 16:00 and subsample is not made to extract hours
Q.Sc.sub    <- subsample(Q.Sc,format(start(Q.Sc.pred),"%F"),format(end(Q.Sc.pred),"%F"),F)
Q.Sc.sub    <- Q.Sc.sub[17:length(Q.Sc.sub)]
# Replace NA values in original time series by modeled data
Q.Sc.sub[is.na(Q.Sc.sub)] <- Q.Sc.pred[is.na(Q.Sc.sub)]

# Plot
plot(subsample(Q.Sc.sub,"2009-07-15","2009-08-10",F),type="p",pch=20)
points(Q.Sc.pred,col="red",pch=20,cex=0.5)

# Output and Save
Q.out   <- merge(Q.Sc,round(Q.Sc.pred,4),round(Q.Sc.sub,4))
names(Q.out) <- c("Q.Sc.orig","Q.Sc.pred","Q.combined")
# Only keep predicted values when Q.Sc does not have values
Q.out[!is.na(Q.Sc),2]<- NA
####
write.zoo(Q.out,sprintf("%s/Q.Sc.orig-pred-combined.csv",path),
          sep=",")
####

# Plot short period
plot(subsample(Q.out,"2009-07-15","2009-08-10",F),type="p",pch=20)

## Compute Subglacial Discharge and Save
Q.Sub.orig  <- round(Q.out[,1]-Q.F,4)
Q.Sub.pred  <- round(Q.out[,2]-Q.F,4)
Q.Sub.comb  <- round(Q.out[,3]-Q.F,4) 

plot(subsample(Q.Sub.comb,"2009-07-15","2009-08-10",F),type="p",pch=20)
points(subsample(Q.Sub.orig,"2009-07-15","2009-08-10",F),type="p",pch=20,col="red")

#### MOST IMPORTANT - SAVE PREDICTION OUTPUT COMBINED WITH ORIGINAL DISCHARGE 
write.zoo(merge(Q.Sub.orig,Q.Sub.pred,Q.Sub.comb),
          sprintf("%s/Q.Sub.orig-pred.csv",path),
          sep=",")
####

#################################################################
#---------------------------------------------------------------#
#     PLOT wit Observed and Modeled Discharge for each YEAR     #
#---------------------------------------------------------------#
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

## some pretty colors for PLOT
k   <- 11
my.cols <- rev(brewer.pal(k, "RdYlBu"))


for (i in 1:lt){
    t.start     <- t.array[i] 
    t.end       <- t.array[i+1]
    sub.start   <- format(t.array[i],"%F")
    sub.end     <- format(t.array[i+1],"%F")
    year        <- format(t.start,"%Y")
    
    if(t.start==as.POSIXct("2002-01-01")){next()}
    
    #SAve
    path.p <- "Plots/Predict_Sc_R2"
    pdf(sprintf("%s/DischargeLinearModel_rollD%i_%s.pdf",path.p,ndays,year),
        height=4)
    
    
    # Subsample
    Q.Sc.o.sub  <- subsample(Q.Sc.orig,sub.start,sub.end,F)
    Q.F.o.sub   <- subsample(Q.F,sub.start,sub.end,F)
    
    
    # Remove values greater than 30
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





### Archive










