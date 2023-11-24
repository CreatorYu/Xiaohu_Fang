 function [IMD3_lower,IMD3_upper] = SignalAnalyzer_FSW43_IMD3(IP,Freq,spacing,RefLev,i)
%   i=0; %Reset the instrument, clear the Error queue
%   IP         = '192.168.1.108';
%   Freq       = 26e9;
%   RefLev     = 10;
%   spacing=40e6;
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
    specan.Write('FREQ:SPAN %f', 5*spacing); % Setting the span
    specan.Write('BAND %f', 200E3); % Setting the RBW
    %specan.Write('BAND:VID 300kHz', 300E3); % Setting the VBW
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
        sweepPoints = specan.QueryInteger('SWE:POIN?'); % Query the expected sweep points
    fprintf('Fetching trace in ASCII format... ');
    tic
    traceASC = specan.QueryASCII_ListOfDoubles('FORM ASC;:TRAC? TRACE%d', sweepPoints, 1); % sweepPoints is the maximum possible allowed count to read
    toc
    fprintf('Sweep points count: %d\n', size(traceASC, 2));
    specan.ErrorChecking(); % Error Checking after the data transfer

     fprintf('Fetching trace in binary format... ');
    tic
    traceBIN = specan.QueryBinaryFloatData('FORM REAL,32;:TRAC? TRACE1');
    toc
    fprintf('Sweep points count: %d\n', size(traceBIN, 2));
    specan.ErrorChecking(); % Error Checking after the data transfer
    % -----------------------------------------------------------
    % Setting the marker to max and querying the X and Y
    % -----------------------------------------------------------
    f1=Freq-0.5*spacing;
    f2=Freq+0.5*spacing;
    f3=Freq-1.5*spacing;
    f4=Freq+1.5*spacing;
    specan.Write('CALC1:MARK1:STAT ON'); % Setting the Marker on
    specan.Write('CALC1:MARK1:x %f',f3); % Setting the lower IMD3 frequency
    specan.Write('CALC1:MARK2:STAT ON'); % Setting the Marker on
    specan.Write('CALC1:MARK2:x %f',f1); % Setting the lower tone frequency
    specan.Write('CALC1:MARK3:STAT ON'); % Setting the Marker on
    specan.Write('CALC1:MARK3:x %f',f2); % Setting the upper tone frequency
    specan.ErrorChecking(); % Error Checking after the markers reading
    specan.Write('CALC1:MARK4:STAT ON'); % Setting the Marker on
    specan.Write('CALC1:MARK4:x %f',f4); % Setting the upper IMD3 frequency
    pause(0.8);

        marker1 = 1;
    markerX1 = specan.QueryDouble('CALC1:MARK%d:X?', marker1);
    markerY1 = specan.QueryDouble('CALC1:MARK%d:Y?', marker1);
    fprintf('Marker Frequency %f Hz, Level %0.2f dBm\n', markerX1, markerY1);


        marker2 = 2;
    markerX2 = specan.QueryDouble('CALC1:MARK%d:X?', marker2);
    markerY2 = specan.QueryDouble('CALC1:MARK%d:Y?', marker2);
    fprintf('Marker Frequency %f Hz, Level %0.2f dBm\n', markerX2, markerY2);
    specan.ErrorChecking(); % Error Checking after the markers reading

        marker3 = 3;
    markerX3 = specan.QueryDouble('CALC1:MARK%d:X?', marker3);
    markerY3 = specan.QueryDouble('CALC1:MARK%d:Y?', marker3);
    fprintf('Marker Frequency %f Hz, Level %0.2f dBm\n', markerX3, markerY3);
    specan.ErrorChecking(); % Error Checking after the markers reading

        marker4 = 4;
    markerX4 = specan.QueryDouble('CALC1:MARK%d:X?', marker4);
    markerY4 = specan.QueryDouble('CALC1:MARK%d:Y?', marker4);
    fprintf('Marker Frequency %f Hz, Level %0.2f dBm\n', markerX4, markerY4);
    specan.ErrorChecking(); % Error Checking after the markers reading

    IMD3_lower=markerY1-markerY2;
    IMD3_upper=markerY4-markerY3;
    fprintf('IMD3_lower %0.2f dBc\n',IMD3_lower);
    fprintf('IMD3_upper %0.2f dBc\n',IMD3_upper);
    %plot(traceBIN);
    end

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
