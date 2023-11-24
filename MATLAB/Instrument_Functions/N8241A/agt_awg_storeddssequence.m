function [returnvalue, errorcode, errorcode_description] = agt_awg_storeddssequence(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
% 
% This function stores a DDS sequence when in DDS mode.  To play a dds
% sequence, users must first store the sequence, then create scenario (see agt_awg_storeddsscenario),
% setup start trigger and stop trigger.  Then send start trigger to start
% or send stop trigger to stop.
%
% function [ returnvalue, errorcode, errorcode_description] = agt_awg_storeddssequence(handle,sequencetable)
%
% Output:        
%   returnvalue             integer     a handle for the sequence
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%   sequencetable           array       an N x at least 7 array that contains the sequence table data 
%
%  Notes:
%    The sequence table consists of seven column vectors:
%       The first column lists the waveform handles.
%       The second lists the number of repetitions for the respective waveform (also called loop count).
%       The third column lists the initial phase in degree.
%       The forth column lists the initial frequency in Hz.
%       The fifth column lists the frequency slope in Hz/sec.  It determines how frequency linearly changes over time.
%           frequencySlope = (endFrequency - initFreq)*clockFrequency/(waveformLength*loopCount)
%       The sixth column lists the initial amplitude.
%       The seventh column lists the amplitude slope.
%           amplitudeSlope = (endAmplitude - initAmplitude)*clockRate/(waveformLength*loopCount)
%       The eigth column tells if initial phase is enabled or not (1 or 0).  This is
%           an optional column.  If it is not specified, 1 will be used.
%       The ninth column specifies the waveform advance mode.  This is also an optional column.  It can be one
%           of the following values.
%               0: auto advance to the next waveform after playing a
%                  waveform.  This is the default value.  It the ninth column
%                  is not specified, 0 will be used.
%               2: wait for a trigger after playing a waveform once
%               3: wait for a trigger after playing a waveform "the number
%                  of repetitions" times.
%               1: play a waveform continuously until receive a jump or stop trigger. 
%       The tenth column specifies the waveform marker mask.  This is also an optional column.  It can be one
%           of the following values.
%               0: enables all markers including waveform start marker,
%                  waveform repeat marker and waveform gate marker.  This is
%                  the default value.  If the tenth column is not specified, 0
%                  will be used.
%               1: masks waveform start marker.
%               2: masks waveform repeat marker.
%               3: masks waveform start marker and waveform repeat marker.
%               4: masks waveform gate marker.
%               5: masks waveform gate marker and waveform start marker.
%               6: masks waveform gate marker and waveform repeat marker.
%               7: masks waveform start marker, waveform repeat marker
%               and waveform gate marker
%              
%
% Example:
%   Please see example10DdsSequencing.m under Examples folder.
%   See Also:  agt_awg_clearddssequence.m, agt_awg_clearwaveform.m, 
%   agt_awg_getstate.m, agt_awg_playwaveform.m, 
%   agt_awg_setstate.m, agt_awg_storeddsscenario.m, agt_awg_storewaveform.m
%

if (nargin < 2) 
    returnvalue = 0;
    errorcode = int32(-1074135025);
    errorcode_description = 'Function requires two (2) input arguments.';
    return;
end

[returnvalue, errorcode, errorcode_description] = N6030MEX('storeddssequence',varargin{1},varargin{2});

