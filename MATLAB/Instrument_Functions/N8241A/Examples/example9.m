% Agilent N6030 Series Matlab Interface, Release 1.20.1.0
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
%  A simple example of how to play an advanced sequence of waveforms with the Agilent N6030A.
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
[ instrumentHandle, errorN, errorMsg ] = agt_awg_open('TCPIP','TCPIP0::A-N8241A-90xxx::inst0::INSTR');
if( errorN ~= 0 )
    % An error occurred while trying to open the session.
    disp('Could not open a session to the instrument');
    return;
end

% Turn the outputs on 
agt_awg_setstate( instrumentHandle, 'outputenabled', 'true' );
agt_awg_setstate( instrumentHandle, 'outputconfig','se');
agt_awg_setstate( instrumentHandle, 'predistortenabled','true');

% Select ARB mode
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
[waveformHandle3,e,m] = agt_awg_storewaveform( instrumentHandle, [ waveform3;waveform3] );

% Transfer the sequences to the instrument
% Sequence 1 is: \\///~~~~~\ (2 down ramps, 3 up ramps, 5 sine cycles, 1 down ramp are
% played as the following steps:
% 1) Down-ramp waveform is played twice, wait for a trigger.  All markers,wfm_start, wfm_rep and wfm_gate, are enabled.
% If 'sw3' is sent, move to step 2
% 2) Up-ramp waveform is played once, wait for a trigger.  Every time 'sw3' is sent
% again, step 2 is repeat until up-ramp waveform is played three times, then move to step 3.
% Marker wfm_start is disabled.
% 3) Sine waveform is played 5 times then auto advance to step 4.  Marker
% wfm_rep is disabled.
% 4) Down-ramp waveform is play once, wait for a trigger.  If 'sw3' is
% sent, go to next sequence if there is one.  Otherwise, go back to step 1.  Marker wfm_gate is disabled.

sequence1 = [    waveformHandle1, 2, 3, 0;
                waveformHandle2, 3, 2, 1; 
                waveformHandle3, 5, 0, 2;
                waveformHandle1, 1, 1, 4];
    
[sequenceHandle1,e,m] = agt_awg_storeadvsequence( instrumentHandle, sequence1 );

%Similarly, sequence 2 is setup as the following.
sequence2 = [   waveformHandle2, 2, 3, 0;
                waveformHandle1, 3, 2, 5;  %enable only marker wfm_rep 
                waveformHandle3, 5, 0, 3;  %enable only marker wfm_gate
                waveformHandle1, 1, 1, 7]; %disable all three markers
    
[sequenceHandle2,e,m] = agt_awg_storeadvsequence( instrumentHandle, sequence2 );

%Transfer scenarios to the instrument

%Scenario 1 plays sequence1 once then sequence2 once.
scenario1 = [sequenceHandle1, 1, 0;
             sequenceHandle2, 1, 0];

%Scenario 2 
scenario2 = [sequenceHandle1, 2, 0;
             sequenceHandle2, 1, 0];

[scenarioHandle1,e,m] = agt_awg_storescenario( instrumentHandle, scenario1);
[scenarioHandle2,e,m] = agt_awg_storescenario( instrumentHandle, scenario2);

% Start playing the scenario 1
[e,m] = agt_awg_setstate( instrumentHandle, 'arbscenhandle', scenarioHandle1);
[e,m] = agt_awg_sendsoftwaretrigger(instrumentHandle,'sw1');

% If you have a scope, you should see some waveform played now.
% To stop, use the following command 
%      [e,m] = agt_awg_sendsoftwaretrigger(instrumentHandle, 'sw2')
% To see next waveform, send the wfmadv trigger, by using the following
%       [e,m] = agt_awg_sendsoftwaretrigger(instrumentHandle, 'sw3')
% And so on.

% Now, after you have experiment the first scenario, now you
% can play the second scenario using the following commands:
[e,m] = agt_awg_sendsoftwaretrigger(instrumentHandle,'sw2')  % stop it first
[e,m] = agt_awg_setstate(instrumentHandle,'arbscenhandle',scenarioHandle2)
[e,m] = agt_awg_sendsoftwaretrigger(instrumentHandle,'sw1')  % start the second scenario

%Now, you can experiment the second scenario by sending 'sw3', the wfmadv
%trigger.

% To close the session, send the following command
agt_awg_close( instrumentHandle );
