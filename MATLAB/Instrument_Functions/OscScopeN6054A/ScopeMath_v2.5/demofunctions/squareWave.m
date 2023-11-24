function varargout = squareWave(Data,Time)
% SQUAREWAVE Square the input waveform
% 
%  Usage:
%  [X,Y]   = SQUAREWAVE(DATA,TIME);
% 
%  MATLAB Code that is executed: 
% 
%    fData = Data.^2;
% 
%  See also
%  INVERTWAVE, PULSEWAVE, PULSEWAVE2, ZEROCROSSING  

% $Author: Tatkins $
% $Revision: 4 $
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
    varargout{2} = 'Amplitude [V^2]';
    varargout{3} = 'Square of the input Waveform';
    return;
end;	

if nargin==0
    help(mfilename)
    return;
end;
varargout{1} = Time;
varargout{2} = Data.^2;