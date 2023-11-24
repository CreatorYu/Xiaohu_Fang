clc 
close all
clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Set DPD parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DPD_type = 'Dualband_Volterra';
% DPD_type = 'Dualband_MP';
Fcarrier1 = 2.05e9;
Fcarrier2 = 2.15e9;
Fsample = 100e6;
FramTime = 1e-3;
PowerBand1 = -40; % in dBm for ESG1
PowerBand2 = -40; % in dBm for ESG2
fG = 300e3;
BW = 5e6;

NofIteration = 12; % No of DPD Iterations

WaveformName = 'WCDMA_1C';
NofDPDPoints = 1e4;

DelayMethod ='MutualInfo' ;

FsampleTx = Fsample; % ESG sampling rate
FsampleRx = Fsample; % PXA sampling rate

Internal_OSR = 4;

fs_original=100e6/Internal_OSR;
fs_target=100e6/Internal_OSR;
Fs=fs_target;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Instruments addresses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ESG1Add = 19; %'GPIB0::19::INSTR'; %    This is the master ESG
ESG2Add = 20; %'GPIB0::20::INSTR';
PXAAdd = 18; %'GPIB0::18::INSTR';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Reading input files 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InI_beforeDPD1_path = '2.05GHz_100MHzWCDMA3G_1C_In_I(0300)_input.txt';
InQ_beforeDPD1_path = '2.05GHz_100MHzWCDMA3G_1C_In_Q(0300)_input.txt';
InI_beforeDPD2_path = '2.15GHz_100MHzWCDMA3G_1C_In_I(1200)_input.txt';
InQ_beforeDPD2_path = '2.15GHz_100MHzWCDMA3G_1C_In_Q(1200)_input.txt';

% In_I_beforeDPD1 = dlmread(InI_beforeDPD1_path, '\t'); In_I_beforeDPD1 = In_I_beforeDPD1(:, 1);
% In_Q_beforeDPD1 = dlmread(InQ_beforeDPD1_path, '\t'); In_Q_beforeDPD1 = In_Q_beforeDPD1(:, 1);
% In_I_beforeDPD2 = dlmread(InI_beforeDPD2_path, '\t'); In_I_beforeDPD2 = In_I_beforeDPD2(:, 1);
% In_Q_beforeDPD2 = dlmread(InQ_beforeDPD2_path, '\t'); In_Q_beforeDPD2 = In_Q_beforeDPD2(:, 1);

In_I_beforeDPD1 = load(InI_beforeDPD1_path); In_I_beforeDPD1 = In_I_beforeDPD1(:, 1);
In_Q_beforeDPD1 = load(InQ_beforeDPD1_path); In_Q_beforeDPD1 = In_Q_beforeDPD1(:, 1);
In_I_beforeDPD2 = load(InI_beforeDPD2_path); In_I_beforeDPD2 = In_I_beforeDPD2(:, 1);
In_Q_beforeDPD2 = load(InQ_beforeDPD2_path); In_Q_beforeDPD2 = In_Q_beforeDPD2(:, 1);

In_I1 = In_I_beforeDPD1;
In_Q1 = In_Q_beforeDPD1;
In_I2 = In_I_beforeDPD2;
In_Q2 = In_Q_beforeDPD2;

cd '../SignalUpload'    
SignalName1 = [WaveformName];
SignalName2 = [WaveformName];

%%%%% Uploading signals to both ESGs

ESG_RF_OFF (ESG1Add, ESG2Add)    

IQUpload ( In_I1', In_Q1', In_I2', In_Q2', PowerBand1, PowerBand2, Fcarrier1, Fcarrier2, FsampleTx, ESG1Add, ESG2Add,SignalName1,SignalName2);   

% ESG_RF_ON (ESG1Add, ESG2Add)


