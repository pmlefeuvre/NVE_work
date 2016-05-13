timespan <- function(data,maxgap.na){
    
    # Interpolate periods separated by less than 10 days
    span.na             <- !is.na(data)
    span.na[span.na==0] <- NA
    span.na             <- na.approx(span.na,maxgap=maxgap.na,na.rm=F) #10 days
    span.na[is.na(span.na)] <- 0
    span.na             <- zoo(span.na, index(data))
    
    # Extract period range.na with data
    range.na   <- span.na+lag(span.na,1,na.pad=F)
    # Deal with end
    range.na[1,which(range.na[1,]==2)] <- 1
    range.na[nrow(range.na),which(range.na[nrow(range.na),]==2)] <- 1
    
    # Go through the data and save start/end
    for (i in 1:ncol(range.na)){
        # Extract edges
        span    <- range.na[range.na[,i]==1,i]
        # Extract index of edges
        start   <- index(span[which(seq(1,length(span)) %% 2 == 1)])
        end     <- index(span[which(seq(1,length(span)) %% 2 != 1)])
        
        # Save
        out <- list(start=start,end=end)
        write.csv(out,sprintf("Data/Timespan/Timespan_%s.csv",
                              names(range.na)[i]),row.names=F)
    }
}