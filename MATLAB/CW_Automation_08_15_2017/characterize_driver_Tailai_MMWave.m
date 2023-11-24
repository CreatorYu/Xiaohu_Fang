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

SMWAdd='TCPIP::192.168.1.102::INSTR';   % set the address of signal generator
%
%DP821A_IP='TCPIP0::192.168.1.106::INSTR';        % set the address of voltage source
FSWIP         = '192.168.1.104';                     % set the address of spectrum analyzer
VNA_addr='TCPIP0::192.168.1.107::hislip0::INSTR';                                      
RefLev     = 10;
% frequency settings 
f_start = 20e9;
f_stop =30e9;
f_step =.5e9;

% desired characterization power range (in dBm) at the output of the driver
p_min = -30;
p_max = -9;
p_step = 1;
p_epsilon = 0.1; % error tolerance

mark=[];
mea_Pout=[];
Gain=[];

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
         
           %p_out =  SignalAnalyzer_FSW43(FSWIP,freq,RefLev,1);
           %p_out =  MATLAB_directSCPI_NRPZxx_Avg_Power_my(freq);
            p_out = fun_MATLAB_directSCPI_NRPZxx_Trace_my(freq,1e-3,1e-4,1e-5);
          
            p_out_mean=p_out
            fprintf('p_out is %2.4f ',p_out_mean);
        S21(p_idx,f_idx)=fun_VNA_S21_read(VNA_addr);
        mea_Pout(p_idx,f_idx)=p_out_mean-Mea_Attenuator_MMWave_2023_1_11(freq);
        Gain(p_idx,f_idx)=p_out_mean-p_in-Mea_Attenuator_MMWave_2023_1_11(freq);
    end
          %  SignalGenerator_SMW200A(SMWAdd,freq,p_target,3);
          fun_VNA_freq_power_set(freq,p_target,VNA_addr,0);  
        % create the data table
        %mea_P(f_idx)=mean(Atten);
         pause(0.5);
end

data_file_name = [ 'Driver_MMWave_PA_data_Pulse' datestr(now,'yyyy-mm-dd-HH-MM' )];
save(data_file_name, 'Gain','mea_Pout','S21');
[N1,N2]=size(mea_Pout);
RFfreq=(f_start:f_step:f_stop)/1e9;
figure()
hold on 
plot(RFfreq,Gain(5,:));
xlabel('Freq (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off
%
figure()
hold on
plot(RFfreq,mea_Pout(N1,:));
xlabel('Freq (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Pout (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off

linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv','-bs','-ys','-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*','-r*', '-m^', '-cv','-bs','-ys','-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*','-r*');
%
figure()
hold on
for i=1:2:N2
    plot(mea_Pout(:,i),Gain(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
axis([15,30,30,50]);
h=legend('20GHz','21GHz','22GHz','23GHz','24GHz','25GHz','26GHz','27GHz','28GHz','29GHz','30GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on
%
%
[N1,N2]=size(S21);
Phase_S21_Nor=zeros(N1,N2); Phase_S21=zeros(N1,N2);
Mag_S21_Nor=zeros(N1,N2); Mag_S21=zeros(N1,N2);
dB_S21_Nor=zeros(N1,N2); dB_S21=zeros(N1,N2);
for i=1:N2
    Phase_S21(:,i)=phase(S21(:,i));
    Phase_S21_Nor(:,i)=Phase_S21(:,i)-Phase_S21(1,i);
    Mag_S21(:,i)=abs(S21(:,i));
    Mag_S21_Nor(:,i)=Mag_S21(:,i)/Mag_S21(1,i);
    dB_S21_Nor(:,i)=20*log10(Mag_S21_Nor(:,i));
end
Phase_S21_Nor_deg=Phase_S21_Nor/pi*180;

figure()
hold on
for i=1:2:N2
    plot(mea_Pout(:,i),Phase_S21_Nor_deg(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
 axis([15,30,-0,40]);
h=legend('20GHz','21GHz','22GHz','23GHz','24GHz','25GHz','26GHz','27GHz','28GHz','29GHz','30GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('AM PM (degree)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on


figure()
hold on
for i=1:2:N2
    plot(mea_Pout(:,i),dB_S21_Nor(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
 axis([15,30,-5,5]);
h=legend('20GHz','21GHz','22GHz','23GHz','24GHz','25GHz','26GHz','27GHz','28GHz','29GHz','30GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('AM AM (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

