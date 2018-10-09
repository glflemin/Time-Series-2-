

/* Augmented Dickey-Fuller Testing */

proc arima data=Ts2.well_imp plot=all;
	identify var=avg_corrected_well_height(24) nlag=24 stationarity=(adf=2);
run;
quit;

data well_imp;
set ts2.well_imp;
pi=constant("pi");
s1=sin(2*pi*1*_n_/8766);
c1=cos(2*pi*1*_n_/8766);
s2=sin(2*pi*2*_n_/8766);
c2=cos(2*pi*2*_n_/8766);
s3=sin(2*pi*3*_n_/8766);
c3=cos(2*pi*3*_n_/8766);
s4=sin(2*pi*4*_n_/8766);
c4=cos(2*pi*4*_n_/8766);
s5=sin(2*pi*1*_n_/168);
c5=cos(2*pi*1*_n_/168);
s6=sin(2*pi*2*_n_/168);
c6=cos(2*pi*2*_n_/168);
s7=sin(2*pi*3*_n_/168);
c7=cos(2*pi*3*_n_/168);
s8=sin(2*pi*4*_n_/168);
c8=cos(2*pi*4*_n_/168);
run;

proc arima data=well_imp plot=all;
identify var=avg_corrected_well_height(24) crosscorr=(s1 c1 s2 c2 s3 c3 s4 c4 s5 c5 s6 c6 s7 c7 s8 c8);
estimate input=(s1 c1 s2 c2 s3 c3 s4 c4 s5 c5 s6 c6 s7 c7 s8 c8);
forecast back=168 lead=168;
run;
quit;
