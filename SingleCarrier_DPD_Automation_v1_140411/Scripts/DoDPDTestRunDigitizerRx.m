DelayAdjusted_In_I = xp_I;
DelayAdjusted_In_Q = xp_Q;
DelayAdjusted_Out_I = x_I;
DelayAdjusted_Out_Q = x_Q;

if strcmp(DPD_type, 'FIR_APD') && FIR_APD_modelParam.use_NL == 1
    % NL Identification assumes we are reverse modelling
    % For forward modelling, we need to interchange signals
    NonlinearID_In_I = xp_I;
    NonlinearID_In_Q = xp_Q;
    NonlinearID_Out_I = x_I;
    NonlinearID_Out_Q = x_Q;
end

disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
if strcmp(DPD_type, 'APD')
    disp(['DPD type = ', DPD_type, '; Engine = ', APD_modelParam.engine]);
else
    disp(['DPD type = ', DPD_type, '; Engine = ', FIR_APD_modelParam.engine]);
end
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DPD Identification and Validation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch DPD_type
    case 'Volterra_DDR'
        DPD = true ;
        %         [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput ] = VolterraDpdIdentification ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , VolterraParameters , NofDPDPoints , DPD ) ;
        VolterraParameters.NSupply = 1 ;
        DelayAdjusted_Vdd = abs(complex(DelayAdjusted_In_I, DelayAdjusted_In_Q));
        [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput, NMSE_error ] = VolterraDpdIdentification_ET ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , circshift(DelayAdjusted_Vdd,0), VolterraParameters , NofDPDPoints , DPD ) ;
        Coeff_DR_real = 20*log10( (max(abs(real(VolterraCoeff))))/(min(abs(real(VolterraCoeff)))));
        Coeff_DR_imag = 20*log10( (max(abs(imag(VolterraCoeff))))/(min(abs(imag(VolterraCoeff)))));
        Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
        num_of_coeff = size(VolterraCoeff,1);
    case 'Volterra_DDR_ET'
        Vdd_shift = 0;
        DPD = true ;
        [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput ] = VolterraDpdIdentification_ET ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , circshift(DelayAdjusted_Vdd,Vdd_shift), VolterraParameters , NofDPDPoints , DPD ) ;
    case 'Volterra_DDR_Aug'
        DPD = true ;
        [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput ] = VolterraDpdIdentification_Aug ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , VolterraParameters , NofDPDPoints , DPD ) ;
    case 'RF_Volterra'
        DelayAdjusted_Vdd = abs(complex(DelayAdjusted_In_I, DelayAdjusted_In_Q));
        [Coeff_RF_Volterra, NMSE_error]=Identify_RF_Volterra_v2_ET(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I , DelayAdjusted_Out_Q ,DelayAdjusted_Vdd, RF_Volterra_Parameters , Fs, NofDPDPoints );
    case 'MP'
        [MP_coefficients, NMSE_error, Cond_A] = Identify_SingleBand_MP(MP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
        Coeff_DR_real = 20*log10( (max(abs(real(MP_coefficients))))/(min(abs(real(MP_coefficients)))));
        Coeff_DR_imag = 20*log10( (max(abs(imag(MP_coefficients))))/(min(abs(imag(MP_coefficients)))));
        Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
    case 'APD'
        [APD_coefficients, NMSE_error] = Identify_SingleBand_APD(APD_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
        Coeff_DR_real = 20*log10( (max(abs(real(APD_coefficients))))/(min(abs(real(APD_coefficients)))));
        Coeff_DR_imag = 20*log10( (max(abs(imag(APD_coefficients))))/(min(abs(imag(APD_coefficients)))));
        Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
    case 'FIR_APD'
        [FIR_APD_coefficients, NMSE_error] = Identify_SingleBand_FIR_APD(FIR_APD_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
        Coeff_DR_real = 20*log10( (max(abs(real(FIR_APD_coefficients))))/(min(abs(real(FIR_APD_coefficients)))));
        Coeff_DR_imag = 20*log10( (max(abs(imag(FIR_APD_coefficients))))/(min(abs(imag(FIR_APD_coefficients)))));
        Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
        if FIR_APD_modelParam.use_NL == 1
            NonlinearID_In_I = DelayAdjusted_In_I;
            NonlinearID_In_Q = DelayAdjusted_In_Q;
            NonlinearID_Out_I = DelayAdjusted_Out_I;
            NonlinearID_Out_Q = DelayAdjusted_Out_Q;
        end
    case 'TwoStep_MP'
        [MP_coefficients, NMSE_error, Cond_A] = Identify_TwoStep_SingleBand_MP(MP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
        Coeff_DR_real = 20*log10( (max(abs(real(MP_coefficients))))/(min(abs(real(MP_coefficients)))));
        Coeff_DR_imag = 20*log10( (max(abs(imag(MP_coefficients))))/(min(abs(imag(MP_coefficients)))));
        Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
    case 'Aug_MP'
        [MP_coefficients, gamma, fval, exitflag, NMSE_error, Cond_A] = Identify_SingleBand_Aug_MP(MP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
        Coeff_DR_real = 20*log10( (max(abs(real(MP_coefficients))))/(min(abs(real(MP_coefficients)))));
        Coeff_DR_imag = 20*log10( (max(abs(imag(MP_coefficients))))/(min(abs(imag(MP_coefficients)))));
        Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
    case 'RF_MP'
        [num_coeff, den_coeff, NMSE_error, Cond_A] = Identify_SingleBand_RFMP(Param_array, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
        Coeff_DR_num_real = 20*log10( (max(abs(real(num_coeff))))/(min(abs(real(num_coeff)))));
        Coeff_DR_num_imag = 20*log10( (max(abs(imag(num_coeff))))/(min(abs(imag(num_coeff)))));
        Coeff_DR_num = max(Coeff_DR_num_real,Coeff_DR_num_imag);
        Coeff_DR_den_real = 20*log10( (max(abs(real(den_coeff))))/(min(abs(real(den_coeff)))));
        Coeff_DR_den_imag = 20*log10( (max(abs(imag(den_coeff))))/(min(abs(imag(den_coeff)))));
        Coeff_DR_den = max(Coeff_DR_den_real,Coeff_DR_den_imag);
    case 'RF_Volterra_ET'
        DelayAdjusted_Vdd = abs(complex(DelayAdjusted_In_I, DelayAdjusted_In_Q));
        [Coeff_RF_Volterra]=Identify_RF_Volterra_ET(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I , DelayAdjusted_Out_Q , DelayAdjusted_Vdd, RF_Volterra_Parameters , Fs, NofDPDPoints );
        %         [Coeff_RF_Volterra]=Identify_RF_Volterra_v2_ET(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I , DelayAdjusted_Out_Q , DelayAdjusted_Vdd, RF_Volterra_Parameters , Fs, NofDPDPoints );
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Apply DPD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch DPD_type
    case 'Volterra_DDR'
        [Pr_I, Pr_Q] = VolterraDpdApply_ET ( In_I_beforeDPD_EVM , In_Q_beforeDPD_EVM , abs(complex(In_I_beforeDPD_EVM,In_Q_beforeDPD_EVM)), VolterraETParameters , VolterraCoeff ) ;
        %         [ Pr_I , Pr_Q ] = VolterraDpdApply ( In_I_beforeDPD_EVM , In_Q_beforeDPD_EVM , VolterraETParameters , VolterraCoeff ) ;
    case 'Volterra_DDR_ET'
        [Pr_I, Pr_Q] = VolterraDpdApply_ET ( In_I_beforeDPD_EVM , In_Q_beforeDPD_EVM , Vdd_beforeDPD, VolterraETParameters , VolterraCoeff ) ;
        %         DelayAdjusted_Vdd_beforeDPD
    case 'RF_Volterra'
        [Pr_I, Pr_Q] = Apply_RF_Volterra_v2_ET(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, abs(complex(In_I_beforeDPD_EVM,In_Q_beforeDPD_EVM)), Coeff_RF_Volterra, RF_Volterra_Parameters , Fs);
        %         [Pr_I , Pr_Q]=Apply_RF_Volterra(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, Coeff_RF_Volterra, RF_Volterra_Parameters , Fs);
    case 'MP'
        [Pr_I, Pr_Q] = Apply_SingleBand_MP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, MP_modelParam, MP_coefficients);
    case 'APD'
        [Pr_I, Pr_Q] = Apply_SingleBand_APD(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, APD_modelParam, APD_coefficients);
    case 'FIR_APD'
        [Pr_I, Pr_Q] = Apply_SingleBand_FIR_APD(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, FIR_APD_modelParam, FIR_APD_coefficients);
    case 'Aug_MP'
        [Pr_I, Pr_Q] = Apply_SingleBand_Aug_MP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, MP_modelParam, MP_coefficients, gamma);
    case 'RFMP_ADRF'
        [Pr_I, Pr_Q] = Apply_SingleBand_RFMP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, RFMP_modelParam, num_coeff, den_coeff, real_zeros, imag_zeros, comp_zeros);
    case 'RFMP_DRF_MFOD'
        [Pr_I, Pr_Q] = Apply_SingleBand_RFMP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, RFMP_modelParam, num_coeff, den_coeff, real_zeros, imag_zeros, comp_zeros);
    case 'RF_Volterra_ET'
        [Pr_I, Pr_Q] = Apply_RF_Volterra_v2_ET(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, DelayAdjusted_Vdd_beforeDPD, Coeff_RF_Volterra, RF_Volterra_Parameters , Fs);
end
% new code
mem_truncate = length(In_I_beforeDPD_EVM) - length(Pr_I);

Pr_I_up=resample(Pr_I,DownSampleTx,UpSampleTx);
Pr_Q_up=resample(Pr_Q,DownSampleTx,UpSampleTx);

% disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
% disp([' Predistorted Signal']);
% checkPower(Pr_I_up, Pr_Q_up,1);
% disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

Draw_spectrum (In_I_beforeDPD,In_I_beforeDPD,Pr_I_up,Pr_Q_up);
In_I = Pr_I_up;
In_Q = Pr_Q_up;
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Final "With DPD" Measurements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' Final DPD measurement with DPD');
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

In_I_withDPD = In_I;
In_Q_withDPD = In_Q;
if strcmp(Calibration, 'Yes')
    %     load(HI_path);
    %     load(HQ_path);
    %     Pr_Input_cal = filter(HI,1,resample(In_I_withDPD,UpSampleTx,DownSampleTx)) + filter(HQ,1,resample(In_Q_withDPD,UpSampleTx,DownSampleTx));
    %     In_I_cal=resample(real(Pr_Input_cal),DownSampleTx,UpSampleTx);
    %     In_Q_cal=resample(imag(Pr_Input_cal),DownSampleTx,UpSampleTx);
else
    In_I_cal = In_I_withDPD; In_Q_cal = In_Q_withDPD;
end

SignalName                        = [WaveformName, 'WithDPD'];
[In_I_cal, In_Q_cal]              = setMeanPower(In_I_cal, In_Q_cal, PowerBand);  % Set the mean power of the I/Q signals to be uploaded
[In_I, In_Q]                      = setMeanPower(In_I, In_Q, 0);                      % Set the mean power of the I/Q signals to be used for DPD
[meanPower, maxPower, PAPR_input] = checkPower(In_I_cal, In_Q_cal, 1) ;           % Check the PAPR of the input file to be uploaded to the transmitter
ComplexSignal{1}                  = complex(In_I_cal, In_Q_cal);
Fcarrier_array{1}                 = Fcarrier ;
FsampleTx_array{1}                = FsampleTx ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Uploading the signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Transmitter_type,'ESG')
    ESG_RF_OFF_SingleCarrier(ESGAdd);
    IQUpload_Singleband ( In_I_cal', In_Q_cal', PowerBand,  Fcarrier, FsampleTx, ESGAdd, SignalName,data_length);
    
    RF_ON_Continue    = 0;
    %     [RF_ON_Continue]  = PushButton_Routine (RF_ON_Continue,Transmitter_type,ESGAdd,RF_channel);
    
    ESG_RF_ON_SingleCarrier(ESGAdd);
    
