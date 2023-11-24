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

SMWAdd='TCPIP::192.168.1.101::INSTR';   % set the address of signal generator
%
DP821A_IP='TCPIP0::192.168.1.105::INSTR';        % set the address of voltage source
FSWIP         = '192.168.1.38';                     % set the address of spectrum analyzer
                                 

RefLev     = 15;
% frequency settings 
f_start =23.5e9;
f_stop =30e9;
f_step =0.5e9;

% desired characterization power range (in dBm) at the output of the driver
p_min = -20;
p_max = -7;
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

%SignalAnalyzer_FSW43_new(FSWIP,1e9,RefLev,0);
%PowerSensor_NRPZ86(3.7e9,0);
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
          Pin=Mea_driver_MMWave(f_start,f_stop,f_idx,p_idx)+Mea_Probe(freq);
  %          Pin=p_idx;
            SignalGenerator_SMW200A(SMWAdd,freq,p_target,1);
            p_in=p_target;
            
            SignalGenerator_SMW200A(SMWAdd,freq,p_target,2);
            
            
            p_out = fun_MATLAB_directSCPI_NRPZxx_Trace_my(freq,1e-3,1e-4,1e-4);
            
            p_out_mean=p_out;
            fprintf('p_out is %2.4f ',p_out_mean);
            pause(1);
            I_m = fun_DS2102A(p_idx);
            Pdc=(I_m-0.0011)*28;
            Pout(p_idx)=p_out_mean-Mea_Attenuator_MMWave_2(freq);
            fprintf('SG power is %02.2f ', Pout(p_idx));
             Gain(p_idx)=Pout(p_idx)-Pin;
             P_DC=28*(I_m-0.0011);
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
            n=n+30;
            pause(1);
        % create the data table
        %mea_P(f_idx)=mean(Atten);
       
    end
data_file_name = [ 'PA_data_Pulse' datestr(now,'yyyy-mm-dd-HH-MM' )];
save(data_file_name, 'Performan_PA'); 
% 一下code用于plot paper中的图

n=2;
Pout_real=[];
for freq=f_start:f_step:f_stop
    f_idx = 1+(freq-f_start)/f_step;
    for p_target=p_min:p_step:p_max
        p_idx = 1+(p_target-p_min)/p_step;
        Pout_real(p_idx,f_idx)=Performan_PA(p_idx+n-1,5);   
        Gain_real(p_idx,f_idx)=Performan_PA(p_idx+n-1,6);
        Pin_real(p_idx,f_idx)=Performan_PA(p_idx+n-1,1);
        DE_real(p_idx,f_idx)=Performan_PA(p_idx+n-1,7);
        PAE_real(p_idx,f_idx)=Performan_PA(p_idx+n-1,8);  
        Att_out(f_idx)=Mea_Attenuator_MMWave_2(freq);
    end
    n=n+30;
end

[N1,N2]=size(Pout_real);
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
% plot(RFfreq,Gain(5,:))
% plot(RFfreq,Pout_real(14,:))
% data_file_name = [ 'driver_data' datestr(now,'yyyy-mm-dd-HH-MM' )];
% save(data_file_name, 'pin','mea_Pout','Gain');     

% 一下code用于plot paper中的图
Nx=7;
linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<');


figure(10)
hold on
for i=1:N2
    plot(Pout_real(:,i),Gain_real(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
axis([30,40,10,20]);
h=legend('24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on



%
%
figure(11)
hold on
for i=1:N2
    plot(Pout_real(:,i),DE_real(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
axis([30,40,0,60]);
h=legend('24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('DE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on


figure(12)
hold on
for i=1:N2
    plot(Pout_real(:,i),PAE_real(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
axis([30,40,0,60]);
h=legend('24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('PAE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on
