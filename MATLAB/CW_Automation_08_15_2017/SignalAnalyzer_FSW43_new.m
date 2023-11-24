function mea_P = SignalAnalyzer_FSW43_new(IP,Freq,RefLev,i)

%i=0,Reset the instrument, clear the Error queue

%  IP         = '192.168.1.38';
%  Freq       = 4e9;
%   RefLev     = 10;
m=[];
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
    end
    specan.Write('INIT:CONT ON'); % Switch ON the continuous sweep
    specan.Write('SYST:DISP:UPD ON'); % Display update ON - switch OFF after debugging
    specan.ErrorChecking(); % Error Checking after Initialization block
    %-----------------------------------------------------------
    % Basic Settings:
    %-----------------------------------------------------------
    specan.Write('DISP:WIND:TRAC:Y:RLEV %0.2f', RefLev); % Setting the Reference Level
    specan.Write('FREQ:CENT %0.9f', Freq); % Setting the center frequency
    specan.Write('FREQ:SPAN %0.6f', 1E6); % Setting the span
    specan.Write('BAND %f', 2E3); % Setting the RBW
    %specan.Write('BAND:VID 300kHz', 300E3); % Setting the VBW
    for i=1:5
    specan.Write('SWE:POIN %d', 10001); % Setting the sweep points
    specan.ErrorChecking(); % Error Checking after Basic Settings block
    % -----------------------------------------------------------
    % SyncPoint 'SettingsApplied' - all the settings were applied
    % -----------------------------------------------------------
    specan.SetTimeoutMilliseconds(2000); % Sweep timeout - set it higher than the instrument measurement time
    specan.Write('INIT'); % Start the sweep
   % fprintf('Waiting for the sweep to finish... ');
    
    specan.QueryString('*OPC?'); % Using *OPC? query waits until the instrument finished the Acquisition
    
    specan.ErrorChecking(); % Error Checking after the acquisition is finished
    % -----------------------------------------------------------
    % SyncPoint 'AcquisitionFinished' - the results are ready
    % -----------------------------------------------------------
    % Fetching the trace in ASCII format
    % -----------------------------------------------------------
    sweepPoints = specan.QueryInteger('SWE:POIN?'); % Query the expected sweep points
    %fprintf('Fetching trace in ASCII format... ');
    
    traceASC = specan.QueryASCII_ListOfDoubles('FORM ASC;:TRAC? TRACE%d', sweepPoints, 1); % sweepPoints is the maximum possible allowed count to read
    
    %fprintf('Sweep points count: %d\n', size(traceASC, 2));
    specan.ErrorChecking(); % Error Checking after the data transfer
    % -----------------------------------------------------------
    % Fetching the trace in Binary format
    % The transfer time of traces in binary format is shorter.
    % The traceBIN data and traceASC data are however the same.
    % -----------------------------------------------------------
    %fprintf('Fetching trace in binary format... ');
    
    traceBIN = specan.QueryBinaryFloatData('FORM REAL,32;:TRAC? TRACE1');
    
    %fprintf('Sweep points count: %d\n', size(traceBIN, 2));
    specan.ErrorChecking(); % Error Checking after the data transfer
    % -----------------------------------------------------------
    % Setting the marker to max and querying the X and Y
    % -----------------------------------------------------------
    
    marker = 1;
    specan.Write('CALC1:MARK%d:MAX', marker); % Set the marker to the maximum point of the entire trace
    specan.QueryString('*OPC?'); % Using *OPC? query waits until the marker is set
    markerX = specan.QueryDouble('CALC1:MARK%d:X?', marker);
    markerY = specan.QueryDouble('CALC1:MARK%d:Y?', marker);
    m(i)=markerY; 
    fprintf('Marker Frequency %0.1f Hz, Level %0.2f dBm\n', markerX, markerY);
    specan.ErrorChecking(); % Error Checking after the markers reading
    plot(traceBIN); % Displaying the trace
    end
    mea_P=mean(m);
    % -----------------------------------------------------------
%     % Making an instrument screenshot and transferring the file to the PC
%     % -----------------------------------------------------------
%     fprintf('Taking instrument screenshot and saving it to the PC... ');
%     specan.Write('HCOP:DEV:LANG PNG;:MMEM:NAME ''c:\Temp\Device_Screenshot.png'''); % Hardcopy settings for taking a screenshot
%     specan.Write('HCOP:IMM'); % Make the screenshot now
%     specan.QueryString('*OPC?'); % Wait for the screenshot to be saved
%     specan.ErrorChecking(); % Error Checking after the screenshot creation
%     specan.Write('MMEM:DATA? ''c:\Temp\Device_Screenshot.png''');
%     specan.ReadBinaryDataToFile('c:\Temp\PC_Screenshot.png');
%     fprintf('saved to PC c:\\Temp\\PC_Screenshot.png\n');
%     specan.ErrorChecking(); % Error Checking after the screenshot save
    % -----------------------------------------------------------
    % Closing the session
    % -----------------------------------------------------------
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
end