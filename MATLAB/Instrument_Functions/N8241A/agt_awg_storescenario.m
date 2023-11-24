function [returnvalue, errorcode, errorcode_description] = agt_awg_storescenario(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
% 
% This function stores a DDS scenario.  Please see agt_awg_storeadvsequence
% for more details.
%
% function [ returnvalue, errorcode, errorcode_description] = agt_awg_storescenario(handle,scenariotable)
%
% Output:        
%   returnvalue             integer     a handle for the sequence
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%   scenariotable           array       an N x at least 2 array that contains the scenario table data 
%
%  Notes:
%    The sequence table consists of three column vectors:
%       The first column lists the advanced sequence handles.  (See agt_awg_storeadvsequence)
%       The second lists the number of repetitions for the respective advanced sequence (also called loop count).
%       The third column lists the sequence marker mask.  This is an
%       optional column.  It can be one of the following values.
%           0: enables all markers including sequence start marker,
%              sequence repeat marker and sequence gate marker.  This is
%              the default value.  If the tenth column is not specified, 0
%              will be used.
%           1: disables sequence start marker.
%           2: disables sequence repeat marker.
%           3: disables sequence repeat marker and sequence repeat marker.
%           4: disables sequence gate marker.
%           5: disables sequence gate and sequence start marker.
%           6: disables sequence gate and sequence repeat marker.
%           7: disables sequence start marker, sequence repeat marker
%              and sequence gate marker
%      
% Example:
%   Please see example9AdvancedSequencing.m under 'Examples' folder.
%
%   See Also:  agt_awg_clearadvscenario.m, agt_awg_clearwaveform.m, 
%   agt_awg_getstate.m, agt_awg_playwaveform.m, 
%   agt_awg_setstate.m, agt_awg_storeadvsequence.m, agt_awg_storewaveform.m
%

if (nargin < 2) 
    returnvalue = 0;
    errorcode = int32(-1074135025);
    errorcode_description = 'Function requires two (2) input arguments.';
    return;
end

[returnvalue, errorcode, errorcode_description] = N6030MEX('storescenario',varargin{1},varargin{2});

