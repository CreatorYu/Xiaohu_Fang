function [WaveformArray,ActualPoints,FirstValidPoint,InitialXOffset,InitialXTimeSeconds,InitialXTimeFraction,XIncrement] = M9703A_Acquisition_64bit(myDigitizer, Channel, PointsPerRecord, SamplingFrequency, FullScaleRange, ACDCCoupling)
% Acquire the Waveform Array from the Instrument
% In Digitizer Mode the Array contains the values of the signal capture.
% In Downconversion Mode the Array contains the values of the
% real part and the imaginary part of signal interleaved.
% - Channel - String value to specify the channel for the downconversion
% configuration. Possible values are Channel1, ...,Channel<n>  where <n> is
% the number of channel input.
% - PointsPerRecord - Number of Samples to be recorded
% - SamplingFrequency - Specify the sampling frequency in Hz.
% In Downconversion Mode, the possible values are 250e6, 125e6, 62.5e6, 31.25e6
% In Digitizer Mode, any value below 1e9
% - FullScaleRange - Specify the full scale range. Possible values are 1
% and 2 Volts.
% - ACDCCoupling - Possible values are 0 for AC, 1 for DC and 2 for GND

% Configure Channels
Offset = 0;
invoke(myDigitizer.Configurationchannel, 'configurechannel', Channel,...
    FullScaleRange, Offset, ACDCCoupling, true);
% Set the acquisition parameters
invoke(myDigitizer.Waveformacquisitionlowlevelacquisition, ...
    'waitforacquisitioncomplete', 1000);
invoke(myDigitizer.Configurationacquisition, 'configureacquisition',...
    1, PointsPerRecord, SamplingFrequency);

% Size waveform array as required and measure
arrayElements = get(myDigitizer.Waveformacquisition, 'Min_Record_Size');
WaveformArray = zeros(arrayElements,1);
% Measurements
fprintf('Measuring Waveform on %s...', Channel);
invoke(myDigitizer.Instrumentspecificcalibration,...
    'calibrationselfcalibrate',4,str2double(Channel(8)));   % fast cal
[WaveformArray,ActualPoints,FirstValidPoint,InitialXOffset,InitialXTimeSeconds,InitialXTimeFraction,XIncrement] ...
    = invoke(myDigitizer.Waveformacquisition, 'readwaveformreal64', Channel, 1000, arrayElements, WaveformArray);

switch FullScaleRange
    case 1
        if max(abs(WaveformArray))>0.3
            msgbox('ADC Over Range', 'Error');
        end
    case 2
        if max(abs(WaveformArray))>0.7
            msgbox('ADC Over Range', 'Error');
        end
    otherwise
        return
end
