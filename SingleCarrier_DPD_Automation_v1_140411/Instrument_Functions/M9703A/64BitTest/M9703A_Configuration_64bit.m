function [InstrumentObj] = M9703A_Configuration_64bit(VisaAddress, ReferenceSource, TriggerSource, TriggerLevel)
% Configure the instrument with the following parameters
% - VisaAddress - String value to specify the visa address for the M9703A. It sould be in the format
% 'PXI21::0::0::INSTR'
% - ReferenceSource - String value to specify the Reference Oscillator
% Source. Possible values are
% 'AgMD1ReferenceOscillatorSourceInternal','AgMD1ReferenceOscillatorSourceAXI'
% and 'AgMD1ReferenceOscillatorSourceExternal' for Internal Source, AXI
% Backplane source (used to synchronize with the AWG) and External Source, respectively.
% - TriggerSource - String value to specify the Source of Trigger. Possible values are Channel1, ...,
% Channel<n> or External1, ..., External<n> trigger sources where <n> is
% the number of available channels or external trigger inputs.
% - TriggerLevel - The Level of the Trigger in Volts

% based on AgMD1_64bit.mdd. Use midedit to view it for reference purpose

% Create driver instance
initOptions = 'Simulate=false, DriverSetup= Cal=0, Trace=false';
myDigitizer = icdevice('AgMD1_64bit.mdd', VisaAddress, 'optionstring', initOptions);

disp('M9703A Driver Initialized');
% Connect to the digitizer using the device object created above
connect(myDigitizer);
% Abort present acquisition if any
invoke(myDigitizer.Waveformacquisitionlowlevelacquisition, 'abort');

% Set the individual channel parameters

% Setup External Clock from AXIe backplane (sync with source)
%{
    0-AgMD1ReferenceOscillatorSourceInternal
    1-AgMD1ReferenceOscillatorSourceExternal
    2-AgMD1ReferenceOscillatorSourcePXIClk10
    3-AgMD1ReferenceOscillatorSourcePXIeClk100
    4-AgMD1ReferenceOscillatorSourceAXIeClk100
%}
switch ReferenceSource
    case 'AgMD1ReferenceOscillatorSourceAXI'
        Reference_Oscillator = 4;
    case 'AgMD1ReferenceOscillatorSourceExternal'
        Reference_Oscillator = 2;
    otherwise
        error('Reference Source Not Recognised');
end
set(myDigitizer.Referenceoscillator, 'Reference_Oscillator_Source', Reference_Oscillator);

% Set the trigger source, and trigger type
TriggerSlope = 1; %0 = Negative %1 = Positive
invoke(myDigitizer.Configurationtrigger,'configureedgetriggersource',...
    TriggerSource, TriggerLevel, TriggerSlope);

% Check for Calibration
% If a calibration is required, calibrate
if invoke(myDigitizer.Instrumentspecificcalibration,...
        'calibrationcalrequired',0) == 1
   Cal_Type = 0;
   %Others include
   %{
   0-AGMD1_VAL_CALIBRATE_TYPE_FULL
   1-AGMD1_VAL_CALIBRATE_TYPE_CHANNEL_CONFIGURATION
   2-AGMD1_VAL_CALIBRATE_TYPE_EXT_CLOCK_TIMING
   3-AGMD1_VAL_CALIBRATE_TYPE_CURRENT_FREQUENCY
   4-AGMD1_VAL_CALIBRATE_TYPE_FAST
   %}
   % Calibrate
   disp('Calibrating...')
   invoke(myDigitizer.Instrumentspecificcalibration,...
       'calibrationselfcalibrate',Cal_Type,0);
   disp('Calibration Complete')
end

InstrumentObj = myDigitizer;
