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
%
%DP821A_IP='TCPIP0::192.168.1.106::INSTR';        % set the address of voltage source
FSWIP         = '192.168.1.38';                     % set the address of spectrum analyzer
                                 
RefLev     = 5;
% frequency settings 
f_start = 0.5e9;
f_stop =4.0e9;
f_step =0.1e9;

% desired characterization power range (in dBm) at the output of the SMW200A
p_min = -35;
p_max = -10;
p_step = 1;
p_epsilon = 0.1; % error tolerance


%Setting Attenuation
load('Attenuator_data_0_5G_4_0G_2023-05-01-17-07.mat');
f_start_A =0.5e9;
f_stop_A =4.0e9;
f1=(f_start-f_start_A)/f_step+1; f2=(f_stop-f_start_A)/f_step+1;
Attenuation=Atten_all(f1:f2);
%
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
            SignalGenerator_SMW200A(SMWAdd,freq,p_target,1);
            p_in=p_target;
            fprintf('SG power is %02.2f ', p_target);
            SignalGenerator_SMW200A(SMWAdd,freq,p_target,2);
            pause(1);
            
         
         %  p_out = fun_MATLAB_directSCPI_NRPZxx_Trace_my(freq,1e-3,1e-4,5e-6);
            p_out =MATLAB_directSCPI_NRPZxx_Avg_Power_my(freq);
          
            p_out_mean=p_out;
            fprintf('p_out is %2.4f ',p_out_mean);
    

    %    mea_Pout(p_idx,f_idx)=p_out_mean-Mea_Attenuator_MMWave(freq);
    %    Gain(p_idx,f_idx)=p_out_mean-p_in-0.5-Mea_Attenuator_MMWave(freq);
         mea_Pout(p_idx,f_idx)=p_out_mean;
    end
         SignalGenerator_SMW200A(SMWAdd,freq,p_target,3);
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
    Pout_real(:,i)=  mea_Pout(:,i)-Attenuation(i);
    Gain(:,i)=Pout_real(:,i)-pin;
end

RFfreq=f_start:f_step:f_stop;
plot(RFfreq,Gain(5,:))
plot(RFfreq,Pout_real(14,:))
% data_file_name = [ 'driver_data_for_SLCG_0_5G_4_0G_' datestr(now,'yyyy-mm-dd-HH-MM' )];
% save(data_file_name, 'pin','mea_Pout','Gain','Pout_real');     

% 一下code用于plot paper中的图
linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv','-bs','-ys','-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*','-r*');
%
figure(1)
hold on
plot(RFfreq,Gain(1,:),'-ro');
set(gcf,'color','w');
% h=legend('1.0GHz','1.2GHz','1.4GHz','1.6GHz','1.8GHz','2.0GHz');
% set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');   
hold off

figure(2)
hold on
plot(RFfreq,max(Pout_real),'-ro');
% plot(RFfreq,Pout_1dB,'-bv')
set(gcf,'color','w');
h=legend('Saturation','1dB Compression');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Pout (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');   
hold off

figure()
hold on
for i=2:2:N2
    plot(pin,Gain(:,i),linestyle1(i/2,:),'linewidth',2);
end
set(gcf,'color','w');
axis([-35,-10,46,52]);
h=legend('4.6GHz','4.7GHz','4.8GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz','30GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Input Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on
%

figure(2)
hold on
for i=1:N2
    plot(Pout_real(:,i),Gain(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
axis([10,37,30,50]);
h=legend('24GHz','24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz','30GHz');
% set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on


%
%
figure(3)
hold on
for i=1:N2
    plot(mea_Pout(:,i),Gain(:,i),linestyle1(i,:),'linewidth',2);
end
h=legend('24GHz','24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz','30GHz');
set(h,'fontsize',14,'fontname','Times New Roman');
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on
