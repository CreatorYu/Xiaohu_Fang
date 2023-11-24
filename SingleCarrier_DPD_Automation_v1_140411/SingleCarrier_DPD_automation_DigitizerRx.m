clc
clear
close all

path(pathdef); % Resets the paths to remove paths outside this folder
addpath(genpath('C:\Program Files (x86)\IVI Foundation\IVI\Components\MATLAB')) ;
addpath(genpath(pwd))%Automatically Adds all paths in directory and subfolders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set Signal Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Receiver_type     = 'Digitizer';  % Choose between 'Digitizer' and 'PXA' for the receiver
Transmitter_type  = 'AWG';  % Choose between 'AWG' and 'ESG' for the transmitter - In case of ESG you should use MATLAB 2009a!!!

global pinv_tol 
pinv_tol = 1e-5;

Fcarrier  = 2e9;         % Center frequency of the modulated signal
FramTime  = 0.4e-3;      % Total frame time for the modulated signal
BW        = 20e6;        % Bandwidth of the modulated signal - Used to calculated ACLR and ACPR from the downloaded I/Q signals  %to be linked to signal
fG        = 300e3;       % Guard band for the modulated signal - Used to calculated ACLR and ACPR from the downloaded I/Q signals

Expansion_Margin = 1.0;           % Used for high speed AWG only. It is used to maintain the average power of AWG when the PAPR of the pre-distorted signal increases.
NofIteration     = 15;            % Maximum # of DPD Iterations
NofDPDPoints     = 10000;         % # of points used in DPD identification
DelayMethod      = 'CrossCorr';   % The method used to adjust the delay between the transmitted and received signal
WaveformName     = 'WCDMA4C';     % The waveform name - Only used when uploading signal to ESG

FsampleTx        = 100e6;         % The sampling rate of the I/Q input files - In 'ESG' mode the sampling clock of the ESG will be set to the same value       %to be linked to signal
FsampleRx        = 100e6;         % The sampling rate of the receiver (max 160MHz)

Fsample_desired  = FsampleRx;     % The sampling rate of the DPD modeing. Fsample_desired < FsampleRx
Fs=Fsample_desired;               %

GainExpansion       = 'No';       % Expansion of the original input signal to take into account for the expansion of the DPD
GainExpansion_value = 2.0;        % Expansion of the original input in dB

Automate_LO = 0;                  % 0 = no automation, 1 = automation, requires GPIB connection of equipment to PC
Amp_Corr = true;                  % amplitude correction for the AWG (set to true - recommended)
mem_truncate = 0;
keep_RF_ON = false;
DoCalibration = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set DPD Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DPD_type = 'Volterra_DDR';
% DPD_type = 'RF_Volterra';
% DPD_type = 'MP';
% DPD_type = 'APD';
% DPD_type = 'FIR_APD';
% DPD_type = 'AUG_MP';
% DPD_type = 'RFMP_ADRF';
% DPD_type = 'RFMP_DRF_MFOD';
switch DPD_type
    case {'Volterra_DDR_ET', 'Volterra_DDR'}
        %%%%% Volterra DDR ET parameters
        VolterraParameters.ModifiedKernels = false;
        VolterraParameters.ModifiedFile    = 'kernelsML.txt' ;
        VolterraParameters.DDR             = true ;
        VolterraParameters.DDRorder        = 2 ;
        %   VolterraETParameters.Order         = [ h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 ] ;
        VolterraParameters.Order           = [ 7  0  5  0  3  0  0  0  0  0   0   ] ;%[ 7  0  5  0  3  0  0  0  0  0   0   ] ;
        VolterraParameters.Static          = 9 ;
        % @Anik: experimental code for wide BW signals
        VolterraParameters.Step            = 1 ;
        if strcmp(DPD_type,'Volterra_DDR')
            VolterraParameters.NSupply = 1 ;
        elseif strcmp(DPD_type,'Volterra_DDR_ET')
            VolterraParameters.NSupply = 1 ;
        end
    case {'RF_Volterra', 'RF_Volterra_ET'}
        RF_Volterra_Parameters.memory_lag=1;
        RF_Volterra_Parameters.embedding_dimension=3 ;
        RF_Volterra_Parameters.M1=3;
        RF_Volterra_Parameters.M3=2;
        RF_Volterra_Parameters.M5=1;
        RF_Volterra_Parameters.M7=0;
        RF_Volterra_Parameters.NL=9 ;
        RF_Volterra_Parameters.carrier_frequency=2*pi*Fcarrier;
        RF_Volterra_Parameters.NSupply=1 ;
    case {'MP', 'AUG_MP'}
        MP_modelParam.N = 7;
        MP_modelParam.M = 5;
        MP_modelParam.Gamma = 0;
        MP_modelParam.type = 'odd_even';  %type = 'odd' or 'odd_even'
    case 'APD'
        APD_modelParam.N = 8;
        APD_modelParam.M = 4;
        APD_modelParam.FIR_M = 4;
        APD_modelParam.architecture = 'multiply'; % 'add' or 'multiply';
        % Supported Mode MP, H_EMP, Mod_H_EMP, CRV, ECRV, ECRV_Pruned
        % Currently not supported UB_MP, NB_EMP, Mod_NB_EMP, Deriv_MP
        APD_modelParam.engine = 'MP';
        APD_modelParam.polyorder = 'odd_aug'; % 'odd' or 'odd_even' or 'odd_aug'
        APD_modelParam.two_step = 0;
    case 'FIR_APD'
        FIR_APD_modelParam.APD_N = 8;
        FIR_APD_modelParam.APD_M = 4;
        FIR_APD_modelParam.FIR_M = 4;
        FIR_APD_modelParam.architecture = 'multiply'; % 'add' or 'multiply';
        % Supported Mode MP, H_EMP, Mod_H_EMP, CRV, ECRV, ECRV_Pruned
        % Currently not supported UB_MP, NB_EMP, Mod_NB_EMP, Deriv_MP
        FIR_APD_modelParam.engine = 'H_EMP';
        FIR_APD_modelParam.polyorder = 'odd_aug'; % 'odd' or 'odd_even' or 'odd_aug'
        FIR_APD_modelParam.two_step = 1;
        % 0: no FIR, 1: parallel_FIR, 2: seperate FIR
        FIR_APD_modelParam.use_parallel_FIR = 1;
        FIR_APD_modelParam.use_NL = 0;
    case 'RFMP_ADRF'
        RFMP_modelParam.MOD_NUM = 2;
        RFMP_modelParam.MOD_DEN = 1;
        RFMP_modelParam.DEN_TYP = 1;
        RFMP_modelParam.M_NUM = 5;
        RFMP_modelParam.M_DEN = 3;
        RFMP_modelParam.N_NUM = 4;
        RFMP_modelParam.N_DEN = RFMP_modelParam.N_NUM+1;
        RFMP_modelParam.BASIS = 'RFMP_ADRF';
        RFMP_modelParam.useNL = 1;
    case 'RFMP_DRF_MFOD'
        RFMP_modelParam.MOD_NUM = 0;
        RFMP_modelParam.MOD_DEN = 0;
        RFMP_modelParam.DEN_TYP = 0;
        RFMP_modelParam.M_NUM = 5;
        RFMP_modelParam.M_DEN = 1;
        RFMP_modelParam.N_NUM = 4;
        RFMP_modelParam.N_DEN = 1;
        RFMP_modelParam.BASIS = 'RFMP_DRF_MFOD';
        RFMP_modelParam.useNL = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set Transmitter/Receiver Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PXAAdd                = 18;                                       % The GPIB address of the PXA
PXA_Atten             = 10;                                       % The mechanical attenuation in dB for the PXA when dowloading the signal. From 6 to 24 with steps of 2 dB
ESGAdd                = 19;                                       % The GPIB address of the ESG
PowerBand 			  = 0;           							  % Power in dBm for ESG (In case of high speed AWG, the power is controlled using VFS)
E4438C_VisaAddress    = ['GPIB0::' num2str(ESGAdd) '::INSTR'];    % Creates the Visa address of the ESG - 'GPIB0::19::INSTR'

DAC_SamplingRate            = 8e9;      % The sampling rate of the AWG - The input I/Q files with sampling rate of FsampleTx will be upsampled to this number. DAC_SamplingRate has to be an integer multiple of FsampleTx
DDC_SamplingFrequency       = 250e6;    % The sampling rate of the Digitzer when in downconversion mode
Digitizer_SamplingFrequency = 1000e6;   % The sampling rate of the Digitzer when in non-downconversion mode
RF_channel                  = 2;        % AWG channel used for sending RF signal - Not used in 'ESG' mode
VFS                         = 0.7;      % Full scale voltage of the AWG. 0.1 < VFS < 0.7;

if strcmp(Transmitter_type,'AWG')
    [DownSampleTx, UpSampleTx] = rat(FsampleTx/FsampleRx);
elseif strcmp(Transmitter_type,'ESG')
    if FsampleTx > 100e6
        disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        disp(' Warning... ESG maximum sampling rate is 100 MHz. Value of 100 MHz will be used for the measurements');
        disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        FsampleTx = 100e6;
    end
    [DownSampleTx, UpSampleTx] = rat(FsampleTx/FsampleTx);
end
if strcmp(Receiver_type,'Digitizer')
    [DownSampleRx, UpSampleRx] = rat(FsampleRx/DDC_SamplingFrequency);
    [DownSampleDigitizer, UpSampleDigitizer] = rat(FsampleRx/Digitizer_SamplingFrequency);
