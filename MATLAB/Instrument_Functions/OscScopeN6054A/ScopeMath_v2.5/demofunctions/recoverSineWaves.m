function varargout = recoverSineWaves(Data,Time,number)
% RECSINEWAVES Recover the sine waves of the waveform
% 
%    [X,Y] = RECSINEWAVES(DATA,TIME, NUMBEROFTONES);
% 
%  This function will find the local peaks in the fft of the data assuming the 
%  highest peak is the first peak. Then rebuild a waveform using only those frequencies.
% 
%    DATA is the data from the instrument.
%
%    TIME is a vector of time points where data was taken.
% 
%    NUMBEROFTONES is the maximum number of tones to use in reconstructing
%    the waveform.  If the maximum number is found is less than this then
%    only the tones found are used.  If NUMBEROFTONES is not provided then the 
%    peaks in the spectrum above the noise floor are used.
% 
%  Example:
%    [x,y] = RECSINEWAVES(Data,Time);
% 
%  See also
%  RECPRIMARYWAVE, REMPRIMARYWAVE 

% $Author: Jliu $
% $Revision: 3 $
% $Date: 3/04/05 4:24p $

% Local Functions Defined: 
% 	[localPeakValue, localPeakIdx]	= localpeaksInternal(waveformin)
%

% $Notes:
%
% $EndNotes

% $Description:
%
% $EndDescription

%   Copyright 1996-2012 The MathWorks, Inc.

if nargout ==3
    varargout{1} = 'Time [sec]';
    varargout{2} = 'Amplitude [V]';
    varargout{3} = 'Recover the sine waves of the waveform';
    return;
end;	

if nargin==0
    help(mfilename)
    return;
end;


N=length(Data);
meanValue = mean(Data);
[val,freqidx]=localpeaksInternal(Data-meanValue); % Shown below

if isempty(val)
    fData = zeros(size(Data));
else
    numTones = length(val);
    if nargin==3
        if (numTones>number)
            useTone=[1:number,numTones-number+1:numTones];
            val=val(useTone);
            freqidx=freqidx(useTone);
        end;
    end;
    freqidx = freqidx-1;
    idxImage = find(freqidx>floor(N/2));
    val(idxImage)=-1*val(idxImage);
    
    freq=(2*pi*(0:N-1)/N);
    freq = freq(:)';
    fData=zeros(size(freq));
    
    idx=min(length(val),20); % This is just to make it faster (DEMO Code).
    
    for c=1:idx;
        fData=fData+val(c)*sin(freq*freqidx(c));
    end;
end;	
varargout{1} = Time;
varargout{2} = fData;

function [localPeakValue, localPeakIdx] = localpeaksInternal(waveformin)
% LOCALPEAKS	Find the amplitude of the primary frequecies.
%	
% This function will find the local peaks in the fft of the data using
% the given window size.  It does not report the peak of the DC signal 
% and assumes the highest peak is the first peak.
%
%
% Notes:
% End of Notes.

% Calculate FFT and frequency spacing 
N = length(waveformin);
fftdata = abs(fft(waveformin))/N;

% We are assuming that the first peak is the maximum except for DC
%	we are removing the DC component.

% If a window width is not specified we will use half the
% distance from DC to first Peak as the window width.
[maxPeak,idxPeak] = max(fftdata);
windowWidth = floor(idxPeak/2)+1;

% Find all the peak frequencies in the given window
M = floor(N/windowWidth);
fdata = reshape(fftdata(1:M*windowWidth),windowWidth,M);
[localPeakValue,idxLocalPeak]=max(fdata);
idxLocalPeak = idxLocalPeak(2:end)+((1:M-1)*windowWidth);
localPeakValue = localPeakValue(2:end);

% Find the noise floor
noisefloor = mean(fftdata);

% Only report back frequencies with values above 2*noise floor
[newLocalPeakidx] = find(localPeakValue>2*noisefloor);
localPeakIdx = idxLocalPeak(newLocalPeakidx);
localPeakValue = abs(localPeakValue(newLocalPeakidx));


