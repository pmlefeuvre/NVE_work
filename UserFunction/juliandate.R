
################################################
####        Compute Julian Dates for        ####
####              the Same Year             ####
################################################

juliandate  <- function(Date){ 
    
# Conversion into Date format
Date        <- as.Date(Date)

# Extract the year of the date 
Year        <- floor(as.numeric(as.yearmon(Date)))

# Create Date string from the extracted year
Year.date   <- as.Date(paste(Year,"-01-01",sep=""))

# Compute julian day for the particular year (Add 1 to account for the date of origin)
Julian.date <- as.numeric(julian(Date,Year.date)) + 1 

# Create date string with the format %Y-%j
Julian.date <- paste(Year,sprintf("%03.0f",Julian.date),sep="-")


return(Julian.date)
}
