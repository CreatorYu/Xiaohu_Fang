%Clearing and preset
close all
clear all
clc
 
%%% Initialize PNA driver 
PNA_Address = 'AgilentPNA835x.Application';
PNA_obj = actxserver (PNA_Address, 'machine', '10.0.0.10');
fprintf('Connected to PNA-X\n'); 

%%% Initialize Measurement Channel 
PNA_channel = PNA_obj.ActiveChannel;
fprintf('Measurement Channel Created\n'); 


%% **********************Small Signal Measurements***********
 
 %***********Port Setting********************%
% P_Input = 1;
% P_Output = 3;
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
CW_freq = 5e09;
IF_BW = 1e03;
Start_Power_dBm = -20;
Stop_Power_dBm = -15;
Step_dBm = 1;
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
PNA_obj.CreateMeasurement(1,'S3_1',1,1);
%Pout 
PNA_obj.CreateMeasurement(1,'Receiver_ch',1,2);
%Manual Sweep
for k = Start_Power_dBm:Stop_Power_dBm
SourcePowerLevel_dBm = k;
PNA_obj.ActiveChannel.StartPower = k;
PNA_obj.ActiveChannel.StopPower = k;
pause(3);
P = PNA_obj.ActiveMeasurement.getData(0,1);
%Read Gain
PNA_obj.ActivateWindow(1)
G = PNA_obj.ActiveMeasurement.getData(0,1);
Gain(index) = mean(cell2mat(G));
%Read Phase 
PNA_obj.ActivateWindow(1)
Theta = PNA_obj.ActiveMeasurement.getData(0,2);
Phase(index) = mean(cell2mat(Theta));
%Read Pout 
PNA_obj.ActivateWindow(2);
P = PNA_obj.ActiveMeasurement.getData(0,1);
Power_out(index) = mean(cell2mat(P));
%Read Drain Current from DMM
% ID(index) = query(obj.socket, ['MEASure:CURRent? '], '%s\n', '%g');
k = k+Step_dBm;
index = index +1;
pause(3);
end

%Plotting functions
plot(Pin,Power_out);
figure();
plot(Pin,Gain);
figure();
plot(Pin,Phase);

%Close all Equipement
%Disconnect DMM 34401A
% fclose(obj.socket);
% fprintf('Disconnected from DMM\n');

 
 %Power Meter code%
 % %%% Initialize Power Meter N1911A
% obj2.GPIB_addr = 'GPIB1::13::INSTR';
% visa_str = sprintf('GPIB1::13::INSTR', obj2.GPIB_addr);
% obj2.socket = visa('agilent', visa_str);
% obj2.socket.Timeout = 100;
% fopen(obj2.socket)
%  fprintf('Connected to power meter: %s\n', ident); 

% %Perform Zero and Cal on Power Meter N1911A
%  err = query(obj2.socket, 'CALibration?');
%             if(str2double(err))
%                 fprintf('Power meter zero and cal failed: code %s\n', err);
%             else
%                 fprintf('Power meter zero and cal successful\n');
%             end
% %Setting Power Meter to CW Fequency
% fprintf(obj2.socket, ':FREQuency %d Hz', CW_freq);

%Disconnect DMM 34401A
%fclose(obj2.socket);
%fprintf('Disconnected from power meter\n');

% fprintf(obj2.socket, 'CONFigure');
% fprintf(obj2.socket, 'SENSe:AVERage:COUNt 15');
% Pout_dBm(index) = query(obj2.socket, 'READ?', '%s\n', '%g');
 