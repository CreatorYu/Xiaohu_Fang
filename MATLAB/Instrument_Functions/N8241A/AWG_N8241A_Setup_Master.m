% AWG N8241a setup
% refer to function agt_awg_setstate() for descriptions of parameters

function[instrumentHandle ]= AWG_N8241A_Setup_Master(Fsample, AWG_gain, Addr)

  disp('Opening a session to the instrument');
  [ instrumentHandle, errorN, errorMsg ] = agt_awg_open('TCPIP',['TCPIP0::', Addr, '::inst0::INSTR']);
  if( errorN ~= 0 )
    % An error occurred while trying to open the session.
    disp('Could not open a session to the instrument');
    return;
  end    
  agt_awg_setstate( instrumentHandle, 'outputmode', 'arb');    % arb is the default mode 
  agt_awg_setstate( instrumentHandle, 'opmode', 'cont');       % continuous mode
  agt_awg_setstate( instrumentHandle, 'samplerate', Fsample ); % sample rate has to be within the range of 1250MHz / (2^n) 
  agt_awg_setstate( instrumentHandle, 'clksrc', 'int' );       % DAC sampling clock source. 
  agt_awg_setstate( instrumentHandle, 'refclksrc', 'int' );    % 'ext' or 'int'. 10 MHz reference clock source.
  agt_awg_setstate( instrumentHandle, 'outputenabled', 'true' );
  agt_awg_setstate( instrumentHandle, 'outputconfig','diff');
  agt_awg_setstate( instrumentHandle, 'outputgain', AWG_gain);
  agt_awg_setstate( instrumentHandle, 'outputfilterenabled','true');
  agt_awg_setstate( instrumentHandle, 'outputbw', 500e6);  % output reconstruction filter bandwidth. choose between 250e6 or 500e6
  agt_awg_setstate( instrumentHandle, 'predistortenabled','false');
  
  agt_awg_setstate( instrumentHandle, 'trigthresholdA', 1);
  agt_awg_setstate( instrumentHandle, 'start', 'ext1')
  
  disp('marker enabled');
  %agt_awg_setstate( instrumentHandle, 'mkrsource','wfm_start', 1);
  agt_awg_setstate( instrumentHandle, 'mkrsource','wfm_start', 1);
  agt_awg_setstate( instrumentHandle, 'mkrpulsewidth', 100e-9);
  agt_awg_setstate( instrumentHandle, 'mkrdelay', 0);
 
end

