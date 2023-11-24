clc
clear
close all

path(pathdef); % Res ets the paths to remove paths outside this folder
addpath(genpath('C:\Program Files (x86)\IVI Foundation\IVI\Components\MATLAB')) ;
addpath(genpath(pwd))%Automatically Adds all paths in directory and subfolders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set Signal Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Receiver_type     = 'PXA';  % Choose between 'Digitizer' and 'PXA' for the receiver
Transmitter_type  = 'AWG';  % Choose between 'AWG' and 'ESG' for the transmitter - In case of ESG you should use MATLAB 2009a!!!

Fcarrier  = 0.90e9;         % Center frequency of the modulated signal
FrameTime  = 0.15e-3;      % Total frame time for the modulated signal
PowerBand = 0;           % Power in dBm for ESG (In case of high speed AWG, the power is controlled using VFS)
BW        = 40e6;        % Bandwidth of the modulated signal - Used to calculated ACLR and ACPR from the downloaded I/Q signals  %to be linked to signal
fG        = 300e3;       % Guard band for the modulated signal - Used to calculated ACLR and ACPR from the downloaded I/Q signals

Expansion_Margin = 0.83;           % Used for high speed AWG only. It is used to maintain the average power of AWG when the PAPR of the pre-distorted signal increases.
FsampleTx        = 200e6;         % The sampling rate of the I/Q input files - In 'ESG' mode the sampling clock of the ESG will be set to the same value       %to be linked to signal
FsampleRx        = 160e6;         % The sampling rate of the receiver (max 400MHz). for 160 MHz signals. this value can be set to 480MHz.
Amp_Corr         = false;          % amplitude correction for the AWG (set to true - recommended)
AWG_RefSource    = 'External';    % 'External'  'Backplane'

DAC_SamplingRate = 8e9;

predistort = 1; %set to 1 if you wanted channel one to transmit a separate predistorted signal
measure    = 0; %set to 1 if you wanted the receiver to measure and download the output signal

%without static predistortion
%V_scaling        = 1.2; %30.7dBm
V_scaling        = 1.45; %29.4dBm
% V_scaling        = 1.3; %28.1

% VFS1   = 0.66/V_scaling;
% VFS2   = 0.64/V_scaling;

%predistort_20MHz
% VFS1   = 0.62;
% VFS2   = 0.41;

%predistort_40MHz
VFS1   = 0.66;
VFS2   = 0.39;



%without predistort
PA_VS_delay                   = 1.40e-9;
PA_VS_delay                   = 1.375e-9;

%predistort
% PA_VS_delay                   = 1.355e-9;

delay_adjust                  = 0.1e-9;
channel2_fine_delay           = delay_adjust + PA_VS_delay;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reading the input files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [fname,dirpath]=uigetfile ('*.txt','Select a txt file','MultiSelect', 'on');
%%%%% LTE 20 MHz
% InI_beforeDPD_path = 'LTE_20MHz_In_I_100r0_PAPR_9r3_16QAM_1ms.txt';
% InQ_beforeDPD_path = 'LTE_20MHz_In_Q_100r0_PAPR_9r3_16QAM_1ms.txt';
%%%%% LTE 20 MHz recommended
% InI_beforeDPD_path = 'LTE_20MHz_In_I_100r0_PAPR_9r22_16QAM_1ms.txt';
% InQ_beforeDPD_path = 'LTE_20MHz_In_Q_100r0_PAPR_9r22_16QAM_1ms.txt';
%%%%% WCDMA 1C - 5 MHz
% InI_beforeDPD_path = 'WCDMA3G_1C_In_I_100r0_PAPR_7r4_Version1200_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_1C_In_Q_100r0_PAPR_7r4_Version1200_1ms.txt';
%%%%% WCDMA 101 - 10 MHz
% InI_beforeDPD_path = 'WCDMA3G_11_In_I_100r0_PAPR_7r4_Version1200_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_11_In_Q_100r0_PAPR_7r4_Version1200_1ms.txt';
%%%%% WCDMA 101 - 15 MHz
% InI_beforeDPD_path = 'WCDMA3G_101_In_I_100r0_PAPR_8r3_Version1200_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_101_In_Q_100r0_PAPR_8r3_Version1200_1ms.txt';
%%%%% WCDMA 4C - 20 MHz
% InI_beforeDPD_path2 = 'WCDMA3G_4C_In_I_100r0_PAPR_7r14_1ms.txt';
% InQ_beforeDPD_path2 = 'WCDMA3G_4C_In_Q_100r0_PAPR_7r14_1ms.txt';
% InI_beforeDPD_path = '20MHz_WDMA_I_Input_PreDist_1.txt';
% InQ_beforeDPD_path = '20MHz_WDMA_Q_Input_PreDist_1.txt';
%%%%% WCDMA 1001 - 20 MHz
% InI_beforeDPD_path = 'WCDMA3G_4C_1001_In_I_100r0_PAPR_7r11_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_4C_1001_In_Q_100r0_PAPR_7r11_1ms.txt';
%%%%% WCDMA 6C - 30 MHz
% InI_beforeDPD_path = 'WCDMA3G_110011_In_I_200r0_PAPR_8r6_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_110011_In_Q_200r0_PAPR_8r6_1ms.txt';
%%%%% WCDMA 6C - 30 MHz
% InI_beforeDPD_path = 'WCDMA3G_111111_In_I_625r0_PAPR_8r96_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_111111_In_Q_625r0_PAPR_8r96_1ms.txt';
% %%%%% WCDMA 111 / LTE 15 - 40 MHz

