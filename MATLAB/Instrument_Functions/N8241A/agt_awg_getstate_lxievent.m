function [returnvalue, errorcode, errorcode_description] = agt_awg_getstate_lxievent(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% function [returnvalue, errorcode, errorcode_description] =  agt_awg_getstate_lxievent(handle,attrib,lxichannel)
%
% This function gets the Additional LXI event based attributes.
%
% Get normal marker properties as normal ( ie 'mkrsource', 'mkrpulsewidth' etc ) using 
% channel 5 for LxiMarker1 and channel 6 for LxiMarker2
%
% Output:        
%   returnvalue             integer      the state values returned by the query
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%   'attrib'                string      selects the attribute to set 
%   'lxichannel'            string      Lxi channel, see below
%                                       
% Supported Attributes:
%   All attributes described in agt_awg_setstate_lxievent.
%

if (nargin ~= 3) 
    error('agt_awg_getstate_lxievent Invalid input parameters. See help for details.');
end

[returnvalue, errorcode, errorcode_description] = N6030MEX('getstate_lxievent',varargin{1},varargin{2},varargin{3});
