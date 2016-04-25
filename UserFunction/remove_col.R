
##############################################################
####################### FUNCTION #############################
##############################################################
# Example:     
#           Output          <- remove_col(LC.zoo.day)
#           ## Individualise the output with their original name
#           list2env(Output,env=environment())
#           rm(Output)


remove_col <- function(data,f.print=F) {
    
    print("Remove Empty Columns")
    
    # Create a string from the dataname for output
    dataname        <- c(deparse(substitute(data)),"lcol")
    
    # Remove empty data columns (only NA)
    # Check 1
    lcol            <- ncol(data)
    if(f.print){cat("Current Dimensions of",dataname,":", lcol,"\n")}
    
    # Extract columns, which have only NA values, store the column name in "drop"
    drop            <- rep(NA,lcol)

    for (i in 1:lcol){
        if (sum(is.na(data[,i])) >= nrow(data)-1){
            if(f.print){cat("Empty column:", names(data)[i],"\n")}
            drop[i] <- names(data)[i]
        }
    }
          
    # Remove columns defined "drop" from Raw
    data             <-data[,!(names(data) %in% drop)]
    
    # Check 2
    lcol            <- ncol(data)
    if(f.print){cat(dataname[1]," Dimensions AFTER removal",dataname[2],":", lcol,"\n")}
    
    # Create ouput list and rename them from the original name of the data
    Output          <- list(data,lcol)
    names(Output)   <- dataname
    
    # Export output
    if(f.print){cat(">> Outputs are:",names(Output),"\n")}
    return(Output)
    
    
}