elseif strcmp(Transmitter_type,'AWG')
    AWG_M8190A_SignalUpload_ChannelSelect_FixedAvgPower(ComplexSignal, Fcarrier_array, FsampleTx_array, DAC_SamplingRate, Amp_Corr, false,RF_channel,Expansion_Margin, PAPR_input, PAPR_original);
    AWG_M8190A_Reference_Clk('External',10e6);
    AWG_M8190A_DAC_Amplitude(RF_channel,VFS);
    AWG_M8190A_MKR_Amplitude(RF_channel,1.2);
    AWG_M8190A_Output_OFF(RF_channel);
    
    RF_ON_Continue    = 0;
    %     [RF_ON_Continue]  = PushButton_Routine (RF_ON_Continue,Transmitter_type,ESGAdd,RF_channel);
    if strcmp(Receiver_type, 'Digitizer')
        if (DownconversionMode == 2)
            if Automate_LO == 1
                if strcmp(LO2_type,'E4433B')
                    E4433B_RF_Configuration (LO_Frequency2, LO_Amplitude, E4433B_Add);
                    E4433B_RF_ON (E4433B_Add);
                elseif strcmp(LO2_type,'E4438C')
                    E4438C_Signal_Configuration(E4438C_Obj, LO_Frequency2, LO_Amplitude);
                    E4438C_Output_Enable(E4438C_Obj, 1);
                end
            end
        end
        if (DownconversionMode == 1) || (DownconversionMode == 2)
            if Automate_LO == 1
                if strcmp(LO_type,'E4433B')
                    E4433B_RF_Configuration (LO_Frequency1, LO_Amplitude, E4433B_Add);
                    E4433B_RF_ON (E4433B_Add);
                elseif strcmp(LO_type,'E4438C')
                    E4438C_Signal_Configuration(E4438C_Obj, LO_Frequency1, LO_Amplitude);
                    E4438C_Output_Enable(E4438C_Obj, 1);
                end
            end
        end
    end
    AWG_M8190A_Output_ON(RF_channel);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Downloading the output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Receiver_type, 'Digitizer')
    %% Signal Acquisition
    GainValue=M9352A_Gain_value;
    M9352A_Gain(M9352A_Obj, AmpChannel, GainValue);
    M9703A_DDC_Configuration(M9703A_Obj, Channel, 0, 0);
    pause(2);
    [WaveformArray0] = M9703A_Acquisition(M9703A_Obj, Channel, floor(FramTime*Digitizer_SamplingFrequency) + 1, Digitizer_SamplingFrequency, FullScaleRange, ACDCCoupling);
    if (DownconversionEnabled == 1)
        DownconversionFrequency1=IF_Frequency;
        M9703A_DDC_Configuration(M9703A_Obj, Channel, DownconversionEnabled, DownconversionFrequency1);
        pause(2);
        [WaveformArray1] = M9703A_Acquisition(M9703A_Obj, Channel, PointsPerRecord, DDC_SamplingFrequency, FullScaleRange, ACDCCoupling);
    end
    if strcmp(Transmitter_type,'AWG')
        AWG_M8190A_Output_OFF(RF_channel);
    elseif strcmp(Transmitter_type,'ESG')
        ESG_RF_OFF_SingleCarrier(ESGAdd);
    end
    if (DownconversionMode == 1) || (DownconversionMode == 2)
        if Automate_LO == 1
            if strcmp(LO_type,'E4433B')
                E4433B_RF_OFF (E4433B_Add);
            elseif strcmp(LO_type,'E4438C')
                E4438C_Output_Enable(E4438C_Obj, 0);
            end
        end
    end
    if (DownconversionMode == 2)
        if Automate_LO == 1
            if strcmp(LO2_type,'E4433B')
                %                 E4433B_RF_Configuration (LO_Frequency2, LO_Amplitude, E4433B_Add);
                E4433B_RF_OFF (E4433B_Add);
            elseif strcmp(LO2_type,'E4438C')
                %                 E4438C_Signal_Configuration(E4438C_Obj, LO_Frequency2, LO_Amplitude);
                E4438C_Output_Enable(E4438C_Obj, 0);
            end
        end
    end
    %% Signal Extraction
    if (DownconversionEnabled == 1)
        RecI=WaveformArray1(1:2:end-1);
        RecQ=WaveformArray1(1+1:2:end);
        ResampledRecI=resample(RecI,DownSampleRx,UpSampleRx).';
        ResampledRecQ=resample(RecQ,DownSampleRx,UpSampleRx).';
        if LO_Frequency1 > Fcarrier
            aux = ResampledRecI;
            ResampledRecI = ResampledRecQ;
            ResampledRecQ = aux;
        end
    elseif (DownconversionMode == 1) || (DownconversionMode == 2)
        time_IQ = [0:1/Digitizer_SamplingFrequency:FramTime];
        IQ_data = WaveformArray0.*exp(1i*2*pi*IF_Frequency*time_IQ);
        RecI=filter(FIR_filter_num, [1 0],(real(IQ_data)));
        RecQ=filter(FIR_filter_num, [1 0],(imag(IQ_data)));
        ResampledRecI=resample(RecI,DownSampleDigitizer,UpSampleDigitizer).';
        ResampledRecQ=resample(RecQ,DownSampleDigitizer,UpSampleDigitizer).';
        %             if LO_Frequency1 > Fcarrier
        %                 aux = ResampledRecI;
        %                 ResampledRecI = ResampledRecQ;
        %                 ResampledRecQ = aux;
        %             end
    elseif (DownconversionMode == 0)
        IF_Frequency0 = Digitizer_SamplingFrequency - Fcarrier;
        time_IQ = [0:1/Digitizer_SamplingFrequency:FramTime];
        teta0 = -1.5;
        WaveformArray0_temp = WaveformArray0 + 0*6.5e-5*exp(1i*2*pi*250e6*time_IQ + 1i*teta0);
        [freq, spectrum1] = Calculated_Spectrum_Real(WaveformArray0_temp,1e9);
        IQ_data = WaveformArray0.*exp(1i*2*pi*IF_Frequency0*time_IQ);
        RecI=filter(FIR_filter_num, [1 0],(real(IQ_data)));
        RecQ=filter(FIR_filter_num, [1 0],(imag(IQ_data)));
        ResampledRecI=resample(RecI,DownSampleDigitizer,UpSampleDigitizer).';
        ResampledRecQ=resample(RecQ,DownSampleDigitizer,UpSampleDigitizer).';
    end
