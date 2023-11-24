function result = dphy(varargin)
% Set up two M8190A modules to run in sync. This function is typically
% called from the multi_channel_sync_gui, but it can also be called from
% other MATLAB functions.
% Parameters are passed as name/value pairs. The following parameter names
% are supported:
% 'sampleRate' - the samplerate that will be used by both M8190A modules
% 'cmd' - can be 'init', 'run', 'display'
%
% Agilent Technologies, Thomas Dippon, 2011-2013
%
% Disclaimer of Warranties: THIS SOFTWARE HAS NOT COMPLETED AGILENT'S FULL
% QUALITY ASSURANCE PROGRAM AND MAY HAVE ERRORS OR DEFECTS. AGILENT MAKES 
% NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND WITH RESPECT TO THE SOFTWARE,
% AND SPECIFICALLY DISCLAIMS THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
% FITNESS FOR A PARTICULAR PURPOSE.
% THIS SOFTWARE MAY ONLY BE USED IN CONJUNCTION WITH AGILENT INSTRUMENTS. 

if (nargin == 0)
    dphy_gui;
    return;
end
% set default values - will be overwritten by arguments
result = [];
cmd = '';
sampleRate = 12e9;
fixedSkew = [0 0 0 0];
slaveClk = 'extclk';
clear dParam;
dParam.lpDataRate = 10e6;
dParam.hsDataRate = 2.5e9;
dParam.lpLow = 0;
dParam.lpHigh = 0.6;
dParam.hsLow = 0.1;
dParam.hsHigh = 0.4;
dParam.lpPattern = '0 1 0 2 0 1 0 2 0 1 3 3 3 2 0';
dParam.hsPattern = '0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5';
dParam.hsSkewAB = 0;
dParam.hsSkewAC = 0;
i = 1;
while (i <= nargin)
    if (ischar(varargin{i}))
        switch lower(varargin{i})
            case 'samplerate';     sampleRate = varargin{i+1};
            case 'cmd';            cmd = varargin{i+1};
            case 'dparam';         dParam = varargin{i+1};
            otherwise; error(['unexpected argument: ' varargin{i}]);
        end
    else
        error('string argument expected');
    end
    i = i+2;
end

arbConfig = loadArbConfig();
if (~isfield(arbConfig, 'visaAddr2'))
    errordlg('Please configure second M8190A module in "Instrument Configuration"');
    return;
end


dParam.lpAmp = dParam.lpHigh - dParam.lpLow;
dParam.lpOffs = (dParam.lpHigh + dParam.lpLow)/2;
dParam.hsAmp = dParam.hsHigh - dParam.hsLow;
dParam.hsOffs = (dParam.hsHigh + dParam.hsLow)/2;
dParam.max = max([dParam.lpHigh dParam.lpLow dParam.hsHigh dParam.hsLow]);
dParam.min = min([dParam.lpHigh dParam.lpLow dParam.hsHigh dParam.hsLow]);
dParam.maxAmp = dParam.max - dParam.min;
dParam.maxOffs = (dParam.max + dParam.min) / 2;
if (isfield(dParam, 'DelayA'))
    fixedSkew = [dParam.DelayA dParam.DelayB dParam.DelayC 0];
end

% common sample rate for both AWGs
fs = sampleRate;

