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

# Load library
library(tools) #

###########
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

# Read Discharge data
Sdt <- read.csv("stats_Sdt_year_short.csv")
Sdt <- Sdt[!is.na(Sdt[,1]),]
Sdt <- Sdt[Sdt[,4]>0,]
# Replace levels
levels(Sdt[,2])  <- c("Min.Engabreelv","Min.Engabrevatn","Min.SedimentChamber",
                      "Org.Engabreelv","Org.Engabrevatn","Org.SedimentChamber")

# Read comments and Noise level(not implemented)

# Creat Rich Text File
sink("Data_assessment_short.rtf")
cat("{\\rtf1\\ansi{\\fonttbl\\f0\\fswiss Helvetica;}\\f0\\pard")

for (year in seq(1992,2016)){
    
    cat("\\line {\\b >",year,"}")
    # Load Cells
    cat("\\line{\\i Load cells}\\line")
    for (i in which(LC[,1]==year)){
        cat(sprintf("- %s: %i days (%i pts)\\line",
                    LC[i,2],LC[i,4],LC[i,3]))
    }
    
    # Met. data
    A.t <- 0
    P.t <- 0
    for (i in which(Met[,1]==year)){
        # Air Temperature
        if(file_path_sans_ext(Met[i,2])=="AT"){
            A.t=A.t+1
            if(A.t==1){cat("\\line{\\i Air Temperature}\\line")}
            
            cat(sprintf("- %s: %i days (%i pts)\\line",
                        file_ext(Met[i,2]),Met[i,4],Met[i,3]))
        }
        # Precipitation
        if(file_path_sans_ext(Met[i,2])=="PP"){
            P.t=P.t+1
            if(P.t==1){cat("\\line{\\i Precipitation}\\line")}
            
            cat(sprintf("- %s: %i days (%i pts)\\line",
                        file_ext(Met[i,2]),Met[i,4],Met[i,3]))
        }
    }
    # Hydro. data
    Q.t <- 0
    for (i in which(Q[,1]==year)){
        # Discharge
        Q.t=Q.t+1
        if(Q.t==1){cat("\\line{\\i Discharge}\\line")}
        
        cat(sprintf("- %s: %i days (%i pts)\\line",
                    Q[i,2],Q[i,4],Q[i,3]))
    }
    # Sediment Conc. data
    Min.t <- 0
    Org.t <- 0
    # Mineral Sediment Concentration
    n <- which(Sdt[,1]==year)
    for (i in which(file_path_sans_ext(Sdt[n,2])=="Min")){
        Min.t <- Min.t+1
        if(Min.t==1){cat("\\line{\\i Mineral Sediment Concentration}\\line")}
        cat(sprintf("- %s: %i days (%i pts)\\line",
                    file_ext(Sdt[n[i],2]),Sdt[n[i],4],Sdt[n[i],3]))
    }
    # Organic Sediment Concentration
    for (i in which(file_path_sans_ext(Sdt[which(Sdt[,1]==year),2])=="Org")){
        Org.t <- Org.t+1
        if(Org.t==1){cat("\\line{\\i Organic Sediment Concentration}\\line")}
        cat(sprintf("- %s: %i days (%i pts)\\line",
                    file_ext(Sdt[n[i],2]),Sdt[n[i],4],Sdt[n[i],3]))
    }
    cat("\\page")
}
cat("\\par}")
sink()