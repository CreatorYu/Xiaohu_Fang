clc
clear
close all
% frequency settings of PA                      
f_start =26e9;
f_stop =26e9;
f_step =0.5e9;

Pin_start=-36; 
Pin_stop=-9;

%fun_VNA_freq_set(f_start);
load('Attenuation_Probe.mat');
Attenuator=A;
f_start_A =20e9;
f_stop_A =30e9;
f1=(f_start-f_start_A)/f_step+1; f2=(f_stop-f_start_A)/f_step+1;
Attenuator=Attenuator(f1:f2);

load('Driver_24G_30G_SBP_mmwave.mat');

phase_driver_array=fun_phase_array_SBP(f_start,Pin_start,Pin_stop);
trace1='CALC1:DATA:TRAC? "Trc1", FDAT';
trace2='CALC1:DATA:TRAC? "Trc2", FDAT';
trace3='CALC1:DATA:TRAC? "Trc3", FDAT';
trace4='CALC1:DATA:TRAC? "Trc4", FDAT';
trace5='CALC1:DATA:TRAC? "Trc5", FDAT';
trace6='CALC1:DATA:TRAC? "Trc6", FDAT';

Pout_PA_VNA=fun_VNA_trace_read(trace3);
Phase_PA_Driver=fun_VNA_trace_read(trace2);  
Gain_PA_Driver=fun_VNA_trace_read(trace1); 
Phase_PA=Phase_PA_Driver-phase_driver_array;
Pout=Pout_PA_VNA-Attenuator;  
Gain_PA=Gain_PA_Driver-37-Attenuator+20;
PDC=fun_VNA_trace_read(trace5);
Itot=PDC/28;



figure()
plot(Pout,Gain_PA,'r-');
title('AMAM');
grid on
figure()
plot(Pout,Phase_PA_Driver,'b-');
title('AMPM both');
grid on
figure()
plot(Pout,Phase_PA,'b-');
title('AMPM PA');
grid on


 data_file_name = ('MMwave_DPA_26GHz_CW_current');
 save(data_file_name, 'Gain_PA','Phase_PA_Driver','Phase_PA','Pout','PDC','Itot');