switch (cmd)
    case 'init'
        [awg1, awg2, syncCfg, scopeCfg] = makeCfg(arbConfig);
        if (~iqoptcheck(awg1, 'bit', 'SEQ'))
            result = -1;
            return;
        end
        if (~iqoptcheck(awg2, 'bit', 'SEQ'))
            result = -1
            return;
        end
        result = setupTestPattern(arbConfig, fs, 1, slaveClk, cmd, fixedSkew, dParam);
        if (isempty(result))
            result = autoDeskew(arbConfig, fs, slaveClk, fixedSkew, dParam);
        end
    case {'run'}
        result = setupTestPattern(arbConfig, fs, 0, slaveClk, cmd, fixedSkew, dParam);
        if (isfield(arbConfig, 'visaAddrScope'))
            setupScope(arbConfig, dParam);
        end
    case {'display'}
        [awg1, awg2, syncCfg, scopeCfg] = makeCfg(arbConfig);
        wfms = calcWfm(sampleRate, awg1, dParam, cmd);
        sig = cell2mat(wfms.').';
        sig = [real(sig(:,1)) imag(sig(:,1)) real(sig(:,2))];
        % scale from normlized to voltage
        sig = (sig + 1)/2 * dParam.maxAmp + dParam.min;
        figure(1);
        clf;
        set(gcf(),'Name','C-PHY generator demo');
        xaxis = linspace(0, (size(sig,1)-1)/fs, size(sig,1));
        plot(xaxis, sig, '.-', 'LineWidth', 2);
        ylim([dParam.min - 0.1*dParam.maxAmp dParam.max + 0.1*dParam.maxAmp]);
        xlabel('time (s)');
        ylabel('Voltage into 50 Ohm (V)');
        legend({'A', 'B', 'C'});
    case {'scope'}
        if (isfield(arbConfig, 'visaAddrScope'))
            setupScope(arbConfig, dParam);
        end
    case 'stop'
        result = doStop(arbConfig);
    otherwise
        error('unknown cmd');
end


function result = doStop(arbConfig)
[awg1 awg2 syncCfg scopeCfg] = makeCfg(arbConfig);
if (~isempty(syncCfg))
    fsync = iqopen(syncCfg);
    if (isempty(fsync))
        return;
    end
    xfprintf(fsync, ':abor');
    xfprintf(fsync, ':inst:mmod:conf 1');
    fclose(fsync);
else
    % open the connection to the AWGs
    f1 = iqopen(awg1);
    if (isempty(f1))
        return;
    end
    f2 = iqopen(awg2);
    if (isempty(f2))
        return;
    end
    % stop both of them
    fprintf(f1, ':abort');
    fprintf(f2, ':abort');
    fclose(f1);
    fclose(f2);
end
result = [];



function setupScope(arbConfig, dParam)
% connect to scope
[~, ~, ~, scopeCfg] = makeCfg(arbConfig);
fscope = iqopen(scopeCfg);
if (isempty(fscope))
    return;
end
% remove all measurements to avoid a cluttered screen
xfprintf(fscope, ':meas:clear');
amp0 = dParam.maxAmp;
offs0 = dParam.maxOffs;
if (isempty(dParam.lpPattern))
    amp1 = dParam.hsAmp;
    offs1 = dParam.hsOffs;
    timescale = 2 / dParam.hsDataRate;
else
    amp1 = dParam.maxAmp;
    offs1 = dParam.maxOffs;
    timescale = 500e-9;
    % don't attempt to do eye diagram with LP & HS data together
    if (dParam.scopeMode == 3)
        return;
    end
end
avg = 'off';
% setup function
xfprintf(fscope, ':func1:SUBtract chan1,chan2');
xfprintf(fscope, ':func2:SUBtract chan2,chan3');
xfprintf(fscope, ':func3:SUBtract chan3,chan1');
switch (dParam.scopeMode)
    case 1 % overlaid
        k = 3;
        b = -2;
        xfprintf(fscope, sprintf(':timebase:scal %g', timescale));
        xfprintf(fscope, 'disp:cgrade off');
        offs = [b*amp1/k+offs1 b*amp1/k+offs1 b*amp1/k+offs1 2*amp0+offs0];
        scale = [amp1/k amp1/k amp1/k amp0];
        funcScale = 2*amp1/k;
        funcOffs = 2*funcScale;
        trigChan = 'aux';
        trigLev = 100e-3;
    case 2 % individual
        k = 1.5;
        xfprintf(fscope, sprintf(':timebase:scal %g', timescale));
        xfprintf(fscope, 'disp:cgrade off');
        offs = [-3*amp1/k+offs1 1*amp1/k+offs1 -1*amp1/k+offs1 3*amp0+offs0];
        scale = [amp1/k amp1/k amp1/k amp0];
        funcScale = 2*amp1/k;
        funcOffs = 3*funcScale;
        trigChan = 'aux';
        trigLev = 100e-3;
    case 3 % eye diagram
        xfprintf(fscope, sprintf(':timebase:scal %g', 0.3 / dParam.hsDataRate));
        xfprintf(fscope, sprintf(':timebase:delay %g', 1 / dParam.hsDataRate));
        xfprintf(fscope, 'disp:cgrade on');
        amp2 = (dParam.hsHigh - dParam.hsLow);
        offs2 = (dParam.hsHigh + dParam.hsLow) / 2;
        sc = 3;
        offs = [-2*amp2/sc+offs2 -2*amp2/sc+offs2 -2*amp2/sc+offs2 3*amp0+offs0];
        scale = [amp2/sc amp2/sc amp2/sc amp0];
        funcScale = 2*amp2/sc;
        funcOffs = 2*funcScale;
        trigChan = 'chan4';
        trigLev = dParam.maxOffs;
        avg = 'off';
end
for i = [3 2 1]
    xfprintf(fscope, sprintf(':chan%d:disp on; scale %g; offs %g', i, scale(i), offs(i)));
end
% turn on function
for i = [3 2 1]
    xfprintf(fscope, sprintf(':func%d:scale %g; offset %g', i, funcScale, funcOffs));
    xfprintf(fscope, sprintf(':func%d:display on', i));
end
% setup timebase
% setup trigger
xfprintf(fscope, sprintf(':trig:lev %s,%g', trigChan, trigLev));
xfprintf(fscope, sprintf(':trig:edge:source %s', trigChan));
% turn on averaging
xfprintf(fscope, sprintf(':acquire:average:count 8'));
xfprintf(fscope, sprintf(':acquire:average %s', avg));
% turn down the bandwidth to reduce the sampling ripple at lower rates
if (dParam.hsDataRate <= 2e9)
    xfprintf(fscope, sprintf(':acquire:bandwidth 6 GHz'));
else
    xfprintf(fscope, sprintf(':acquire:bandwidth auto'));
end
xfprintf(fscope, sprintf(':cdisplay'));
fclose(fscope);


function result = setupTestPattern(arbConfig, fs, doDeskew, slaveClk, cmd, fixedSkew, dParam)
global cal_amp;
global cal_offs;
global g_skew;
[awg1, awg2, syncCfg, ~] = makeCfg(arbConfig);
switch lower(slaveClk)
    case {'extclk' 'external sample clock' }
        refSource = 'AXI';
        awg2.extClk = 1;   % ARB #2 is the slave and will run on external clock
    case {'axiref' 'axi reference clock' }
        refSource = 'AXI';
        awg2.extClk = 0;
    case {'extref' 'external reference clock' }
        refSource = 'EXTernal';
        awg2.extClk = 0;
    otherwise
        error(['unexpected slaveClk parameter: ' slaveClk]);
end
if (mod(length(dParam.lpPattern), 2) ~= 0)
    msgbox('length of LP pattern must be even');
    result = -1;
    return;
end
dummySegNum = 1;
% open the connection to the AWGs
f1 = iqopen(awg1);
if (isempty(f1))
    return;
end
f2 = iqopen(awg2);
if (isempty(f2))
    return;
end
% set the amplitude & offset values
awg1.ampType = 'DC';
awg2.ampType = 'DC';
amp = dParam.maxAmp;
awg1.amplitude = [amp amp];
awg2.amplitude = [amp amp];
offs = dParam.maxOffs;
awg1.offset = [offs offs];
awg2.offset = [offs offs];
% if level calibration has been performed, use cal values
if (exist('cal_amp', 'var') && ~isempty(cal_amp) && ~doDeskew)
    awg1.amplitude = [cal_amp(1) cal_amp(3)];
    awg2.amplitude = [cal_amp(2) amp];
    awg1.offset = [cal_offs(1) cal_offs(3)];
    awg2.offset = [cal_offs(2) offs];
end;
if (~isempty(syncCfg))
    fsync = iqopen(syncCfg);
    if (isempty(fsync))
        return;
    end
    xfprintf(fsync, ':abor');
    xfprintf(fsync, ':inst:mmod:conf 1');
    configMode = query(fsync, ':INSTrument:MMODule:CONF?');
    if (str2double(configMode) ~= 0)
        xfprintf(fsync, ':inst:slave:del:all');
        xfprintf(fsync, sprintf(':inst:mast ""'));
    end
else
    % stop both of them
    fprintf(f1, ':abort');
    fprintf(f2, ':abort');
    % turn channel coupling on (in case it is not already on)
    fprintf(f1, ':inst:coup:stat1 on');
    fprintf(f2, ':inst:coup:stat1 on');
    % set 100 MHz RefClk for the slave, source as specified
    fprintf(f2, sprintf(':ROSCillator:FREQuency %g', 100e6));
    fprintf(f2, sprintf(':ROSCillator:SOURce %s', refSource));
end

% switch AWG2 to internal clock temporarily to avoid clock loss
% but only if we actually perform deskew - not for simple start/stop
if (doDeskew && isempty(syncCfg))
    switch (awg2.model)
        case 'M8190A_12bit'
            dwid = 'WSPeed';
        case 'M8190A_14bit'
            dwid = 'WPRecision';
        case { 'M8190A_DUC_x3' 'M8190A_DUC_x12' 'M8190A_DUC_x24' 'M8190A_DUC_x48' }
            interpolationFactor = eval(awg2.model(13:end));
            dwid = sprintf('INTX%d', interpolationFactor);
        otherwise
            dwid = [];
            % older instrument - do not send any command
    end
    cmds = sprintf(':FREQuency:RASTer:SOURce INTernal; :FREQuency:RASTer %.15g', fs);
    if (~isempty(dwid))
        cmds = sprintf('%s; :TRACe1:DWIDth %s; :TRACe2:DWIDth %s', cmds, dwid, dwid);
    end
    xfprintf(f2, cmds);
end

%% set up AWG #1 -------------------------------------------------------
% delete all waveform segments
iqseq('delete', [], 'arbConfig', awg1, 'keepOpen', 1);
% create a "dummy" segment, that compensates the trigger delay.
% Fine delay can be adjusted using the Soft Front Panel
% (Ultimately, the deskew process should be automated)
% Trigger delay will be approx. 160 sequence clock cycles plus 
% some fixed delay due to the trigger cable
% One sequence clock cycle is 48 resp. 64 sample clocks.
% We also have have to take care of the linear playtime restriction
% of >256 sequence clock cycles.
fixDelay = 18e-9;
n1 = 257 * awg1.segmentGranularity;
n2 = n1 + (160 + round(fixDelay * fs / awg1.segmentGranularity)) * awg1.segmentGranularity;
dummySegment = zeros(1, n2);
nextSeg1 = [];
nextSeg2 = [];
% now create the real waveform segment, resp. the "test" segment which
% can be used to measure the skew
wfms = calcWfm(fs, awg1, dParam, cmd);
% download the waveforms into AWG1, but don't start the AWG yet (run=0)
% also, keep the connection open to speed up the download process
for i=1:size(wfms,1)
    iqdownload(wfms{i,1}, fs, 'arbConfig', awg1, 'keepOpen', 1, 'run', 0, 'segmentNumber', i+1);
end
iqdownload(dummySegment, fs, 'arbConfig', awg1, 'keepOpen', 1, 'run', 0, 'segmentNumber', dummySegNum);

%% set up ARB #2 -------------------------------------------------------
% delete all segments
iqseq('delete', [], 'arbConfig', awg2, 'keepOpen', 1, 'run', 0);
% shorter dummy segment in the second AWG because by the time it receives
% the trigger, the first AWG was already running for some time
dummySegment = zeros(1, n1);
for i=1:size(wfms,1)
    iqdownload(wfms{i,2}, fs, 'arbConfig', awg2, 'keepOpen', 1, 'run', 0, 'segmentNumber', i+1);
end
iqdownload(dummySegment, fs, 'arbConfig', awg2, 'keepOpen', 1, 'run', 0, 'segmentNumber', dummySegNum);

%% now set up the sequence table (the same table will be used for both
% modules).  Data is entered into a struct and then passed to iqseq()
clear seq;
% dummy segment once
i = 1;
% Without SYNC module, play a dummy segment once to compensate delay
if (isempty(syncCfg))
    seq(i).segmentNumber = dummySegNum;
    seq(i).segmentLoops = 1;
    seq(i).sequenceInit = 1;
    seq(i).sequenceEnd = 1;
    seq(i).markerEnable = 1;    % marker to start the slave module
    i = i + 1;
end
% the test segment(s)
for k=1:size(wfms,1)
    seq(i).segmentNumber = k+1;
    seq(i).segmentLoops = 1;
    if (k == 1)
        seq(i).sequenceInit = 1;
        seq(i).markerEnable = 1;
        seq(i).sequenceAdvance = 'Conditional';
    end
    if (k == size(wfms,1))
        seq(i).sequenceEnd = 1;
    end
    i = i + 1;
end
% the dummy segment
seq(i).segmentNumber = dummySegNum;
seq(i).segmentLoops = 1;
seq(i).segmentAdvance = 'Auto';
seq(i).sequenceInit = 1;
seq(i).sequenceEnd = 1;
seq(i).scenarioEnd = 1;
iqseq('define', seq, 'arbConfig', awg1, 'keepOpen', 1, 'run', 0);
iqseq('define', seq, 'arbConfig', awg2, 'keepOpen', 1, 'run', 0);

% set AWG #1 to triggered or continuous - depending on sync module
iqseq('triggerMode',  ~isempty(syncCfg), 'arbConfig', awg1, 'keepopen', 1);
% turn on triggered mode in AWG #2 in any case
iqseq('triggerMode', 'triggered', 'arbConfig', awg2, 'keepopen', 1);
% set SYNC Marker level of AWG #1 and trigger threshold of AWG #2
lev = 250e-3;
xfprintf(f1, sprintf(':mark1:sync:volt:ampl %g; offs %g', 500e-3, lev));
if (isempty(syncCfg))
    xfprintf(f2, sprintf(':arm:trigger:level %g; imp low; slope pos', lev));
end
% and run (i.e. wait for trigger)
iqseq('mode', 'STSC', 'arbConfig', awg2, 'keepopen', 1);
% wait until AWG #2 has started (make sure it is ready to respond to the trigger)
query(f2, '*opc?');
% now start AWG #1 which will generate a SYNC marker and trigger AWG #2
iqseq('mode', 'STSC', 'arbConfig', awg1, 'keepopen', 1);

if (~doDeskew && length(g_skew) == 4 && length(fixedSkew) == 4)
    setAWGDelay(f1, f2, g_skew + fixedSkew, g_skew + fixedSkew);
end
fclose(f1);
fclose(f2);
result = [];


function wfms = calcWfm(fs, awg1, dParam, cmd)
% Calculate the waveforms that will be downloaded to the AWGs
% The returned wfms are two-dimensional cell arrays that contain vectors
% of complex values. 1st dimension is the waveform number (for building a
% sequence), the second dimension points to the AWG number (1 and 2).
% The real and imaginary part correspond to channel 1 and 2 of each AWG.
% (This just happens to be the format the iqdownload expects)
clear wfms;
% For deskew, simply generate a single "step function".
% Otherwise, calculate the waveforms based on dParam.lpPattern and
% dParam.hsPattern
if (strcmp(cmd, 'init'))
    t1 = iqpulsegen('arbConfig', awg1, 'sampleRate', fs, 'pw', 9600, 'rise', 0, 'fall', 0, 'off', 9600, 'high', 1, 'low', -1);
    wfms{1,1} = complex(real(t1), real(t1));
    wfms{1,2} = complex(real(t1), real(t1));
else
    % don't show any warnings about short waveforms in display only mode
    nowarning = (strcmp(cmd, 'display'));
    [p1 p2 p3 p4] = trPat(dParam);
    idx = 1;
    if (~isempty(p1))
        t1 = iserial('sampleRate', fs, 'data', p1, 'transitiontime', dParam.hsTT, 'dataRate', dParam.hsDataRate, 'isi', dParam.hsIsi, 'SJpp', dParam.hsJitter, 'SJFreq', dParam.hsJitterFreq, 'nowarning', nowarning);
        t2 = iserial('sampleRate', fs, 'data', p2, 'transitiontime', dParam.hsTT, 'dataRate', dParam.hsDataRate, 'isi', dParam.hsIsi, 'SJpp', dParam.hsJitter, 'SJFreq', dParam.hsJitterFreq, 'nowarning', nowarning);
        t3 = iserial('sampleRate', fs, 'data', p3, 'transitiontime', dParam.hsTT, 'dataRate', dParam.hsDataRate, 'isi', dParam.hsIsi, 'SJpp', dParam.hsJitter, 'SJFreq', dParam.hsJitterFreq, 'nowarning', nowarning);
        t4 = iserial('sampleRate', fs, 'data', p4, 'transitiontime', 0, 'dataRate', dParam.hsDataRate, 'nowarning', nowarning);
        wfms{idx,1} = complex(t1, t2);
        wfms{idx,2} = complex(t3, t4);
        idx = idx + 1;
    end
    if (~isempty(dParam.lpPattern))
        t1 = iserial('sampleRate', fs, 'data', bitand(dParam.lpPattern, 1)/1, 'transitiontime', dParam.lpTT, 'dataRate', dParam.lpDataRate, 'SJpp', dParam.lpJitter, 'SJFreq', dParam.lpJitterFreq);
        t2 = iserial('sampleRate', fs, 'data', bitand(dParam.lpPattern, 2)/2, 'transitiontime', dParam.lpTT, 'dataRate', dParam.lpDataRate, 'SJpp', dParam.lpJitter, 'SJFreq', dParam.lpJitterFreq);
        t3 = iserial('sampleRate', fs, 'data', bitand(dParam.lpPattern, 4)/4, 'transitiontime', dParam.lpTT, 'dataRate', dParam.lpDataRate, 'SJpp', dParam.lpJitter, 'SJFreq', dParam.lpJitterFreq);
        t4 = iserial('sampleRate', fs, 'data', repmat([0 0], 1, length(dParam.lpPattern)/2), 'transitiontime', 0, 'dataRate', dParam.lpDataRate);
        wfms{idx,1} = complex(t1, t2);
        wfms{idx,2} = complex(t3, t4);
    end
end


function [p1 p2 p3 p4] = trPat(dParam)
% calculate 4 waveforms based on dParam.hsPattern
pat = dParam.hsPattern;
len = numel(pat);
levA = [0 2 0 1 1 0 2; ...  % A
        0 0 2 2 0 1 1; ...  % B
        0 1 1 0 2 2 0] / 2; % C
% defines the next symbol based on input and current symbol
% where: +x=1, -x=2, +y=3, -y=4, +z=5, -z=6
nextSym = [5 6 1 2 3 4; ... % input 000
           6 5 2 1 4 3; ... % input 001
           3 4 5 6 1 2; ... % input 010
           4 3 6 5 2 1; ... % input 011
           2 1 4 3 6 5; ... % input 100
           1 2 3 4 5 6];    % input 101 --> stay the same (not a valid)
currSym = 1;
for i=1:length(pat)
    x = pat(i);
    if (x >= 0 && x <= 5)
        currSym = nextSym(x+1, currSym);
        pat(i) = -currSym;
    elseif (x <= -1 && x >= -6)
        currSym = -pat(i);
    else
        pat(i) = 0;
    end
end
relL = (dParam.hsLow - dParam.min) / dParam.maxAmp;
relH = (dParam.hsHigh - dParam.min) / dParam.maxAmp;
p1 = levA(1,-pat+1) * (relH - relL) + relL;
p2 = levA(2,-pat+1) * (relH - relL) + relL;
p3 = levA(3,-pat+1) * (relH - relL) + relL;
% if no LP pattern, make clock repetitive
if (isempty(dParam.lpPattern))
    p4 = [repmat([1;0], floor(len/2), 1); zeros(mod(len,2),1)];
else
    p4 = [0; 0; repmat([1;0], floor(len/2)-2, 1); 0; 0; zeros(mod(len,2),1)];
end


function result = autoDeskew(arbConfig, fs, slaveClk, fixedSkew, dParam)
% perform deskew and level calibration of the 4 AWG channels
global cal_amp;
global cal_offs;
global g_skew;
result = [];
[awg1, awg2, ~, scopeCfg] = makeCfg(arbConfig);
% connect to AWGs
f1 = iqopen(awg1);
f2 = iqopen(awg2);
% connect to scope
fscope = iqopen(scopeCfg);
if (isempty(fscope))
    result = 'can''t connect to scope';
    return;
end

% define on which channels the scope should compare signals
ch = [1 2];
% scope timebase scales for the three successive measurements
timebase = [10e-9 50e-12 50e-12];
% delay (in sec) to allow scope to take sufficient number of measurements
measDelay = [0.2 1 1];
if (isempty(initScopeMeasurement(fscope, ch, dParam)))
    return;
end
% initialize AWG delay
setAWGDelay(f1, f2, [0 0 0 0], fixedSkew);
% perform first measurement to determine coarse delay
cdel = doScopeMeasurement(fscope, ch, timebase(1), measDelay(1));
%fprintf('---\nskew1 = %g\n', cdel * 1e12);
% if measurement is invalid, give up
if (isempty(cdel))
    return;
end
%fprintf(sprintf('cdel = %g\n', round(cdel*1e12)));
cdel = cdel + fixedSkew(ch(1)) - fixedSkew(ch(2));
if (abs(cdel) > 10e-9)
    errordlg({sprintf('Skew is too large for the built-in delay line (%g ns).', cdel * 1e9) ...
            'Please make sure that you have connected the AWG outputs' ...
            'to the scope according to the connection diagram.'});
    return;
end
% set the coarse delay in the AWG
setAWGDelay(f1, f2, [0 0 0 0], [cdel 0 cdel 0] + fixedSkew);

for mloop = 1:2
    % now measure again with higher resolution
    fdel = doScopeMeasurement(fscope, ch, timebase(2), measDelay(2));
    fdel = fdel + fixedSkew(ch(1)) - fixedSkew(ch(2));
    %fprintf('skew%d = %g\n', mloop + 1, fdel * 1e12);
    if (isempty(fdel))
        return;
    end
    %fprintf(sprintf('fdel = %g\n', round(fdel*1e12)));
    if (abs(cdel + fdel) > 10e-9)
        errordlg(sprintf('Delay after first correction too large: %g ns', (cdel + fdel) * 1e9));
        return;
    end
    pdel = cdel;
    cdel = pdel + fdel;
    setAWGDelay(f1, f2, [pdel 0 pdel 0] + fixedSkew, [cdel 0 cdel 0] + fixedSkew);
end

% measure again (sanity check)
% result = doScopeMeasurement(fscope, ch, timebase(3), measDelay(3));
%fprintf('skewFinal = %g\n', result * 1e12);
% xfprintf(fscope, sprintf(':acquire:average off'));

% try to adjust the second channel of each AWG as well - if it is connected
% if measurement is invalid, simply return
del13 = doScopeMeasurement(fscope, [1 3], timebase(2), measDelay(2), 0);
if (isempty(del13))
    errordlg({'Can''t measure skew of M8190A#1, channel 2.' ...
            'Please make sure that you have connected the AWG outputs' ...
            'to the scope according to the connection diagram.'});
    return;
end
%fprintf(sprintf('del13 = %g\n', round(del13*1e12)));
del13 = del13 + fixedSkew(1) - fixedSkew(3);
del24 = doScopeMeasurement(fscope, [2 4], timebase(2), measDelay(2), 0);
if (isempty(del24))
    errordlg({'Can''t measure skew of M8190A#2, channel 2.' ...
            'Please make sure that you have connected the AWG outputs' ...
            'to the scope according to the connection diagram.'});
    return;
end
%fprintf(sprintf('del24 = %g\n', round(del24*1e12)));
del24 = del24 + fixedSkew(2) - fixedSkew(4);
setAWGDelay(f1, f2, [cdel 0 cdel 0] + fixedSkew, [cdel 0 cdel-del13 -del24] + fixedSkew);
g_skew = [cdel 0 cdel-del13 -del24];
% if we managed to get to here, all 4 scope channels have a valid signal,
% so lets turn them all on
for i = 1:3
    xfprintf(fscope, sprintf(':chan%d:disp on', i));
end
% except channel 4 - not used right now
xfprintf(fscope, sprintf(':chan%d:disp off', 4));
% calibrate voltages, too
timebase = 10e-9;
xfprintf(fscope, sprintf(':timebase:scal %g', timebase));
xfprintf(fscope, sprintf(':meas:clear'));
clear meas_high;
clear meas_low;
for i = 1:3
    meas_high(i) = str2double(query(fscope, sprintf(':meas:vtop? chan%d', i)));
    meas_low(i) = str2double(query(fscope, sprintf(':meas:vbase? chan%d', i)));
end
want_high = dParam.max;
want_low = dParam.min;
cal_high = 2*want_high - meas_high;
cal_low = 2*want_low - meas_low;
cal_amp = cal_high - cal_low;
cal_offs = (cal_high + cal_low)/2;
% apply new amplitude settings
setupTestPattern(arbConfig, fs, 0, slaveClk, 'init', fixedSkew, dParam);
% now show how nicely they are aligned
xfprintf(fscope, sprintf(':meas:clear'));
%xfprintf(fscope, sprintf(':meas:deltatime chan%d,chan%d', 1, 4));
xfprintf(fscope, sprintf(':meas:deltatime chan%d,chan%d', 1, 3));
xfprintf(fscope, sprintf(':meas:deltatime chan%d,chan%d', 1, 2));
xfprintf(fscope, sprintf(':meas:stat on'));


function cSkewChange = setAWGDelay(f1, f2, prevSkew, skew)
% set the skew for all four AWG channels to <skew>.
% <skew> must be a vector with 4 elements representing channels 1 2 3 & 4
% values can be negative (!)
% <prevSkew> is the "previous skew". This is used to keep the coarse delay
% unchanged if possible (<prevSkew> must also be a vector of four elements)
% returns 1 if any of the coarse skews were changed

%fprintf('skew in:  ');
%fprintf(sprintf('%g ', round(skew*1e12)));
%fprintf('\n');
% make them all zero-based
cSkewChange = 0;
skew = skew - min(skew);
prevSkew = prevSkew - min(prevSkew);
cskew = zeros(1,4);
fskew = zeros(1,4);
fvec = [f1 f2 f1 f2];
chvec = [1 1 2 2];
for i = 1:4
    if (skew(i) < 15e-12)
        cskew(i) = 0;
        fskew(i) = skew(i);
    else
        cskew(i) = floor((skew(i) - 15e-12) * 1e11) / 1e11;
        fskew(i) = skew(i) - cskew(i);
        if (prevSkew(i) ~= 0)
            cpskew = floor((prevSkew(i) - 15e-12) * 1e11) / 1e11;
            nfskew = skew(i) - cpskew;
            if (nfskew <= 30e-12 && nfskew >= 0)
                cskew(i) = cpskew;
                fskew(i) = nfskew;
            else
                cSkewChange = 1;
            end
        end
    end
    xfprintf(fvec(i), sprintf(':arm:cdel%d %g', chvec(i), cskew(i)));
    xfprintf(fvec(i), sprintf(':arm:del%d %g', chvec(i), fskew(i)));
end
%fprintf('skew set: ');
%fprintf(sprintf('%g ', round((cskew+fskew)*1e12)));
%fprintf('coarse: ');
%fprintf(sprintf('%g ', round(cskew*1e12)));
%fprintf('fine: ');
%fprintf(sprintf('%g ', round(fskew*1e12)));
%fprintf('\n');


function result = initScopeMeasurement(fscope, ch, dParam)
result = [];
xfprintf(fscope, '*rst');
xfprintf(fscope, ':syst:head off');
for i = 1:4
    xfprintf(fscope, sprintf(':chan%d:disp on', i));
end
timebase = 10e-9;
xfprintf(fscope, sprintf(':timebase:scal %g', timebase));
offs = dParam.maxOffs;
scale = dParam.maxAmp / 6;
for i = 1:4
    xfprintf(fscope, sprintf(':chan%d:scale %g; offs %g', i, scale, offs));
end
trigLev = offs;
xfprintf(fscope, sprintf(':trig:mode edge'));
xfprintf(fscope, sprintf(':trig:edge:slope positive'));
xfprintf(fscope, sprintf(':trig:edge:source chan1'));
xfprintf(fscope, sprintf(':trig:lev chan1,%g', trigLev));
xfprintf(fscope, ':run');
res = query(fscope, 'ader?');
if (eval(res) ~= 1)
    % try one more time
    res = query(fscope, 'ader?');
    if (eval(res) ~= 1)
        res = questdlg('Please verify that the scope captures the waveform correctly and press OK','Scope','OK','Cancel','OK');
        if (~strcmp(res, 'OK'))
            fclose(fscope);
            return;
        end
    end
end
xfprintf(fscope, ':meas:deltatime:def rising,1,middle,rising,1,middle');
for i = 1:4
    xfprintf(fscope, sprintf(':meas:thresholds:absolute chan%d,%g,%g,%g', i, offs+dParam.maxAmp/4, offs, offs-dParam.maxAmp/4));
    xfprintf(fscope, sprintf(':meas:thresholds:method chan%d,absolute', i));
end
%xfprintf(fscope, sprintf(':acquire:average:count 8'));
%xfprintf(fscope, sprintf(':acquire:average on'));
result = 1;



function result = doScopeMeasurement(fscope, ch, timebase, measDelay, showError)
result = [];
if (~exist('showError', 'var'))
    showError = 1;
end
for i = 1:4
    xfprintf(fscope, sprintf(':chan%d:disp on', i));
end
xfprintf(fscope, sprintf(':timebase:scal %g', timebase));
doMeasAgain = 1;
while (doMeasAgain)
    xfprintf(fscope, sprintf(':meas:clear'));
    xfprintf(fscope, sprintf(':meas:deltatime chan%d,chan%d', ch(1), ch(2)));
    xfprintf(fscope, sprintf(':meas:stat on'));
    pause(measDelay);
    query(fscope, 'ader?');
    measStr = query(fscope, ':meas:results?');
    measList = eval(['[' measStr(11:end-1) ']']);
%    fprintf(sprintf('Result: %s\n', measStr));
    meas = measList(4);   % mean
    if (abs(meas) > 1e37)
        if (showError)
            errordlg({'Invalid scope measurement: ' sprintf('%g', meas) ' ' ...
                'Please make sure that you have connected the AWG outputs' ...
                'to the scope according to the connection diagram.'});
        end
        return;
    end
    if (abs(measList(3) - measList(2)) > 100e-12)   % max - min
        res = questdlg({'The scope returns delta time measurements with large variations.' ...
                       'Please verify that the slave clock source is set correctly and the' ...
                       'scope shows a steady waveform. Then press OK' },'Scope','OK','Cancel','OK');
        if (~strcmp(res, 'OK'))
            fclose(fscope);
            return;
        end
    else
        doMeasAgain = 0;
    end
    result = meas;
end


function [awg1, awg2, syncCfg, scopeCfg] = makeCfg(arbConfig)
% create separate config structures for AWG#1, AWG#2, SYNC module and scope
if (~strcmp(arbConfig.connectionType, 'visa'))
    errormsg('Only VISA connection type is supported by this utility');
end
awg1 = arbConfig;
awg2 = arbConfig;
awg2.visaAddr = arbConfig.visaAddr2;
scopeCfg = [];
if (isfield(arbConfig, 'visaAddrScope'))
    scopeCfg.model = 'scope';
    scopeCfg.connectionType = 'visa';
    scopeCfg.visaAddr = arbConfig.visaAddrScope;
end
syncCfg = [];
if (isfield(arbConfig, 'useM8192A') && arbConfig.useM8192A ~= 0)
    syncCfg.model = 'M8192A';
    syncCfg.connectionType = 'visa';
    syncCfg.visaAddr = arbConfig.visaAddrM8192A;
end




function retVal = xfprintf(f, s, ignoreError)
% Send the string s to the instrument object f
% and check the error status
% if ignoreError is set, the result of :syst:err is ignored
% returns 0 for success, -1 for errors
    retVal = 0;
    if (evalin('base', 'exist(''debugScpi'', ''var'')'))
        fprintf('cmd = %s\n', s);
    end
    fprintf(f, s);
    result = query(f, ':syst:err?');
    if (isempty(result))
        fclose(f);
        errordlg({'The instrument did not respond to a :SYST:ERRor query.' ...
            'Please check that the firmware is running and responding to commands.'}, 'Error');
        retVal = -1;
        return;
    end
    if (~exist('ignoreError', 'var') || ignoreError == 0)
        if (~strncmp(result, '0,No error', 10) && ~strncmp(result, '0,"No error"', 12) && ~strncmp(result, '0', 1))
            errordlg({'Instrument returns an error on command:' s 'Error Message:' result});
            retVal = -1;
        end
    end

