clear
clc
close all
clearvars

path(pathdef); % Res ets the paths to remove paths outside this folder
addpath(genpath('C:\Program Files (x86)\IVI Foundation\IVI\Components\MATLAB')) ;
path('C:\Documents\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Signals',path)
path('C:\Documents\Xiaohu_Fang\EmRG_Code\TX_Calibration\Instrument_Functions\SignalCapture_UXA',path)
addpath(genpath('C:\Documents\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411')) ;
addpath(genpath(pwd))%Automatically Adds all paths in directory and subfolders

SG=SignalGenerator_E8267D(19,-25);
PM = PowerMeter_N1911A(15);
PS_m = PowerSupply_N6705A(5);
PS_a = PowerSupply_F3643A(7);
ATN=Attenuator('Attenuator_Coupler_4_8GHz_2.s2p');
%
SG.connect;
PM.connect;
PS_m.connect;
PS_a.connect;
%
% preset the signal generator and power meter 
% SG.preset;
PM.preset;
%
%

PS_m_chan=1
%
%
p_sg=-30.1;
Fcarrier=5.2e9;
Cal = load('IQ_Imbalance_M8190_fLO5r2GHz_BW_800MHzFreq_Domain');
time_now = clock;
dir_name = strcat('5r2GHz',date,'_',int2str(time_now(4)),'_',int2str(time_now(5)),'_',int2str(time_now(6)));
UXA_Atten             = 14;    
%
%
FsampleAWG            = 2e9; 
AWG_AutoNorm		  = false;   % choose weather to normalize IQ data sending to the DAC
AWG_Gain       = 0.5;    % between 0.35 - 0.5;
I_offset  = 0;
Q_offset = 0;

n                   	= (0:1023)';         %  1024 sample points
FBB                 	= FsampleAWG/256*4;    %  baseband frequency
Amplitude           	= 0.6;

SG.frequency(Fcarrier);
PM.frequency(Fcarrier);
PM.offset(ATN.attenuation(Fcarrier)+0.5);
fprintf('Attenuation at %g Hz is %g dB\n', Fcarrier, ATN.attenuation(Fcarrier)+0.5);
    %PM.offset(0);
PM.zero_and_cal;
SG.power(p_sg);
SG.rf(1);
SG.modulation_on
pause(0.5);
%
% In_I                	=   cos(2*pi*(FBB/FsampleAWG)*n)*Amplitude ;
% In_Q                	=  sin(2*pi*(FBB/FsampleAWG)*n)*Amplitude ;

