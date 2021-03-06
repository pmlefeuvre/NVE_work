
#---------------------------------------------------------------#
#           CONCATENATE, MERGE AND SORT LOAD CELL DATA          #
#                       FROM 1992 to 2015                       #
#                                                               #
# NOTES:                                                        #
# - The code loads all editted files placed in the OrderedR     #
#   folder, concatenate them per year and do extra few things.  #
#   Manual quality checks are necessary to locate lines with    #
#   errors (see the end of the file).                           #
# - This code is a conversion of the bash code:                 #
#       > merging_raw.sh lasted edited in 2013-02-19            #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2016-04-22 #
#                                       Last Update: 2016-04-22 #
#                                                               #
# Updates:                                                      #
#                                                               #
#---------------------------------------------------------------#

##########################################
# # Clean up Workspace
# rm(list = ls(all = TRUE))
##########################################

Raw_merging <- function(year=2013){
    
    # Detect Operating System
    if(.Platform$OS.type == "unix"){   HOME="/Users/PiM/Desktop"}
    if(.Platform$OS.type == "windows"){HOME="//nve/fil/h/HB/Personlige mapper/PiM"}
    
    # Go to the following Path in order to access data files
    setwd(sprintf("%s/NVE_work/PressureData/",HOME))
    Sys.setenv(TZ="UTC")        
    
    # Load libraries
    if(!require("zoo")){install.packages("zoo")}
    library(zoo)
    
    # Load User Functions
    
    #########################################################################
    
    # New Order    NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
    colname.new <- c("Year","Day","Hour","LC6","LC1e","LC4","LC2a","LC97_2",
                     "LC97_1","LC7","LC2b","LC01","Battery")
    lcol        <- length(colname.new) 
    
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
        path        <- sprintf("%s/OrderedR",year[n])
        filename    <- list.files(path,pattern=c(".dat|.DAT"),full.names=T)
        lf          <- length(filename)
        
        # Load and concatenate files using do.call, rbind and lapply
        data.year   <- do.call("rbind",
                               lapply(filename,
                                      function(fname) read.csv(fname, header=F,
                                                               blank.lines.skip=T)))
        lrow        <- nrow(data.year)
        cat("YEAR:",year[n],"--- Compiled_data - Total row:",lrow,"\n")
        
        # Add column names
        colnames(data.year) <- colname.new
        
        ######################################
        ##     NaNs and DUPLICATED LINES     ##
        ######################################    
        # "Not a Number" values (also called NaN or NA) are converted back to blanks
        data.year[is.na(data.year)]<-""
        
        # Compute and Print whether line and date duplicates exist 
        cat("Number of duplicated lines:",sum(duplicated(data.year)),"\n")
        dupl.date <- sum(duplicated(data.year[,c(1,2,3)]))
        if (dupl.date>0){cat("Number of duplicated dates:",dupl.date,"\n",
                             "!!! some data are from another year !!!", "\n")}
        # Remove duplicated lines if any
        data.year   <- data.year[!duplicated(data.year),]
        # Recompute number of rows in case duplicates are removed
        lrow        <- nrow(data.year)
        
        ######################################
        ##         SORT DATA BY DATES       ##
        ######################################
        # Add year to first column
        data.year[,1] <- rep(year[n],lrow)
        # Reformat columns for doy and Hr:Min
        data.year[,2] <- sprintf("%03.0f",as.numeric(data.year[,2]))
        data.year[,3] <- sprintf("%04.0f",as.numeric(data.year[,3]))
        #     # Round to 4 decimals
        #     for (j in seq(4,12)){data.year[,j] <- round(data.year[,j],4)}
        
        # Reorder according to the day (2nd column) and hour:minute (3rd column)
        data.year   <- data.year[order(data.year[,2],data.year[,3]),]
        
        ######################################
        ##     EXTRACT BATTTERY VOLTAGE     ##
        ######################################
        # Extract Dates and Battery Voltage
        Dates       <- as.POSIXct(strptime(sprintf("%s %s %s",data.year[,1],
                                                   data.year[,2],data.year[,3]),
                                           "%Y %j %H%M"))
        voltage     <- zoo(data.year[,13],Dates)
        voltage     <- voltage[!is.na(index(voltage))] #SOLVE ISSUE WITH NA
            
        # Remove the column with voltage data from the battery
        data.year <- data.year[,seq(1,12)]
        
        ######################################
        ##            SAVE DATA             ##
        ######################################
        # Path
        path.out    <- sprintf("%s/ProcessingR",year[n])
        dir.create(path.out,showWarnings = FALSE)
        
        # Filename
        filename.out<- sprintf("Compiled_%s.csv",year[n])
        
        # Write out with new order of the columns
        write.table(data.year,sprintf("%s/%s",path.out,filename.out), sep=",",
                    row.names=F,col.names=T,quote=F)
        
        
        # Write out Battery voltage
        filename.out<- sprintf("Voltage_%s.csv",year[n])
        write.zoo(voltage,sprintf("%s/%s",path.out,filename.out))
        
    }#End year loop
}#End function



## ARCHIVE
## VERIFY THAT ALL ROWS OF EACH FILES ARE READ 
#     lrow.total <- 0
#     # Loop through the files
#     for (i in 1:lf){ 
#         # Load
#         data.old    <- read.csv(filename[i],header=F,blank.lines.skip=T)
#         lrow        <- nrow(data.old)
#         lrow.total  <- lrow.total + lrow
#     }
#     cat("YEAR:",year[n],"--- All_datafiles - Total row:",lrow.total,"\n")





