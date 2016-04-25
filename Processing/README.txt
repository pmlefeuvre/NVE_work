The "Processing" Directory contains all codes that are used to convert load cell frequency into pressure, then save/load the data in different format and finally to process the pressure data for different analysis.

1) The first program to run is "LoadAllData_subsample_save.R"/"LoadAllData_subsample_save_freq.R".
They will read and combine the cleaned frequency data and save the pressure/frequency into files containing a subset of 2 months of the data (in "Data/Zoo/"). This splitting facilitates the loading and analysis of the load cell data.

source('LoadAllData_subsample_save.R') # To convert into pressure
source('LoadAllData_subsample_save_freq.R') # To keep frequency data



2) Now, that the data are saved and processed, they can be loaded into R using:
- "f_Load_ZooSub_month.R" to load the pressure of the load cell in MPa, and
- "f_Load_ZooSub_month_freq.R" to load the frequency in Hz.
These two functions work similarly. First, you have to load them into R (i.e. source('f_Load_ZooSub_month.R') ), then you can call the function, the period of interest and the data type as follows:

LC.reg.sub <- Load_ZooSub_month("2000-01-01","2001-01-01","15minmean")

This loads the 15min interval pressure data for the period 2000-2001 and saves it into the variable "LC.reg.sub".

3) For Plotting, Please first make the directory "Plots" inside "Processing".

