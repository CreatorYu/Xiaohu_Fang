function [errorcode, errorcode_description] = agt_awg_softwaretrigger(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% This function sends a software trigger to the instrument.  This will only
% have an effect if the AGN6030A is looking for a trigger source of 'sw1',
% 'sw2', or 'sw3'.
%
% For more information, see agt_awg_setstate: 'start', 'stop', 'hold',
% 'resume', 'wfmadv', 'scenariojump', or 'scenarioadv'.
%
% function [ errorcode, errorcode_description] = agt_awg_softwaretrigger(handle, trigger)
%
% Output:        
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%   trigger                 string      'sw1', 'sw2', or 'sw3'
%
%   See Also: agt_awg_setstate.m
%

if (nargin < 1) 
    error('Invalid input parameters.');
end

if ( ~isnumeric(varargin{1}) )
    error('Instrument Handle must be a number');
end

if ( isnumeric(varargin{2} ) )
    if varargin{2} == 1 || varargin{2} == 2 || varargin{2} == 3
        varargin{2} = ['sw' num2str(varargin{2})];
    else
      errorcode = int32(-1074135025);
      errorcode_description = 'Invalid input parameters. See help for details.';
      return;
    end
end

[errorcode, errorcode_description] = N6030MEX('sendsoftwaretrigger',varargin{1},varargin{2});
    