elseif strcmp(Receiver_type, 'PXA')
    [RecI_captured, RecQ_captured] = IQCapture_with_atten (Fcarrier, FsampleRx, FramTime, PXAAdd, PXA_Atten);
    ResampledRecI = RecI_captured(200:end);
    ResampledRecQ = RecQ_captured(200:end);
    if strcmp(Transmitter_type,'AWG')
        AWG_M8190A_Output_OFF(RF_channel);
    elseif strcmp(Transmitter_type,'ESG')
        ESG_RF_OFF_SingleCarrier(ESGAdd)
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Delay Adjustment and analyzing the signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
In_I_withDPD = resample(In_I_withDPD,UpSampleTx,DownSampleTx);
In_Q_withDPD = resample(In_Q_withDPD,UpSampleTx,DownSampleTx);

disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp([' Input Signal']);
checkPower(In_I_withDPD, In_Q_withDPD,1);
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp([' Output Signal']);
checkPower(ResampledRecI, ResampledRecQ,1);
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

[In_I_withDPD, In_Q_withDPD, ResampledRecI, ResampledRecQ]                                     = AdjustPowerAndPhase(In_I_withDPD, In_Q_withDPD, ResampledRecI, ResampledRecQ, 0) ;
[In_I_withDPD, In_Q_withDPD, out_I1_withDPD, out_Q1_withDPD]                                   = UnifyLength(In_I_withDPD, In_Q_withDPD, ResampledRecI, ResampledRecQ, data_length - 200) ;
[DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, timedelay1] = AdjustDelay(In_I_withDPD, In_Q_withDPD, out_I1_withDPD, out_Q1_withDPD,Fs,2000) ;
[DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;

PlotGain(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
PlotAMPM(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
PlotSpectrum(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;

[EVM_dB EVM_perc]                = EVM_calculate (DelayAdjusted_In_I,DelayAdjusted_In_Q,DelayAdjusted_Out_I,DelayAdjusted_Out_Q);
[freq, spectrum]                 = Calculated_Spectrum(out_I1_withDPD,out_Q1_withDPD,Fs);
[freq, spectrum]                 = Calculated_Spectrum(DelayAdjusted_Out_I,DelayAdjusted_Out_Q,Fs);
[ACLR_L_withDPD, ACLR_U_withDPD] = Calculate_ACLR (freq, spectrum, 0, BW, fG);
[ACPR_L_withDPD, ACPR_U_withDPD] = Calculate_ACPR (freq, spectrum, 0, BW, fG);

[DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM,timedelay_EVM]  = AdjustDelay(In_I_beforeDPD_EVM(mem_truncate+1:end), In_Q_beforeDPD_EVM((mem_truncate+1:end)), out_I1_withDPD, out_Q1_withDPD,Fs,2000);
[DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM]                = AdjustPowerAndPhase(DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM,0);

PlotGain(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
PlotAMPM(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
PlotSpectrum(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;

[EVM_dB_withDPD EVM_perc_withDPD] = EVM_calculate (DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM);

display([ ' EVM with DPD        = ' num2str(EVM_perc_withDPD)      ' % ' ]);
display([ ' ACLR (L/U) with DPD = ' num2str(ACLR_L_withDPD) ' / '  num2str(ACLR_U_withDPD) ' dB ' ]);
display([ ' ACPR (L/U) with DPD = ' num2str(ACPR_L_withDPD) ' / '  num2str(ACPR_U_withDPD) ' dB ' ]);

Out_I_withDPD = out_I1_withDPD;
Out_Q_withDPD = out_Q1_withDPD;

[meanPower, maxPower, PAPRin_withDPD]  = checkPower(In_I_withDPD,In_Q_withDPD,0);
[meanPower, maxPower, PAPRout_withDPD] = checkPower(out_I1_withDPD,out_Q1_withDPD,0);

disp(  ' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp([ ' Input PAPR with DPD     = ' num2str(PAPRin_withDPD)  ' dB ' ]);
disp([ ' Output PAPR with DPD    = ' num2str(PAPRout_withDPD) ' dB ' ]);
disp(  ' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Saving Measurement Results - With DPD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Making measurement directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd([pwd '\Measurements']);
cd(dir_name_parent);
if strcmp(DPD_type, 'APD')
    dir_name = strcat(DPD_type, '_', APD_modelParam.engine);
else %FIR_APD
    dir_name = strcat(DPD_type, '_', FIR_APD_modelParam.engine);
end
mkdir(dir_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Writing files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(dir_name)
%%%% Input signal before DPD
fidIEH = fopen(['I_Input_NoDPD_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',In_I_beforeDPD_EVM);
fclose(fidIEH);
fidIEH = fopen(['Q_Input_NoDPD_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',In_Q_beforeDPD_EVM);
fclose(fidIEH);
%%%% PreDistorted Input
fidIEH = fopen(['I_Input_PreDist_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',In_I_withDPD);
fclose(fidIEH);
fidIEH = fopen(['Q_Input_PreDist_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',In_Q_withDPD);
fclose(fidIEH);
%%%% Output with DPD
fidIEH = fopen(['I_Output_WithDPD_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',Out_I_withDPD);
fclose(fidIEH);
fidIEH = fopen(['Q_Output_WithDPD_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',Out_Q_withDPD);
fclose(fidIEH);
cd ..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Wirting Summary file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fidIEH = fopen(['Summary.txt'],'at');
fprintf(fidIEH,'\n\n================================================\n ');
if strcmp(DPD_type, 'APD')
    fprintf(fidIEH,['DPD type = ', DPD_type, '; Engine = ', APD_modelParam.engine]);
else
    fprintf(fidIEH,['DPD type = ', DPD_type, '; Engine = ', FIR_APD_modelParam.engine]);
end
fprintf(fidIEH,'\nWith DPD Results \n ');
fprintf(fidIEH,'EVM (%%) = %4.3f \n ',EVM_perc_withDPD);
fprintf(fidIEH,'ACLR_L/ACLR_U = %4.3f / %4.3f \n ',ACLR_L_withDPD,ACLR_U_withDPD);
fprintf(fidIEH,'ACPR_L/ACPR_U = %4.3f / %4.3f \n ',ACPR_L_withDPD,ACPR_U_withDPD);
fprintf(fidIEH,'PAPRin = %4.3f \n ',PAPRin_withDPD);
fprintf(fidIEH,'PAPRout = %4.3f \n ',PAPRout_withDPD);
fprintf(fidIEH,'\nModeling Performance \n ');
fprintf(fidIEH,'NMSE(dB) = %4.3f \n ',NMSE_error);
switch DPD_type
    case 'Aug_MP'
        fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
        fprintf(fidIEH,'NL = %4.3f \n ',MP_modelParam.N);
        fprintf(fidIEH,'M = %4.3f \n ',MP_modelParam.M);
        fprintf(fidIEH,['Type =  ',MP_modelParam.type, '\n ']);
        %     fprintf(fidIEH,'Gamma = %4.3f + i%4.3f \n ',real(gamma), imag(gamma));
        fprintf(fidIEH,'Gamma = %s \n ',num2str(gamma));
        fprintf(fidIEH,'Number of coefficients = %4.3f \n ', size(MP_coefficients,1))
        fprintf(fidIEH,'Coefficients DR = %4.3f \n ', Coeff_DR);
        fprintf(fidIEH,'Conditioning Number = %4.3f \n ', Cond_A);
    case 'RF_MP'
        fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
        fprintf(fidIEH,'NL_numerator = %4.3f \n ',RFMP_Param.n_num);
        fprintf(fidIEH,'M_numerator = %4.3f \n ',RFMP_Param.m_num);
        fprintf(fidIEH,['Type_numerator =  ',RFMP_Param.mod_num, '\n ']);
        fprintf(fidIEH,'Nbr. of num_coefficients = %4.3f \n ', size(num_coeff));
        fprintf(fidIEH,'NL_denominator = %4.3f \n ',RFMP_Param.n_den);
        fprintf(fidIEH,'M_denominator = %4.3f \n ',RFMP_Param.m_den);
        fprintf(fidIEH,['Type_denominator =  ',RFMP_Param.mod_den, '\n ']);
        fprintf(fidIEH,'Nbr. of den_coefficients = %4.3f \n ', size(den_coeff));
        fprintf(fidIEH,'Coefficients DR (Numerator) = %4.3f \n ', Coeff_DR_num);
        fprintf(fidIEH,'Coefficients DR (Denominator) = %4.3f \n ', Coeff_DR_den);
        fprintf(fidIEH,'Conditioning Number = %4.3f \n ', Cond_A);
    case 'RF_Volterra'
        fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
        fprintf(fidIEH,'Static NL = %4.3f \n ',RF_Volterra_Parameters.NL);
        fprintf(fidIEH,'M1 = %4.3f \n ',RF_Volterra_Parameters.M1);
        fprintf(fidIEH,'M3 = %4.3f \n ',RF_Volterra_Parameters.M3);
        fprintf(fidIEH,'M5 = %4.3f \n ',RF_Volterra_Parameters.M5);
        fprintf(fidIEH,'M7 = %4.3f \n ',RF_Volterra_Parameters.M7);
        fprintf(fidIEH,'Memory Lag = %4.3f \n ',RF_Volterra_Parameters.memory_lag);
    case 'Volterra_DDR'
        fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
        fprintf(fidIEH,'Static NL = %4.3f \n ',VolterraParameters.Static);
        fprintf(fidIEH,'Memory Orders = %4.3f, %4.3f, %4.3f, %4.3f, %4.3f \n ',VolterraParameters.Order(1), VolterraParameters.Order(2), VolterraParameters.Order(3), VolterraParameters.Order(4), VolterraParameters.Order(5));
        fprintf(fidIEH,'Number of coefficients = %4.3f \n ', num_of_coeff);
        fprintf(fidIEH,'Coefficients DR = %4.3f \n ', Coeff_DR);
    case 'MP'
        fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
        fprintf(fidIEH,'NL = %4.3f \n ',MP_modelParam.N);
        fprintf(fidIEH,'M = %4.3f \n ',MP_modelParam.M);
        fprintf(fidIEH,['Type = ',MP_modelParam.type,'\n ']);
        fprintf(fidIEH,'Number of coefficients = %4.3f \n ', size(MP_coefficients,1));
        fprintf(fidIEH,'Coefficients DR = %4.3f \n ', Coeff_DR);
        fprintf(fidIEH,'Conditioning Number = %4.3f \n ', Cond_A);
    case 'APD'
        fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
        fprintf(fidIEH,['Engine = ',APD_modelParam.engine,'\n ']);
        fprintf(fidIEH,'NL = %4.3f \n ',APD_modelParam.N);
        fprintf(fidIEH,'M = %4.3f \n ',APD_modelParam.M);
        fprintf(fidIEH,['Type = ',APD_modelParam.polyorder,'\n ']);
        fprintf(fidIEH,'Use two step identification = %4.3f \n ',APD_modelParam.two_step);
        fprintf(fidIEH,'Number of coefficients = %4.3f \n ', size(APD_coefficients,1));
        fprintf(fidIEH,'Coefficients DR = %4.3f \n ', Coeff_DR);
    case 'FIR_APD'
        fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
        fprintf(fidIEH,['Engine = ',FIR_APD_modelParam.engine,'\n ']);
        fprintf(fidIEH,'APD_NL = %4.3f \n ',FIR_APD_modelParam.APD_N);
        fprintf(fidIEH,'APD_M = %4.3f \n ',FIR_APD_modelParam.APD_M);
        fprintf(fidIEH,'FIR_M = %4.3f \n ',FIR_APD_modelParam.FIR_M);
        fprintf(fidIEH,['Type = ',FIR_APD_modelParam.polyorder,'\n ']);
        fprintf(fidIEH,'Use two step identification = %4.3f \n ',FIR_APD_modelParam.two_step);
        fprintf(fidIEH,'Number of coefficients = %4.3f \n ', size(FIR_APD_coefficients,1));
        fprintf(fidIEH,'Coefficients DR = %4.3f \n ', Coeff_DR);
end
fprintf(fidIEH,'\n');
fprintf(fidIEH,'\nPout   =        dBm');
fprintf(fidIEH,'\nVdd    = 28     V');
fprintf(fidIEH,'\nIdd    =        mA');
fprintf(fidIEH,'\nDE     =        %');
fprintf(fidIEH,'\nPAE    =        %');
fclose(fidIEH);
cd ..
cd ..

if strcmp(DPD_type, 'FIR_APD') && FIR_APD_modelParam.use_NL == 1
    dir_name = dir_name_parent;
    DoNonlinTestRunDigitizerRx;
end
