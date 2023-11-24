function result = multi_channel_sync(varargin)
% Set up two M8190A modules to run in sync. This function is typically
% called from the multi_channel_sync_gui, but it can also be called from
% other MATLAB functions.
% Parameters are passed as name/value pairs. The following parameter names
% are supported:
% 'sampleRate' - the samplerate that will be used by both M8190A modules
% 'cmd' - can be 'manualDeskew', 'autoDeskew', 'start', 'stop'
% 'arbConfig' - arbConfig struct - optional (see loadArbConfig)
% 'useMarkers' - set to 1 if the channel 1 sample markers are used for
%               deskewing instead of the ch1 outputs of each module
% 'slaveClk' - 'extClk' (external sample clock), 'axiRef' (AXI reference clock)
%              or 'extRef' (external reference clock)
% 'triggered' - if set to 1, will generate a single waveform on every
%              trigger event, otherwise will generate continuous signal
% 'waveformID' - see popupmenuWaveform in multi_channel_sync_gui
% 'fixedSkew' - manually entered skew for each channel (vector of 4 values)
%              if empty or all zeros, instrument skew will not be affected
%
% Agilent Technologies, Thomas Dippon, 2011-2013
%
% Disclaimer of Warranties: THIS SOFTWARE HAS NOT COMPLETED AGILENT'S FULL
% QUALITY ASSURANCE PROGRAM AND MAY HAVE ERRORS OR DEFECTS. AGILENT MAKES 
% NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND WITH RESPECT TO THE SOFTWARE,
% AND SPECIFICALLY DISCLAIMS THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
% FITNESS FOR A PARTICULAR PURPOSE.
% THIS SOFTWARE MAY ONLY BE USED IN CONJUNCTION WITH AGILENT INSTRUMENTS. 

result = [];
if (nargin == 0)
    multi_channel_sync_gui;
    return;
end
% set default values - will be overwritten by arguments
cmd = '';
sampleRate = 8e9;
arbConfig = loadArbConfig();
useMarkers = 0;
triggered = 0;
waveformID = 1;
slaveClk = 'axiRef';
fixedSkew = [0 0 0 0];
i = 1;
while (i <= nargin)
    if (ischar(varargin{i}))
        switch lower(varargin{i})
            case 'samplerate';     sampleRate = varargin{i+1};
            case 'cmd';            cmd = varargin{i+1};
            case 'arbconfig';      arbConfig = varargin{i+1};
            case 'usemarkers';     useMarkers = varargin{i+1};
            case 'slaveclk';       slaveClk = varargin{i+1};
            case 'triggered';      triggered = varargin{i+1};
            case 'waveformid';     waveformID = varargin{i+1};
            case 'fixedskew';      fixedSkew = varargin{i+1};
            otherwise; error(['unexpected argument: ' varargin{i}]);
        end
    else
        error('string argument expected');
    end
    i = i+2;
end


% common sample rate for both AWGs
fs = sampleRate;

switch (cmd)
    case 'manualDeskew'
        result = setupTestPattern(arbConfig, fs, 1, slaveClk, useMarkers, fixedSkew, 0, 2);
    case 'autoDeskew'
        result = setupTestPattern(arbConfig, fs, 1, slaveClk, useMarkers, fixedSkew, 0, 2);
        if (isempty(result))
            autoDeskew(arbConfig, fixedSkew);
        end
    case 'start'
        result = setupTestPattern(arbConfig, fs, 0, slaveClk, useMarkers, fixedSkew, triggered, waveformID);
        if (isfield(arbConfig, 'visaAddrScope'))
            setupScope(arbConfig, waveformID, triggered);
        end
    case 'stop'
        result = doStop(arbConfig);
    case 'trigger'
        result = doTrigger(arbConfig);
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



function result = doTrigger(arbConfig)
[awg1 , ~, syncCfg, ~] = makeCfg(arbConfig);
if (~isempty(syncCfg))
    fsync = iqopen(syncCfg);
    if (isempty(fsync))
        return;
    end
    xfprintf(fsync, ':trig:beg');
    fclose(fsync);
else
    % open the connection to AWG1
    f1 = iqopen(awg1);
    xfprintf(f1, ':trig:beg');
    fclose(f1);
end
result = [];



