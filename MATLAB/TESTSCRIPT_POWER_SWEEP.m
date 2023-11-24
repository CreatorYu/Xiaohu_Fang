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
startFreq   = 20e9;
stopFreq    = 30e9;
cwFreq      = 28e9;
startPow    = -20;
stopPow     = 0;
numOfPoints = 21;
ifBandwidth = 100e3;
includePAE  = 0; 

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
    
    % window5
    if includePAE == 1
        [activateSMU] = ActiveSMUReminder()
        if activateSMU == 1
            PNA_obj.CreateMeasurement(1,'DC1_AM1',1,5)      % Pout
            PNA_obj.CreateMeasurement(1,'DC1_VM1',1,5)      % Pout
        end
    end
    
    PNA_obj.ActivateWindow(1)
    PNA_obj.Channels.Item(1).StartFrequency   = startFreq;
    PNA_obj.Channels.Item(1).StopFrequency    = stopFreq;
    PNA_obj.Channels.Item(1).set('TestPortPower', 1, -20); % -20 dBm input power as a pre-caution
    PNA_obj.Channels.Item(1).NumberOfPoints   = numOfPoints;
end

%% Conduct Power Cal in PNA-X
[sourceCal]   = PowerSweepSourceCalReminder();
[rxCal]       = PowerSweepRxCalReminder();


%% window 6 for PAE and DE
    PNA_obj.CreateMeasurement(1,'B',1,6)   % Gain 
    PAE_equation = '100 * (.001*pow(mag(Tr2),2)-(.001*pow(mag(Tr2),2)/pow(mag(Tr3),2)))/(Tr5*Tr6)';
    setEquation(PNA_obj, PAE_equation)
    PNA_obj.ActiveMeasurement.Format = 6;  
    PNA_obj.ActiveMeasurement.Trace.AutoScale;
    
    PNA_obj.CreateMeasurement(1,'B',1,6)   % Gain 
    DE_equation = '100 * (.001*pow(mag(Tr2),2))/(Tr5*Tr6)';
    setEquation(PNA_obj, DE_equation)
    PNA_obj.ActiveMeasurement.Format = 6;  
   
    PNA_obj.ActiveMeasurement.NAWindow.ScaleCouplingMethod = 1;
    PNA_obj.ActiveMeasurement.Trace.AutoScale;
    
 %% obtain results at a single CW freq   
if sourceCal && rxCal == 1
    
    cwFreq      = 2.2e9;
    startPow    = -10;
    stopPow     = 10;
    setPowerSweep(PNA_obj, cwFreq, startPow, stopPow, numOfPoints, ifBandwidth);
    
    traceIndexArray = [1, 2, 3, 4, 7, 8];
    [results] = PA_results_capture(traceIndexArray, PNA_obj)
    
end

%% wide-band test script 
cwFreqArray = 20e9:1e9:30e9;
for ind = 1 : length(cwFreqArray)
    setPowerSweep(PNA_obj, cwFreqArray(ind), startPow, stopPow, numOfPoints, ifBandwidth);
    %PNA_obj.Channels.Item(1).Single
    pause(1)
    PA_Results(ind) = PA_results_capture_no_PAE(traceIndexArray, PNA_obj);
    pause(1)
end

%% real-time display for tuning
ind = 0;
while(1)
    Pin.dbm         = PNA_read_trace(Pin.traceID,  PNA_obj, 'dBm');
    Pout.dbm       = PNA_read_trace(Pout.traceID, PNA_obj, 'dBm');
    Gain = Pout.dbm - Pin.dbm;
    pause(1);
%     plot(Pout.dbm(2:end), Gain(2:end));
plot(gain_compression(Pout.dbm, Gain), '*');
    ind = ind + 1;
end





