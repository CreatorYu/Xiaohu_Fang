% Agilent N6030 Series Matlab Interface, Release 1.20.1.0
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
%  A simple example of how to play a DDS sequence of waveforms with the Agilent N6030A.
%  Make sure your instrument has the DDS option

numberOfSamples = 12500;
samples = 1:numberOfSamples;
samples = samples*0;
waveform1 = 1 + samples;          % A dc waveform 
waveform2 = -1 + samples;         % Another dc waveform

% Try to open a session, you need to put your instruments hostname or IP address into the VISA address below
% Host name defaults to A-[model number]-[last 5 digits of serial #]
% Host name VISA address would like: 'TCPIP0::A-N8241A-90123::inst0::INSTR' for a N8241A with a serial # of US45090123
% IP based VISA address would like: 'TCPIP0::196.196.196.196::inst0::INSTR' for an IP address of 196.196.196.196
[ instrumentHandle, errorN, errorMsg ] = agt_awg_open('TCPIP','TCPIP0::A-N8241A-90xxx::inst0::INSTR','DDS');
if( errorN ~= 0 )
    % An error occurred while trying to open the session.
    disp('Could not open a session to the instrument');
    return;
end

% Turn the outputs on 
agt_awg_setstate( instrumentHandle, 'outputenabled', 'true' );
agt_awg_setstate( instrumentHandle, 'outputconfig','se');
agt_awg_setstate( instrumentHandle, 'predistortenabled','false');

% Select advanced sequence mode
agt_awg_setstate( instrumentHandle, 'outputmode', 'adv_seq');

%Setup start trigger and stop trigger and waveform advance trigger
agt_awg_setstate( instrumentHandle, 'start','sw1');
agt_awg_setstate( instrumentHandle, 'stop','sw2');
agt_awg_setstate( instrumentHandle, 'wfmadv','sw3');

%Setup marker sources: marker1 = wfm_start, marker2 = wfm repeat, marker3 = wfm_gate
agt_awg_setstate( instrumentHandle, 'mkrsource','wfm_start',1);
agt_awg_setstate( instrumentHandle, 'mkrsource','wfm_rep',2);
agt_awg_setstate( instrumentHandle, 'mkrsource','wfm_gate',3);


% Transfer the waveforms to the instrument
[waveformHandle1,e,m] = agt_awg_storewaveform( instrumentHandle, [ waveform1;waveform1] );
[waveformHandle2,e,m] = agt_awg_storewaveform( instrumentHandle, [ waveform2;waveform2] );

% Transfer a sequence to the instrument
% The below sequence is played as the following steps:
% 1) waveform 1 is played 100000 times then auto advance to step 2.  All markers,wfm_start, wfm_rep and wfm_gate, are enabled.
% In step 1, initial frequency is set to 1 MHz, assume the clock rate is
% 1.25GHz.  Frequency slope is 1 MHz/sec, or end frequency is 2 MHz.
% Initial phase is 0 degree, initial phase is disabled.  Initial amplitude
% is 1 full scale.  Amplitude slope is 0.
% 2) waveform 2 is played 100000, from 2MHz to 1 MHz, 
% Initial phase is 45 degrees, initial phase is enabled.
% Initial amplitude is 0.5 full scale, end amplitude is 1 full scale.
% That means amplitude slope is 0.5 FS/sec.  

sequence = [   waveformHandle1, 100000, 0, 1000000, 1000000, 1, 0, 0 ;
               waveformHandle2, 100000, 45,2000000, -1000000, 0.5, 500000, 1 ];
    
[sequenceHandle,e,m] = agt_awg_storeddssequence( instrumentHandle, sequence );

%Transfer scenarios to the instrument
%Scenario has 1 sequence.
scenario = [sequenceHandle, 1, 0];

[scenarioHandle,e,m] = agt_awg_storeddsscenario( instrumentHandle, scenario);

% Start playing the scenario 1
[e,m] = agt_awg_setstate( instrumentHandle, 'arbscenhandle', scenarioHandle);
[e,m] = agt_awg_sendsoftwaretrigger(instrumentHandle,'sw1');

% To stop playing, send stop trigger
%[e,m] = agt_awg_sendsoftwaretrigger(instrumentHandle,'sw2');

% To close the session, send the following command
agt_awg_close( instrumentHandle );