function setupScope(arbConfig, waveformID, triggered)
% connect to scope
[~, ~, ~, scopeCfg] = makeCfg(arbConfig);
fscope = iqopen(scopeCfg);
if (isempty(fscope))
    return;
end
% remove all measurements to avoid a cluttered screen
xfprintf(fscope, ':meas:clear');
switch (waveformID)
    case 2  % test pattern
        setupScope2(fscope);
        xfprintf(fscope, sprintf(':timebase:scal %g', 50e-9));
        xfprintf(fscope, sprintf(':trig:edge:source chan1'));
    case 3   % pulse & sine wave
        setupScope2(fscope);
        if (triggered)
            xfprintf(fscope, sprintf(':timebase:scal %g', 5e-6));
        else
            xfprintf(fscope, sprintf(':timebase:scal %g', 50e-9));
        end
        xfprintf(fscope, sprintf(':trig:edge:source chan1'));
    case {4 5}   % pulse with different phase / delay
        setupScope2(fscope);
        xfprintf(fscope, sprintf(':timebase:scal %g', 10e-9));
        xfprintf(fscope, sprintf(':trig:edge:source aux'));
        xfprintf(fscope, sprintf(':trig:lev aux,%g', 100e-3));
    case 6   % CW with different phase
        setupScope2(fscope);
        xfprintf(fscope, sprintf(':timebase:scal %g', 10e-9));
        xfprintf(fscope, sprintf(':trig:edge:source chan1'));
    case 7   % LFSR 
        setupScope2(fscope);
        xfprintf(fscope, sprintf(':timebase:scal %g', 100e-12));
        xfprintf(fscope, sprintf(':trig:edge:source chan1'));
    case 8   % three level signals
        setupScope2(fscope);
        xfprintf(fscope, sprintf(':timebase:scal %g', 500e-12));
        xfprintf(fscope, sprintf(':trig:lev aux,%g', 100e-3));
        xfprintf(fscope, sprintf(':trig:edge:source aux'));
end
fclose(fscope);


function setupScope2(fscope)
offs = 0;
scale = 200e-3;
for i = [1 2 3 4]
    xfprintf(fscope, sprintf(':chan%d:disp on', i));
    xfprintf(fscope, sprintf(':chan%d:offs %g', i, offs));
    xfprintf(fscope, sprintf(':chan%d:scale %g', i, scale));
end


function result = setupTestPattern(arbConfig, fs, doDeskew, slaveClk, useMarkers, fixedSkew, triggered, waveformID)
result = [];
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
dummySegNum = 2;
testSegNum = 1;
% open the connection to the AWGs
f1 = iqopen(awg1);
if (isempty(f1))
    return;
end
f2 = iqopen(awg2);
if (isempty(f2))
    return;
end
if (~isempty(syncCfg))
    fsync = iqopen(syncCfg);
    if (isempty(fsync))
        return;
    end
    xfprintf(fsync, ':abor');
    % always go to configuration mode and remote all modules
    % so that we can set the sample rate and mode
    xfprintf(fsync, ':inst:mmod:conf 1');
    xfprintf(fsync, ':inst:slave:del:all');
    xfprintf(fsync, sprintf(':inst:mast ""'));
else
    % stop both of them
    xfprintf(f1, ':abort');
    xfprintf(f2, ':abort');
    % turn channel coupling on (in case it is not already on)
    xfprintf(f1, ':inst:coup:stat1 on');
    xfprintf(f2, ':inst:coup:stat1 on');
    % set 100 MHz RefClk for the slave, source as specified
    xfprintf(f2, sprintf(':ROSCillator:FREQuency %g', 100e6));
    xfprintf(f2, sprintf(':ROSCillator:SOURce %s', refSource));
end
% set marker levels if we are using markers
if (useMarkers && doDeskew)
    xfprintf(f1, sprintf(':MARKer1:SAMPle:VOLTage:OFFSet %g; AMPLitude %g', 0, 0.5));
    xfprintf(f2, sprintf(':MARKer1:SAMPle:VOLTage:OFFSet %g; AMPLitude %g', 0, 0.5));
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
    cmd = sprintf(':FREQuency:RASTer:SOURce INTernal; :FREQuency:RASTer %.15g', fs);
    if (~isempty(dwid))
        cmd = sprintf('%s; :TRACe1:DWIDth %s; :TRACe2:DWIDth %s', cmd, dwid, dwid);
    end
    xfprintf(f2, cmd);
