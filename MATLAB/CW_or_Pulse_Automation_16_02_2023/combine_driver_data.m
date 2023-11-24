clc
clear all
close all
% frequency settings of PA                      
f_start =24e9;
f_stop =30e9;
f_step =0.5e9;

% desired characterization power range (in dBm) at the output of the PA
p_min = -36;
p_max = -9;
p_step = 1;
p_epsilon = 0.1; % error tolerance
f_points = 1+(f_stop-f_start)/f_step;
p_points = 1+(p_max-p_min)/p_step;
Gain_driver=zeros(p_points:f_points);
phase_driver=zeros(p_points:f_points);
Pout_driver=zeros(p_points:f_points);
pin=-36:1:-9;
for freq=f_start:f_step:f_stop
    f_idx = 1+(freq-f_start)/f_step;
 if f_idx==1
 load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\MMwave_SBP_24GHz_CW.mat');
 elseif f_idx ==2
 load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\MMwave_SBP_24_5GHz_CW.mat')
 elseif f_idx==3
     load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\MMwave_SBP_25GHz_CW.mat')
 elseif f_idx==4
     load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\MMwave_SBP_25_5GHz_CW.mat')
 elseif f_idx==5
     load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\MMwave_SBP_26GHz_CW.mat')
 elseif f_idx==6
     load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\MMwave_SBP_26_5GHz_CW.mat')
 elseif f_idx==7
     load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\MMwave_SBP_27GHz_CW.mat')
 elseif f_idx==8
     load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\MMwave_SBP_27_5GHz_CW.mat')
 elseif f_idx==9
     load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\MMwave_SBP_28GHz_CW.mat')
 elseif f_idx==10
     load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\MMwave_SBP_28_5GHz_CW.mat')
 elseif f_idx==11
     load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\MMwave_SBP_29GHz_CW.mat')
 elseif f_idx==12
     load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\MMwave_SBP_29_5GHz_CW.mat')
 elseif f_idx==13
     load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\MMwave_SBP_30GHz_CW.mat')
 end
 Gain_driver(:,f_idx)=Gain_Driver;
 Pout_driver(:,f_idx)=Pout_VNA;
 phase_driver(:,f_idx)=Phase_Driver;
end
    
%  save('Driver_24G_30G_SBP_mmwave_2','Gain_driver','pin','Pout_driver','phase_driver');