clc 
clear all
close all

FsampleTx = 100e6; % Input file sampling rate - Has to be an integer of the DAC_SamplingRate
FsampleRx = 100e6; % DPD analysis sampling rate
FramTime = 0.4e-3;

Fsample_desired = FsampleRx; %min(FsampleTx,FsampleRx);
Fs=Fsample_desired;

DAC_SamplingRate = 4e9;
DDC_SamplingFrequency=250e6; %250e6;
Digitizer_SamplingFrequency=1000e6;

%% Digitizer Parameters Definition
M9703A_VisaAddress='PXI21::0::0::INSTR';
ReferenceSource='AgMD1ReferenceOscillatorSourceAXI';
% ReferenceSource='AgMD1ReferenceOscillatorSourceExternal';
TriggerSource='External1';
TriggerLevel=0.2;
Channel='Channel1';
DownconversionEnabled=0; % choose between 0 (Digitizer) and 1 (DDC)
DownconversionMode=0; % choose between 0 (no Downconversion), 1 (Single DownConversion) and 2 (Dual DownConversion)
PointsPerRecord=floor(FramTime*DDC_SamplingFrequency) + 1; %189888;
FullScaleRange=2;
ACDCCoupling=1;
%% Amplifier Parameters Definition
M9352A_VisaAddress='PXI32::10::0::INSTR';
AmpChannel='Channel1';
load FIR_filter_fs_1r0GHz_fpass_0r2GHz_Order343.mat
FIR_filter_num = Num;
M9352A_Gain_value = 8;


%% Reading input files  
%%%%% LTE 20 MHz
% InI_beforeDPD_path = 'LTE_20MHz_In_I_100r0_PAPR_9r3_16QAM_1ms.txt';
% InQ_beforeDPD_path = 'LTE_20MHz_In_Q_100r0_PAPR_9r3_16QAM_1ms.txt';

%%%%% WCDMA 11 - 10 MHz
InI_beforeDPD_path = 'WCDMA3G_11_In_I_100r0_PAPR_7r4_Version1200_1ms.txt';
InQ_beforeDPD_path = 'WCDMA3G_11_In_Q_100r0_PAPR_7r4_Version1200_1ms.txt';

% % %%%%% WCDMA 101 - 15 MHz
% InI_beforeDPD_path = 'WCDMA3G_101_In_I_100r0_PAPR_8r3_Version1200_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_101_In_Q_100r0_PAPR_8r3_Version1200_1ms.txt';

% % %%%%% WCDMA 4C - 20 MHz
% InI_beforeDPD_path = 'WCDMA3G_4C_In_I_200r0_PAPR_7r14_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_4C_In_Q_200r0_PAPR_7r14_1ms.txt';

%%%%% WCDMA 1001 - 20 MHz
% InI_beforeDPD_path = 'WCDMA3G_4C_1001_In_I_200r0_PAPR_7r11_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_4C_1001_In_Q_200r0_PAPR_7r11_1ms.txt';

%%%%% WCDMA 4C - 30 MHz
% InI_beforeDPD_path = 'WCDMA3G_110011_In_I_200r0_PAPR_8r6_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_110011_In_Q_200r0_PAPR_8r6_1ms.txt';

%%%%% WCDMA 6C - 30 MHz
% InI_beforeDPD_path = 'WCDMA3G_111111_In_I_625r0_PAPR_8r96_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_111111_In_Q_625r0_PAPR_8r96_1ms.txt';

%%%%% WCDMA 111 / LTE 15 - 40 MHz
% InI_beforeDPD_path = 'WCDMA111_LTE15_40MHz_In_I_200r0_PAPR_8r4_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA111_LTE15_40MHz_In_Q_200r0_PAPR_8r4_1ms.txt';


In_I_beforeDPD = load(['Signals\' InI_beforeDPD_path]); In_I_beforeDPD = In_I_beforeDPD(:, 1);
In_Q_beforeDPD = load(['Signals\' InQ_beforeDPD_path]); In_Q_beforeDPD = In_Q_beforeDPD(:, 1);

min_size = min([ size(In_I_beforeDPD,1) size(In_I_beforeDPD,1)]);

if min_size > round(FramTime*FsampleTx) + 1
    min_size = round(FramTime*FsampleTx) + 1;
end
In_I_beforeDPD = In_I_beforeDPD(1:min_size);
In_Q_beforeDPD = In_Q_beforeDPD(1:min_size);

In_I_cal = In_I_beforeDPD;
In_Q_cal = In_Q_beforeDPD;

[In_I_cal, In_Q_cal] = setMeanPower(In_I_cal, In_Q_cal, 0) ;
checkPower(In_I_cal, In_Q_cal, 1) ;
shaping = 9;
Env_channel = 2;
Envelope_Upload_AWG_M8190A (In_I_cal, In_Q_cal, Fs, DAC_SamplingRate,shaping,Env_channel);
AWG_M8190A_Reference_Clk('External',10e6);        
VFS = 0.4;
AWG_M8190A_DAC_Amplitude(Env_channel,VFS);
AWG_M8190A_MKR_Amplitude(Env_channel,1.2);
AWG_M8190A_Output_OFF(Env_channel);        
AWG_M8190A_Output_ON(Env_channel);        
  

