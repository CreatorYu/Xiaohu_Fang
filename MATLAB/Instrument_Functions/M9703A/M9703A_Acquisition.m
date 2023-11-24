function [WaveformArray,ActualPoints,FirstValidPoint,InitialXOffset,InitialXTimeSeconds,InitialXTimeFraction,XIncrement] = M9703A_Acquisition(InstrumentObj, Channel, PointsPerRecord, SamplingFrequency, FullScaleRange, ACDCCoupling)
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

	
% Create pointers to Channel1 channel and trigger source objects
    [pCh1] = InstrumentObj.DeviceSpecific.Channels.Item(Channel);
    
% Setup acquisition - Records must be 1 for Channel.Measurement methods.
% For multiple records use Channel.MutiRecordMeasurement methods.
    InstrumentObj.DeviceSpecific.Acquisition.WaitForAcquisitionComplete(1000);
	InstrumentObj.DeviceSpecific.Acquisition.ConfigureAcquisition(1, PointsPerRecord, SamplingFrequency); % Records, PointsPerRecord, SampleRate
    pCh1.Configure(FullScaleRange, 0.0, ACDCCoupling, true); % Range, Offset, Coupling, Enabled 

% Size waveform array as required and measure
    arrayElements = InstrumentObj.DeviceSpecific.Acquisition.QueryMinWaveformMemory(64,1,0,PointsPerRecord);
    WaveformArray = zeros(arrayElements,1);
    disp(sprintf('Measuring Waveform on %s...',Channel));
    InstrumentObj.DeviceSpecific.Calibration.SelfCalibrate(4,str2num(Channel(8)));
 	[WaveformArray,ActualPoints,FirstValidPoint,InitialXOffset,InitialXTimeSeconds,InitialXTimeFraction,XIncrement] = pCh1.Measurement.ReadWaveformReal64(1000, WaveformArray );
    
    
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
        
    
    

    