if ~strcmp(DPD_type,'FIR_APD')
    disp('Nonlinear optimization only supported for DPD_type = FIR_APD. Aborting...')
    return;
end

params.DEBUG = 1;
params.MaxFunEval = 40e3;
params.MaxIter = 40e3;
params.TolFun = 1e-6;
% if strcmp(APD_modelParam.engine, 'H_EMP')
% [NL_FIR_DPD_coefficients, NL_NMSE_error] = Identify_SingleBand_Cascaded_NLTB(FIR_DPD_modelParam, NonlinearID_In_I, NonlinearID_In_Q, NonlinearID_Out_I, NonlinearID_Out_Q, NofDPDPoints, FIR_DPD_coefficients);
% elseif strcmp(FIR_DPD_modelParam.engine, 'ECRV')
% [NL_FIR_DPD_coefficients, NL_NMSE_error] = Identify_SingleBand_Cascaded_NLTB_CRV(FIR_DPD_modelParam, NonlinearID_In_I, NonlinearID_In_Q, NonlinearID_Out_I, NonlinearID_Out_Q, NofDPDPoints, FIR_DPD_coefficients);
% end
[NL_FIR_APD_coefficients, NL_NMSE_error] = Identify_SingleBand_FIR_APD_NL(FIR_APD_modelParam, NonlinearID_In_I, NonlinearID_In_Q, NonlinearID_Out_I, NonlinearID_Out_Q, NofDPDPoints, FIR_APD_coefficients, params);
Coeff_DR_real = 20*log10( (max(abs(real(NL_FIR_APD_coefficients))))/(min(abs(real(NL_FIR_APD_coefficients)))));
Coeff_DR_imag = 20*log10( (max(abs(imag(NL_FIR_APD_coefficients))))/(min(abs(imag(NL_FIR_APD_coefficients)))));
Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);

[Pr_I, Pr_Q] = Apply_SingleBand_FIR_APD(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, FIR_APD_modelParam, NL_FIR_APD_coefficients);

Pr_I_up=resample(Pr_I,DownSampleTx,UpSampleTx);
Pr_Q_up=resample(Pr_Q,DownSampleTx,UpSampleTx);

disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp([' Predistorted Signal']);
checkPower(Pr_I_up, Pr_Q_up,1);
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

In_I = Pr_I_up;
In_Q = Pr_Q_up;
close all;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Final "With DPD" Measurements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' DPD measurement with non-linearly identified coefficients');
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

In_I_withDPD = In_I;
In_Q_withDPD = In_Q;
In_I_cal = In_I_withDPD; In_Q_cal = In_Q_withDPD;

SignalName                        = [WaveformName, 'WithDPD'];
[In_I_cal, In_Q_cal]              = setMeanPower(In_I_cal, In_Q_cal, PowerBand);  % Set the mean power of the I/Q signals to be uploaded
[In_I, In_Q]                      = setMeanPower(In_I_withDPD, In_Q_withDPD, 0);  % Set the mean power of the I/Q signals to be used for DPD
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
    [RF_ON_Continue]  = PushButton_Routine (RF_ON_Continue,Transmitter_type,ESGAdd,RF_channel);
    
    ESG_RF_ON_SingleCarrier(ESGAdd);
    
