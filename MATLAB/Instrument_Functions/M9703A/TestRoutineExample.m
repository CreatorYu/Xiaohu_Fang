%% Parameters Definition
VisaAddress='PXI21::0::0::INSTR';
ReferenceSource='AgMD1ReferenceOscillatorSourceAXI';
TriggerSource='External1';
TriggerLevel=0.2;
Channel='Channel2';
DownconversionEnabled=1;
DownconversionFrequency=62.5e6;
PointsPerRecord=189888;
SamplingFrequency=250e6;
FullScaleRange=1;
ACDCCoupling=1;

%% Instrument Initialization and Configuration
[InstrumentObj]=M9703A_Configuration(VisaAddress, ReferenceSource, TriggerSource, TriggerLevel);

%% Downconversion Configuration
M9703A_DDC_Configuration(InstrumentObj, Channel, DownconversionEnabled, DownconversionFrequency);

%% Signal Acquisition
[WaveformArray,ActualPoints,FirstValidPoint,InitialXOffset,InitialXTimeSeconds,InitialXTimeFraction,XIncrement] = M9703A_Acquisition(InstrumentObj, Channel, PointsPerRecord, SamplingFrequency, FullScaleRange, ACDCCoupling);

%% Signal Extraction
RecI=WaveformArray(1:2:end-1);
RecQ=WaveformArray(1+1:2:end);

ResampledRecI=resample(RecI,2,5).';
ResampledRecQ=resample(RecQ,2,5).';

%% Measurements
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
