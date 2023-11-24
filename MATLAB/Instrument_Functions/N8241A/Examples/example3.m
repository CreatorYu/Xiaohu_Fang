% Agilent N6030 Series Matlab Interface, Release 1.20.1.0
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
%  A simple example of how to open a session to the Agilent N6030
%  AWG, set the state, play the waveform, and close the session.
%
% Try to open a session, you need to put your instruments hostname or IP address into the VISA address below
% Host name defaults to A-[model number]-[last 5 digits of serial #]
% Host name VISA address would like: 'TCPIP0::A-N8241A-90123::inst0::INSTR' for a N8241A with a serial # of US45090123
% IP based VISA address would like: 'TCPIP0::196.196.196.196::inst0::INSTR' for an IP address of 196.196.196.196
disp('Opening a session to the instrument.');
[ instrumentHandle, errorN, errorMsg ] = agt_awg_open('TCPIP','TCPIP0::A-N8241A-90xxx::inst0::INSTR');

if( errorN ~= 0 )
    % An error occurred while trying to open the session.
    error('Could not open a session to the instrument');
    return;
end
disp('Session to instrument opened successfully .');


% Get the state of the OutputEnabled attribute of the instrument.
[returnValue, errorN, errorMsg] = agt_awg_getstate( instrumentHandle, 'outputenabled' );
if( errorN ~= 0 )
	agt_awg_close( instrumentHandle );
    disp(['Error occurred reading instrument state: Error #', num2str(errorM), ' (', errorMsg, ')' ]);
    return;
else
    % Display the results to the console.
    disp(['Attribute successfully read. OutputEnabled = ', returnValue, ' .' ] );
end

% Set the state of the OutputEnabled attribute of the N6030A.
[errorN, errorMsg] = agt_awg_setstate( instrumentHandle, 'outputenabled', 'true' );
if( errorN ~= 0 )
	agt_awg_close( instrumentHandle );
    disp(['Error occurred writing insturment state: Error #', num2str(errorM), ' (', errorMsg, ')' ]);
    return;
else
    % Displays the results to the console.
    disp(['Attribute successfully written. OutputEnabled = ', returnValue, ' .' ] );
end

% Get the state of the OutputEnabled attribute of the N6030A
[returnValue, errorN, errorMsg] = agt_awg_getstate( instrumentHandle, 'outputenabled' );
if( errorN ~= 0 )
 	agt_awg_close( instrumentHandle );
	disp(['Error occurred reading instrument state: Error #', num2str(errorM), ' (', errorMsg, ')' ]);
    return;
else
    % Display the results to the console
    disp(['Attribute successfully read. OutputEnabled = ', returnValue, ' .' ] );
end


% Close the session
disp('Trying to close the session.');
[ errorN, errorMsg ] = agt_awg_close( instrumentHandle );

if( errorN ~= 0 )
    % An error occurred while trying to close the session.
    error('Could not close the session to the instrument');
    return;
end
disp('Session to the instrument closed successfully.');