%%%%% WCDMA 1C - 5 MHz
% InI_beforeDPD_path = 'WCDMA3G_1C_In_I_100r0_PAPR_7r4_Version1200_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA3G_1C_In_Q_100r0_PAPR_7r4_Version1200_1ms.txt';
% BW = 5e6;
% fG = 300e3;
%%%%% LTE 20 MHz
% InI_beforeDPD_path = 'LTE_20MHz_In_I_100r0_PAPR_9r3_16QAM_1ms.txt';
% InQ_beforeDPD_path = 'LTE_20MHz_In_Q_100r0_PAPR_9r3_16QAM_1ms.txt';
%%%%% WCDMA 111 / LTE 15 - 40 MHz
% InI_beforeDPD_path = 'WCDMA111_LTE15_40MHz_In_I_200r0_PAPR_8r4_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA111_LTE15_40MHz_In_Q_200r0_PAPR_8r4_1ms.txt';
%%%%% WCDMA 4C + LTE15 + LTE20 - 80 MHz
% InI_beforeDPD_path = 'WCDMA_4C_LTE15_LTE20_80MHz_In_I_400r0_PAPR_10r9_1ms.txt';
% InQ_beforeDPD_path = 'WCDMA_4C_LTE15_LTE20_80MHz_In_Q_400r0_PAPR_10r9_1ms.txt';
%%%%% WCDMA 4C + LTE20 - 80 MHz
InI_beforeDPD_path = 'WCDMA_4C_LTE20_80MHz_In_I_400r0_PAPR_9r6_1ms.txt';
InQ_beforeDPD_path = 'WCDMA_4C_LTE20_80MHz_In_Q_400r0_PAPR_9r6_1ms.txt';
%%%%% 4 carrier LTE signal 80MHz
% InI_beforeDPD_path = 'LTE_4x20M_I_fs_1e+09_PAPR_8.5_11.3_16QAM_1ms_4xUPS.txt';
% InQ_beforeDPD_path = 'LTE_4x20M_Q_fs_1e+09_PAPR_8.5_11.3_16QAM_1ms_4xUPS.txt';
%%%%% 8 carrier LTE signal 160MHz
% InI_beforeDPD_path = 'LTE_8x20M_I_fs_1e+09_PAPR_8.4_11.0_16QAM_1ms_4xUPS.txt';
% InQ_beforeDPD_path = 'LTE_8x20M_Q_fs_1e+09_PAPR_8.4_11.0_16QAM_1ms_4xUPS.txt';
%%%%% Single carrier aggregated LTE - 80 MHz
% InI_beforeDPD_path = 'SC_80M_I_fs_1e+09_PAPR_7.9_8.7_64QAM_1ms_16xUPS.txt';
% InQ_beforeDPD_path = 'SC_80M_Q_fs_1e+09_PAPR_7.9_8.7_64QAM_1ms_16xUPS.txt';
%%%%% Single carrier aggregated LTE - 160 MHz
% InI_beforeDPD_path = 'SC_160M_I_fs_1e+09_PAPR_7.1_8.8_64QAM_1ms_8xUPS.txt';
% InQ_beforeDPD_path = 'SC_160M_I_fs_1e+09_PAPR_7.1_8.8_64QAM_1ms_8xUPS.txt';
% InI_beforeDPD_path = 'I_Input_PreDist_5r2.txt';
% InQ_beforeDPD_path = 'Q_Input_PreDist_5r2.txt';
BW = 80e6;
fG = 300e3;
PAPR_limit = 11;
FsampleTx = 400e6;
FrameTime = 0.128e-3;
%
In_I=load(InI_beforeDPD_path);
In_Q=load(InQ_beforeDPD_path);
In_I_beforeDPD=In_I;   In_Q_beforeDPD=In_Q;
[In_I_beforeDPD, In_Q_beforeDPD] = setMeanPower(In_I_beforeDPD, In_Q_beforeDPD, 0) ;
[meanPower, maxPower, PAPR_original] = checkPower(In_I_beforeDPD, In_Q_beforeDPD, 1) ;
In_I = In_I(1:round(FrameTime*FsampleTx));
In_Q = In_Q(1:round(FrameTime*FsampleTx));
In_ori = complex(In_I,In_Q);
for i = 1:10
    Y = LimitPAPR(In_ori, PAPR_limit);
%     CheckPower(Y, 1);

    Y_filtered= digital_lpf(Y, FsampleTx, BW/2);
    %CheckPower(Y_filtered, 1);
    In_ori = Y_filtered;
end
ps(In_ori, 200e6)
In_ori = digital_lpf(In_ori,FsampleTx, BW / 2);
In_I = real(In_ori); In_Q = imag(In_ori); 
PlotSpectrum(In_I, In_Q,In_I, In_Q,1,FsampleTx);


%% APPLY CALIBRAITON
%     Cal = load('IQ_Imbalance_M8190_fLO4r9GHz_BW_800MHzFreq_Domain');
    Cal = Cal.TX_CAL_RESULTS;
    iter = 3;
    [I_corr, Q_corr ] = ApplyInverseIQImbalanceFilters(In_I, In_Q, FsampleTx, ...
            Cal(iter).G.G11, Cal(iter).G.G12, Cal(iter).G.G21, Cal(iter).G.G22, Cal(iter).tones, Cal(iter).tones); 
    I_corr = real(I_corr);
    Q_corr = real(Q_corr);
    [I_corr,Q_corr] = setMeanPower(I_corr,Q_corr,0);
    
%% Upconversion the signal to AWG sampling rate    
[UpsampleTx, DownsampleTx] = rat(FsampleAWG/FsampleTx);
In_I_AWG = resample(I_corr, UpsampleTx, DownsampleTx, 500);
In_Q_AWG = resample(Q_corr, UpsampleTx, DownsampleTx, 500);
[In_I_AWG, In_Q_AWG] = setMeanPower(In_I_AWG,In_Q_AWG,0);
[meanPower, maxPower, PAPR_original] = checkPower(In_I_AWG,In_Q_AWG, 1);
PlotSpectrum(In_I_AWG, In_Q_AWG,In_I_AWG, In_Q_AWG,1,FsampleAWG);
        %%


