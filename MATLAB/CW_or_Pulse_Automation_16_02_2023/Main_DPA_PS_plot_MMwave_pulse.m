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

Pout_PA_VNA=fun_VNA_trace_read(trace1);
Phase_PA_Driver=fun_VNA_trace_read(trace3);  
Gain_PA_Driver=fun_VNA_trace_read(trace4); 
PDC=fun_VNA_trace_read(trace6);
DE_VNA=fun_VNA_trace_read(trace5);
Nd=length(Pout_PA_VNA);

Pout=Pout_PA_VNA-Attenuator;  
% Step=(Pin_stop-Pin_start)/(Nd-1);
% Pin=Pin_start:Step:Pin_stop; Pin=Pin';
% % Pout=Pin+AMAM+29.2;
Gain_PA=Gain_PA_Driver-mean(Gain_total)-Attenuator; 
DE_real=10.^((Pout-30)./10)./PDC.*100;
Phase_PA=Phase_PA_Driver(2:Nd)-phase_total(1:Nd-1);
PAE_real=(10.^((Pout-30)./10)-(10.^((Pout-30-Gain_PA)./10)))./PDC.*100;

figure()
plot(Pout,Gain_PA,'r-');
title('AMAM');
grid on
figure()
plot(Pout(2:Nd),Phase_PA,'b-');
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

 data_file_name = ('MMwave_Linear_DPA_27GHz_pulse');
 save(data_file_name, 'Gain_PA','DE_real','Phase_PA','Pout','PAE_real','PDC','Phase_PA_Driver');
% Linear DPA bias:
% if Fcarrier==4.85e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,3.5);%Idsm=24mA
%     elseif Fcarrier ==4.9e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,3.55);%Idsm=24mA
%     elseif Fcarrier ==5.0e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,3.55);%Idsm=24mA
%     elseif Fcarrier ==5.1e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,3.556); %Idsm=24mA    
%     elseif Fcarrier ==5.2e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,3.556); %Idsm=24mA
%     elseif Fcarrier ==5.3e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,3.556); %Idsm=24mA
%     elseif Fcarrier ==5.4e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,3.556); %Idsm=24mA
%     elseif Fcarrier ==5.5e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,3.65); %Idsm=24mA
%     elseif Fcarrier ==5.6e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,3.85); %Idsm=24mA
%     elseif Fcarrier ==5.7e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,4.05); %Idsm=24mA
%     elseif Fcarrier ==5.8e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,4.15); %Idsm=24mA
%     elseif Fcarrier ==5.9e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,4.25); %Idsm=24mA
%     else
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,4.35);%Idsm=24mA
% end