end

%% set up AWG #1 -------------------------------------------------------
% delete all waveform segments
if (waveformID ~= 1)
    iqseq('delete', [], 'arbConfig', awg1, 'keepOpen', 1);
end
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
% now create the real waveform segment, resp. the "test" segment which
% can be used to measure the skew
switch (waveformID)
    case 1  % use exising segment #1
        testSegment1 = [];
        testSegment2 = [];
    case 2  % test segment
        t1 = iqpulsegen('arbConfig', awg1, 'sampleRate', fs, 'pw', 9600, 'rise', 0, 'fall', 0, 'off', 9600, 'high', 1, 'low', -1);
        testSegment1 = complex(real(t1), real(t1));
        testSegment2 = testSegment1;
    case 3  % pulse followed by sinewave
        n = 192;
        clear t;
        for i=1:4
            t(i,:) = [-1*ones(1,n) ones(1,n) zeros(1,i*n) sin(2*pi*(1:n)/n) zeros(1,(6-i)*n)];
        end
        testSegment1 = complex(t(1,:), t(2,:));
        testSegment2 = complex(t(3,:), t(4,:));
    case 4  % sine waves with different phases
        clear t;
        for i=1:4
            t(i,:) = iqpulse('sampleRate', fs, 'pri', 4e-6, 'pw', 2e-6, 'phase', 45*i, 'offset', 200e6, 'span', 300e6);
        end
        testSegment1 = complex(real(t(1,:)), real(t(2,:)));
        testSegment2 = complex(real(t(3,:)), real(t(4,:)));
    case 5  % sine waves with different delays
        clear t;
        for i=1:4
            t(i,:) = iqpulse('sampleRate', fs, 'pri', 4e-6, 'pw', 2e-6, 'delay', i/200e6, 'offset', 200e6, 'span', 300e6);
        end
        testSegment1 = complex(real(t(1,:)), real(t(2,:)));
        testSegment2 = complex(real(t(3,:)), real(t(4,:)));
    case 6  % CW signal with different phases
        clear t;
        for i=1:4
            t(i,:) = iqtone('sampleRate', fs, 'tone', 50e6, 'phase', 45*pi/180*i);
        end
        testSegment1 = complex(real(t(1,:)), real(t(2,:)));
        testSegment2 = complex(real(t(3,:)), real(t(4,:)));
    case 7   % 4 LFSR signals
        t1 = iserial('sampleRate', fs, 'data', polytest([8 7 2 1], [1 0 1 1 1 0 0 1], 192*255, 0), 'dataRate', fs);
        t2 = iserial('sampleRate', fs, 'data', polytest([8 6 5 1], [1 0 1 1 0 0 0 1], 192*255, 0), 'dataRate', fs);
        t3 = iserial('sampleRate', fs, 'data', polytest([8 4 3 2], [1 0 1 1 0 0 0 1], 192*255, 0), 'dataRate', fs);
        t4 = iserial('sampleRate', fs, 'data', polytest([8 6 3 2], [1 1 0 0 0 0 0 1], 192*255, 0), 'dataRate', fs);
        testSegment1 = complex(t1, t2);
        testSegment2 = complex(t3, t4);
    case 8   % 4 three-level signals
        t1 = iserial('sampleRate', fs, 'data', repmat([0 2 1 2 0 1 0 1 2 2 1 0 0 2], 1, 256)/2, 'transitiontime', 0, 'dataRate', fs/4);
        t2 = iserial('sampleRate', fs, 'data', repmat([1 0 0 1 2 2 1 0 0 1 2 2 1 1], 1, 256)/2, 'transitiontime', 0, 'dataRate', fs/4);
        t3 = iserial('sampleRate', fs, 'data', repmat([2 1 2 0 1 0 2 2 1 0 0 1 2 0], 1, 256)/2, 'transitiontime', 0, 'dataRate', fs/4);
        t4 = iserial('sampleRate', fs, 'data', repmat([2 0 2 0 2 0 2 0 2 0 2 0 2 0], 1, 256)/2, 'transitiontime', 0, 'dataRate', fs/4);
        testSegment1 = complex(t1, t2);
        testSegment2 = complex(t3, t4);
    otherwise
        error(['unexpected waveformID: ' num2str(waveformID)]);
