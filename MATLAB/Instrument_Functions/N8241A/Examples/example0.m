% Agilent N6030 Series Matlab Interface, Release 1.20.1.0
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
%  A simple example of how to open and close a session to the Agilent N6030 AWG.

% Show Arbs that have been entered into The primary IO library and are connected to the LAN
[ directory, errorN, errorMsg ] = agt_awg_browse;
disp(directory);