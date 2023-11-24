% Agilent N6030 Series Matlab Interface, Release 1.20.1.0
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
%  A simple example of how to create a waveform, open a session to the Agilent N6030
%  AWG, play the waveform, and close the session.
%
% Create waveform - a sine wave with 2000 pts
% Played at 1250 MHz, this will produce a tone of 1.250 MHz
numberOfSamples = 2000;
samples = 1:numberOfSamples;
ch1 = sin( 2*samples/numberOfSamples * 2*pi);
ch2 = cos( 2*samples/numberOfSamples * 2*pi);
waveform = [ ch1; ch2 ];

% Try to open a session, you need to put your instruments hostname or IP address into the VISA address below
% Host name defaults to A-[model number]-[last 5 digits of serial #]
% Host name VISA address would like: 'TCPIP0::A-N8241A-90123::inst0::INSTR' for a N8241A with a serial # of US45090123
% IP based VISA address would like: 'TCPIP0::196.196.196.196::inst0::INSTR' for an IP address of 196.196.196.196
[ instrumentHandle, errorN, errorMsg ] = agt_awg_open('TCPIP','TCPIP0::169.254.144.24::inst0::INSTR');
if( errorN ~= 0 )
    % An error occurred while trying to open the session.
    disp('Could not open a session to the instrument');
    return;
end

% Turn the outputs on 
agt_awg_setstate( instrumentHandle, 'outputenabled', 'true' );

% Select ARB mode
agt_awg_setstate( instrumentHandle, 'outputmode', 'arb');

% Transfer the waveform to the N6030A
[ waveformHandle, errorN, errorMsg ] = agt_awg_storewaveform( instrumentHandle, waveform);
if( errorN ~= 0 )
    % An error occurred while trying to store the waveform.
	agt_awg_close( instrumentHandle );
    disp('Could not transfer the waveform to the instrument');
    errorN
    errorMsg
    return;
end 

% Start playing the waveform to the instrument
[ errorN, errorMsg ] = agt_awg_playwaveform( instrumentHandle, waveformHandle );
if( errorN ~= 0 )
    % An error occurred while trying to playback the waveform.
	agt_awg_close( instrumentHandle );
    disp('Could not initiate playback of the waveform on the instrument');
    errorN
    errorMsg
    return;
end 

% Close the session
agt_awg_close( instrumentHandle );
