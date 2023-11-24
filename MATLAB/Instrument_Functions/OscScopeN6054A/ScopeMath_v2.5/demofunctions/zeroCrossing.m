function varargout = zeroCrossing(Data,Time)
% ZEROCROSSING Return times found for zero crossings in data with
% interpolation
% 
%  Usage:
%  [X,Y]   = ZEROCROSSING(DATA,TIME);
% 
%    MATLAB Code that is executed: 
% 
%    sig   = (Data>guardband) - (Data<-guardband);
%    idx   = find(sig);  
%    w     = find(diff(sig(idx))); 
%    idx1  = idx(w);              
%    idx2  = idx(w+1);            
%    y1    = waveform(idx1); 
%    y2    = waveform(idx2); 
%    fData = ((idx1 - y1.*(idx2-idx1)./(y2-y1))-1)/Fs; 
% 
%  See also
%  INVERTWAVE, SQUAREWAVE, PULSEWAVE, PULSEWAVE2 

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
    varargout{1} = 'Index';
    varargout{2} = 'Time [sec]';
    varargout{3} = 'Return times found for zero crossings in data with interpolation';
    return;
end;	

if nargin==0
    help(mfilename)
    return;
end;

%Remove mean
Data=Data-mean(Data);

% I use a guardband in case of noise.
guardband = max(Data)*0.01;

sig = (Data>guardband) - (Data<-guardband);

% Find the index of all the points outside of the guardband
idx  = find(sig);  

% Generate indexes of when we transition from one state to the other.
%   Remember a derivative (diff) is zero for constant values and a number if there is a change.
w = find(diff(sig(idx))); 
idx1 = idx(w);              % Valid Point before Crossing state
idx2 = idx(w+1);            % Valid Point after Crossing

y1 = Data(idx1); y2 = Data(idx2); % Get y values for interp
Fs=1/(Time(2)-Time(1));
% Find Crossing using linear interpolation.  
%   index_value = current_index - current_y/slope
%   Times are the index_value/SampleRate.
fData = ((idx1 - y1.*(idx2-idx1)./(y2-y1))-1)/Fs; 
varargout{1} = (1:length(fData));
varargout{2} = fData;
