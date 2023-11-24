function [handle,errorcode,errorcode_description] = agt_awg_open(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% function [handle,errorcode,errorcode_description] = agt_awg_open(connectiontype,addressString,optionString)
%
% Output:
%   handle                  integer     a handle to the instrument created by this function   
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   connectiontype          string      'PCI' is the only connectivity currently supported  
%   addressstring           string      VISA resource name
%   optionString            string      This is an optional argument.  For now, only one option string is supported:
%                                           'DDS': this option is used to open a DDS session.
%                                       If this argument is ommitted, a regular session will be opened,
%                                       which will not support DDS or noise applications.
%                                       
%                                       Note: after openning a DDS session, when applicable, DDS sequence interfaces
%                                       should be used instead of regular sequence interfaces.  For example,
%                                       agt_awg_storeddssequence, agt_awg_playddssequence and agt_awg_clearddssequence should be
%                                       called instead of agt_awg_storsequence agt_awg_playsequence and agt_awg_clearsequence.
%                                       
%                                           
% This function generates connection structures according to the interface type.
% The valid interface type is: 'PCI'.
% 
% The function call is:
% For regular cPCI/PXI connection:
%     agt_awg_open('PCI',Address)
%     sample: handle = agt_awg_open('PCI','PCI Addr');
% For cPCI/PXI connection with DDS option:
%     handle = agt_awg_open('PCI','PCI Addr','DDS');
%
%   See Also: agt_awg_browse.m, agt_awg_close.m
%

if (nargin < 1) 
    [handle,errorcode,errorcode_description] = N6030MEX('open','any');
    return;
end

if (~ischar(varargin{1}))
   error('The first argument has to be a string specifying the connection ''PCI'' or ''TCPIP''');
else
    interface = lower( varargin{1} );    
end

if (nargin > 2)
    optionString = varargin{3};
    if(~ischar(optionString)) 
        error('The third argument has to be a string specifying one of the options: DDS0, DDS1 or AWGN');
    end
else
    optionString = '';
end

if (strcmpi(optionString,'DDS') == 1) 
    option = 1;
else
    option = 0;
end

if (strcmpi(interface,'PCI'))
    if(nargin > 1)
        addressString = varargin{2};
    else
        addressString = 'any';
    end
    [handle,errorcode,errorcode_description] = N6030MEX('open',addressString,option);
    return;
elseif (strcmpi(interface,'TCPIP'))
    if(nargin > 1)
        addressString = varargin{2};
    else
        addressString = 'any';
    end
    [handle,errorcode,errorcode_description] = N6030MEX('open',addressString,option);
    return;
else 
    handle = uint32(0);
    errorcode = int32(-1074135025);
    errorcode_description = 'Interface type not supported.';
end
