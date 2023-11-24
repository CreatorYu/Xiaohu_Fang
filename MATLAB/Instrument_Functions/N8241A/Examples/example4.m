% Agilent N6030 Series Matlab Interface, Release 1.20.1.0
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
%  A simple example of how to create a waveform, open a session to the Agilent N6030
%  AWG, play the waveform, and close the session.
%
% Create a waveform - a sine wave with 2000 pts
% Played at 1250 MHz, this will produce a tone of 1.250 MHz
numberOfSamples_1 = 2000;
numberOfSamples_2 = 1000;
samples_ch1 = [-1999:-1000 1000:1999]; %[-numberOfSamples_1:-numberOfSamples_1/2 numberOfSamples_1/2:numberOfSamples_1];
samples_ch2 = [-999:-500 500:999];%[-numberOfSamples_2:-numberOfSamples_2/2-1 (numberOfSamples_2/2)-1:numberOfSamples_2];
samples_ch2 = [samples_ch2 samples_ch2];
ch1 = round(samples_ch1/numberOfSamples_1);
ch2 = round(samples_ch2/numberOfSamples_2);

waveform = [ ch1; ch2];

% Try to open a session, you need to put your instruments hostname or IP address into the VISA address below
% Host name defaults to A-[model number]-[last 5 digits of serial #]
% Host name VISA address would like: 'TCPIP0::A-N8241A-90123::inst0::INSTR' for a N8241A with a serial # of US45090123
% IP based VISA address would like: 'TCPIP0::196.196.196.196::inst0::INSTR' for an IP address of 196.196.196.196
disp('Opening a session to the instrument');
[ instrumentHandle, errorN, errorMsg ] = agt_awg_open('TCPIP','TCPIP0::169.254.144.24::inst0::INSTR');
if( errorN ~= 0 )
    % An error occurred while trying to open the session.
    disp('Could not open a session to the instrument');
    return;
end

disp('Enabling the instrument output');
[ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle, 'outputenabled', 'true');
if( errorN ~= 0 )
    % An error occurred while trying to enable the output.
	agt_awg_close( instrumentHandle );
    disp('Could not enable the instrument output');
    return;
end


disp('Setting the instrument to ARB mode');
[ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle, 'outputmode', 'arb');
if( errorN ~= 0 )
    % An error occurred while trying to set the ARB mode.
	agt_awg_close( instrumentHandle );
    disp('Could not set the instrument to ARB mode');
    return;
end

disp('Setting the instrument output configuration');
[ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle, 'outputconfig','diff');
if( errorN ~= 0 )
    % An error occurred while trying to set the ARB mode.
	agt_awg_close( instrumentHandle );
    disp('Could not set the instrument output configuration');
    return;
end

disp('Setting the instrument output gain');
[ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle, 'outputgain',0.5);
if( errorN ~= 0 )
    % An error occurred while trying to set the ARB mode.
	agt_awg_close( instrumentHandle );
    disp('Could not set the instrument output gain');
    return;
end

disp('Transfering the waveform to the instrument');
[ waveformHandle, errorN, errorMsg ] = agt_awg_storewaveform( instrumentHandle, waveform);
if( errorN ~= 0 )
    % An error occurred while trying to store the waveform.
 	agt_awg_close( instrumentHandle );
	disp('Could not transfer the waveform to the instrument');
    errorN
    errorMsg
    return;
end 

disp('Initiating playback of the waveform on the instrument');
[ errorN, errorMsg ] = agt_awg_playwaveform( instrumentHandle, waveformHandle );
if( errorN ~= 0 )
    % An error occurred while trying to playback the waveform.
	agt_awg_close( instrumentHandle );
    disp('Could not initiate playback of the waveform on the instrument');
    errorN
    errorMsg
    return;
end 

disp('Press ENTER to close the instrument session and conclude this example.');
pause;

agt_awg_close( instrumentHandle );
disp('Session to the instrument closed successfully.');
