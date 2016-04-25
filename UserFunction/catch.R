
# print("tic")
# Sys.sleep(3)
# print("tic") 


## Function to know the given time and value

catch	<- function(LC, Boundary, Condition, LCname){

	# Look at superior or inferior values depending on the variable of Condition 
	       if (Condition == 1){
	 		Rows	<- which(LC >= Boundary, arr.in=TRUE);
	} else if (Condition == -1){
 			Rows	<- which(LC <= Boundary, arr.in=TRUE);
	}

# Construct an array (time, value and row number) with the values that fulfills the previous condition (see "Boundary")
 Time 		<- strptime(paste(Year[Rows], Day[Rows], Times[Rows]),"%Y %j %H:%M");
 Value 		<- LC[Rows];
 result	 	<- paste(as.character(Time), Rows, Value, sep=" ");

# Create path and filename and then Save the data
# path 		<- paste(getwd(),"/Search/",sep="")
 today 		<- format(Sys.Date(), "%Y-%m-%d");
 filename 	<- paste("Search/",paste(LCname,today,"csv", sep="."),sep="");
 write(result, file=filename, sep=",");

# Print the values in the terminal
 return(result)

# Clear the variables
 rm(LC,Boundary, Condition, LCname, Rows, Value, Time, result)

}
