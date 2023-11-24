function varargout = removePrimaryWave(Data,Time)
% REMPRIMARYWAVE Recover the primary sine wave of the waveform and remove
% it
% 
%    [X,Y] = REMPRIMARYWAVE(DATA,TIME);
% 
%   Calculates the primary tone in the signal and returns the original waveform
%   minus the primary sinewave.
% 
% 
%  Example:
%    [x,y] = REMPRIMARYWAVE(Data,Time);
% 
%  See also
%  RECPRIMARYWAVE, RECSINEWAVES

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
    varargout{1} = 'Time [sec]';
    varargout{2} = 'Amplitude [V]';
    varargout{3} = 'Recover the primary sine wave of the waveform and remove it';
    return;
end;	

if nargin==0
    help(mfilename)
    return;
end;

% Take the FFT of the data and find the largest signal above DC
% then generate a sin wave with this frequency.

% Get the length of the signal
N=length(Data);

% Take the FFT of the data removing DC
fftdata = fft(Data-mean(Data));

% Find the maximum peak in the FFT
[y,idxTone] = max(fftdata);
idxTone=idxTone;
% Calculate the frequency that this peak represents.
freq=(idxTone-1)/N;

% Generate the sin wave that represents this frequency using the angle from
% the FFT data.
a1=angle(fftdata(idxTone));
a2=angle(fftdata(N-idxTone+2));
if a1>=0
    if a2>0
        disp('Imaginary Results in FFT.  We have a problem.');
        ang = 0;        
    else
        ang = a1+pi/2; % cos(ang)
    end;
else
    if a2>=0
        ang = a1+pi/2; %sin(ang)
    else
        disp('Imaginary Results in FFT.  We have a problem.');
        ang = 0;        
    end;
end;
varargout{1} = Time;
varargout{2}=Data-((2*abs(y)/N)*sin(2*pi*(0:N-1)*freq+ang));