end
% download the waveforms into AWG1, but don't start the AWG yet (run=0)
% also, keep the connection open to speed up the download process
if (~isempty(testSegment1))
    iqdownload(testSegment1, fs, 'arbConfig', awg1, 'keepOpen', 1, 'run', 0, 'segmentNumber', testSegNum);
end
iqdownload(dummySegment, fs, 'arbConfig', awg1, 'keepOpen', 1, 'run', 0, 'segmentNumber', dummySegNum);

%% set up ARB #2 -------------------------------------------------------
% delete all segments
if (waveformID ~= 1)
    iqseq('delete', [], 'arbConfig', awg2, 'keepOpen', 1, 'run', 0);
end
% shorter dummy segment in the second AWG because by the time it receives
% the trigger, the first AWG was already running for some time
dummySegment = zeros(1, n1);
if (~isempty(testSegment2))
    iqdownload(testSegment2, fs, 'arbConfig', awg2, 'keepOpen', 1, 'run', 0, 'segmentNumber', testSegNum);
end
iqdownload(dummySegment, fs, 'arbConfig', awg2, 'keepOpen', 1, 'run', 0, 'segmentNumber', dummySegNum);

%% now set up the sequence table (the same table will be used for both
% modules).  Data is entered into a struct and then passed to iqseq()
clear seq;
i = 1;
% Without SYNC module, play a dummy segment once to compensate delay
if (isempty(syncCfg))
    seq(i).segmentNumber = dummySegNum;
    seq(i).segmentLoops = 1;
    seq(i).markerEnable = 1;    % marker to start the slave module
    i = i + 1;
end
% the test segment
seq(i).segmentNumber = testSegNum;
seq(i).segmentLoops = 1;
seq(i).markerEnable = 1;
if (triggered)
    seq(i).segmentAdvance = 'Auto';
else
    seq(i).segmentAdvance = 'Conditional';
end
i = i + 1;
% the dummy segment
seq(i).segmentNumber = dummySegNum;
seq(i).segmentLoops = 1;
seq(i).segmentAdvance = 'Auto';
iqseq('define', seq, 'arbConfig', awg1, 'keepOpen', 1, 'run', 0);
iqseq('define', seq, 'arbConfig', awg2, 'keepOpen', 1, 'run', 0);

% set AWG #1 to triggered or continuous - depending on user selection
iqseq('triggerMode', triggered || ~isempty(syncCfg), 'arbConfig', awg1, 'keepopen', 1);
% turn on triggered mode in AWG #2 in any case
iqseq('triggerMode', 'triggered', 'arbConfig', awg2, 'keepopen', 1);
% and run (i.e. wait for trigger)
iqseq('mode', 'STSC', 'arbConfig', awg2, 'keepopen', 1);
% wait until AWG #2 has started (make sure it is ready to respond to the trigger)
query(f2, '*opc?');
% now start AWG #1 which will generate a SYNC marker and trigger AWG #2
iqseq('mode', 'STSC', 'arbConfig', awg1, 'keepopen', 1);

fclose(f1);
fclose(f2);




function result = autoDeskew(arbConfig, fixedSkew)
result = [];
[awg1, awg2, ~, scopeCfg] = makeCfg(arbConfig);
% connect to AWGs
f1 = iqopen(awg1);
if (isempty(f1))
    return;
end
f2 = iqopen(awg2);
if (isempty(f2))
    return;
end
% connect to scope
fscope = iqopen(scopeCfg);
if (isempty(fscope))
    return;
end

% define on which channels the scope should compare signals
ch = [1 2];
% scope timebase scales for the three successive measurements
timebase = [10e-9 50e-12 50e-12];
% delay (in sec) to allow scope to take sufficient number of measurements
measDelay = [0.2 1 1];
if (isempty(initScopeMeasurement(arbConfig, f1, fscope, ch)))
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
    return;
end
%fprintf(sprintf('del13 = %g\n', round(del13*1e12)));
del13 = del13 + fixedSkew(1) - fixedSkew(3);
del24 = doScopeMeasurement(fscope, [2 4], timebase(2), measDelay(2), 0);
if (isempty(del24))
    return;
