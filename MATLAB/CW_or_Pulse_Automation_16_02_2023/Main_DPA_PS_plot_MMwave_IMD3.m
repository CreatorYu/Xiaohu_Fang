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


Pin_start=-36; Pin_stop=-9;
trace1='CALC1:DATA:TRAC? "Trc1", FDAT';
trace2='CALC1:DATA:TRAC? "Trc2", FDAT';
trace3='CALC1:DATA:TRAC? "Trc3", FDAT';
trace4='CALC1:DATA:TRAC? "Trc4", FDAT';
trace5='CALC1:DATA:TRAC? "Trc5", FDAT';
trace6='CALC1:DATA:TRAC? "Trc6", FDAT';

IMD3_lower=fun_VNA_trace_read(trace1);
IMD3_upper=fun_VNA_trace_read(trace2);  
Pout_LTO=fun_VNA_trace_read(trace3); 
Pout_UTO=fun_VNA_trace_read(trace4); 
% PDC=fun_VNA_trace_read(trace6);
% DE_VNA=fun_VNA_trace_read(trace5);
% Nd=length(Pout_PA_VNA);

Pout_LTO=Pout_LTO-Attenuator; 
Pout_UTO=Pout_UTO-Attenuator; 
% Step=(Pin_stop-Pin_start)/(Nd-1);
% Pin=Pin_start:Step:Pin_stop; Pin=Pin';
% % Pout=Pin+AMAM+29.2;
% Gain_PA=Gain_PA_Driver-mean(Gain_total)-Attenuator+20; 
% DE_real=10.^((Pout-30)./10)./PDC.*100;
% Phase_PA=Phase_PA_Driver-phase_total(1:Nd);
% PAE_real=(10.^((Pout-30)./10)-(10.^((Pout-30-Gain_PA)./10)))./PDC.*100;

figure()
plot(Pout_LTO,IMD3_lower,'r-');
title('IMD3 lower');
grid on
figure()
plot(Pout_UTO,IMD3_upper,'b-');
title('IMD3 upper');
grid on
% figure()
% plot(Pout,DE_real,'r-');
% title('DE');
% grid on
% figure()
% plot(Pout,PAE_real,'r-');
% title('PAE');
% grid on

 data_file_name = ('MMwave_DPA_27GHz_40M_IMD3');
 save(data_file_name, 'IMD3_lower','IMD3_upper','Pout_LTO','Pout_UTO');


