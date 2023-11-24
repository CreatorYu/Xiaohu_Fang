clc
clear
close all
% frequency settings of PA                      
f_start =27e9;
f_stop =27e9;
f_step =0.5e9;


%fun_VNA_freq_set(f_start);
load('Attenuation_Probe.mat');
Attenuator=A;
f_start_A =20e9;
f_stop_A =30e9;
f1=(f_start-f_start_A)/f_step+1; f2=(f_stop-f_start_A)/f_step+1;
Attenuator=Attenuator(f1:f2);

load('Driver_AMPM_Pout_27GHz_CW.mat');

Pin_start=-35; Pin_stop=-10;
trace1='CALC1:DATA:TRAC? "Trc1", FDAT';
trace2='CALC1:DATA:TRAC? "Trc2", FDAT';
trace3='CALC1:DATA:TRAC? "Trc3", FDAT';
trace4='CALC1:DATA:TRAC? "Trc4", FDAT';
trace5='CALC1:DATA:TRAC? "Trc5", FDAT';
trace6='CALC1:DATA:TRAC? "Trc6", FDAT';

Pout_PA_VNA=fun_VNA_trace_read(trace3);
Phase_PA_Driver=fun_VNA_trace_read(trace2);  
Gain_PA_Driver=fun_VNA_trace_read(trace1); 
PDC=fun_VNA_trace_read(trace5);
DE_VNA=fun_VNA_trace_read(trace4);
Nd=length(Pout_PA_VNA);

Pout=Pout_PA_VNA-Attenuator;  
% Step=(Pin_stop-Pin_start)/(Nd-1);
% Pin=Pin_start:Step:Pin_stop; Pin=Pin';
% % Pout=Pin+AMAM+29.2;
Gain_PA=Gain_PA_Driver+20-mean(Gain_total)-Attenuator; 
DE_real=10.^((Pout-30)./10)./PDC.*100;
Phase_PA=Phase_PA_Driver-phase_total(1:Nd);
PAE_real=(10.^((Pout-30)./10)-(10.^((Pout-30-Gain_PA)./10)))./PDC.*100;
Itot=PDC/28*1000;

figure()
plot(Pout,Gain_PA,'r-');
title('AMAM');
grid on
figure()
plot(Pout,Phase_PA,'b-');
title('AMPM');
grid on
figure()
plot(Pout,DE_real,'r-');
title('DE');
grid on
figure()
plot(Pout,PAE_real,'r-');
title('PAE');
grid on

 data_file_name = ('New_MMwave_Linear_DPA_27GHz_CW_2');
 save(data_file_name, 'Gain_PA','DE_real','Phase_PA','Pout','PAE_real','PDC','Phase_PA_Driver','Itot');

 Ia=Itot;
 load('New_MMwave_Linear_DPA_27GHz_CW.mat');
 Im=Itot-Ia;
 figure()
 hold on
 plot(Pout,Im,'r-');
 plot(Pout,Ia,'r-');
 title('DC Current');
 grid on
 hold off
% 
%  IT=Itot;
%  load('New_MMwave_Linear_DPA_27GHz_CW_2.mat');
%  Ia=Itot;
%  Im=IT-Ia;
%  figure()
%  hold on
%  plot(Pout,Im,'r-');
%  plot(Pout,Ia,'r-');
%  title('DC Current');
%  grid on
%  hold off

 data_file_name = ('New_MMwave_Linear_DPA_27GHz_CW');
 save(data_file_name, 'Gain_PA','DE_real','Phase_PA','Pout','PAE_real','PDC','Phase_PA_Driver','Itot','Im','Ia');
% MMwave Linear DPA bias:
%24.5 GHz 1.95  3.65
%25.0 GHz 1.96  3.8
%25.5 GHz 1.95  3.8
%26.0 GHz 1.95  3.75
%26.5 GHz 1.93  3.8
%27.0 GHz 1.95  3.75
% end


