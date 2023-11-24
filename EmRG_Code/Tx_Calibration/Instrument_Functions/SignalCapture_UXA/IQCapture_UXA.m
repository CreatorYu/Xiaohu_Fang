function [I, Q] = IQCapture_UXA (Freq, Fsample, time, UXAAdd, Atten, ...
    ClockReference)

    clkrate = Fsample * 1.25;
%     if clkrate >= 600e6;
%         clkrate = 600e6;
%     end

    Frequency = num2str(Freq);
    capture_time = num2str(time);
    Address = UXAAdd ;
    Attenuation = num2str(Atten);
    digital_IF_BW = num2str(Fsample);

    obj.handle = {};
    obj.Address = Address;

    saCfg.connected = 1 ;
    saCfg.connectionType = 'visa';
    saCfg.visaAddr = [num2str(Address)] ;
    saCfg.useListSweep = 0 ;
    saCfg.useMarker = 0 ;
    saCfg.InputBufferSize = 10e9;
    % Test connection
    obj1 = iqopen(saCfg);
    fclose(obj1);
    obj1 = obj1(1);

    obj.handle = obj1;

    obj.handle.Timeout = 25;

    obj.OnOff = false;
    obj.scale_type = '';
    obj.Initialized = true;
    try 
        fopen(obj.handle);
        freq_read = query(obj.handle,':SENSe:FREQuency:RF:CENTer?');

        fprintf(obj.handle,[':INSTrument:SELect BASIC']);     
        fprintf(obj.handle,':CONF:WAV');

        fprintf(obj.handle,':FORM:DATA REAL,32');
        fprintf(obj.handle,':FORM:BORD SWAP');
        % Set the center RF Frequency
        fprintf(obj.handle,[':SENSe:FREQuency:RF:CENTer ' Frequency]);
        % Set the IF path to the 1 GHz IF path
        fprintf(obj.handle,[':IFPath:AUTO ON']);
        % Set the complex sampling rate
        fprintf(obj.handle,[':WAVeform:SRATe ' num2str(clkrate)]);
    %     % Enable the low noise path
    %     fprintf(obj.handle,[':POW:MW:PATH LNP']);
        % Set the digital IF bandwidth
        fprintf(obj.handle,[':WAVeform:DIF:BANDwidth ' digital_IF_BW]);
        % Set the mechanical attenuator value
        fprintf(obj.handle,[':SENSe:POW:Attenuation ' Attenuation]);
        % Set the oscillator source to use the external reference
        fprintf(obj.handle,[':ROSCillator:SOURce:TYPE ', ClockReference]);
        % Set the trigger to the external 1 trigger
        fprintf(obj.handle,[':TRIGger:WAV:SOURce ', 'EXTernal3']);
        fprintf(obj.handle,[':TRIGger:EXTernal3:LEVel 0.7']);
        % Set the measuring time
        fprintf(obj.handle,[':WAVeform:SWEep:TIME ' capture_time]);
        fprintf(obj.handle,':FETCh:WAV0?');
        data = binblockread(obj.handle,'float32');
        fscanf(obj.handle); %removes the terminator character

        I = data(1:2:length(data));
        Q = data(2:2:length(data));

        % Resample the data to the IF analysis bandwidth
        [downsample, upsample] = rat(Fsample/clkrate);
        % Drop the uncorrelated samples from UXA settling
        uncorrelatedSamples = 0; 
        % Apply a high order filter to supress the decimation artifacts
%         resamplingFilterOrder = 80;
%         I = resample(I(uncorrelatedSamples:end), downsample, upsample, resamplingFilterOrder);
%         Q = resample(Q(uncorrelatedSamples:end), downsample, upsample, resamplingFilterOrder); 
        I = I(1+uncorrelatedSamples:end);
        Q = Q(1+uncorrelatedSamples:end);
        
        % Close the connection to the UXA
        fclose(obj.handle);
    catch
        warning('Problem during capture IQ, please check memory.')
        fclose(obj.handle);
    end
end                        
