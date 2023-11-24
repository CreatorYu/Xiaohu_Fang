function IQUpload_AWG_M8190A(SignalsCell, CarrierFreqCell, SampleFreqCell, SampleFreqAWG, CorrectionEnabled)
% Upload one or several signals to the configured AWG
% - SignalsCell - cell of complex signals that needs to be sent
% - CarrierFreqCell - cell of carrier frequency values to which signals will be
% upconverted
% - SampleFreqCell - cell of sampling frequency values of each signal 
% - SampleFreqAWG - Sample Frequency of the M8190A. Value should be between
% 125e6 and 8e9 for Version 14Bits and 125e6 and 12e9 for Version 12Bits
% - CorrectionEnabled - logical value for enabling the amplitude correction
% saved in the ampCorr.mat



    UpsamplingMethod = 'Interpolation' ; % either 'Interpolation' or 'FFT' could be used
    channelMapping = [1 0; 0 1] ; %Set I to channel 1 and Q to channel 2 
    
    
   
    if SampleFreqAWG > 8e9
        msgbox('Please check the highest sampling rate', 'Error');
        return
    end

    for j = 1 : length(SignalsCell)
        iqdata = [];
        fs = 0;
        marker = [];
        % read data
            iqdata = SignalsCell{j} ;
            iqdata = reshape(iqdata, length(iqdata), 1) ;
           
            fs = SampleFreqCell{j} ;
        % resample if necessary
            if fs < SampleFreqAWG
                method = UpsamplingMethod;
                factor = SampleFreqAWG/fs ;
                switch (method)
                    case 'Interpolation'; ipfct = @(data,r) interp(double(data), r);
                    case 'FFT'; ipfct = @(data,r) interpft(data, r * length(data));
                    otherwise error('unknown method');
                end
                try
                    iqdata = ipfct(iqdata, factor);
                    fs = fs * factor;
                catch ex
                    errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
                end
            end
        % Upconversion
            fc = CarrierFreqCell{j} ;
            n = length(iqdata);
            iqdata = iqdata .* exp(1i*2*pi*(n*fc/fs)/n*(1:n)') ;
        % Combine Signal
            if j == 1
                iqtotaldata = iqdata ;
            else
                iqtotaldata = iqtotaldata+iqdata ;
            end
    end
    
    if (CorrectionEnabled)
        iqtotaldata = iqCorrectionEnabled(iqtotaldata, fs);
    end
    
    marker = [ones(floor(factor*5*2),1); zeros(length(iqtotaldata)-floor(factor*5*2),1)] ;


% Plot Combined signal for verification
    assignin('base', 'iqtotaldata', iqtotaldata) ;
    assignin('base', 'fs', fs) ;
    
    if (~isempty(iqtotaldata))
         iqplot(iqtotaldata, fs, 'marker', marker) ;
    end

% Upload the signal to the AWG
    hMsgBox = msgbox('Downloading Waveform. Please wait...', 'Please wait...');
    iqdata = iqtotaldata ;
    
    if (~isempty(iqdata))
        len = numel(iqdata);
        iqdata = reshape(iqdata, len, 1);
        marker = reshape(marker, numel(marker), 1);
        arbConfig = loadArbConfig();
        rept = lcm(len, arbConfig.segmentGranularity) / len;
        if (rept * len < arbConfig.minimumSegmentSize)
            rept = rept+1;
        end
        segmentNum = 1;
        iqdownload(repmat(iqdata, rept, 1), fs, 'channelMapping', channelMapping, ...
            'segmentNumber', segmentNum, 'marker', repmat(marker, rept, 1));
        assignin('base', 'iqdata', repmat(iqdata, rept, 1));
    end
    delete(hMsgBox)


