function [errorcode, errorcode_description] = agt_awg_clearwaveform(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
%This function removes a previously created waveform.  This function is
%suggested to be invoked when the user has created an excess or
%unmanagable amount of waveforms and would like to clear out some memory.
%
% function [ errorcode, errorcode_description] = agt_awg_clearwaveform(handle,waveformhandle)
%
% Output:        
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%   waveformhandle          integer     Optional: removes referenced waveform 
%
% See Also: agt_awg_storewaveform, agt_awg_playwaveform,
% agt_awg_setstate, agt_awg_clearsequence
%


if (nargin < 1) 
    error('Invalid input parameters.');
end

if ( ~isnumeric(varargin{1}) )
   error('Instrument Handle must be a number');
end

if( nargin == 1)
    % Clear all waveform memory
    [errorcode, errorcode_description] = N6030MEX('clearwaveform',varargin{1},-1);
    return;
end

if ( ~isnumeric(varargin{2} ) )
    errorcode = int32(-1074135025);
    errorcode_description = 'Invalid input parameters. See help for details.';
    return;
end

% clear waveform at index
[errorcode, errorcode_description] = N6030MEX('clearwaveform',varargin{1},varargin{2});

