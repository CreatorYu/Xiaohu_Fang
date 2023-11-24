function [RF_ON_Continue] = PushButton_Routine_Env (ComplexSignal,Fcarrier_array,FsampleTx_array, ...
    DAC_SamplingRate,Vdd_beforeDPD,shaping,Expansion_Margin,PAPR_input,PAPR_original, ...
    RF_ON_Continue,Transmitter_type,ESGAdd,RF_channel)

RF_ON_Continue = 0;        
while RF_ON_Continue == 0
    choice_RF_ON = menu('Turn ON the RF Source?', ...
    'RF ON and Continue','RF ON', 'RF OFF', 'Delay The Envelope');
    if choice_RF_ON == 1
            disp(['Turn ON the RF Source and Continue'])
            RF_ON_Continue = 1;
    elseif choice_RF_ON == 2
            disp(['Turn ON the RF Source'])
            RF_ON_Continue = 0;
            AWG_M8190A_Output_ON(RF_channel);
    elseif choice_RF_ON == 3
            disp(['Turn OFF the RF Source'])
            RF_ON_Continue = 0;                    
            AWG_M8190A_Output_OFF(RF_channel);
            pause(3)
    elseif choice_RF_ON == 4
            disp(['Delay The Envelope'])
            delay_str = inputdlg('Envelope Delay in nsec?');
            delay_Env = str2num(delay_str{:})*1e-9;
            [Vdd_beforeDPD_delayed, Vdd_beforeDPD_delayed] = FineTimeDelay_Adjust(Vdd_beforeDPD, Vdd_beforeDPD, FsampleTx, delay_Env);
            AWG_M8190A_SignalUpload_RF_Env_Dual_Channel(ComplexSignal, Fcarrier_array, FsampleTx_array, DAC_SamplingRate, false, false, Vdd_beforeDPD_delayed, Vdd_beforeDPD_delayed, shaping, Expansion_Margin,PAPR_input,PAPR_original);
            AWG_M8190A_Output_OFF(RF_channel);
            RF_ON_Continue = 0;
    end
end 
RF_ON_Continue = 0;  

end