#---------------------------------------------------------------#
#                 Plot a Grid taking into account               #
#                  either hours, days or 5 days                 #
#                                                               #
#                                                               #
# Author: Pim Lefeuvre                         Date: 17/06/2014 #
# Updates                                                       #
# 2014-09-05: Add my.grid.week.year to add year to last date    #
#---------------------------------------------------------------#

my.grid.day <-function(t.start,t.end,ax=1,col="grey",lwd=1,...){
    t.start2    <- trunc(t.start,"days")
    t.end2      <- trunc(t.end,"days")
    min.ticks   <- seq(t.start2,t.end,"hours")
    maj.ticks   <- seq(t.start2,t.end2,"6 hours")
    maj.ticks2  <- seq(t.start2,t.end2,"days")
    axis.POSIXct(ax,at=min.ticks,labels=F,tcl=-0.2)
    axis.POSIXct(ax,at=maj.ticks[-length(maj.ticks)],labels=F,tcl=-0.4)
    axis.POSIXct(ax,at=maj.ticks2[-length(maj.ticks2)],cex.axis=0.7,lwd=lwd,
                 labels=format(maj.ticks2[-length(maj.ticks2)],format="%d %b"),...)
    axis.POSIXct(ax,at=maj.ticks[-length(maj.ticks)],cex.axis=0.7,lwd=lwd,
                 labels=format(maj.ticks[-length(maj.ticks)],format="%H:%M\n"),...)
    # Add year
    lab <- sprintf("%s\n%s", format(max(maj.ticks),format="%Y"),
                   format(max(maj.ticks),format="%d %b"))
    axis.POSIXct(ax,at=max(maj.ticks),labels=lab,lwd=lwd,
                 cex.axis=0.8,...)
    # Add grid
    grid(nx=NA, ny=NULL)
    abline(v=maj.ticks,col=col, lty="dotted", lwd=par("lwd"))
}

my.grid.week <-function(t.start,t.end){
    t.start2    <- trunc(t.start,"days")
    t.end2      <- trunc(t.end,"days")
    min.ticks   <- seq(t.start2,t.end,"hours")
    maj.ticks   <- seq(t.start2,t.end2,"days")
    axis.POSIXct(1,at=min.ticks,labels=F,tcl=-0.2)
    axis.POSIXct(1,at=maj.ticks,labels=format(maj.ticks,format="%d %b"))
    grid(nx=NA, ny=NULL)
    abline(v=maj.ticks,col="black", lty="dotted", lwd=par("lwd"))
}

my.grid.week.year <-function(t.start,t.end){
    t.start2    <- trunc(t.start,"days")
    t.end2      <- trunc(t.end,"days")
    min.ticks   <- seq(t.start2,t.end,"hours")
    maj.ticks   <- seq(t.start2,t.end2,"6 hours") 
    maj.ticks2  <- seq(t.start2,t.end2,"days")
    axis.POSIXct(1,at=min.ticks,labels=F,tcl=-0.2)
    axis.POSIXct(1,at=maj.ticks,labels=F,tcl=-0.3)
    axis.POSIXct(1,at=maj.ticks2[-length(maj.ticks2)],
                 labels=format(maj.ticks2[-length(maj.ticks2)],format="%d %b"))
    # Add year
    lab <- sprintf("%s\n%s", format(max(maj.ticks),format="%Y"),
                   format(max(maj.ticks),format="%d %b"))
    axis.POSIXct(1,at=max(maj.ticks),labels=lab)
    
    # Add grid
    grid(nx=NA, ny=NULL)
    abline(v=maj.ticks2,col="black", lty="dotted", lwd=par("lwd"))
}

my.grid.week.nogrid <-function(t.start,t.end,ax=1,...){
    t.start2    <- trunc(t.start,"days")
    t.end2      <- trunc(t.end,"days")
    min.ticks   <-  seq(t.start2,t.end2,"days")
    maj.ticks   <- seq(t.start2,t.end2,"2 days")
    axis.POSIXct(ax,at=min.ticks,labels=F,tcl=-0.2)
    axis.POSIXct(ax,at=maj.ticks,cex.axis=0.7,
                 labels=format(maj.ticks,format="%d %b"),...)
#     # Add year
#     lab <- sprintf("%s\n%s", format(max(maj.ticks),format="%Y"),
#                    format(max(maj.ticks),format="%d %b"))
#     axis.POSIXct(ax,at=max(maj.ticks),labels=lab,lwd=2,...)
#     # Add grid
#     abline(v=maj.ticks,col="grey", lty="dotted", lwd=par("lwd"))
}

