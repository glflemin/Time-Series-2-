proc arima data=Ts2.well_imp plot=all;
	identify var=avg_corrected_well_height(1) nlag=24 stationarity=(adf=5);
run;
quit;

proc arima data=ts2.well_imp plot=all;
identify var=avg_corrected_well_height(1,8766) nlag=24;* minic scan esacf p=(0:5) q=(0:5);
estimate p=1 q=5;
forecast back=168 lead=168 out=residset;
run;
quit;
* for difference of 1,;
*2,2 has best model;

* for difference of 1 year then 1,;
* 1,5 is the best by far;
