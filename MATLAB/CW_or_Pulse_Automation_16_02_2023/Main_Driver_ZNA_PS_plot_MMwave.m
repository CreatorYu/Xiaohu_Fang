clc
clear

% frequency settings of PA                      
f_start =24.0e9;
f_stop =24.0e9;
f_step =0.5e9;


%fun_VNA_freq_set(f_start);
% desired characterization power range (in dBm) at the output of the PA
p_min = -35;
p_max = -16;
p_step = 1;
Pin=p_min:p_step:p_max;
Pin=Pin';
% p_epsilon = 0.1; % error tolerance
% load('A.mat')
% Attenuator=A(:,13);
% f_start_A =4.2e9;
% f_stop_A =6.8e9;
% f1=(f_start-f_start_A)/f_step+1; f2=(f_stop-f_start_A)/f_step+1;
% Attenuator=Attenuator(f1:f2);

% load('driver_data_for_Doherty_4_2G_6_8G_2023-04-13-16-38.mat')
% f_start_D =4.2e9;
% f_stop_D =6.8e9;
% %
% p_min_D = -35;
% p_max_D = -12;
% f1=(f_start-f_start_D)/f_step+1; f2=(f_stop-f_start_D)/f_step+1;
% p1=(p_min-p_min_D)/p_step+1;   p2=(p_max-p_min_D)/p_step+1;
% %
% Gain_Driver=Gain(p1:p2,f1:f2);

trace1='CALC1:DATA:TRAC? "Trc1", FDAT';
trace2='CALC1:DATA:TRAC? "Trc2", FDAT';
trace3='CALC1:DATA:TRAC? "Trc3", FDAT';
% trace4='CALC1:DATA:TRAC? "Trc4", FDAT';
% trace5='CALC1:DATA:TRAC? "Trc5", FDAT';

Gain_driver=fun_VNA_trace_read(trace1);
phase_driver=fun_VNA_trace_read(trace2);
Pout_driver=fun_VNA_trace_read(trace3);     
% Gain_total=fun_VNA_trace_read(trace4);
% phase_total=fun_VNA_trace_read(trace5);
% Nd=length(Pout_VNA);

plot(Pout_driver,Gain_driver,'r-');
title('AMAM');
grid on
figure(2)
plot(Pout_driver,phase_driver,'b-');
title('AMPM');
grid on

data_file_name = ('Driver_SBP_AMPM_for_single_PA_pulse_27_5G');
save(data_file_name,'Pin','Pout_driver','phase_driver','Gain_driver');
