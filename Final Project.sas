data well_merged;
set ts2.well_merged;
time=_n_;
pi=constant("pi");
s1=sin(2*pi*1*_n_/8766);
c1=cos(2*pi*1*_n_/8766);
s2=sin(2*pi*2*_n_/8766);
c2=cos(2*pi*2*_n_/8766);
s3=sin(2*pi*3*_n_/8766);
c3=cos(2*pi*3*_n_/8766);
s4=sin(2*pi*4*_n_/8766);
c4=cos(2*pi*4*_n_/8766);
drop var1;
run;

proc sgplot data=well_merged;
series x=time y=avg_corrected_well_height;
series x=time y=tide_height;
series x=time y=rain_amt;
run;
quit;

proc arima data=well_merged;
identify var=avg_corrected_well_height(1,8766) crosscorr=(tide_height(6) rain_amt(2)) nlag=24;* p=(0:12) q=(0:12) minic esacf;
estimate p=1 q=8 input=(/(1)tide_height rain_amt);
forecast back=168 lead=168 out=test1;
run;
quit;
/*
1,9 with just tide height or 2,8
2,8
4,2 looks good as well
5,1 looks good as well
q=8,9,10 all good options
don't go below 2 for p

best I have so far

proc arima data=well_merged;
identify var=avg_corrected_well_height(1,8766) crosscorr=(tide_height(6) rain_amt(2)) nlag=24;* p=(0:12) q=(0:12) minic esacf;
estimate p=1 q=8 input=(/(1)tide_height rain_amt);
forecast back=168 lead=168 out=test1;
run;
quit;
*/
data mape;
	set test1(firstobs=93504);
	pct_error = 100*abs(residual)/abs(avg_corrected_well_height);
run;
proc means data=mape n mean;
	var pct_error;
run;
