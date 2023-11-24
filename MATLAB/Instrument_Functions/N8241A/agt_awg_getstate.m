function [returnvalue, errorcode, errorcode_description] = agt_awg_getstate(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% This function returns the value of a specific attribute.
%
% function [returnvalue, errorcode, errorcode_description] = agt_awg_getstate(handle,attrib,option)
%
% Output:        
%   returnvalue             varies      the state values returned by the query
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%   'attrib'                string      selects the specific attribute
%                                       (see agt_awg_setstate for a list of atttributes)
%   option                  integer     specifies one of the following
%                                           - front panel channel : 1 or 2.  If not
%                                                       specified, both channel will be
%                                                       effected.
%											- marker  : from 1 to 6.  If not
%														specified, 1 will be used.
%														(5 and 6 are LXI only markers)
%											- trigger : 1 to 5.  If not
%														specified, 1 will be used.
%														(5 is LXI only trigger)
%
%
% Supported Attributes:
%   All attributes described in agt_awg_setstate.
%
%   'outputoffsetmin'
%       Minimum allowable output voltage offset in Volts.
%       
%   'outputoffsetmax'
%       Maximum allowable output voltage offset in Volts.
%
%   'ddsenabed'            
%       'true' if the opened session is dds, 'false' otherwise.
%   'instrumentoptions'
%       return a list of current instrument options such as memory size,
%       number of DAC bits, half rate, dynamic sequencing or DDS.
%   See Also: agt_awg_browse.m, agt_awg_setstate.m,
%

if (nargin < 2) 
    error('Not enough input arguments.');
end

if ( (nargin == 2) && ischar(varargin{2}))
    [returnvalue, errorcode, errorcode_description] = agt_awg_getall(varargin{1},varargin{2});
elseif ((nargin == 3) && ischar(varargin{2}))
    [returnvalue, errorcode, errorcode_description] = agt_awg_getone(varargin{1},varargin{2},varargin{3});
else
    error('Invalid input arguments. See help for details.');
end

function [returnvalue, errorcode, errorcode_description] = agt_awg_getall(handle,attrib)
handle = handle(1);
[returnvalue, errorcode, errorcode_description] = N6030MEX('getstate',handle,attrib,0); 

function [returnvalue, errorcode, errorcode_description] = agt_awg_getone(handle,attrib,chan)
handle = handle(1);
[returnvalue, errorcode, errorcode_description] = N6030MEX('getstate',handle,attrib,chan);

% function [returnvalue, errorcode, errorcode_description] = agt_awg_getall(handle)
% % get all statevars as per awg_statevar
