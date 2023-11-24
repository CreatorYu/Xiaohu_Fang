Fs_rowIQ = 122.88e6;
oversampling = 1;
fs = 8e+09;
carrierOffset = [2e+09];
sampleRate = Fs_rowIQ * oversampling;
numSymbols = 3000;
modType = 'QAM16';
% oversampling = 800;

filterType = 'Square Root Raised Cosine';
filterNsym = 80;
filterBeta = 0.35;
magnitude = [0];
quadErr = 0;
correction = 0;

newdata = 0;
normalize = 1;
arbConfig = [];


InI_beforeDPD_path = '../Signals/4CWCDMA_I_122p88_7dB.txt';
InQ_beforeDPD_path = '../Signals/4CWCDMA_Q_122p88_7dB.txt';


In_I_beforeDPD = load([InI_beforeDPD_path]); In_I_beforeDPD = In_I_beforeDPD(:, 1);
In_Q_beforeDPD = load([InQ_beforeDPD_path]); In_Q_beforeDPD = In_Q_beforeDPD(:, 1);

rawIQ=complex(In_I_beforeDPD,In_Q_beforeDPD).';

% use the same sequence every time so that results are comparable
randStream = RandStream('mt19937ar'); 
reset(randStream);

% find rational number to approximate the oversampling
[overN , overD] = rat(oversampling);
% adjust number of samples to match AWG limitations
arbConfig = loadArbConfig(arbConfig);
overD1 = gcd(overD, numSymbols);
numSamples = lcm(numSymbols * overN / overD1, arbConfig.segmentGranularity);
while (numSamples < arbConfig.minimumSegmentSize)
    numSamples = 2 * numSamples;
end
numSymbols = round(numSamples / overN * overD);


%% Signal Resampling
iqdata = upsample(rawIQ, overN);

if (overD ~= 1)
    iqdata = decimate(iqdata, overD);
end


%% calculate carrier offsets
len = length(iqdata);
result = zeros(1,len);
linmag = 10.^(magnitude./20);
for i = 1:length(carrierOffset)
    cy = round(len * carrierOffset(i) / sampleRate);
    shiftSig = exp(1i * 2 * pi * cy * (linspace(0, 1 - 1/len, len) + randStream.rand(1)));
    if (newdata)
        iqdata = iqmod_gen(hmod, numSymbols, overN, overD, filt, quadErr, offsetmod, randStream);
    end
    result = result + linmag(i) * (iqdata .* shiftSig);
end
iqdata = result;


%% normalize the output
if (normalize)
    scale = max(max(abs(real(iqdata))), max(abs(imag(iqdata))));
    iqdata = iqdata / scale;
end

delete(randStream);

%% Plot Signal
iqplot(iqdata, sampleRate);
