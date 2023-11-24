function [x, y, Target_fSample] = NormalizeUploadCaptureNormalize(backoff, ... 
    inputI, inputQ, iNoCor, qNoCor, svars)
    
    instrumentHandle = svars.awgHandle;
    AWG_UpSample = svars.awgUpSample;
    AWG_DownSample = svars.awgDownSample;
    AWG_ExpansionMargin = backoff;
    
    norm            = max(max(abs(inputI), max(abs(inputQ))));
    In_I            = inputI / norm * 10 ^ (- AWG_ExpansionMargin / 20);
    In_Q            = inputQ / norm * 10 ^ (- AWG_ExpansionMargin / 20);
    
    % Create waveform for upload to AWG at AWG sampling rate
    In_I_u          = resample(In_I, AWG_UpSample, AWG_DownSample);
    In_Q_u          = resample(In_Q, AWG_UpSample, AWG_DownSample);
    Waveform        = [In_I_u' + svars.iOffset; In_Q_u' + svars.qOffset];
    
    % Upload the waveform and capture the corresponding output on PXA
    AWG_N8241A_SignalUpload(instrumentHandle, Waveform, svars.awgNormalize);
    
    PXA_CaptureResampleAnalyzeEVM
    [Out_I, Out_Q]  = IQCapture_with_atten( svars.fCarrier,     ...
                                            svars.fSampleRx,    ...
                                            svars.frameTime,    ...
                                            svars.pxaAddress,   ...
                                            svars.pxaAtten );  
    Out_I           = Out_I(20:end);
    Out_Q           = Out_Q(20:end);
    
    Target_fSample = min([svars.fSampleTx, svars.fSampleRx, svars.fSampleMaxRx, svars.fSampleMaxTx]);
    [DownSampleTargetRx, UpSampleTargetRx] = rat(svars.fSampleRx/Target_fSample);
    [DownSampleTargetTx, UpSampleTargetTx] = rat(svars.fSampleTx/Target_fSample);
    Out_I = resample(Out_I, UpSampleTargetRx, DownSampleTargetRx);
    Out_Q = resample(Out_Q, UpSampleTargetRx, DownSampleTargetRx);
    iNoCor = resample(iNoCor, UpSampleTargetTx, DownSampleTargetTx);
    qNoCor = resample(qNoCor, UpSampleTargetTx, DownSampleTargetTx);
    
    % Normalize the output to a gain of 0 dB w.r.t the input, 
    % calculate the mean phase of the input and output signals and adjusts
    % output to mean phase to match input
    [d_In_I, d_In_Q, d_Out_I, d_Out_Q] ...
        = AdjustPowerAndPhase(iNoCor, qNoCor, Out_I, Out_Q, 0);
    % Matches delay between input and output using cross-correlation
    [d_In_I, d_In_Q, d_Out_I, d_Out_Q, timedelay1] ... 
        = AdjustDelay_noplots(d_In_I, d_In_Q, d_Out_I, d_Out_Q, svars.fSampleTx, 200);
    [d_In_I, d_In_Q, d_Out_I, d_Out_Q] ...
        = AdjustPowerAndPhase(d_In_I, d_In_Q, d_Out_I, d_Out_Q, 0);
    [d_In_I, d_In_Q, d_Out_I, d_Out_Q, timedelay1]  = UltraFineAdjustDelay_EVM_Method(d_In_I, d_In_Q, d_Out_I, d_Out_Q ,svars.fSampleRx);
    [d_In_I, d_In_Q, d_Out_I, d_Out_Q]              = AdjustPowerAndPhase(d_In_I, d_In_Q, d_Out_I, d_Out_Q, 0) ;
    x = complex(d_In_I,  d_In_Q);
    y = complex(d_Out_I, d_Out_Q);
    
end

