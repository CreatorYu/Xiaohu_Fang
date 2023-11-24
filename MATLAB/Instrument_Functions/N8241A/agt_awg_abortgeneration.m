function [errorcode, errorcode_description] = agt_awg_abortgeneration(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% This function aborts waveform playback. 
% Use this in continuous output mode to stop playback.
%
% function [ errorcode, errorcode_description] = agt_awg_abortgeneration(handle)
%
% Output:        
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
%                                       
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%   
%   See Also:  agt_awg_initiategeneration.m
%

if (nargin < 1) 
    error('Invalid input parameters.');
end

if ( ~isnumeric(varargin{1}) )
   error('Instrument Handle must be a number');
end

[errorcode, errorcode_description] = N6030MEX('abortgeneration',varargin{1});
    

