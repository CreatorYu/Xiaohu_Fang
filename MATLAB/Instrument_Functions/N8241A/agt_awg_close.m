function [errorcode,errorcode_description]  = agt_awg_close(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% function [errorcode, errorcode_description] = agt_awg_close(handle)
% This function closes a session.
% Output:        
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%
%   See Also: agt_awg_browse, agt_awg_open
%

if (nargin < 1) 
   error('Not enough input arguments.');
end

if (~isnumeric(varargin{1}))
   error('Instrument Handle must be a number');
else
    handle = varargin{1};    
    handle = handle(1);
    [errorcode,errorcode_description] = N6030MEX('close',handle);
end
