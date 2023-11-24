function [errorcode, errorcode_description] = agt_awg_playsequence(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% This function plays a specific sequence.
%
% function [ errorcode, errorcode_description] = agt_awg_playsequence(handle,sequencehandle)
%
% Output:        
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%   sequencehandle          integer     references a specific sequence to play
%
%   See Also: agt_awg_clearsequence.m, agt_awg_clearwaveform.m, 
%   agt_awg_getstate.m, agt_awg_playwaveform.m, agt_awg_setstate.m,
%   agt_awg_storesequence.m, agt_awg_storewaveform.m
%

if (nargin < 1) 
    error('Invalid input parameters.');
end

if ( ~isnumeric(varargin{1}) )
   error('Handle must be a number');
end

if ( ~isnumeric(varargin{2} ) )
    errorcode = int32(-1074135025);
    errorcode_description = 'Invalid input parameters. See help for details.';
    return;
end

[errorcode, errorcode_description] = N6030MEX('playsequence',varargin{1},varargin{2});
    

