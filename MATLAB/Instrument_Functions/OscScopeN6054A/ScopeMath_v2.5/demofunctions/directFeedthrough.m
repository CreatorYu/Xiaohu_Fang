function varargout = directFeedthrough(Data,Time,varargin)
% No processing on the data - feed it back to the GUI
%   Copyright 1996-2012 The MathWorks, Inc.

if nargout ==3
    varargout{1} = 'Time [sec]';
    varargout{2} = 'Amplitude [V]';
    varargout{3} = 'Direct feedthrough of input data';
    return;
end;	

varargout{1} = Time;
varargout{2} = Data;
