
barplot_TimeFactors  <- function(t.data,
                                 type=c("year","yearmonth","month","doy","hour"),
                                 n.data=NULL,...)
{    
    
    cat("\nCompute barplot_TimeFactors with type:",type,"\n")
    
    # Error Message
    if (!sum(c("year","yearmonth","month","doy","hour") %in% type)){
        stop("Temporal type is not known. Handle: year, yearmonth, month, doy & hour")}
    
    # TIME Parameter
    lt          <- length(t.data)
    
    ####################################################
    ##    CONVERT TIME INTO LEVELS defined by type    ##
    ####################################################
    if (type == "year")
    {
        require(lubridate)
        # Create Levels
        t.new       <- seq(from=as.POSIXct(sprintf("%i-01-01",year(t.data[1]))),
                           to  =as.POSIXct(sprintf("%i-01-01",year(t.data[lt]))),
                           by="years")
        t.level     <- year(t.new)
        t.text      <- "Year" 
        
        # Extract Years
        t.fac.data  <- year(t.data)
        
        
    }else if (type == "yearmonth")
    {
        require(lubridate)
        # Create Levels
        t.new       <- seq(from=as.POSIXct(sprintf("%i-01-01",year(t.data[1]))),
                           to  =as.POSIXct(sprintf("%i-01-01",year(t.data[lt]))),
                           by="months")
        t.level     <- format(t.new,"%b %Y")
        t.text      <- "Month"
        
        # Extract Months and Years
        t.fac.data  <- format(t.data,"%b %Y")
        
        
    }else if (type == "month")
    {
        # Create Levels
        t.new       <- seq(from=as.POSIXct("01-01",format="%d-%m"),
                           to  =as.POSIXct("01-12",format="%d-%m"),by="months")
        t.level     <- month.abb
        t.text      <- "Month"
        
        # Extract Months
        t.fac.data  <- months(t.data,abbreviate=TRUE)
        
        
    }else if (type == "doy")
    {
        # Create Levels
        t.new       <- seq(from=as.POSIXct("2000-01-01"),
                           to  =as.POSIXct("2000-12-31"),by="days")
        t.level     <- format(t.new)
        t.text      <- "Day"
        
        # Compile days into one year // Convert index into POSIXlt
        year        <- 2000
        ind         <- as.POSIXlt(t.data)
        # Set index year to desired value
        ind$year    <- rep(year-1900,length(ind))
        t.data.2000 <- as.POSIXct(ind)        
        
        # Extract Days
        t.fac.data  <- as.POSIXct(trunc(t.data.2000,units="days"))
        
        
    }else if (type == "hour")
    {    
        # Create Levels
        t.new       <- seq(from=as.POSIXct("00:00",format="%H:%M"),
                           to  =as.POSIXct("23:00",format="%H:%M"),by="hours") 
        t.level     <- format(t.new, format="%H:%M")
        t.text      <- "Hour"
        
        # Extract Hours
        t.fac.data  <- format(trunc.POSIXt(as.POSIXct(t.data,format="%Y-%m-%d %H:%M")
                                           ,units="hours"),format="%H:%M")
    }

    
    ####################################################
    ##            CONVERT TIME INTO FACTOR            ##
    ####################################################
    # Create Factors
    t.fac       <- factor(t.fac.data,levels=t.level)
    
    
    ####################################################
    ## COMPUTE STATISTICS AND PLOT IF n.data has DATA ##  
    ####################################################
    # Parameters
    ln          <- length(n.data)
    nlev        <- length(t.level)
    
    # Assign empty arrays
    count       <- rep(NA,nlev)
    
    # Define time label (x-axis)
    if (any(type %in% c("year","yearmonth","month","doy"))){xlab <- "Date"
    } else if (type == "hours"){xlab <- "Time"}
    
        #######################
        ### FOR n.data=NULL ###
        #######################
    if( ln==0 ){
        # Count number of observations
        for (i in 1:nlev) {
            count[i]    <- sum(t.fac==t.level[i],na.rm=T)
            # Print 
            if (type == "doy"){
                if (format(as.POSIXct(t.level[i]),"%d") =="01"){
                    cat(t.text,":", t.level[i], "has",count[i], "obs.","\n")}
            }else{cat(t.text,":", t.level[i], "has",count[i], "obs.","\n")}
        }
        
        # Export data
        info <- zoo(count,order.by=t.new)
        
        ### PLOT ###
        barplot(table(t.fac),xlab=xlab,...) #yaxt="n",
        
        
        ###########################
        ### WHEN n.data EXISTS ###
        ###########################
    } else if ( ln>0 ){ 
        # Assign empty arrays
        mean.fac    <- rep(NA,nlev)
        med.fac     <- rep(NA,nlev)
        qtle.25.fac <- rep(NA,nlev)
        qtle.75.fac <- rep(NA,nlev)
        qtle.IQR.fac<- rep(NA,nlev)
        
        # Do the same job than the cmd: "summary" but ignore NA values
        for (i in 1:nlev) 
        {
            # Count number of observations
            count[i]    <- sum(!is.na(n.data) & t.fac==t.level[i],na.rm=T)
            # Display result only for each month if type="doy" otherwise print all count data
            if (type == "doy"){
                if (format(as.POSIXct(t.level[i]),"%d") =="01"){
                    cat(t.text,":", t.level[i], "has",count[i], "obs.","\n")}
            }else{cat(t.text,":", t.level[i], "has",count[i], "obs.","\n")}
            
            
            
            # Extract data
            data.sub        <- n.data[!is.na(n.data) & t.fac==t.level[i]]
            
            # Compute statistics
            mean.fac[i]     <- mean(data.sub,na.rm=T)
            med.fac[i]      <- median(data.sub,na.rm=T)
            qtle.25.fac[i]  <- quantile(data.sub,na.rm=T)[2]
            qtle.75.fac[i]  <- quantile(data.sub,na.rm=T)[4]
            qtle.IQR.fac[i] <- med.fac[i]-1.58*diff(c(qtle.25.fac[i],
                                                      qtle.75.fac[i]))
        }
        
        # Export data
        info <- zoo(cbind(mean.fac,med.fac,qtle.25.fac,qtle.75.fac,qtle.IQR.fac,count),
                    order.by=t.new)
        
        ### PLOT ###
        
        # add plot with n. of obs. to the boxplot
        if (type == "doy"){
             
            # Figure with N. of Observations
            ymax    <- max(info[,6])
            y.tck   <- round(seq(0,ymax,length.out=3))
            
            par(fig=c(0,1,0.8,1),mar=c(0,4.1,2,2))
            plot(info[,6],xaxt="n",yaxt="n",ylab="",xlab="",ylim=c(0,ymax),bty='n')
            mtext("number of\nobs. per day",2,1.5,cex=.8)
            axis(2,at=y.tck,labels=y.tck,tck=-0.05,cex.axis=0.6,las=2,line=-.5)
            axis(4,at=y.tck,labels=y.tck,tck=-0.05,cex.axis=0.6,las=2,line=-.5)
            # Boxplot
            par(fig=c(0,1,0,0.8),mar=c(5.1,4.1,0,2), new=TRUE)
            boxplot(n.data~t.fac,xlab=xlab,xaxt="n", xpd = NA,...)
            
            # Time Axis
            # Extract month in day of the year
            d       <- as.POSIXlt(t.new[1])
            d$mon   <- d$mon+seq(0,12)
            d       <- as.POSIXlt(as.POSIXct(d))
            # Plot time axis 
            axis(1,c(d$yday[1:12],nlev),format(d,"%b"))
            axis(1,seq(1,nlev,5),labels=F,tck=-0.01)

            # Reset default figure parameters
            par(def.par)
            
        }else{
            boxplot(n.data~t.fac,xlab=xlab,...) #yaxt="n",
            mtext(paste(" N=",count), side=3,at=seq(1,nlev), 
                  las=2,adj=0,cex=0.7,col="grey")
        }
        
        
    }
    print("---")
    return(info)
}


### ARCHIVE






