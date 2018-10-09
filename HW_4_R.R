
library(plyr)
library(tidyverse)
library(rJava)
library(xlsx)
library(zoo)
library(forecast)
library(imputeTS)

setwd("C:\\Users\\Grant\\Downloads")
path <- "C:\\Users\\Grant\\Documents\\GitHub\\Time-Series-2-\\G_1260_T_imputed.csv"
well <- read_csv(path)

well.ts <- ts(well$Avg_Corrected_Well_Height, frequency=24) # creating a ts object from well height
indexer.ts <- ts(1, length(well.ts)) # creating an index variable for the ts

# creating sin and cos ts index terms. Added e's because why not
x1.sine=sin(2*pi*indexer.ts*1/12)
x1.cose=cos(2*pi*indexer.ts*1/12)
x2.sine=sin(2*pi*indexer.ts*2/12)
x2.cose=cos(2*pi*indexer.ts*2/12)
x3.sine=sin(2*pi*indexer.ts*3/12)
x3.cose=cos(2*pi*indexer.ts*3/12)
x4.sine=sin(2*pi*indexer.ts*4/12)
x4.cose=cos(2*pi*indexer.ts*4/12)

# bind the trig terms into a matrix
x.meg=cbind(x1.sine, x1.cose, x2.sine, x2.cose, x3.sine, x3.cose, x4.sine, x4.cose) 

# run an ARIMA with 0 pdq terms
arima.1<-Arima(well.ts, order=c(0,0,0))
summary(arima.1)

# run an ARIMA /w 1 p term 
arima.2<-Arima(well.ts,order=c(1,0,0),xreg=fourier(well.ts,K=4))
summary(arima.2)

# NOT WORKING YET 
S.ARIMA.2 <- Arima(well.ts, order=c(1,1,1), seasonal=c(1,1,1), xreg=fourier(well.ts, K=4), method="ML")
summary(S.ARIMA)

?Arima

