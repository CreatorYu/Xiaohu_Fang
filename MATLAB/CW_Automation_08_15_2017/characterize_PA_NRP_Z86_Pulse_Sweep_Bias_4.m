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
 Lan_addr='192.168.1.103';                                

RefLev     = 15;
% frequency settings 
f_start =24e9;
f_stop =24.5e9;
f_step =0.5e9;

% desired characterization power range (in dBm) at the output of the driver
p_min = -24;
p_max = -10;
p_step = 2;
p_epsilon = 0.1; % error tolerance

Vgm_min = 2.3;
Vgm_max = 2.4;
Vgm_step =0.05;

trigLev=1e-5;

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
Vgm_points = int8(1+(Vgm_max-Vgm_min)/Vgm_step);
%    fun_N6705_Voltage_Set(Lan_addr,2.5,2);
%     fun_N6705_Voltage_Set(Lan_addr,2.5,4);
    fun_N6705_Voltage_Set(Lan_addr,2.02,3);
    fun_N6705_Voltage_Set(Lan_addr,2.02,1);

data(1:f_points,1:Vgm_points) = struct( 'frequency', 0,'Vgm', 1e-6, 'table', zeros(p_points,10));

for Vgm=Vgm_min:Vgm_step:Vgm_max
    Vgm_idx = int8(1+(Vgm-Vgm_min)/Vgm_step);
    fun_N6705_Voltage_Set(Lan_addr,Vgm,2);
    fun_N6705_Voltage_Set(Lan_addr,Vgm,4);
    
for freq=f_start:f_step:f_stop
    f_idx = 1+(freq-f_start)/f_step;
    fprintf('Frequency is %g Hz (%d of %d)\n', freq, f_idx, f_points);
   
    %fprintf('Attenuation at %g Hz is %g dB\n', freq, Mea_Attenuator(freq));
    %PM.offset(0);
       data(f_idx,Vgm_idx).frequency = freq;  
       data(f_idx,Vgm_idx).Vgm = Vgm;  

    for p_target=p_min:p_step:p_max
        p_idx = 1+(p_target-p_min)/p_step;
        p_sg= p_target;
  %        Pin=Mea_driver_MMWave(f_start,f_stop,f_idx,p_idx)+Mea_Probe(freq);
            
  Pin=p_target+32;
            SignalGenerator_SMW200A(SMWAdd,freq,p_target,1);
            p_in=p_target;
            
            SignalGenerator_SMW200A(SMWAdd,freq,p_target,2);
            
            
            p_out = fun_MATLAB_directSCPI_NRPZxx_Trace_my(freq,1e-3,1e-4,trigLev);
            
            p_out_mean=p_out;
            fprintf('p_out is %2.4f ',p_out_mean);
            pause(3);
            I_m = fun_DS2102A_Chan2(p_idx);
            Pdc=(I_m-0.0011)*28;
            Pout=p_out_mean-Mea_Attenuator_MMWave_2(freq);
            fprintf('SG power is %02.2f ', Pout);
             Gain=Pout-Pin;
             P_DC=28*(I_m-0.0011);
             DE=100*10^((Pout-30)/10) / P_DC;
             PAE=100*(10^((Pout-30)/10)-10^((Pin-30)/10))/ P_DC;
            
%             Performan_PA(p_idx+n-1,1)=Pin;
%             Performan_PA(p_idx+n-1,2)=I_m;
%             Performan_PA(p_idx+n-1,3)=Pdc;
%             Performan_PA(p_idx+n-1,4)=p_out_mean;
%             Performan_PA(p_idx+n-1,5)=Pout(p_idx);
%              Performan_PA(p_idx+n-1,6)=Gain(p_idx);
%              Performan_PA(p_idx+n-1,7)=DE;
%              Performan_PA(p_idx+n-1,8)=PAE;
        data(f_idx,Vgm_idx).table(p_idx,1) = p_sg;     % signal generator power level
        data(f_idx,Vgm_idx).table(p_idx,2) = Pin;  % PA_in (a.k.a Driver_out)
        data(f_idx,Vgm_idx).table(p_idx,3) = p_out_mean; % power meter out
        data(f_idx,Vgm_idx).table(p_idx,4) = Pout;       % PA_out
        data(f_idx,Vgm_idx).table(p_idx,5) = Gain;     % gain
        data(f_idx,Vgm_idx).table(p_idx,6) = I_m;      % main current
        data(f_idx,Vgm_idx).table(p_idx,7) = PAE;      % PAE
        data(f_idx,Vgm_idx).table(p_idx,8) = DE;      % drain efficiency   
            
    end
            SignalGenerator_SMW200A(SMWAdd,freq,p_target,3);
        %    pause(1);
        % create the data table
        %mea_P(f_idx)=mean(Atten);
       
