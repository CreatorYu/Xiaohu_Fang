%Clearing and preset
close all
clear all
clc
 
%% Initialize PNA driver 
PNA_Address = 'AgilentPNA835x.Application';
PNA_obj = actxserver (PNA_Address, 'machine', '10.0.0.10');
fprintf('Connected to PNA-X\n'); 
PNA_obj.Preset

%% Set Parameters
startFreq   = 10e6;
stopFreq    = 67e9;
powerPort   = 0; 
numOfPoints = 1601;
ifBandwidth = 100e3;

setFreqSweep(PNA_obj, startFreq, stopFreq, powerPort, numOfPoints, ifBandwidth);
setFreqSweepQuadDisplay(PNA_obj);


%% Save snp
