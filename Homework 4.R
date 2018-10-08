######################
#
#  Time Series Homework 4
#  Fall 2
#  Orange Team 1
#
######################

setwd("/Users/matttrombley/Desktop/Time Series II/Homework 4/")
library(plyr)

# Read in the data file
well <- read.csv("G-1260_T.csv")

# Create a time element that is hourly to aggregate on
well$UTC.Hour <- as.character(well$UTC.Hour)
well$date_hour <- paste(paste(well$UTC.Date,substr(well$UTC.Hour,1,nchar(well$UTC.Hour)-3),sep=" "),":00",sep="")

# Aggregate the corrected well height data to hourly
well_agg <- aggregate(well$Corrected, list(well$date_hour), mean)

# Clean up formatting of dates, times, and row/column names
well_agg$Group.1 <- as.POSIXct(strptime(well_agg$Group.1, "%m/%d/%y %H:%M"), tz="UTC")
well_agg <- well_agg[order(well_agg$Group.1),]
rownames(well_agg) <- 1:nrow(well_agg)
colnames(well_agg) <- c("Date_Time", "Avg_Corrected_Well_Height")

# Check to see if there are missing values
x1 <- as.POSIXct('2007-10-01 05:00:00',tz='UTC')
x2 <- as.POSIXct('2018-06-13 03:00:00',tz='UTC')
full_date_time <- as.data.frame(seq(from=x1,to=x2,by="hour"))
nrow(full_date_time) - nrow(well_agg) # 497 entries missing
colnames(full_date_time) <- c("Date_Time")

# Create full data set including missing times
well_imputed <- join(full_date_time,well_agg, by = "Date_Time", type = "left")
sum(is.na(well_imputed$Avg_Corrected_Well_Height)) # 497 NA values - can impute
which(is.na(well_imputed$Avg_Corrected_Well_Height)) # Index of missing values

# Impute missing values with desired measure
for (i in 1:nrow(well_imputed)) {
   if (is.na(well_imputed$Avg_Corrected_Well_Height[i])) {
      well_imputed$Avg_Corrected_Well_Height[i] = mean(well_agg$Avg_Corrected_Well_Height)
   }
}
