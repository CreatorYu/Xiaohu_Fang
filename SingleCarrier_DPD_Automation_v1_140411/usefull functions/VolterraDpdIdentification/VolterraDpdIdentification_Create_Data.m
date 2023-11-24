function data = VolterraDpdIdentification_Create_Data(In_I,In_Q,Out_I,Out_Q)
    % Input and Output Waveforms
        data.In_I = In_I; data.Out_I = Out_I;
        data.In_Q = In_Q; data.Out_Q = Out_Q;
    % Complex signal
        data.Vin  = complex(In_I ,In_Q );
        data.Vout = complex(Out_I,Out_Q);
    % Amplitude
        data.Rin  = abs(data.Vin );
        data.Rout = abs(data.Vout);
    % Phase
        data.Phin  = angle(data.Vin );
        data.Phout = angle(data.Vout);
    % Aveage power
        data.AvgPin  = 10*log10(mean(data.Rin.^2)/100)+30;
        data.AvgPout = 10*log10(mean(data.Rout.^2)/100)+30;
    % Max power
        data.MaxPin  = 10*log10(max(data.Rin.^2)/100)+30;
        data.MaxPout = 10*log10(max(data.Rout.^2)/100)+30;
    % Power
        data.Pin  = 10*log10(data.Rin.^2 /100)+30;
        data.Pout = 10*log10(data.Rout.^2/100)+30;
    % Normalize the data
        data.Offset = data.AvgPout - data.AvgPin;
