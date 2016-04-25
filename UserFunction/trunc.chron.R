
###################################################
## COMING FROM :
## http://stackoverflow.com/questions/2134972/r-how-to-split-a-chron-date-time-object-in-zoo-for-aggregation
## Create sub-hourly time interval
###################################################

## Function 1: From Demosthenex
# Where X is a zoo obj with chron timestamps containing both time & date
# and min is like "00:30:00" for half hour intervals
trunc.chrontime <- function (x, min)
{
    if (!inherits(x, "times")) 
        x = as.chron(x)
    s = substr(as.character(x),11,18)
    c = chron(times=s)
    trunc(c,min)
}



## Function 2: from Shane 
trunc.minutes <- function (x, n.minutes) 
{
    if (!inherits(x, "times")) 
        x <- as.chron(x)
    x <- as.numeric(x)
    sec <- round(24 * 3600 * abs(x - floor(x)))
    h <- (sec%/%(n.minutes*60))/(60/n.minutes)
    hour <- as.integer(h)
    minutes <- (h %% hour) * 60
    chron(dates=chron::dates(x), times=times(paste(hour, minutes, "00", sep=":")))
}
