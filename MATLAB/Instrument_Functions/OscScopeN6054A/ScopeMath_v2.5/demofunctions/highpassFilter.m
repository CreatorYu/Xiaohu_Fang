function varargout = highPassFilter(Data,Time, varargin)
% HIGHPASSFILTER Filter data using highpass Chebyshev filtering
% 
%    [X,Y]       = HIGHPASSFILTER(DATA,TIME, FILTERORDER,RIPPLE,WN);
% 
%    This uses a cheby2 filter design to calculate the filter coefficents.
%    DATA is the waveform you wish to filter.
%    FIlTERORDER is the order to the filter to calculate.
%    RIPPLE is the amount of exceptable ripple in DB.
%    WN is the normalized stopband frequency.
%    
%    The options used if not provided are the following:
%    FIlTERORDER = 10;
%    RIPPLE      = 20;
%    WN          = 0.5;
% 
%  Usage:
%  [X,Y]         = HIGHPASSFILTER(DATA,TIME);
% 
%    Relevant MATLAB Code that is executed: 
%    [B,A]       =cheby2(filteroder,ripple,wn);
%    fData       = filter(B,A,Data);
% 
%  Example:
%    [x,y]       = HIGHPASSFILTER(Data,Time);
% 
%  See also
%  LOWPASSFILTER, BANDPASSFILTER

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
    varargout{3} = 'Filter data using highpass Chebyshev filtering';
    return;
end;	

switch(nargin)
    case 0
        help highpassfilter
        return;
    case 2
        filterorder = 10;
        ripple = 20;
        Wn = 0.9;
    case 3
        filterorder = varargin{1};
        ripple = 20;
        Wn = 0.9;
    case 4
        filterorder = varargin{1};
        ripple = varargin{2};
        Wn = 0.9;
    case 5
        filterorder = varargin{1};
        ripple = varargin{2};
        Wn = varargin{3};
    otherwise
        error('ScopeMath:highpassfilter','Incorect number of inputs.');
end;
[B,A] = cheby2(filterorder,ripple,Wn,'high');
varargout{1} = Time;
varargout{2} = filter(B,A,Data);
