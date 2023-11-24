function [errorcode, errorcode_description] = agt_awg_clearadvsequence(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% This function removes a previously created advanced sequence.
%
% function [ errorcode, errorcode_description] = agt_awg_clearadvsequence(handle,sequencehandle)
%
% Output:        
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
%
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open) 
%   sequencehandle          integer     Optional: removes referenced sequence.  
%
% See Also: agt_awg_storeadvsequence, agt_awg_storescenario
% agt_awg_storewaveform, agt_awg_setstate, agt_awg_getstate,
% agt_awg_clearwaveform
%


if (nargin < 1) 
     error( 'Invalid input parameters.');
 end

if ( ~isnumeric(varargin{1}) )
   error('Instrument Handle must be a number');
end

if( nargin == 1)
    [errorcode, errorcode_description] = N6030MEX('clearadvsequence',varargin{1},-1);
    return;
end

if ( ~isnumeric(varargin{2} ) )
    errorcode = int32(-1074135025);
    errorcode_description = 'Invalid input parameters. See help for details.';
    return;
end

%Clear waveform at index
[errorcode, errorcode_description] = N6030MEX('clearadvsequence',varargin{1},varargin{2});

