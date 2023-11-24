%Clearing and preset
close all
clear all
clc
path('C:\Documents\Xiaohu_Fang\MATLAB\CW_Automation_08_15_2017',path)

CW_freq = 4.9e09;
IF_BW = 1e03;
Start_Power_dBm = -46;
Stop_Power_dBm = -23;
Step_dBm = 1;
 
%%% Initialize PNA driver 
PNA_Address = 'AgilentPNA835x.Application';
PNA_obj = actxserver (PNA_Address, 'machine', '10.0.0.10');
fprintf('Connected to PNA-X\n'); 

%%% Initialize Measurement Channel 
PNA_channel = PNA_obj.ActiveChannel;
fprintf('Measurement Channel Created\n');

% setting power meter and dc source
PM = PowerMeter_N1911A(15);
ATN=Attenuator('Attenuator_Coupler_4_8GHz_2.s2p');
PS_m = PowerSupply_N6705A(5);
PS_m_chan = 1; % channel to measure from
PS_a = PowerSupply_F3643A(7);

% connect to the instruments
PM.connect;
PS_m.connect;
PS_a.connect;

% preset the signal generator and power meter 
% SG.preset;
PM.preset;
PM.offset(ATN.attenuation(CW_freq)+0.5);
fprintf('Attenuation at %g Hz is %g dB\n', CW_freq, ATN.attenuation(CW_freq)+0.5);
%PM.offset(0);
PM.zero_and_cal;


%% **********************Small Signal Measurements***********
 
 %***********Port Setting********************%
P_Input = 1;
P_Output = 2;
%***********************END****************%

% %****************************Small Signal Measurement setup***********%
% Start_freq = 1e09;
% Stop_freq = 10e09;
% Step = 100e06;
% NumberofFreqpts = ((Stop_freq-Start_freq)/Step)+1;
% IF_BW = 10;
% freq = linspace(Start_freq,Stop_freq,NumberofFreqpts);
% freq = freq.*1e-09;
% %*********************************************************************%
%  PNA_obj.ActiveChannel.SweepType = 'naLinearSweep';
%  PNA_obj.ActiveChannel.IFBandwidth = IF_BW;
%  PNA_obj.ActiveChannel.StartFrequency = Start_freq;
%  PNA_obj.ActiveChannel.StopFrequency = Stop_freq;
%  PNA_obj.ActiveChannel.NumberOfPoints = NumberofFreqpts;
%  %**********************************************************%
% %NOTE: S-Parameter output Windows must be displayed for data acquisition% 
% 
% %**************************Creating Windows******************************%
% S11 dB
% PNA_obj.CreateSParameter(1,P_Input,P_Input,1);
% S21 dB
% PNA_obj.CreateSParameter(1,P_Output,P_Input,2);
% S12 dB
% PNA_obj.CreateSParameter(1,P_Input,P_Output,3);
% S22 dB
% PNA_obj.CreateSParameter(1,P_Output,P_Output,4);
% %************************************************************************%  
% fprintf('Acquire S-Parameter Data?\n'); 
% keyboard;
% A = PNA_obj.ActiveMeasurement.GetSnPData('S2P'); 
% SP = cell2mat(A(:,:,1));
% Storing Data
% S11 = SP(1,:);
% S21 = SP(2,:);
% S12 = SP(3,:);
% S22 = SP(4,:);
% 
% Plotting functions
% plot(freq,S11);
% figure();
% plot(freq,S21);
% figure();
% plot(freq,S12);
% figure()
% plot(freq,S22);

 %**********************Large Signal Measurements***********%

%%% Initialize DMM 34401A
% obj.socket = visa('agilent', 'GPIB1::12::INSTR');
% fopen(obj.socket);
% fprintf('Connected to DMM: %s\n', ident); 

%% *******Measurement Parameters************%

Numberofpoints = ((Stop_Power_dBm-Start_Power_dBm)/Step_dBm) + 1;
Pin = linspace(Start_Power_dBm,Stop_Power_dBm,Numberofpoints);
Pout = zeros(Numberofpoints,1);
Gain = zeros(Numberofpoints,1);
Phase = zeros(Numberofpoints,1);
%***********************END****************%

