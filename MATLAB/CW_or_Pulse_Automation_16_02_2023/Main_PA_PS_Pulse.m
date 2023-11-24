clc
clear
Pin_start=-35; Pin_stop=-14;
trace1='CALC1:DATA:TRAC? "Trc1", FDAT';
trace3='CALC1:DATA:TRAC? "Trc3", FDAT';
trace4='CALC1:DATA:TRAC? "Trc4", FDAT';
trace5='CALC1:DATA:TRAC? "Trc5", FDAT';
trace6='CALC1:DATA:TRAC? "Trc6", FDAT';
DE=fun_VNA_trace_read(trace1);
AMAM=fun_VNA_trace_read(trace3);     AMAM_avg=movmean(AMAM,1);
AMPM=fun_VNA_trace_read(trace4);     AMPM_avg=movmean(AMPM,1);
%PDC=fun_VNA_trace_read(trace5);
Pout=fun_VNA_trace_read(trace6);
Nd=length(AMAM);

Step=(Pin_stop-Pin_start)/(Nd-1);
Pin=Pin_start:Step:Pin_stop; Pin=Pin';
% Pout=Pin+AMAM+29.2;
figure(1)
plot(Pout,AMAM_avg,'r-');
title('AMAM');
grid on
figure(2)
plot(Pout,AMPM_avg,'b-');
title('AMPM');
grid on
figure(3)
plot(Pout,DE*100,'r-');
title('DE');
grid on
save('Linear_DPA_Pulse_6_0GHz.mat')