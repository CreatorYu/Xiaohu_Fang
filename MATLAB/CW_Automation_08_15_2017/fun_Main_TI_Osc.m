%% MATLAB ICT DPO/MSO2000/B Get Waveform
% Date:  May 30, 2017
% This script demonstrates how to pull waveform data off of a DPO/MSO2000/B
% and scale it for a simple plot.

% Tektronix provides the following example "AS IS" without any guarantees
% or support.  This example is for instructional guidance only.

%% variables
function Avg_reading=fun_Main_TI_Osc(scale1,tri1,CH)
% 固定记录长度为20K
% scale1='0.2';
% tri1='0.080';
%CH='CH1';
visa_brand = 'ni';
scale=sprintf('%s:SCALE %s',CH,scale1);
tri=sprintf('TRIGGER:A:LEVEL:%s %s',CH,tri1);
channel=sprintf('data:source %s',CH);
%scale1 = 'CH1:SCALE 0.2'
%tri = 'TRIGGER:A:LEVEL:CH1 0.080';
visa_address = 'USB0::0x0699::0x03C4::C025110::0::INSTR';
%visa_address = 'USB::0x0699::0x0368::C038753::INSTR';
buffer = 1000 * 1024; %20 KiB

%% open instrument
dpo2k = visa(visa_brand, visa_address, 'InputBuffer', buffer, ...
    'OutputBuffer', buffer);
fopen(dpo2k);

query(dpo2k, '*IDN?')

%% configure output
Vscale=100e-3;
Vscale1=num2str(Vscale);
fwrite(dpo2k, scale);
fwrite(dpo2k, tri);
fwrite(dpo2k, 'wfmo:byt_n 1');
record = str2double(query(dpo2k, 'hor:reco?'));
fwrite(dpo2k, 'header 0')
fwrite(dpo2k, 'data:encdg rib') %signed integer, msb first
fwrite(dpo2k, channel);
% fwrite(dpo2k, 'data:comp singular_yt') %see Appendix B of programmer's manual
% fwrite(dpo2k, 'data:resolution full') %DPO/MSO2000/B series only. See Appendix B
fwrite(dpo2k, 'data:start 1');
fprintf(dpo2k, 'data:stop %i', record);

%% request sample data
fwrite(dpo2k, 'curve?');

%% read binary block header
waste = fread(dpo2k, 1); %discard '#' character
a = char(fread(dpo2k, 1));
bytes = char(fread(dpo2k, str2double(a))');

% read digital values into sample matrix
samples = fread(dpo2k, str2double(bytes), 'int8');
fread(dpo2k, 1); %discard linefeed character

%% get scaling values
x_incr = str2double(query(dpo2k, "wfmo:xincr?"));
x_zero = str2double(query(dpo2k, "wfmo:xzero?"));
y_incr = str2double(query(dpo2k, "wfmo:ymult?"));
y_off = str2double(query(dpo2k, "wfmo:yoff?"));
y_zero = str2double(query(dpo2k, "wfmo:yzero?"));

%% close instrument
fclose(dpo2k); % close connection
delete(dpo2k); % remove the ICT object
clear dpo2k; % remove the local MATLAB variable

%% scale samples for plot
x_range = record * x_incr;
x_max = x_range + x_zero;
time_base = linspace(x_zero, x_max, record);

scaled_samples = (samples * y_incr) + y_off;

%% simple plot
plot(time_base(10000:15000), scaled_samples(10000:15000));
Avg_reading=mean(scaled_samples(10000:12000))

%plot(samples);
end