%*******************Receiver Selection*************************%
if P_Output == 1
    Receiver_ch = 'A';
elseif P_Output == 2
    Receiver_ch = 'B';
elseif P_Output == 3
    Receiver_ch = 'C';
else
    Receiver_ch = 'D';
end
%***********************END*************************************%

%Setting Large Signal Measurement Parameters
%Configuring Source
PNA_obj.ActiveChannel.SweepType = 'naPowerSweep';
PNA_obj.ActiveChannel.CWFrequency = CW_freq;
PNA_obj.ActiveChannel.IFBandwidth = IF_BW;
%Intializing vectors to store data
Pout_dBm = ones(1,Numberofpoints);
Gain = ones(1,Numberofpoints);
ID = ones(1,Numberofpoints);
index = 1;
%Creating Measurement Windows
%S21_dB for large signal gain
% PNA_obj.CreateMeasurement(1,'S2_1',1,1);
%Pout 
% PNA_obj.CreateMeasurement(1,'Receiver_ch',1,2);
%Manual Sweep
for k = Start_Power_dBm:Stop_Power_dBm
SourcePowerLevel_dBm = k;
PNA_obj.ActiveChannel.StartPower = k;
PNA_obj.ActiveChannel.StopPower = k;
if index<20
pause(1);
else pause(0.5);
end
% P = PNA_obj.ActiveMeasurement.getData(0,1);
%Read Gain
PNA_obj.ActivateWindow(1)
G = PNA_obj.ActiveMeasurement.getData(0,1);
Gain_CW(index) = mean(cell2mat(G));
%Read Phase 
PNA_obj.ActivateWindow(1)
Theta = PNA_obj.ActiveMeasurement.getData(0,2);
PM_CW(index) = mean(cell2mat(Theta));
%Read Pout 
% PNA_obj.ActivateWindow(2);
% P = PNA_obj.ActiveMeasurement.getData(0,1);
% Power_out(index) = mean(cell2mat(P));
%Read Drain Current from DMM
% ID(index) = query(obj.socket, ['MEASure:CURRent? '], '%s\n', '%g');
% k = k+Step_dBm;

% Read voltage , current and power from dc source and power meter
V_m(index) = PS_m.voltage(PS_m_chan);
I_m(index) = PS_m.current(PS_m_chan);
V_a(index) = PS_a.voltage;
I_a(index) = PS_a.current;
p_out(index) = PM.measure;
index = index +1;
% pause(0.5);
end
PNA_obj.ActiveChannel.StartPower = Start_Power_dBm;
PNA_obj.ActiveChannel.StopPower = Start_Power_dBm;
pause(2)
p_out_w = 10.^((p_out-30)/10); % p_out in Watts
% p_in_w(index) = 10^((p_in-30)/10); % p_in in Watts
p_dc = (V_m.*I_m+V_a.*I_a);
DE = 100*p_out_w./p_dc;
%
PNA_obj.ActiveChannel.StartPower = Start_Power_dBm;
PNA_obj.ActiveChannel.StopPower = Stop_Power_dBm;
pause(2);
AM_PM = PNA_read_trace_phase(2,  PNA_obj);
AM_AM = PNA_read_trace(1,  PNA_obj, 'dB');
%
% P_pna=Start_Power_dBm:Step_dBm:Stop_Power_dBm;
P_pna=Start_Power_dBm:Step_dBm:Stop_Power_dBm;
Pout=p_out';
P_pna=P_pna';
Gain_CW=Gain_CW';
PM_CW=PM_CW';
np=length(P_pna); np2=length(Pout);
table=zeros(np,11);
table(:,1)=P_pna;
table(1:np2,2)=Pout;
table(1:np2,3)=p_out_w';
table(1:np2,4)=I_m'*1000;
table(1:np2,5)=I_a'*1000;
table(1:np2,6)=p_dc';
table(1:np2,7)=DE';
table(:,8)=AM_AM;
table(1:np2,9)=Gain_CW;
table(:,10)=AM_PM;
table(1:np2,11)=PM_CW;

