######################
#
#  Time Series Final Project
#  Fall 2
#  Orange Team 1
#
######################

# Packages
library(plyr)
library(zoo)

# Working directories and file paths
setwd("/Users/matttrombley/Documents/GitHub/Time-Series-2-/")
well <- read.csv("G-1260_T.csv")
rain <- read.csv("G-1260_T_rain.csv")
tide <- read.csv("station_8722802.csv")

# Remove values having code P and make time indices match well data
well <- well[1:112063,]
rain <- rain[69221:443908,]
tide <- tide[173031:1109630,]

# Create a time element that is hourly to aggregate on
well$time <- as.character(well$time)
rain$Time <- as.character(rain$Time)
tide$hour_check <- substr(tide$Time,1,1)
tide$hour1 <- substr(tide$Time,2,2)
tide$hour2 <- substr(tide$Time,1,2)
tide$new_hour <- ifelse(tide$hour_check == '0',tide$hour1,tide$hour2)
well$date_hour <- paste(paste(well$date,substr(well$time,1,nchar(well$time)-3),sep=" "),":00",sep="")
rain$date_hour <- paste(rain$Date,paste(substr(rain$Time,1,nchar(rain$Time)-3),":00",sep=""),sep=" ")
tide$date_hour <- paste(tide$Date,paste(tide$new_hour,":00",sep=""),sep=" ")

# Aggregate the corrected well height data to hourly
well_agg <- aggregate(well$Corrected, list(well$date_hour), mean)
rain_agg <- aggregate(rain$RAIN_FT, list(rain$date_hour), sum)
tide_agg <- aggregate(tide$Prediction, list(tide$date_hour), mean)

# Clean up formatting of dates, times, and row/column names
well_agg$Group.1 <- as.POSIXct(strptime(well_agg$Group.1, "%m/%d/%y %H:%M"), tz="UTC")
rain_agg$Group.1 <- as.POSIXct(strptime(rain_agg$Group.1, "%m/%d/%y %H:%M"), tz="UTC")
tide_agg$Group.1 <- as.POSIXct(strptime(tide_agg$Group.1, "%Y-%m-%d %H:%M"), tz="UTC")
well_agg <- well_agg[order(well_agg$Group.1),]
rain_agg <- rain_agg[order(rain_agg$Group.1),]
tide_agg <- tide_agg[order(tide_agg$Group.1),]
rownames(well_agg) <- 1:nrow(well_agg)
rownames(rain_agg) <- 1:nrow(rain_agg)
rownames(tide_agg) <- 1:nrow(tide_agg)
colnames(well_agg) <- c("Date_Time", "Avg_Corrected_Well_Height")
colnames(rain_agg) <- c("Date_Time", "Rain_Amt")
colnames(tide_agg) <- c("Date_Time", "Tide_Height")

# Check to see if there are missing values
x1 <- as.POSIXct('2007-10-01 01:00:00',tz='UTC')
x2 <- as.POSIXct('2018-06-07 23:00:00',tz='UTC')
full_date_time <- as.data.frame(seq(from=x1,to=x2,by="hour"))
colnames(full_date_time) <- c("Date_Time")
nrow(full_date_time) - nrow(well_agg) # 509 row difference
nrow(full_date_time) - nrow(rain_agg) # 0 row difference
nrow(full_date_time) - nrow(tide_agg) # 12 row difference


# Create full data set including missing times
well_imputed <- join(full_date_time,well_agg, by = "Date_Time", type = "left")
tide_imputed <- join(full_date_time,tide_agg, by = "Date_Time", type = "left")
rain_imputed <- rain_agg[1:(nrow(rain_agg)-1),]
sum(is.na(well_imputed$Avg_Corrected_Well_Height)) # 508 NA values - can impute
sum(is.na(tide_imputed$Tide_Height)) #11 NA values - can impute
# which(is.na(well_imputed$Avg_Corrected_Well_Height)) # Index of missing values

# Impute missing values with desired measure
well_imputed$Avg_Corrected_Well_Height <- na.approx(well_imputed$Avg_Corrected_Well_Height)
tide_imputed$Tide_Height <- na.approx(tide_imputed$Tide_Height)
sum(is.na(well_imputed$Avg_Corrected_Well_Height)) # No more NA values
sum(is.na(tide_imputed$Tide_Height)) # No more NA values

# Join together into one set and write out all sets
merged_set <- join(well_imputed,tide_imputed,by="Date_Time",type="left")
merged_set <- join(merged_set,rain_imputed,by="Date_Time",type="left")
write.csv(merged_set, "G-1260_merged_data.csv")
