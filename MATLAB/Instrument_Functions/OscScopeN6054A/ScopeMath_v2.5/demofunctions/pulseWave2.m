function varargout = pulseWave2(Data,Time)
% PULSEWAVE2 Create a pulse at zero crossings
% 
%  Usage:
%  [X,Y]         = PULSEWAVE2(DATA,TIME);
% 
%    MATLAB Code that is executed: 
% 
%    sig         = (Data>guardband) - (Data<-guardband);
%    idx         = find(sig);  
%    w           = find(diff(sig(idx))); 
%    idx1        = idx(w);              
%    fData       = zeros(size(Data));
%    fData(idx1) = 1;
% 
%  See also
%  INVERTWAVE, SQUAREWAVE, PULSEWAVE, ZEROCROSSING  

% $Author: Tatkins $
% $Revision: 3 $
% $Date: 5/06/05 1:41p $

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
    varargout{3} = 'Pulses at Zero Crossings';
    return;
end;	

if nargin==0
    help(mfilename)
    return;
end;

Data = Data-mean(Data);

% I use a guardband in case of noise.
guardband = max(Data)*0.01;

sig = (Data>guardband) - (Data<-guardband);

% Find the index of all the points outside of the guardband
idx  = find(sig);  

% Generate indexes of when we transition from one state to the other.
%   Remember a derivative (diff) is zero for constant values and a number if there is a change.
w = find(diff(sig(idx))); 
idx1 = idx(w);              % Valid Point before Crossing state

% Generate the output signal with zeros except at just before crossing
fData = zeros(size(Data));
fData(idx1) = 1;

varargout{1} = Time;
varargout{2} = fData;
