% This function uploads signals to N8241A and realizes these features
% 1. apply imbalance calibration
% 2. maintain signal average power

% the calibration is done at FsampleCal, which might be different from the
% sample rate of IQ (FsampleTx). Therefore, IQ is first resampled to
% FsampleCal before the calibration is applied. The resampled IQ is
% then resampled again to FsampleAWG before being uploaded.

function [vRange, waveform] = AWG_N8241A_TX_withCal_FixedAvePower(I, Q, instrumentHandle,  ...
    CalResults, FsampleTx, Expansion_Margin, PAPR_input, PAPR_original);

    ResampleOrder = 80;

    if nargin == 6
        PAPR_input = 0;
        PAPR_original = 0;
    end
    
    [meanIn, maxIn] = checkPower(I, Q);

    H_coeff   = CalResults.H_coeff;
    I_offset  = CalResults.I_offset;
    Q_offset  = CalResults.Q_offset;
    FsampleCal= CalResults.FsampleCal;

    FsampleAWG   = 625e6;
    AWG_AutoNorm = false;
    M_Imbalance  = length(H_coeff)/2;

    [Cal_Downsample, Cal_Upsample]  = rat(FsampleTx/FsampleCal);
    [AWG_DownSample, AWG_UpSample]  = rat(FsampleCal/FsampleAWG);

    % apply imbalance correction (delay compensated) at FsampleCal
    I_resampled = resample(I, Cal_Upsample, Cal_Downsample, ResampleOrder);
    Q_resampled = resample(Q, Cal_Upsample, Cal_Downsample, ResampleOrder);
    xCor        = complex(I_resampled, Q_resampled);
    xCor        = [zeros(M_Imbalance - 1, 1); xCor];
    xCor        = ApplyImbalanceCorrection(xCor, H_coeff, M_Imbalance);

    temp_section = xCor(end-2*M_Imbalance + 1 : end);                       % to reduce shoot-up after applying the filter
    xCor(1:length(temp_section)) = temp_section;

    I_resampled = real(xCor);
    Q_resampled = imag(xCor);

    % adjust the peak of the amplitude according to the expansion margin
    [I_resampled, Q_resampled] = normalizeDACpeak(I_resampled, Q_resampled, Expansion_Margin);

    % adjust the average if PAPR is changed
    I_resampled = I_resampled * 10^((PAPR_input - PAPR_original)/20) ;
    Q_resampled = Q_resampled * 10^((PAPR_input - PAPR_original)/20) ;

    norm_factor = max(max(I_resampled), max(Q_resampled));
    if norm_factor > 1
        display('warning: PAPR has changed. More expansion margin is required');
        I_resampled = I_resampled / norm_factor;
        Q_resampled = Q_resampled / norm_factor;
    end

    [meanOut, maxOut] = checkPower(I_resampled, Q_resampled);

    % resample to AWG rate
    Iu       = resample(I_resampled, AWG_UpSample, AWG_DownSample, ResampleOrder);
    Qu       = resample(Q_resampled, AWG_UpSample, AWG_DownSample, ResampleOrder);
    waveform = [Iu' + I_offset ; Qu' + Q_offset];
    
    vRange.meanIn = meanIn; vRange.maxIn = maxIn; vRange.meanOut = meanOut; vRange.maxOut = maxOut;
    vRange.scaleRatio = meanOut / meanIn;

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
    