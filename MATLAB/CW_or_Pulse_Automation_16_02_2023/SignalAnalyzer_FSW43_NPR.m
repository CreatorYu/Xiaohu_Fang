 function  NPR=SignalAnalyzer_FSW43_NPR(IP,Freq,BW,RefLev,i)
%   i=1; %Reset the instrument, clear the Error queue
%   IP         = '192.168.1.105';
%   Freq       = 26e9;
%   RefLev     = -20;
%   BW    = 100e6;
try
    specan = VISA_Instrument(['TCPIP::' IP '::hislip0']); % Adjust the VISA Resource string to fit your instrument
    specan.SetTimeoutMilliseconds(3000); % Timeout for VISA Read Operations
    % specan.AddLFtoWriteEnd = false;
catch ME
    error ('Error initializing the instrument:\n%s', ME.message);
end

try
    specan.ClearStatus();
    idnResponse = specan.QueryString('*IDN?');
    fprintf('\nInstrument Identification string: %s\n', idnResponse);
    if i==0
        specan.Write('*RST;*CLS'); % Reset the instrument, clear the Error queue
    elseif i==1
    specan.Write('INIT:CONT ON'); % Switch ON the continuous sweep
    specan.Write('SYST:DISP:UPD ON'); % Display update ON - switch OFF after debugging
    specan.ErrorChecking(); % Error Checking after Initialization block
    %-----------------------------------------------------------
    % Basic Settings:
    %-----------------------------------------------------------
    specan.Write('DISP:WIND:TRAC:Y:RLEV %f', RefLev); % Setting the Reference Level
    specan.Write('FREQ:CENT %f', Freq); % Setting the center frequency
    specan.Write('FREQ:SPAN %f', BW); % Setting the span
    specan.Write('BAND %f', 30E3); % Setting the RBW
    %specan.Write('BAND:VID 300kHz', 300E3); % Setting the VBW
    specan.ErrorChecking(); % Error Checking after Basic Settings block
    % -----------------------------------------------------------

    specan.Write('NPR:STAT ON'); % Activate NPR measurement
    specan.Write('NPR:CHAN:BWID %f',BW); % Specify the channel bandwidth to be used = 72 MHz
    specan.Write('NPR:CHAN:INT:AUTO ON'); % Active the basic channel
    specan.Write('NPR:NOTC:COUN 1'); % Setting the number of notcs 
    specan.Write('NPR:NOTC1:FREQ:OFFS 0'); % Setting the notc offset frequency
    specan.Write('NPR:NOTC1:BWID:REL 5'); % Setting the notc bandwith
%     specan.Write('NPR:NOTC2:FREQ:OFFS 25e6'); % Setting the notc offset frequency
%     specan.Write('NPR:NOTC2:BWID:REL 5'); % Setting the notc bandwith
    specan.ErrorChecking(); % Error Checking after the markers reading
%    specan.Write('INIT:CONT OFF'); % Select single sweep mode
    specan.Write('INIT;*WAI'); % Initiate a new measurement and wait until the sweep has finished.
    pause(1);
    NPR=specan.QueryDouble('CALC:NPR:RES? NPR'); %Query the noise power ratio,retured in dB
    fprintf('\n The NPR is %f dB \n', NPR);
    end
    % -----------------------------------------------------------
    % Closing the session
    % -----------------------------------------------------------
    specan.Write('@LOC'); % Go to Local
    specan.Close() % Closing the session to the instrument
    % -----------------------------------------------------------
    % Error handling
    % -----------------------------------------------------------
catch ME
    switch ME.identifier
        case 'VISA_Instrument:ErrorChecking'
            % Perform your own additional steps here
            rethrow(ME);
        otherwise
            rethrow(ME)
    end
end
