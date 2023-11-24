clc
clear
close all
% frequency settings of PA                      
f_start =29e9;
f_stop =29e9;
f_step =0.5e9;


%fun_VNA_freq_set(f_start);
load('Attenuation_Probe.mat');
Attenuator=A;
f_start_A =20e9;
f_stop_A =30e9;
f1=(f_start-f_start_A)/f_step+1; f2=(f_stop-f_start_A)/f_step+1;
Attenuator=Attenuator(f1:f2);

% load('Driver_SBP_AMPM_for_single_PA_pulse_24_5G.mat')
load('Driver_AMPM_Pout_29GHz_CW.mat');
Pin_start=-35; Pin_stop=-10;
trace1='CALC1:DATA:TRAC? "Trc1", FDAT';
trace2='CALC1:DATA:TRAC? "Trc2", FDAT';
trace3='CALC1:DATA:TRAC? "Trc3", FDAT';
% trace4='CALC1:DATA:TRAC? "Trc4", FDAT';
% trace5='CALC1:DATA:TRAC? "Trc5", FDAT';
% trace6='CALC1:DATA:TRAC? "Trc6", FDAT';


Gain_PA_Driver=fun_VNA_trace_read(trace1);
Phase_PA_Driver=fun_VNA_trace_read(trace2); 
Pout_PA_VNA=fun_VNA_trace_read(trace3);  

% PDC=fun_VNA_trace_read(trace6);
% DE_VNA=fun_VNA_trace_read(trace5);
% Nd=length(Pout_PA_VNA);

Pout=Pout_PA_VNA-Attenuator;  
% Step=(Pin_stop-Pin_start)/(Nd-1);
% Pin=Pin_start:Step:Pin_stop; Pin=Pin';
% % Pout=Pin+AMAM+29.2;
Gain_PA=Gain_PA_Driver-mean(Gain_total)-Attenuator; 
% DE_real=10.^((Pout-30)./10)./PDC.*100;
% Phase_PA=Phase_PA_Driver-phase_total(1:Nd);
% PAE_real=(10.^((Pout-30)./10)-(10.^((Pout-30-Gain_PA)./10)))./PDC.*100;

figure()
plot(Pout,Gain_PA,'r-');
title('AMAM');
grid on
figure()
plot(Pout,Phase_PA_Driver,'b-');
title('AMPM');
grid on

 data_file_name = ('MMwave_single_PA_2_29GHz_pulse');
 save(data_file_name, 'Gain_PA','Pout','Phase_PA_Driver');



