
*libname time "C:\Users\kiera\OneDrive\Documents\MSA 2019\Time Series";
libname timer "C:\\Users\\Grant\\Downloads";

data time.well;
	set well;
	if code = 'A';
	hour = hour(time);
	hour_char = put(hour, $2.);
	pi=constant("pi"); *just telling SAS that pi is pi;
	s1=sin(2*pi*1*_n_/12);*all divided by length of season, length of 2pi, 1 2 3 4 is just the different variations, _n_ is an index for the observation #;
	c1=cos(2*pi*1*_n_/12);
	s2=sin(2*pi*2*_n_/12);
	c2=cos(2*pi*2*_n_/12);
	s3=sin(2*pi*3*_n_/12);
	c3=cos(2*pi*3*_n_/12);
	s4=sin(2*pi*4*_n_/12);
	c4=cos(2*pi*4*_n_/12);
	drop hour;
run;

/*seasonal dummy variables -- dlag can't go past 12 tho....
proc glm data = time.well;
	class hour_char;
	model corrected = hour_char;
	output out=time.check r=residual ;
run;
*now run the ARIMA on the residuals;
proc arima data=time.check plot=all;
	identify var=residual nlag=25 stationarity=(adf=2); *for proc arima, identify and var always have to be there -- nlag tells sas how many lags to go back for THE PLOTS;
			*adf = tells it how many to go back for THE TESTS;
run;
quit;
*/

*to view well series;
proc arima data=time.well plot=all;
identify var=corrected nlag = 25 stationarity=(adf=2);
run;
quit;
*random walk?;
*take differences;
proc arima data=time.well plot=all;
identify var=corrected(1) nlag = 25 stationarity=(adf=2);
run;
quit;

*differencing at 1 and seasonal difference at 24;
proc arima data=time.well plot=all;
	identify var=corrected(1,24) nlag=72;
	estimate p=(1,24) method=ML; 
	*estimate q=(1)(12) method=ML; *to make it multiplicative;
	forecast back=168 lead=168;
run;
quit;

*Trying out some trig functions -- all pvalues suuuuper high;
proc arima data=time.well plot=all;
	identify var=corrected(1,24) crosscorr=(s1 c1 s2 c2 s3 c3 s4 c4);
	estimate p=(1,24) input=(s1 c1 s2 c2 s3 c3 s4 c4); *p=1 --> AR(1);
	forecast back=168 lead=168;
run;
quit;


proc glm data = time.well plots(maxpoints=999999999);
	class hour;
	model corrected = hour;
run;
