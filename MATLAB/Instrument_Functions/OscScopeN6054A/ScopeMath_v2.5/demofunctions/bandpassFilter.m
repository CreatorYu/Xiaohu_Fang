function varargout = bandpassFilter(Data,Time, varargin)
% BANDPASSFILTER Filter data using bandpass Chebyshev filtering
% 
%    [X,Y]       = BANDPASSFILTER(DATA, TIME, FILTERORDER,RIPPLE,WN);
% 
%    This uses a cheby2 filter design to calculate the filter coefficents.
%    DATA is the waveform you wish to filter.
%    FIlTERORDER is the order of the filter to calculate.
%    RIPPLE is the amount of exceptable ripple in DB.
%    WN is the normalized cutoff frequency (vector).
%    
%    The options used if not provided are the following:
%    FIlTERORDER = 10;
%    RIPPLE      = 20;
%    WN          = [0.2,0.8];
% 
%  Usage:
%  [X,Y]         = BANDPASSFILTER(DATA,TIME);
% 
%    Relevant MATLAB Code that is executed: 
%    [B,A]       =cheby2(filteroder,ripple,wn);
%    fData       = filter(B,A,Data);
% 
%  Example:
%    [x,y]       = BANDPASSFILTER(Data,Time);
% 
%  See also
%  LOWPASSFILTER, HIGHPASSFILTER

% $Author: Jliu $
% $Revision: 3 $
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
    varargout{3} = 'Filter data using bandpass Chebyshev filtering';
    return;
end;	

switch(nargin)
    case 0
        help bandpassfilter
        return;
    case 2
        filterorder = 10;
        ripple = 20;
        Wn = [0.2,0.8];
    case 3
        filterorder = varargin{1};
        ripple = 20;
        Wn = [0.2,0.8];
    case 4
        filterorder = varargin{1};
        ripple = varargin{2};
        Wn = [0.2,0.8];
    case 5
        filterorder = varargin{1};
        ripple = varargin{2};
        Wn = varargin{3};
    otherwise
        error('ScopeMath:bandpassfilter','Incorrect number of inputs.');
end;
[B,A] = cheby2(filterorder,ripple,Wn,'bandpass');
varargout{1} = Time;
varargout{2} = filter(B,A,Data);


