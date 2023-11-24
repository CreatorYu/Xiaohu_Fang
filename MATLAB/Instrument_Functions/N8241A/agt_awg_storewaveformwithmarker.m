function [returnvalue, errorcode, errorcode_description] = agt_awg_storewaveformwithmarker(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% This function stores a specific waveform and returns a unique handle that references the waveform. 
% All vector data for a given waveform is normalized to the maximum
% amplitude (will lie between +1 and -1), and thus will always range to
% full scale.  N6030 must be in 'arb' mode to store a waveform.
%
% function [ returnvalue, errorcode, errorcode_description] = agt_awg_storewaveformwithmarker(handle,waveform,ch1mkr,ch1mkr2,ch2mkr1,ch2mkr2,option)
%
% Output:        
%   returnvalue             integer     a handle for the waveform
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
%
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%   waveform                array       a numeric array that contains the waveform data
%   ch1mkr1                 array       one dimensional numeric array that contains channel 1 waveform
%                                       marker 1.  Dat should be only 0 or 1.
%   ch1mkr2                 array       one dimensional numeric array that contains channel 1 waveform
%                                       marker 2.  Dat should be only 0 or 1.
%                                       This is an optional argument.
%   ch2mkr1                 array       one dimensional numeric array that contains channel 2 waveform
%                                       marker 1.  Dat should be only 0 or 1.
%                                       This is an optional argument.
%   ch2mkr2                 array       one dimensional numeric array that contains channel 2 waveform
%                                       marker 2.  Dat should be only 0 or 1.
%                                       This is an optional argument
%                                       
%   option                  integer     0: do not scale.  
%                                       1: scale.  Default value is 1.
%                                       This is an optional argument.
% 
%   Note: All the marker array sizes must be the same and equal to one eigth of the waveform array size.
%   Example: 
%           wfm = (0:127)
%           mkr = [0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1]
%           agt_awg_storewaveformwithmarker(instrumentHandle,[wfm;wfm],mkr,mkr,mkr,mkr)
%
%   See Also:  agt_awg_clearsequence.m, agt_awg_clearwaveform.m, 
%   agt_awg_getstate.m, agt_awg_playsequence.m, agt_awg_playwaveform.m, 
%   agt_awg_setstate.m, agt_awg_storesequence.m
%

if (nargin < 3) 
    error('Function requires at least three (3) input arguments.');
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

wfmSize = size(varargin{2});
if(min(wfmSize) > 2)
    returnvalue = 0;
    errorcode = int32(-1074135025);
    errorcode_description = 'Waveform must be a numeric array of 2 or less dimensions. See help for details.';
    return;
end

if( max(wfmSize) < 64 )
    returnvalue = 0;
    errorcode = int32(-1074135025);
    errorcode_description = 'Waveform must have at least 64 samples.';
    return;
end

if( mod(max(wfmSize),8) )
    returnvalue = 0;
    errorcode = int32(-1074135025);
    errorcode_description = 'Waveform must have a multiple of 8 number of samples.';
    return;
end

% Convert to row vector
if( wfmSize(1) < wfmSize(2) )
    waveform = varargin{2}';
else
    waveform = varargin{2};
end

if (isscalar(varargin{nargin}))
    option = 1;
    numOfMkrArray = nargin - 3;
else
    option = 0;
    numOfMkrArray = nargin - 2;
end

if(numOfMkrArray == 0)
    returnvalue = 0;
    errorcode = int32(-1074135025);
    errorcode_description = 'At least one marker array is required';
    return;
end

minCh1Mkr1Size = min(size(varargin{3}));
maxCh1Mkr1Size = max(size(varargin{3}));
if(~(maxCh1Mkr1Size == max(wfmSize)/8))
    returnvalue = 0;
    errorcode = int32(-1074135025);
    errorcode_description = 'Marker size must be one eigth of waveform size. See help for details.';
    return;
end
if(~(minCh1Mkr1Size == 1))
    returnvalue = 0;
    errorcode = int32(-1074135025);
    errorcode_description = 'Marker array must be one dimensional';
    return;
end

for i=(0:(numOfMkrArray-1))
    arraySize = size(varargin{3+i});
    if(~(max(arraySize) == maxCh1Mkr1Size && min(arraySize)== minCh1Mkr1Size))
        returnvalue = 0;
        errorcode = int32(-1074135025);
        errorcode_description = 'All marker size must be the same';
        return;
    end
    if(arraySize(1) < arraySize(2))
        varargin{3 + i} = varargin{3 + i}';
    end
end

ch1Mkr(:,1) = varargin{3};

if (numOfMkrArray == 1)
    ch1Mkr(:,2) = varargin{3};
    ch2Mkr = ch1Mkr;
else
    if(numOfMkrArray == 2)
        ch1Mkr(:,2) = varargin{4};
        ch2Mkr = ch1Mkr;
    else
        if(numOfMkrArray == 3)
            ch1Mkr(:,2) = varargin{4};
            ch2Mkr(:,1) = varargin{5};
            ch2Mkr(:,2) = varargin{5};
        else
            ch1Mkr(:,2) = varargin{4};
            ch2Mkr(:,1) = varargin{5};
            ch2Mkr(:,2) = varargin{6};
        end
    end
end

%  convert markerst to 8 bit integer (marker 2 = msb 1, marker 1 = msb 2).    
marker1 = (((2^7).*ch1Mkr(:,2)) + ((2^6).*ch1Mkr(:,1)));
marker2 = (((2^7).*ch2Mkr(:,2)) + ((2^6).*ch2Mkr(:,1)));

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
    if(option == 1 && varargin{nargin} == 0)
        % do not scale
    else  
        waveform = waveform / max(max(abs(waveform)));
    end
  
    [returnvalue, errorcode, errorcode_description] = N6030MEX('storewaveformwithmarker',varargin{1},waveform,marker1,marker2);
    return 
end