%% AWG8241 transmitting singal
% instrumentHandle = AWG_N8241A_Setup(FsampleAWG, AWG_Gain);
% % Waveform = [In_I' + I_offset; In_Q' + Q_offset];
% Waveform = [I_corr.' + I_offset; Q_corr.' + Q_offset];
% % Upload the waveform and capture the corresponding output on PXA
% AWG_N8241A_SignalUpload(instrumentHandle, Waveform, AWG_AutoNorm);
% agt_awg_close(instrumentHandle);

%% AWG M8190 transmitting singal
% M8190 setting 
PowerBand = 0;
In_I_cal=In_I_AWG;  In_Q_cal=In_Q_AWG;
[In_I_cal, In_Q_cal]              = setMeanPower(In_I_cal, In_Q_cal, PowerBand);      % Set the mean power of the I/Q signals to be uploaded
% [In_I, In_Q]                      = setMeanPower(In_I, In_Q, 0);                      % Set the mean power of the I/Q signals to be used for DPD
% [meanPower, maxPower, PAPR_input] = checkPower(In_I_cal, In_Q_cal, 1) ;
[meanPower, maxPower, PAPR_input] = checkPower(In_I_cal, In_Q_cal, 1) ;
Amp_Corr = false;
RF_channel=1;
DAC_SamplingRate=FsampleAWG;
Expansion_Margin=0;
%     ComplexSignal{1}                  = complex(In_I_cal, In_Q_cal);
 %   Fcarrier_array{1}                 = Fcarrier ;
    ComplexSignal{1} = complex(In_I_cal, In_Q_cal);
    Fcarrier_array{1}                 = 0 ;
    FsampleTx_array{1}                = DAC_SamplingRate ;
AWG_M8190A_IQSignalUpload_ChannelSelect_FixedAvgPower(ComplexSignal, Fcarrier_array, FsampleTx_array, DAC_SamplingRate, Amp_Corr, false,RF_channel,Expansion_Margin, PAPR_input, PAPR_original, 0, 0);
AWG_M8190A_Reference_Clk('Backplane');
AWG_M8190A_DAC_Amplitude(1,0.7);
AWG_M8190A_DAC_Amplitude(2,0.7);
AWG_M8190A_MKR_Amplitude(1,1.5);       % Set the trigger amplitude to 1.5 V 
AWG_M8190A_MKR_Amplitude(2,1.5);       % Set the trigger amplitude to 1.5 V 
        %
AWG_M8190A_Output_OFF(1);
AWG_M8190A_Output_OFF(2);
        
%         %         RF_ON_Continue    = 0;
%         [RF_ON_Continue]  = PushButton_Routine (keep_RF_ON,Transmitter_type,ESGAdd,RF_channel);
        
AWG_M8190A_Output_ON(1);
AWG_M8190A_Output_ON(2);

% % Set parameters of PXA 
% FsampleRx=160e6;
% Fs=FsampleRx;
% PXAAdd                = 18;                                       % The GPIB address of the PXA
% PXA_Atten             = 10;                                       % The mechanical attenuation in dB for the PXA when dowloading the signal. From 6 to 24 with steps of 2 dB
% % Capture data using PXA
% [RecI_captured, RecQ_captured] = IQCapture_with_atten (Fcarrier, FsampleRx, FrameTime, PXAAdd, PXA_Atten);

% Set parameters of UXA 
FsampleRx=1e9;
Fs=FsampleRx;
UXAAdd                = 'GPIB0::18::INSTR';                                       % The GPIB address of the PXA
% UXA_Atten             = 20;                                       % The mechanical attenuation in dB for the PXA when dowloading the signal. From 6 to 24 with steps of 2 dB
UXA_ClockReference       = 'External';
[RecI_captured, RecQ_captured] = IQCapture_UXA (Fcarrier, FsampleRx/1.25, FrameTime, UXAAdd, UXA_Atten, UXA_ClockReference);
 ResampledRecI = RecI_captured(200:end);
 ResampledRecQ = RecQ_captured(200:end);
% ResampledRecI = RecI_captured(200:end);
% ResampledRecQ = RecQ_captured(200:end);
%
[UpsampleTx, DownsampleTx] = rat(FsampleTx/FsampleRx);
    ResampledRecI = resample(ResampledRecI,UpsampleTx,DownsampleTx,100);
    ResampledRecQ = resample(ResampledRecQ,UpsampleTx,DownsampleTx,100);
  %   PlotSpectrum(In_I, In_Q,ResampledRecI, ResampledRecQ,1,FsampleTx);
