% Agilent N6030 Series Matlab Interface, Release 1.20.1.0
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
function [ freq, waveform ] = example5( numberOfSamples )
%  A simple example of how to create a waveform, open a session to the Agilent N6030
%  AWG, play the waveform, and close the session.
%
% Create waveform - a sine wave with N number of sample points
% if( rem(numberOfSamples,16) ~= 0 )
%     disp('numberOfSamples must be a multiple of 16');
%     return;
% end
% 
% freq = 1.250e9 / numberOfSamples;
% disp( ['Based on a 1.25 GHz sample clock, the output frequency is ', num2str(freq/1e6), ' MHz.' ] );

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
[ instrumentHandle, errorN, errorMsg ] = agt_awg_open('TCPIP','TCPIP0::169.254.144.24::inst0::INSTR');
if( errorN ~= 0 )
    % An error occurred while trying to open the session.
    disp('Could not open a session to the instrument');
    return;
end

% Turn the outputs on 
agt_awg_setstate( instrumentHandle, 'outputenabled', 'true' );

agt_awg_setstate( instrumentHandle, 'outputconfig', 'amp' );
agt_awg_setstate( instrumentHandle, 'outputgain', '0.5' );




% Select ARB mode
agt_awg_setstate( instrumentHandle, 'outputmode', 'arb');

% Transfer the waveform to the instrument
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
