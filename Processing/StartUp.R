
# Start Up
# These are the libraries that you need to run all the R routines

install.packages(c("zoo","chron","hydroTSM","Hmisc","lattice",
                   "latticeExtra","signal","MASS","hydroGOF",
                   "RColorBrewer","lubridate","psych","RCurl",
                   "quantmod","classInt","aqfig","plyr","scales",
                   "ggplot2"))


# Set the working directory where are all the routines
# Detect Operating System
if(.Platform$OS.type == "unix"){   HOME="/Users/PiM/Desktop"}
if(.Platform$OS.type == "windows"){HOME="//nve/fil/h/HB/Personlige mapper/PiM"}

# Go to the following Path in order to access data files
setwd(sprintf("%s/NVE_work/Processing/",HOME))
Sys.setenv(TZ="UTC")        

# The "Processing" Directory contains all codes that are used to convert load cell frequency into pressure, then save/load the data in different format and finally to process the pressure data for different analysis.
# 
# 1) The first program to run is "LoadAllData_subsample_save.R"/"LoadAllData_subsample_save_freq.R".
# They will read and combine the cleaned frequency data and save the pressure/frequency into files containing a subset of 2 months of the data (in "Data/Zoo/"). This splitting facilitates the loading and analysis of the load cell data.

source('LoadAllData_subsample_save.R') # To convert into and save pressure
source('LoadAllData_subsample_save_freq.R') # To save only frequency data


# 2) Now, that the data are saved and processed, they can be loaded into R using:
#   - "f_Load_ZooSub_month.R" to load the pressure of the load cell in MPa, and
#   - "f_Load_ZooSub_month_freq.R" to load the frequency in Hz.
# These two functions work similarly. First, you have to load them into R (i.e. source('f_Load_ZooSub_month.R') ), then you can call the function, the period of interest and the data type as follows:

source('f_Load_ZooSub_month.R') # Load the function that loads the LC data

LC.reg.sub <- Load_ZooSub_month("2000-01-01","2001-01-01","15min_mean")
head(LC.reg.sub)

# This loads the 15min interval pressure data for the period 2000-2001 and saves it into the variable "LC.reg.sub".
# (The data SHOULD ALWAYS BE SAVED IN THE VARIABLE "LC.reg.sub" FOR THE ROUTINE TO WORK PROPERLY).

# 3) For Plotting
# 3a) You can use the classic plot function in R. As LC.reg.sub is a zoo object, plot() will automatically have the time on the x-axis and Pressure on the y-axis.
# Each time series will have its own panel.

plot(LC.reg.sub)

# If you want all load cells on one single plot, just add:
plot(LC.reg.sub,plot.type="single")

# To plot points instead of lines (the default for zoo data), add: pch=20 or pch="."
plot(LC.reg.sub,plot.type="single",type="p",pch=".")
# pch gives the type of points to use. Find more types in the R help: ?pch

# The color of the time series is defined by the option "col"
plot(LC.reg.sub,plot.type="single",type="p",pch=".",col=c("red","orange","yellow","cyan","blue"))

# 3b) The pressure is plotted using the "Plot_LCs_Pressure()" function contained in "f_Plot_LCs.R". To get in R, run: 

source('f_Plot_LCs.R')

# Now, the function is accessible from the Console and you can run a default example, by running:

Plot_LCs_Pressure() # that is the same than
Plot_LCs_Pressure(sub.start="2003-07-01",sub.end="2003-07-15",LCname=c("LC97_1","LC97_2"),type="15min_mean",f.plot=FALSE)

# Notes: The load cells (LC) are plotted in pairs on subpanels.The number of panels depends on the number of LCs and allows a maximum of three pairs (or three panels).
# Input: The start and end of the period is given with the 2 first inputs, then the load cell names, the type of data and whether you want to save the figure
# A) sub.start and sub.end accepts date and time in the format: "2003-07-01 01:00".
# B) The order in "LCname" defines in which order the pairs of LCs are plotted. 
# C) The by-default data have 15min interval. 1-min and 1-day data can also be used with "min","day_med".
# D) The plot is viewed in R with f.plot set FALSE and saved in a pdf if set to TRUE, but then the figure does not appear in R.
# !!! For Saving plots, Please first make the directory "Plots" inside "Processing".


# 3d) Another routine can be used to plot the whole Pressure dataset that is saved in a pdf (Fig.3 in Lefeuvre et al., 2015)

source('Plot_LC_all.R')








