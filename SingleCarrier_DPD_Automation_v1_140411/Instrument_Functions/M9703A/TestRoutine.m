%% Signal Transmission Initialization

OrI1_path = '1111_In_I.txt' ;
OrQ1_path = '1111_In_Q.txt' ;

Fcarrier1 = 62.5e6 ;
FsampleTx1 = 100e6 ;
FramTime = 1e-3 ;
data_length = 70e3 ;
NbOfPoint = data_length ;
CDTRFTB = 0 ;
PowerBand1 = 20 ;
PXA_Atten1 = 10 ;

[UpSample, DownSample] = rat(100/92.16) ;
Or_I1 = loadfile(OrI1_path, NbOfPoint+CDTRFTB) ; Or_I1 = resample(Or_I1, UpSample, DownSample) ; Or_I1 = Or_I1(CDTRFTB+1:end) ;
Or_Q1 = loadfile(OrQ1_path, NbOfPoint+CDTRFTB) ; Or_Q1 = resample(Or_Q1, UpSample, DownSample) ; Or_Q1 = Or_Q1(CDTRFTB+1:end) ;
[Or_I1, Or_Q1] = setMeanPower(Or_I1, Or_Q1, PowerBand1) ;
Pr_I1 = Or_I1 ;
Pr_Q1 = Or_Q1 ;
In_I1 = Pr_I1 ;
In_Q1 = Pr_Q1 ;
[In_I1, In_Q1] = setMeanPower(In_I1, In_Q1, PowerBand1) ;
ComplexSignal{1} = complex(In_I1, In_Q1);
Fcarrier{1} = Fcarrier1 ;
FsampleTx{1} = FsampleTx1 ;

%% Signal Reception Initialization
    % Create driver instance
    driver = instrument.driver.AgMD1();

    % Edit resource and options as needed.  Resource is ignored if option Simulate=true
    resourceDesc = 'PXI21::0::0::INSTR';

    initOptions = 'Simulate=false, DriverSetup= Cal=0, Trace=false';			
    idquery = true;
    reset   = true;

    driver.Initialize(resourceDesc, idquery, reset, initOptions);
    disp('Driver Initialized');
    %Downconversion Configuration
    ChannelUsed='Channel1';
    DownconversionEnabled=1;
    DownconversionFrequency=62.5e6;
    Configure(driver.DeviceSpecific.Channels3.Item3(ChannelUsed).Downconversion,DownconversionEnabled,DownconversionFrequency);
    
    %Reference Clock Configuration
    driver.DeviceSpecific.ReferenceOscillator.Source='AgMD1ReferenceOscillatorSourceAXI'; %use 'AgMD1ReferenceOscillatorSourceInternal' for internal reference
    
    % Create pointers to Channel1 channel and trigger source objects
    [pCh1] = driver.DeviceSpecific.Channels.Item('Channel1');
    [pTrigSrc] = driver.DeviceSpecific.Trigger.Sources.Item('External1');
    
    % Setup triggering
    driver.DeviceSpecific.Trigger.ActiveSource = 'External1';
    pTrigSrc1.Type = 'AgMD1TriggerEdge';
    pTrigSrc.Level=0.2; %set the trigger level to 0.2V
    
	% Setup acquisition - Records must be 1 for Channel.Measurement methods.
	% For multiple records use Channel.MutiRecordMeasurement methods.
    PointsPerRecord = 189888;
    driver.DeviceSpecific.Acquisition.WaitForAcquisitionComplete(1000);
	driver.DeviceSpecific.Acquisition.ConfigureAcquisition(1, PointsPerRecord, 0.25E9); % Records, PointsPerRecord, SampleRate
    pCh1.Configure(1.0, 0.0, 1, true); % Range, Offset, Coupling, Enabled

     % Calibrate and measure waveform
    disp('Calibrating Channel1...');
    driver.DeviceSpecific.Calibration.SelfCalibrate(4,1);   % 0=AgMD1CalibrateTypeFull
    
    
%% Upload Signal
AWG_M8190A_SignalUpload(ComplexSignal(1), Fcarrier(1), FsampleTx(1), 500e6, false)
display('Upload Complete') ;
%% Download Signal
% delay_s=0; 
% driver.DeviceSpecific.Trigger.Delay=delay_s;
 % Size waveform array as required and measure
    arrayElements = driver.DeviceSpecific.Acquisition.QueryMinWaveformMemory(64,1,0,PointsPerRecord);
    WaveformArray = zeros(arrayElements,1);
    disp('Measuring Waveform on Channel1...');
 	[WaveformArray,ActualPoints,FirstValidPoint,InitialXOffset,InitialXTimeSeconds,InitialXTimeFraction,XIncrement] = pCh1.Measurement.ReadWaveformReal64(1000, WaveformArray );
    
%     plot(WaveformArray);
    starting=int32(FirstValidPoint)+1;
%     ending=int32(ActualPoints);
    RecI=WaveformArray(starting:2:end-1);
    RecQ=WaveformArray(starting+1:2:end);
    
    ResampledRecI=resample(RecI,2,5).';
    ResampledRecQ=resample(RecQ,2,5).';
    

checkPower(Or_I1, Or_Q1,1);
checkPower(ResampledRecI, ResampledRecQ,1);
[Or_I1, Or_Q1, RecI, RecQ] = AdjustPowerAndPhase(Or_I1, Or_Q1, ResampledRecI, ResampledRecQ, 0) ;
%     PlotSpectrum(Or_I1, Or_Q1, RecI, RecQ) ;

