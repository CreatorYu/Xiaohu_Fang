%Clearing and preset
close all
clear all
clc
 
%% Initialize PNA driver 
PNA_Address = 'AgilentPNA835x.Application';
PNA_obj       = actxserver (PNA_Address, 'machine', '10.0.0.10');
fprintf('Connected to PNA-X\n'); 
% 

%% Set Parameters
startFreq   = 0.1e9;
stopFreq    = 6e9;
cwFreq      = 0.9e9;
startPow    = -20;
stopPow     = 0;
numOfPoints = 100;
ifBandwidth = 100e3;

%% Set up Windows
[setUpwindow] = PowerSweepClearDisplayRoutine();
if setUpwindow == 1
    PNA_obj.Preset;
	
    % window1
    PNA_obj.ActiveMeasurement.ChangeParameter('R1',1);
    
    % window2
    PNA_obj.CreateMeasurement(1,'B',1,2)      % Pout
    
    % window3
    PNA_obj.CreateMeasurement(1,'B/R1',1,3)   % Gain
    setEquation(PNA_obj, 'Tr2/Tr1')   
    
       % window4
    PNA_obj.CreateMeasurement(1,'B/R1',1,4);  % AMPM
    setEquation(PNA_obj, 'Tr2/Tr1')
    PNA_obj.ActiveMeasurement.Format = 2;     % 2 - display in phase
    
    PNA_obj.ActivateWindow(1)
    PNA_obj.Channels.Item(1).StartFrequency   = startFreq;
    PNA_obj.Channels.Item(1).StopFrequency    = stopFreq;
    PNA_obj.Channels.Item(1).set('TestPortPower', 1, -5); % -20 dBm input power as a pre-caution
    PNA_obj.Channels.Item(1).NumberOfPoints   = numOfPoints;
end

%% Conduct Power Cal in PNA-X
[sourceCal]   = PowerSweepSourceCalReminder();
[rxCal]       = PowerSweepRxCalReminder();

   
    PNA_obj.ActiveMeasurement.NAWindow.ScaleCouplingMethod = 1;
    PNA_obj.ActiveMeasurement.Trace.AutoScale;
    
 %% obtain results at a single CW freq   
cwFreqArray = 5.0e9:0.025e9:5.0e9;
for ind = 1 : length(cwFreqArray)
    startPow    = -6;
    stopPow     = -6;
    setPowerSweep(PNA_obj, cwFreqArray(ind), startPow, stopPow, numOfPoints, ifBandwidth); 
    pause(1)
    AMAM{ind} = PNA_read_trace(3, PNA_obj, 'dBm'); 
    Pin{ind} = PNA_read_trace(1, PNA_obj, 'dBm');  
    pause(1)
end
 

%% wide-band test script 
cwFreqArray = 5e9:0.025e9:6e9;
for ind = 1 : length(cwFreqArray)
    startPow    = -10;
    stopPow     = 8;
    setPowerSweep(PNA_obj, cwFreqArray(ind), startPow, stopPow, numOfPoints, ifBandwidth); 
    pause(1)
    AMAM{ind} = PNA_read_trace(3, PNA_obj, 'dBm'); 
    Pin{ind} = PNA_read_trace(1, PNA_obj, 'dBm');  
    pause(1)
end


%% Plot
figure; hold on;
for ind =1:length(cwFreqArray); plot(Pin{ind}, AMAM{ind}); end;

