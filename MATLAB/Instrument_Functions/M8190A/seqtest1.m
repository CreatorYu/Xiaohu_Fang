function seqtest1()
% Demonstration of M8190A sequencing capabilities
% with focus on time domain. Output is best viewed on an oscilloscope.
% This demo can also be used to show dynamic sequencing (see line 66)
%
% Instrument Configuration has to be set up using IQtools config dialog
%
% Agilent Technologies, Thomas Dippon, 2011-2013
%
% Disclaimer of Warranties: THIS SOFTWARE HAS NOT COMPLETED AGILENT'S FULL
% QUALITY ASSURANCE PROGRAM AND MAY HAVE ERRORS OR DEFECTS. AGILENT MAKES 
% NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND WITH RESPECT TO THE SOFTWARE,
% AND SPECIFICALLY DISCLAIMS THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
% FITNESS FOR A PARTICULAR PURPOSE.
% THIS SOFTWARE MAY ONLY BE USED IN CONJUNCTION WITH AGILENT INSTRUMENTS. 


% make sure that we can connect to the M8190A and have the right licenses
if (~iqoptcheck([], 'bit', 'SEQ'))
    return;
end
f = iqopen();
fprintf(f, ':abort');

% define the sample rate
fs = 8e9;
% define the segment length (make sure it divides evenly into 64 as well as
% 48, so that it can run in 12 bit as well as 14 bit mode
segLen = 3840;
% set up a couple of waveform segments
% single pulse
s1 = iqpulsegen('pw', segLen/2, 'off', segLen/2, 'rise', 0, 'fall', 0);
s1(segLen) = 0;
% noise
s2 = rand(segLen, 1) - 0.5;
s2(segLen) = 0;
% a triangle waveform
s3 = iqpulsegen('pw', 0, 'off', 0, 'rise', segLen/4, 'fall', segLen/4, 'high', [0.5 -0.5], 'low', 0);
% a sinusoidal waveform
s4 = 0.75*sin(2*pi*(1:segLen)/segLen);

loadSegments = 1;
if (loadSegments)
    % start from scratch and delete all segments
    iqseq('delete', [], 'keepOpen', 1);
    % download the waveform segments - identical data on channel 1 and 2
    iqdownload(complex(real(s1), real(s1)), fs, 'segmentNumber', 1, 'keepOpen', 1, 'run', 0);
    iqdownload(complex(real(s2), real(s2)), fs, 'segmentNumber', 2, 'keepOpen', 1, 'run', 0);
    iqdownload(complex(real(s3), real(s3)), fs, 'segmentNumber', 3, 'keepOpen', 1, 'run', 0);
    iqdownload(complex(real(s4), real(s4)), fs, 'segmentNumber', 4, 'keepOpen', 1, 'run', 0);
end

setupSequence = 1;
if (setupSequence)
    % and set up the sequence
    advanceMode = 'Auto';       % replace 'Auto' with 'Conditional' to show
                                % how the sequencer can wait for an event.
                                % You can press the "Force Event" button
                                % or apply a signal to the Event input
                                % to trigger the event
    clear seq;
    seq(1).segmentNumber = 1;
    seq(1).segmentLoops = 1;
    seq(1).markerEnable = true;
    seq(1).segmentAdvance = advanceMode;
    
    seq(2).segmentNumber = 2;
    seq(2).segmentLoops = 1;
    seq(2).segmentAdvance = advanceMode;
    
    seq(3).segmentNumber = 3;
    seq(3).segmentLoops = 1;
    seq(3).segmentAdvance = advanceMode;
    
    seq(4).segmentNumber = 4;
    seq(4).segmentLoops = 1;
    seq(4).segmentAdvance = advanceMode;
    iqseq('define', seq, 'keepOpen', 1, 'run', 0);
end

dyn = 1;    % set dyn=1 to enable dynamic switching between segments
if (dyn)
    fprintf(f, ':abort');
    fprintf(f, ':func1:mode arb');
    fprintf(f, ':func2:mode arb');
    fprintf(f, ':stab1:dyn on');
    fprintf(f, ':stab2:dyn on');
    fprintf(f, ':init:imm');
    % select a couple of segments - alternatively, use dynamic sequence
    % control connector
    fprintf(f, ':stab:dyn:sel 2');
    pause(2);
    fprintf(f, ':stab:dyn:sel 1');
    pause(2);
    fprintf(f, ':stab:dyn:sel 0');
    pause(2);
    fprintf(f, ':stab:dyn:sel 3');
end

%fprintf(sprintf('Result = %s', query(f, ':syst:err?')));
fclose(f);
end