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
startFreq   = 1e9;
stopFreq    = 3e9;
cwFreq      = 2.2e9;
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
    PNA_obj.ActiveMeasurement.ChangeParameter('R1',1);  % Src 1
    
    % window2
    PNA_obj.CreateMeasurement(1,'R3',3,2)               % Src2
    
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


%%

setPowerSweep(PNA_obj, 1e9, -20, -20, numOfPoints, ifBandwidth);

% Port 1 and Port 3 are ON. Port 2 and Port 4 are OFF
PNA_obj.Channels.Item(1).set('SourcePortMode', 1, 1);  % 1 - ON
PNA_obj.Channels.Item(1).set('SourcePortMode', 2, 2);  % 2 - OFF
PNA_obj.Channels.Item(1).set('SourcePortMode', 3, 1);  
PNA_obj.Channels.Item(1).set('SourcePortMode', 4, 2);  
PNA_obj.Channels.Item(1).set('TestPortPower',  1, -20); % -20 dBm input power as a pre-caution
PNA_obj.Channels.Item(1).set('TestPortPower',  3, -20); % -20 dBm input power as a pre-caution

% Enable Phase Control
PNA_obj.Channels.Item(1).PhaseControl.set('PhaseControlMode', 1, 3);       % 3 - less accurate 
PNA_obj.Channels.Item(1).PhaseControl.set('PhaseControlMode', 3, 3); 

% Set Fixed Phase Control
portNum = 3;
phaseVal = 0;
setPNASrcPhase(PNA_obj, portNum, phaseVal)


