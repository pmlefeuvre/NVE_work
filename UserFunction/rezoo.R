############################################
#    Reformat index entries into POSIXct   #
#     If there are duplicates, they are    #
#          aggregated with FUN=mean        #
############################################

rezoo <- function(zoozoo,zooindex=NULL) {
    
    
    
    # Extract data and convert time in POSIX object
    if (length(zooindex) == 0){
        x       <- as.POSIXct(index(zoozoo))
    } else {
        x       <- zooindex
    }
    y       <- coredata(zoozoo)
    
    # as.POSIXct does not get tz, so I have to set it manually to avoid it using tz=CEST
    attr(x, "tzone") <- 'UTC'
    
    # Reformat in zoo (time series)   
    rezoo   <- zoo(y,x)
    
    # Search for duplicates and give their timestamp 
    agg     <- index(zoozoo[which(duplicated(index(zoozoo)))])
    
    # If there are duplicates, it prints the identified columns and then aggregate them
    if (sum(is.na(agg))>1)
    {
        print(index(zoozoo[which(duplicated(index(zoozoo)))]))
        rezoo   <- aggregate(rezoo,index(rezoo),function(x) mean(x, na.rm=TRUE))
    }
    
    return(rezoo)
    
}