elseif strcmp(Receiver_type,'PXA')
    if FsampleRx > 160e6
        disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        disp(' Warning... PXA maximum sampling rate is 160 MHz. Value of 160 MHz will be used for the measurements');
        disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        FsampleRx = 160e6;
    end
    [DownSampleRx, UpSampleRx] = rat(FsampleRx/FsampleRx);
end
if ( strcmp(Receiver_type,'Digitizer') || strcmp(Transmitter_type,'AWG') )
    % Digitizer Parameters Definition
    M9703A_VisaAddress='PXI21::0::0::INSTR';
    ReferenceSource='AgMD1ReferenceOscillatorSourceAXI';
    %     ReferenceSource='AgMD1ReferenceOscillatorSourceExternal';
    TriggerSource='External1';
    TriggerLevel=0.2;
    Channel='Channel1';
    DownconversionEnabled =0;   % choose between 0 (Digitizer) and 1 (DDC)
    DownconversionMode    =1;   % choose between 0 (no Downconversion), 1 (Single DownConversion) and 2 (Dual DownConversion)
    PointsPerRecord=floor(FramTime*DDC_SamplingFrequency) + 1; %189888;
    FullScaleRange=2;
    ACDCCoupling=1;
    % Amplifier Parameters Definition
    M9352A_VisaAddress='PXI32::10::0::INSTR';
    AmpChannel='Channel1';
    load FIR_filter_fs_1r0GHz_fpass_0r2GHz_Order343.mat
    %     load FIR_filter_fs_1r0GHz_fpass_0r35GHz_Order375.mat
    FIR_filter_num = Num;
    M9352A_Gain_value = 14; % Max: 39.5, Min: 8
end
if strcmp(Receiver_type,'Digitizer')
    % LO Generator Parameters Definition
    %     E4438C_VisaAddress='GPIB0::19::INSTR'; %'GPIB0::19::INSTR'
    E4433B_Add = 17;
    E4433B_VisaAddress=['GPIB0::' num2str(E4433B_Add) '::INSTR']; %'GPIB0::17::INSTR'
    % 380e6 for 850MHz, 390e6 for 750MHz
    IF_Frequency=250e6; %250e6;
    IF2_Frequency=2.0e9; %250e6;
    % LO_Frequency2=Fcarrier2-IF_Frequency;
    LO_Amplitude=0;
    LO_type = 'E4438C';  % choose between 'E4433B' and 'E4438C'
    LO2_type = 'E4438C';  % choose between 'E4433B' and 'E4438C'
    if (DownconversionMode == 2)
        LO_Frequency1=IF2_Frequency-IF_Frequency;
        LO_Frequency2=Fcarrier+IF2_Frequency;
    elseif (DownconversionMode == 1)
        LO_Frequency1=Fcarrier+IF_Frequency;
    elseif (DownconversionMode == 0)
    end
end
if strcmp(Receiver_type,'Digitizer')
    %     [Digitizer.M9703A_Obj]  =  M9703A_Configuration(Digitizer.M9703A_VisaAddress, Digitizer.ReferenceSource, Digitizer.TriggerSource, Digitizer.TriggerLevel);
    [M9703A_Obj] = M9703A_Configuration(M9703A_VisaAddress, ReferenceSource, TriggerSource, TriggerLevel, DoCalibration);
    [M9352A_Obj] = M9352A_Configuration(M9352A_VisaAddress);
    if (DownconversionMode == 1) || (DownconversionMode == 2)
        if strcmp(LO_type,'E4433B')
            E4433B_RF_Configuration (LO_Frequency1, LO_Amplitude, E4433B_Add);
        end
        if ( strcmp(LO_type,'E4438C') || strcmp(LO2_type,'E4438C') )
            if (Automate_LO == 1)
                [E4438C_Obj] = E4438C_Configuration(E4438C_VisaAddress);
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reading the input files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [fname,dirpath]=uigetfile ('*.txt','Select a txt file','MultiSelect', 'on');
%%%%% LTE 20 MHz
% InI_beforeDPD_path = 'LTE_20MHz_In_I_100r0_PAPR_9r3_16QAM_1ms.txt';
% InQ_beforeDPD_path = 'LTE_20MHz_In_Q_100r0_PAPR_9r3_16QAM_1ms.txt';
%%%%% LTE 20 MHz recommended
InI_beforeDPD_path = 'LTE_20MHz_In_I_100r0_PAPR_9r22_16QAM_1ms.txt';
InQ_beforeDPD_path = 'LTE_20MHz_In_Q_100r0_PAPR_9r22_16QAM_1ms.txt';
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
% InI_beforeDPD_path = 'WCDMA3G_4C_In_I_100r0_PAPR_7r14_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_4C_In_Q_100r0_PAPR_7r14_1ms.txt';
%%%%% WCDMA 1001 - 20 MHz
% InI_beforeDPD_path = 'WCDMA3G_4C_1001_In_I_100r0_PAPR_7r11_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_4C_1001_In_Q_100r0_PAPR_7r11_1ms.txt';
%%%%% WCDMA 6C - 30 MHz
% InI_beforeDPD_path = 'WCDMA3G_110011_In_I_200r0_PAPR_8r6_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_110011_In_Q_200r0_PAPR_8r6_1ms.txt';
%%%%% WCDMA 6C - 30 MHz
% InI_beforeDPD_path = 'WCDMA3G_111111_In_I_625r0_PAPR_8r96_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_111111_In_Q_625r0_PAPR_8r96_1ms.txt';
%%%%% WCDMA 111 / LTE 15 - 40 MHz
% InI_beforeDPD_path = 'WCDMA111_LTE15_40MHz_In_I_200r0_PAPR_8r4_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA111_LTE15_40MHz_In_Q_200r0_PAPR_8r4_1ms.txt';
%%%%% WCDMA 10C - 50 MHz
% InI_beforeDPD_path = 'WCDMA3G_10C_In_I_400r0_PAPR_10r0_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_10C_In_Q_400r0_PAPR_10r0_1ms.txt';
%%%%% WCDMA 4C + LTE15 + LTE20 - 80 MHz
% InI_beforeDPD_path = 'WCDMA_4C_LTE15_LTE20_80MHz_In_I_400r0_PAPR_10r9_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA_4C_LTE15_LTE20_80MHz_In_Q_400r0_PAPR_10r9_1ms.txt';
%%%%% WCDMA 4C + LTE20 - 80 MHz
% InI_beforeDPD_path = 'WCDMA_4C_LTE20_80MHz_In_I_400r0_PAPR_9r6_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA_4C_LTE20_80MHz_In_Q_400r0_PAPR_9r6_1ms.txt';
%%%%% WCDMA 4C + LTE20 - 80 MHz
% InI_beforeDPD_path = 'WCDMA_4C_LTE20_80MHz_In_I_400r0_PAPR_10r4_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA_4C_LTE20_80MHz_In_Q_400r0_PAPR_10r4_1ms.txt';
%%%%% WCDMA 4C + LTE20 + 1001 - 160 MHz
% InI_beforeDPD_path = 'WCDMA_4C_LTE20_1001_160MHz_In_I_800r0_PAPR_8r9_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA_4C_LTE20_1001_160MHz_In_Q_800r0_PAPR_8r9_1ms.txt';
%%%%% Receiver Calibration, Fs = 400e6, 201 tones, -100 to 100 MHz
% InI_beforeDPD_path = 'MT_I.txt';
% InQ_beforeDPD_path = 'MT_Q.txt';

