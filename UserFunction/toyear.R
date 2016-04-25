#                                            #
# Convert the index of data to the same year #
#                                            #
# Update: 2016-04-14
# I had to change the code in order to handle with error message caused by duplicates of the date
# Although this duplicate are done in purpose

# Source: http://r.789695.n4.nabble.com/xts-time-series-and-plot-questions-td3868424.html

# Library
require(xts)

# Function
toyear <- function(x, year) {
    # get year of last obs
    xyear <- .indexyear(last(x))+1900
    # get index and convert to POSIXlt
    ind <- as.POSIXlt(index(x))
    # set index year to desired value
    ind$year <- rep(year-1900,length(ind))
    x <- zoo(coredata(x),as.POSIXct(ind))
    # label column with year of last obs
    colnames(x) <- paste(colnames(x),xyear,sep=".")
    x
}

# OLD CODE DOES NOT WORK ANYMODE BECAUSE OF AN UPDATE OF ZOO
# # Function
# toyear <- function(x, year) {
#     # get year of last obs
#     xyear <- .indexyear(last(x))+1900
#     # get index and convert to POSIXlt
#     ind <- as.POSIXlt(index(x))
#     # set index year to desired value
#     ind$year <- year-1900
#     index(x) <- ind
#     # label column with year of last obs
#     colnames(x) <- paste(colnames(x),xyear,sep=".")
#     x
# }