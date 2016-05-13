#---------------------------------------------------------------#
#           FORMAT AND WRITE EXTRACTED STATISTICS               #
#                   FOR THE DATA ASSESSMENT                     #
#                                                               #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2016-05-11 #
#                                       Last Update: 2016-05-11 #
#                                                               #
#---------------------------------------------------------------#

# ##########################################
# # Clean up Workspace
rm(list = ls(all = TRUE))
# # Save "par" default
def.par <- par(no.readonly = TRUE)
# ##########################################

setwd("~/Desktop/NVE_work/Documentation/Data_assessment")
#
library(tools)

# Read LC data
LC  <- read.csv("stats_LCs_year_short.csv")
LC  <- LC[!is.na(LC[,1]),]
# # Notes
# LC.notes <- cbind(rep("low",6+3),rep("med",3),rep("low",3),
#                   "med","low-med","med-high",rep("high",6))

# Read AirTemp. and Precip. data
Met <- read.csv("stats_ATPP_year_short.csv")
Met <- Met[!is.na(Met[,1]),]
Met <- Met[Met[,4]>0,]
# Replace levels
levels(Met[,2]) <- c("AT.Engabrevatn","AT.Glomfjord","AT.Reipaa",
                     "AT.Skjaeret1","AT.Skjaeret2","PP.Glomfjord","PP.Reipaa")

# Read Discharge data
Q   <- read.csv("stats_Q_year_short.csv")
Q   <- Q[!is.na(Q[,1]),]
Q   <- Q[Q[,4]>0,]
# Replace levels
levels(Q[,2])  <- c("Engabreelv","Engabrevatn","Fonndal_crump","Fonndal_fjell",
                    "SedimentChamber","Subglacial(Fc)","Subglacial(Ff)")

sink("Data_assessment_short.txt")
for (year in seq(1992,2016)){
    
    cat("\n>",year)
    # Load Cells
    cat("\nLoad cells\n")
    for (i in which(LC[,1]==year)){
        cat(sprintf("- %s: %i days (%i pts) --- Noise: low ---\n",
                    LC[i,2],LC[i,4],LC[i,3]))
    }
    
    # Met. data
    A.t <- 0
    P.t <- 0
    for (i in which(Met[,1]==year)){
        # Air Temperature
        if(file_path_sans_ext(Met[i,2])=="AT"){
            A.t=A.t+1
            if(A.t==1){cat("\nAir Temperature\n")}
            
            cat(sprintf("- %s: %i days (%i pts) --- Noise: low ---\n",
                        file_ext(Met[i,2]),Met[i,4],Met[i,3]))
        }
        # Precipitation
        if(file_path_sans_ext(Met[i,2])=="PP"){
            P.t=P.t+1
            if(P.t==1){cat("\nPrecipitation\n")}
            
            cat(sprintf("- %s: %i days (%i pts) --- Noise: low ---\n",
                        file_ext(Met[i,2]),Met[i,4],Met[i,3]))
        }
    }
    # Hydro. data
    Q.t <- 0
    for (i in which(Q[,1]==year)){
        # Discharge
        Q.t=Q.t+1
        if(Q.t==1){cat("\nDischarge\n")}
        
        cat(sprintf("- %s: %i days (%i pts) --- Noise: low ---\n",
                    Q[i,2],Q[i,4],Q[i,3]))
    }
}
sink()