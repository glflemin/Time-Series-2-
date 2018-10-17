libname time "C:\Users\kiera\OneDrive\Documents\MSA 2019\Time Series\homework";


proc means data=time.all1260_new mean std;
	var Avg_Corrected_Well_Height;
run;

*try out some transformations;
data time.all1260_newb;
	set time.all1260_new;
	depth_log = log(Avg_Corrected_Well_Height);
	depth_centered = (Avg_Corrected_Well_Height - 3.7322836);
	depth_stdzd = (Avg_Corrected_Well_Height - 3.7322836)/1.2880925;
	*rain_log = log(rain_amt);
	rain_sq = rain_amt*rain_amt;
	*tide_log = log(tide_height);
	tide_sq = tide_height*tide_height;
	rain1=lag1(rain_amt);
	rain2=lag2(rain_amt);
	rain3=lag3(rain_amt);
	rain4=lag4(rain_amt);
	rain5=lag5(rain_amt);
	rain6=lag6(rain_amt);
	tide1=lag1(tide_height);
	tide2=lag2(tide_height);
	tide3=lag3(tide_height);
	tide4=lag4(tide_height);
	tide5=lag5(tide_height);
	tide6=lag6(tide_height);
	depth_log1=lag1(depth_log);
	depth_log2=lag2(depth_log);
run;
/*checking which lags you should use */
proc glmselect data=time.all1260_newb;
model depth_log=depth_log1 depth_log2 rain_amt rain1 rain2 rain3 rain4 rain5 rain6 tide_height tide1 tide2 tide3 tide4 tide5 tide6/selection=backward select=aic;
run;
quit;

/* need 2 y-axis here, do this later */
proc sgplot data=time.all1260_newb;
series x=date_time y=depth_stdzd;
*series x=date_time y=tide_height;
series x=date_time y=rain_amt;
run;
quit;



/* Adding in the new predictors ---KEEP THIS ONE!!!!! 1,2,3 & p=3 & q=1 slightly better */
proc arima data=time.all1260_newb;
identify var=depth_log(1,17532) crosscorr=(tide_height rain_amt) nlag=72;
*estimate input=(construction interest) p=2 method=ML;
estimate input=(tide_height (1,2,3,4) rain_amt) p=2 method=ML;
forecast back=168 lead=168 out=forecasts;
run;
quit;
proc arima data=time.all1260_newb;
identify var=depth_log(1,17532) crosscorr=(tide_height rain_amt) nlag=72;
*estimate input=(construction interest) p=2 method=ML;
estimate input=(tide_height (1,2,3) rain_amt) p=3 q=1 method=ML;
forecast back=168 lead=168 out=forecasts;
run;
quit;
*set up the casts dataset to calucate error stats on the forecasts;
data time.casts;
	set forecasts;
	if _n_ > 93503;
	predicted = exp(forecast);
	actual = exp(depth_log);
	residual_fr = actual - predicted;
	abserror = abs(residual_fr);
	abspcterror = abs(residual_fr/actual);
run;
*find MAE and MAPE;
proc means data = time.casts mean;
	var abserror abspcterror;
run;



