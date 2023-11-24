%function VM_BB_Auto
    close all;
    clear;
    instrreset;
    %instrhwinfo('gpib','agilent')
    PXA=gpib('agilent', 7, 18);
    MXG=gpib('agilent', 7, 19);
    fopen(PXA);
    fopen(MXG);
    
    Fc = 2e9; %Carrier frequency
    FreqBB = 10e6; %MXG baseband frequency
    PowerMXG = 17; %MXG output power in dBm
    %MXGAdd = 19;
    Fstep = 10e6;
    Freqs = 10e6:Fstep:1e9;
    
    Count = 0;
    M1 = zeros(length(Freqs),1);
    %M2 = zeros(length(Freqs),1);
    
    fprintf(MXG, 'POW %d', PowerMXG);
    for FreqBB=Freqs
            Count = Count + 1;
            fprintf(MXG, 'SOUR:FREQ %d', FreqBB);
            FreqM = Fc - FreqBB;
            Span = 5*FreqBB;
            fprintf(PXA, ':FREQuency:CENTer %d', Fc-FreqBB);
            fprintf(PXA, 'CALC:MARK1:X %d', FreqM);
            pause(2);
            M1(Count)=str2double(query(PXA, 'CALC:MARK1:Y?'));
    end
    
    fclose(MXG);
    fclose(PXA);
    plot(Freqs+Fc, M1);
%end

