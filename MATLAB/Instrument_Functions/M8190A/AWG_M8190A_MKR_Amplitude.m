function AWG_M8190A_MKR_Amplitude(Channel,Amplitude)
% Configure the Sample Marker Amplitude for the M8190A
% Channel - Specify the channel to be set (1 or 2)
% Amplitude - Voltage Amplitude (between 0 and 1.5 V)
    
    arbConfig = loadArbConfig();
    f = iqopen(arbConfig);
     if Amplitude < 0 || Amplitude > 1.5
        msgbox('The Voltage should be between 0 and 1.5 V', 'Error');
        return
     else 
         xfprintf(f, sprintf(':SOUR:MARK%d:SAMP:VOLT:AMPL %d',Channel,Amplitude));
     end
    
             
end            
