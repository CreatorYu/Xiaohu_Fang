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

% single-ended or doherty amplifier measurement
is_doherty = 1;

%Device Adress
SMWAdd='TCPIP::192.168.1.101::INSTR';   % set the address of signal generator
DP821A_IP='TCPIP0::192.168.1.105::INSTR';        % set the address of voltage source
FSWIP         = '192.168.1.105';                     % set the address of spectrum analyzer
Lan_addr='192.168.1.106';                                 
VNA_addr='TCPIP0::192.168.1.107::hislip0::INSTR';
DP932U_IP='192.168.1.105';
HMP2030_IP='TCPIP::192.168.1.102::5025::SOCKET';

%Device Parameters Setting 
triggerLev=1e-5;
RefLev     = 10;
chan=2;
BW=100e6;

% frequency settings                       
f_start =30.5e9;
f_stop =30.5e9;
f_step =0.5e9;

% desired characterization power range (in dBm) at the output of the driver
Pout_driver_max=22;
p_min = -35;
p_max = 0;
p_step = 1;
p_epsilon = 0.1; % error tolerance

% create the driver 

% load('driver_data_SBP_23_31G_2023-08-28-11-38.mat');
% f_start_D =23e9;
% f_stop_D =31e9;
% %
% p_min_D = -30;
% p_max_D = -8;
% f1=(f_start-f_start_D)/f_step+1; f2=(f_stop-f_start_D)/f_step+1;
% p1=(p_min-p_min_D)/p_step+1;   p2=(p_max-p_min_D)/p_step+1;
% %
% Pout_Driver=Pout_real(p1:p2,f1:f2);

% create the output coupler/attenuator
%ATN=Attenuator('Attenuator_Coupler_4_8GHz_2.s2p');
% ATN=Attenuator('Attenuator_WilkAeroflex_33dB_Oct31.s2p');

% preset the instruments
%SignalAnalyzer_FSW43_new(FSWIP,1e9,RefLev,0);
%PowerSensor_NRPZ86(3.7e9,0);
f_points = 1+(f_stop-f_start)/f_step;
p_points = 1+(p_max-p_min)/p_step;

% pre-allocate memory for the data
data(1:f_points) = struct( 'frequency', 0, 'table', zeros(p_points,10));

for freq=f_start:f_step:f_stop
    f_idx = 1+(freq-f_start)/f_step;
    fprintf('Frequency is %g Hz (%d of %d)\n', freq, f_idx, f_points);
   
    %fprintf('Attenuation at %g Hz is %g dB\n', freq, Mea_Attenuator(freq));
    %PM.offset(0);
     data(f_idx).frequency = freq; 
     Pin_driver_max=fun_SBP_Driver_out2in(Pout_driver_max,freq); 
     p_sg_min=p_min+Pin_driver_max;
     p_sg_max=p_max+Pin_driver_max;
     Conditon=1; p_target0=-18;
         
    for p_target=p_sg_min:p_step:p_sg_max
        p_idx = 1+(p_target-p_sg_min)/p_step;
        Pin=fun_SBP_Driver_in2out(p_target, freq)-1+Mea_Probe(freq);
        %Pin=Pout_Driver(p_idx,f_idx);
        % Pin=p_target+32;     
        SignalGenerator_SMW200A(SMWAdd,freq,p_target,1);
            p_in=Pin;
            p_sg=p_target;
            SignalGenerator_SMW200A(SMWAdd,freq,p_target,2);
            fprintf('p_sg is %2.4f \n',p_sg);
            fprintf('p_in is %2.4f \n',p_in);
            %fun_VNA_freq_power_set(freq,p_target,VNA_addr,1);
            %p_out = fun_MATLAB_directSCPI_NRPZxx_Trace_my(27e9,1e-3,1e-4,triggerLev);
            p_out = MATLAB_directSCPI_NRPZxx_Avg_Power_my(freq);
            if p_out<-20
                RefLev     = -10;
            elseif (-20 < p_out) && (p_out<-15)
                RefLev     = 0;
            elseif (-15 < p_out) && (p_out<-5)
                RefLev     = 5;
            elseif p_out > -5
                RefLev = 10;
            else
                RefLev = 10;
            end
            
            NPR=SignalAnalyzer_FSW43_NPR(FSWIP,freq,BW,RefLev,1);
            I_m =fun_PowerSupply_HMP2030(HMP2030_IP);
            fprintf('p_out from PM is %2.4f \n',p_out);
            Pout=p_out-Mea_Attenuator_MMWave(freq);
            fprintf('SG power is %02.2f \n', Pout);
            Gain=Pout-Pin;
            P_DC=28*(I_m-0.0001);
            DE=100*10^((Pout-30)/10) / P_DC;
            PAE=100*(10^((Pout-30)/10)-10^((Pin-30)/10))/ P_DC;
            % create the data table
        data(f_idx).table(p_idx,1) = p_sg;     % signal generator power level
        data(f_idx).table(p_idx,2) = p_in;     % PA_in (a.k.a Driver_out)
        data(f_idx).table(p_idx,3) = P_DC;
        data(f_idx).table(p_idx,4) = Pout;      
        data(f_idx).table(p_idx,5) = Gain;   
        data(f_idx).table(p_idx,6) = DE;
        data(f_idx).table(p_idx,7) = PAE;
        data(f_idx).table(p_idx,8) = NPR;
    end
            SignalGenerator_SMW200A(SMWAdd,freq,p_target,3);
            
             %fun_VNA_freq_power_set(freq,p_target,VNA_addr,0);
%               scale1 = 'CH1:SCALE 0.02';
%               tri = 'TRIGGER:A:LEVEL:CH1 0.027';
%               I=fun_Main_TBS_Osc(scale1,tri);
%             pause(1);
        % create the data table
        %mea_P(f_idx)=mean(Atten);
       
end
 data_file_name = [ 'PA_data_NDPA_NPR_30_5G_one_notch_' datestr(now,'yyyy-mm-dd-HH-MM' )];
 save(data_file_name, 'data'); 
% 一下code用于plot paper中的图

linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv');
% load('PA_data_2017-08-19-21-39')
Nf=length(data);
freq=zeros(1,Nf);

% figure; plot(data(f_idx).table(:,3),data(f_idx).table(:,10))
% figure; plot(data(f_idx).table(:,3),data(f_idx).table(:,4))

% 平时简单的绘图如下
figure()
hold on
for i=1:Nf
    plot(data(i).table(:,4),data(i).table(:,5),linestyle1(i,:),'linewidth',1)
end
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([0,40,12,22]);
h=legend('24GHz','24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz','30GHz','30.5GHz','31GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:Nf
    plot(data(i).table(:,4),data(i).table(:,6),linestyle1(i,:),'linewidth',1)
end
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([0,40,0,40]);
h=legend('24GHz','24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz','30GHz','30.5GHz','31GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('DE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:Nf
    plot(data(i).table(:,4),data(i).table(:,7),linestyle1(i,:),'linewidth',1)
end
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([0,40,0,40]);
h=legend('24GHz','24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz','30GHz','30.5GHz','31GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('PAE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:Nf
    plot(data(i).table(:,4),data(i).table(:,8),linestyle1(i,:),'linewidth',1)
end
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([8,36,0,40]);
h=legend('24GHz','24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz','30GHz','30.5GHz','31GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('NPR (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on