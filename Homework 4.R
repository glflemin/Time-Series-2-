######################
#
#  Time Series Homework 4
#  Fall 2
#  Orange Team 1
#
######################

# Packages
library(plyr)
library(tidyverse)
library(rJava)
library(xlsx)
library(zoo)
library(forecast)
library(imputeTS)

# Working directories and file paths - Matt
setwd("/Users/matttrombley/Documents/GitHub/Time-Series-2-/")
well <- read.csv("G-1260_T.csv")

# Working directories and file paths - Grant
setwd("C:\\Users\\Grant\\Downloads")
path <- "C:\\Users\\Grant\\Documents\\GitHub\\Time-Series-2-\\G-1260_T.csv"
well <- read_csv(path)

well <- well[1:112063,] # Remove values having code P

# Create a time element that is hourly to aggregate on
well$UTC_Hour <- as.character(well$UTC_Hour)
well$date_hour <- paste(paste(well$UTC_Date,substr(well$UTC_Hour,1,nchar(well$UTC_Hour)-3),sep=" "),":00",sep="")

# Aggregate the corrected well height data to hourly
well_agg <- aggregate(well$Corrected, list(well$date_hour), mean)

# Clean up formatting of dates, times, and row/column names
well_agg$Group.1 <- as.POSIXct(strptime(well_agg$Group.1, "%m/%d/%y %H:%M"), tz="UTC")
well_agg <- well_agg[order(well_agg$Group.1),]
rownames(well_agg) <- 1:nrow(well_agg)
colnames(well_agg) <- c("Date_Time", "Avg_Corrected_Well_Height")

# Check to see if there are missing values
x1 <- as.POSIXct('2007-10-01 05:00:00',tz='UTC')
x2 <- as.POSIXct('2018-06-08 00:00:00',tz='UTC')
full_date_time <- as.data.frame(seq(from=x1,to=x2,by="hour"))
nrow(full_date_time) - nrow(well_agg) # 497 entries missing
colnames(full_date_time) <- c("Date_Time")

# Create full data set including missing times
well_imputed <- join(full_date_time,well_agg, by = "Date_Time", type = "left")
sum(is.na(well_imputed$Avg_Corrected_Well_Height)) # 497 NA values - can impute
which(is.na(well_imputed$Avg_Corrected_Well_Height)) # Index of missing values

# Impute missing values with desired measure
well_imputed$Avg_Corrected_Well_Height <- na.approx(well_imputed$Avg_Corrected_Well_Height)
sum(is.na(well_imputed$Avg_Corrected_Well_Height)) # No more NA values

# Check well plot for seasonality and/or trend (use zoo because ts doesn't work well with hourly indexing)
well_ts <- zoo(well_imputed$Avg_Corrected_Well_Height, full_date_time$Date_Time)
plot(well_ts,xlab = "Time (Years)", ylab = "Corrected Well Height (feet)", main="Time Series Plot of Well 1260 Height") # Plot of general time series
decomp <- ts(well_imputed$Avg_Corrected_Well_Height, freq=8760)
decomp_stl <- stl(decomp, s.window = 7)
plot(decomp_stl) # Definitely have seasonality; trend may be negligible

# Write out CSV for use in SAS
write.csv(well_imputed, file = 'G_1260_T_imputed.csv', row.names = TRUE)

# Split sets for training and evaluating models (one week for evaluation)
well_imp_train <- well_imputed[1:93623,]
well_imp_test <- well_imputed[93624:93791,]

##########

arima.well=Arima(well_ts,order=c(1,0,0))
summary(arima.well)
Acf(arima.well$residuals)$acf
Pacf(arima.well$residuals)$acf
x1.sin=sin(2*pi*well_ts*1/8766)
x1.cos=cos(2*pi*well_ts*1/8766)
x2.sin=sin(2*pi*well_ts*2/8766)
x2.cos=cos(2*pi*well_ts*2/8766)
x3.sin=sin(2*pi*well_ts*3/8766)
x3.cos=cos(2*pi*well_ts*3/8766)
x4.sin=sin(2*pi*well_ts*4/8766)
x4.cos=cos(2*pi*well_ts*4/8766)
x.reg=cbind(x1.sin,x1.cos,x2.sin,x2.cos,x3.sin,x3.cos,x4.sin,x4.cos)
test_arima <- Arima(well_ts, order = c(2, 0, 0), seasonal = c(1, 0, 0), xreg=x.reg, method = "ML")
summary(test_arima)
forecast(test_arima, h = 168)
plot(forecast(test_arima, h = 168))
