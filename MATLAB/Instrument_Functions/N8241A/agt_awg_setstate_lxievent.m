function [errorcode, errorcode_description] = agt_awg_setstate_lxievent(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% function [errorcode, errorcode_description] = agt_awg_setstate_lxievent(handle,attrib,lxichannel,value)
%
% This function sets or updates the Additional LXI event based attributes.
%
% Setup up normal marker properties as normal ( ie 'mkrsource', 'mkrpulsewidth' etc ) using 
% channel 5 for LxiMarker1 and channel 6 for LxiMarker2
%
% Output:        
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%   'attrib'                string      selects the attribute to set 
%   'lxichannel'            string      Lxi channel, see below
%   'value'                 integer     specifies the value to set
%                                       
% Supported Lxi Channels:
%				'LAN0'
%				'LAN1'
%				'LAN2'
%				'LAN3'
%				'LAN4'
%				'LAN5'
%				'LAN6'
%				'LAN7'
%				'LXI0'
%				'LXI1'
%				'LXI2'
%				'LXI3'
%				'LXI4'
%				'LXI5'
%				'LXI6'
%				'LXI7'
%				'EXT'
%
% Supported Attributes:
%
%	'src'				
%       Set the LXI Marker Event source
%       Valid values are:
%			5  is LxiMarker1
%			6  is LxiMarker2
%
%	'drivemode'			
%       Set the LXI Marker Event Output drive mode (Typically set to 0 to turn on, 1 to turn off output)
%       Valid values are:
%			0 Driven
%			1 Off
%			2 Wired Or mode
%
%

if (nargin ~= 4) 
    error('agt_awg_setstate_lxievent Invalid input parameters. See help for details.');
end

[errorcode, errorcode_description] = N6030MEX('setstate_lxievent',varargin{1},varargin{2},varargin{3},varargin{4});
