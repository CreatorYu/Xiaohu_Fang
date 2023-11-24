function [returnvalue, errorcode, errorcode_description] = agt_awg_storesequence(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
% 
% This function stores a waveform sequence.
%
% function [ returnvalue, errorcode, errorcode_description] = agt_awg_storesequence(handle,sequencetable)
%
% Output:        
%   returnvalue             integer     a handle for the sequence
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%   sequencetable           array       an N x 2 array that contains the sequence table data 
%
%  Notes:
%    The sequence table consists of two column vectors. The first column lists the waveform
%    handles, the second lists the number of repetitions for the respective waveform.
%
% Example:
% seq  = [ 5, 10 ; 7, 100 ];
% This sequence would play waveform #5 ten times, then waveform # 7 one
% hundred times.
%
%   See Also:  agt_awg_clearsequence.m, agt_awg_clearwaveform.m, 
%   agt_awg_getstate.m, agt_awg_playsequence.m, agt_awg_playwaveform.m, 
%   agt_awg_setstate.m, agt_awg_storesequence.m, agt_awg_storewaveform.m
%

if (nargin < 2) 
    error('Function requires two (2) input arguments.');
end

if ( ~isnumeric(varargin{1} ) )
   error('Instrument Handle must be a number');
end

if ( ~isnumeric(varargin{2} ) )
    returnvalue = 0;
    errorcode = int32(-1074135025);
    errorcode_description = 'Sequence must be a numeric array. See help for details.';
    return;
end

dimensions = size(varargin{2});

if( dimensions(2) ~= 2)
    returnvalue = 0;
    errorcode = int32(-1074135025);
    errorcode_description = 'Waveform must be an N x 2 numeric array. See help for details.';
    return;
end

[returnvalue, errorcode, errorcode_description] = N6030MEX('storesequence',varargin{1},varargin{2});

