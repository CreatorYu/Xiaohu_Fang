clc
clear
close all

path(pathdef); % Resets the paths to remove paths outside this folder
path('D:\Matlab\Xiaohu_Fang\MATLAB\CW_Automation_08_15_2017',path);
path('D:\Matlab\Xiaohu_Fang\MATLAB\IQ_imbalance_cal_results',path);
path('D:\Matlab\Xiaohu_Fang\EmRG_Code\TX_Calibration\Instrument_Functions\SignalCapture_UXA',path)
path('D:\Matlab\Xiaohu_Fang\MATLAB',path)
path('D:\Matlab\DPD_2022_09\RsMatlabToolkit_24',path);
path('D:\Matlab\DPD_2022_09\RsMatlabToolkit_24\Examples',path);
path('D:\Matlab\DPD_2022_09',path);
path('D:\Matlab\DPD_2022_09\MATLAB_directSCPI_Examples_5.0',path);
addpath(genpath(pwd))%Automatically Adds all paths in directory and subfolders
addpath(genpath('D:\Matlab\Xiaohu_Fang\MATLAB\Instrument_Functions'));

SMWAdd='TCPIP::192.168.1.100::INSTR';   % set the address of signal generator
%
DP821A_IP='TCPIP0::192.168.1.104::INSTR';        % set the address of voltage source
FSWIP         = '192.168.1.38';                     % set the address of spectrum analyzer
                                 
RefLev     = 15;
% frequency settings 
f_start = 6.4e9;
f_stop =6e9;
f_step =-0.2e9;

% desired characterization power range (in dBm) at the output of the driver
p_min = -30;
p_max = -15;
p_step = 1;
p_epsilon = 0.1; % error tolerance

mark=[];
mark_dc=[];
mark_i=[];
Pin=[];
Pout=[];
Gain=[];
DE=[];
Performan_PA=[];
% preset the instruments
SignalGenerator_SMW200A(SMWAdd,1e9,-45,0);
SignalAnalyzer_FSW43_new(FSWIP,1e9,RefLev,0);

f_points = 1+(f_stop-f_start)/f_step;
p_points = 1+(p_max-p_min)/p_step;

n=2;
for freq=f_start:f_step:f_stop
    f_idx = 1+(freq-f_start)/f_step;
    fprintf('Frequency is %g Hz (%d of %d)\n', freq, f_idx, f_points);
   
    %fprintf('Attenuation at %g Hz is %g dB\n', freq, Mea_Attenuator(freq));
    %PM.offset(0);
    Performan_PA(n-1,1)=freq;    
    for p_target=p_min:p_step:p_max
        p_idx = 1+(p_target-p_min)/p_step;
        Pin=Mea_driver(f_idx,p_idx);
            SignalGenerator_SMW200A(SMWAdd,freq,p_target,1);
            p_in=p_target;
            fprintf('SG power is %02.2f ', p_target);
            SignalGenerator_SMW200A(SMWAdd,freq,p_target,2);
            
            for i=1:3
            p_out = SignalAnalyzer_FSW43(FSWIP,freq,RefLev,1);
            Mea_DC=PowerSupply_DP821A(DP821A_IP);
            mark(i)=p_out;
            mark_dc(i)=Mea_DC(3)-0.02;
            mark_i(i)=Mea_DC(2)-0.0006;
            end
            
            p_out_mean=mean(mark);
            fprintf('p_out is %2.4f ',p_out_mean);
            
            I_m = mean(mark_i);
            Pdc=mean(mark_dc);
            Pout(p_idx)=p_out_mean-Mea_Attenuator(freq);
            Gain(p_idx)=p_out_mean-Pin-Mea_Attenuator(freq);
            P_DC=28*I_m;
            DE=100*10^((Pout(p_idx)-30)/10) / P_DC;
            PAE=100*(10^((Pout(p_idx)-30)/10)-10^((Pin-30)/10))/ P_DC;
            
            Performan_PA(p_idx+n-1,1)=Pin;
            Performan_PA(p_idx+n-1,2)=I_m;
            Performan_PA(p_idx+n-1,3)=Pdc;
            Performan_PA(p_idx+n-1,4)=p_out_mean;
            Performan_PA(p_idx+n-1,5)=Pout(p_idx);
            Performan_PA(p_idx+n-1,6)=Gain(p_idx);
            Performan_PA(p_idx+n-1,7)=DE;
            Performan_PA(p_idx+n-1,8)=PAE;
            
    end
            SignalGenerator_SMW200A(SMWAdd,freq,p_target,3);
            n=n+17;
        % create the data table
        %mea_P(f_idx)=mean(Atten);
       
    end
    
