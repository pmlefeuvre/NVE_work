

#---------------------------------------------------------------#
#      REORDER LOAD CELL DATA TO FIT 1992-2013 SEQUENCE         #
#                                                               #
# NOTES:                                                        #
# - The code is adapted to the structure of each file (columns  #
#   with year,day,hour,load cells,...) found in the Raw Folder. #
#   It depends on manual input and is therefore not flexible.   #
# - This code is a conversion of two bash codes:                #
#   > Raw_editting_1992-1998.sh lasted edited in 2013-10-15 and #
#   > Raw_editting_1999-2013.sh lasted edited in 2013-10-08.    #
#                                                               #
# Author: Pim Lefeuvre                         Date: 2016-04-21 #
#                                       Last Update: 2016-04-21 #
#                                                               #
# Updates:                                                      #
#                                                               #
#---------------------------------------------------------------#

##########################################
# Clean up Workspace
rm(list = ls(all = TRUE))
##########################################

# Go to the following Path in order to access data files
setwd("/Users/PiM/Desktop/NVE_work/Raw/")
Sys.setenv(TZ="UTC")    

# Load libraries

# Load User Functions

#########################################################################

# New Order    NaN - DoY - Hr:Mn - 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
colname.new <- c("Year","DoY","Hr:Min","LC6","LC1e","LC4","LC2a","LC97_2",
                 "LC97_1","LC7","LC2b","LC01","Battery")
lcol        <- length(colname.new) 

# Loop through the years
year        <- seq(1992,2013)
ly          <- length(year)

