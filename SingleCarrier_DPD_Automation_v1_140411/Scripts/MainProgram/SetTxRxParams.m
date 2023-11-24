%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set Transmitter/Receiver Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PXAAdd                = 18;                                       % The GPIB address of the PXA
PXA_Atten             = 10;                                       % The mechanical attenuation in dB for the PXA when dowloading the signal. From 6 to 24 with steps of 2 dB
ESGAdd                = 19;                                       % The GPIB address of the ESG
PowerBand 			  = 0;           							  % Power in dBm for ESG (In case of high speed AWG, the power is controlled using VFS)
E4438C_VisaAddress    = ['GPIB0::' num2str(ESGAdd) '::INSTR'];    % Creates the Visa address of the ESG - 'GPIB0::19::INSTR'

DAC_SamplingRate            = 8e9;      % The sampling rate of the AWG - The input I/Q files with sampling rate of FsampleTx will be upsampled to this number. DAC_SamplingRate has to be an integer multiple of FsampleTx
DDC_SamplingFrequency       = 250e6;    % The sampling rate of the Digitzer when in downconversion mode
Digitizer_SamplingFrequency = 1000e6;   % The sampling rate of the Digitzer when in non-downconversion mode
RF_channel                  = 2;        % AWG channel used for sending RF signal - Not used in 'ESG' mode
VFS                         = 0.7;      % Full scale voltage of the AWG. 0.1 < VFS < 0.7;

if strcmp(Transmitter_type,'AWG')
    [DownSampleTx, UpSampleTx] = rat(FsampleTx/FsampleRx);
elseif strcmp(Transmitter_type,'ESG')
    if FsampleTx > 100e6
        disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        disp(' Warning... ESG maximum sampling rate is 100 MHz. Value of 100 MHz will be used for the measurements');
        disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        FsampleTx = 100e6;
    end
    [DownSampleTx, UpSampleTx] = rat(FsampleTx/FsampleTx);
end
if strcmp(Receiver_type,'Digitizer')
    [DownSampleRx, UpSampleRx] = rat(FsampleRx/DDC_SamplingFrequency);
    [DownSampleDigitizer, UpSampleDigitizer] = rat(FsampleRx/Digitizer_SamplingFrequency);
elseif strcmp(Receiver_type,'PXA')
    if FsampleRx > 160e6
        disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        disp(' Warning... PXA maximum sampling rate is 160 MHz. Value of 160 MHz will be used for the measurements');
        disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        FsampleRx = 160e6;
    end
    [DownSampleRx, UpSampleRx] = rat(FsampleRx/FsampleRx);
end
if ( strcmp(Receiver_type,'Digitizer') || strcmp(Transmitter_type,'AWG') )
    % Digitizer Parameters Definition
    M9703A_VisaAddress='PXI21::0::0::INSTR';
    ReferenceSource='AgMD1ReferenceOscillatorSourceAXI';
    %     ReferenceSource='AgMD1ReferenceOscillatorSourceExternal';
    TriggerSource='External1';
    TriggerLevel=0.2;
    Channel='Channel1';
    DownconversionEnabled =0;   % choose between 0 (Digitizer) and 1 (DDC)
    DownconversionMode    =1;   % choose between 0 (no Downconversion), 1 (Single DownConversion) and 2 (Dual DownConversion)
    PointsPerRecord=floor(FramTime*DDC_SamplingFrequency) + 1; %189888;
    FullScaleRange=2;
    ACDCCoupling=1;
    % Amplifier Parameters Definition
    M9352A_VisaAddress='PXI32::10::0::INSTR';
    AmpChannel='Channel1';
    load FIR_filter_fs_1r0GHz_fpass_0r2GHz_Order343.mat
    %     load FIR_filter_fs_1r0GHz_fpass_0r35GHz_Order375.mat
    FIR_filter_num = Num;
    M9352A_Gain_value = 14; % Max: 39.5, Min: 8
end
if strcmp(Receiver_type,'Digitizer')
    % LO Generator Parameters Definition
    %     E4438C_VisaAddress='GPIB0::19::INSTR'; %'GPIB0::19::INSTR'
    E4433B_Add = 17;
    E4433B_VisaAddress=['GPIB0::' num2str(E4433B_Add) '::INSTR']; %'GPIB0::17::INSTR'
    % 380e6 for 850MHz, 390e6 for 750MHz
    IF_Frequency=250e6; %250e6;
    IF2_Frequency=2.0e9; %250e6;
    % LO_Frequency2=Fcarrier2-IF_Frequency;
    LO_Amplitude=0;
    LO_type = 'E4438C';  % choose between 'E4433B' and 'E4438C'
    LO2_type = 'E4438C';  % choose between 'E4433B' and 'E4438C'
    if (DownconversionMode == 2)
        LO_Frequency1=IF2_Frequency-IF_Frequency;
        LO_Frequency2=Fcarrier+IF2_Frequency;
    elseif (DownconversionMode == 1)
        LO_Frequency1=Fcarrier+IF_Frequency;
    elseif (DownconversionMode == 0)
    end
end
if strcmp(Receiver_type,'Digitizer')
    %     [Digitizer.M9703A_Obj]  =  M9703A_Configuration(Digitizer.M9703A_VisaAddress, Digitizer.ReferenceSource, Digitizer.TriggerSource, Digitizer.TriggerLevel);
    [M9703A_Obj] = M9703A_Configuration(M9703A_VisaAddress, ReferenceSource, TriggerSource, TriggerLevel, DoCalibration);
    [M9352A_Obj] = M9352A_Configuration(M9352A_VisaAddress);
    if (DownconversionMode == 1) || (DownconversionMode == 2)
        if strcmp(LO_type,'E4433B')
            E4433B_RF_Configuration (LO_Frequency1, LO_Amplitude, E4433B_Add);
        end
        if ( strcmp(LO_type,'E4438C') || strcmp(LO2_type,'E4438C') )
            if (Automate_LO == 1)
                [E4438C_Obj] = E4438C_Configuration(E4438C_VisaAddress);
            end
        end
    end
end