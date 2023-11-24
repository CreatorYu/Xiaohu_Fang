function [errorcode, errorcode_description] = agt_awg_playwaveform(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% This function plays a specific waveform.
%
% function [ errorcode, errorcode_description] = agt_awg_playwaveform(handle,waveformhandle)
%
% Output:        
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%   waveformhandle          integer     references a specific waveform to play
%   
%   See Also:  agt_awg_clearwaveform.m, agt_awg_getstate, agt_awg_playsequence.m, 
%   agt_awg_setstate.m, agt_awg_storewaveform.m
%

if (nargin < 1) 
    error('Invalid input parameters.');
end

if ( ~isnumeric(varargin{1}) )
   error('Instrument Handle must be a number');
end

if ( ~isnumeric(varargin{2} ) )
    errorcode = int32(-1074135025);
    errorcode_description = 'Invalid input parameters. See help for details.';
    return;
end

[errorcode, errorcode_description] = N6030MEX('playwaveform',varargin{1},varargin{2});
    

