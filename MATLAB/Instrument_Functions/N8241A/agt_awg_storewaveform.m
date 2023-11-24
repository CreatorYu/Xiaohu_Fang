function [returnvalue, errorcode, errorcode_description] = agt_awg_storewaveform(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% This function stores a specific waveform and returns a unique handle that references the waveform. 
% All vector data for a given waveform is normalized to the maximum
% amplitude (will lie between +1 and -1), and thus will always range to
% full scale.  N6030 must be in 'arb' mode to store a waveform.
%
% function [ returnvalue, errorcode, errorcode_description] = agt_awg_storewaveform(handle,waveform)
%
% Output:        
%   returnvalue             integer     a handle for the waveform
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%   waveform                array       an array that contains the waveform data
%   option                  integer     0: do not scale.  
%                                       1: scale.  Default value is 1.
% 
% Required:
%   N6030 must be in 'arb' mode (see: agt_awg_setstate) in order to store a
%   waveform.
%
%   See Also:  agt_awg_clearsequence.m, agt_awg_clearwaveform.m, 
%   agt_awg_getstate.m, agt_awg_playsequence.m, agt_awg_playwaveform.m, 
%   agt_awg_setstate.m, agt_awg_storesequence.m
%

if (nargin < 2) 
    error('Function requires at least two (2) input arguments.');
end

if ( ~isnumeric(varargin{1} ) )
    error('Instrument Handle must be a number');
end

if ( ~isnumeric(varargin{2} ) )
    returnvalue = 0;
    errorcode = int32(-1074135025);
    errorcode_description = 'Waveform must be a numeric array. See help for details.';
    return;
end

dimensions = size(varargin{2});

if(min(dimensions) > 2)
    returnvalue = 0;
    errorcode = int32(-1074135025);
    errorcode_description = 'Waveform must be a numeric array of 2 or less dimensions. See help for details.';
    return;
end

if( max(dimensions) < 64 )
    returnvalue = 0;
    errorcode = int32(-1074135025);
    errorcode_description = 'Waveform must have at least 64 samples.';
    return;
end

if( mod(max(dimensions),8) )
    returnvalue = 0;
    errorcode = int32(-1074135025);
    errorcode_description = 'Waveform must have a multiple of 8 number of samples.';
    return;
end



% Convert to row vector
if( dimensions(1) < dimensions(2) )
    waveform = varargin{2}';
    %transponsed = 1;
else
    waveform = varargin{2};
    %transponsed = 0;
end
    
%%%%% INTEGER METHOD %%%%% 
if( isa(varargin{2},'int16') )
    % Use integer transfer mechanism
    % waveformhandle = index
    returnvalue = 0;
    errorcode = int32(-1074135025);
    errorcode_description = 'NOT YET IMPLEMENTED';
    return
end

%%%%% REAL NUMBER METHOD %%%%% 
if( isreal(varargin{2}) )
    % if 1 x N, pad Ch-2 with zeros
    if( min(size(waveform)) == 1 )
        waveform = [ waveform, zeros(max(size(waveform)),1) ];
    end
    if(nargin == 3 && varargin{3} == 0)
        scale = 0;
    else
        scale = max(max(abs(waveform)));
    end
    if(scale ~= 0)
        waveform = (1/scale) * waveform;
    end
    
    [returnvalue, errorcode, errorcode_description] = N6030MEX('storewaveform',varargin{1},waveform);
   return 
end        
