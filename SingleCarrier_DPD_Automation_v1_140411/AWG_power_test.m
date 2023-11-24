clc 
clear all
close all

%%
Fcarrier = 2.0e9;
FramTime = 1e-3;
PowerBand = 0; % in dBm for ESG
Transmitter_type = 'AWG'; % choose between 'AWG' and 'ESG';
Fs=200e6;
DAC_SamplingRate = 8e9;
DDC_SamplingFrequency = 250e6;

%% Digitizer Parameters Definition
M9703A_VisaAddress='PXI21::0::0::INSTR';
ReferenceSource='AgMD1ReferenceOscillatorSourceAXI';
TriggerSource='External1';
TriggerLevel=0.2;
Channel='Channel1';
DownconversionEnabled=1;
% DDC_SamplingFrequency=250e6;
PointsPerRecord=floor(FramTime*DDC_SamplingFrequency) + 1; %189888;
Digitizer_SamplingFrequency=1000e6;
FullScaleRange=2;
ACDCCoupling=1;
%% Amplifier Parameters Definition
M9352A_VisaAddress='PXI32::10::0::INSTR';
AmpChannel='Channel1';
%% Instruments Initialization and Configuration
[M9703A_Obj] = M9703A_Configuration(M9703A_VisaAddress, ReferenceSource, TriggerSource, TriggerLevel);
[M9352A_Obj] = M9352A_Configuration(M9352A_VisaAddress);
%% Reading input files  

%%%%% WCDMA 111 / LTE 15 - 40 MHz
InI_beforeDPD_path = 'WCDMA111_LTE15_40MHz_In_I_200r0_PAPR_8r4_1ms.txt';
InQ_beforeDPD_path = 'WCDMA111_LTE15_40MHz_In_Q_200r0_PAPR_8r4_1ms.txt';

In_I_beforeDPD = load(['Signals\' InI_beforeDPD_path]); In_I_beforeDPD = In_I_beforeDPD(:, 1);
In_Q_beforeDPD = load(['Signals\' InQ_beforeDPD_path]); In_Q_beforeDPD = In_Q_beforeDPD(:, 1);

min_size = min([ size(In_I_beforeDPD,1) size(In_I_beforeDPD,1)]);

In_I_beforeDPD = In_I_beforeDPD(1:min_size);
In_Q_beforeDPD = In_Q_beforeDPD(1:min_size);

data_length = length(In_I_beforeDPD)

In_I = In_I_beforeDPD;
In_Q = In_Q_beforeDPD;

[In_I, In_Q] = setMeanPower(In_I, In_Q, PowerBand) ;

In_I = In_I - In_I + 1;
In_Q = In_Q - In_Q;

ComplexSignal{1} = complex(In_I, In_Q);
Fcarrier_array{1} = Fcarrier ;
FsampleTx_array{1} = Fs ;

ComplexSignal{2} = complex(In_Q, In_I);
Fcarrier_array{2} = 2.2e9 ;
FsampleTx_array{2} = Fs ;


%% Signal Transmission
AWG_M8190A_SignalUpload(ComplexSignal, Fcarrier_array, FsampleTx_array, DAC_SamplingRate, false, false)
AWG_M8190A_DAC_Amplitude(1,0.7)
AWG_M8190A_Output_OFF(1);

AWG_M8190A_Output_ON(1);

M9703A_Obj.Close;
M9352A_Obj.Close;