my.grid.week.simple <-function(t.start,t.end,ax=1,...){
    t.start2    <- trunc(t.start,"days")
    t.end2      <- trunc(t.end,"days")
    min.ticks   <- seq(t.start2,t.end,"hours")      # "2 hours"
    maj.ticks   <- seq(t.start2,t.end2,"6 hours")  # "days"
    maj.ticks2  <- seq(t.start2,t.end2,"days")      # "2 days"
    axis.POSIXct(ax,at=min.ticks,labels=F,tcl=-0.2)
    axis.POSIXct(ax,at=maj.ticks,labels=F,tcl=-0.3)
    axis.POSIXct(ax,at=maj.ticks2,labels=F,...)
    
    # Add grid
    grid(nx=NA, ny=NULL)
    abline(v=maj.ticks2,col="black", lty="dotted", lwd=par("lwd"))
}

my.grid.week2.year <-function(t.start,t.end,ax=1,col="black",lwd=2,...){
    t.start2    <- trunc(t.start,"days")
    t.end2      <- trunc(t.end,"days")
    min.ticks   <- seq(t.start2,t.end,"2 hours")
    maj.ticks   <- seq(t.start2,t.end2,"days")
    maj.ticks2  <- seq(t.start2,t.end2,"2 days")
    axis.POSIXct(ax,at=min.ticks,labels=F,tcl=-0.2)
    axis.POSIXct(ax,at=maj.ticks[-length(maj.ticks)],labels=F,tcl=-0.4)
    axis.POSIXct(ax,at=maj.ticks2[-length(maj.ticks2)],cex.axis=0.7,lwd=lwd,
                 labels=format(maj.ticks2[-length(maj.ticks2)],format="%d %b"),...)
    # Add year
    lab <- sprintf("%s\n%s", format(max(maj.ticks),format="%Y"),
                   format(max(maj.ticks),format="%d %b"))
    axis.POSIXct(ax,at=max(maj.ticks),labels=lab,lwd=lwd,
                 cex.axis=0.8,...)
    # Add grid
    grid(nx=NA, ny=NULL)
    abline(v=maj.ticks,col=col, lty="dotted", lwd=par("lwd"))
#     # Add grid
#     grid(nx=NA, ny=NULL)
#     abline(v=maj.ticks2,col="black", lty="dotted", lwd=par("lwd"))
}

my.grid.week2.simple <-function(t.start,t.end,ax=1,col="black",lwd=2,...){
    t.start2    <- trunc(t.start,"days")
    t.end2      <- trunc(t.end,"days")
    min.ticks   <- seq(t.start2,t.end,"2 hours")
    maj.ticks   <- seq(t.start2,t.end2,"days")
    maj.ticks2  <- seq(t.start2,t.end2,"2 days")
    axis.POSIXct(ax,at=min.ticks,labels=F,tcl=-0.2)
    axis.POSIXct(ax,at=maj.ticks[-length(maj.ticks)],labels=F,tcl=-0.4)
    axis.POSIXct(ax,at=maj.ticks2[-length(maj.ticks2)],labels=F,
                 cex.axis=0.7,lwd=lwd,...)
    
    # Add grid
    grid(nx=NA, ny=NULL)
    abline(v=maj.ticks,col=col, lty="dotted", lwd=par("lwd"))
}

my.grid.month <-function(t.start,t.end,ax=1,...){
    t.start2    <- trunc(t.start,"days")
    t.end2      <- trunc(t.end,"days")
    min.ticks   <- seq(t.start2,t.end,"days")
    maj.ticks   <- seq(t.start2,t.end2,"5 days")
    axis.POSIXct(ax,at=min.ticks,labels=F,tcl=-0.2)
    axis.POSIXct(ax,at=maj.ticks,cex.axis=0.7,lwd=1,
                 labels=format(maj.ticks,format="%d %b"),...)
    
    # Add grid
    grid(nx=NA, ny=NULL)
    abline(v=maj.ticks,col="black", lty="dotted", lwd=par("lwd"))
}

