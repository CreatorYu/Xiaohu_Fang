% This code capture output from PXA and evaluates the EVM between o_x and
% the captured signal

function [x, y, EVM_perc, Target_fSample, RxPower] = PXA_CaptureResampleAnalyzeEVM(O_In_I, O_In_Q, Fcarrier, FsampleRx, FsampleTx, FrameTime, PXAAdd, PXA_Atten, UltraDelayEnableFlag)
    
    [Out_I, Out_Q]  = IQCapture_with_atten (Fcarrier, FsampleRx, FrameTime, PXAAdd, PXA_Atten);        
    Out_I           = Out_I(100:end);
    Out_Q           = Out_Q(100:end);
    
    [RxPower.meanPower, RxPower.maxPower, RxPower.PAPR] = checkPower(Out_I, Out_Q);
    
    Target_fSample = min([FsampleTx, FsampleRx]);
    [DownSampleTargetRx, UpSampleTargetRx] = rat(FsampleRx/Target_fSample);
    [DownSampleTargetTx, UpSampleTargetTx] = rat(FsampleTx/Target_fSample);
    Out_I = resample(Out_I, UpSampleTargetRx, DownSampleTargetRx);
    Out_Q = resample(Out_Q, UpSampleTargetRx, DownSampleTargetRx);
    O_In_I = resample(O_In_I, UpSampleTargetTx, DownSampleTargetTx);
    O_In_Q = resample(O_In_Q, UpSampleTargetTx, DownSampleTargetTx);

    [d_In_I, d_In_Q, d_Out_I, d_Out_Q]              = AdjustPowerAndPhase(O_In_I, O_In_Q, Out_I, Out_Q, 0);
    [d_In_I, d_In_Q, d_Out_I, d_Out_Q, timedelay1]  = AdjustDelay(d_In_I, d_In_Q, d_Out_I, d_Out_Q, FsampleRx, 200);
    [d_In_I, d_In_Q, d_Out_I, d_Out_Q]              = AdjustPowerAndPhase(d_In_I, d_In_Q, d_Out_I, d_Out_Q, 0) ;
    if UltraDelayEnableFlag == true
        [d_In_I, d_In_Q, d_Out_I, d_Out_Q, timedelay1]  = UltraFineAdjustDelay_EVM_Method(d_In_I, d_In_Q, d_Out_I, d_Out_Q ,FsampleRx, Target_fSample/1e6);
        [d_In_I, d_In_Q, d_Out_I, d_Out_Q]              = AdjustPowerAndPhase(d_In_I, d_In_Q, d_Out_I, d_Out_Q, 0) ;
    end    
    x = complex(d_In_I, d_In_Q);
    y = complex(d_Out_I, d_Out_Q);
    [EVM_dB EVM_perc] = EVM_calculate(d_In_I, d_In_Q,d_Out_I,d_Out_Q);
    
end
