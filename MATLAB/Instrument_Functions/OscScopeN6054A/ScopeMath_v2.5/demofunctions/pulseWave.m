function varargout = pulseWave(Data,Time)
% PULSEWAVE Create a pulse from a sine wave
% 
%  Usage:
%  [X,Y]                = PULSEWAVE(DATA,TIME);
% 
%    MATLAB Code that is executed: 
% 
%    idxPositive        = find(Data>0);
%    idxNegative        = find(Data<0);
%    fData              = zeros(size(Data));
%    fData(idxPositive) = 1;
%    fData(idxNegative) = -1;
% 
%  See also
%  INVERTWAVE, SQUAREWAVE, PULSEWAVE2, ZEROCROSSING  

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
    varargout{3} = 'Create a pulse from a sine wave';
    return;
end;	

if nargin==0
    help(mfilename)
    return;
end;

Data = Data-mean(Data);
idxPositive = find(Data>0);
idxNegative = find(Data<0);
fData = zeros(size(Data));
fData(idxPositive) = 1;
fData(idxNegative) = -1;
varargout{1}=Time;
varargout{2}=fData;
