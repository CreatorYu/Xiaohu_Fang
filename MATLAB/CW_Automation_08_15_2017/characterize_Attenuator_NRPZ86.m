clc
clear
close all

path(pathdef); % Resets the paths to remove paths outside this folder
path('D:\Matlab\Xiaohu_Fang\MATLAB\CW_Automation_08_15_2017',path);
path('D:\Matlab\Xiaohu_Fang\EmRG_Code\TX_Calibration\Instrument_Functions\SignalCapture_UXA',path)
path('D:\Matlab\Xiaohu_Fang\MATLAB',path)
path('D:\Matlab\DPD_2022_09\RsMatlabToolkit_24',path);
path('D:\Matlab\DPD_2022_09\RsMatlabToolkit_24\Examples',path);
path('D:\Matlab\DPD_2022_09',path);
path('D:\Matlab\DPD_2022_09\MATLAB_directSCPI_Examples_5.0',path);
path('D:\Matlab\DPD_2022_09\MATLAB_ICT_rsnrpz_Examples',path);
addpath(genpath(pwd))%Automatically Adds all paths in directory and subfolders
addpath(genpath('D:\Matlab\Xiaohu_Fang\MATLAB\Instrument_Functions'));

SMWAdd='TCPIP::192.168.1.106::INSTR';   % set the address of signal generator
%
%DP821A_IP='TCPIP0::192.168.1.106::INSTR';        % set the address of voltage source
FSWIP         = '192.168.1.38';                     % set the address of spectrum analyzer
%VNA_addr='TCPIP0::192.168.1.107::hislip0::INSTR';                                 
RefLev     = -5;
triggerLev=1e-5;
% frequency settings 
f_start = 4.8e9;
f_stop =6e9;
f_step =.1e9;

% desired characterization power range (in dBm) at the output of the driver
p_min = -5;
p_max = 0;
p_step = 5;
p_epsilon = 0.1; % error tolerance

mark=[];
Atten_all=[];
Atten=[];
mea_A=[];
pout=[];
% preset the instruments
%SignalGenerator_SMW200A(SMWAdd,1e9,-45,0);
%SignalAnalyzer_FSW43(FSWIP,1e9,RefLev,0);

f_points = 1+(f_stop-f_start)/f_step;
p_points = 1+(p_max-p_min)/p_step;


for freq=f_start:f_step:f_stop
    f_idx = 1+(freq-f_start)/f_step;
    fprintf('Frequency is %g Hz (%d of %d)\n', freq, f_idx, f_points);
 
    %fprintf('Attenuation at %g Hz is %g dB\n', freq, Mea_Attenuator(freq));
    %PM.offset(0);
     %PowerSensor_NRPZ86(freq,0);   
    for p_target=p_min:p_step:p_max
        p_idx = 1+(p_target-p_min)/p_step;
            SignalGenerator_SMW200A(SMWAdd,freq,p_target,1);
            p_in=p_target;
            fprintf('SG power is %02.2f ', p_target);
            SignalGenerator_SMW200A(SMWAdd,freq,p_target,2);
            %fun_VNA_freq_power_set(freq,p_target,VNA_addr,1);  
           % p_out =fun_MATLAB_directSCPI_NRPZxx_Trace_my(freq,1e-4,1e-5,triggerLev);
            p_out = MATLAB_directSCPI_NRPZxx_Avg_Power_my(freq);
            pause(0.5);
            p_out_mean=p_out;
            fprintf('p_out is %2.4f ',p_out_mean);
    

        Atten(p_idx) = p_out_mean-p_in;
        Atten_all(f_idx,p_idx)=p_out_mean-p_in;
        pout(f_idx,p_idx)=p_out_mean;
    end
         % fun_VNA_freq_power_set(freq,p_target,VNA_addr,0);
     SignalGenerator_SMW200A(SMWAdd,freq,p_target,3);
        % create the data table
        mea_A(f_idx)=mean(Atten);              
    end
    
