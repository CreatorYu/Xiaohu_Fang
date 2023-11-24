%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Downloading the output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Receiver_type, 'Digitizer')
	%% Signal Acquisition
	GainValue = M9352A_Gain_value;
	M9352A_Gain(M9352A_Obj, AmpChannel, GainValue);
	M9703A_DDC_Configuration(M9703A_Obj, Channel, 0, 0);
	pause(2);
	%% Download the complete signal at the input of the digitizer to check if it is overloaded
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