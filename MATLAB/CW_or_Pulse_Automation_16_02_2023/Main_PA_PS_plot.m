clc
clear

% frequency settings of PA                      
f_start =4.5e9;
f_stop =4.5e9;
f_step =0.1e9;


fun_VNA_freq_set(f_start);
% desired characterization power range (in dBm) at the output of the PA
p_min = -35;
p_max = -14;
p_step = 1;
p_epsilon = 0.1; % error tolerance
load('A.mat')
Attenuator=A(:,13);
f_start_A =4.2e9;
f_stop_A =6.8e9;
f1=(f_start-f_start_A)/f_step+1; f2=(f_stop-f_start_A)/f_step+1;
Attenuator=Attenuator(f1:f2);

load('driver_data_for_Doherty_4_2G_6_8G_2023-04-13-16-38.mat')
f_start_D =4.2e9;
f_stop_D =6.8e9;
%
p_min_D = -35;
p_max_D = -12;
f1=(f_start-f_start_D)/f_step+1; f2=(f_stop-f_start_D)/f_step+1;
p1=(p_min-p_min_D)/p_step+1;   p2=(p_max-p_min_D)/p_step+1;
%
Gain_Driver=Gain(p1:p2,f1:f2);

Pin_start=-36; Pin_stop=-14;
trace1='CALC1:DATA:TRAC? "Trc1", FDAT';
trace3='CALC1:DATA:TRAC? "Trc3", FDAT';
trace4='CALC1:DATA:TRAC? "Trc4", FDAT';
trace7='CALC1:DATA:TRAC? "Trc7", FDAT';
trace6='CALC1:DATA:TRAC? "Trc6", FDAT';
DE_VNA=fun_VNA_trace_read(trace1);
AMAM=fun_VNA_trace_read(trace3);     AMAM_avg=movmean(AMAM,5);
AMPM=fun_VNA_trace_read(trace4);     AMPM_avg=movmean(AMPM,5);
PDC=fun_VNA_trace_read(trace7);
Pout_VNA=fun_VNA_trace_read(trace6);
Nd=length(AMAM);

Pout=Pout_VNA(2:Nd)+Attenuator;  
Step=(Pin_stop-Pin_start)/(Nd-1);
Pin=Pin_start:Step:Pin_stop; Pin=Pin';
% Pout=Pin+AMAM+29.2;
Gain_PA=AMAM(2:Nd)-mean(Gain_Driver);
Gain_PA_ave=movmean(Gain_PA,1);
DE_real=10.^((Pout-30)./10)./PDC(2:Nd).*100;
figure(1)
plot(Pout,Gain_PA,'r-');
title('AMAM');
grid on
figure(2)
plot(Pout,AMPM_avg(2:Nd),'b-');
title('AMPM');
grid on
figure(3)
plot(Pout,DE_real,'r-');
title('DE');
grid on

data_file_name = [ 'Wideband_DPA_4_5GHz_CW_' datestr(now,'yyyy-mm-dd-HH-MM' )];
save(data_file_name, 'DE_VNA','AMAM','AMPM','AMPM_avg','PDC','Pout','Gain_PA','DE_real');
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

% Wideband DPA bias:
% if Fcarrier==4.4e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,4.4);%Idsm=19.4mA
%     elseif Fcarrier ==4.6e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,4.4);%Idsm=19.4mA
%     elseif Fcarrier ==4.8e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,4.4);%Idsm=19.4mA
%     elseif Fcarrier ==5.0e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,4.5); %Idsm=19.4mA    
%     elseif Fcarrier ==5.2e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,4.5); %Idsm=19.6mA
%     elseif Fcarrier ==5.4e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,4.6); %Idsm=19.7mA
%     elseif Fcarrier ==5.6e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,4.7); %Idsm=19.7mA
%     elseif Fcarrier ==5.8e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,4.8); %Idsm=19.7mA
%     elseif Fcarrier ==6.0e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,5.1); %Idsm=19.7mA
%     elseif Fcarrier ==6.2e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,5.3); %Idsm=19.7mA
%     elseif Fcarrier ==6.4e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,5.3); %Idsm=19.7mA
%     elseif Fcarrier ==6.6e9
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,5.3); %Idsm=19.7mA
%     else
%         fun_PowerSetting_HMP2030(HMP2030_IP,HMP_channel,5.3);%Idsm=19.7mA
% end