################
for (n in 1:ly){
    
    cat("\n---")
    ######################################
    ##      LOAD DATA FOR EACH YEAR     ##
    ######################################
    # Path and filename
    path        <- sprintf("%s/Raw",year[n])
    filename    <- list.files(path,pattern=c(".dat|.DAT"),full.names=T)
    lf          <- length(filename)
    
    # To simplify handling of files, get their number (ONLY work for particular years)
    if(year[n]<=1998){
        file.number <- regmatches(basename(filename), regexpr("[0-9].*[0-9]",
                                                              basename(filename)))
        if(year[n]<=1995){          file.number <- as.numeric(file.number)}
        if(year[n]%in%c(1996,1997)){file.number <- as.numeric(gsub("_","0",file.number))}
        if(year[n]==1998){ 
            file.number[c(1,lf)]   <- "99999"
            file.number             <- as.numeric(file.number)}
    }
    
    ################
    # Loop through the files
    for (i in 1:lf){ 
        
        # Load
        data.old    <- read.csv(filename[i],header=F,blank.lines.skip=T)
        lrow        <- nrow(data.old)
        
        cat("\nYEAR:",year[n],"--- file:",filename[i]," \t-- col.:",
            ncol(data.old),", row:",lrow)
        
        ######################################
        ##   NAs and ASSIGN EMPTY MATRIX    ##
        ######################################   
        # NAs are converted back to blanks
        data.old[is.na(data.old)]<-""
        
        # Make dataframe with an empty matrix
        data.new    <- as.data.frame(matrix(data='',lrow,lcol)) 
        
        ############################################
        ## REORDER EACH FILE TO NEW COLUMN FORMAT ##
        ############################################  
        # Reorder the columns of each file
        if (year[n] %in% c(1992,1993,1994,1995)){
            
            if (file.number[i]<=40){
                # Column Order in the file(s) -- 1992 and 1993 
                # Name: Station-Year-DoY-Hr:Mn-Battery-LoggerTemp.- 4 - 6 - 2a - 2b - 7  - 1e
                # Col.:    1   - 2  - 3 -  4  -   5   -    6      - 7 - 8 -  9 - 10 - 11 - 12
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col.:  2 - 3 -  4   - 8 - 12 - 7 -  9 -  ""  -  ""  - 11 - 10 - "" -  5
                # NewCol:1 - 2 -  3   - 4 - 5  - 6 -  7 -  ""  -  ""  - 10 - 11 - "" -  13
                order.data.old              <- c(2,3,4,8,12,7,9,11,10,5 )
                order.data.new              <- c(1,2,3,4,5 ,6,7,10,11,13)
            } else if (file.number[i]<=47){
                # Column Order in the file(s) -- 1993 
                # Name: Station-Year-DoY-Hr:Mn- 4 - 6 - 2a - 2b - 7 - 1e
                # Col.:    1   - 2  - 3 -  4  - 5 - 6 - 7  - 8 -  9 - 10
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col.:  2  - 3 -  4  - 6 - 10 - 5 -  7 -  ""  -  ""  - 9  - 8  - "" -  ""
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  ""  -  ""  - 10 - 11 - "" -  ""
                order.data.old              <- c(2,3,4,6,10,5,7,9 ,8 )
                order.data.new              <- c(1,2,3,4,5 ,6,7,10,11)
            } else if (file.number[i]<=71){
                # Column Order in the file(s)  -- 1993  
                # Name: Station-DoY-Hr:Mn- 4 - 6 - 2a - 2b - 7 - 1e
                # Col.:    1   - 2 -  3  - 4 - 5 - 6  - 7  - 8 -  9 
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col.:  1  - 2 -  3  - 5 - 9  - 4 -  6 -  ""  -  ""  - 8  - 7  - "" -  ""
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  ""  -  ""  - 10 - 11 - "" -  ""
                order.data.old              <- c(1,2,3,5,9,4,6,8 ,7 )
                order.data.new              <- c(1,2,3,4,5,6,7,10,11)
            } else if (file.number[i]<=90){
                # Column Order in the file(s)  -- 1994            #(in  089 & 090 )
                # Name:Station-DoY-Hr:Mn- 7 - 1e - 2b - 2a - 4 - 6 ( - LoggerTemp.)
                # Col.:   1   - 2 -  3  - 4 - 5  - 6  - 7  - 8 - 9 ( -     10     )
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col.:  1  - 2 -  3  - 9 - 5  - 8 -  7 -  ""  -  ""  - 4  - 6  - "" -  ""
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  ""  -  ""  - 10 - 11 - "" -  ""
                order.data.old              <- c(1,2,3,9,5,8,7,4 ,6)
                order.data.new              <- c(1,2,3,4,5,6,7,10,11)
            } else if (file.number[i]<=95){
                # Column Order in the file(s)  -- 1994            
                # Name:Station-DoY-Hr:Mn- 7 - 1e - 2b - 2a - 4 - 6  - LoggerTemp. - Battery 
                # Col.:   1   - 2 -  3  - 4 - 5  - 6  - 7  - 8 - 9  -     10     -     11  
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col.:  1  - 2 -  3  - 9 - 5  - 8 -  7 -  ""  -  ""  - 4  - 6  - "" -  11
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  ""  -  ""  - 10 - 11 - "" -  13
                order.data.old              <- c(1,2,3,9,5,8,7,4 ,6 ,11)
                order.data.new              <- c(1,2,3,4,5,6,7,10,11,13)
            } else if (file.number[i]<=98){
                # Column Order in the file(s)  -- 1994 and 1995  
                # Name:Station-DoY-Hr:Mn- 2a - 2b - 1e - 7 - 6 - 4 -Battery-LoggerTemp.
                # Col.:   1   - 2 -  3  - 4  - 5  - 6  - 7 - 8 - 9 -  10   -    11
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col.:  1  - 2 -  3  - 8 - 6  - 9 -  4 -  ""  -  ""  - 7  - 5  - "" -  10
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  ""  -  ""  - 10 - 11 - "" -  ""
                order.data.old              <- c(1,2,3,8,6,9,4,7 ,5 ,10)
                order.data.new              <- c(1,2,3,4,5,6,7,10,11,13)
            }
            
        } else if (year[n] %in% c(1996,1997)){
            
            if (file.number[i]<=97011){
                # Column Order in the file(s)  -- 1996 and 1997 
                # Name:Station-DoY-Hr:Mn- 6 - 1e - 4 - 2b - 2a - ?? -Battery-LoggerTemp
                # Col.:   1   - 2 -  3  - 4 - 5  - 6 - 7  - 8  - 9  -   10  -   11
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col:   1  - 2 -  3  - 4 - 5  - 6 -  8 -  ""  -  ""  - "" - 7  - "" -  10
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  ""  -  ""  - "" - 11 - "" -  13
                order.data.old              <- c(1,2,3,4,5,6,8,7 ,10)
                order.data.new              <- c(1,2,3,4,5,6,7,11,13)
            } else if (file.number[i]<=97013){
                # Column Order in the file(s)  -- 1997 
                # Name: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2b - 2a - 97_2 - 97_1 -Battery-LoggerTemp
                # Col.:    1   - 2 -  3  - 4 - 5  - 6 - 7  - 8  -  9   -  10  -  11   -    12
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col:   1  - 2 -  3  - 4 - 5  - 6 -  8 -  9   -  10  - "" - 7  - "" -  11
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - "" - 11 - "" -  13
                order.data.old              <- c(1,2,3,4,5,6,8,9,10,7 ,11)
                order.data.new              <- c(1,2,3,4,5,6,7,8,9 ,11,13)
            } else if (file.number[i]<=97014){
                # Column Order in the file(s)  -- 1997 
                # Name: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2b - 2a - 97_1 -25barPT-10barPT
                # Col.:    1   - 2 -  3  - 4 - 5  - 6 - 7  - 8  -  9   -  10   -  12
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col:   1  - 2 -  3  - 4 - 5  - 6 -  8 -  ""  -  9   - "" - 7  - "" -  ""
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  ""  -  9   - "" - 11 - "" -  ""
                order.data.old              <- c(1,2,3,4,5,6,8,9,7 )
                order.data.new              <- c(1,2,3,4,5,6,7,9,11)
            } else if (file.number[i]<=98001){
                # Column Order in the file(s)  -- 1997 and 1998                                      #(in 97015-16)
                # Name: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2b - 2a - 97_2 - 97_1 -25barPT-10barPT-Battery(-LoggerTemp)
                # Col.:    1   - 2 -  3  - 4 - 5  - 6 - 7  - 8  -  9   -  10  -  11   -  12   -  13   (-    14    )
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col:   1  - 2 -  3  - 4 - 5  - 6 -  8 -  9   -  10  - "" - 7  - "" -  13
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - "" - 11 - "" -  13
                order.data.old              <- c(1,2,3,4,5,6,8,9,10,7 ,13)
                order.data.new              <- c(1,2,3,4,5,6,7,8,9 ,11,13)
            }
            
        } else if (year[n]==1998){
            
            if (file.number[i]<=98016){
                # Column Order in the file(s)  -- 1997 and 1998                                      
                # Name: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2b - 2a - 97_2 - 97_1 -25barPT-10barPT-Battery
                # Col.:    1   - 2 -  3  - 4 - 5  - 6 - 7  - 8  -  9   -  10  -  11   -  12   -  13   
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col:   1  - 2 -  3  - 4 - 5  - 6 -  8 -  9   -  10  - "" - 7  - "" -  13
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - "" - 11 - "" -  13
                order.data.old              <- c(1,2,3,4,5,6,8,9,10,7 ,13)
                order.data.new              <- c(1,2,3,4,5,6,7,8,9 ,11,13)
            } else if (file.number[i]<=98020){
                # Column Order in the file(s)  -- 1998
                # Name: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2b - 2a - 97_2 - 97_1 -Battery
                # Col.:    1   - 2 -  3  - 4 - 5  - 6 - 7  - 8  -  9   -  10  -  11    
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col:   1  - 2 -  3  - 4 - 5  - 6 -  8 -  9   -  10  - "" - 7  - "" -  11
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - "" - 11 - "" -  13
                order.data.old              <- c(1,2,3,4,5,6,8,9,10,7 ,11)
                order.data.new              <- c(1,2,3,4,5,6,7,8,9 ,11,13)
            } else if (basename(filename[i])=="CompiledXLS_1998.dat"){
                # Remove ":" in Hr:Min
                data.old[,3] <- gsub(":","",data.old[,3])
                
                # Column Order in the file(s)  -- 1998
                # Name: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - ?? -Battery
                # Col.:    1   - 2 -  3  - 4 - 5  - 6 - 7  -  8   -  9   - 10 -  11    
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col:   1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - "" - "" - "" -  11
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - "" - "" - "" -  13
                order.data.old              <- c(1,2,3,4,5,6,7,8,9,11)
                order.data.new              <- c(1,2,3,4,5,6,7,8,9,13)
            } else if (basename(filename[i])=="Data99_01.dat"){
                # Column Order in the file(s)  -- 1998
                # Name: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - ?? -Battery
                # Col.:    1   - 2 -  3  - 4 - 5  - 6 - 7  -  8   -  9   - 10 -  11    
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col:   1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - "" - "" - "" -  11
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - "" - "" - "" -  13
                order.data.old              <- c(1,2,3,4,5,6,7,8,9,11)
                order.data.new              <- c(1,2,3,4,5,6,7,8,9,13)
            }
            
        } else if (year[n] %in% c(1999,2000)){
            # Remove ":" in Hr:Min for the file FromGaute'sBackupCompiled_2000_117_ordered.dat
            data.old[,3] <- gsub(":","",data.old[,3])
            
            # Column Order in the file(s)  -- 1999 and 2000
            # Name: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  -Battery
            # Col.:    1   - 2 -  3  - 4 - 5  - 6 - 7  -  8   -  9   - 10 -  11    
            # New Order, respect column order and empty columns    
            # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
            # Col:   1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - 10 - "" - "" -  11
            # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - 10 - "" - "" -  13
            order.data.old              <- c(1,2,3,4,5,6,7,8,9,10,11)
            order.data.new              <- c(1,2,3,4,5,6,7,8,9,10,13)
            
        } else if (year[n] %in% c(2001,2002)){
            
            if (basename(filename[i])=="Mar20001a.dat"){
                # Column Order in the file(s)  -- 2001
                # Name: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  -Battery
                # Col.:    1   - 2 -  3  - 4 - 5  - 6 - 7  -  8   -  9   - 10 -  11    
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col:   1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - 10 - "" - "" -  11
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - 10 - "" - "" -  13
                order.data.old              <- c(1,2,3,4,5,6,7,8,9,10,11)
                order.data.new              <- c(1,2,3,4,5,6,7,8,9,10,13)
            } else {
                # Column Order in the file(s)  -- 2001 and 2002
                # Name: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 01 -Battery
                # Col.:    1   - 2 -  3  - 4 - 5  - 6 - 7  -  8   -  9   - 10 -  11    
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col:   1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - "" - "" - 10 -  11
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - "" - "" - 12 -  13
                order.data.old              <- c(1,2,3,4,5,6,7,8,9,10,11)
                order.data.new              <- c(1,2,3,4,5,6,7,8,9,12,13)
            }
            
        } else if (year[n]==2003){
            
            if (basename(filename[i]) %in% c("FEB18001.dat","APR02001.dat","MAY03a.dat")){
                # Column Order in the file(s)  -- 2003
                # Name: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 01 -Battery
                # Col.:    1   - 2 -  3  - 4 - 5  - 6 - 7  -  8   -  9   - 10 -  11    
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col:   1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - "" - "" - 10 -  11
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - "" - "" - 12 -  13
                order.data.old              <- c(1,2,3,4,5,6,7,8,9,10,11)
                order.data.new              <- c(1,2,3,4,5,6,7,8,9,12,13)
            } else if (basename(filename[i]) %in% c("MAY03b.dat","JUL03001.dat","SEP28001.dat","Nov07.dat")){
                # Column Order in the file(s)  -- 2003
                # Name: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 -Battery
                # Col.:    1   - 2 -  3  - 4 - 5  - 6 - 7  -  8   -  9   - 10    
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col:   1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - "" - "" - "" -  10
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - "" - "" - "" -  13
                order.data.old              <- c(1,2,3,4,5,6,7,8,9,10)
                order.data.new              <- c(1,2,3,4,5,6,7,8,9,13)
            } else if (basename(filename[i]) %in% c("Nov13.dat","MAR240001.dat")){
                # Column Order in the file(s)  -- 2003
                # Name: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  -Battery
                # Col.:    1   - 2 -  3  - 4 - 5  - 6 - 7  -  8   -  9   - 10 -  11    
                # New Order, respect column order and empty columns    
                # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
                # Col:   1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - 10 - "" - "" -  11
                # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - 10 - "" - "" -  13
                order.data.old              <- c(1,2,3,4,5,6,7,8,9,10,11)
                order.data.new              <- c(1,2,3,4,5,6,7,8,9,10,13)
            }
        } else if (year[n]>2003){
            # Column Order in the file(s)  -- 2004-2013
            # Name: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  -Battery
            # Col.:    1   - 2 -  3  - 4 - 5  - 6 - 7  -  8   -  9   - 10 -  11    
            # New Order, respect column order and empty columns    
            # Name:St/Yr-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  - 2b - 01 - Battery
            # Col:   1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - 10 - "" - "" -  11
            # NewCol:1  - 2 -  3  - 4 - 5  - 6 -  7 -  8   -  9   - 10 - "" - "" -  13
            order.data.old              <- c(1,2,3,4,5,6,7,8,9,10,11)
            order.data.new              <- c(1,2,3,4,5,6,7,8,9,10,13)
            
        }
        
        ############################################################################
        # REORDER THE COLUMNS !!!! MOST IMPORTANT LINE OF CODE !!!!
        data.new[,order.data.new]   <- data.old[,order.data.old ]
        ############################################################################
        
        ######################################
        ##            SAVE DATA             ##
        ######################################
        # Directory
        path.out    <- sprintf("%s/OrderedR",year[n]) 
        dir.create(path.out,showWarnings = FALSE)
        # Filename
        filename.out<- sprintf("%s_ordered.dat",
                               strsplit(basename(filename[i]),"\\.")[[1]][1])
        
        # Write out with new order of the columns
        write.table(data.new,sprintf("%s/%s",path.out,filename.out), sep=",",
                    row.names=F,col.names=F,quote = F)
    }
}

