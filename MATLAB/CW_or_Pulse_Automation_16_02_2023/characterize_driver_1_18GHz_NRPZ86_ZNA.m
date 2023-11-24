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

SMWAdd='TCPIP::192.168.1.101::INSTR';   % set the address of signal generator
VNA_addr='TCPIP0::192.168.1.107::hislip0::INSTR';  % set the address of ZNA
%
%DP821A_IP='TCPIP0::192.168.1.106::INSTR';        % set the address of voltage source
FSWIP         = '192.168.1.38';                     % set the address of spectrum analyzer


RefLev     = 5;
% frequency settings 
f_start = 4.6e9;
f_stop =6.2e9;
f_step =0.1e9;

% desired characterization power range (in dBm) at the output of the SMW200A
p_min = -35;
p_max = -12;
p_step = 1;
p_epsilon = 0.1; % error tolerance

mark=[];
mea_Pout=[];
% Gain=[];

% preset the instruments
% SignalGenerator_SMW200A(SMWAdd,1e9,-45,0);
% SignalAnalyzer_FSW43(FSWIP,1e9,RefLev,0);

f_points = 1+(f_stop-f_start)/f_step;
p_points = 1+(p_max-p_min)/p_step;


for freq=f_start:f_step:f_stop
    f_idx = 1+(freq-f_start)/f_step;
    fprintf('Frequency is %g Hz (%d of %d)\n', freq, f_idx, f_points);
 
    %fprintf('Attenuation at %g Hz is %g dB\n', freq, Mea_Attenuator(freq));
    %PM.offset(0);
        
    for p_target=p_min:p_step:p_max
        p_idx = 1+(p_target-p_min)/p_step;
            %SignalGenerator_SMW200A(SMWAdd,freq,p_target,1);
            p_in=p_target;
            fprintf('SG power is %02.2f ', p_target);
            %SignalGenerator_SMW200A(SMWAdd,freq,p_target,2);
            fun_VNA_freq_power_set(freq,p_target,VNA_addr,1);
            pause(0.5);
            
         
         %  p_out = fun_MATLAB_directSCPI_NRPZxx_Trace_my(freq,1e-3,1e-4,5e-6);
            p_out =MATLAB_directSCPI_NRPZxx_Avg_Power_my(freq);
          
            p_out_mean=p_out;
            phase_S21=fun_VNA_S21_phase_read(VNA_addr);
            fprintf('p_out is %2.4f ',p_out_mean);
            fprintf('p_out is %2.4f ',phase_S21);
    

    %    mea_Pout(p_idx,f_idx)=p_out_mean-Mea_Attenuator_MMWave(freq);
    %    Gain(p_idx,f_idx)=p_out_mean-p_in-0.5-Mea_Attenuator_MMWave(freq);
         phase_S21_Driver(p_idx,f_idx)=phase_S21;
         mea_Pout(p_idx,f_idx)=p_out_mean;
    end
         %SignalGenerator_SMW200A(SMWAdd,freq,p_target,3);
         fun_VNA_freq_power_set(freq,p_target,VNA_addr,0);
        % create the data table
        %mea_P(f_idx)=mean(Atten);
       
end

[N1,N2]=size(mea_Pout);
Pout_real=zeros(N1,N2); Gain=zeros(N1,N2);Att=zeros(1,N2);
pin=p_min:p_step:p_max;
pin=pin';
for freq=f_start:f_step:f_stop
    i=(freq-f_start)/f_step+1;
    %Att(1,i)=Mea_Attenuator_2(freq);
    Pout_real(:,i)=  mea_Pout(:,i)-Mea_Attenuator_2(freq);
    Gain(:,i)=Pout_real(:,i)-pin;
end

RFfreq=f_start:f_step:f_stop;
plot(RFfreq,Gain(5,:))
plot(RFfreq,Pout_real(14,:))
data_file_name = [ 'driver_data_for_Doherty_4_6G_6_2G_' datestr(now,'yyyy-mm-dd-HH-MM' )];
save(data_file_name, 'pin','mea_Pout','Gain','Pout_real','phase_S21_Driver');     

% 一下code用于plot paper中的图
linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv','-bs','-ys','-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*','-r*');

figure(1)
hold on
for i=1:N2
    plot(Pout_real(:,i),Gain(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
axis([10,32,30,50]);
h=legend('4.6GHz','4.7GHz','4.8GHz','4.9GHz','5GHz','5.1GHz','5.2GHz','5.3GHz','5.4GHz','5.5GHz','5.6GHz','5.7GHz','5.8GHz','5.9GHz','6.0GHz');
% set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on


%
%
figure(2)
hold on
for i=1:N2
    for j=1:N1
    phase_S21_normalized(j,i)=phase_S21_Driver(j,i)-phase_S21_Driver(1,i);
    end
end

for i=1:N2
    plot(mea_Pout(:,i),Gain(:,i),linestyle1(i,:),'linewidth',2);
end
h=legend('4.6GHz','4.7GHz','4.8GHz','4.9GHz','5GHz','5.1GHz','5.2GHz','5.3GHz','5.4GHz','5.5GHz','5.6GHz','5.7GHz','5.8GHz','5.9GHz','6.0GHz');
set(h,'fontsize',14,'fontname','Times New Roman');
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on
