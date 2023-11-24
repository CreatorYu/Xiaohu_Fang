function varargout = wavePSD2(Data,Time,varargin)
% WAVEPSD2 Power spectral density with zero padding
% 
%    [X,Y] = WAVEPSD2(DATA,TIME,WINDOW);
% 
%   This function will calculate the power spectral density
%   of the data passed to it 
% 
%    WFORMIN is the data you wish calculate the power spectral desity of.
% 
%    WINDOW is the window to use and takes the following values:
%        'RECTANGLE' uses a rectangulare window.
%        'HANNING' uses a hanning window.
%        'HAMMING' uses a hamming window.
% 
% 
%    Relevant MATLAB Code that is executed: 
%    fData = 20*log10(abs(fft(Data.*window))/sqrt(N));
% 
% 
%  Example:
%    [x,y] = WAVEPSD2(Data,Time);
% 
%  See also
%  WAVEPSD

% $Author: Jliu $
% $Revision: 2 $
% $Date: 3/04/05 4:24p $

% Local Functions Defined: 
% 

% $Notes:
%
% $EndNotes

% $Description:
%
% $EndDescription

%   Copyright 1996-2012 The MathWorks, Inc.

if nargout ==3
    varargout{1} = 'Frequency [Hz]';
    varargout{2} = 'psd [dB]';
    varargout{3} = 'Power Spectral Density with Zero Padding';
    return;
end;	

if nargin==0
    help(mfilename)
    return;
end;

% Calculate the power spectral density of the data.
% put data in dB units.

N=length(Data);
pad = 2^(floor(log10(N)/log10(2))+1)-N;
Fs = 1/(Time(2)-Time(1));
N=pad+N;
switch(nargin)
    case 2
        window = ones(N,1);
    case 3
        windowName = varargin{2};
        if strcmpi(windowName(1:3),'HAN')
            window = hanning(N);
        elseif strcmpi(windowName(1:3),'HAM')
            window = hamming(N);           
        else
            window = ones(N,1);
        end;
end;

freq = ((0:N-1)./N)*Fs;
fftdata = 20*log10(abs(fft([Data,zeros(1,pad)].*window'))/sqrt(N));
varargout{1} = freq(1:floor(length(freq)/2));
varargout{2} = fftdata(1:floor(length(fftdata)/2));

