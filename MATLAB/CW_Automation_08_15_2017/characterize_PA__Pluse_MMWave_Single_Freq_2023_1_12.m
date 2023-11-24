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

SMWAdd='TCPIP::192.168.1.105::INSTR';   % set the address of signal generator
%
DP821A_IP='TCPIP0::192.168.1.105::INSTR';        % set the address of voltage source
FSWIP         = '192.168.1.104';                     % set the address of spectrum analyzer
Lan_addr='192.168.1.102';                                 
VNA_addr='TCPIP0::192.168.1.107::hislip0::INSTR';

triggerLev=1e-5;
RefLev     = 10;
% frequency settings
%   
freq=24e9;
% f_start =23e9;
% f_stop =27e9;
f_step =0.5e9;

% desired characterization power range (in dBm) at the output of the driver
p_min = -30;
p_max = -9;
p_step = 1;
p_epsilon = 0.1; % error tolerance

DP932U_IP='192.168.1.105';
chan=2;

mark=[];
mark_dc=[];
mark_i=[];
Pin=[];                                                     
Pout=[];
Gain=[];
DE=[];
Performan_PA=[];
% 
%% Load driver data
S21=[]; mea_Pout=[];
load('Driver_MMWave_PA_data_Pulse2023-01-12-17-33.mat')
f_start_D =20e9;
f_stop_D =30e9;
%
p_min_D = -30;
p_max_D = -9;
%
% f1=(f_start-f_start_D)/f_step+1; f2=(f_stop-f_start_D)/f_step+1;
f1=(freq-f_start_D)/f_step+1;
p1=(p_min-p_min_D)/p_step+1;   p2=(p_max-p_min_D)/p_step+1;
%
Pout_Driver=mea_Pout(p1:p2,f1);
S21_Driver=S21(p1:p2,f1);
%
S21=[]; mea_Pout=[];
%
%     fun_N6705_Voltage_Set(Lan_addr,2.02,1);
%     fun_N6705_Voltage_Set(Lan_addr,VgA,2);
%     fun_N6705_Voltage_Set(Lan_addr,2.02,3);
fun_N6705_Voltage_Set(Lan_addr,3.7,4);
%SignalAnalyzer_FSW43_new(FSWIP,1e9,RefLev,0);
%PowerSensor_NRPZ86(3.7e9,0);
% f_points = 1+(f_stop-f_start)/f_step;
p_points = 1+(p_max-p_min)/p_step;

n=2;
%     f_idx = 1+(freq-f_start)/f_step;
    fprintf('Frequency is %g Hz \n', freq);
   
    %fprintf('Attenuation at %g Hz is %g dB\n', freq, Mea_Attenuator(freq));
    %PM.offset(0);
    Performan_PA(n-1,1)=freq;    
    for p_target=p_min:p_step:p_max
        p_idx = 1+(p_target-p_min)/p_step;
        Pin=Pout_Driver(p_idx)+Mea_Probe(freq);
      % Pin=p_target+32;    
      % SignalGenerator_SMW200A(SMWAdd,freq,p_target,1);
        p_in=p_target;
            
        %SignalGenerator_SMW200A(SMWAdd,freq,p_target,2);
        fun_VNA_freq_power_set(freq,p_target,VNA_addr,1);
        pause(0.5);
        p_out = fun_MATLAB_directSCPI_NRPZxx_Trace_my(freq,1e-3,1e-4,triggerLev);
        p_out_mean=p_out;
            fprintf('p_out is %2.4f ',p_out_mean);
           
            if p_idx < 5
                scale1 = 'CH1:SCALE 0.01';
                tri = 'TRIGGER:A:LEVEL:CH1 0.013';
            elseif (p_idx >= 5) && (p_idx < 15)
                scale1 = 'CH1:SCALE 0.02';
                tri = 'TRIGGER:A:LEVEL:CH1 0.02';    
            else
                scale1 = 'CH1:SCALE 0.05';
                tri = 'TRIGGER:A:LEVEL:CH1 0.05';
            end
             pause(0.5);
            I_m=fun_Main_TI_Osc(scale1,tri);
            %I_m = fun_DS2102A(p_idx);

           %[~,I_m] = fun_PowerSupply_N6705A_Lan(Lan_addr,chan);
           % DC=PowerSupply_DP821A(DP821A_IP);
           %DC= PowerSupply_DP932U(DP932U_IP);
          
