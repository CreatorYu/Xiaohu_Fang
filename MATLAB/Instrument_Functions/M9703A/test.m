% Create a device object. 
deviceObj = icdevice('AgMD1_AgMD1.mdd', 'PXI21::0::0::INSTR');

% Connect device object to hardware.
connect(deviceObj);

% Query property value(s).
get(deviceObj, 'InstrumentModel')

% Execute device object function(s).
geterror(deviceObj)

% Create pointers to Channel1 channel and trigger source objects
[pCh1] = deviceObj.Channel(1);
[pTrigSrc] = deviceObj.Trigger(1);

% Setup acquisition - Records must be 1 for Channel.Measurement methods.
% For multiple records use Channel.MutiRecordMeasurement methods.
% PointsPerRecord = 100;
% INVOKE(deviceObj,'configureacquisition',1,PointsPerRecord,1.0E9)
% deviceObj.Configurationacquisition1(1, PointsPerRecord, 1.0E9); % Records, PointsPerRecord, SampleRate
% deviceObj.Configurationchannel1(1.0, 0.0, 1, true); % Range, Offset, Coupling, Enabled

PointsPerRecord = 100;
set(pCh1, 'Range', 1);
get(pCh1, 'Range')

set(deviceObj.Acquisition,'RecordSize',PointsPerRecord)
get(deviceObj.Acquisition,'RecordSize')

 % Calibrate and measure waveform
    disp('Calibrating Channel1...');
    invoke(deviceObj.Calibration1,'SelfCalibrate',0,1);   % 0=AgMD1CalibrateTypeFull

 % Size waveform array as required and measure
    arrayElements = invoke(deviceObj.Acquisition1,'QueryMinWaveformMemory',64,1,0,PointsPerRecord);
    WaveformArray = zeros(arrayElements,1);
   
    disp('Measuring Waveform on Channel1...');
    [WaveformArray,ActualPoints,FirstValidPoint,InitialXOffset,InitialXTimeSeconds,InitialXTimeFraction,XIncrement] = invoke(deviceObj.Channelmeasurement1,'ReadWaveformReal64',2000,WaveformArray);
      
    
comobj = deviceObj.Channelmeasurement.Parent;
comobj = comobj.Interface;
comobj = comobj.Channels;
name = comobj.Name(deviceObj.Channelmeasurement.HwIndex);
comobj = comobj.Item(name);
comobj = comobj.Measurement;

feature('COM_SafeArraySingleDim',1);
[WaveformArray, ActualPoints, FirstValidPoint, InitialXOffset, InitialXTimeSeconds, InitialXTimeFraction, XIncrement] = Interface.IVI_AgMD1_1.4_Type_Library.IAgMD1ChannelMeasurement.ReadWaveformReal64(int32(2000));
feature('COM_SafeArraySingleDim',0);
    
    
	voltsMax = pCh1.Measurement.FetchWaveformMeasurement(6); % 6=AgMD1MeasurementVoltageMax
    voltsMin = pCh1.Measurement.FetchWaveformMeasurement(7); % 7=AgMD1MeasurementVoltageMin
	voltsAvg = pCh1.Measurement.FetchWaveformMeasurement(10); % 10=AgMD1MeasurementVoltageAverage
    disp(blanks(1));    
    
% Execute device object function(s).
% invoke(deviceObj, 'initwithoptions', 'PXI21::0::0::INSTR',true,true,'Simulate=false, DriverSetup= Cal=0, Trace=false');
% groupObj = get(deviceObj, 'Waveformacquisitionlowlevelacquisition');
% groupObj = groupObj(1);

% groupObj = get(deviceObj, 'Acquisition');
% groupObj = groupObj(1);
% invoke(groupObj, 'Initiate');
% invoke(groupObj, 'WaitForAcquisitionComplete', 20);
% 
% groupObj = get(deviceObj, 'Trigger');
% groupObj = groupObj(1);
% invoke(groupObj, 'SendSoftwareTrigger');
% 
% groupObj = get(deviceObj, 'Waveformacquisitionlowlevelacquisitionmultirecordacquisition');
% groupObj = groupObj(1);
% 
% invoke(groupObj, 'fetchmultirecordwaveformint16', 'Channel1', 0, 1, 0, 10000, 20064,[] ,[] ,[],[] ,[] ,[]);
% groupObj = get(deviceObj, 'Waveformacquisitionlowlevelacquisitionmultirecordacquisition');
% groupObj = groupObj(1);

% Disconnect device object from hardware.
disconnect(deviceObj);