elseif strcmp(Transmitter_type,'AWG')
    AWG_M8190A_SignalUpload_ChannelSelect_FixedAvgPower(ComplexSignal, Fcarrier_array, FsampleTx_array, DAC_SamplingRate, Amp_Corr, false,RF_channel,Expansion_Margin, PAPR_input, PAPR_original);
    AWG_M8190A_Reference_Clk('External',10e6);
    AWG_M8190A_DAC_Amplitude(RF_channel,VFS);
    AWG_M8190A_MKR_Amplitude(RF_channel,1.2);
    AWG_M8190A_Output_OFF(RF_channel);
    
    RF_ON_Continue    = 0;
    [RF_ON_Continue]  = PushButton_Routine (RF_ON_Continue,Transmitter_type,ESGAdd,RF_channel);
    
    AWG_M8190A_Output_ON(RF_channel);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Downloading the output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Receiver_type, 'Digitizer')
    % Signal Acquisition
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
    % Signal Extraction
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
    if strcmp (Measure_Pout_Eff,'True')
        PS_m = PowerSupply_N6705A(DCSource_Add);
        PS_m.connect;
        PS_m_chan = 1; % channel to measure from
        V_m_with_DPD = PS_m.voltage(PS_m_chan);
        I_m_with_DPD = PS_m.current(PS_m_chan);
        Pout_measured_with_DPD = PM_obj.measure;
        Pdc_measured_with_DPD  = V_m_with_DPD*I_m_with_DPD;
        DE_measured_with_DPD = 100*10^((Pout_measured_with_DPD-30)/10) / Pdc_measured_with_DPD;
    end
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

[DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM,timedelay_EVM]  = AdjustDelay(In_I_beforeDPD_EVM(mem_truncate+1:end), In_Q_beforeDPD_EVM(mem_truncate+1:end), out_I1_withDPD, out_Q1_withDPD,Fs,2000);
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
% disp([ ' Measured Pout with DPD  = ' num2str(Pout_measured_with_DPD) ' dBm ' ]);
% disp([ ' Measured DE with DPD    = ' num2str(DE_measured_with_DPD) ' % ' ]);
disp(  ' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Saving Measurement Results - With DPD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Writing files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd('Measurements')
cd(dir_name)
save('old_coeff.mat','FIR_APD_coefficients');
save('new_coeff.mat','NL_FIR_APD_coefficients');

%%%% Input signal before DPD
fidIEH = fopen(['I_Input_NoDPD_NL.txt'],'wt');
fprintf(fidIEH,'\n');
fprintf(fidIEH,'%12.20f\n',In_I_beforeDPD_EVM);
fclose(fidIEH);
fidIEH = fopen(['Q_Input_NoDPD_NL.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',In_Q_beforeDPD_EVM);
fclose(fidIEH);
%%%% PreDistorted Input
fidIEH = fopen(['I_Input_PreDist_NL.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',In_I_withDPD);
fclose(fidIEH);
fidIEH = fopen(['Q_Input_PreDist_NL.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',In_Q_withDPD);
fclose(fidIEH);
%%%% Output with DPD
fidIEH = fopen(['I_Output_WithDPD_NL.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',Out_I_withDPD);
fclose(fidIEH);
fidIEH = fopen(['Q_Output_WithDPD_NL.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',Out_Q_withDPD);
fclose(fidIEH);

fidIEH = fopen(['Summary.txt'],'at');
fprintf(fidIEH,' \n');
fprintf(fidIEH,'\nWith Nonlinear Identification \n ');
fprintf(fidIEH,'NL_EVM (%%) = %4.3f \n ',EVM_perc_withDPD);
fprintf(fidIEH,'NL_ACLR_L/ACLR_U = %4.3f / %4.3f \n ',ACLR_L_withDPD,ACLR_U_withDPD);
fprintf(fidIEH,'NL_ACPR_L/ACPR_U = %4.3f / %4.3f \n ',ACPR_L_withDPD,ACPR_U_withDPD);
fprintf(fidIEH,'NL_PAPRin = %4.3f \n ',PAPRin_withDPD);
fprintf(fidIEH,'NL_PAPRout = %4.3f \n ',PAPRout_withDPD);

fprintf(fidIEH,'\nNonlinear Modeling Performance \n ');
fprintf(fidIEH,'NL_NMSE(dB) = %4.3f \n ',NL_NMSE_error);
fprintf(fidIEH,'NL_Coefficients DR = %4.3f \n ', Coeff_DR);

fclose(fidIEH);
cd ..
cd ..