InI_beforeDPD_path2 = 'WCDMA111_LTE15_40MHz_In_I_200r0_PAPR_8r4_1ms.txt';
InQ_beforeDPD_path2 = 'WCDMA111_LTE15_40MHz_In_Q_200r0_PAPR_8r4_1ms.txt';
InI_beforeDPD_path = '40MHz_WCDMA_I_Input_PreDist_1_resample.txt';
InQ_beforeDPD_path = '40MHz_WCDMA_Q_Input_PreDist_1_resample.txt';

% InI_beforeDPD_path = 'WCDMA111_LTE15_40MHz_In_I_200r0_PAPR_8r4_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA111_LTE15_40MHz_In_Q_200r0_PAPR_8r4_1ms.txt';

%%%%% WCDMA 10C - 50 MHz
% InI_beforeDPD_path = 'WCDMA3G_10C_In_I_400r0_PAPR_10r0_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_10C_In_Q_400r0_PAPR_10r0_1ms.txt';
%%%%% WCDMA 4C + LTE15 + LTE20 - 80 MHz
% InI_beforeDPD_path = 'WCDMA_4C_LTE15_LTE20_80MHz_In_I_400r0_PAPR_10r9_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA_4C_LTE15_LTE20_80MHz_In_Q_400r0_PAPR_10r9_1ms.txt';
%%%% WCDMA 4C + LTE20 - 80 MHz
% InI_beforeDPD_path = 'WCDMA_4C_LTE20_80MHz_In_I_400r0_PAPR_9r6_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA_4C_LTE20_80MHz_In_Q_400r0_PAPR_9r6_1ms.txt';
%%%%% WCDMA 4C + LTE20 - 80 MHz
% InI_beforeDPD_path = 'WCDMA_4C_LTE20_80MHz_In_I_400r0_PAPR_10r4_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA_4C_LTE20_80MHz_In_Q_400r0_PAPR_10r4_1ms.txt';
% % % %%%%% WCDMA 4C + LTE20 + 1001 - 160 MHz
% InI_beforeDPD_path = 'WCDMA_4C_LTE20_1001_160MHz_In_I_800r0_PAPR_8r9_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA_4C_LTE20_1001_160MHz_In_Q_800r0_PAPR_8r9_1ms.txt';

