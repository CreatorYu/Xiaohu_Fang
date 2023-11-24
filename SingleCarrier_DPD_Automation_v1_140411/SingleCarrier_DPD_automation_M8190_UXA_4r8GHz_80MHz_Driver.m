clc
clear
close all

path(pathdef); % Resets the paths to remove paths outside this folder
path('C:\Documents\Xiaohu_Fang\MATLAB\CW_Automation_08_15_2017',path);
path('C:\Documents\Xiaohu_Fang\MATLAB\IQ_imbalance_cal_results',path);
path('C:\Documents\Xiaohu_Fang\EmRG_Code\TX_Calibration\Instrument_Functions\SignalCapture_UXA',path)
path('C:\Documents\Xiaohu_Fang\MATLAB',path)
addpath(genpath(pwd))%Automatically Adds all paths in directory and subfolders
addpath(genpath('C:\Documents\Xiaohu_Fang\MATLAB\Instrument_Functions'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set Signal Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Receiver_type     = 'UXA';  % 'PXA' or 'UXA' for the receiver
Transmitter_type  = 'AWG';  % Choose between 'AWG' and 'ESG' for the transmitter - In case of ESG you should use MATLAB 2009a!!!

p_sg=-32;
Fcarrier  = 4.8e9;       % Center frequency of the modulated signal
FramTime  = 0.128e-3;      % Total frame time for the modulated signal
PowerBand = 0;           % Power in dBm for ESG (In case of high speed AWG, the power is controlled using VFS)

Expansion_Margin = 0;           % Used for high speed AWG only. It is used to maintain the average power of AWG when the PAPR of the pre-distorted signal increases.
NofIteration     = 4;            % Maximum # of DPD Iterations
NofDPDPoints     = 10000;         % # of points used in DPD identification
DelayMethod      = 'CrossCorr';   % The method used to adjust the delay between the transmitted and received signal
WaveformName     = 'WCDMA4C';     % The waveform name - Only used when uploading signal to ESG

FsampleTx        = 400e6;         % The sampling rate of the I/Q input files - In 'ESG' mode the sampling clock of the ESG will be set to the same value       %to be linked to signal
FsampleRx        = 1000e6;         % The sampling rate of the receiver (max 160MHz)

Fsample_desired  = FsampleRx;     % The sampling rate of the DPD modeing. Fsample_desired < FsampleRx
Fs=Fsample_desired;               %

GainExpansion       = 'No';       % Expansion of the original input signal to take into account for the expansion of the DPD
GainExpansion_value = 2.0;        % Expansion of the original input in dB

Measure_Pout_Eff    = 'True';     % Set to 'True' to measure the average power and efficiency when making final DPD measurements
% DCSource_Add        = 5;          % GPIB address for the DC power source - N6705B

% GPIB address for everything 
SG=SignalGenerator_E8267D(19,-25);
PM = PowerMeter_N1911A(15);
PS_m = PowerSupply_N6705A(5);
PS_a = PowerSupply_F3643A(7);
ATN=Attenuator('Attenuator_Coupler_4_8GHz_2.s2p');

% Connection of everything
SG.connect;
PM.connect;
PS_m.connect;
PS_a.connect;
%
PM.preset;
%
PS_m_chan=1;
FsampleAWG            = 2e9; 
AWG_AutoNorm		  = false;   % choose weather to normalize IQ data sending to the DAC
AWG_Gain       = 0.5;    % between 0.35 - 0.5;
I_offset  = 0;
Q_offset = 0;
%
SG.frequency(Fcarrier);
PM.frequency(Fcarrier);
PM.offset(ATN.attenuation(Fcarrier)+0.5);
fprintf('Attenuation at %g Hz is %g dB\n', Fcarrier, ATN.attenuation(Fcarrier)+0.5);
    %PM.offset(0);
PM.zero_and_cal;

Amp_Corr = true;                  % amplitude correction for the AWG (set to true - recommended)
mem_truncate = 0;
keep_RF_ON = false;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set DPD Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DPD_type = 'Volterra_DDR';
% DPD_type = 'RF_Volterra';
% DPD_type = 'MP';
% DPD_type = 'APD';
% DPD_type = 'FIR_APD';
% DPD_type = 'AUG_MP';
% DPD_type = 'RF_MP';
switch DPD_type
    case {'Volterra_DDR_ET', 'Volterra_DDR'}
        %%%%% Volterra DDR ET parameters
        VolterraParameters.ModifiedKernels = false;
        VolterraParameters.ModifiedFile    = 'kernelsML.txt' ;
        VolterraParameters.DDR             = true ;
        VolterraParameters.DDRorder        = 1 ;
        %   VolterraETParameters.Order         = [ h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 ] ;
        VolterraParameters.Order           = [ 11  0  0  0  0  0  0  0  0  0   0   ] ;%[ 7  0  5  0  3  0  0  0  0  0   0   ] ;
        VolterraParameters.Static          = 7 ;
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
        MP_modelParam.M = 1;
        MP_modelParam.Gamma = 0;
        MP_modelParam.type = 'odd_even';  %type = 'odd' or 'odd_even'
    case 'APD'
        APD_modelParam.N = 8;
        APD_modelParam.M = 4;
        APD_modelParam.FIR_M = 4;
        APD_modelParam.architecture = 'multiply'; % 'add' or 'multiply';
        % Supported Mode MP, H_EMP, Mod_H_EMP, CRV, ECRV, ECRV_Pruned
		% Currently not supported UB_MP, NB_EMP, Mod_NB_EMP, Deriv_MP
        APD_modelParam.engine = 'Mod_H_EMP';
        APD_modelParam.polyorder = 'odd_aug'; % 'odd' or 'odd_even' or 'odd_aug'
        APD_modelParam.two_step = 1;
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
        FIR_APD_modelParam.use_parallel_FIR = 1;
        FIR_APD_modelParam.use_NL = 0;
    case 'RF_MP'
        RFMP_Param.m_num = 3;
        RFMP_Param.m_den = 1;
        RFMP_Param.n_num = 9;
        RFMP_Param.n_den = 1;
        RFMP_Param.mod_num = 0;   % 0 = odd_even; 1 = even_only; 2 = odd_only
        RFMP_Param.mod_den = 0;   % 0 = odd_even; 1 = even_only; 2 = odd_only
        Param_array = [RFMP_Param.m_num, RFMP_Param.m_den, RFMP_Param.n_num ...
            RFMP_Param.n_den, RFMP_Param.mod_num, RFMP_Param.mod_den];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set Transmitter/Receiver Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PXAAdd                = 18;                                       % The GPIB address of the PXA
PXA_Atten             = 22;                                       % The mechanical attenuation in dB for the PXA when dowloading the signal. From 6 to 24 with steps of 2 dB
ESGAdd                = 19;                                       % The GPIB address of the ESG
E4438C_VisaAddress    = ['GPIB0::' num2str(ESGAdd) '::INSTR'];    % Creates the Visa address of the ESG - 'GPIB0::19::INSTR'
% UXA Parameters
UXAAdd                = 'GPIB0::18::INSTR';                                       % The GPIB address of the PXA
UXA_Atten             = 6;                                       % The mechanical attenuation in dB for the PXA when dowloading the signal. From 6 to 24 with steps of 2 dB
UXA_ClockReference       = 'External';
%
DAC_SamplingRate            = FsampleAWG ;      % The sampling rate of the AWG - The input I/Q files with sampling rate of FsampleTx will be upsampled to this number. DAC_SamplingRate has to be an integer multiple of FsampleTx
RF_channel                  = 1;        % AWG channel used for sending RF signal - Not used in 'ESG' mode
VFS                         = 0.7;      % Full scale voltage of the AWG. 0.1 < VFS < 0.7;

if strcmp(Transmitter_type,'AWG')
    [DownSampleTx, UpSampleTx] = rat(FsampleTx/FsampleRx);
elseif strcmp(Transmitter_type,'AWG_N8241A')
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
if strcmp(Receiver_type,'PXA')
    if FsampleRx > 160e6
        disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        disp(' Warning... PXA maximum sampling rate is 160 MHz. Value of 160 MHz will be used for the measurements');
        disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        FsampleRx = 160e6;
    end
    [DownSampleRx, UpSampleRx] = rat(FsampleRx/FsampleRx);
elseif strcmp(Receiver_type,'UXA')
    [DownSampleRx, UpSampleRx] = rat(FsampleRx/FsampleRx);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reading the input files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [fname,dirpath]=uigetfile ('*.txt','Select a txt file','MultiSelect', 'on');
%%%% LTE 20 MHz
% InI_beforeDPD_path = 'LTE_20MHz_In_I_100r0_PAPR_9r3_16QAM_1ms.txt';
% InQ_beforeDPD_path = 'LTE_20MHz_In_Q_100r0_PAPR_9r3_16QAM_1ms.txt';
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
InI_beforeDPD_path = 'WCDMA_4C_LTE20_80MHz_In_I_400r0_PAPR_9r6_1ms.txt';
InQ_beforeDPD_path = 'WCDMA_4C_LTE20_80MHz_In_Q_400r0_PAPR_9r6_1ms.txt';
%%%%% WCDMA 4C + LTE20 - 80 MHz
% InI_beforeDPD_path = 'WCDMA_4C_LTE20_80MHz_In_I_400r0_PAPR_10r4_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA_4C_LTE20_80MHz_In_Q_400r0_PAPR_10r4_1ms.txt';
%%%%% WCDMA 4C + LTE20 + 1001 - 160 MHz
% InI_beforeDPD_path = 'WCDMA_4C_LTE20_1001_160MHz_In_I_800r0_PAPR_8r9_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA_4C_LTE20_1001_160MHz_In_Q_800r0_PAPR_8r9_1ms.txt';
%%%%% Single carrier aggregated LTE - 80 MHz
% InI_beforeDPD_path = 'SC_80M_I_fs_1e+09_PAPR_7.9_8.7_64QAM_1ms_16xUPS.txt';
% InQ_beforeDPD_path = 'SC_80M_Q_fs_1e+09_PAPR_7.9_8.7_64QAM_1ms_16xUPS.txt';
%%%%% 4 carrier LTE signal 80MHz
% InI_beforeDPD_path = 'LTE_4x20M_I_fs_1e+09_PAPR_8.5_11.3_16QAM_1ms_4xUPS.txt';
% InQ_beforeDPD_path = 'LTE_4x20M_Q_fs_1e+09_PAPR_8.5_11.3_16QAM_1ms_4xUPS.txt';
%%%%% 8 carrier LTE signal 160MHz
% InI_beforeDPD_path = 'LTE_8x20M_I_fs_1e+09_PAPR_8.4_11.0_16QAM_1ms_4xUPS.txt';
% InQ_beforeDPD_path = 'LTE_8x20M_Q_fs_1e+09_PAPR_8.4_11.0_16QAM_1ms_4xUPS.txt';
%%%%% Single carrier aggregated LTE - 160 MHz
% InI_beforeDPD_path = 'SC_160M_I_fs_1e+09_PAPR_7.1_8.8_64QAM_1ms_8xUPS.txt';
% InQ_beforeDPD_path = 'SC_160M_I_fs_1e+09_PAPR_7.1_8.8_64QAM_1ms_8xUPS.txt';
%%%%% Receiver Calibration, Fs = 400e6, 201 tones, -100 to 100 MHz
% InI_beforeDPD_path = 'MT_I.txt';
% InQ_beforeDPD_path = 'MT_Q.txt';

fG        = 300e3;       % Gaurd band for the modulated signal - Used to calculated ACLR and ACPR from the downloaded I/Q signals
BW        = 80e6;        % Bandwidth of the modulated signal - Used to calculated ACLR and ACPR from the downloaded I/Q signals  %to be linked to signal
PAPR_limit = 11;

In_I_beforeDPD = load(['Signals\' InI_beforeDPD_path]); In_I_beforeDPD = In_I_beforeDPD(:, 1);
In_Q_beforeDPD = load(['Signals\' InQ_beforeDPD_path]); In_Q_beforeDPD = In_Q_beforeDPD(:, 1);
In_I=In_I_beforeDPD;
In_Q=In_Q_beforeDPD;
In_I = In_I(1:round(FramTime*FsampleTx));
In_Q = In_Q(1:round(FramTime*FsampleTx));
In_ori = complex(In_I,In_Q);

%Lower the noise floor
for i = 1:10
    Y = LimitPAPR(In_ori, PAPR_limit);
%     CheckPower(Y, 1);

    Y_filtered= digital_lpf(Y, FsampleTx, BW/2);
    %CheckPower(Y_filtered, 1);
    In_ori = Y_filtered;
end

ps(In_ori, FsampleTx)
In_ori = digital_lpf(In_ori,FsampleTx, BW / 2);
In_I = real(In_ori); In_Q = imag(In_ori); 
In_I_beforeDPD=In_I;   In_Q_beforeDPD=In_Q;
% [In_I_beforeDPD, In_Q_beforeDPD] = setMeanPower(In_I_beforeDPD, In_Q_beforeDPD, 0) ;
% [meanPower, maxPower, PAPR_original] = checkPower(In_I_beforeDPD, In_Q_beforeDPD, 1) ;

% min_size = min([ size(In_I_beforeDPD,1) size(In_I_beforeDPD,1)]);
% 
% if min_size > round(FramTime*FsampleTx) + 0
%     min_size = round(FramTime*FsampleTx) + 0;
% end
% In_I_beforeDPD = In_I_beforeDPD(1:min_size);
% In_Q_beforeDPD = In_Q_beforeDPD(1:min_size);

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

%% APPLY CALIBRAITON
Cal_index=(Fcarrier-4.7e9)/1e8;
 %   Cal = load('IQ_Imbalance_M8190_fLO5r0GHz_Freq_Domain');
 if Cal_index==0
    Cal = load('IQ_Imbalance_M8190_fLO4r7GHz_BW_800MHzFreq_Domain');
 elseif Cal_index==1
    Cal = load('IQ_Imbalance_M8190_fLO4r8GHz_BW_800MHzFreq_Domain');
 elseif Cal_index==2
    Cal = load('IQ_Imbalance_M8190_fLO4r9GHz_BW_800MHzFreq_Domain');
 elseif Cal_index==3
    Cal = load('IQ_Imbalance_M8190_fLO5r0GHz_BW_800MHzFreq_Domain');
 elseif Cal_index==4
    Cal = load('IQ_Imbalance_M8190_fLO5r1GHz_BW_800MHzFreq_Domain');
 elseif Cal_index==5
    Cal = load('IQ_Imbalance_M8190_fLO5r2GHz_BW_800MHzFreq_Domain');
 elseif Cal_index==6
    Cal = load('IQ_Imbalance_M8190_fLO5r3GHz_BW_800MHzFreq_Domain');
 end
    Cal = Cal.TX_CAL_RESULTS;
    iter = 3;
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
   
  %     
 %% Apply calibration
        [I_corr, Q_corr ] = ApplyInverseIQImbalanceFilters(In_I_cal, In_Q_cal, FsampleTx, ...
            Cal(iter).G.G11, Cal(iter).G.G12, Cal(iter).G.G21, Cal(iter).G.G22, Cal(iter).tones, Cal(iter).tones); 
        I_corr = real(I_corr);
        Q_corr = real(Q_corr);
        [I_corr,Q_corr] = setMeanPower(I_corr,Q_corr,0);
        [meanPower, maxPower, PAPR_input] = checkPower(I_corr, Q_corr, 1)
    
    
 %  ComplexSignal{1}                  = complex(In_I_cal, In_Q_cal);
    ComplexSignal{1}                  = complex(I_corr, Q_corr);
 %   Fcarrier_array{1}                 = Fcarrier ;
    Fcarrier_array{1}                 = 0 ;
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
        SG.frequency(Fcarrier);
        SG.power(p_sg);
        SG.rf(1);
        SG.modulation_on
 %      AWG_M8190A_SignalUpload_ChannelSelect_FixedAvgPower(ComplexSignal, Fcarrier_array, FsampleTx_array, DAC_SamplingRate, Amp_Corr, false,RF_channel,Expansion_Margin, PAPR_input, PAPR_original);
        AWG_M8190A_IQSignalUpload_ChannelSelect_FixedAvgPower(ComplexSignal, Fcarrier_array, FsampleTx_array, DAC_SamplingRate, Amp_Corr, false,RF_channel,Expansion_Margin, PAPR_input, PAPR_original, 0, 0);
        AWG_M8190A_Reference_Clk('Backplane');
%         AWG_M8190A_DAC_Amplitude(RF_channel,VFS);
%         AWG_M8190A_MKR_Amplitude(RF_channel,1.5);
        %

        AWG_M8190A_DAC_Amplitude(1,0.7);
        AWG_M8190A_DAC_Amplitude(2,0.7);
        % AWG_M8190A_MKR_Amplitude(1,1.5);       % Set the trigger amplitude to 1.5 V 
        AWG_M8190A_MKR_Amplitude(1,1.5);       % Set the trigger amplitude to 1.5 V 
        AWG_M8190A_MKR_Amplitude(2,1.5);       % Set the trigger amplitude to 1.5 V 
        %
        AWG_M8190A_Output_OFF(1);
        AWG_M8190A_Output_OFF(2);
        %         RF_ON_Continue    = 0;
        [RF_ON_Continue]  = PushButton_Routine (keep_RF_ON,Transmitter_type,ESGAdd,RF_channel);
        
        AWG_M8190A_Output_ON(1);
        AWG_M8190A_Output_ON(2);
        pause(0.5);
    elseif strcmp(Transmitter_type,'AWG_N8241A')
        SG.frequency(Fcarrier);
        SG.power(p_sg);
        SG.rf(1);
        SG.modulation_on
        pause(0.5);
        instrumentHandle = AWG_N8241A_Setup(FsampleAWG, AWG_Gain);

        Waveform = [I_corr.' + I_offset; Q_corr.' + Q_offset];
      % Waveform = [In_I_AWG' + I_offset; In_Q_AWG' + Q_offset];

% Upload the waveform and capture the corresponding output on PXA
        AWG_N8241A_SignalUpload(instrumentHandle, Waveform, AWG_AutoNorm);
        agt_awg_close(instrumentHandle);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Downloading the output
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(Receiver_type, 'PXA')
        [RecI_captured, RecQ_captured] = IQCapture_with_atten (Fcarrier, FsampleRx, FramTime, PXAAdd, PXA_Atten);
        ResampledRecI = RecI_captured(200:end);
        ResampledRecQ = RecQ_captured(200:end);
        if strcmp(Transmitter_type,'AWG')
%             AWG_M8190A_Output_OFF(1);
%             AWG_M8190A_Output_OFF(2);
            SG.rf(0);
            SG.modulation_off% measurement end
        elseif strcmp(Transmitter_type,'ESG')
            ESG_RF_OFF_SingleCarrier(ESGAdd)
        elseif strcmp(Transmitter_type,'AWG_N8241A')
            SG.rf(0);
            SG.modulation_off% measurement end
        end
    elseif strcmp(Receiver_type, 'UXA')
    [RecI_captured, RecQ_captured] = IQCapture_UXA (Fcarrier, FsampleRx/1.25, FramTime, UXAAdd, UXA_Atten, UXA_ClockReference);
    ResampledRecI = RecI_captured(200:end);
    ResampledRecQ = RecQ_captured(200:end);

%
    if strcmp (Measure_Pout_Eff,'True')       
        V_m_with_DPD = PS_m.voltage(PS_m_chan);
        I_m_with_DPD = PS_m.current(PS_m_chan);
        V_a_with_DPD = PS_a.voltage;
        I_a_with_DPD = PS_a.current;
        Pout_measured_with_DPD = PM.measure;
        Pdc_measured_with_DPD  = V_m_with_DPD*I_m_with_DPD+V_a_with_DPD*I_a_with_DPD;
        DE_measured_with_DPD = 100*10^((Pout_measured_with_DPD-30)/10) / Pdc_measured_with_DPD;
    end
    if strcmp(Transmitter_type,'AWG')
%         AWG_M8190A_Output_OFF(1);
%         AWG_M8190A_Output_OFF(2);
        SG.rf(0);
        SG.modulation_off% measurement end
    elseif strcmp(Transmitter_type,'ESG')
        ESG_RF_OFF_SingleCarrier(ESGAdd)
    elseif strcmp(Transmitter_type,'AWG_N8241A')
            SG.rf(0);
            SG.modulation_off% measurement end
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
%     [In_I, In_Q, out_I1, out_Q1]                = UnifyLength(In_I, In_Q, ResampledRecI, ResampledRecQ);
    [In_I, In_Q, out_I1, out_Q1]                = UnifyLength(In_I, In_Q, ResampledRecI, ResampledRecQ);
    
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, timedelay1] = AdjustDelay(In_I, In_Q, out_I1, out_Q1,Fs,2000) ;
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;
    PlotGain(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
    PlotAMPM(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
    PlotSpectrum(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
    
    [EVM_dB EVM_perc] = EVM_calculate (DelayAdjusted_In_I,DelayAdjusted_In_Q,DelayAdjusted_Out_I,DelayAdjusted_Out_Q);
    
    % Downsample the recieved data to 5*BW to get the correct ACLR and ACPR 
    [UpsampleACP, DownsampleACP] = rat(5*BW/FsampleRx);
     OUT_I_ACP = resample(DelayAdjusted_Out_I, UpsampleACP, DownsampleACP, 500);
     OUT_Q_ACP = resample(DelayAdjusted_Out_Q, UpsampleACP, DownsampleACP, 500);
         % Remove the spurious
     sig  = complex(OUT_I_ACP(1:25000), OUT_Q_ACP(1:25000));
 %  ps(sig, FsampleRx);
    sig_nospurs = remove_spurious_specific(sig, 5*BW, -50e6);
 %  ps(sig_nospurs, FsampleRx)
    OUT_I_ACP=real(sig_nospurs);
    OUT_Q_ACP=imag(sig_nospurs);
%    PlotSpectrum(In_I, In_Q,ResampledRecI, ResampledRecQ,1,FsampleTx);
     
     [OUT_I_ACP, OUT_Q_ACP] = setMeanPower(OUT_I_ACP,OUT_Q_ACP,0);
     PlotSpectrum(OUT_I_ACP, OUT_Q_ACP,OUT_I_ACP, OUT_Q_ACP,5*BW);
    
    [freq, spectrum] = Calculated_Spectrum(OUT_I_ACP, OUT_Q_ACP, 5*BW);
    [ACLR_L, ACLR_U] = Calculate_ACLR (freq, spectrum, 0, BW, fG)
    [ACPR_L, ACPR_U] = Calculate_ACPR (freq, spectrum, 0, BW, fG);
    
    [DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM, timedelay_EVM]   = AdjustDelay(In_I_beforeDPD_EVM(mem_truncate+1:end), In_Q_beforeDPD_EVM((mem_truncate+1:end)), out_I1, out_Q1,Fs,2000) ;
    [DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM]                     = AdjustPowerAndPhase(DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM, 0) ;
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;
    PlotGain(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
    PlotAMPM(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
    % PlotSpectrum(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
    
    [EVM_dB EVM_perc] = EVM_calculate (DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM);
    
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
        case 'RF_MP'
            [num_coeff, den_coeff, NMSE_error, Cond_A] = Identify_SingleBand_RFMP(Param_array, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_num_real = 20*log10( (max(abs(real(num_coeff))))/(min(abs(real(num_coeff)))));
            Coeff_DR_num_imag = 20*log10( (max(abs(imag(num_coeff))))/(min(abs(imag(num_coeff)))));
            Coeff_DR_num = max(Coeff_DR_num_real,Coeff_DR_num_imag);
            Coeff_DR_den_real = 20*log10( (max(abs(real(den_coeff))))/(min(abs(real(den_coeff)))));
            Coeff_DR_den_imag = 20*log10( (max(abs(imag(den_coeff))))/(min(abs(imag(den_coeff)))));
            Coeff_DR_den = max(Coeff_DR_den_real,Coeff_DR_den_imag);
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
            [ Pr_I , Pr_Q ] = VolterraDpdApply_ET ( In_I_beforeDPD_EVM , In_Q_beforeDPD_EVM , abs(complex(In_I_beforeDPD_EVM,In_Q_beforeDPD_EVM)), VolterraETParameters , VolterraCoeff ) ;
            %         [ Pr_I , Pr_Q ] = VolterraDpdApply ( In_I_beforeDPD_EVM , In_Q_beforeDPD_EVM , VolterraETParameters , VolterraCoeff ) ;
        case 'Volterra_DDR_ET'
            [ Pr_I , Pr_Q ] = VolterraDpdApply_ET ( In_I_beforeDPD_EVM , In_Q_beforeDPD_EVM , Vdd_beforeDPD, VolterraETParameters , VolterraCoeff ) ;
            %         DelayAdjusted_Vdd_beforeDPD
        case 'RF_Volterra'
            [Pr_I , Pr_Q]=Apply_RF_Volterra_v2_ET(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, abs(complex(In_I_beforeDPD_EVM,In_Q_beforeDPD_EVM)), Coeff_RF_Volterra, RF_Volterra_Parameters , Fs);
            %         [Pr_I , Pr_Q]=Apply_RF_Volterra(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, Coeff_RF_Volterra, RF_Volterra_Parameters , Fs);
        case 'MP'
            [Pr_I, Pr_Q] = Apply_SingleBand_MP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, MP_modelParam, MP_coefficients);
        case 'APD'
            [Pr_I, Pr_Q] = Apply_SingleBand_APD(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, APD_modelParam, APD_coefficients);
        case 'FIR_APD'
            [Pr_I, Pr_Q] = Apply_SingleBand_FIR_APD(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, FIR_APD_modelParam, FIR_APD_coefficients);
        case 'Aug_MP'
            [Pr_I, Pr_Q] = Apply_SingleBand_Aug_MP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, MP_modelParam, MP_coefficients, gamma);
        case 'RF_MP'
            [Pr_I, Pr_Q] = Apply_SingleBand_RFMP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, Param_array, num_coeff, den_coeff);
        case 'RF_Volterra_ET'
            [Pr_I , Pr_Q]=Apply_RF_Volterra_v2_ET(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, DelayAdjusted_Vdd_beforeDPD, Coeff_RF_Volterra, RF_Volterra_Parameters , Fs);
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

PushButton_Save_Result
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Final "With DPD" Measurements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' Final DPD measurement with DPD');
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
In_I = Pr_I_up;
In_Q = Pr_Q_up;
In_I_withDPD = In_I;
In_Q_withDPD = In_Q;
In_I_cal = In_I_withDPD; In_Q_cal = In_Q_withDPD;

SignalName                        = [WaveformName, 'WithDPD'];
[In_I_cal, In_Q_cal]              = setMeanPower(In_I_cal, In_Q_cal, PowerBand);  % Set the mean power of the I/Q signals to be uploaded
[In_I, In_Q]                      = setMeanPower(In_I, In_Q, 0);                      % Set the mean power of the I/Q signals to be used for DPD
[meanPower, maxPower, PAPR_input] = checkPower(In_I_cal, In_Q_cal, 1) ;           % Check the PAPR of the input file to be uploaded to the transmitter

        [I_corr, Q_corr ] = ApplyInverseIQImbalanceFilters(In_I_cal, In_Q_cal, FsampleTx, ...
            Cal(iter).G.G11, Cal(iter).G.G12, Cal(iter).G.G21, Cal(iter).G.G22, Cal(iter).tones, Cal(iter).tones); 
        I_corr = real(I_corr);
        Q_corr = real(Q_corr);
        [I_corr,Q_corr] = setMeanPower(I_corr,Q_corr,0);
        [meanPower, maxPower, PAPR_input] = checkPower(I_corr, Q_corr, 1)
    
    
 %  ComplexSignal{1}                  = complex(In_I_cal, In_Q_cal);
    ComplexSignal{1}                  = complex(I_corr, Q_corr);
 %   Fcarrier_array{1}                 = Fcarrier ;
    Fcarrier_array{1}                 = 0 ;
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
        SG.frequency(Fcarrier);
        SG.power(p_sg);
        SG.rf(1);
        SG.modulation_on
        
 %      AWG_M8190A_SignalUpload_ChannelSelect_FixedAvgPower(ComplexSignal, Fcarrier_array, FsampleTx_array, DAC_SamplingRate, Amp_Corr, false,RF_channel,Expansion_Margin, PAPR_input, PAPR_original);
        AWG_M8190A_IQSignalUpload_ChannelSelect_FixedAvgPower(ComplexSignal, Fcarrier_array, FsampleTx_array, DAC_SamplingRate, Amp_Corr, false,RF_channel,Expansion_Margin, PAPR_input, PAPR_original, 0, 0);
        AWG_M8190A_Reference_Clk('Backplane');
%         AWG_M8190A_DAC_Amplitude(RF_channel,VFS);
%         AWG_M8190A_MKR_Amplitude(RF_channel,1.5);
        %

        AWG_M8190A_DAC_Amplitude(1,0.7);
        AWG_M8190A_DAC_Amplitude(2,0.7);
        % AWG_M8190A_MKR_Amplitude(1,1.5);       % Set the trigger amplitude to 1.5 V 
        AWG_M8190A_MKR_Amplitude(1,1.5);       % Set the trigger amplitude to 1.5 V 
        AWG_M8190A_MKR_Amplitude(2,1.5);       % Set the trigger amplitude to 1.5 V 
        %
        AWG_M8190A_Output_OFF(1);
        AWG_M8190A_Output_OFF(2);
        
        %         RF_ON_Continue    = 0;
        [RF_ON_Continue]  = PushButton_Routine (keep_RF_ON,Transmitter_type,ESGAdd,RF_channel);
        
        AWG_M8190A_Output_ON(1);
        AWG_M8190A_Output_ON(2);
        pause(0.5);
elseif strcmp(Transmitter_type,'AWG_N8241A')
        SG.frequency(Fcarrier);
        SG.power(p_sg);
        SG.rf(1);
        SG.modulation_on
        pause(0.5);
        instrumentHandle = AWG_N8241A_Setup(FsampleAWG, AWG_Gain);

        Waveform = [I_corr.' + I_offset; Q_corr.' + Q_offset];
      % Waveform = [In_I_AWG' + I_offset; In_Q_AWG' + Q_offset];

% Upload the waveform and capture the corresponding output on PXA
        AWG_N8241A_SignalUpload(instrumentHandle, Waveform, AWG_AutoNorm);
        agt_awg_close(instrumentHandle);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Downloading the output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Receiver_type, 'PXA')
    [RecI_captured, RecQ_captured] = IQCapture_with_atten (Fcarrier, FsampleRx, FramTime, PXAAdd, PXA_Atten);
    ResampledRecI = RecI_captured(200:end);
    ResampledRecQ = RecQ_captured(200:end);
    if strcmp (Measure_Pout_Eff,'True')       
        V_m_with_DPD = PS_m.voltage(PS_m_chan);
        I_m_with_DPD = PS_m.current(PS_m_chan);
        V_a_with_DPD = PS_a.voltage;
        I_a_with_DPD = PS_a.current;
        Pout_measured_with_DPD = PM.measure;
        Pdc_measured_with_DPD  = V_m_with_DPD*I_m_with_DPD+V_a_with_DPD*I_a_with_DPD;
        DE_measured_with_DPD = 100*10^((Pout_measured_with_DPD-30)/10) / Pdc_measured_with_DPD;
    end
    if strcmp(Transmitter_type,'AWG')
        AWG_M8190A_Output_OFF(RF_channel);
    elseif strcmp(Transmitter_type,'ESG')
        ESG_RF_OFF_SingleCarrier(ESGAdd)
    elseif strcmp(Transmitter_type,'AWG_N8241A')
            SG.rf(0);
            SG.modulation_off% measurement end
    end
elseif strcmp(Receiver_type, 'UXA')
    [RecI_captured, RecQ_captured] = IQCapture_UXA (Fcarrier, FsampleRx/1.25, FramTime, UXAAdd, UXA_Atten, UXA_ClockReference);
    ResampledRecI = RecI_captured(200:end);
    ResampledRecQ = RecQ_captured(200:end);
    

    if strcmp (Measure_Pout_Eff,'True')       
        V_m_with_DPD = PS_m.voltage(PS_m_chan);
        I_m_with_DPD = PS_m.current(PS_m_chan);
        V_a_with_DPD = PS_a.voltage;
        I_a_with_DPD = PS_a.current;
        Pout_measured_with_DPD = PM.measure;
        Pdc_measured_with_DPD  = V_m_with_DPD*I_m_with_DPD+V_a_with_DPD*I_a_with_DPD;
        DE_measured_with_DPD = 100*10^((Pout_measured_with_DPD-30)/10) / Pdc_measured_with_DPD;
    end
    if strcmp(Transmitter_type,'AWG')
        AWG_M8190A_Output_OFF(1);
        AWG_M8190A_Output_OFF(2);
        SG.rf(0);
        SG.modulation_off% measurement end
    elseif strcmp(Transmitter_type,'ESG')
        ESG_RF_OFF_SingleCarrier(ESGAdd)
    elseif strcmp(Transmitter_type,'AWG_N8241A')
            SG.rf(0);
            SG.modulation_off% measurement end
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
[In_I_withDPD, In_Q_withDPD, out_I1_withDPD, out_Q1_withDPD]                                   = UnifyLength(In_I_withDPD, In_Q_withDPD, ResampledRecI, ResampledRecQ) ;
[DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, timedelay1] = AdjustDelay(In_I_withDPD, In_Q_withDPD, out_I1_withDPD, out_Q1_withDPD,Fs,2000) ;
[DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;

PlotGain(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
PlotAMPM(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
% PlotSpectrum(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;

    % Downsample the recieved data to 5*BW to get the correct ACLR and ACPR 
    [UpsampleACP, DownsampleACP] = rat(5*BW/FsampleRx);
    OUT_I_ACP = resample(DelayAdjusted_Out_I, UpsampleACP, DownsampleACP, 500);
    OUT_Q_ACP = resample(DelayAdjusted_Out_Q, UpsampleACP, DownsampleACP, 500);
    
      % Remove the spurious
    sig  = complex(OUT_I_ACP(1:25000), OUT_Q_ACP(1:25000));
 %  ps(sig, FsampleRx);
    sig_nospurs = remove_spurious_specific(sig, 5*BW, [-50e6 0]);
 %  ps(sig_nospurs, FsampleRx)
    OUT_I_ACP=real(sig_nospurs);
    OUT_Q_ACP=imag(sig_nospurs);
     
    [OUT_I_ACP, OUT_Q_ACP] = setMeanPower(OUT_I_ACP,OUT_Q_ACP,0);
    PlotSpectrum(In_I_beforeDPD, In_Q_beforeDPD,OUT_I_ACP, OUT_Q_ACP,5*BW);
    
    [freq, spectrum] = Calculated_Spectrum(OUT_I_ACP, OUT_Q_ACP, 5*BW);


[EVM_dB EVM_perc]                = EVM_calculate (DelayAdjusted_In_I,DelayAdjusted_In_Q,DelayAdjusted_Out_I,DelayAdjusted_Out_Q);

[ACLR_L_withDPD, ACLR_U_withDPD] = Calculate_ACLR (freq, spectrum, 0, BW, fG);
[ACPR_L_withDPD, ACPR_U_withDPD] = Calculate_ACPR (freq, spectrum, 0, BW, fG);

[DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM, timedelay_EVM]   = AdjustDelay(In_I_beforeDPD_EVM(mem_truncate+1:end), In_Q_beforeDPD_EVM((mem_truncate+1:end)), out_I1_withDPD, out_Q1_withDPD,Fs,2000) ;
[DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM]                = AdjustPowerAndPhase(DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM,0);

PlotGain(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
PlotAMPM(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
% PlotSpectrum(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;

[EVM_dB_withDPD EVM_perc_withDPD] = EVM_calculate (DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM);

display([ ' EVM with DPD        = ' num2str(EVM_perc_withDPD)      ' % ' ]);
display([ ' ACLR (L/U) with DPD = ' num2str(ACLR_L_withDPD) ' / '  num2str(ACLR_U_withDPD) ' dB ' ]);
display([ ' ACPR (L/U) with DPD = ' num2str(ACPR_L_withDPD) ' / '  num2str(ACPR_U_withDPD) ' dB ' ]);

Out_I_withDPD = out_I1_withDPD;
Out_Q_withDPD = out_Q1_withDPD;

[meanPower, maxPower, PAPRin_withDPD]  = checkPower(In_I_withDPD,In_Q_withDPD,0);
[meanPower, maxPower, PAPRout_withDPD] = checkPower(out_I1_withDPD,out_Q1_withDPD,0);

disp(  ' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp([ ' Input PAPR with DPD     = ' num2str(PAPRin_withDPD)  ' dB ' ]);
disp([ ' Output PAPR with DPD    = ' num2str(PAPRout_withDPD) ' dB ' ]);
disp([ ' Measured Pout with DPD  = ' num2str(Pout_measured_with_DPD) ' dBm ' ]);
disp([ ' Measured DE with DPD    = ' num2str(DE_measured_with_DPD) ' % ' ]);
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

        [I_corr, Q_corr ] = ApplyInverseIQImbalanceFilters(In_I_cal, In_Q_cal, FsampleTx, ...
            Cal(iter).G.G11, Cal(iter).G.G12, Cal(iter).G.G21, Cal(iter).G.G22, Cal(iter).tones, Cal(iter).tones); 
        I_corr = real(I_corr);
        Q_corr = real(Q_corr);
        [I_corr,Q_corr] = setMeanPower(I_corr,Q_corr,0);
        [meanPower, maxPower, PAPR_input] = checkPower(I_corr, Q_corr, 1)
    
    
 %  ComplexSignal{1}                  = complex(In_I_cal, In_Q_cal);
    ComplexSignal{1}                  = complex(I_corr, Q_corr);
 %   Fcarrier_array{1}                 = Fcarrier ;
    Fcarrier_array{1}                 = 0 ;
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
        SG.frequency(Fcarrier);
        SG.power(p_sg);
        SG.rf(1);
        SG.modulation_on
 %      AWG_M8190A_SignalUpload_ChannelSelect_FixedAvgPower(ComplexSignal, Fcarrier_array, FsampleTx_array, DAC_SamplingRate, Amp_Corr, false,RF_channel,Expansion_Margin, PAPR_input, PAPR_original);
        AWG_M8190A_IQSignalUpload_ChannelSelect_FixedAvgPower(ComplexSignal, Fcarrier_array, FsampleTx_array, DAC_SamplingRate, Amp_Corr, false,RF_channel,Expansion_Margin, PAPR_input, PAPR_original, 0, 0);
        AWG_M8190A_Reference_Clk('Backplane');
%         AWG_M8190A_DAC_Amplitude(RF_channel,VFS);
%         AWG_M8190A_MKR_Amplitude(RF_channel,1.5);
        %

        AWG_M8190A_DAC_Amplitude(1,0.7);
        AWG_M8190A_DAC_Amplitude(2,0.7);
        % AWG_M8190A_MKR_Amplitude(1,1.5);       % Set the trigger amplitude to 1.5 V 
        AWG_M8190A_MKR_Amplitude(1,1.5);       % Set the trigger amplitude to 1.5 V 
        AWG_M8190A_MKR_Amplitude(2,1.5);       % Set the trigger amplitude to 1.5 V 
        %
        AWG_M8190A_Output_OFF(1);
        AWG_M8190A_Output_OFF(2);
        
        %         RF_ON_Continue    = 0;
        [RF_ON_Continue]  = PushButton_Routine (keep_RF_ON,Transmitter_type,ESGAdd,RF_channel);
        
        AWG_M8190A_Output_ON(1);
        AWG_M8190A_Output_ON(2);
        pause(0.5);
elseif strcmp(Transmitter_type,'AWG_N8241A')
        SG.frequency(Fcarrier);
        SG.power(p_sg);
        SG.rf(1);
        SG.modulation_on
        pause(0.5);
        instrumentHandle = AWG_N8241A_Setup(FsampleAWG, AWG_Gain);

        Waveform = [I_corr.' + I_offset; Q_corr.' + Q_offset];
      % Waveform = [In_I_AWG' + I_offset; In_Q_AWG' + Q_offset];

% Upload the waveform and capture the corresponding output on PXA
        AWG_N8241A_SignalUpload(instrumentHandle, Waveform, AWG_AutoNorm);
        agt_awg_close(instrumentHandle);
end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Downloading the output
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Downloading the output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Receiver_type, 'PXA')
    [RecI_captured, RecQ_captured] = IQCapture_with_atten (Fcarrier, FsampleRx, FramTime, PXAAdd, PXA_Atten);
    ResampledRecI = RecI_captured(200:end);
    ResampledRecQ = RecQ_captured(200:end);
    if strcmp (Measure_Pout_Eff,'True')
        V_m_without_DPD = PS_m.voltage(PS_m_chan);
        I_m_without_DPD = PS_m.current(PS_m_chan);
        V_a_without_DPD = PS_a.voltage;
        I_a_without_DPD = PS_a.current;
        Pout_measured_without_DPD = PM.measure;
        Pdc_measured_without_DPD  = V_m_without_DPD*I_m_without_DPD;
        DE_measured_without_DPD = 100*10^((Pout_measured_without_DPD-30)/10) / Pdc_measured_without_DPD ;
    end
    if strcmp(Transmitter_type,'AWG')
        AWG_M8190A_Output_OFF(RF_channel);
    elseif strcmp(Transmitter_type,'ESG')
        ESG_RF_OFF_SingleCarrier(ESGAdd)
    elseif strcmp(Transmitter_type,'AWG_N8241A')
        SG.rf(0);
            SG.modulation_off% measurement end
    end
elseif strcmp(Receiver_type, 'UXA')
    [RecI_captured, RecQ_captured] = IQCapture_UXA (Fcarrier, FsampleRx/1.25, FramTime, UXAAdd, UXA_Atten, UXA_ClockReference);
    ResampledRecI = RecI_captured(200:end);
    ResampledRecQ = RecQ_captured(200:end);
    
    
    if strcmp (Measure_Pout_Eff,'True')       
        V_m_without_DPD = PS_m.voltage(PS_m_chan);
        I_m_without_DPD = PS_m.current(PS_m_chan);
        V_a_without_DPD = PS_a.voltage;
        I_a_without_DPD = PS_a.current;
        Pout_measured_without_DPD = PM.measure;
        Pdc_measured_without_DPD  = V_m_with_DPD*I_m_with_DPD+V_a_with_DPD*I_a_with_DPD;
        DE_measured_without_DPD = 100*10^((Pout_measured_with_DPD-30)/10) / Pdc_measured_with_DPD;
    end
    if strcmp(Transmitter_type,'AWG')
%         AWG_M8190A_Output_OFF(1);
%         AWG_M8190A_Output_OFF(2);
        SG.rf(0);
        SG.modulation_off% measurement end
    elseif strcmp(Transmitter_type,'ESG')
        ESG_RF_OFF_SingleCarrier(ESGAdd)
    elseif strcmp(Transmitter_type,'AWG_N8241A')
            SG.rf(0);
            SG.modulation_off% measurement end
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
[In_I_withoutDPD,In_Q_withoutDPD,out_I1_withoutDPD,out_Q1_withoutDPD]                           = UnifyLength(In_I_withoutDPD, In_Q_withoutDPD, ResampledRecI, ResampledRecQ);
[DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, timedelay1]  = AdjustDelay(In_I_withoutDPD, In_Q_withoutDPD, out_I1_withoutDPD, out_Q1_withoutDPD,Fs,2000);
[DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]              = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0);

PlotGain(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
PlotAMPM(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
% PlotSpectrum(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;

[UpsampleACP, DownsampleACP] = rat(5*BW/FsampleRx);
     OUT_I_ACP = resample(DelayAdjusted_Out_I, UpsampleACP, DownsampleACP, 500);
     OUT_Q_ACP = resample(DelayAdjusted_Out_Q, UpsampleACP, DownsampleACP, 500);
        % Remove the spurious
    sig  = complex(OUT_I_ACP(1:25000), OUT_Q_ACP(1:25000));
 %  ps(sig, FsampleRx);
    sig_nospurs = remove_spurious_specific(sig, 5*BW, [-50e6 0]);
 %  ps(sig_nospurs, FsampleRx)
    OUT_I_ACP=real(sig_nospurs);
    OUT_Q_ACP=imag(sig_nospurs);
     
    [OUT_I_ACP, OUT_Q_ACP] = setMeanPower(OUT_I_ACP,OUT_Q_ACP,0);
    PlotSpectrum(In_I_beforeDPD, In_Q_beforeDPD,OUT_I_ACP, OUT_Q_ACP,5*BW);
    
    [freq, spectrum] = Calculated_Spectrum(OUT_I_ACP, OUT_Q_ACP, 5*BW);
    [ACLR_L, ACLR_U] = Calculate_ACLR (freq, spectrum, 0, BW, fG);
    [ACPR_L, ACPR_U] = Calculate_ACPR (freq, spectrum, 0, BW, fG);


[EVM_dB EVM_perc] = EVM_calculate (DelayAdjusted_In_I,DelayAdjusted_In_Q,DelayAdjusted_Out_I,DelayAdjusted_Out_Q);

[ACLR_L_withoutDPD, ACLR_U_withoutDPD]  = Calculate_ACLR (freq, spectrum, 0, BW, fG);
[ACPR_L_withoutDPD, ACPR_U_withoutDPD]  = Calculate_ACPR (freq, spectrum, 0, BW, fG);

[DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM, timedelay_EVM] = AdjustDelay(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, out_I1_withoutDPD, out_Q1_withoutDPD,Fs,2000) ;
[DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM]                = AdjustPowerAndPhase(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM, 0) ;

PlotGain(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
PlotAMPM(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
% PlotSpectrum(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;

[EVM_dB_withoutDPD EVM_perc_withoutDPD] = EVM_calculate (DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM);

display([ 'EVM without DPD        = ' num2str(EVM_perc_withoutDPD)      ' % ' ]);
display([ 'ACLR (L/U) without DPD = ' num2str(ACLR_L_withoutDPD) ' / '  num2str(ACLR_U_withoutDPD) ' dB ' ]);
display([ 'ACPR (L/U) without DPD = ' num2str(ACPR_L_withoutDPD) ' / '  num2str(ACPR_U_withoutDPD) ' dB ' ]);

Out_I_withoutDPD = out_I1_withoutDPD;
Out_Q_withoutDPD = out_Q1_withoutDPD;

[meanPower, maxPower, PAPRin_withoutDPD] = checkPower(In_I_withoutDPD,In_Q_withoutDPD,0);
[meanPower, maxPower, PAPRout_withoutDPD] = checkPower(out_I1_withoutDPD,out_Q1_withoutDPD,0);

disp(  ' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp([ ' Input PAPR without DPD     = ' num2str(PAPRin_withoutDPD) ' dB ' ]);
disp([ ' Output PAPR without DPD    = ' num2str(PAPRout_withoutDPD) ' dB ' ]);
disp([ ' Measured Pout without DPD  = ' num2str(Pout_measured_without_DPD) ' dBm ' ]);
disp([ ' Measured DE without DPD    = ' num2str(DE_measured_without_DPD) ' % ' ]);
disp(  ' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
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
% fprintf(fidIEH,'Internal Rx down/upsampling rate = %4.3f / %4.3f \n ',DownSampleRx,UpSampleRx);
% fprintf(fidIEH,'Internal Tx down/upsampling rate = %4.3f / %4.3f \n ',DownSampleTx,UpSampleTx);
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
if strcmp(Measure_Pout_Eff,'True')
    fprintf(fidIEH,'\n');
    fprintf(fidIEH,'With DPD Measurements');
    fprintf(fidIEH,'\nPout  = %4.3f   dBm ', Pout_measured_with_DPD);
    fprintf(fidIEH,'\nVdd   = %4.3f   V', V_m_with_DPD);
    fprintf(fidIEH,'\nIdd   = %4.3f   mA', I_m_with_DPD*1e3);
    fprintf(fidIEH,'\nDE    = %4.3f  %',DE_measured_with_DPD);
    fprintf(fidIEH,'\nPAE   =        %');
    fprintf(fidIEH,'\n');
    fprintf(fidIEH,'Without DPD Measurements');
    fprintf(fidIEH,'\nPout  = %4.3f   dBm ', Pout_measured_without_DPD);
    fprintf(fidIEH,'\nVdd   = %4.3f   V', V_m_without_DPD);
    fprintf(fidIEH,'\nIdd   = %4.3f   mA', I_m_without_DPD*1e3);
    fprintf(fidIEH,'\nDE    = %4.3f  %',DE_measured_without_DPD);
    fprintf(fidIEH,'\nPAE   =        %');
else
    fprintf(fidIEH,'\n');
    fprintf(fidIEH,'\nPout   =        dBm ');
    fprintf(fidIEH,'\nVdd    = 28     V');
    fprintf(fidIEH,'\nIdd    =        mA');
    fprintf(fidIEH,'\nDE     =        %');
    fprintf(fidIEH,'\nPAE    =        %');
end
fclose(fidIEH);
cd ..
cd ..

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Close Connection with Instrument
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Receiver_type,'Digitizer')
    M9703A_Obj.Close;
    M9352A_Obj.Close;
    if strcmp(LO_type,'E4438C')
        E4438C_Obj.Close;
    end
end
