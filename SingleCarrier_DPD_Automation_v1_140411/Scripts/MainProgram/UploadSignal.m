SignalName                        = [WaveformName];
[In_I_cal, In_Q_cal]              = setMeanPower(In_I_cal, In_Q_cal, PowerBand);      % Set the mean power of the I/Q signals to be uploaded
[meanPower, maxPower, PAPR_input] = checkPower(In_I_cal, In_Q_cal, 1) ;  % Check the PAPR of the input file to be uploaded to the transmitter
ComplexSignal{1}                  = complex(In_I_cal, In_Q_cal);
Fcarrier_array{1}                 = Fcarrier ;
FsampleTx_array{1}                = FsampleTx ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Uploading the signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Transmitter_type,'ESG')
	ESG_RF_OFF_SingleCarrier(ESGAdd);
	IQUpload_Singleband ( In_I_cal', In_Q_cal', PowerBand,  Fcarrier, FsampleTx, ESGAdd, SignalName,data_length);
	
	%         RF_ON_Continue    = 0;
	[RF_ON_Continue]  = PushButton_Routine (keep_RF_ON,Transmitter_type,ESGAdd,RF_channel);
	
	ESG_RF_ON_SingleCarrier(ESGAdd);
	
elseif strcmp(Transmitter_type,'AWG')
	% experimental
	%         clear In_I_cal In_Q_cal iqdata iqtotaldata IQ_data RecI RecQ
	%         WaveformArray0 time_IQ
	AWG_M8190A_SignalUpload_ChannelSelect_FixedAvgPower(ComplexSignal, Fcarrier_array, FsampleTx_array, DAC_SamplingRate, Amp_Corr, false,RF_channel,Expansion_Margin, PAPR_input, PAPR_original);
	AWG_M8190A_Reference_Clk('External',10e6);
	AWG_M8190A_DAC_Amplitude(RF_channel,VFS);
	AWG_M8190A_MKR_Amplitude(RF_channel,1.2);
	AWG_M8190A_Output_OFF(RF_channel);
	
	%         RF_ON_Continue    = 0;
	[RF_ON_Continue]  = PushButton_Routine (keep_RF_ON,Transmitter_type,ESGAdd,RF_channel);
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