In_I_beforeDPD     = load(['Signals\' InI_beforeDPD_path]); 
In_Q_beforeDPD     = load(['Signals\' InQ_beforeDPD_path]); 

min_size           = round(FrameTime*FsampleTx);
In_I_beforeDPD     = In_I_beforeDPD(1:min_size);
In_Q_beforeDPD     = In_Q_beforeDPD(1:min_size);

[In_I_beforeDPD, In_Q_beforeDPD] = setMeanPower(In_I_beforeDPD, In_Q_beforeDPD, 0) ;


In_I1 = In_I_beforeDPD; In_Q1 = In_Q_beforeDPD; 
In_I2 = In_I_beforeDPD; In_Q2 = In_Q_beforeDPD; 

if predistort == 1
    In_I_beforeDPD2     = load(['Signals\' InI_beforeDPD_path2]); 
    In_Q_beforeDPD2    = load(['Signals\' InQ_beforeDPD_path2]); 
    
    In_I_beforeDPD2     = In_I_beforeDPD2(1:min_size);
    In_Q_beforeDPD2    = In_Q_beforeDPD2(1:min_size);
    
    [In_I_beforeDPD2, In_Q_beforeDPD2] = setMeanPower(In_I_beforeDPD2, In_Q_beforeDPD2, 0) ;
    
    In_I2 = In_I_beforeDPD2; In_Q2 = In_Q_beforeDPD2; 
end

[meanIn, maxIn, PAPR_input]   = checkPower(In_I1, In_Q1);
PAPR_original                 = PAPR_input;

% temp code
%In_I1 = ones(length(In_I1),1); In_Q1 = In_I1; In_I2 = zeros(length(In_I2),1); In_Q2 = ones(length(In_Q2),1);

ComplexSignal{1}              = complex(In_I1, In_Q1);
CarrierFreqCell{1}            = Fcarrier ;
FsampleTx_array{1}            = FsampleTx ;
ComplexSignal{2}              = complex(In_I2, In_Q2);
CarrierFreqCell{2}            = Fcarrier ;
FsampleTx_array{2}            = FsampleTx ;

AWG_M8190A_Reference_Clk(AWG_RefSource,10e6);
AWG_M8190A_SignalUpload_DualChannel_FixedAvgPower(ComplexSignal, CarrierFreqCell, FsampleTx_array, DAC_SamplingRate, true, false, Expansion_Margin, PAPR_input, PAPR_original, channel2_fine_delay)
AWG_M8190A_DAC_Amplitude(1,VFS1);
AWG_M8190A_DAC_Amplitude(2,VFS2);
AWG_M8190A_MKR_Amplitude(1,1.2);
AWG_M8190A_Output_ON(1);
AWG_M8190A_Output_ON(2);

if measure == 1
% Receiver

PXAAdd = 18;
PXA_Atten = 16;
mem_truncate = 20;
[xEVM , yEVM, EVM_perc, FsampleDPD, RxPower] = PXA_CaptureResampleAnalyzeEVM(In_I2(mem_truncate:end), In_Q2(mem_truncate:end), Fcarrier, FsampleRx, FsampleTx, FrameTime, PXAAdd, PXA_Atten, 0);
    
 % analyze
    display(['received signal has an average power of ' ...
        num2str(RxPower.meanPower) 'and a peak power of ' num2str(RxPower.maxPower)]);
    
    PlotGain(real(xEVM), imag(xEVM), real(yEVM), imag(yEVM)) ;
    PlotAMPM(real(xEVM), imag(xEVM), real(yEVM), imag(yEVM)) ;
    PlotSpectrum(real(xEVM), imag(xEVM), real(yEVM), imag(yEVM)) ;
    [freq, spectrum] = Calculated_Spectrum(real(yEVM), imag(yEVM), FsampleDPD);
    [ACLR_L, ACLR_U] = Calculate_ACLR (freq, spectrum, 0, BW, fG);
    [ACPR_L, ACPR_U] = Calculate_ACPR (freq, spectrum, 0, BW, fG);
    
     
    display([ 'EVM          = ' num2str(EVM_perc)      ' % ' ]);
    display([ 'ACLR (L/U)   = ' num2str(ACLR_L) ' / '  num2str(ACLR_U) ' dB ' ]);
    display([ 'ACPR (L/U)   = ' num2str(ACPR_L) ' / '  num2str(ACPR_U) ' dB ' ]);


% Save I and Q file
AWG_M8190A_Output_OFF(1);
AWG_M8190A_Output_OFF(2);

cd('Measurements')
fidIEH = fopen(['I_w_VS_in_40MHz_higher_bias.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',real(xEVM));
fclose(fidIEH);
fidIEH = fopen(['Q_w_VS_in_40MHz_higher_bias.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',imag(xEVM));
fclose(fidIEH);
fidIEH = fopen(['I_w_VS_out_40MHz_higher_bias.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',real(yEVM));
fclose(fidIEH);
fidIEH = fopen(['Q_w_VS_out_40MHz_higher_bias.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',imag(yEVM));
fclose(fidIEH);
cd ..
end