%     sig  = complex(ResampledRecI, ResampledRecQ);
%     ps(sig, FsampleTx)
%     sig_nospurs = remove_spurious_specific(sig, FsampleTx, [-50e6 0]);
%     ps(sig_nospurs, FsampleTx)
%     ResampledRecI=real(sig_nospurs);
%     ResampledRecQ=imag(sig_nospurs);
     PlotSpectrum(In_I, In_Q,ResampledRecI, ResampledRecQ,8,FsampleTx);
  %  
    
    %
    data_length = length(In_I);
    %
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp([' Input Signal']);
    checkPower(In_I, In_Q,1);
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp([' Output Signal']);
    checkPower(ResampledRecI, ResampledRecQ,1);
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    
    [In_I, In_Q, ResampledRecI, ResampledRecQ]  = AdjustPowerAndPhase(In_I, In_Q, ResampledRecI, ResampledRecQ, 0);
    [In_I, In_Q, out_I1, out_Q1]                = UnifyLength(In_I, In_Q, ResampledRecI, ResampledRecQ);
    
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, timedelay1] = AdjustDelay(In_I, In_Q, out_I1, out_Q1,FsampleTx,1000) ;
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;
    PlotGain(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
    PlotAMPM(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
    
    sig  = complex(DelayAdjusted_Out_I(1:20001), DelayAdjusted_Out_Q(1:20001));
    ps(sig, FsampleTx)
    sig_nospurs = remove_spurious_specific(sig, FsampleTx, [-50e6 0]);
    ps(sig_nospurs, FsampleTx)
    ResampledRecI_ACP=real(sig_nospurs);
    ResampledRecQ_ACP=imag(sig_nospurs);
    PlotSpectrum(In_I, In_Q,ResampledRecI_ACP, ResampledRecQ_ACP,10,FsampleTx);
    
    
    
    % PlotSpectrum(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
    
    [EVM_dB EVM_perc] = EVM_calculate (DelayAdjusted_In_I,DelayAdjusted_In_Q,DelayAdjusted_Out_I,DelayAdjusted_Out_Q);
    [freq, spectrum] = Calculated_Spectrum(ResampledRecI_ACP, ResampledRecQ_ACP,FsampleTx);
    [ACLR_L, ACLR_U] = Calculate_ACLR (freq, spectrum, 0, BW, fG);
    [ACPR_L, ACPR_U] = Calculate_ACPR (freq, spectrum, 0, BW, fG);
    [meanPower, maxPower, PAPRin] = checkPower(DelayAdjusted_In_I,DelayAdjusted_In_Q,0);
    [meanPower, maxPower, PAPRout] = checkPower(DelayAdjusted_Out_I,DelayAdjusted_Out_Q,0);

       
    display([ 'EVM          = ' num2str(EVM_perc)      ' % ' ]);
    display([ 'ACLR (L/U)   = ' num2str(ACLR_L) ' / '  num2str(ACLR_U) ' dB ' ]);
    display([ 'ACPR (L/U)   = ' num2str(ACPR_L) ' / '  num2str(ACPR_U) ' dB ' ]);
    
%% DE measurement
V_m = PS_m.voltage(PS_m_chan);
Vg_m = PS_m.voltage(3);
Vg_a = PS_m.voltage(4);
I_m = PS_m.current(PS_m_chan);
V_a = PS_a.voltage;
I_a = PS_a.current;
%     
p_out = PM.measure;
SG.rf(0);
SG.modulation_off% measurement end
        
fprintf('P_out is %2.4f \n', p_out);
fprintf('I_m is %2.4f \n', I_m);
fprintf('I_a is %2.4f \n', I_a);                        
        
       % gain = p_out-p_in;
 %       fprintf('Gain is %2.4f \n', gain);
        p_out_w = 10^((p_out-30)/10); % p_out in Watts
  %      p_in_w = 10^((p_in-30)/10); % p_in in Watts
        p_dc = (V_m*I_m+V_a*I_a);
        DE = 100*p_out_w/p_dc;
        fprintf('DE is %3.2f\n', DE);
        fprintf('---------------\n');
PushButton_Save_Result    
    
%% Saving Measurement Results - With DPD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Making measurement directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
cd([pwd '\Measurements']);
% time_now = clock;
% dir_name = strcat('4r9GHz',date,'_',int2str(time_now(4)),'_',int2str(time_now(5)),'_',int2str(time_now(6)));
mkdir(dir_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Writing files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(dir_name)
%%%% Input signal before DPD
fidIEH = fopen(['I_Input_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',DelayAdjusted_In_I);
fclose(fidIEH);
fidIEH = fopen(['Q_Input_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',DelayAdjusted_In_Q);
fclose(fidIEH);
%
fidIEH = fopen(['I_Output_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',DelayAdjusted_Out_I);
fclose(fidIEH);
fidIEH = fopen(['Q_Output_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',DelayAdjusted_Out_Q);
fclose(fidIEH);
cd ..
cd ..
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Saving Measurement Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Writing files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd('Measurements')
cd(dir_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Wirting Summary file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fidIEH = fopen(['Summary.txt'],'wt');
% fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
fprintf(fidIEH,'Carrier Frequency = %4.3f GHz \n ',Fcarrier/1e9);
fprintf(fidIEH,'Signal BW = %4.3f MHz \n ',BW/1e6);
fprintf(fidIEH,['Signal Name (I) = ',InI_beforeDPD_path, '\n ']);
fprintf(fidIEH,['Signal Name (Q) = ',InQ_beforeDPD_path, '\n ']);
% fprintf(fidIEH,'ESG/PSG Power = %4.3f \n ',PowerBand);
fprintf(fidIEH,'DPD sampling rate = %4.3f MHz \n ',Fs/1e6);
fprintf(fidIEH,'Main gate bias = %4.3f V \n ',-Vg_m);
fprintf(fidIEH,'Aux. gate bias = %4.3f V \n ',-Vg_a);
% fprintf(fidIEH,'Internal Rx down/upsampling rate = %4.3f / %4.3f \n ',DownsampleRx,UpsampleRx);
% fprintf(fidIEH,'Internal Tx down/upsampling rate = %4.3f / %4.3f \n ',DownsampleTx,UpsampleTx);
% fprintf(fidIEH,'DPD Iteration = %4.3f \n ',IterationCount);

fprintf(fidIEH,'\nWithout DPD Results \n ');
fprintf(fidIEH,'EVM (%%) = %4.3f \n ',EVM_perc);   
fprintf(fidIEH,'ACLR_L/ACLR_U = %4.3f / %4.3f \n ',ACLR_L,ACLR_U);
fprintf(fidIEH,'ACPR_L/ACPR_U = %4.3f / %4.3f \n ',ACPR_L,ACPR_U);
fprintf(fidIEH,'PAPRin = %4.3f \n ',PAPRin);
fprintf(fidIEH,'PAPRout = %4.3f \n ',PAPRout);

% if strcmp(Measure_Pout_Eff,'True')
%     fprintf(fidIEH,'\n');
%     fprintf(fidIEH,'With DPD Measurements');
%     fprintf(fidIEH,'\nPout  = %4.3f   dBm ', Pout_measured_with_DPD);
%     fprintf(fidIEH,'\nVdd   = %4.3f   V', V_m_with_DPD);
%     fprintf(fidIEH,'\nIdd   = %4.3f   mA', I_m_with_DPD*1e3);
%     fprintf(fidIEH,'\nDE    = %4.3f  %',DE_measured_with_DPD);
%     fprintf(fidIEH,'\nPAE   =        %');
fprintf(fidIEH,'\n');
fprintf(fidIEH,'Without DPD Measurements');
fprintf(fidIEH,'\nPin of PSG  = %4.3f   dBm ', p_sg);
fprintf(fidIEH,'\nPout  = %4.3f   dBm ', p_out);
fprintf(fidIEH,'\nVdd   = %4.3f   V', V_m);
fprintf(fidIEH,'\nIddm   = %4.3f   mA', I_m*1e3);
fprintf(fidIEH,'\nIdda   = %4.3f   mA', I_a*1e3);
fprintf(fidIEH,'\nDE    = %4.3f  %',DE);
fprintf(fidIEH,'\nPAE   =        %');
% else
%     fprintf(fidIEH,'\n');
%     fprintf(fidIEH,'\nPout   =        dBm ');
%     fprintf(fidIEH,'\nVdd    = 28     V');
%     fprintf(fidIEH,'\nIdd    =        mA');
%     fprintf(fidIEH,'\nDE     =        %');
%     fprintf(fidIEH,'\nPAE    =        %');
% end
fclose(fidIEH);
cd ..
cd ..
