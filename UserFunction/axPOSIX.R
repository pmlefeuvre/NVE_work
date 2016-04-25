
########################################################
############## FORMAT DATE FOR X-AXIS ##################
########################################################
# ex: axPOSIX(x,"months","%m/%d")
#     axPOSIX(x,"years","%Y")

axPOSIX <- function (x,date.by=c("days","months","years"),date.format=c("%m/%d","%Y"))
{
    # Define Range by rounding up the date
    r <- round(range(as.POSIXct(index(x))), "days")
#     r <- as.POSIXct(round(range(index(x)), "days"))
    
    # Plot axis
    axis.POSIXct(1, at=seq(r[1], r[2], by=date.by), format=date.format)

}


## INFO ##
# %b : Abbreviated month name in the current locale. (Also matches full name on input.)
# %B : Full month name in the current locale. (Also matches abbreviated name on input.)