In_I_beforeDPD = load(['Signals\' InI_beforeDPD_path]); In_I_beforeDPD = In_I_beforeDPD(:, 1);
In_Q_beforeDPD = load(['Signals\' InQ_beforeDPD_path]); In_Q_beforeDPD = In_Q_beforeDPD(:, 1);

min_size = min([ size(In_I_beforeDPD,1) size(In_I_beforeDPD,1)]);

if min_size > round(FramTime*FsampleTx) + 1
    min_size = round(FramTime*FsampleTx) + 1;
end
In_I_beforeDPD = In_I_beforeDPD(1:min_size-1);
In_Q_beforeDPD = In_Q_beforeDPD(1:min_size-1);

[In_I_beforeDPD, In_Q_beforeDPD] = setMeanPower(In_I_beforeDPD, In_Q_beforeDPD, 0) ;
[meanPower, maxPower, PAPR_original] = checkPower(In_I_beforeDPD, In_Q_beforeDPD, 1) ;

Vdd_beforeDPD = abs(complex(In_I_beforeDPD, In_Q_beforeDPD));

In_I_beforeDPD_EVM = resample(In_I_beforeDPD,UpSampleTx,DownSampleTx);
In_Q_beforeDPD_EVM = resample(In_Q_beforeDPD,UpSampleTx,DownSampleTx);

data_length = length(In_I_beforeDPD);

disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp([' The length of the signals   = ',num2str(data_length)]);
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

In_I = In_I_beforeDPD;
In_Q = In_Q_beforeDPD;

if strcmp(GainExpansion,'Yes')
    InflectionPoint=0.2;
    PAPR_beforeExpansion=computePAPR(In_I,In_Q)
    [ In_I , In_Q ] = Generate_XdB_Expansion(In_I,In_Q,GainExpansion_value,InflectionPoint);
    PAPR_afterExpansion=computePAPR(In_I,In_Q)
end

% Turn LO ON
% Prompt user to turn LO ON
if Automate_LO == 0
    [Continue_Flag] = Confirmation_Dialogue('Is the LO Source turned ON?','Turn ON Prompt');
    if Continue_Flag == -1
        if strcmp(Receiver_type,'Digitizer')
            M9703A_Obj.Close;
            M9352A_Obj.Close;
        end
        error('User Abort');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DPD Iteration loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for IterationCount = 1:NofIteration
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp([' Iteration nb ',num2str(IterationCount), ' out of ', num2str(NofIteration)]);
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    In_I_cal = In_I; In_Q_cal = In_Q;

    
    SignalName                        = [WaveformName, num2str(IterationCount)];
    [In_I_cal, In_Q_cal]              = setMeanPower(In_I_cal, In_Q_cal, PowerBand);      % Set the mean power of the I/Q signals to be uploaded
    [In_I, In_Q]                      = setMeanPower(In_I, In_Q, 0);                      % Set the mean power of the I/Q signals to be used for DPD
    [meanPower, maxPower, PAPR_input] = checkPower(In_I_cal, In_Q_cal, 1) ;  % Check the PAPR of the input file to be uploaded to the transmitter
    ComplexSignal{1}                  = complex(In_I_cal, In_Q_cal);
    Fcarrier_array{1}                 = Fcarrier ;
    FsampleTx_array{1}                = FsampleTx ;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Uploading the signal
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(Transmitter_type,'ESG')
        ESG_RF_OFF_SingleCarrier(ESGAdd);
        IQUpload_Singleband ( In_I_cal', In_Q_cal', PowerBand,  Fcarrier, FsampleTx, ESGAdd, SignalName,data_length);
        
        %         RF_ON_Continue    = 0;
        [RF_ON_Continue]  = PushButton_Routine (keep_RF_ON,Transmitter_type,ESGAdd,RF_channel);
        
        ESG_RF_ON_SingleCarrier(ESGAdd);
        
    elseif strcmp(Transmitter_type,'AWG')
        % experimental
        %         clear In_I_cal In_Q_cal iqdata iqtotaldata IQ_data RecI RecQ
        %         WaveformArray0 time_IQ
        AWG_M8190A_SignalUpload_ChannelSelect_FixedAvgPower(ComplexSignal, Fcarrier_array, FsampleTx_array, DAC_SamplingRate, Amp_Corr, false,RF_channel,Expansion_Margin, PAPR_input, PAPR_original);
        AWG_M8190A_Reference_Clk('External',10e6);
        AWG_M8190A_DAC_Amplitude(RF_channel,VFS);
        AWG_M8190A_MKR_Amplitude(RF_channel,1.2);
        AWG_M8190A_Output_OFF(RF_channel);
        
        %         RF_ON_Continue    = 0;
        [RF_ON_Continue]  = PushButton_Routine (keep_RF_ON,Transmitter_type,ESGAdd,RF_channel);
        if strcmp(Receiver_type, 'Digitizer')
            if (DownconversionMode == 2)
                if Automate_LO == 1
                    if strcmp(LO2_type,'E4433B')
                        E4433B_RF_Configuration (LO_Frequency2, LO_Amplitude, E4433B_Add);
                        E4433B_RF_ON (E4433B_Add);
                    elseif strcmp(LO2_type,'E4438C')
                        E4438C_Signal_Configuration(E4438C_Obj, LO_Frequency2, LO_Amplitude);
                        E4438C_Output_Enable(E4438C_Obj, 1);
                    end
                end
            end
            if (DownconversionMode == 1) || (DownconversionMode == 2)
                if Automate_LO == 1
                    if strcmp(LO_type,'E4433B')
                        E4433B_RF_Configuration (LO_Frequency1, LO_Amplitude, E4433B_Add);
                        E4433B_RF_ON (E4433B_Add);
                    elseif strcmp(LO_type,'E4438C')
                        E4438C_Signal_Configuration(E4438C_Obj, LO_Frequency1, LO_Amplitude);
                        E4438C_Output_Enable(E4438C_Obj, 1);
                    end
                end
            end
        end
        AWG_M8190A_Output_ON(RF_channel);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Downloading the output
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(Receiver_type, 'Digitizer')
        %% Signal Acquisition
        GainValue = M9352A_Gain_value;
        M9352A_Gain(M9352A_Obj, AmpChannel, GainValue);
        M9703A_DDC_Configuration(M9703A_Obj, Channel, 0, 0);
        pause(2);
        %% Download the complete signal at the input of the digitizer to check if it is overloaded
        [WaveformArray0] = M9703A_Acquisition(M9703A_Obj, Channel, floor(FramTime*Digitizer_SamplingFrequency) + 1, Digitizer_SamplingFrequency, FullScaleRange, ACDCCoupling);
        if (DownconversionEnabled == 1)
            DownconversionFrequency1=IF_Frequency;
            M9703A_DDC_Configuration(M9703A_Obj, Channel, DownconversionEnabled, DownconversionFrequency1);
            pause(2);
            [WaveformArray1] = M9703A_Acquisition(M9703A_Obj, Channel, PointsPerRecord, DDC_SamplingFrequency, FullScaleRange, ACDCCoupling);
        end
        if strcmp(Transmitter_type,'AWG')
            AWG_M8190A_Output_OFF(RF_channel);
        elseif strcmp(Transmitter_type,'ESG')
            ESG_RF_OFF_SingleCarrier(ESGAdd);
        end
        
        if (DownconversionMode == 1) || (DownconversionMode == 2)
            if Automate_LO == 1
                if strcmp(LO_type,'E4433B')
                    E4433B_RF_OFF (E4433B_Add);
                elseif strcmp(LO_type,'E4438C')
                    E4438C_Output_Enable(E4438C_Obj, 0);
                end
            end
        end
        if (DownconversionMode == 2)
            if Automate_LO == 1
                if strcmp(LO2_type,'E4433B')
                    %                 E4433B_RF_Configuration (LO_Frequency2, LO_Amplitude, E4433B_Add);
                    E4433B_RF_OFF (E4433B_Add);
                elseif strcmp(LO2_type,'E4438C')
                    %                 E4438C_Signal_Configuration(E4438C_Obj, LO_Frequency2, LO_Amplitude);
                    E4438C_Output_Enable(E4438C_Obj, 0);
                end
            end
        end
        %% Signal Extraction
        if (DownconversionEnabled == 1)
            RecI=WaveformArray1(1:2:end-1);
            RecQ=WaveformArray1(1+1:2:end);
            ResampledRecI=resample(RecI,DownSampleRx,UpSampleRx).';
            ResampledRecQ=resample(RecQ,DownSampleRx,UpSampleRx).';
            if LO_Frequency1 > Fcarrier
                aux = ResampledRecI;
                ResampledRecI = ResampledRecQ;
                ResampledRecQ = aux;
            end
        elseif (DownconversionMode == 1) || (DownconversionMode == 2)
            time_IQ = [0:1/Digitizer_SamplingFrequency:FramTime];
            IQ_data = WaveformArray0.*exp(1i*2*pi*IF_Frequency*time_IQ);
            RecI=filter(FIR_filter_num, [1 0],(real(IQ_data)));
            RecQ=filter(FIR_filter_num, [1 0],(imag(IQ_data)));
            ResampledRecI=resample(RecI,DownSampleDigitizer,UpSampleDigitizer).';
            ResampledRecQ=resample(RecQ,DownSampleDigitizer,UpSampleDigitizer).';
            %             if LO_Frequency1 > Fcarrier
            %                 aux = ResampledRecI;
            %                 ResampledRecI = ResampledRecQ;
            %                 ResampledRecQ = aux;
            %             end
        elseif (DownconversionMode == 0)
            IF_Frequency0 = Digitizer_SamplingFrequency - Fcarrier;
            time_IQ = [0:1/Digitizer_SamplingFrequency:FramTime];
            teta0 = -1.5;
            WaveformArray0_temp = WaveformArray0 + 0*6.5e-5*exp(1i*2*pi*250e6*time_IQ + 1i*teta0);
            [freq, spectrum1] = Calculated_Spectrum_Real(WaveformArray0_temp,1e9);
            IQ_data = WaveformArray0.*exp(1i*2*pi*IF_Frequency0*time_IQ);
            RecI=filter(FIR_filter_num, [1 0],(real(IQ_data)));
            RecQ=filter(FIR_filter_num, [1 0],(imag(IQ_data)));
            ResampledRecI=resample(RecI,DownSampleDigitizer,UpSampleDigitizer).';
            ResampledRecQ=resample(RecQ,DownSampleDigitizer,UpSampleDigitizer).';
        end
    elseif strcmp(Receiver_type, 'PXA')
        [RecI_captured, RecQ_captured] = IQCapture_with_atten (Fcarrier, FsampleRx, FramTime, PXAAdd, PXA_Atten);
        ResampledRecI = RecI_captured(200:end);
        ResampledRecQ = RecQ_captured(200:end);
        if strcmp(Transmitter_type,'AWG')
            AWG_M8190A_Output_OFF(RF_channel);
        elseif strcmp(Transmitter_type,'ESG')
            ESG_RF_OFF_SingleCarrier(ESGAdd)
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Delay Adjustment and analyzing the signal
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    In_I = resample(In_I,UpSampleTx,DownSampleTx);
    In_Q = resample(In_Q,UpSampleTx,DownSampleTx);
    
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp([' Input Signal']);
    checkPower(In_I, In_Q,1);
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp([' Output Signal']);
    checkPower(ResampledRecI, ResampledRecQ,1);
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    
    [In_I, In_Q, ResampledRecI, ResampledRecQ]  = AdjustPowerAndPhase(In_I, In_Q, ResampledRecI, ResampledRecQ, 0);
    [In_I, In_Q, out_I1, out_Q1]                = UnifyLength(In_I, In_Q, ResampledRecI, ResampledRecQ, data_length - 200);
    
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, timedelay1] = AdjustDelay(In_I, In_Q, out_I1, out_Q1,Fs,2000) ;
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;
    PlotGain(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
    PlotAMPM(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
    PlotSpectrum(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
    
    [EVM_dB, EVM_perc] = EVM_calculate (DelayAdjusted_In_I,DelayAdjusted_In_Q,DelayAdjusted_Out_I,DelayAdjusted_Out_Q);
    [freq, spectrum] = Calculated_Spectrum(DelayAdjusted_Out_I,DelayAdjusted_Out_Q,Fs);
    [ACLR_L, ACLR_U] = Calculate_ACLR (freq, spectrum, 0, BW, fG);
    [ACPR_L, ACPR_U] = Calculate_ACPR (freq, spectrum, 0, BW, fG);
    
    [DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM, timedelay_EVM]   = AdjustDelay(In_I_beforeDPD_EVM(mem_truncate+1:end), In_Q_beforeDPD_EVM((mem_truncate+1:end)), out_I1, out_Q1,Fs,2000) ;
    [DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM]                     = AdjustPowerAndPhase(DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM, 0) ;
    PlotGain(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
    PlotAMPM(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
    PlotSpectrum(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
    
    [EVM_dB, EVM_perc] = EVM_calculate (DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM);
    
    display([ 'EVM          = ' num2str(EVM_perc)      ' % ' ]);
    display([ 'ACLR (L/U)   = ' num2str(ACLR_L) ' / '  num2str(ACLR_U) ' dB ' ]);
    display([ 'ACPR (L/U)   = ' num2str(ACPR_L) ' / '  num2str(ACPR_U) ' dB ' ]);
    
    [next_iteration, keep_RF_ON]  = ContinueIteration_Routine;
    if (next_iteration == 0)
        In_I = resample(In_I,DownSampleTx,UpSampleTx);
        In_Q = resample(In_Q,DownSampleTx,UpSampleTx);
        break
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% DPD Identification and Validation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch DPD_type
        case 'Volterra_DDR'
            clear iqdata iqtotaldata
            DPD = true ;
            %         [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput ] = VolterraDpdIdentification ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , VolterraParameters , NofDPDPoints , DPD ) ;
            VolterraParameters.NSupply = 1 ;
            DelayAdjusted_Vdd = abs(complex(DelayAdjusted_In_I, DelayAdjusted_In_Q));
            [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput, NMSE_error ] = VolterraDpdIdentification_ET ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , circshift(DelayAdjusted_Vdd,0), VolterraParameters , NofDPDPoints , DPD ) ;
            Coeff_DR_real = 20*log10( (max(abs(real(VolterraCoeff))))/(min(abs(real(VolterraCoeff)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(VolterraCoeff))))/(min(abs(imag(VolterraCoeff)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
            num_of_coeff = size(VolterraCoeff,1);
        case 'Volterra_DDR_ET'
            Vdd_shift = 0;
            DPD = true ;
            [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput ] = VolterraDpdIdentification_ET ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , circshift(DelayAdjusted_Vdd,Vdd_shift), VolterraParameters , NofDPDPoints , DPD ) ;
        case 'Volterra_DDR_Aug'
            DPD = true ;
            [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput ] = VolterraDpdIdentification_Aug ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , VolterraParameters , NofDPDPoints , DPD ) ;
        case 'RF_Volterra'
            DelayAdjusted_Vdd = abs(complex(DelayAdjusted_In_I, DelayAdjusted_In_Q));
            [Coeff_RF_Volterra, NMSE_error]=Identify_RF_Volterra_v2_ET(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I , DelayAdjusted_Out_Q ,DelayAdjusted_Vdd, RF_Volterra_Parameters , Fs, NofDPDPoints );
        case 'MP'
            [MP_coefficients, NMSE_error, Cond_A] = Identify_SingleBand_MP(MP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_real = 20*log10( (max(abs(real(MP_coefficients))))/(min(abs(real(MP_coefficients)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(MP_coefficients))))/(min(abs(imag(MP_coefficients)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
        case 'APD'
            [APD_coefficients, NMSE_error] = Identify_SingleBand_APD(APD_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_real = 20*log10( (max(abs(real(APD_coefficients))))/(min(abs(real(APD_coefficients)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(APD_coefficients))))/(min(abs(imag(APD_coefficients)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
        case 'FIR_APD'
            [FIR_APD_coefficients, NMSE_error] = Identify_SingleBand_FIR_APD(FIR_APD_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_real = 20*log10( (max(abs(real(FIR_APD_coefficients))))/(min(abs(real(FIR_APD_coefficients)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(FIR_APD_coefficients))))/(min(abs(imag(FIR_APD_coefficients)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
            if FIR_APD_modelParam.use_NL == 1
                NonlinearID_In_I = DelayAdjusted_In_I;
                NonlinearID_In_Q = DelayAdjusted_In_Q;
                NonlinearID_Out_I = DelayAdjusted_Out_I;
                NonlinearID_Out_Q = DelayAdjusted_Out_Q;
                %                 [NL_FIR_DPD_coefficients, NL_NMSE_error] = Identify_SingleBand_Cascaded_NLTB(FIR_DPD_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints, FIR_DPD_coefficients);
            end
        case 'TwoStep_MP'
            [MP_coefficients, NMSE_error, Cond_A] = Identify_TwoStep_SingleBand_MP(MP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_real = 20*log10( (max(abs(real(MP_coefficients))))/(min(abs(real(MP_coefficients)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(MP_coefficients))))/(min(abs(imag(MP_coefficients)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
        case 'Aug_MP'
            [MP_coefficients, gamma, fval, exitflag, NMSE_error, Cond_A] = Identify_SingleBand_Aug_MP(MP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_real = 20*log10( (max(abs(real(MP_coefficients))))/(min(abs(real(MP_coefficients)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(MP_coefficients))))/(min(abs(imag(MP_coefficients)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
        case 'RFMP_ADRF'
            if RFMP_modelParam.useNL == 0
                [num_coeff, den_coeff, NMSE_error, Cond_A, real_zeros, imag_zeros, comp_zeros] = Identify_SingleBand_RFMP(RFMP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            elseif RFMP_modelParam.useNL == 1
                params.MaxFunEval = 40000;
                params.MaxIter = 40000;
                params.TolFun = 1e-6;
                [num_coeff, den_coeff, NMSE_error, real_zeros, imag_zeros, comp_zeros] = Identify_SingleBand_RFMP_NL(RFMP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints, params);            
            end
            Coeff_DR_num_real = 20*log10( (max(abs(real(num_coeff))))/(min(abs(real(num_coeff)))));
            Coeff_DR_num_imag = 20*log10( (max(abs(imag(num_coeff))))/(min(abs(imag(num_coeff)))));
            Coeff_DR_num = max(Coeff_DR_num_real,Coeff_DR_num_imag);
            Coeff_DR_den_real = 20*log10( (max(abs(real(den_coeff))))/(min(abs(real(den_coeff)))));
            Coeff_DR_den_imag = 20*log10( (max(abs(imag(den_coeff))))/(min(abs(imag(den_coeff)))));
            Coeff_DR_den = max(Coeff_DR_den_real,Coeff_DR_den_imag);
            Coeff_DR = max(Coeff_DR_den, Coeff_DR_num);
        case 'RFMP_DRF_MFOD'
            if RFMP_modelParam.useNL == 0
                [num_coeff, den_coeff, NMSE_error, Cond_A, real_zeros, imag_zeros, comp_zeros] = Identify_SingleBand_RFMP(RFMP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            elseif RFMP_modelParam.useNL == 1
                params.MaxFunEval = 40000;
                params.MaxIter = 40000;
                params.TolFun = 1e-6;
                [num_coeff, den_coeff, NMSE_error, real_zeros, imag_zeros, comp_zeros] = Identify_SingleBand_RFMP_NL(RFMP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints, params);            
            end
            Coeff_DR_num_real = 20*log10( (max(abs(real(num_coeff))))/(min(abs(real(num_coeff)))));
            Coeff_DR_num_imag = 20*log10( (max(abs(imag(num_coeff))))/(min(abs(imag(num_coeff)))));
            Coeff_DR_num = max(Coeff_DR_num_real,Coeff_DR_num_imag);
            Coeff_DR_den_real = 20*log10( (max(abs(real(den_coeff))))/(min(abs(real(den_coeff)))));
            Coeff_DR_den_imag = 20*log10( (max(abs(imag(den_coeff))))/(min(abs(imag(den_coeff)))));
            Coeff_DR_den = max(Coeff_DR_den_real,Coeff_DR_den_imag);
            Coeff_DR = max(Coeff_DR_den, Coeff_DR_num);
        case 'RF_Volterra_ET'
            DelayAdjusted_Vdd = abs(complex(DelayAdjusted_In_I, DelayAdjusted_In_Q));
            [Coeff_RF_Volterra]=Identify_RF_Volterra_ET(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I , DelayAdjusted_Out_Q , DelayAdjusted_Vdd, RF_Volterra_Parameters , Fs, NofDPDPoints );
            %         [Coeff_RF_Volterra]=Identify_RF_Volterra_v2_ET(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I , DelayAdjusted_Out_Q , DelayAdjusted_Vdd, RF_Volterra_Parameters , Fs, NofDPDPoints );
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Apply DPD
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch DPD_type
        case 'Volterra_DDR'
            [Pr_I, Pr_Q] = VolterraDpdApply_ET(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, abs(complex(In_I_beforeDPD_EVM,In_Q_beforeDPD_EVM)), VolterraETParameters, VolterraCoeff) ;
        case 'Volterra_DDR_ET'
            [Pr_I, Pr_Q] = VolterraDpdApply_ET(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, Vdd_beforeDPD, VolterraETParameters, VolterraCoeff) ;
        case 'RF_Volterra'
            [Pr_I, Pr_Q] = Apply_RF_Volterra_v2_ET(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, abs(complex(In_I_beforeDPD_EVM,In_Q_beforeDPD_EVM)), Coeff_RF_Volterra, RF_Volterra_Parameters, Fs);
        case 'MP'
            [Pr_I, Pr_Q] = Apply_SingleBand_MP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, MP_modelParam, MP_coefficients);
        case 'APD'
            [Pr_I, Pr_Q] = Apply_SingleBand_APD(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, APD_modelParam, APD_coefficients);
        case 'FIR_APD'
            [Pr_I, Pr_Q] = Apply_SingleBand_FIR_APD(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, FIR_APD_modelParam, FIR_APD_coefficients);
        case 'Aug_MP'
            [Pr_I, Pr_Q] = Apply_SingleBand_Aug_MP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, MP_modelParam, MP_coefficients, gamma);
        case 'RFMP_ADRF'
            [Pr_I, Pr_Q] = Apply_SingleBand_RFMP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, RFMP_modelParam, num_coeff, den_coeff, real_zeros, imag_zeros, comp_zeros);
        case 'RFMP_DRF_MFOD'
            [Pr_I, Pr_Q] = Apply_SingleBand_RFMP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, RFMP_modelParam, num_coeff, den_coeff, real_zeros, imag_zeros, comp_zeros);
        case 'RF_Volterra_ET'
            [Pr_I, Pr_Q] = Apply_RF_Volterra_v2_ET(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, DelayAdjusted_Vdd_beforeDPD, Coeff_RF_Volterra, RF_Volterra_Parameters, Fs);
    end
    % new code
    mem_truncate = length(In_I_beforeDPD_EVM) - length(Pr_I);
    
    Pr_I_up=resample(Pr_I,DownSampleTx,UpSampleTx);
    Pr_Q_up=resample(Pr_Q,DownSampleTx,UpSampleTx);
    
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp([' Predistorted Signal']);
    checkPower(Pr_I_up, Pr_Q_up,1);
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    
    Draw_spectrum (In_I_beforeDPD,In_I_beforeDPD,Pr_I_up,Pr_Q_up);
    In_I = Pr_I_up;
    In_Q = Pr_Q_up;
    close all;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Final "With DPD" Measurements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' Final DPD measurement with DPD');
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

In_I_withDPD = In_I;
In_Q_withDPD = In_Q;

In_I_cal = In_I_withDPD; In_Q_cal = In_Q_withDPD;

SignalName                        = [WaveformName, 'WithDPD'];
[In_I_cal, In_Q_cal]              = setMeanPower(In_I_cal, In_Q_cal, PowerBand);  % Set the mean power of the I/Q signals to be uploaded
[In_I, In_Q]                      = setMeanPower(In_I, In_Q, 0);                      % Set the mean power of the I/Q signals to be used for DPD
[meanPower, maxPower, PAPR_input] = checkPower(In_I_cal, In_Q_cal, 1) ;           % Check the PAPR of the input file to be uploaded to the transmitter
ComplexSignal{1}                  = complex(In_I_cal, In_Q_cal);
Fcarrier_array{1}                 = Fcarrier ;
FsampleTx_array{1}                = FsampleTx ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Uploading the signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Transmitter_type,'ESG')
    ESG_RF_OFF_SingleCarrier(ESGAdd);
    IQUpload_Singleband ( In_I_cal', In_Q_cal', PowerBand,  Fcarrier, FsampleTx, ESGAdd, SignalName,data_length);
    
    %     RF_ON_Continue    = 0;
    %     [RF_ON_Continue]  = PushButton_Routine (keep_RF_ON,Transmitter_type,ESGAdd,RF_channel);
    
    ESG_RF_ON_SingleCarrier(ESGAdd);
    
elseif strcmp(Transmitter_type,'AWG')
    AWG_M8190A_SignalUpload_ChannelSelect_FixedAvgPower(ComplexSignal, Fcarrier_array, FsampleTx_array, DAC_SamplingRate, Amp_Corr, false,RF_channel,Expansion_Margin, PAPR_input, PAPR_original);
    AWG_M8190A_Reference_Clk('External',10e6);
    AWG_M8190A_DAC_Amplitude(RF_channel,VFS);
    AWG_M8190A_MKR_Amplitude(RF_channel,1.2);
    AWG_M8190A_Output_OFF(RF_channel);
    
    %     RF_ON_Continue    = 0;
    %     [RF_ON_Continue]  = PushButton_Routine (keep_RF_ON,Transmitter_type,ESGAdd,RF_channel);
    if strcmp(Receiver_type, 'Digitizer')
        if (DownconversionMode == 2)
            if Automate_LO == 1
                if strcmp(LO2_type,'E4433B')
                    E4433B_RF_Configuration (LO_Frequency2, LO_Amplitude, E4433B_Add);
                    E4433B_RF_ON (E4433B_Add);
                elseif strcmp(LO2_type,'E4438C')
                    E4438C_Signal_Configuration(E4438C_Obj, LO_Frequency2, LO_Amplitude);
                    E4438C_Output_Enable(E4438C_Obj, 1);
                end
            end
        end
        if (DownconversionMode == 1) || (DownconversionMode == 2)
            if Automate_LO == 1
                if strcmp(LO_type,'E4433B')
                    E4433B_RF_Configuration (LO_Frequency1, LO_Amplitude, E4433B_Add);
                    E4433B_RF_ON (E4433B_Add);
                elseif strcmp(LO_type,'E4438C')
                    E4438C_Signal_Configuration(E4438C_Obj, LO_Frequency1, LO_Amplitude);
                    E4438C_Output_Enable(E4438C_Obj, 1);
                end
            end
        end
    end
    AWG_M8190A_Output_ON(RF_channel);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Downloading the output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Receiver_type, 'Digitizer')
    %% Signal Acquisition
    GainValue=M9352A_Gain_value;
    M9352A_Gain(M9352A_Obj, AmpChannel, GainValue);
    M9703A_DDC_Configuration(M9703A_Obj, Channel, 0, 0);
    pause(2);
    [WaveformArray0] = M9703A_Acquisition(M9703A_Obj, Channel, floor(FramTime*Digitizer_SamplingFrequency) + 1, Digitizer_SamplingFrequency, FullScaleRange, ACDCCoupling);
    if (DownconversionEnabled == 1)
        DownconversionFrequency1=IF_Frequency;
        M9703A_DDC_Configuration(M9703A_Obj, Channel, DownconversionEnabled, DownconversionFrequency1);
        pause(2);
        [WaveformArray1] = M9703A_Acquisition(M9703A_Obj, Channel, PointsPerRecord, DDC_SamplingFrequency, FullScaleRange, ACDCCoupling);
    end
    if strcmp(Transmitter_type,'AWG')
        AWG_M8190A_Output_OFF(RF_channel);
    elseif strcmp(Transmitter_type,'ESG')
        ESG_RF_OFF_SingleCarrier(ESGAdd);
    end
    if (DownconversionMode == 1) || (DownconversionMode == 2)
        if Automate_LO == 1
            if strcmp(LO_type,'E4433B')
                E4433B_RF_OFF (E4433B_Add);
            elseif strcmp(LO_type,'E4438C')
                E4438C_Output_Enable(E4438C_Obj, 0);
            end
        end
    end
    if (DownconversionMode == 2)
        if Automate_LO == 1
            if strcmp(LO2_type,'E4433B')
                %                 E4433B_RF_Configuration (LO_Frequency2, LO_Amplitude, E4433B_Add);
                E4433B_RF_OFF (E4433B_Add);
            elseif strcmp(LO2_type,'E4438C')
                %                 E4438C_Signal_Configuration(E4438C_Obj, LO_Frequency2, LO_Amplitude);
                E4438C_Output_Enable(E4438C_Obj, 0);
            end
        end
    end
    %% Signal Extraction
    if (DownconversionEnabled == 1)
        RecI=WaveformArray1(1:2:end-1);
        RecQ=WaveformArray1(1+1:2:end);
        ResampledRecI=resample(RecI,DownSampleRx,UpSampleRx).';
        ResampledRecQ=resample(RecQ,DownSampleRx,UpSampleRx).';
        if LO_Frequency1 > Fcarrier
            aux = ResampledRecI;
            ResampledRecI = ResampledRecQ;
            ResampledRecQ = aux;
        end
    elseif (DownconversionMode == 1) || (DownconversionMode == 2)
        time_IQ = [0:1/Digitizer_SamplingFrequency:FramTime];
        IQ_data = WaveformArray0.*exp(1i*2*pi*IF_Frequency*time_IQ);
        RecI=filter(FIR_filter_num, [1 0],(real(IQ_data)));
        RecQ=filter(FIR_filter_num, [1 0],(imag(IQ_data)));
        ResampledRecI=resample(RecI,DownSampleDigitizer,UpSampleDigitizer).';
        ResampledRecQ=resample(RecQ,DownSampleDigitizer,UpSampleDigitizer).';
        %             if LO_Frequency1 > Fcarrier
        %                 aux = ResampledRecI;
        %                 ResampledRecI = ResampledRecQ;
        %                 ResampledRecQ = aux;
        %             end
    elseif (DownconversionMode == 0)
        IF_Frequency0 = Digitizer_SamplingFrequency - Fcarrier;
        time_IQ = [0:1/Digitizer_SamplingFrequency:FramTime];
        teta0 = -1.5;
        WaveformArray0_temp = WaveformArray0 + 0*6.5e-5*exp(1i*2*pi*250e6*time_IQ + 1i*teta0);
        [freq, spectrum1] = Calculated_Spectrum_Real(WaveformArray0_temp,1e9);
        IQ_data = WaveformArray0.*exp(1i*2*pi*IF_Frequency0*time_IQ);
        RecI=filter(FIR_filter_num, [1 0],(real(IQ_data)));
        RecQ=filter(FIR_filter_num, [1 0],(imag(IQ_data)));
        ResampledRecI=resample(RecI,DownSampleDigitizer,UpSampleDigitizer).';
        ResampledRecQ=resample(RecQ,DownSampleDigitizer,UpSampleDigitizer).';
    end
elseif strcmp(Receiver_type, 'PXA')
    [RecI_captured, RecQ_captured] = IQCapture_with_atten (Fcarrier, FsampleRx, FramTime, PXAAdd, PXA_Atten);
    ResampledRecI = RecI_captured(200:end);
    ResampledRecQ = RecQ_captured(200:end);
    if strcmp(Transmitter_type,'AWG')
        AWG_M8190A_Output_OFF(RF_channel);
    elseif strcmp(Transmitter_type,'ESG')
        ESG_RF_OFF_SingleCarrier(ESGAdd)
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Delay Adjustment and analyzing the signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
In_I_withDPD = resample(In_I_withDPD,UpSampleTx,DownSampleTx);
In_Q_withDPD = resample(In_Q_withDPD,UpSampleTx,DownSampleTx);

disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp([' Input Signal']);
checkPower(In_I_withDPD, In_Q_withDPD,1);
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp([' Output Signal']);
checkPower(ResampledRecI, ResampledRecQ,1);
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

[In_I_withDPD, In_Q_withDPD, ResampledRecI, ResampledRecQ]                                     = AdjustPowerAndPhase(In_I_withDPD, In_Q_withDPD, ResampledRecI, ResampledRecQ, 0) ;
[In_I_withDPD, In_Q_withDPD, Out_I_withDPD, Out_Q_withDPD]                                     = UnifyLength(In_I_withDPD, In_Q_withDPD, ResampledRecI, ResampledRecQ, data_length - 200) ;
[DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, timedelay1] = AdjustDelay(In_I_withDPD, In_Q_withDPD, Out_I_withDPD, Out_Q_withDPD,Fs,2000) ;
[DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;

PlotGain(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
PlotAMPM(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
PlotSpectrum(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;

[EVM_dB, EVM_perc]                = EVM_calculate (DelayAdjusted_In_I,DelayAdjusted_In_Q,DelayAdjusted_Out_I,DelayAdjusted_Out_Q);
[freq, spectrum]                 = Calculated_Spectrum(Out_I_withDPD,Out_Q_withDPD,Fs);
[freq, spectrum]                 = Calculated_Spectrum(DelayAdjusted_Out_I,DelayAdjusted_Out_Q,Fs);
[ACLR_L_withDPD, ACLR_U_withDPD] = Calculate_ACLR (freq, spectrum, 0, BW, fG);
[ACPR_L_withDPD, ACPR_U_withDPD] = Calculate_ACPR (freq, spectrum, 0, BW, fG);

[DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM, timedelay_EVM]   = AdjustDelay(In_I_beforeDPD_EVM(mem_truncate+1:end), In_Q_beforeDPD_EVM((mem_truncate+1:end)), Out_I_withDPD, Out_Q_withDPD,Fs,2000) ;
[DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM]                = AdjustPowerAndPhase(DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM,0);

PlotGain(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
PlotAMPM(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
PlotSpectrum(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;

[EVM_dB_withDPD, EVM_perc_withDPD] = EVM_calculate (DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM);

display([ ' EVM with DPD        = ' num2str(EVM_perc_withDPD)      ' % ' ]);
display([ ' ACLR (L/U) with DPD = ' num2str(ACLR_L_withDPD) ' / '  num2str(ACLR_U_withDPD) ' dB ' ]);
display([ ' ACPR (L/U) with DPD = ' num2str(ACPR_L_withDPD) ' / '  num2str(ACPR_U_withDPD) ' dB ' ]);

[meanPower, maxPower, PAPRin_withDPD]  = checkPower(In_I_withDPD,In_Q_withDPD,0);
[meanPower, maxPower, PAPRout_withDPD] = checkPower(Out_I_withDPD,Out_Q_withDPD,0);

disp(  ' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp([ ' Input PAPR with DPD     = ' num2str(PAPRin_withDPD)  ' dB ' ]);
disp([ ' Output PAPR with DPD    = ' num2str(PAPRout_withDPD) ' dB ' ]);
disp(  ' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Saving Measurement Results - With DPD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Making measurement directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd([pwd '\Measurements']);
time_now = clock;
dir_name = strcat('Measurement',date,'_',int2str(time_now(4)),'_',int2str(time_now(5)),'_',int2str(time_now(6)));
mkdir(dir_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Writing files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(dir_name)
%%%% Input signal before DPD
fidIEH = fopen(['I_Input_NoDPD_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',In_I_beforeDPD_EVM);
fclose(fidIEH);
fidIEH = fopen(['Q_Input_NoDPD_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',In_Q_beforeDPD_EVM);
fclose(fidIEH);
%%%% PreDistorted Input
fidIEH = fopen(['I_Input_PreDist_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',In_I_withDPD);
fclose(fidIEH);
fidIEH = fopen(['Q_Input_PreDist_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',In_Q_withDPD);
fclose(fidIEH);
%%%% Output with DPD
fidIEH = fopen(['I_Output_WithDPD_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',Out_I_withDPD);
fclose(fidIEH);
fidIEH = fopen(['Q_Output_WithDPD_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',Out_Q_withDPD);
fclose(fidIEH);
cd ..
cd ..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear In_Q_withDPD In_I_withDPD Out_I_withDPD Out_Q_withDPD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Final "Without DPD" Measurements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' Without DPD measurement');
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

In_I_withoutDPD = In_I_beforeDPD;
In_Q_withoutDPD = In_Q_beforeDPD;

In_I_cal = In_I_withoutDPD; In_Q_cal = In_Q_withoutDPD;

SignalName                        = [WaveformName, 'WithoutDPD'];
[In_I_cal, In_Q_cal]              = setMeanPower(In_I_cal, In_Q_cal, PowerBand);        % Set the mean power of the I/Q signals to be uploaded
[In_I, In_Q]                      = setMeanPower(In_I, In_Q, 0);                      % Set the mean power of the I/Q signals to be used for DPD
[meanPower, maxPower, PAPR_input] = checkPower(In_I_cal, In_Q_cal, 1) ;                 % Check the PAPR of the input file to be uploaded to the transmitter
ComplexSignal{1}                  = complex(In_I_cal, In_Q_cal);
Fcarrier_array{1}                 = Fcarrier ;
FsampleTx_array{1}                = FsampleTx ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Uploading the signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Transmitter_type,'ESG')
    ESG_RF_OFF_SingleCarrier(ESGAdd);
    IQUpload_Singleband ( In_I_cal', In_Q_cal', PowerBand,  Fcarrier, FsampleTx, ESGAdd, SignalName,data_length);
    
    %     RF_ON_Continue    = 0;
    %     [RF_ON_Continue]  = PushButton_Routine (keep_RF_ON,Transmitter_type,ESGAdd,RF_channel);
    
    ESG_RF_ON_SingleCarrier(ESGAdd);
    
elseif strcmp(Transmitter_type,'AWG')
    AWG_M8190A_SignalUpload_ChannelSelect_FixedAvgPower(ComplexSignal, Fcarrier_array, FsampleTx_array, DAC_SamplingRate, Amp_Corr, false,RF_channel,Expansion_Margin, PAPR_input, PAPR_original);
    AWG_M8190A_Reference_Clk('External',10e6);
    AWG_M8190A_DAC_Amplitude(RF_channel,VFS);
    AWG_M8190A_MKR_Amplitude(RF_channel,1.2);
    AWG_M8190A_Output_OFF(RF_channel);
    
    %     RF_ON_Continue    = 0;
    %     [RF_ON_Continue]  = PushButton_Routine (keep_RF_ON,Transmitter_type,ESGAdd,RF_channel);
    if strcmp(Receiver_type, 'Digitizer')
        if (DownconversionMode == 2)
            if Automate_LO == 1
                if strcmp(LO2_type,'E4433B')
                    E4433B_RF_Configuration (LO_Frequency2, LO_Amplitude, E4433B_Add);
                    E4433B_RF_ON (E4433B_Add);
                elseif strcmp(LO2_type,'E4438C')
                    E4438C_Signal_Configuration(E4438C_Obj, LO_Frequency2, LO_Amplitude);
                    E4438C_Output_Enable(E4438C_Obj, 1);
                end
            end
        end
        if (DownconversionMode == 1) || (DownconversionMode == 2)
            if Automate_LO == 1
                if strcmp(LO_type,'E4433B')
                    E4433B_RF_Configuration (LO_Frequency1, LO_Amplitude, E4433B_Add);
                    E4433B_RF_ON (E4433B_Add);
                elseif strcmp(LO_type,'E4438C')
                    E4438C_Signal_Configuration(E4438C_Obj, LO_Frequency1, LO_Amplitude);
                    E4438C_Output_Enable(E4438C_Obj, 1);
                end
            end
        end
    end
    AWG_M8190A_Output_ON(RF_channel);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Downloading the output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Receiver_type, 'Digitizer')
    %% Signal Acquisition
    GainValue=M9352A_Gain_value;
    M9352A_Gain(M9352A_Obj, AmpChannel, GainValue);
    M9703A_DDC_Configuration(M9703A_Obj, Channel, 0, 0);
    pause(2);
    [WaveformArray0] = M9703A_Acquisition(M9703A_Obj, Channel, floor(FramTime*Digitizer_SamplingFrequency) + 1, Digitizer_SamplingFrequency, FullScaleRange, ACDCCoupling);
    if (DownconversionEnabled == 1)
        DownconversionFrequency1=IF_Frequency;
        M9703A_DDC_Configuration(M9703A_Obj, Channel, DownconversionEnabled, DownconversionFrequency1);
        pause(2);
        [WaveformArray1] = M9703A_Acquisition(M9703A_Obj, Channel, PointsPerRecord, DDC_SamplingFrequency, FullScaleRange, ACDCCoupling);
    end
    if strcmp(Transmitter_type,'AWG')
        AWG_M8190A_Output_OFF(RF_channel);
    elseif strcmp(Transmitter_type,'ESG')
        ESG_RF_OFF_SingleCarrier(ESGAdd);
    end
    if (DownconversionMode == 1) || (DownconversionMode == 2)
        if Automate_LO == 1
            if strcmp(LO_type,'E4433B')
                E4433B_RF_OFF (E4433B_Add);
            elseif strcmp(LO_type,'E4438C')
                E4438C_Output_Enable(E4438C_Obj, 0);
            end
        end
    end
    if (DownconversionMode == 2)
        if Automate_LO == 1
            if strcmp(LO2_type,'E4433B')
                %                 E4433B_RF_Configuration (LO_Frequency2, LO_Amplitude, E4433B_Add);
                E4433B_RF_OFF (E4433B_Add);
            elseif strcmp(LO2_type,'E4438C')
                %                 E4438C_Signal_Configuration(E4438C_Obj, LO_Frequency2, LO_Amplitude);
                E4438C_Output_Enable(E4438C_Obj, 0);
            end
        end
    end
    %% Signal Extraction
    if (DownconversionEnabled == 1)
        RecI=WaveformArray1(1:2:end-1);
        RecQ=WaveformArray1(1+1:2:end);
        ResampledRecI=resample(RecI,DownSampleRx,UpSampleRx).';
        ResampledRecQ=resample(RecQ,DownSampleRx,UpSampleRx).';
        if LO_Frequency1 > Fcarrier
            aux = ResampledRecI;
            ResampledRecI = ResampledRecQ;
            ResampledRecQ = aux;
        end
    elseif (DownconversionMode == 1) || (DownconversionMode == 2)
        time_IQ = [0:1/Digitizer_SamplingFrequency:FramTime];
        IQ_data = WaveformArray0.*exp(1i*2*pi*IF_Frequency*time_IQ);
        RecI=filter(FIR_filter_num, [1 0],(real(IQ_data)));
        RecQ=filter(FIR_filter_num, [1 0],(imag(IQ_data)));
        ResampledRecI=resample(RecI,DownSampleDigitizer,UpSampleDigitizer).';
        ResampledRecQ=resample(RecQ,DownSampleDigitizer,UpSampleDigitizer).';
        %             if LO_Frequency1 > Fcarrier
        %                 aux = ResampledRecI;
        %                 ResampledRecI = ResampledRecQ;
        %                 ResampledRecQ = aux;
        %             end
    elseif (DownconversionMode == 0)
        IF_Frequency0 = Digitizer_SamplingFrequency - Fcarrier;
        time_IQ = [0:1/Digitizer_SamplingFrequency:FramTime];
        teta0 = -1.5;
        WaveformArray0_temp = WaveformArray0 + 0*6.5e-5*exp(1i*2*pi*250e6*time_IQ + 1i*teta0);
        [freq, spectrum1] = Calculated_Spectrum_Real(WaveformArray0_temp,1e9);
        IQ_data = WaveformArray0.*exp(1i*2*pi*IF_Frequency0*time_IQ);
        RecI=filter(FIR_filter_num, [1 0],(real(IQ_data)));
        RecQ=filter(FIR_filter_num, [1 0],(imag(IQ_data)));
        ResampledRecI=resample(RecI,DownSampleDigitizer,UpSampleDigitizer).';
        ResampledRecQ=resample(RecQ,DownSampleDigitizer,UpSampleDigitizer).';
    end
elseif strcmp(Receiver_type, 'PXA')
    [RecI_captured, RecQ_captured] = IQCapture_with_atten (Fcarrier, FsampleRx, FramTime, PXAAdd, PXA_Atten);
    ResampledRecI = RecI_captured(200:end);
    ResampledRecQ = RecQ_captured(200:end);
    if strcmp(Transmitter_type,'AWG')
        AWG_M8190A_Output_OFF(RF_channel);
    elseif strcmp(Transmitter_type,'ESG')
        ESG_RF_OFF_SingleCarrier(ESGAdd)
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Delay Adjustment and analyzing the signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
In_I_withoutDPD = resample(In_I_withoutDPD,UpSampleTx,DownSampleTx);
In_Q_withoutDPD = resample(In_Q_withoutDPD,UpSampleTx,DownSampleTx);

disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp([' Input Signal']);
checkPower(In_I_withoutDPD, In_Q_withoutDPD,1);
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp([' Output Signal']);
checkPower(ResampledRecI, ResampledRecQ,1);
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

[In_I_withoutDPD,In_Q_withoutDPD,ResampledRecI,ResampledRecQ]                                   = AdjustPowerAndPhase(In_I_withoutDPD, In_Q_withoutDPD, ResampledRecI, ResampledRecQ, 0);
[In_I_withoutDPD,In_Q_withoutDPD,Out_I_withoutDPD,Out_Q_withoutDPD]                             = UnifyLength(In_I_withoutDPD, In_Q_withoutDPD, ResampledRecI, ResampledRecQ, data_length-200);
[DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, timedelay1]  = AdjustDelay(In_I_withoutDPD, In_Q_withoutDPD, Out_I_withoutDPD, Out_Q_withoutDPD,Fs,2000);
[DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]              = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0);

PlotGain(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
PlotAMPM(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
PlotSpectrum(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;

[EVM_dB, EVM_perc] = EVM_calculate (DelayAdjusted_In_I,DelayAdjusted_In_Q,DelayAdjusted_Out_I,DelayAdjusted_Out_Q);

[freq, spectrum]                        = Calculated_Spectrum(DelayAdjusted_Out_I,DelayAdjusted_Out_Q,Fs);
[ACLR_L_withoutDPD, ACLR_U_withoutDPD]  = Calculate_ACLR (freq, spectrum, 0, BW, fG);
[ACPR_L_withoutDPD, ACPR_U_withoutDPD]  = Calculate_ACPR (freq, spectrum, 0, BW, fG);

[DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM, timedelay_EVM] = AdjustDelay(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, Out_I_withoutDPD, Out_Q_withoutDPD,Fs,2000) ;
[DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM]                = AdjustPowerAndPhase(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM, 0) ;

PlotGain(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
PlotAMPM(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
PlotSpectrum(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;

[EVM_dB_withoutDPD, EVM_perc_withoutDPD] = EVM_calculate (DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM);

display([ 'EVM without DPD        = ' num2str(EVM_perc_withoutDPD)      ' % ' ]);
display([ 'ACLR (L/U) without DPD = ' num2str(ACLR_L_withoutDPD) ' / '  num2str(ACLR_U_withoutDPD) ' dB ' ]);
display([ 'ACPR (L/U) without DPD = ' num2str(ACPR_L_withoutDPD) ' / '  num2str(ACPR_U_withoutDPD) ' dB ' ]);

[meanPower, maxPower, PAPRin_withoutDPD] = checkPower(In_I_withoutDPD,In_Q_withoutDPD,0);
[meanPower, maxPower, PAPRout_withoutDPD] = checkPower(Out_I_withoutDPD,Out_Q_withoutDPD,0);

display([ 'Input PAPR without DPD   = ' num2str(PAPRin_withoutDPD) ' dB ' ]);
display([ 'Output PAPR without DPD  = ' num2str(PAPRout_withoutDPD) ' dB ' ]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Saving Measurement Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Writing files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd('Measurements')
cd(dir_name)
%%%% Output without DPD
fidIEH = fopen(['I_Output_WithoutDPD.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',Out_I_withoutDPD);
fclose(fidIEH);
fidIEH = fopen(['Q_Output_WithoutDPD.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',Out_Q_withoutDPD);
fclose(fidIEH);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Wirting Summary file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fidIEH = fopen(['Summary.txt'],'wt');
fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
fprintf(fidIEH,'Carrier Frequency = %4.3f GHz \n ',Fcarrier/1e9);
fprintf(fidIEH,'Signal BW = %4.3f MHz \n ',BW/1e6);
fprintf(fidIEH,['Signal Name (I) = ',InI_beforeDPD_path, '\n ']);
fprintf(fidIEH,['Signal Name (Q) = ',InQ_beforeDPD_path, '\n ']);
fprintf(fidIEH,'ESG/PSG Power = %4.3f \n ',PowerBand);
fprintf(fidIEH,'DPD sampling rate = %4.3f MHz \n ',Fs/1e6);
fprintf(fidIEH,'Internal Rx down/upsampling rate = %4.3f / %4.3f \n ',DownSampleRx,UpSampleRx);
fprintf(fidIEH,'Internal Tx down/upsampling rate = %4.3f / %4.3f \n ',DownSampleTx,UpSampleTx);
fprintf(fidIEH,'DPD Iteration = %4.3f \n ',IterationCount);

fprintf(fidIEH,'\nWithout DPD Results \n ');
fprintf(fidIEH,'EVM (%%) = %4.3f \n ',EVM_perc_withoutDPD);
fprintf(fidIEH,'ACLR_L/ACLR_U = %4.3f / %4.3f \n ',ACLR_L_withoutDPD,ACLR_U_withoutDPD);
fprintf(fidIEH,'ACPR_L/ACPR_U = %4.3f / %4.3f \n ',ACPR_L_withoutDPD,ACPR_U_withoutDPD);
fprintf(fidIEH,'PAPRin = %4.3f \n ',PAPRin_withoutDPD);
fprintf(fidIEH,'PAPRout = %4.3f \n ',PAPRout_withoutDPD);

fprintf(fidIEH,'\nWith DPD Results \n ');
fprintf(fidIEH,'EVM (%%) = %4.3f \n ',EVM_perc_withDPD);
fprintf(fidIEH,'ACLR_L/ACLR_U = %4.3f / %4.3f \n ',ACLR_L_withDPD,ACLR_U_withDPD);
fprintf(fidIEH,'ACPR_L/ACPR_U = %4.3f / %4.3f \n ',ACPR_L_withDPD,ACPR_U_withDPD);
fprintf(fidIEH,'PAPRin = %4.3f \n ',PAPRin_withDPD);
fprintf(fidIEH,'PAPRout = %4.3f \n ',PAPRout_withDPD);

fprintf(fidIEH,'\nModeling Performance \n ');
fprintf(fidIEH,'NMSE(dB) = %4.3f \n ',NMSE_error);

switch DPD_type
    case 'Aug_MP'
        fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
        fprintf(fidIEH,'NL = %4.3f \n ',MP_modelParam.N);
        fprintf(fidIEH,'M = %4.3f \n ',MP_modelParam.M);
        fprintf(fidIEH,['Type =  ',MP_modelParam.type, '\n ']);
        %     fprintf(fidIEH,'Gamma = %4.3f + i%4.3f \n ',real(gamma), imag(gamma));
        fprintf(fidIEH,'Gamma = %s \n ',num2str(gamma));
        fprintf(fidIEH,'Number of coefficients = %4.3f \n ', size(MP_coefficients,1))
        fprintf(fidIEH,'Coefficients DR = %4.3f \n ', Coeff_DR);
        fprintf(fidIEH,'Conditioning Number = %4.3f \n ', Cond_A);
    case 'RF_MP'
        fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
        fprintf(fidIEH,'NL_numerator = %4.3f \n ',RFMP_Param.n_num);
        fprintf(fidIEH,'M_numerator = %4.3f \n ',RFMP_Param.m_num);
        fprintf(fidIEH,['Type_numerator =  ',RFMP_Param.mod_num, '\n ']);
        fprintf(fidIEH,'Nbr. of num_coefficients = %4.3f \n ', size(num_coeff));
        fprintf(fidIEH,'NL_denominator = %4.3f \n ',RFMP_Param.n_den);
        fprintf(fidIEH,'M_denominator = %4.3f \n ',RFMP_Param.m_den);
        fprintf(fidIEH,['Type_denominator =  ',RFMP_Param.mod_den, '\n ']);
        fprintf(fidIEH,'Nbr. of den_coefficients = %4.3f \n ', size(den_coeff));
        fprintf(fidIEH,'Coefficients DR (Numerator) = %4.3f \n ', Coeff_DR_num);
        fprintf(fidIEH,'Coefficients DR (Denominator) = %4.3f \n ', Coeff_DR_den);
        fprintf(fidIEH,'Conditioning Number = %4.3f \n ', Cond_A);
    case 'RF_Volterra'
        fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
        fprintf(fidIEH,'Static NL = %4.3f \n ',RF_Volterra_Parameters.NL);
        fprintf(fidIEH,'M1 = %4.3f \n ',RF_Volterra_Parameters.M1);
        fprintf(fidIEH,'M3 = %4.3f \n ',RF_Volterra_Parameters.M3);
        fprintf(fidIEH,'M5 = %4.3f \n ',RF_Volterra_Parameters.M5);
        fprintf(fidIEH,'M7 = %4.3f \n ',RF_Volterra_Parameters.M7);
        fprintf(fidIEH,'Memory Lag = %4.3f \n ',RF_Volterra_Parameters.memory_lag);
    case 'Volterra_DDR'
        fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
        fprintf(fidIEH,'Static NL = %4.3f \n ',VolterraParameters.Static);
        fprintf(fidIEH,'Memory Orders = %4.3f, %4.3f, %4.3f, %4.3f, %4.3f \n ',VolterraParameters.Order(1), VolterraParameters.Order(2), VolterraParameters.Order(3), VolterraParameters.Order(4), VolterraParameters.Order(5));
        fprintf(fidIEH,'Number of coefficients = %4.3f \n ', num_of_coeff);
        fprintf(fidIEH,'Coefficients DR = %4.3f \n ', Coeff_DR);
    case 'MP'
        fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
        fprintf(fidIEH,'NL = %4.3f \n ',MP_modelParam.N);
        fprintf(fidIEH,'M = %4.3f \n ',MP_modelParam.M);
        fprintf(fidIEH,['Type = ',MP_modelParam.type,'\n ']);
        fprintf(fidIEH,'Number of coefficients = %4.3f \n ', size(MP_coefficients,1));
        fprintf(fidIEH,'Coefficients DR = %4.3f \n ', Coeff_DR);
        fprintf(fidIEH,'Conditioning Number = %4.3f \n ', Cond_A);
    case 'APD'
        fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
        fprintf(fidIEH,['Engine = ',APD_modelParam.engine,'\n ']);
        fprintf(fidIEH,'NL = %4.3f \n ',APD_modelParam.N);
        fprintf(fidIEH,'M = %4.3f \n ',APD_modelParam.M);
        fprintf(fidIEH,['Type = ',APD_modelParam.polyorder,'\n ']);
        fprintf(fidIEH,'Use two step identification = %4.3f \n ',APD_modelParam.two_step);
        fprintf(fidIEH,'Number of coefficients = %4.3f \n ', size(APD_coefficients,1));
        fprintf(fidIEH,'Coefficients DR = %4.3f \n ', Coeff_DR);
    case 'FIR_APD'
        fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
        fprintf(fidIEH,['Engine = ',FIR_APD_modelParam.engine,'\n ']);
        fprintf(fidIEH,'APD_NL = %4.3f \n ',FIR_APD_modelParam.APD_N);
        fprintf(fidIEH,'APD_M = %4.3f \n ',FIR_APD_modelParam.APD_M);
        fprintf(fidIEH,'FIR_M = %4.3f \n ',FIR_APD_modelParam.FIR_M);
        fprintf(fidIEH,['Type = ',FIR_APD_modelParam.polyorder,'\n ']);
        fprintf(fidIEH,'Use two step identification = %4.3f \n ',FIR_APD_modelParam.two_step);
        fprintf(fidIEH,'Number of coefficients = %4.3f \n ', size(FIR_APD_coefficients,1));
        fprintf(fidIEH,'Coefficients DR = %4.3f \n ', Coeff_DR);
end
fprintf(fidIEH,'\n');
fprintf(fidIEH,'\nPout   =        dBm');
fprintf(fidIEH,'\nVdd    = 28     V');
fprintf(fidIEH,'\nIdd    =        mA');
fprintf(fidIEH,'\nDE     =        %');
fprintf(fidIEH,'\nPAE    =        %');
fclose(fidIEH);
cd ..
cd ..

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Close Connection with Instrument
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Receiver_type,'Digitizer')
    M9703A_Obj.Close;
    M9352A_Obj.Close;
    if strcmp(LO_type,'E4438C') && Automate_LO == 1
        E4438C_Obj.Close;
    end
    % Turn LO OFF
    %Prompt user to turn LO OFF
    if Automate_LO == 0
        [Continue_Flag] = Confirmation_Dialogue('Is the LO Source turned OFF?','Turn OFF Prompt');
        if Continue_Flag == -1
            if strcmp(Receiver_type,'Digitizer')
                M9703A_Obj.Close;
                M9352A_Obj.Close;
            end
            error('User Abort');
        end
    end
end
