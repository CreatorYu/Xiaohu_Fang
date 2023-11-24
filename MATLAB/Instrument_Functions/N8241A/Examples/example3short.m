% Agilent N6030 Series Matlab Interface, Release 1.20.1.0
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
%  A simple example of how to open and close a session to the Agilent N6030
%  AWG, and read and write the state of an instrument attribute.
%
% Try to open a session, you need to put your instruments hostname or IP address into the VISA address below
% Host name defaults to A-[model number]-[last 5 digits of serial #]
% Host name VISA address would like: 'TCPIP0::A-N8241A-90123::inst0::INSTR' for a N8241A with a serial # of US45090123
% IP based VISA address would like: 'TCPIP0::196.196.196.196::inst0::INSTR' for an IP address of 196.196.196.196
[ instrumentHandle, errorN, errorMsg ] = agt_awg_open('TCPIP','TCPIP0::A-N8241A-90xxx::inst0::INSTR');
if( errorN ~= 0 )
    % An error occurred while trying to open the session.
    error('Could not open a session to the instrument');
    return;
end

% Get the state of the OutputEnabled attribute of the instrument.
[returnValue, errorN, errorMsg] = agt_awg_getstate( instrumentHandle, 'outputenabled' );
disp(['Attribute successfully read. OutputEnabled = ', returnValue, ' .' ] );

% Set the state of the OutputEnabled attribute of the instrument.
agt_awg_setstate( instrumentHandle, 'outputenabled', 'true' );

% Get the state of the OutputEnabled attribute of the instrument.
returnValue = agt_awg_getstate( instrumentHandle, 'outputenabled' );
disp(['Attribute successfully read. OutputEnabled = ', returnValue, ' .' ] );

agt_awg_close( instrumentHandle );
