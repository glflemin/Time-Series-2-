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
run;

/* need 2 y-axis here, do this later */
proc sgplot data=time.all1260_newb;
series x=date_time y=depth_stdzd;
*series x=date_time y=tide_height;
series x=date_time y=rain_amt;
run;
quit;

/* Adding in the new predictors ---KEEP THIS ONE!!!!! */
proc arima data=time.all1260_newb;
identify var=depth_log(1,17532) crosscorr=(tide_height rain_amt) nlag=72;
*estimate input=(construction interest) p=2 method=ML;
estimate input=(tide_height (1,2,3,4) rain_amt) p=2 method=ML;
forecast back=168 lead=168 out=forecasts;
run;
quit;
*set up the casts dataset to calucate error stats on the forecasts;
data casts;
	set forecasts;
	if _n_ > 93503;
	abserror = abs(residual);
	abspcterror = abs(residual/depth_log);
run;
*find MAE and MAPE;
proc means data = casts mean;
	var abserror abspcterror;
run;

