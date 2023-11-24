function [returnvalue, errorcode, errorcode_description] = agt_awg_storeadvsequence(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
% 
% This function stores an advanced sequence.  To play an advanced
% sequence, users must first store the sequence, then create scenario (see agt_awg_storescenario),
% setup start trigger and stop trigger or jump trigger if desirable.  Then send start trigger to start
% or send stop trigger to stop.
%
% function [ returnvalue, errorcode, errorcode_description] = agt_awg_storeadvsequence(handle,sequencetable)
%
% Output:        
%   returnvalue             integer     a handle for the sequence
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%   sequencetable           array       an N x at least 2 array that contains the sequence table data 
%
%  Notes:
%    The sequence table consists of seven column vectors:
%       The first column lists the waveform handles.
%       The second lists the number of repetitions for the respective waveform (also called loop count).
%       The third column specifies the waveform advance mode.  This is also an optional column.  It can be one
%           of the following values.
%               0: auto advance to the next waveform after playing a
%                  waveform.  This is the default value.  It the ninth column
%                  is not specified, 0 will be used.
%               2: wait for a trigger after playing a waveform once
%               3: wait for a trigger after playing a waveform "the number
%                  of repetitions" times.
%               1: play a waveform continuously until receive a jump or stop trigger. 
%       The forth column specifies the waveform marker mask.  This is also an optional column.  It can be one
%           of the following values.
%               0: enables all markers including waveform start marker,
%                  waveform repeat marker and waveform gate marker.  This is
%                  the default value.  If the tenth column is not specified, 0
%                  will be used.
%               1: disables waveform start marker.
%               2: disables waveform repeat marker.
%               3: disables waveform start marker and waveform repeat marker.
%               4: disables waveform gate marker.
%               5: disables waveform start marker and waveform gate marker.
%               6: disables waveform repeat marker and waveform gate marker.
%               7: disables waveform start marker, waveform repeat marker
%               and waveform gate marker
%              
%
% Example:
%   Please see example9AdvancedSequencing.m under Examples folder.
%
%   See Also:  agt_awg_clearadvsequence.m, agt_awg_clearwaveform.m, 
%   agt_awg_getstate.m, agt_awg_playwaveform.m, 
%   agt_awg_setstate.m, agt_awg_storeadvscenario.m, agt_awg_storewaveform.m
%

if (nargin < 2) 
    returnvalue = 0;
    errorcode = int32(-1074135025);
    errorcode_description = 'Function requires two (2) input arguments.';
    return;
end

[returnvalue, errorcode, errorcode_description] = N6030MEX('storeadvsequence',varargin{1},varargin{2});

