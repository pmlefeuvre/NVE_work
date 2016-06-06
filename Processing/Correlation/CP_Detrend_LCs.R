
##########################################################################
##              Extract Trends and Short Term Variablilty               ##
##              And Plot Month Variations for:                          ##
##              - 4 years Period between 1996 - 2013                    ##
##              - Whole Period 1996 - 2013
##########################################################################

###########################################
# # Clean up Workspace
# rm(list = ls(all = TRUE))
###########################################

### Go to the following Path in order to access data files
setwd("/Users/PiM/Desktop/PhD/Data Processing/Load Cells/Processing")
Sys.setenv(TZ="UTC")  

# Load libraries
library(zoo)
library(lattice)
library(signal)

# Load User Functions
source('~/Desktop/PhD/Data Processing/Load Cells/Processing/f_Detrend.R')


# Interval
hour        <- 60 #min
day         <- 24 #hours 

win.mean    <- 4*hour/15#12*hour/15 #15min interval = 4 points per hour
win.corr    <- 12*(hour/15)#24*(hour/15)

print(paste("Win.mean:", win.mean))
print(paste("Win.corr:", win.corr))



# #################################
# ## Correlation for 4 YEAR periods
# 
# years <- seq(1996,2012,4)
# years[5] <- years[5]+1 #To add 2013
# 
# for (k in 1:(length(years)-1)){
#     
#     # Time span
#     sub.start <- sprintf("01/01/%i 00:00",years[k])
#     # Condition to change month end for 2013
#     if(years[k+1]<2013){sub.end=sprintf("01/01/%i 00:00",years[k+1])
#     }else{sub.end=sprintf("05/01/%i 00:00",years[k+1])}
#     
#     # Print
#     print(sprintf("Analysing Corr. between %i & %i",years[k],years[k+1]))
#     
#     # Function
#     LC.reg.sub <- f_Detrend(LCnames=c("LC6","LC97_2"),
#                             sub.start= sub.start,
#                             sub.end  = sub.end,
#                             win.mean,win.corr)
# }


###############################################
## Correlation between LCs for the WHOLE Period
# LCnames     <- names(LC.reg.sub)
LCnames     <- c("LC6","LC4","LC97_1","LC97_2","LC1e","LC7")
n           <- 1

for (i in LCnames[2:length(LCnames)]){
    
    print(sprintf("Correlation between %s & %s",LCnames[n],i))
    LC.reg.sub <- f_Detrend(LCnames=c(LCnames[n],i),
                            sub.start="11/01/1992 00:00",
                            sub.end=  "05/01/2013 00:00",
                            win.mean,win.corr) 
}



#################################
##### ARCHIVE

# hour.mean   <- c(1,2,4,8,day/2,day,2*day,4*day,6*day)
# hour.coor   <- c(1,2,4,8,day/2,day,2*day,4*day,6*day)

# LC.reg.sub <- f_Detrend(LCnames=c("LC6","LC4"),
#                         sub.start="01/01/1996 00:00",
#                         sub.end=  "05/01/2013 00:00",
#                         win.mean,win.corr)
# 
# LC.reg.sub <- f_Detrend(LCnames=c("LC6","LC4"),
#                         sub.start="01/01/1996 00:00",
#                         sub.end=  "01/01/2000 00:00",
#                         win.mean,win.corr)
# 
# LC.reg.sub <- f_Detrend(LCnames=c("LC6","LC4"),
#                         sub.start="01/01/2000 00:00",
#                         sub.end=  "01/01/2004 00:00",
#                         win.mean,win.corr)
# 
# LC.reg.sub <- f_Detrend(LCnames=c("LC6","LC4"),
#                         sub.start="01/01/2004 00:00",
#                         sub.end=  "01/01/2008 00:00",
#                         win.mean,win.corr)
# 
# LC.reg.sub <- f_Detrend(LCnames=c("LC6","LC4"),
#                         sub.start="01/01/2008 00:00",
#                         sub.end=  "05/01/2013 00:00",
#                         win.mean,win.corr)
# 
# ##
# print(paste("LCnames:", c("LC97_1","LC97_2")))
# 
# LC.reg.sub <- f_Detrend(LCnames=c("LC97_1","LC97_2"),
#                         sub.start="01/01/1996 00:00",
#                         sub.end=  "05/01/2013 00:00",
#                         win.mean,win.corr)
# 
# LC.reg.sub <- f_Detrend(LCnames=c("LC97_1","LC97_2"),
#                         sub.start="01/01/1996 00:00",
#                         sub.end=  "01/01/2000 00:00",
#                         win.mean,win.corr)
# 
# LC.reg.sub <- f_Detrend(LCnames=c("LC97_1","LC97_2"),
#                         sub.start="01/01/2000 00:00",
#                         sub.end=  "01/01/2004 00:00",
#                         win.mean,win.corr)
# 
# LC.reg.sub <- f_Detrend(LCnames=c("LC97_1","LC97_2"),
#                         sub.start="01/01/2004 00:00",
#                         sub.end=  "01/01/2008 00:00",
#                         win.mean,win.corr)
# 
# LC.reg.sub <- f_Detrend(LCnames=c("LC97_1","LC97_2"),
#                         sub.start="01/01/2008 00:00",
#                         sub.end=  "05/01/2013 00:00",
#                         win.mean,win.corr)
# 
# 
# print(paste("LCnames:", c("LC6","LC97_2")))
# LC.reg.sub <- f_Detrend(LCnames=c("LC6","LC97_2"),
#                         sub.start="01/01/1996 00:00",
#                         sub.end=  "05/01/2013 00:00",
#                         win.mean,win.corr) 