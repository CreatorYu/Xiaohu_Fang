function [errorcode, errorcode_description] = agt_awg_initiategeneration(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% This function initiates waveform playback. 
% Use this in continuous output mode to start playback.
%
% function [ errorcode, errorcode_description] = agt_awg_initiategeneration(handle)
%
% Output:        
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%   
%   See Also:  agt_awg_abortgeneration.m
%

if (nargin < 1) 
    error('Invalid input parameters.');
end

if ( ~isnumeric(varargin{1}) )
   error('Instrument Handle must be a number');
end

[errorcode, errorcode_description] = N6030MEX('initiategeneration',varargin{1});
    

