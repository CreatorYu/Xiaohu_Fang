function AWG_N8241A_OFF

    instrumentHandle = AWG_N8241A_Setup(625e6, 0.5);
    agt_awg_close(instrumentHandle);
  
end