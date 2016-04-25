

clearcloseall <- function(){

###########################################
###############   CHECKS   ################
# Freeing up Memory System // Garbage cmd
gc()

# Clean up Workspace
rm(list = ls(all = TRUE))

# Check what is stored in the GlobalEnv and Clean it
remove(list = conflicts(detail=TRUE)$.GlobalEnv)

# Detach the column names and the dataframe 
#### Has to be ignored for the first run only ####
detach()

# Close all figure windows
graphics.off()

############################################
}