save('DPA_4r9GHz_AM_PM.mat','Pout','P_pna','AM_PM','AM_AM','Gain_CW','PM_CW','table');
PNA_obj.ActiveChannel.StartPower = Start_Power_dBm;
PNA_obj.ActiveChannel.StopPower = Start_Power_dBm;



%Plotting functions
figure(1);
hold on
plot(p_out,Gain_CW,'-ro', p_out,AM_AM(1:np2),'-m*');
set(gcf,'color','w');
axis([10,40,15,25]);
h=legend('CW','Pulse');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('AM AM','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off 

figure(2);
hold on
plot(p_out,PM_CW,'-ro', p_out,AM_PM(1:np2),'-m*');
set(gcf,'color','w');
axis([10,40,45,55]);
h=legend('CW','Pulse');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('AM PM','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off 
  
 
% data_file_name = [ 'PA_data_' datestr(now,'yyyy-mm-dd-HH-MM' )];
% save(data_file_name, 'data');
% %
% %
% close all
% linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<');
% % load('PA_data_2017-08-19-21-39')
% Nf=length(data);
% freq=zeros(1,Nf);
% Psat=zeros(1,Nf);
% for i=1:Nf
%     freq(i)=data(i).frequency;
%     Psat(i)=max(data(i).table(:,3));
% end 
% % figure; plot(data(f_idx).table(:,3),data(f_idx).table(:,10))
% % figure; plot(data(f_idx).table(:,3),data(f_idx).table(:,4))
% figure(1)
% hold on
% for i=1:Nf
%     plot(data(i).table(:,3),data(i).table(:,10),linestyle1(i,:),'linewidth',1)
% end
% % for i=1:Nx
% %     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
% %     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% % end
% set(gcf,'color','w');
% axis([20,40,0,60]);
% h=legend('4.7GHz','4.8GHz','4.9GHz','5.0GHz','5.1GHz','5.2GHz','5.3GHz');
% set(h,'fontsize',14,'fontname','Times New Roman')
% % title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
% xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
% ylabel('Drain Efficiency','fontsize',15,'fontname','Times New Roman','fontweight','b');    
% hold off    
% grid on
% % 平时简单的绘图如下
% figure(2)
% hold on
% for i=1:Nf
%     plot(data(i).table(:,3),data(i).table(:,4),linestyle1(i,:),'linewidth',1)
% end
% % for i=1:Nx
% %     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
% %     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% % end
% set(gcf,'color','w');
% axis([20,40,0,10]);
% h=legend('4.7GHz','4.8GHz','4.9GHz','5.0GHz','5.1GHz','5.2GHz','5.3GHz');
% set(h,'fontsize',14,'fontname','Times New Roman')
% % title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
% xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
% ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
% hold off    
% grid on
% figure(3)
% hold on
% for i=1:Nf
%     plot(data(i).table(:,3),data(i).table(:,6)*1000,linestyle1(i,:),'linewidth',1)
% end
% % for i=1:Nx
% %     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
% %     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% % end
% set(gcf,'color','w');
% axis([20,40,0,400]);
% h=legend('4.7GHz','4.8GHz','4.9GHz','5.0GHz','5.1GHz','5.2GHz','5.3GHz');
% set(h,'fontsize',14,'fontname','Times New Roman')
% for i=1:Nf
%     plot(data(i).table(:,3),data(i).table(:,8)*1000,linestyle1(i,:),'linewidth',1)
% end
% % title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
% xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
% ylabel('DC Drain Current (mA)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
% hold off    
% grid on
% %
% figure(4)
% hold on
% plot(freq/1e9, Psat, linestyle1(1,:),'linewidth',1)
% set(gcf,'color','w');
% axis([4.7,5.3,37,41]);
% % h=legend('4.9GHz','5.0GHz','5.1GHz');
% % set(h,'fontsize',14,'fontname','Times New Roman')
% % title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
% xlabel('Frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
% ylabel('Saturation Pout (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
% hold off    
% grid on
% 
