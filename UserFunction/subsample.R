

##############################################################
######### FUNCTION FOR SUBSAMPLING LONG TIME SERIES ##########
##############################################################

# source('~/Desktop/PhD/Data Processing/R/subsample.R')

subsample <- function(zoo.data,sub.start,sub.end,f.print=T,drop=T) {
    
    # Define TZ to avoid time difference correction
    Sys.setenv(TZ="UTC")
    
    # Library
    require(chron)
    
    # Identify Date Format for start
    if        (nchar(sub.start) == 8) {
              dateformat.stt="%Y-%j"
    } else if (nchar(sub.start) == 10) {
        if ( length(grep("-",sub.start))>0 ){
              dateformat.stt="%Y-%m-%d"
        }else{dateformat.stt="%m/%d/%Y"
        }
    } else if (nchar(sub.start) == 16) {
        if ( length(grep("-",sub.start))>0 ){
              dateformat.stt="%Y-%m-%d %H:%M"
        }else{dateformat.stt="%m/%d/%Y %H:%M"
        }
    } else if (nchar(sub.start) == 19) {
        if ( length(grep("-",sub.start))>0 ){
            dateformat.stt="%Y-%m-%d %H:%M:%S"
        }else{dateformat.stt="%m/%d/%Y %H:%M:%S"
        }
    }
    
    # Identify Date Format for end
    if        (nchar(sub.end) == 8) {
        dateformat.end="%Y-%j"
    } else if (nchar(sub.end) == 10) {
        if ( length(grep("-",sub.end))>0 ){
            dateformat.end="%Y-%m-%d"
        }else{dateformat.end="%m/%d/%Y"
        }
    } else if (nchar(sub.end) == 16) {
        if ( length(grep("-",sub.end))>0 ){
            dateformat.end="%Y-%m-%d %H:%M"
        }else{dateformat.end="%m/%d/%Y %H:%M"
        }
    } else if (nchar(sub.end) == 19) {
        if ( length(grep("-",sub.end))>0 ){
            dateformat.end="%Y-%m-%d %H:%M:%S"
        }else{dateformat.end="%m/%d/%Y %H:%M:%S"
        }
    }
    
    # Print status
    if(f.print){
    cat("NOTE:",sub.start,"and",sub.end, "conforms to the dateformat:",
        dateformat.stt," and", dateformat.end,"\n")
    }
    # Convert in POSIXct (Note: POSIXct extracts my machine local time(zone), and 
    # corrected from UTC to CEST (2 hours difference)
    ts.start        <- as.POSIXct(sub.start, format=dateformat.stt, tz="UTC")
    ts.end          <- as.POSIXct(sub.end,   format=dateformat.end, tz="UTC")
    print(sprintf("Subsampling: %s - %s",as.Date(ts.start),as.Date(ts.end)))
    
    # In case there is a problem of formatting
    if(is.na(ts.start)){ts.start<-as.POSIXct(sub.start,format='%Y-%m-%d',tz="UTC")}
    if(is.na(ts.end))  {ts.end  <-as.POSIXct(sub.start,format='%Y-%m-%d',tz="UTC")}
    
    ## Note: I used to apply a time correction of 3600 sec, that were 
    ## substracted from the converted date because of a problem of time zone.
    ## It added one hour (if CET) and 2 hours (if CEST) to the original date
    ## SOLVED when setting TimeZone in UTC
    
    # Check if dates are in "chron" format. If yes, they are converted into "POSIXct"
    # Used for compatibility with old code.
    if( is.chron(index(zoo.data)) ){
     index(zoo.data)=as.POSIXct(index(zoo.data))   
    }
    
    # Get index for Date limits
    index.start     <- min(which(index(zoo.data) >= ts.start))
    index.end       <- max(which(index(zoo.data) <= ts.end))
    
    
    # Sub-sample data
    sub.data        <- zoo.data[index.start:index.end,drop=drop] 
    # ",drop=F" can be added to not convert one column into vector (keep colnames)
    # Reformat as array. Usually when input has one column
    if(!is.array(sub.data) && !drop){sub.data <- cbind(sub.data)}
    
    # Export output
    if (length(names(sub.data)) < 20){
        data.name <- names(sub.data)
    } else {data.name <- "!!No Names!!"}
    
    if(f.print){
    cat(">> Original dimensions:",nrow(zoo.data),"rows","\n")
    cat(">> Subsample of",data.name,"contains",
        nrow(sub.data),"observations","\n")
    }
    return(sub.data)
}

# Archive
#     cat("NOTE: Dates (e.g.",sub.start,"and",sub.end,
#         ") must have the format %Y-%j (julian day) or %m/%d/%Y for chron use","\n",
#         "      2013.12.11 - NOW also accepts %Y-%m-%d","\n")