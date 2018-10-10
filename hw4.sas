

/* Augmented Dickey-Fuller Testing */

proc arima data=Ts2.well_imp plot=all;
	identify var=avg_corrected_well_height(25) nlag=24 stationarity=(adf=5);
run;
quit;

proc arima data=ts2.well_imp plot=all;
identify var=avg_corrected_well_height(1) nlag=24; *minic scan esacf p=(0:48) q=(0:48);
estimate p=1 q=1;
forecast back=168 lead=168;
run;
quit;
