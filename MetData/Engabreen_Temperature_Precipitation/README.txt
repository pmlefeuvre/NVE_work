Hei Paul,
I send you the Raw Data and some R codes that will 
transform the original irregular time series into
a regular time series that will include NA/NaN when
there are gaps.

You just need to run the file Run_All_Load.R in R:
source("Run_All_Load.R")
And it should automatically process the Raw Data and
create a Level 1 product.

If you want to skip this step, the processed data are
in the folder "Data". But I thin that you should be
aware of the processing and code I am using.

No correction is applied except for removing NA values.
There are just some time series/time stamp formatting.

The final format does not have header, is comma separated,
has an ISO date format %Y-%m-%d %HH:%MM:%SS and contains
only hourly values.

Have fun,

Cheers,

PiM						2013-09-03
