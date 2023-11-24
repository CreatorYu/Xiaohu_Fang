clc
clear
close all
% frequency settings of PA 
%网分的设定：扫描时间1s，平均100次
f_start =30e9;
f_stop =30e9;
f_step =0.5e9;

Pin_start=-36; 
Pin_stop=-9;
Pin=Pin_start:1:Pin_stop;
trace1='CALC1:DATA:TRAC? "Trc1", FDAT';
trace2='CALC1:DATA:TRAC? "Trc2", FDAT';
trace3='CALC1:DATA:TRAC? "Trc3", FDAT';
trace4='CALC1:DATA:TRAC? "Trc4", FDAT';
trace5='CALC1:DATA:TRAC? "Trc5", FDAT';
trace6='CALC1:DATA:TRAC? "Trc6", FDAT';

Pout_VNA=fun_VNA_trace_read(trace3);
Phase_Driver=fun_VNA_trace_read(trace2);  
Gain_Driver=fun_VNA_trace_read(trace1); 



figure()
plot(Pout_VNA,Gain_Driver,'r-');
title('AMAM');
grid on
figure()
plot(Pout_VNA,Phase_Driver,'b-');
title('AMPM both');
grid on


 data_file_name = ('MMwave_SBP_30GHz_CW');
 save(data_file_name, 'Pin','Gain_Driver','Phase_Driver','Pout_VNA');


