% Agilent N6030 Series Matlab Interface, Release 1.20.1.0
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
%  A simple example of how to play a sequence of waveforms with the Agilent N6030A.
%  

numberOfSamples = 2000;
samples = 1:numberOfSamples;

waveform1 = 1 - 2*samples/numberOfSamples;          % A down ramp
waveform2 = 2*samples/numberOfSamples - 1;          % An up ramp
waveform3 = sin( samples/numberOfSamples * 2*pi);   % A sine wave

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

% Transfer the waveforms to the instrument
[waveformHandle1,e,m] = agt_awg_storewaveform( instrumentHandle, [ waveform1;waveform1] );
[waveformHandle2,e,m] = agt_awg_storewaveform( instrumentHandle, [ waveform2;waveform2] );
[waveformHandle3,e,m] = agt_awg_storewaveform( instrumentHandle, [ waveform3;waveform3] );

% Select SEQ mode
agt_awg_setstate( instrumentHandle, 'outputmode', 'seq');

% Transfer the sequence to the instrument
% Sequence is: \\///~~~~~ (2 down ramps, 3 up ramps, 5 sine cycles

sequence = [    waveformHandle1, 2;
                waveformHandle2, 3;
                waveformHandle3, 5 ];
    
[sequenceHandle,e,m] = agt_awg_storesequence( instrumentHandle, sequence );
if( e ~= 0 )
    % An error occurred while trying to store sequence.
	agt_awg_close( instrumentHandle );
    disp('Could not store the sequence');
    return;
end

% Start playing the waveform to the instrument
[e,m] = agt_awg_playsequence( instrumentHandle, sequenceHandle );
if( e ~= 0 )
    % An error occurred while trying to play the sequence.
	agt_awg_close( instrumentHandle );
    disp('Could not play the sequence');
    return;
end

% Close the session
agt_awg_close( instrumentHandle );