%             I_m=DC(2);
%             V_m=DC(1);

            Pdc=28*(I_m-0.001);
            Pout(p_idx)=p_out_mean-Mea_Attenuator_MMWave_2023_1_11(freq);
            fprintf('SG power is %02.2f ', Pout(p_idx));
            Gain(p_idx)=Pout(p_idx)-Pin;
            P_DC=28*(I_m-0.001);
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
            S21(p_idx)=fun_VNA_S21_read(VNA_addr);
    end
            %SignalGenerator_SMW200A(SMWAdd,freq,p_target,3);
             fun_VNA_freq_power_set(freq,p_target,VNA_addr,0);
              scale1 = 'CH1:SCALE 0.01';
              tri = 'TRIGGER:A:LEVEL:CH1 0.013';
              I=fun_Main_TI_Osc(scale1,tri);
            n=n+33;
            pause(1);
        % create the data table
        %mea_P(f_idx)=mean(Atten);

 data_file_name = [ 'PA_data_MMwave_Pulse' datestr(now,'yyyy-mm-dd-HH-MM' )];
 save(data_file_name, 'Performan_PA','S21','freq'); 
% 一下code用于plot paper中的图

n=2;
Pout_real=[]; Gain_real=[]; P_DC=[]; Pin_real=[]; DE_real=[]; PAE_real=[];
%
for p_target=p_min:p_step:p_max
        Pin=Performan_PA(p_idx+n-1,1);
        p_idx = 1+(p_target-p_min)/p_step;
        Pout_real(p_idx,f_idx)=Performan_PA(p_idx+n-1,5);   
        Gain_real(p_idx,f_idx)=Performan_PA(p_idx+n-1,6);
        P_DC(p_idx,f_idx)=Performan_PA(p_idx+n-1,3);
        Pin_real(p_idx,f_idx)=Performan_PA(p_idx+n-1,1);
        DE_real(p_idx,f_idx)=Performan_PA(p_idx+n-1,7);
        PAE_real(p_idx,f_idx)= Performan_PA(p_idx+n-1,8); 
        Att_out(f_idx)=Mea_Attenuator_MMWave_2023_1_11(freq);
end
n=n+33;

N1=size(Pout_real);
% Pout_real=zeros(N1,N2); Gain=zeros(N1,N2);Att=zeros(1,N2);
% pin=p_min:p_step:p_max;
% for freq=f_start:f_step:f_stop 
%     i=(freq-f_start)/f_step+1;
%     Att(1,i)=Mea_Attenuator_MMWave(freq);
%     Pout_real(:,i)=  mea_Pout(:,i)-Mea_Attenuator_MMWave(freq);
%     Gain(:,i)=Pout_real(:,i)-pin;
% end
% 
% RFfreq=f_start:f_step:f_stop;
% figure(9)
% hold on
% plot(RFfreq,Gain_real(5,:));
% hold off


% figure(1)
% hold on
% plot(RFfreq,Pout_real(N1,:),'-ro');
% xlabel('Frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
% ylabel('Sat Pout (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');  
% hold off

% figure(2)
% hold on
% plot(RFfreq,max(PAE_real),'-ro');
% plot(RFfreq,max(DE_real),'-m*');
% h=legend('PAE','DE');
% set(h,'fontsize',14,'fontname','Times New Roman')
% xlabel('Frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
% ylabel('Efficiency (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');  
% hold off
% 
% figure(18)
% plot(RFfreq,Pout_real(21,:))
% data_file_name = [ 'driver_data' datestr(now,'yyyy-mm-dd-HH-MM' )];
% save(data_file_name, 'pin','mea_Pout','Gain');     

% 一下code用于plot paper中的图
Nx=7;
linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv');
figure(10)
hold on
    plot(Pout_real,Gain_real,linestyle1(1,:),'linewidth',2);
set(gcf,'color','w');
% axis([-20,0,0,30]);
% h=legend('23GHz','23.5GHz','24GHz','24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz');
% set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure(14)
hold on
    plot(Pout_real,DE_real,linestyle1(1,:),'linewidth',2);
set(gcf,'color','w');
axis([20,40,0,80]);
% h=legend('23GHz','23.5GHz','24GHz','24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz');
% set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('DE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on
%
%
figure(11)
hold on
    plot(Pout_real(:,i),PAE_real(:,i),linestyle1(i,:),'linewidth',2);
set(gcf,'color','w');
% axis([-20,0,0,30]);
% h=legend('23GHz','23.5GHz','24GHz','24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz');
% set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('PAE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

N1=length(S21);
Phase_S21_Nor=zeros(N1); Phase_S21=zeros(N1,N2);
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

figure(12)
hold on
for i=1:2:N2
    plot(Pout_real(:,i),Phase_S21_Nor_deg(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
 axis([15,35,-0,40]);
h=legend('23GHz','23.5GHz','24GHz','24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('AM PM (degree)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on


figure(13)
hold on
for i=1:2:N2
    plot(Pout_real(:,i),dB_S21_Nor(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
 axis([15,35,-5,5]);
h=legend('23GHz','23.5GHz','24GHz','24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('AM AM (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on