my.grid.month.nogrid <-function(t.start,t.end,ax=1,...){
    t.start2    <- trunc(t.start,"days")
    t.end2      <- trunc(t.end,"days")
    min.ticks   <- seq(t.start2,t.end,"days")
    maj.ticks   <- seq(t.start2,t.end2,"5 days")
    axis.POSIXct(ax,at=min.ticks,labels=F,tcl=-0.2)
    axis.POSIXct(ax,at=maj.ticks,cex.axis=0.7,lwd=1,
                 labels=format(maj.ticks,format="%d %b"),...)
}

my.grid.month.simple <-function(t.start,t.end){
    t.start2    <- trunc(t.start,"days")
    t.end2      <- trunc(t.end,"days")
    min.ticks   <- seq(t.start2,t.end,"days")
    maj.ticks   <- seq(t.start2,t.end2,"5 days")
    axis.POSIXct(1,at=min.ticks,labels=F,tcl=-0.2)
    axis.POSIXct(1,at=maj.ticks,labels=F)
    grid(nx=NA, ny=NULL)
    abline(v=maj.ticks,col="black", lty="dotted", lwd=par("lwd"))
}

my.grid.month.year <-function(t.start,t.end,ax=1,...){
    t.start2    <- trunc(t.start,"days")
    t.end2      <- trunc(t.end,"days")
    min.ticks   <- seq(t.start2,t.end,"days")
    maj.ticks   <- seq(t.start2,t.end2,"5 days")
    axis.POSIXct(ax,at=min.ticks,labels=F,tcl=-0.2)
    axis.POSIXct(ax,at=maj.ticks[-length(maj.ticks)],cex.axis=0.7,lwd=1,
                 labels=format(maj.ticks[-length(maj.ticks)],format="%d %b"),...)
    
    # Add year
    lab <- sprintf("%s\n%s", format(max(maj.ticks),format="%Y"),
                   format(max(maj.ticks),format="%d %b"))
    axis.POSIXct(1,at=max(maj.ticks),labels=lab,cex.axis=0.8)
    
    # Add grid
    grid(nx=NA, ny=NULL)
    abline(v=maj.ticks,col="black", lty="dotted", lwd=par("lwd"))
}


my.grid.year <-function(t.start,t.end){
    t.start     <- as.POSIXct(sprintf("%i-01-01",year(t.start)))
    t.end       <- as.POSIXct(sprintf("%i-01-01",year(t.end)))
    min.ticks   <- seq(t.start,t.end,"months")
    maj.ticks   <- seq(t.start,t.end,"years")
    axis.POSIXct(1,at=min.ticks,labels=F,tcl=-0.2)
    axis.POSIXct(1,at=maj.ticks,labels=T)
    grid(nx=NA, ny=NULL)
    abline(v=maj.ticks,col="black", lty="dotted", lwd=par("lwd"))
}

my.grid.year2 <-function(t.start,t.end){
    t.start     <- as.POSIXct(sprintf("%i-01-01",year(t.start)))
    t.end       <- as.POSIXct(sprintf("%i-01-01",year(t.end)))
    min.ticks   <- seq(t.start,t.end,"years")
    maj.ticks   <- seq(t.start,t.end,"10 years")
    axis.POSIXct(1,at=min.ticks,labels=F,tcl=-0.2)
    axis.POSIXct(1,at=maj.ticks,labels=T)
    grid(nx=NA, ny=NULL)
    abline(v=maj.ticks,col="black", lty="dotted", lwd=par("lwd"))
}

my.grid.year3 <-function(t.start,t.end){
    t.start     <- as.POSIXct(sprintf("%i-01-01",year(t.start)))
    t.end       <- as.POSIXct(sprintf("%i-01-01",year(t.end)))
    min.ticks   <- seq(t.start,t.end,"years")
    maj.ticks   <- seq(t.start,t.end,"5 years")
    axis.POSIXct(1,at=min.ticks,labels=F,tcl=-0.2)
    axis.POSIXct(1,at=maj.ticks,labels=T)
    grid(nx=NA, ny=NULL)
    abline(v=maj.ticks,col="black", lty="dotted", lwd=par("lwd"))
}