end
%fprintf(sprintf('del24 = %g\n', round(del24*1e12)));
del24 = del24 + fixedSkew(2) - fixedSkew(4);
setAWGDelay(f1, f2, [cdel 0 cdel 0] + fixedSkew, [cdel 0 cdel-del13 -del24] + fixedSkew);
% if we managed to get to here, all 4 scope channels have a valid signal,
% so lets turn them all on
for i = 1:4
    xfprintf(fscope, sprintf(':chan%d:disp on', i));
end
xfprintf(fscope, sprintf(':meas:clear'));
xfprintf(fscope, sprintf(':meas:deltatime chan%d,chan%d', 1, 2));
xfprintf(fscope, sprintf(':meas:deltatime chan%d,chan%d', 1, 3));
xfprintf(fscope, sprintf(':meas:deltatime chan%d,chan%d', 1, 4));
xfprintf(fscope, sprintf(':meas:stat on'));
fclose(f1);
fclose(f2);
fclose(fscope);


function cSkewChange = setAWGDelay(f1, f2, prevSkew, skew)
% set the skew for all four AWG channels to <skew>.
% <skew> must be a vector with 4 elements representing channels 1 2 3 & 4
% values can be negative (!)
% <prevSkew> is the "previous skew". This is used to keep the coarse delay
% unchanged if possible (<prevSkew> must also be a vector of four elements)
% returns 1 if any of the coarse skews were changed

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


function result = initScopeMeasurement(arbConfig, f1, fscope, ch)
result = [];
xfprintf(fscope, '*rst');
xfprintf(fscope, ':syst:head off');
for i = 1:4
    xfprintf(fscope, sprintf(':chan%d:disp on', i));
end
trigLev = str2double(query(f1, ':volt:offs?'));
ampl = str2double(query(f1, ':volt:ampl?'));

timebase = 10e-9;
xfprintf(fscope, sprintf(':timebase:scal %g', timebase));
scale = ampl / 6;
for i = 1:4
    xfprintf(fscope, sprintf(':chan%d:offs %g', i, trigLev));
    xfprintf(fscope, sprintf(':chan%d:scale %g', i, scale));
end
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
    xfprintf(fscope, sprintf(':meas:thresholds:absolute chan%d,%g,%g,%g', i, trigLev+ampl/4, trigLev, trigLev-ampl/4));
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
    meas = measList(4);   % mean
    if (abs(meas) > 1e37)
        if (showError)
            errordlg({'Signal edges were not found on the scope.' ...
                'Please make sure that you have connected the AWG outputs' ...
                'to the scope according to the connection diagram.' ...
                '(Measurement result returned was: ' sprintf('%g', meas) ')'});
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


function result = polytest(poly, data, len, doPrint, pat)
if (~exist('poly', 'var'))
    poly = [8 7 2 1];
%    poly = [8 6 5 1];
%    poly = [8 4 3 2];
%    poly = [8 6 3 2];
end
if (~exist('data', 'var'))
    data = [1 0 1 1 1 0 0 1];
%    data = [1 0 1 1 0 0 0 1];
%    data = [1 0 1 1 0 0 0 1];
%    data = [1 1 0 0 0 0 0 1];
end
if (~exist('len', 'var'))
    len = 256;
end
if (~exist('doPrint', 'var'))
    doPrint = 0;
end
if (~exist('pat', 'var'))
    pat = [];
end
pdList = 1;
for i=1:length(pdList)
    %pd = pdList(i);
    %poly = dec2bin(pd, 8)-48;
    %data = dec2bin(pd, 8)-48; 
    result = calcPoly(poly, data, len, doPrint, pat);
end


function result = calcPoly(poly, data, len, doPrint, pat)
data0 = data;
if (max(poly) > 1)
    p2 = zeros(1, max(poly));
    p2(poly) = 1;
    p2(2:max(poly)) = p2(1:max(poly)-1);
    p2(1) = 1;
    poly = p2;
end
result = zeros(len, 1);
for i=1:len
    out2 = data(8);
    result(i) = out2;
    data(2:8) = data(1:7);
    data(1) = 0;
    if (out2)
        data = xor(data, poly);
    end
end



function [awg1, awg2, syncCfg, scopeCfg] = makeCfg(arbConfig)
% create separate config structures for AWG#1, AWG#2, SYNC module and scope
if (~strcmp(arbConfig.connectionType, 'visa'))
    errormsg('Only VISA connection type is supported by this utility');
end
if (~isfield(arbConfig, 'visaAddr2'))
    errormsg('Please configure second M8190A module in configuration window');
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

