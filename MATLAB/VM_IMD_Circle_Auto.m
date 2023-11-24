%function VM_CIRCLE_Auto
    close all;
    clear;
    instrreset;
    %instrhwinfo('gpib','agilent')
    PXA=gpib('agilent', 7, 18);
    PS1port=gpib('agilent', 7, 5); % The bottom one
    PS2port=gpib('agilent', 7, 9);
    DriverMDD = [pwd '\Instrument_Functions\PowerSupply_E3631A\agilent_e3631a.mdd'];
    PS1 = icdevice(DriverMDD, PS1port);
    PS2 = icdevice(DriverMDD, PS2port);
    
    fopen(PXA);
    connect(PS1);
    connect(PS2);

    PS1.Output(1).Enabled='on';
    PS2.Output(1).Enabled='on';

    Vcom1 = 0.805;
    Vos1 = 0.015;
    Vcom2 = 0.805;
    Vos2 = 0.015;
    Count = 0;
       
    for R = 0.6:0.1:0.6
        for Theta = 0:10:350
            IC = R * cos(degtorad(Theta));
            QC = R * sin(degtorad(Theta));
            PS2.Output(1).VoltageLevel=Vcom1 + IC + Vos1;
            PS2.Output(2).VoltageLevel=Vcom1 - IC - Vos1;
            PS1.Output(1).VoltageLevel=Vcom2 + QC - Vos2+0.002;
            PS1.Output(2).VoltageLevel=Vcom2 - QC + Vos2;
            pause(1);

            Count = Count + 1;
            
            M1(Count)=str2double(query(PXA, 'CALC:MARK1:Y?'));
            M2(Count)=str2double(query(PXA, 'CALC:MARK2:Y?'));
            M3(Count)=str2double(query(PXA, 'CALC:MARK3:Y?'));
            M4(Count)=str2double(query(PXA, 'CALC:MARK4:Y?'));
            M5(Count)=str2double(query(PXA, 'CALC:MARK5:Y?'));
            M6(Count)=str2double(query(PXA, 'CALC:MARK6:Y?'));
        end
    end
    
    invoke(PS1.System, 'beep');
    fclose(PXA);
%end
