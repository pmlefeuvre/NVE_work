# Plot all pressure and MetData 

# ##########################################
# # Clean up Workspace
rm(list = ls(all = TRUE))
# # Save "par" default
def.par <- par(no.readonly = TRUE)
# ##########################################

# Detect Operating System
if(.Platform$OS.type == "unix"){   HOME="/Users/PiM/Desktop"}
if(.Platform$OS.type == "windows"){HOME="//nve/fil/h/HB/Personlige mapper/PiM"}

# Go to the following Path in order to access data files
setwd(sprintf("%s/NVE_work/Processing/",HOME))
Sys.setenv(TZ="UTC")      

# Load library
source("f_Plot_LCs_MetHydro.R")

# Variables
LCname      <- c("LC6","LC4")#c("LC97_1","LC97_2")#
# Q.station   <- list(c("Fonndal_crump","Subglacial"),
#                     c("Fonndal_fjell","Subglacial"),
#                     c("sedimentkammer","Engabrevatn"),
#                     c("Engabreelv","Engabrevatn"))
# AT.station  <- c("Glomfjord","Reipaa","Engabrevatn","Skjaeret")
# PP.station  <- c("Glomfjord","Reipaa")

for (year in seq(1992,2015)){
    
    for (Q.station in list(c("sedimentkammer","Engabreelv"),
                           c("Engabreelv","Engabrevatn"),
                           c("Fonndal_crump","Subglacial"),
                           c("Fonndal_fjell","Subglacial"))){
        
        for (AT.station in c("Glomfjord","Reipaa","Engabrevatn","Skjaeret")){
            
            for (PP.station in c("Glomfjord","Reipaa")) {
                
                if (year==1992){sub.start <- sprintf("%i-11-01",year)
                }else{          sub.start <- sprintf("%i-01-01",year)}
                                sub.end   <- sprintf("%i-01-01",year+1)
                
                try(Plot_LCs_MetHydro(sub.start,sub.end,
                                      LCname,type="15min_mean",
                                      Q.station,AT.station,PP.station,f.plot=T))
                
            } 
            
        }
        
    }  
    
}

