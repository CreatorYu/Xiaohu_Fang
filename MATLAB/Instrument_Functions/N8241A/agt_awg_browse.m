function [directory,errorcode,errorcode_description] = agt_awg_browse()
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% function [directory,errorcode,errorcode_description] = agt_awg_browse
%
% Output:
%   directory               varies      if directory = 0, the
%                                       string 'None' is displayed
%                                       if directory is non-zero,
%                                       a cell array of Mx3 is created, where M equals the 
%                                        number of found instruments
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
%   
% This function browses the system for all detected N6030A instruments. The
% cell array returned (when 1 or more instruments were found), has one row
% per found instrument. Each row has three columns;
%   Column 1: string    Visa Resourse name of the instrument
%   Column 2: string    Serial Number of the instrument
%   Column 3: numeric   PXI Slot Number of the instrument
%



[directory,errorcode,errorcode_description] = N6030MEX('browse');
