function SignalGenerator_SMW200A(SMWAdd,center_frequency,input_power,i)

%SMWAdd='TCPIP::192.168.1.102::INSTR';
%center_frequency=3.8;
%input_power=-29;
% i=0, reset the instrument;
% i=1,Set the RF parameter of SMW200A
% i=2,output ON
% i=3,output OFF
% Use the VISA interface from National Instruments and
% connect via GPIB board number 0 to an instrument with address 28
% [status, InstrObject] = rs_connect( 'visa', 'ni', 'GPIB0::28::INSTR' );

% Use the VISA interface from National Instruments and
% connect via LAN (VXI-11)
  [status, InstrObject] = rs_connect( 'visa', 'ni', SMWAdd );

% Use the raw TCP/IP socket connection on port 5025
% [status, InstrObject] = rs_connect( 'tcpip', 'smbv100a255025' );

if( ~status )
    clear;
    disp( 'rs_connect() failed.' );
    return;
end

% target instrument path for waveform file
%InstrTargetPath = 'D:\';                   % MS Windows based, e.g. SMU, SMJ, SMATE
%InstrTargetPath = '/var/smbv/';            % Linux based, flash memory, e.g. SMBV
%InstrTargetPath = '/hdd/';                 % Linux based, hard drive, e.g. SMBV 
InstrTargetPath = '/var/user/';            % Linux based, SMW200A

StartARB         = 1;                       % start in path A
KeepLocalFile    = 0;                       % waveform only temporarily saved
LocalFileName    = 'awgn.wv';               % The local and remote file name

center_frequency=center_frequency/1e9;
% *************************************************************************
% Instrument Setup
% *************************************************************************

% check for R&S device, we also need the *IDN? result later...
disp( 'Checking instrument...' );
[status, InstrIDN] = rs_send_query( InstrObject, '*IDN?' );
if( ~status ); clear;  return; end
if( isempty( strfind( InstrIDN, 'Rohde&Schwarz' ) ) )
    disp('This is not a Rohde&Schwarz device.');
    clear; return;
end

% reset the instrument
if i==0 %i=0, reset the instrument
  [status, OPCResponse] = rs_send_query( InstrObject, '*RST; *OPC?' );
  if( ~status ); clear;  return; end
  [status] = rs_send_command( InstrObject, '*CLS' );
  if( ~status ); clear;  return; end
elseif i==1 %i=1,Set the RF parameter of SMW200A
  %Set the RF parameter of SMW200A
     [Status]=rs_send_command( InstrObject, 'SOURce1:BB:IQGain DB8');
      if( ~status ); clear;  return; end  

    [Status]=rs_send_command( InstrObject, ['FREQ:CW ' num2str(center_frequency) ' GHz' ]);
    if( ~status ); clear;  return; end
% 
     [Status]=rs_send_command( InstrObject, ['POW:POW ' num2str(input_power) ' dBm' ]);
      if( ~status ); clear;  return; end
      %
elseif i==2 %i=2,output ON
 % switch output ON
 [status, Result] = rs_send_query( InstrObject, 'OUTP:STAT ON; *OPC?' );
    if( ~status ); clear;  return; end   

elseif i==3 %i=3,output OFF
  [status, Result] = rs_send_query( InstrObject, 'OUTP:STAT OFF; *OPC?' );
    if( ~status ); clear;  return; end   
end
  % Read the instruments error queue
   status = rs_check_instrument_errors( InstrObject );
   if( ~status ); clear;  return; end


% delete instrument object
delete( InstrObject );

% clear variables
clear;

return;
end

