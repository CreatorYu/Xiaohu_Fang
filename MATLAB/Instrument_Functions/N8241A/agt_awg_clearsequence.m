function [errorcode, errorcode_description] = agt_awg_clearsequence(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% This function removes a previously created waveform sequence.
%
% function [ errorcode, errorcode_description] = agt_awg_clearsequence(handle,sequencehandle)
%
% Output:        
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
%
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open) 
%   sequencehandle          integer     Optional: removes referenced sequence  
%
% See Also: agt_awg_storesequence, agt_awg_playsequence,
% agt_awg_storewaveform.m, agt_awg_setstate.m, agt_awg_getstate.m,
% agt_awg_clearwaveform.m
%


if (nargin < 1) 
    error('Invalid input parameters.');
end

if ( ~isnumeric(varargin{1}) )
   error('Handle must be a number');
end

if( nargin == 1)
    [errorcode, errorcode_description] = N6030MEX('clearsequenc',varargin{1},-1);
    return;
end

if ( ~isnumeric(varargin{2} ) )
    errorcode = int32(-1074135025);
    errorcode_description = 'Invalid input parameters. See help for details.';
    return;
end

%Clear waveform at index
[errorcode, errorcode_description] = N6030MEX('clearsequence',varargin{1},varargin{2});