end
end
data_file_name = [ 'PA_data_Pulse_Vgm_NDPA' datestr(now,'yyyy-mm-dd-HH-MM' )];
save(data_file_name, 'data');
% 一下code用于plot paper中的图

Pout_real=[];Gain_real=[];
for Vgm=Vgm_min:Vgm_step:Vgm_max
     Vgm_idx = int8(1+(Vgm-Vgm_min)/Vgm_step);
for freq=f_start:f_step:f_stop
    f_idx = 1+(freq-f_start)/f_step;
    for p_target=p_min:p_step:p_max
        p_idx = 1+(p_target-p_min)/p_step;
        Pin_real(p_idx,f_idx,Vgm_idx)=data(f_idx,Vgm_idx).table(p_idx,2);
        Pout_real(p_idx,f_idx,Vgm_idx)=data(f_idx,Vgm_idx).table(p_idx,4);   
        Gain_real(p_idx,f_idx,Vgm_idx)=data(f_idx,Vgm_idx).table(p_idx,5);
        Id_real(p_idx,f_idx,Vgm_idx)=data(f_idx,Vgm_idx).table(p_idx,6);
       PAE_real(p_idx,f_idx,Vgm_idx)=data(f_idx,Vgm_idx).table(p_idx,7);  
        DE_real(p_idx,f_idx,Vgm_idx)=data(f_idx,Vgm_idx).table(p_idx,8);  
    end
    Att_out(f_idx)=Mea_Attenuator_MMWave_2(freq);
end
end


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


[N1,N2,N3]=size(Pout_real);
figure(10)
hold on
for i=1:N3
    plot(Pout_real(:,1,i),Gain_real(:,1,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([30,40,10,20]);
h=legend('2.3V','2.4V','2.5V','2.6V','2.7V');
set(h,'fontsize',14,'fontname','Times New Roman')
title( '23.5GHz','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on



%
%
figure(11)
hold on
for i=1:N3
    plot(Pout_real(:,2,i),Gain_real(:,2,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([24,38,40,50]);
h=legend('2.3V','2.35V','2.4V','2.6V','2.7V');
set(h,'fontsize',14,'fontname','Times New Roman')
title('%s GHz','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:N3
    plot(Pout_real(:,1,i),PAE_real(:,1,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([30,40,10,20]);
h=legend('2.3V','2.4V','2.5V','2.6V','2.7V');
set(h,'fontsize',14,'fontname','Times New Roman')
title('24GHz','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('PAE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on


figure(13)
hold on
for i=1:N3
    plot(Pout_real(:,3,i),Gain_real(:,3,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([14,30,49,57]);
h=legend('2.3V','2.35V','2.4V','2.6V','2.7V');
set(h,'fontsize',14,'fontname','Times New Roman')
title('24.5GHz','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:N3
    plot(Pout_real(:,3,i),PAE_real(:,3,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([30,40,10,20]);
h=legend('2.3V','2.4V','2.5V','2.6V','2.7V');
set(h,'fontsize',14,'fontname','Times New Roman')
title('24.5GHz','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('PAE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on



figure()
hold on
for i=1:N3
    plot(Pout_real(:,3,i),Gain_real(:,3,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
axis([14,30,49,57]);
h=legend('1.87V','1.92V','1.97V','2.02V','2.12V');
set(h,'fontsize',14,'fontname','Times New Roman')
title('28GHz','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on




figure()
hold on
for i=1:N3
    plot(Pout_real(:,2,i),DE_real(:,2,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
axis([24,38,10,50]);
h=legend('2.3V','2.4V','2.5V','2.6V','2.7V');
set(h,'fontsize',14,'fontname','Times New Roman')
title('24GHz','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('DE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

% figure(13)
% hold on
% for i=1:N3
%     plot(Pout_real(:,2,i),Gain_real(:,2,i),linestyle1(i,:),'linewidth',2);
% end
% set(gcf,'color','w');
% % axis([30,40,10,20]);
% h=legend('1.87V','1.92V','1.97V','2.02V','2.12V');
% set(h,'fontsize',14,'fontname','Times New Roman')
% title('28GHz','fontsize',14,'fontname','Times New Roman');
% xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
% ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
% hold off    
% grid on