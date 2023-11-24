% AWG N8241a setup
% refer to function agt_awg_setstate() for descriptions of parameters

function[instrumentHandleMaster, instrumentHandleSlave]= AWG_N8241A_Setup_Multi(Fsample, AWG_Gain_Master, AWG_Gain_Slave)

  Master_Add          = '169.254.144.24';
  Slave_Add           = '169.254.93.209'; % 169.254.93.209

  disp(['Opening a session to the Master instrument (', Master_Add, ')']);
  disp('Transfering the waveform to the instrument');
  [ instrumentHandleMaster, errorN, errorMsg ] = agt_awg_open('TCPIP',['TCPIP0::', Master_Add, '::inst0::INSTR']);
  if( errorN ~= 0 )
    % An error occurred while trying to open the session.
    disp('Could not open a session to the instrument');
    return;
  end
  disp(['Opening a session to the Slave instrument (', Slave_Add, ')']);
  [ instrumentHandleSlave, errorN, errorMsg ] = agt_awg_open('TCPIP',['TCPIP0::', Slave_Add, '::inst0::INSTR']);
  if( errorN ~= 0 )
    % An error occurred while trying to open the session.
    disp('Could not open a session to the instrument');
    return;
  end
  
  % Common settings
  agt_awg_setstate( instrumentHandleMaster, 'outputenabled', 'true');
  agt_awg_setstate( instrumentHandleSlave, 'outputenabled', 'true');
  agt_awg_setstate( instrumentHandleMaster, 'outputmode', 'arb');
  agt_awg_setstate( instrumentHandleSlave, 'outputmode', 'arb');
  %agt_awg_setstate( instrumentHandleMaster, 'syncenabled', 'true');
  %agt_awg_setstate( instrumentHandleSlave, 'syncenabled', 'true');
  
  agt_awg_setstate( instrumentHandleMaster, 'syncmode', 'master');
  agt_awg_setstate( instrumentHandleSlave, 'syncmode', 'slave');
  agt_awg_setstate( instrumentHandleMaster, 'outputconfig', 'diff');
  agt_awg_setstate( instrumentHandleSlave, 'outputconfig', 'diff');
  agt_awg_setstate( instrumentHandleMaster, 'start', 'ext4');
  agt_awg_setstate( instrumentHandleSlave, 'start', 'ext4');
  agt_awg_setstate( instrumentHandleMaster, 'opmode', 'cont');
  agt_awg_setstate( instrumentHandleSlave, 'opmode', 'cont');
  agt_awg_setstate( instrumentHandleMaster, 'outputgain', AWG_Gain_Master);
  agt_awg_setstate( instrumentHandleSlave, 'outputgain', AWG_Gain_Slave);
  agt_awg_setstate( instrumentHandleMaster, 'outputfilterenabled', 'true');
  agt_awg_setstate( instrumentHandleSlave, 'outputfilterenabled', 'true');
  agt_awg_setstate( instrumentHandleMaster, 'outputbw', 500e6); 
  agt_awg_setstate( instrumentHandleSlave, 'outputbw', 500e6);
  agt_awg_setstate( instrumentHandleMaster, 'predistortenabled', 'false');
  agt_awg_setstate( instrumentHandleSlave, 'predistortenabled', 'false');
  
  
  % Master-specific
  agt_awg_setstate( instrumentHandleMaster, 'mkrsource', 'wfm_start', 4);
  agt_awg_setstate( instrumentHandleMaster, 'mkrsource', 'wfm_start', 2);
  agt_awg_setstate( instrumentHandleMaster, 'mkrsource', 'wfm_start', 1);
  agt_awg_setstate( instrumentHandleMaster, 'samplerate', Fsample);
  
  % Slave-specific
  
  agt_awg_setstate (instrumentHandleSlave, 'samplerate', Fsample);
  

end

