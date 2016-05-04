
#########################################################################
#         Load, Correct, Save and Plot Discharge Data from the          #
#                   Svartisen Subglacial Laboratory                     # 
#                      - Fonndal Crump                                  #
#                      - Fonndal Fjellterskel                           #
#                      - Sediment Chamber                               #
#                                                                       #
# Author: Pim Lefeuvre                              Date: 2014-09-11    #
#                                                                       #
# Require packages: chron,zoo,hydroTSM,hydroGOF,signal,RColorBrewer     #
# You can potentially install them with the following code:             #
# install.packages("chron","zoo","hydroTSM","hydroGOF","signal","RColorBrewer") #
# Restricitve Firewalls can stop the installation                       #
#                                                                       #
#                                                                       #
# FOLDER STRUCTURE (need to be created before hand):                    #     
# path.wd/ stores all R codes used for the processing                   # 
# path.wd/UserFunctions stores my functions for repetitive simple jobs  #
#                                                                       #
# path.wd/Data/Discharge stores discharge output                        #
# path.wd/Data/Raw stores Hydra 2 komplett raw data                     #
#                                                                       #
# path.wd/Plots/ stores all plots                                       #
# path.wd/Plots/Compare_SubDaily compares daily discharge products      #
# path.wd/Plots/Discharge_Hr plot Hourly Q with model for each year     #
# path.wd/Plots/Lag_Sc_F plot results of lag analysis                   #
# path.wd/Plots/Predict_Sc_R2 Plot attempts of Q predictions            #
#                                                                       #
#                                                                       #
# Warnings: "In zoo(rval, index(x)[i]) : some methods for “zoo” objects #
# do not work if the index entries in ‘order.by’ are not unique"        #
# are issued after using the user function barplot_TimeFactors. Problem #
# is not identified. Function works reasonnably well, most of the time. #     
#                                                                       #
#                                                                       #
# Formerly (partly from) "Hydra2/CP_f_LoadQ.R"                          #
#########################################################################

###########################################
# Clean up Workspace
rm(list = ls(all = TRUE))
# Save "par" default
def.par <- par(no.readonly = TRUE)
###########################################

# !! HAS TO BE ENTERED MANUALLY!!
# !! HAS TO BE ENTERED MANUALLY!!
# Set Path -- "path.wd" is the path to the Working Directory 
# !! HAS TO BE ENTERED MANUALLY!!
# !! HAS TO BE ENTERED MANUALLY!!
# Detect Operating System
if(.Platform$OS.type == "unix"){   HOME="/Users/PiM/Desktop"}
if(.Platform$OS.type == "windows"){HOME="//nve/fil/h/HB/Personlige mapper/PiM"}

# Go to the following Path in order to access data files
path.wd <- sprintf("%s/NVE_work/MetData/DischargeSSL_corrections",HOME) 
setwd(path.wd)
Sys.setenv(TZ="UTC")  

# Load libraries
library(chron)
library(zoo)
library(lubridate) # cmd: year

# Load User functions
source("f_LoadQ.R")
source("f_DischargeCorrection.R")
source("Plot_Discharge_hourly.R")

# Make folder where will be saved the data
dir.create("Plots/",showWarnings = FALSE)
dir.create("../../Processing/Data/MetData/",showWarnings = FALSE)
dir.create("../../Processing/Data/MetData/Discharge",showWarnings = FALSE)

#################################################################
#####                   LOAD DISCHARGE DATA                 #####
#################################################################
print(">> LOAD <<")
# Path
path_raw    <- "Data/Raw"

##### SEDIMENT CHAMBER
# Komplet Data
filename    <- sprintf("%s/%s",path_raw,
                       "sedimentkammer_komplet_Discharge.csv")
filename_out<- "SedtChamber_Q_komp.csv"

# Load, Process and Save data
f_LoadQ(filename,filename_out,path.wd) 
#####



##### FONNDAL CRUMP
# Komplet Data
filename    <- sprintf("%s/%s",path_raw,
                       "Fonndal_crump_komplet_Discharge.csv")
filename_out<- "FonndalC_Q_komp.csv"

# Load, Process and Save data
f_LoadQ(filename,filename_out,path.wd) 
#####


##### FONNDAL FJELLSTERKEL
# Komplet Data
filename    <- sprintf("%s/%s",path_raw,
                       "Fonndal_fjell_komplet_Discharge.csv")
filename_out<- "FonndalF_Q_komp.csv"

# Load, Process and Save data
f_LoadQ(filename,filename_out,path.wd) 
#####


##### SUBGLACIAL INTAKE
# Komplet Data -- DAILY!! -- NOT USED
filename    <- sprintf("%s/%s",path_raw,
                       "subglasial_inntak_komplet_Discharge.csv")
filename_out<- "Subglacial_Q_komp.csv"

# Load, Process and Save data
f_LoadQ(filename,filename_out,path.wd) 
# Known warning message due to downsampling
#####


#################################################################
#####               DISCHARGE CORRECTIONS                   #####
#################################################################
print(">> APPLY CORRECTION <<")
# Apply Corrections to Fonndal and Sediment Chamber
Discharge_Correction(path.wd,f.plot=F)


#################################################################
#####           PREDICT SEDIMENT CHAMBER DISCHARGE          #####
#################################################################
print(">> COMPUTE DISCHARGE PREDICTION <<")
source("Predict_SedimentChamber.R")


#################################################################
# FILL GAPS FROM INTERPOLATION OF COEFFICIENT FROM LINEAR MODEL #
#################################################################
print(">> FILL GAPS IN DISCHARGE <<")
source("FillGaps_SedtChbr_roll_lm.R")


#################################################################
#####   LAG ANALYSIS BETWEEN FONNDAL AND SEDIMENT CHAMBER   #####
#################################################################
print(">> ANALYSE LAG BETWEEN Q STATIONS <<")
source("Lag_SedtChbr_Fonndal.R")


#################################################################
##### COMPARE RESULTS OF DAILY DISCHARGE WITH NVE's RESULTS #####
#################################################################
print(">> COMPARE DAILY DISCHARGES COMPUTED BY NVE AND THIS CODE <<")
source("Compare_DailySub_NVE-pmle.R")


#################################################################
#####               PLOT HOURLY DISCHARGE                   #####
#################################################################
print(">> PLOT HOURLY DISCHARGE<<")
# Period per year
year     <- seq(1997,2013)

# Path and Filename
path            <- "../../Processing/Data/MetData/Discharge"
# Make folder where will be saved the plots
dir.create("Plots/Discharge_Hr/",showWarnings = FALSE)

# Filename for Subglacial Discharge
filename_Q <- sprintf("%s/Q.Sub.orig-pred.csv",path)
for (j in year){
    # Function
    Output <- Plot_Discharge_hourly(filename_Q,year=j,path.wd)
    # Extract Variable contained in Output to not load twice data
    list2env(Output,env=environment())
}
rm(Q,Q.mean,Output)

# Filename for Sediment Chamber
filename_Q <- sprintf("%s/Q.Sc.orig-pred-combined.csv",path)
for (j in year){
    # Function
    Output <- Plot_Discharge_hourly(filename_Q,year=j,path.wd)
    # Extract Variable contained in Output to not load twice data
    list2env(Output,env=environment())
}
rm(Q,Q.mean,Output)