#### KNOWN PROBLEMS CAUSING ERRORS OR WARNINGS ####
# 1) Add end line
# If the following message appears in the console, it means that you need to
# add a blank line at the end of the file. the read.table() does not seem to 
# detect the end of the file.
#
# 1: In read.table(file = file, header = header, sep = sep, quote = quote,  :
#    incomplete final line found by readTableHeader on '1993/Raw/data013.dat'
# 
# FOR:
# [1] "YEAR:1993 --- file: 1993/Raw/data013.dat"
# [1] "YEAR:1993 --- file: 1993/Raw/data015.dat"
# [1] "YEAR:1993 --- file: 1993/Raw/data017.dat"

# 2) Add one or two columns
# I had to add 1 or 2 commas (columns) on the 1st line to make the number of
# columns fit the used formats. Usually files where one value is saved only 
# intermittently (such as Battery voltage) caused the problem.
#
# Error in `[.data.frame`(data.old, , order.data.old) : 
# undefined columns selected
#
# FOR
# [1] "YEAR:1997 --- file: 1997/Raw/DAT97_07.DAT"
# [1] "YEAR:1997 --- file: 1997/Raw/DAT97_17.DAT"
# [1] "YEAR:1997 --- file: 1997/Raw/DAT97_18.DAT"
# [1] "YEAR:1997 --- file: 1997/Raw/DAT98001.dat"
# [1] "YEAR:1998 --- file: 1998/Raw/DAT980[02-20].dat"
# [1] "YEAR:1998 --- file: 1998/Raw/Data99_01.dat"
# All files in  1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008,
#               2009, 2010, 2011, 2012, 2013

# 3) Split files that have different data format
# Splitted Mar20001.dat into two files: 
# - Mar20001a.dat that has the structure: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 7  -Battery
# - Mar20001b.dat that has the structure: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 01 -Battery 

# Splitted MAY03.dat into two files: 
# - MAY03a.dat that has the structure: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 - 01 -Battery
# - MAY03b.dat that has the structure: Station-DoY-Hr:Mn- 6 - 1e - 4 - 2a - 97_2 - 97_1 -Battery 


