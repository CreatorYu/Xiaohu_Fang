%% Execute this script before running ScopeMath to initialize scope
% settings.

%   Copyright 1996-2012 The MathWorks, Inc.

DriverMDD = [pwd '\drivers\AgilentInfiniium_IVICOM.mdd'];
ResourceString = 'TCPIP0::Agilent-7a4ca89.dhcp.mathworks.com::inst0::INSTR';

instrreset;

% Create a device object. 
deviceObj = icdevice(DriverMDD, ResourceString);

% Connect device object to hardware.
connect(deviceObj);
% Query property value(s).
set(deviceObj.Acquisition(1), 'NumberOfAverages',8);
set(deviceObj.Acquisition(1), 'NumberOfEnvelopes',0);
set(deviceObj.Acquisition(1), 'NumberOfPointsMin',1000);
set(deviceObj.Acquisition(1), 'TimePerRecord',1e-06);
clear all; close all;
instrreset;