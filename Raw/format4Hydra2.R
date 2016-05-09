
#---------------------------------------------------------------#
#       REFORMAT LOAD CELL DATA FOR TRANSFER TO HYDRA 2         #
#                                                               #
# NOTES:                                                        #
# - INPUT: Compiled Frequency data for each year                #
# - LOOP through each year and EXTRACT time and data for each   #
#   load cell and each year.                                    #
# - Reformat time from "%Y,%j,%H%M" to "%Y%m%d/%H%M"            #
# - Remove empty lines for each load cell                       #
# - Change NaN values from -99999 to -9999                      #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2016-04-11 #
#                                       Last Update: 2016-04-27 #
#                                                               #
# Updates:                                                      #
# - 2016-04-02: Replace individual load cell codes by a loop    #
#               Change output directory from Sample to Hydra2   #
# - 2016-04-27: Convert bash code into a R routine              #
#                                                               #
#---------------------------------------------------------------#

##########################################
# # Clean up Workspace
# rm(list = ls(all = TRUE))
##########################################

format4Hydra2 <- function(year=2013){
    
    # Detect Operating System
    if(.Platform$OS.type == "unix"){   HOME="/Users/PiM/Desktop"}
    if(.Platform$OS.type == "windows"){HOME="//nve/fil/h/HB/Personlige mapper/PiM"}
    
    # Go to the following Path in order to access data files
    setwd(sprintf("%s/NVE_work/Raw/",HOME))
    Sys.setenv(TZ="UTC")          
    
    # Load libraries
    
    # Load User Functions
    
    
    #########################################################################
    # Order in Compiled files:   
    # Year-DaY-Hour-LC6-LC1e-LC4-LC2a-LC97_2-LC97_1-LC7-LC2b-LC01-Battery
    LCname      <- c("LC6","LC1e","LC4","LC2a","LC97_2","LC97_1",
                     "LC7","LC2b","LC01")
    lLC         <- length(LCname)
    
    # Loop through the years
    # year        <- seq(2013,2015) # Used as variable - 2016-05-09
    ly          <- length(year)
    
    ################
    for (n in 1:ly){
        
        cat("\n---\n")
        ######################################
        ##      LOAD DATA FOR EACH YEAR     ##
        ######################################
        # Path and filename
        path        <- sprintf("%i/ProcessingR",year[n])
        filename    <- sprintf("%s/Compiled_%i.csv",path,year[n])
        
        # Load the file
        colClasses  <- c(rep("character",3),rep("numeric",9)) 
        data.year   <- read.csv(filename,colClasses=colClasses)
        lrow        <- nrow(data.year)
        lcol        <- ncol(data.year) 
        cat("YEAR:",year[n],"--- Compiled_data - Total row:",lrow,"\n")
        
        
        # Extract Dates and Convert into the Hydra2 format
        Dates       <- as.POSIXct(strptime(sprintf("%s %s %s",data.year$Year,
                                                   data.year$Day,data.year$Hour),
                                           "%Y %j %H%M"))
        Dates_H2     <- strftime(Dates,"%Y%m%d/%H%M")
        
        ######################################
        ##     NaNs and DUPLICATED LINES     ##
        ######################################    
        # "Not a Number" values (also called NaN or NA) are converted back to -9999
        data.year[is.na(data.year)]<- (-9999)
        
        # Remove duplicated lines if any
        cat("Number of duplicated lines:",sum(duplicated(data.year)),"\n")
        data.year   <- data.year[!duplicated(data.year),]
        # Recompute number of rows in case duplicates are removed
        lrow        <- nrow(data.year)
        
        ######################################
        ##   SAVE DATA FOR EACH LOAD CELL   ##
        ######################################
        for (i in 1:lLC){
            
            # Extract Data for each load cell
            LCcol           <- which(colnames(data.year) == LCname[i])
            data.year.LC    <- sprintf("%s %s",Dates_H2,data.year[,LCcol])
            
            ######################################
            ##            SAVE DATA             ##
            ######################################
            # Path
            path.out    <- sprintf("%s/ProcessingR/Hydra2",year[n])
            dir.create(path.out,showWarnings = FALSE)
            
            # Filename
            filename.out<- sprintf("%s_%s.csv",LCname[i],year[n])
            
            # Write out with new order of the columns
            write.table(data.year.LC,sprintf("%s/%s",path.out,filename.out),
                        row.names=F,col.names=sprintf("Date %s",LCname[i]),
                        quote=F)
            
        }#End load cell loop
    }#End year loop  
}#End function
