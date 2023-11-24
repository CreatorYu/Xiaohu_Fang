function varargout = invertWave(Data,Time)
% INVERTWAVE Invert the waveform
% 
%  Usage:
%  [X,Y]   = INVERTWAVE(DATA,TIME);
% 
%  MATLAB Code that is executed: 
% 
%    fData = -1*Data;
% 
%  See also
%  SQUAREWAVE, PULSEWAVE, PULSEWAVE2, ZEROCROSSING 

% $Author: Tatkins $
% $Revision: 5 $
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
    varargout{3} = 'Invert the Waveform';
    return;
end;	
if nargin==0
    help(mfilename)
    return;
end;
varargout{1} = Time;
varargout{2} = -1*Data;
