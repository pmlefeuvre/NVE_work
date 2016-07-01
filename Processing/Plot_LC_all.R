#---------------------------------------------------------------#
#         FUNCTION THAT PLOTS LOAD CELL TIME SERIES             #
#                   FROM 1992 to 2014                           #
#                                                               #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2015-01-01 #
#                                       Last Update: 2016-13-08 #
#                                                               #
# Based on "Plot_LCall4.R", a version of "Plot_LC_all3.R"       #
#---------------------------------------------------------------#


#########################################
# Clean up Workspace
rm(list = ls(all = TRUE))
#########################################


############################################################################
# Detect Operating System
if(.Platform$OS.type == "unix"){   HOME="/Users/PiM/Desktop"}
if(.Platform$OS.type == "windows"){HOME="//nve/fil/h/HB/Bredata/breprosjekt/Engabreen/Engabreen Brelabben/"}

# Go to the following Path in order to access data files
setwd(sprintf("%s/NVE_work/Processing/",HOME))
Sys.setenv(TZ="UTC")    

# Load libraries (!!! NEED TO BE PRE-INSTALLED !!!)
library(zoo)
library(chron)
library(lattice)
library(grid)

# Load User Functions
source('f_Load_ZooSub_month.R')
source("../UserFunction/juliandate.R")


## PARAMETERS
sub.start   <- "11/01/1992 00:00"
sub.end     <- "01/01/2014 00:00"
t.start     <- as.POSIXct(sub.start,format="%m/%d/%Y %H:%M")
t.end       <- as.POSIXct(sub.end,format="%m/%d/%Y %H:%M")

daterange   <- paste(juliandate(t.start),juliandate(t.end),sep="_")
day         <- 60*60*24 

########################################
# Include all figures in a pdf
filename        <- sprintf("Plots/PDF_LC_all4_%s_15min.pdf", daterange)
# filename        <- sprintf("Plots/PDF_LC_all4_%s_daily.pdf", daterange)
pdf(file=filename,height=12,width=25)


################################################
####                Load Data               ####
################################################
# Load Data and create LC.reg.sub to avoid reloading the data
LC.reg.sub  <- Load_ZooSub_month(sub.start,sub.end,type="15min_mean")
# LC.reg.sub  <- Load_ZooSub_month(sub.start,sub.end,type="day_med")

# # Downsample to one point per hour
LC.reg.sub_orig <- LC.reg.sub
LC.reg.sub  <- LC.reg.sub_orig[seq(1,dim(LC.reg.sub_orig)[1],by=4)] 

LC.plot     <- merge(LC.reg.sub[,1],LC.reg.sub[,6],LC.reg.sub[,2],LC.reg.sub[,4]) 
ncol        <- dim(LC.plot)[2] 
# Rename columns 
colname  <- c("Normal Basal Pressure LC6 & LC4", "Normal Basal Pressure LC97_1 & LC97_2",
              "Normal Basal Pressure LC1e & LC7","Normal Basal Pressure LC2a, LC2b, LC01")
names(LC.plot) <- colname

# Plot Parameters
col     <- c(rep("black",ncol),rep("gray75",ncol),"gray25")
pch     <- "." 
cex     <- 0.01
cex.txt <- 2.1
lwd     <- 1

# Axis Parameters
xlabel  <- "Time [Month Year]"
ylabel  <- rep("P [MPa]",ncol) # Inversed
ymin    <- 0
ymax    <- 3
n.tick  <- signif((ymax-ymin)+1,digits=1) 
ylim    <- rep(list(c(ymin,ymax)),ncol)       
yticks  <- rep(list(seq(ymin, ymax,length.out=n.tick)),ncol)
xticks  <- seq(as.POSIXct("1993-01-01"),t.end,"years")
x.ticks.lab <- format(xticks,"%b %Y")
x.ticks.lab[cumsum(!is.na(x.ticks.lab)) %% 2 == 0] <- " "

# Legend Parameters
text.leg<- list(names(LC.reg.sub[,c(1,3)]),names(LC.reg.sub[,c(6,5)]),names(LC.reg.sub[,c(2,7)]),names(LC.reg.sub[,c(4,8)]))
vp.pos.x<- c(0.94,0.08,0.936,0.932) 


# Plot function
p              <- function(x, y,...) {
    # Grid
    panel.grid(h=-1, v=-1,x=x,y=y,col="grey");
    
    # Panel
    i <- panel.number();
    panel.xyplot(x, y,pch=pch, col=col[i],main=NULL,cex=cex,ylab=ylabel[i]);
    panel.abline(h = 0, lty=3)
    
    # Legend
    draw.key(list(text=list(text.leg[[i]]),
                  points=list(pch=19,col=c(col[i],col[i+4])),background="white",
                  border="black",columns=2,between=0.8,padding.text=4,
                  between.columns=0.8,cex=cex.txt),
             draw = TRUE,
             vp = viewport(x = unit(vp.pos.x[i], "npc"), y = unit(0.15, "npc"))) 
    #     legend("bottomright",text.leg[[i]],pch=".",cex=0.1,col[c(1,5)])
}


# Plot Lattice
obj <- xyplot(LC.plot, width="sj", strip=F, panel=p,
              main="Load Cell Data Overview",
              scales=list(y=list(relation='free', rot=0,limits=ylim,at=yticks), 
                          x=list(limits=c(t.start-day,t.end+day),at=xticks
                                 ,labels=x.ticks.lab),
                          cex=cex.txt, alternating=3),
              xlab=xlabel, ylab=ylabel,
              par.settings = list(par.main.text = list(cex=cex.txt+0.5),
                                  par.xlab.text = list(cex=cex.txt+0.5),
                                  par.ylab.text = list(cex=cex.txt+0.5)))

# Display plot
print(obj)


## Add Second Load Cell record in each panel
# Panel 1
trellis.focus("panel", 1, 1,highlight = FALSE)
do.call("panel.xyplot", list(index(LC.reg.sub), LC.reg.sub[,3], pch=pch,
                             col=col[5],lwd=lwd,main=NULL,cex=cex))
trellis.unfocus()

# Panel 2
trellis.focus("panel", 1, 2,highlight = FALSE)
do.call("panel.xyplot", list(index(LC.reg.sub), LC.reg.sub[,5], pch=pch,
                             col=col[6],lwd=lwd,main=NULL,cex=cex))
trellis.unfocus()

# Panel 3
trellis.focus("panel", 1, 3,highlight = FALSE)
do.call("panel.xyplot", list(index(LC.reg.sub), LC.reg.sub[,7], pch=pch,
                             col=col[7],lwd=lwd,main=NULL,cex=cex))
trellis.unfocus()

# Panel 4
trellis.focus("panel", 1, 4,highlight = FALSE)
do.call("panel.xyplot", list(index(LC.reg.sub), LC.reg.sub[,8], pch=pch,
                             col=col[8],lwd=lwd,main=NULL,cex=cex))
# do.call("panel.xyplot", list(index(LC.reg.sub), LC.reg.sub[,9], pch=".",
#                              col=col[9],lwd=2,main=NULL,cex=0.1))
trellis.unfocus()


########################################
# # End PDF/PS file
dev.off()


## Archive
# do.call("draw.key",list(text="LC6"),
#         draw=T,
#         vp = viewport(x = unit(0.75, "npc"), y = unit(0.9, "npc")))
# update(all,auto.key = list(x=0,y=0,text=c('test1','test2','test3')))
