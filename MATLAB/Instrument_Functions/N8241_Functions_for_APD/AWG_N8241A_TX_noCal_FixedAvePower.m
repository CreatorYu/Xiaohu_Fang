% This function uploads signals to N8241A and realizes these features
% 1. apply imbalance calibration
% 2. maintain signal average power

% the calibration is done at FsampleCal, which might be different from the
% sample rate of IQ (FsampleTx). Therefore, IQ is first resampled to
% FsampleCal before the calibration is applied. The resampled IQ is
% then resampled again to FsampleAWG before being uploaded. 

function AWG_N8241A_TX_noCal_FixedAvePower(I, Q, instrumentHandle,  FsampleTx, Expansion_Margin);
    
    FsampleAWG   = 625e6;
    AWG_AutoNorm = false;
    
    [AWG_DownSample, AWG_UpSample]  = rat(FsampleTx/FsampleAWG);

    I_resampled = resample(I, AWG_UpSample, AWG_DownSample);
    Q_resampled = resample(Q, AWG_UpSample, AWG_DownSample); 
    [I_resampled, Q_resampled] = normalizeDACpeak(I_resampled, Q_resampled, Expansion_Margin);
         
    [meanOut, maxOut] = checkPower(I_resampled, Q_resampled);

    % resample to AWG rate
    Iu       = I_resampled;
    Qu       = Q_resampled;
    waveform = [Iu'  ; Qu'];  
      
    %disp('Transfering the waveform to the instrument');
      [ waveformHandle, errorN, errorMsg ] = agt_awg_storewaveform( instrumentHandle, waveform, AWG_AutoNorm);
      if( errorN ~= 0 )
        % An error occurred while trying to store the waveform.
        agt_awg_close( instrumentHandle );
        disp('Could not transfer the waveform to the instrument');
        errorN
        errorMsg
        return;
      end 
      %play waveform
      [ errorN, errorMsg ] = agt_awg_playwaveform( instrumentHandle, waveformHandle );	  
end