function varargout = histogram(Data,Time,varargin)
% HISTOGRAM Histogram plot
% 
%    [XUOT,Y]       = HISTOGRAM (DATA,TIME);
% 
%    [XUOT,Y]= HISTOGRAM (DATA,TIME) bins the elements in vector DATA 
%    into 50 equally spaced containers and returns the number of elements 
%    in each container as a row vector Y; XOUT contains the bin locations.

%    TIME is needed for consistency with SCOPEMATH API

%   Copyright 1996-2012 The MathWorks, Inc.

if nargout ==3
    varargout{1} = 'Amplitude [V]';
    varargout{2} = '# Samples';
    varargout{3} = 'Histogram';
    return;
end;	

switch(nargin)
    case 0
        help hist
        return;
    case {2, 3}        
        [n , xout] = hist(Data, 500);
        
    otherwise
        error('ScopeMath:histogram','Incorect number of inputs.');
end;

varargout{1} = xout;
varargout{2} = n;
