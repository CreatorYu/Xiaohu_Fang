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
PowerBand = 0;           % Power in dBm for ESG (In case of high speed AWG, the power is controlled using VFS)
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
SetTxRxParams
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

ReadInputFiles

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DPD Iteration loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Turn LO ON
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
for IterationCount = 1:NofIteration
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp([' Iteration nb ',num2str(IterationCount), ' out of ', num2str(NofIteration)]);
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    In_I_cal = In_I; In_Q_cal = In_Q;
    [In_I, In_Q] = setMeanPower(In_I, In_Q, 0);
    
	UploadSignal
	DownloadSignal
	
	In_I = resample(In_I,UpSampleTx,DownSampleTx);
	In_Q = resample(In_Q,UpSampleTx,DownSampleTx);
	AdjustDelayAndAnalysis
	
	display([ 'EVM          = ' num2str(EVM_perc)      ' % ' ]);
	display([ 'ACLR (L/U)   = ' num2str(ACLR_L) ' / '  num2str(ACLR_U) ' dB ' ]);
	display([ 'ACPR (L/U)   = ' num2str(ACPR_L) ' / '  num2str(ACPR_U) ' dB ' ]);
	
	[next_iteration, keep_RF_ON]  = ContinueIteration_Routine;
    if (next_iteration == 0)
        In_I = resample(In_I,DownSampleTx,UpSampleTx);
        In_Q = resample(In_Q,DownSampleTx,UpSampleTx);
        break
    end

	IdentifyDPD
	ApplyDPD
	
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

In_I_withDPD = In_I; In_Q_withDPD = In_Q;
In_I_cal = In_I_withDPD; In_Q_cal = In_Q_withDPD;
[In_I, In_Q] = setMeanPower(In_I, In_Q, 0);

UploadSignal
DownloadSignal

In_I = resample(In_I_withDPD,UpSampleTx,DownSampleTx);
In_Q = resample(In_Q_withDPD,UpSampleTx,DownSampleTx);
AdjustDelayAndAnalysis

% Copy the results
EVM_perc_withDPD = EVM_perc;
ACLR_L_withDPD = ACLR_L; ACLR_U_withDPD = ACLR_L;
ACPR_L_withDPD = ACLR_L; ACPR_U_withDPD = ACLR_L;
Out_I_withDPD = out_I1; Out_Q_withDPD = out_Q1;

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

In_I_withoutDPD = In_I_beforeDPD; In_Q_withoutDPD = In_Q_beforeDPD;
In_I_cal = In_I_withoutDPD; In_Q_cal = In_Q_withoutDPD;

UploadSignal
DownloadSignal

In_I = resample(In_I_withoutDPD,UpSampleTx,DownSampleTx);
In_Q = resample(In_Q_withoutDPD,UpSampleTx,DownSampleTx);
AdjustDelayAndAnalysis

% Copy the results
EVM_perc_withoutDPD = EVM_perc;
ACLR_L_withoutDPD = ACLR_L; ACLR_U_withoutDPD = ACLR_L;
ACPR_L_withoutDPD = ACLR_L; ACPR_U_withoutDPD = ACLR_L;
Out_I_withoutDPD = out_I1; Out_Q_withoutDPD = out_Q1;

display([ ' EVM without DPD        = ' num2str(EVM_perc_withoutDPD)      ' % ' ]);
display([ ' ACLR (L/U) without DPD = ' num2str(ACLR_L_withoutDPD) ' / '  num2str(ACLR_U_withoutDPD) ' dB ' ]);
display([ ' ACPR (L/U) without DPD = ' num2str(ACPR_L_withoutDPD) ' / '  num2str(ACPR_U_withoutDPD) ' dB ' ]);

[meanPower, maxPower, PAPRin_withoutDPD]  = checkPower(In_I_withoutDPD,In_Q_withoutDPD,0);
[meanPower, maxPower, PAPRout_withoutDPD] = checkPower(Out_I_withoutDPD,Out_Q_withoutDPD,0);

disp(  ' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp([ ' Input PAPR without DPD     = ' num2str(PAPRin_withoutDPD)  ' dB ' ]);
disp([ ' Output PAPR without DPD    = ' num2str(PAPRout_withoutDPD) ' dB ' ]);
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
