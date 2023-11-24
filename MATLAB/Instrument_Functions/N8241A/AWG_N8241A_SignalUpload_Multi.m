% N8241A can be configured in multiple modes.
% Diff mode uses the DAC output directly, hence having the best linearity
% Each +/- terminal swings from -0.25V to 0.25V. Or -0.5V to 0.5V combined
% user has the flexibility in whether to normalize the waveform during uploading
% If AWG_scale == 0, I/Q dataset should be scaled within -1 to 1
% Otherwise, the output will be clipped at the DAC output
% If AWG_scale == 1, the program will divide [I Q] by max(max([I Q]))
% The actual output is equal to IQ data multiplied by the gain, which
% is between 0.37 - 0.5. 

function [] = AWG_N8241A_SignalUpload(instrumentHandle, waveform, AWG_AutoNorm)
  
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

