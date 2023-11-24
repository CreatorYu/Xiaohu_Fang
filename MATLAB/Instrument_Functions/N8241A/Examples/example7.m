% Agilent N6030 Series Matlab Interface, Release 1.20.1.0
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.

%  A simple example of how to use the "savebin" and "savemarkerbin" attributes
%  available with the N6030A matlab functions (see: agt_awg_savebin.m and
%  agt_awg_savemarkerbin.m).  The binary files will be output to your
%  current working directory with a *.bin extension.  These files may then
%  be loaded by the N6030A Control Utility (GUI) and played out.
%

% 78.125 MHz CW Tone for N6030A, chosen for simple spacing of markers.
t = 0:1023;  %  1024 sample points.
Fsig = 78.125e6;  %  Waveform frequency.
Fs = 1250e6;  %  Clock frequency.
waveform = sin(2*pi*(Fsig/Fs)*t);  %  generate the waveform.
plot(t,waveform);
grid;

%  a call to the "agt_awg_savebin.m function" to create a 16 bit binary
%  file from the waveform data.
agt_awg_savebin('78_125MHz',waveform);

%  initialize marker 1 and marker 2.  each marker must have a length = ...
%  length(waveform)/8 since the Sync clk divide ratio is 8 (see: 
%   agt_awg_savemarkerbin.m).  the FPGA clock runs at Fs/8 when using 
%   the internal sampling clock.
m1 = zeros((length(t)/8),1);  
m2 = zeros((length(t)/8),1);  
count = 0;  

%  genearate the markers.  marker 1 will event every 16 cycles of the
%  waveform, while marker 2 will event every 32 cycles of the waveform and
%  be shifted by 8 cycles from marker 1.  note, there are also 16 samples
%  in each cycle and 64 cycles in the waveform.
for iter = 1: 32 : (length(t)/8)
    count = count + 1;
    if (iter < length(t))
        m1(iter,1) = 1;
        if (mod(count,2) == 0)
            m2(iter+16,1) = 1;
        end
    end
end

%  a call to the "agt_awg_savemarkerbin.m function" to create a 8 bit binary
%  file from the marker data.
agt_awg_savemarkerbin('78_125MHz_marker',m1,m2);
    