clc
clear
close all
path('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\usefull functions',path);
path('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Doherty_wideband\Measurement13-Apr-2023_20_20_7',path);
%addpath(genpath('D:\Matlab\Xiaohu_Fang\EmRG_Code\TX_Calibration\Utility_Functions'));
path(' D:\Matlab\Xiaohu_Fang\MATLAB',path);
path('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\usefull functions\delayAdjustment',path);
j=sqrt(-1);
% a=rand(2000,1);
% 
% load('64QAM_PAPR_6_6dB.mat','a');
 freq=4.4e9;
Fs=500e6;
fG        = 2000e3;       % Gaurd band for the modulated signal - Used to calculated ACLR and ACPR from the downloaded I/Q signals
BW        = 100e6; 
%
FsampleTx=500e6; 
FsampleRx=500e6; 
InI = load('I_Input_NoDPD_1.txt');
InQ = load('Q_Input_NoDPD_1.txt');
OutI_WithDPD= load('I_Output_WithDPD_1.txt');
OutQ_WithDPD= load('Q_Output_WithDPD_1.txt');
OutI_WithoutDPD= load('I_Output_WithoutDPD.txt');
OutQ_WithoutDPD= load('Q_Output_WithoutDPD.txt');
In=InI+j*InQ;
In_I_withDPD=InI;
In_Q_withDPD=InQ;
Out_WithDPD=OutI_WithDPD+j*OutQ_WithDPD;
Out_WithoutDPD=OutI_WithoutDPD+j*OutQ_WithoutDPD;
[UpsampleTx, DownsampleTx] = rat(FsampleTx/FsampleRx);
%In_I_withoutDPD = resample(In_I_withoutDPD,UpsampleTx,DownsampleTx);
%In_Q_withoutDPD = resample(In_Q_withoutDPD,UpsampleTx,DownsampleTx);
%%
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, timedelay1] = AdjustDelay(InI, InQ, OutI_WithDPD, OutQ_WithDPD,Fs,2000) ;
    [DelayAdjusted_WoDPD_I, DelayAdjusted_WoDPD_Q, DelayAdjusted_Out_I2, DelayAdjusted_Out_Q2, timedelay2] = AdjustDelay(OInI, InQ, OutI_WitouthDPD, OutQ_WithoutDPD,Fs,2000) ;
    %
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;
    [DelayAdjusted_WoDPD_I, DelayAdjusted_WoDPD_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_owo_I,DelayAdjusted_owo_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;
    PlotGain(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
    PlotAMPM(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
    
    %PlotSpectrum(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayA)
    
    [UpsampleACP, DownsampleACP] = rat(5*BW/FsampleRx);
    OUT_I_ACP = resample(DelayAdjusted_Out_I, UpsampleACP, DownsampleACP, 500);
    OUT_Q_ACP = resample(DelayAdjusted_Out_Q, UpsampleACP, DownsampleACP, 500);
             % Remove the spurious
     sig  = complex(OUT_I_ACP(1:9000), OUT_Q_ACP(1:9000));
 %  ps(sig, FsampleRx);
    sig_nospurs = remove_spurious_specific(sig, 5*BW, [0 0]);
    OUT_I_ACP=real(sig_nospurs);
    OUT_Q_ACP=imag(sig_nospurs); 
    [OUT_I_ACP, OUT_Q_ACP] = setMeanPower(OUT_I_ACP,OUT_Q_ACP,0);
    PlotSpectrum(DelayAdjusted_WoDPD_I, DelayAdjusted_WoDPD_Q,OUT_I_ACP, OUT_Q_ACP,5*BW);
%%%
[EVM_dB EVM_perc]                = EVM_calculate (DelayAdjusted_In_I,DelayAdjusted_In_Q,DelayAdjusted_Out_I,DelayAdjusted_Out_Q);