figure()
hold on
    plot(abs(complex(Or_I1,Or_Q1)))
    plot(abs(complex(RecI,RecQ)),'r')
hold off

[or_I1, or_Q1, out_I1, out_Q1] = UnifyLength(Or_I1, Or_Q1, RecI, RecQ, NbOfPoint) ;
[or_I1, or_Q1, out_I1, out_Q1, timedelay1] = AdjustDelay(or_I1, or_Q1, out_I1, out_Q1,250e6,2000) ;
[or_I1, or_Q1, out_I1, out_Q1] = AdjustPowerAndPhase(or_I1, or_Q1, out_I1, out_Q1, 0) ;
PlotGain(or_I1, or_Q1, out_I1, out_Q1) ;
PlotAMPM(or_I1, or_Q1, out_I1, out_Q1) ;
PlotSpectrum(or_I1, or_Q1, out_I1, out_Q1) ;




%% Measurement
close all ;
L = length(WaveformArray) ;
Fs = 1000e6;
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(WaveformArray,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
plot(f,10*log10(2*abs(Y(1:NFFT/2+1)))) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

t = 0:1/(Fs):1e-3 ;
t = t(1:L) ;

y = WaveformArray ;


y = WaveformArray .*exp(-2*1i*pi*62.5e6*t) ;

y = resample(y,1,2) ;
y = resample(y,2,1) ;

II = real(y) ;
QQ = imag(y) ;

[Or_II, Or_QQ, II, QQ] = AdjustPowerAndPhase(Or_I1, Or_Q1, II.', QQ.', 0) ;
PlotSpectrum(Or_II, Or_QQ, II, QQ) ;

%%

% Or_I1=Or_I1(1:end/2);
% Or_Q1=Or_Q1(1:end/2);
checkPower(Or_I1, Or_Q1,1);
checkPower(RecI.', RecQ.',1);
[Or_I1, Or_Q1, RecI, RecQ] = AdjustPowerAndPhase(Or_I1, Or_Q1, RecI.', RecQ.', 0) ;

RecI = resample(RecI,2,5) ;
RecI = resample(RecI,5,2) ;
RecQ = resample(RecQ,2,5) ;
RecQ = resample(RecQ,5,2) ;
[Or_I1, Or_Q1, RecI, RecQ] = AdjustPowerAndPhase(Or_I1, Or_Q1, RecI, RecQ, 0) ;

PlotSpectrum(Or_I1, Or_Q1, RecI, RecQ) ;

%%
close all
figure()
hold on
    plot(abs(complex(Or_I1,Or_Q1)))
    plot(abs(complex(RecI,RecQ)),'r')
hold off
%%
    in_I = Or_I1(1:103091) ;
    in_Q = Or_Q1(1:103091) ;
    out_I = [RecI(86798:end)];...;RecI(1:86797)] ;
    out_Q = [RecQ(86798:end)];...;RecQ(1:86797)] ;

%     FilterCoef = [0.00249087118050868,0.00561443460908477,-0.00409259378715573,-0.0328476466238316,-0.0428487485770209,0.0317654668493948,0.194923413516296,0.338879588345010,0.338879588345010,0.194923413516296,0.0317654668493948,-0.0428487485770209,-0.0328476466238316,-0.00409259378715573,0.00561443460908477,0.00249087118050868];
%         y = complex(out_I,out_Q) ;
%         y = filter(FilterCoef,1,y) ;
%     out_I = real(y(length(FilterCoef)-7:end)) ;
%     out_Q = imag(y(length(FilterCoef)-7:end)) ;

%     in_I = resample(in_I,2,5) ;
%     in_Q = resample(in_Q,2,5) ;
%     out_I = resample(out_I,2,5) ;
%     out_Q = resample(out_Q,2,5) ;
    
    
close all
figure()
hold on
    plot(abs(complex(in_I,in_Q)))
    plot(abs(complex(out_I,out_Q)),'r')
hold off

PlotGain(in_I, in_Q, out_I, out_Q) ;
PlotAMPM(in_I, in_Q, out_I, out_Q) ;
PlotSpectrum(in_I, in_Q, out_I, out_Q) ;

%%
[in_I, in_Q, out_I, out_Q] = UnifyLength(in_I, in_Q, out_I, out_Q, 60e3) ;
[in_I, in_Q, out_I, out_Q, timedelay1] = AdjustDelay(in_I, in_Q, out_I, out_Q,100e6,1000,25,3) ;

%%

Out_I1=RecI;
Out_Q1=RecQ;
[or_I1, or_Q1, out_I1, out_Q1] = UnifyLength(Or_I1, Or_Q1, Out_I1, Out_Q1, NbOfPoint) ;
[or_I1, or_Q1, out_I1, out_Q1, timedelay1] = AdjustDelay(or_I1, or_Q1, out_I1, out_Q1,250e6,2000) ;
[or_I1, or_Q1, out_I1, out_Q1] = AdjustPowerAndPhase(or_I1, or_Q1, out_I1, out_Q1, 0) ;
PlotGain(or_I1, or_Q1, out_I1, out_Q1) ;
PlotAMPM(or_I1, or_Q1, out_I1, out_Q1) ;
PlotSpectrum(or_I1, or_Q1, out_I1, out_Q1) ;

%% Extra configurations

driver.Close();
AWG_M8190A_Output_OFF(1)
AWG_M8190A_DAC_Amplitude(1,0.7)
AWG_M8190A_MKR_Amplitude(1,1)